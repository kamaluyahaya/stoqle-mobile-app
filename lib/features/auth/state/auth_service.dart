import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/navigations/navigation_service.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

/// Provider
final authServiceProvider = StateNotifierProvider<AuthService, AuthState>((
  ref,
) {
  return AuthService(repo: AuthRepository())..loadFromStorage();
});

class AuthService extends StateNotifier<AuthState> {
  final AuthRepository repo;
  final _storage = const FlutterSecureStorage();

  AuthService({required this.repo}) : super(AuthState.initial());

  Map<String, dynamic> _normalizeResponse(Map<String, dynamic> resp) {
    if (resp.containsKey('data') && resp['data'] is Map<String, dynamic>) {
      return resp['data'] as Map<String, dynamic>;
    }
    return resp;
  }

  void clearTransientFlags() {
    state = state.copyWith(
      isOtpSent: false,
      otpVerified: false,
      message: null,
      isLoading: false,
    );
  }

  /// Persist token + user, update state
  Future<void> setAuth(String token, Map<String, dynamic>? user) async {
    final userMap = user ?? <String, dynamic>{};

    // 1) update in-memory state first (synchronous)
    final dynamic rawId =
        userMap['user_id'] ??
        userMap['id'] ??
        userMap['uid'] ??
        userMap['userId'];
    final int? parsedUserId = rawId is int
        ? rawId
        : (rawId is String ? int.tryParse(rawId) : null);

    state = state.copyWith(
      isLoading: false,
      token: token,
      email: userMap['email']?.toString(),
      phone: userMap['phone_no']?.toString() ?? userMap['phone']?.toString(),
      name: userMap['full_name']?.toString(),
      accountStatus: userMap['account_status']?.toString() ?? 'active',
      needsProfile: userMap['needsProfile'] ?? false,
      otpVerified: true,
      user_id: parsedUserId,
    );

    // 2) persist to secure storage asynchronously
    unawaited(_storage.write(key: 'auth_token', value: token));
    unawaited(_storage.write(key: 'auth_user', value: jsonEncode(userMap)));
  }

  /// Restore from secure storage
  Future<void> loadFromStorage() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _storage.read(key: 'auth_token');
      final userJson = await _storage.read(key: 'auth_user');

