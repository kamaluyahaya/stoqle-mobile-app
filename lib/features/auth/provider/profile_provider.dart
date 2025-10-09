// profile_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/core/services/profile_service.dart';
import 'package:stoqle/core/utils/constants.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';

/// Simple uploading state used by the UI / notifier to show upload progress.
final profileUploadingProvider = StateProvider<bool>((ref) => false);

// Provide ProfileService (adjust baseUrl & auth provider as required)
final profileServiceProvider = Provider<ProfileService>((ref) {
  ref.watch(authServiceProvider);
  return ProfileService(
    baseUrl: ApiConstants.baseUrl, // change to your real base url
    ref: ref,
    // auth: auth,
  );
});
