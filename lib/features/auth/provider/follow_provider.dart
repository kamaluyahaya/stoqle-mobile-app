// lib/providers/follow_providers.dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/component/lib/follow_params.dart'; // contains FollowTab
import 'package:stoqle/core/services/follower_service.dart';
import 'package:stoqle/core/utils/constants.dart';
import 'package:stoqle/features/auth/state/user_summary.dart';
import 'auth_provider.dart'; // ensure path is correct

// ApiService provider (adjust imports/path if necessary)
final apiServiceProvider = Provider<ApiService>((ref) {
  final auth = ref.watch(authServiceProvider); // adjust to your auth provider
  final base = ApiConstants.baseUrl;
  return ApiService(baseUrl: base, authToken: auth?.token);
});

// ApiService provider (adjust imports/path if necessary)

enum FollowTab { friends, following, followers, recommend }

class PaginatedState {
  final List<UserSummary> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final int offset;
  final int limit;
  final String? error;

  PaginatedState({
    required this.items,
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.offset = 0,
    this.limit = 20,
    this.error,
  });

  PaginatedState copyWith({
    List<UserSummary>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    int? offset,
    int? limit,
    String? error,
  }) {
    return PaginatedState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      error: error,
    );
  }
}

class PaginatedNotifier extends StateNotifier<PaginatedState> {
  final Ref ref;
  final FollowTab tab;
  final int targetUserId;

  PaginatedNotifier(this.ref, {required this.tab, required this.targetUserId})
    : super(PaginatedState(items: [], loading: false));

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null, offset: 0);
    try {
      final api = ref.read(apiServiceProvider);
      List<UserSummary> items;

      if (tab == FollowTab.followers) {
        items = await api.fetchFollowers(
          targetUserId: targetUserId,
          limit: state.limit,
          offset: 0,
        );
      } else if (tab == FollowTab.following) {
        items = await api.fetchFollowing(
          targetUserId: targetUserId,
          limit: state.limit,
          offset: 0,
        );
      } else if (tab == FollowTab.recommend) {
        items = await api.fetchRecommendations(
          targetUserId: targetUserId,
          limit: state.limit,
          offset: 0,
        );
      } else if (tab == FollowTab.friends) {
        // reuse existing fetchFollowers endpoint, then filter mutual (both flags true)
        final fetched = await api.fetchFollowers(
          targetUserId: targetUserId,
          limit: state.limit,
          offset: 0,
        );
        items = fetched
            .where(
              (u) =>
                  (u.isFollowedByViewer ?? false) &&
                  (u.isFollowingViewer ?? false),
            )
            .toList();
      } else {
        items = [];
      }

      state = state.copyWith(
        items: items,
        loading: false,
        hasMore: items.length >= state.limit,
        offset: items.length,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) {
      return;
    }
    state = state.copyWith(loadingMore: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);
      final nextOffset = state.offset;
      List<UserSummary> items;

      if (tab == FollowTab.following) {
        items = await api.fetchFollowing(
          targetUserId: targetUserId,
          limit: state.limit,
          offset: nextOffset,
        );
      } else if (tab == FollowTab.followers) {
        items = await api.fetchFollowers(
          targetUserId: targetUserId,
          limit: state.limit,
          offset: nextOffset,
        );
      } else if (tab == FollowTab.recommend) {
        items = await api.fetchRecommendations(
          targetUserId: targetUserId,
          limit: state.limit,
          offset: nextOffset,
        );
      } else if (tab == FollowTab.friends) {
        // For friends we fetch next page of followers and filter mutuals.
        final fetched = await api.fetchFollowers(
          targetUserId: targetUserId,
          limit: state.limit,
          offset: nextOffset,
        );
        items = fetched
            .where(
              (u) =>
                  (u.isFollowedByViewer ?? false) &&
                  (u.isFollowingViewer ?? false),
            )
            .toList();
      } else {
        items = [];
      }

      state = state.copyWith(
        items: [...state.items, ...items],
        loadingMore: false,
        hasMore: items.length >= state.limit,
        offset: state.offset + items.length,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    }
  }

  // Optimistic toggle
  Future<void> toggleFollow(
    int targetId, {
    required bool currentlyFollowing,
  }) async {
    final api = ref.read(apiServiceProvider);

    // optimistic update: update items list
    state = state.copyWith(
      items: state.items.map((u) {
        if (u.userId == targetId) {
          final int newFollowers = currentlyFollowing
              ? max(0, u.totalFollowers - 1)
              : (u.totalFollowers + 1);
          return u.copyWith(
            isFollowedByViewer: !currentlyFollowing,
            totalFollowers: newFollowers,
          );
        }
        return u;
      }).toList(),
    );

    try {
      if (currentlyFollowing) {
        await api.unfollowUser(targetId);
      } else {
        await api.followUser(targetId);
      }
    } catch (e) {
      // revert on error
      state = state.copyWith(
        items: state.items.map((u) {
          if (u.userId == targetId) {
            return u.copyWith(isFollowedByViewer: currentlyFollowing);
          }
          return u;
        }).toList(),
      );
      rethrow;
    }
  }
}

// provider factory
final paginatedNotifierProvider =
    StateNotifierProvider.family<
      PaginatedNotifier,
      PaginatedState,
      FollowParams
    >((ref, params) {
      return PaginatedNotifier(
        ref,
        tab: params.tab,
        targetUserId: params.userId,
      );
    });