      if (token != null && userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;

        final dynamic rawId =
            user['user_id'] ?? user['id'] ?? user['uid'] ?? user['userId'];
        final int? parsedUserId = rawId is int
            ? rawId
            : (rawId is String ? int.tryParse(rawId) : null);

        state = state.copyWith(
          isLoading: false,
          token: token,
          email: user['email']?.toString(),
          phone: user['phone_no']?.toString() ?? user['phone']?.toString(),
          name: user['full_name']?.toString(),
          accountStatus: user['account_status']?.toString() ?? 'active',
          needsProfile: false,
          otpVerified: true,
          user_id: parsedUserId,
        );
        return;
      }
    } catch (e, st) {
      debugPrint('loadFromStorage error: $e\n$st');
    }

    state = state.copyWith(isLoading: false, token: null);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'auth_user');
    state = AuthState.initial();
    // just to be explicit - clear transient flags if any
    clearTransientFlags();
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }

  /// Login or register
  Future<void> login({
    String? email,
    String? phone,
    String? password,
    String? fullName,
    String? provider,
    String? fcmToken,
    String? deviceId,
    String? platform,
  }) async {
    state = state.copyWith(isLoading: true, message: null);

    try {
      final resp = await repo.registerOrLogin(
        email: email,
        phone: phone,
        password: password,
        fullName: fullName,
        provider: provider,
        fcmToken: fcmToken,
        deviceId: deviceId,
        platform: platform,
      );

      final payload = _normalizeResponse(resp);
      final token = (payload['token'] ?? payload['access_token'])?.toString();
      final user = payload['user'] is Map<String, dynamic>
          ? payload['user'] as Map<String, dynamic>
          : null;
      final msg = (resp['message'] ?? '').toString();

      final needsProfile =
          payload['needsProfile'] == true ||
          (payload['needsProfile']?.toString() == 'true');

      state = state.copyWith(toastMessage: resp['message'] ?? '');

      if (token != null) {
        await setAuth(token, user);
        state = state.copyWith(message: msg.isNotEmpty ? msg : 'Logged in');
        NavigationService.pushReplacementNamed('/dashboard');
        return;
      }

      final lmsg = msg.toLowerCase();
      final otpSentRegex = RegExp(
        r'otp.*(sent|resent|send)',
        caseSensitive: false,
      );

      if (lmsg.isNotEmpty && otpSentRegex.hasMatch(lmsg)) {
        state = state.copyWith(
          isLoading: false,
          isOtpSent: true,
          message: msg,
          // ensure identifier is preserved so UI can keep the form readOnly + resend works
          email: email,
          phone: phone,
          // also update toastMessage so listener can detect resends
          toastMessage: msg,
        );
        return;
      }

      if (needsProfile) {
        state = state.copyWith(
          isLoading: false,
          otpVerified: true,
          needsProfile: true,
          message: msg.isNotEmpty
              ? msg
              : 'OTP verified. Complete your profile.',
          email: email,
          phone: phone,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        message: msg.isNotEmpty ? msg : 'Unexpected response',
      );
    } catch (e, st) {
      debugPrint('login error: $e\n$st');
      state = state.copyWith(isLoading: false, message: e.toString());
    }
  }

  /// Verify OTP
  Future<void> verifyOtp({
    String? email,
    String? phone,
    required String otp,
    String? fcmToken,
    String? deviceId,
    String? platform,
  }) async {
    state = state.copyWith(isLoading: true, message: null);

    try {
      final resp = await repo.verifyOTP(
        email: email,
        phone: phone,
        otp: otp,
        fcmToken: fcmToken,
        deviceId: deviceId,
        platform: platform,
      );

      final payload = (resp['data'] is Map<String, dynamic>)
          ? resp['data'] as Map<String, dynamic>
          : resp;

      final msg = (resp['message'] ?? '').toString();
      final token = (payload['token'] ?? payload['access_token'])?.toString();
      final user = payload['user'] is Map<String, dynamic>
          ? payload['user'] as Map<String, dynamic>
          : null;

      final dynamic rawUserId =
          user?['user_id'] ??
          user?['id'] ??
          user?['userId'] ??
          user?['uid'] ??
          payload['user_id'];
      final int? parsedUserId = rawUserId is int
          ? rawUserId
          : (rawUserId is String ? int.tryParse(rawUserId) : null);

      final needsProfile =
          payload['needsProfile'] == true ||
          (payload['needsProfile']?.toString() == 'true') ||
          (user != null && user['account_status']?.toString() == 'new_account');

      // Logged in
      if (token != null) {
        await setAuth(token, user);
        state = state.copyWith(message: msg.isNotEmpty ? msg : 'Logged in');

        NavigationService.pushReplacementNamed(
          '/dashboard',
          arguments: {'email': user?['email'] ?? email ?? phone},
        );
        return;
      }

      // Needs profile (no token yet)
      if (needsProfile) {
        state = state.copyWith(
          isLoading: false,
          otpVerified: true,
          needsProfile: true,
          message: msg.isNotEmpty ? msg : 'OTP verified. Complete profile.',
          email: user?['email']?.toString() ?? email,
          phone: user?['phone_no']?.toString() ?? phone,
          name: user?['full_name']?.toString(),
          accountStatus: user?['account_status']?.toString() ?? 'new_account',
          user_id: parsedUserId,
        );

        NavigationService.pushReplacementNamed(
          '/user_fullname',
          arguments: {
            'user_id': parsedUserId,
            'email': user?['email'],
            'phone': user?['phone_no'],
            'name': user?['full_name'],
            'raw_user': user,
          },
        );
        return;
      }

      // Fallback
      state = state.copyWith(
        isLoading: false,
        message: msg.isNotEmpty ? msg : 'Unexpected response',
      );
    } catch (e, st) {
      debugPrint('verifyOtp error: $e\n$st');
      state = state.copyWith(isLoading: false, message: e.toString());
    }
  }

  /// Update Full Name
  Future<void> updateName({
    required int userId,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, message: null);

    try {
      final data = await repo.updateName(userId: userId, fullName: fullName);

      final msg = (data['message'] ?? '').toString();
      final token = data['data']?['token'];
      final user = data['data']?['user'];

      if (token != null && user != null) {
        await setAuth(token.toString(), user);
        state = state.copyWith(
          message: msg.isNotEmpty ? msg : 'Profile updated',
        );
        NavigationService.pushReplacementNamed('/dashboard');
      } else {
        state = state.copyWith(
          isLoading: false,
          message: msg.isNotEmpty ? msg : 'Profile not updated',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, message: e.toString());
    }
  }
}
