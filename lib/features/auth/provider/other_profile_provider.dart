import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/core/services/profile_service.dart';
import 'package:stoqle/features/auth/models/profile_model.dart';
import '../provider/auth_provider.dart';

// family provider to fetch arbitrary user profiles by id
class ProfileByIdNotifier extends StateNotifier<AsyncValue<Profile>> {
  final Ref ref;
  final ProfileService service;
  final String userId;

  ProfileByIdNotifier(this.ref, this.service, this.userId)
    : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    try {
      state = const AsyncValue.loading();
      final profile = await service.fetchProfileById(userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => fetch();
}

final profileByIdProvider =
    StateNotifierProvider.family<
      ProfileByIdNotifier,
      AsyncValue<Profile>,
      String
    >((ref, userId) {
      final service = ref.watch(profileServiceProvider);
      final notifier = ProfileByIdNotifier(ref, service, userId);

      // optional: re-fetch if auth changes (token refresh)
      ref.listen(authServiceProvider, (prev, next) {
        if (prev?.token != next.token) {
          notifier.refresh();
        }
      });

      return notifier;
    });
