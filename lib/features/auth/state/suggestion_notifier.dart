import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/core/services/suggestion_services.dart';

import '../models/suggestion_model.dart';
import '../models/suggestion_param.dart';

/// A StateNotifier that holds a list of SuggestionUser for a specific
/// SuggestionParams. It loads on construction and exposes fetch / follow APIs.
class SuggestionNotifier
    extends StateNotifier<AsyncValue<List<SuggestionUser>>> {
  final SuggestionService service;
  final SuggestionParams params;

  SuggestionNotifier(this.service, this.params)
    : super(const AsyncValue.loading()) {
    fetch(); // initial load
  }

  /// Fetch using the notifier's params.
  Future<void> fetch() async {
    try {
      state = const AsyncValue.loading();
      final users = await service.fetchSuggestions(
        limit: params.limit,
        offset: params.offset,
        q: params.q,
      );
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Force re-fetch (public helper).
  Future<void> refresh() => fetch();

  /// Optimistic follow: remove the user locally immediately, call API.
  /// If API fails, we revert by re-fetching the list.
  ///
  /// Returns true when follow succeeded, false otherwise.
  Future<bool> followUser(int userId) async {
    // Snapshot current data (if any)
    final current = state.maybeWhen(
      data: (list) => list,
      orElse: () => <SuggestionUser>[],
    );
    // Optimistically remove the user
    final updated = List<SuggestionUser>.from(current)
      ..removeWhere((u) => u.userId == userId);
    state = AsyncValue.data(updated);

    try {
      final success = await service.followUser(userId);
      if (success) {
        return true;
      } else {
        // revert by re-fetching if API returned non-success
        await fetch();
        return false;
      }
    } catch (error, st) {
      // revert on error and keep the error visible if you want:
      await fetch();
      // optionally set an error state if you want consumers to see it:
      // state = AsyncValue.error(error, st);
      return false;
    }
  }
}

/// Provider family: one SuggestionNotifier instance per SuggestionParams.
/// autoDispose so unused param instances free memory.
final suggestionNotifierProvider = StateNotifierProvider.autoDispose
    .family<
      SuggestionNotifier,
      AsyncValue<List<SuggestionUser>>,
      SuggestionParams
    >((ref, params) {
      final service = ref.read(suggestionServiceProvider);
      return SuggestionNotifier(service, params);
    });
