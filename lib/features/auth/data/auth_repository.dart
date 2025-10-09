import '../../../core/services/dio_client.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient();

  /// Unified register-or-login endpoint (password, OTP, google fast-path)
  Future<Map<String, dynamic>> registerOrLogin({
    String? email,
    String? phone, // caller-friendly name (we map to phone_no)
    String? password,
    String? fullName,
    String? provider,
    String? fcmToken,
    String? deviceId,
    String? platform,
  }) async {
    try {
      const String endpoint = '/register-or-login';
      final Map<String, dynamic> payload = {};

      if (email != null) payload['email'] = email;
      if (phone != null)
        payload['phone_no'] = phone; // backend expects phone_no
      if (password != null && password.isNotEmpty)
        payload['password'] = password;
      if (fullName != null) payload['full_name'] = fullName;
      if (provider != null) payload['provider'] = provider;

      // device info
      if (fcmToken != null) payload['fcm_token'] = fcmToken;
      if (deviceId != null) payload['device_id'] = deviceId;
      if (platform != null) payload['platform'] = platform;

      final response = await _dioClient.post(endpoint, data: payload);

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'message': response.data.toString()};
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update user's full name
  Future<Map<String, dynamic>> updateName({
    required int userId,
    required String fullName,
  }) async {
    try {
      final response = await _dioClient.put(
        '/user/$userId/name',
        data: {"full_name": fullName},
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'message': response.data.toString()};
      }
    } catch (e) {
      rethrow;
    }
  }

  /// If you still want a pure password-only login endpoint, support /login
  Future<Map<String, dynamic>> loginWithPassword({
    String? email,
    String? phone,
    required String password,
    String? fcmToken,
    String? deviceId,
    String? platform,
  }) async {
    try {
      const String endpoint = '/login';
      final Map<String, dynamic> payload = {};
      if (email != null) payload['email'] = email;
      if (phone != null) payload['phone_no'] = phone;
      payload['password'] = password;

      if (fcmToken != null) payload['fcm_token'] = fcmToken;
      if (deviceId != null) payload['device_id'] = deviceId;
      if (platform != null) payload['platform'] = platform;

      final response = await _dioClient.post(endpoint, data: payload);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'message': response.data.toString()};
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP endpoint (email OR phone must be provided). Matches backend keys.
  Future<Map<String, dynamic>> verifyOTP({
    String? email,
    String? phone,
    required String otp,
    String? fcmToken,
    String? deviceId,
    String? platform,
  }) async {
    try {
      const String endpoint = '/verify-otp';
      final Map<String, dynamic> payload = {'otp': otp};

      if (email != null) payload['email'] = email;
      if (phone != null) payload['phone_no'] = phone;

      if (fcmToken != null) payload['fcm_token'] = fcmToken;
      if (deviceId != null) payload['device_id'] = deviceId;
      if (platform != null) payload['platform'] = platform;

      final response = await _dioClient.post(endpoint, data: payload);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {'message': response.data.toString()};
      }
    } catch (e) {
      rethrow;
    }
  }
}
