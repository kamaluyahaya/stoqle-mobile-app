import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/core/services/note_service.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';
import 'package:stoqle/features/auth/provider/socket_provider.dart';
import '../models/socialPost.dart';

// NotesNotifier (reusable)
typedef FetchPostsFn = Future<List<SocialPost>> Function();

class NotesNotifier extends StateNotifier<AsyncValue<List<SocialPost>>> {
  final Ref ref;
  final FetchPostsFn fetchPosts;
  final bool filterToMyPosts;

  // We keep references to the socket callbacks to remove them on dispose
  void Function(dynamic)? _onCreated;
  void Function(dynamic)? _onUpdated;
  void Function(dynamic)? _onDeleted;

  NotesNotifier(this.ref, this.fetchPosts, {this.filterToMyPosts = false})
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final auth = ref.read(authServiceProvider);
    if (auth.token == null || auth.user_id == null) {
      state = AsyncValue.error('No token or userId', StackTrace.current);
      return;
    }

    await fetch();

    final socketService = ref.read(socketServiceProvider);

    _onCreated = (data) {
      try {
        final note = SocialPost.fromJson(Map<String, dynamic>.from(data));
        if (filterToMyPosts) {
          final authNow = ref.read(authServiceProvider);
          if (note.userId != authNow.user_id) return; // ignore others
        }
        state = AsyncValue.data([note, ...(state.value ?? [])]);
      } catch (e) {
        print('⚠️ note_created parse error: $e');
      }
    };

    _onUpdated = (data) {
      try {
        final note = SocialPost.fromJson(Map<String, dynamic>.from(data));
        if (filterToMyPosts) {
          final authNow = ref.read(authServiceProvider);
          if (note.userId != authNow.user_id) return;
        }
        final updated = (state.value ?? [])
            .map((n) => n.id == note.id ? note : n)
            .toList();
        state = AsyncValue.data(updated);
      } catch (e) {
        print('⚠️ note_updated parse error: $e');
      }
    };

    _onDeleted = (data) {
      try {
        final id = data['id'];
        final updated = (state.value ?? []).where((n) => n.id != id).toList();
        state = AsyncValue.data(updated);
      } catch (e) {
        print('⚠️ note_deleted parse error: $e');
      }
    };

    socketService.on('post_created', _onCreated!);
    socketService.on('note_updated', _onUpdated!);
    socketService.on('note_deleted', _onDeleted!);

    ref.onDispose(() {
      socketService.off('post_created', _onCreated!);
      socketService.off('note_updated', _onUpdated!);
      socketService.off('note_deleted', _onDeleted!);
    });
  }

  Future<void> fetch() async {
    try {
      state = const AsyncValue.loading();
      final posts = await fetchPosts();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => fetch();
}

// Providers
final notesNotifierProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<SocialPost>>>((ref) {
      final service = ref.watch(notesServiceProvider);
      final notifier = NotesNotifier(
        ref,
        service.fetchMyNotes,
        filterToMyPosts: true,
      );

      // keep auth-driven refresh behavior
      ref.listen(authServiceProvider, (prev, next) {
        if (prev?.token != next.token || prev?.user_id != next.user_id) {
          notifier.refresh();
        }
      });

      return notifier;
    });

final userPostsNotifierProvider =
    StateNotifierProvider.family<
      NotesNotifier,
      AsyncValue<List<SocialPost>>,
      String
    >((ref, userId) {
      final service = ref.watch(notesServiceProvider);
      final notifier = NotesNotifier(
        ref,
        () => service.fetchByUser(userId), // pass fetch function
        filterToMyPosts: false,
      );

      // Re-fetch if auth changes (e.g., logout/login)
      ref.listen(authServiceProvider, (prev, next) {
        if (prev?.token != next.token || prev?.user_id != next.user_id) {
          notifier.refresh();
        }
      });

      return notifier;
    });

final notesAllNotifierProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<SocialPost>>>((ref) {
      final service = ref.watch(notesServiceProvider);
      final notifier = NotesNotifier(
        ref,
        service.fetchAll,
        filterToMyPosts: false,
      );

      ref.listen(authServiceProvider, (prev, next) {
        if (prev?.token != next.token || prev?.user_id != next.user_id) {
          notifier.refresh();
        }
      });

      return notifier;
    });
