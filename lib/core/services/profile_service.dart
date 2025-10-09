import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/core/utils/constants.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';
import '../../features/auth/models/profile_model.dart';

// 👉 Provider must be outside the class
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(baseUrl: ApiConstants.baseUrl, ref: ref);
});

class ProfileService {
  final String baseUrl;
  final Ref ref;
  final Dio _dio;

  ProfileService({required this.baseUrl, required this.ref})
    : _dio = Dio(
        BaseOptions(baseUrl: baseUrl, headers: {"Accept": "application/json"}),
      );

  Future<Map<String, dynamic>> uploadProfilePictureBytes(
    Uint8List bytes, {
    required String filename,
    String fieldName = 'profile_pic',
  }) async {
    final auth = ref.read(authServiceProvider);
    final token = auth.token;
    final userId = auth.user_id; // adapt property name

    if (token == null || userId == null) {
      throw Exception('No auth token or user id available');
    }

    final formData = FormData.fromMap({
      fieldName: MultipartFile.fromBytes(bytes, filename: filename),
    });

    try {
      final response = await _dio.post(
        '/profile/$userId/profile-pic',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Upload failed: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Profile> fetchProfile() async {
    final auth = ref.read(authServiceProvider);
    final token = auth.token;

    if (token == null || token.isEmpty) {
      throw Exception("No auth token found. Please login again.");
    }

    try {
      final response = await _dio.get(
        '/auth/profile/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data['data'] ?? response.data;
        return Profile.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to fetch profile (${response.statusCode}): ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch profile: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Profile> fetchProfileById(String userId) async {
    final auth = ref.read(authServiceProvider);
    final token = auth.token;

    if (token == null || token.isEmpty) {
      throw Exception("No auth token found. Please login again.");
    }

    try {
      final response = await _dio.get(
        '/profile/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data['data'] ?? response.data;
        return Profile.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to fetch profile (${response.statusCode}): ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch profile: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }
}
