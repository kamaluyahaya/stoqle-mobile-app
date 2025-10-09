// lib/features/social/state/comments_notifier.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';
import 'package:stoqle/features/auth/provider/socket_provider.dart';
import 'package:stoqle/features/auth/state/comment_service.dart';
import 'package:stoqle/features/auth/state/comment_state.dart';
import 'package:stoqle/features/auth/state/socket_service.dart';
import '../models/comment_model.dart';

final commentsServiceProvider = Provider<CommentsService>(
  (ref) => CommentsService(),
);

final commentsNotifierProvider = StateNotifierProvider.family
    .autoDispose<CommentsNotifier, CommentsState, int>((ref, postId) {
      final svc = ref.watch(commentsServiceProvider);
      final socketSvc = ref.watch(socketServiceProvider);
      final auth = ref.watch(authServiceProvider);

      final notifier = CommentsNotifier(
        ref: ref,
        postId: postId,
        service: svc,
        socketService: socketSvc,
        authToken: auth?.token,
        currentUserId: auth?.user_id,
      );

      ref.onDispose(() => notifier.dispose());
      return notifier;
    });

class CommentsNotifier extends StateNotifier<CommentsState> {
  final Ref ref;
  final int postId;
  final CommentsService service;
  final SocketService? socketService;
  final String? authToken;
  final int? currentUserId;

  StreamSubscription? _socketSub;

  CommentsNotifier({
    required this.ref,
    required this.postId,
    required this.service,
    required this.socketService,
    this.authToken,
    this.currentUserId,
  }) : super(CommentsState()) {
    _init();
  }

  void _init() {
    loadComments();
    _setupSocketListeners();
  }

  Future<void> loadComments({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(isLoading: true, page: 1, comments: []);
      } else {
        state = state.copyWith(isLoading: true);
      }

      final pageToLoad = refresh ? 1 : state.page;

      final result = await service.fetchComments(
        postId: postId,
        page: pageToLoad,
        limit: 50,
        extraHeaders: authToken != null
            ? {'Authorization': 'Bearer $authToken'}
            : null,
      );

      final fetched = (result['comments'] as List<Comment>);
      final countRaw = result['count'] ?? fetched.length;

      final count = (countRaw is int)
          ? countRaw
          : int.tryParse(countRaw.toString()) ?? fetched.length;

      // 👇 grab post_total_like
      final postTotalLikeRaw = result['post_total_like'] ?? 0;
      final postTotalLike = (postTotalLikeRaw is int)
          ? postTotalLikeRaw
          : int.tryParse(postTotalLikeRaw.toString()) ?? 0;

      // 👇 grab liked_by_user
      final likedByUserRaw = result['user_has_liked'] ?? false;
      final likedByUser = likedByUserRaw is bool
          ? likedByUserRaw
          : likedByUserRaw.toString() == 'true';

      final newList = refresh ? fetched : [...state.comments, ...fetched];
      final hasMore = newList.length < count;

      state = state.copyWith(
        isLoading: false,
        comments: newList,
        count: count,
        postTotalLike: postTotalLike,
        userHasLiked: likedByUser, // include here
        page: pageToLoad + 1,
        hasMore: hasMore,
        error: null,
      );
      print("DATASSSSSSSSSSSSSSSSSSSSSSSS: ${state.userHasLiked}");
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshComments() => loadComments(refresh: true);

  void addLocalComment(Comment c) {
    final newList = [c, ...state.comments];
    state = state.copyWith(comments: newList, count: state.count + 1);
  }

  /// createComment uses singular endpoint per your server: /social/:postId/comment
  // in CommentsNotifier class (lib/features/social/state/comments_notifier.dart)
  Future<Comment> createComment(String content) async {
    try {
      final created = await service.createComment(
        postId: postId,
        content: content,
        extraHeaders: authToken != null
            ? {'Authorization': 'Bearer $authToken'}
            : null,
      );

      addLocalComment(created);

      try {
        socketService?.emit('create_comment', {
          'post_id': postId,
          'comment_id': created.commentId,
        });
      } catch (_) {}

      return created;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint('createComment error in notifier: $e');
      rethrow;
    }
  }

  /// Like/unlike comment with optimistic UI
  Future<void> likeComment(int commentId) async {
    final idx = state.comments.indexWhere((c) => c.commentId == commentId);
    if (idx == -1) return;

    final old = state.comments[idx];
    final toggledLike = !old.likedByUser;

    final updatedComment = old.copyWith(
      likesCount: toggledLike
          ? old.likesCount + 1
          : (old.likesCount > 0 ? old.likesCount - 1 : 0),
      likedByUser: toggledLike,
    );

    final newList = [...state.comments];
    newList[idx] = updatedComment;
    state = state.copyWith(comments: newList);

    try {
      await service.likeComment(
        commentId,
        extraHeaders: authToken != null
            ? {'Authorization': 'Bearer $authToken'}
            : null,
      );
    } catch (e) {
      // rollback
      final rollbackList = [...state.comments];
      rollbackList[idx] = old;
      state = state.copyWith(comments: rollbackList, error: e.toString());
    }
  }

  /// Like/unlike post (you can call this from Post bottom bar)
  Future<void> likePost(int postId) async {
    try {
      // optimistic update of the post UI should be handled by Post's provider or parent.
      await service.likePost(
        postId,
        extraHeaders: authToken != null
            ? {'Authorization': 'Bearer $authToken'}
            : null,
      );

      // optionally emit socket event
      try {
        socketService?.emit('post_like', {'post_id': postId});
      } catch (_) {}
    } catch (e) {
      // handle error (e.g., show snackbar) — keep notifier stateless here
      state = state.copyWith(error: e.toString());
    }
  }

  void _setupSocketListeners() {
    if (socketService == null) return;

    try {
      socketService!.on('comment_created', (payload) {
        if (payload == null) return;
        try {
          final map = payload is Map
              ? Map<String, dynamic>.from(payload)
              : Map<String, dynamic>.from(payload as dynamic);

          // Always assume payload is a full enriched row
          final incoming = Comment.fromJson(map);

          if (incoming.postId == postId) {
            final exists = state.comments.any(
              (c) => c.commentId == incoming.commentId,
            );
            if (!exists) addLocalComment(incoming);
          }
        } catch (_) {}
      });

      socketService!.on('post_comment', (payload) {
        if (payload == null) return;
        try {
          final map = payload is Map
              ? Map<String, dynamic>.from(payload)
              : Map<String, dynamic>.from(payload as dynamic);

          final incoming = Comment.fromJson(map);

          if (incoming.postId == postId) {
            final exists = state.comments.any(
              (c) => c.commentId == incoming.commentId,
            );
            if (!exists) addLocalComment(incoming);
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      socketService?.off('comment_created');
      socketService?.off('post_comment');
    } catch (_) {}
    _socketSub?.cancel();
    super.dispose();
  }
}
