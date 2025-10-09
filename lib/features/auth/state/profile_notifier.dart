// profile_notifier.dart
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/core/services/note_service.dart';
import 'package:stoqle/core/services/profile_service.dart';
import 'package:stoqle/features/auth/models/profile_model.dart';
import 'package:stoqle/features/auth/models/socialPost.dart';
import 'package:stoqle/features/auth/provider/profile_provider.dart'
    hide profileServiceProvider;
import 'package:stoqle/features/auth/provider/auth_provider.dart';

class ProfileStateNotifier extends StateNotifier<AsyncValue<Profile>> {
  final Ref ref;
  final ProfileService service;

  ProfileStateNotifier(this.ref, this.service)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    // Use read here for initial check; we also listen to auth changes below
    final auth = ref.read(authServiceProvider);
    if (auth?.token == null || auth?.user_id == null) {
      state = AsyncValue.error('No token or userId', StackTrace.current);
      return;
    }

    await fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      state = const AsyncValue.loading();
      // ProfileService.fetchProfile() returns a Profile (per your Dio service)
      final profile = await service.fetchProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => fetchProfile();

  /// Upload bytes and update state using server response.
  /// Returns true on success, false on failure.
  Future<bool> uploadProfilePicture(
    Uint8List bytes, {
    String filename = 'profile.jpg',
  }) async {
    ref.read(profileUploadingProvider.notifier).state = true;
    try {
      final resp = await service.uploadProfilePictureBytes(
        bytes,
        filename: filename,
      );
      // API likely returns { status, message, data: { user: {...}, ... } }
      final data = resp['data'] ?? resp;
      // Create Profile instance from returned data and update state
      final updatedProfile = Profile.fromJson(data as Map<String, dynamic>);
      state = AsyncValue.data(updatedProfile);
      return true;
    } catch (e, st) {
      // Keep previous state rather than clearing it; surface the error
      state = AsyncValue.error(e, st);
      return false;
    } finally {
      ref.read(profileUploadingProvider.notifier).state = false;
    }
  }
}

final postProvider = FutureProvider.family<SocialPost, int>((ref, postId) {
  final svc = ref.watch(notesServiceProvider);
  return svc.fetchPost(postId);
});

/// Factory provider for the notifier. It watches the profileServiceProvider
/// to obtain the service instance (which itself reads auth when needed).
final profileNotifierProvider =
    StateNotifierProvider<ProfileStateNotifier, AsyncValue<Profile>>((ref) {
      final service = ref.watch(profileServiceProvider);
      final notifier = ProfileStateNotifier(ref, service);

      // react to auth changes: refresh profile when token/userId changes
      ref.listen(authServiceProvider, (previous, next) {
        final prevToken = previous?.token;
        final nextToken = next?.token;
        final prevId = previous?.user_id;
        final nextId = next?.user_id;

        if (prevToken != nextToken || prevId != nextId) {
          notifier.refresh();
        }
      });

      return notifier;
    });
