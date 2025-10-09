// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stoqle/features/auth/state/user_summary.dart';

class ApiService {
  final String baseUrl;
  final String? authToken;

  ApiService({required this.baseUrl, this.authToken});

  Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _getJson(Uri url) async {
    final r = await http.get(url, headers: _headers());
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    }
    throw Exception('Request failed (${r.statusCode}) ${r.body}');
  }

  Future<List<UserSummary>> fetchFollowers({
    required int targetUserId,
    int limit = 20,
    int offset = 0,
    String? q,
  }) async {
    final query = {
      'limit': '$limit',
      'offset': '$offset',
      if (q != null && q.isNotEmpty) 'q': q,
    };
    final uri = Uri.parse(
      '$baseUrl/users/$targetUserId/followers',
    ).replace(queryParameters: query);

    final json = await _getJson(uri);
    print("FOLLOWERS JSON: $json"); // debug log

    final data = json['data'] ?? {};
    final items = (data['items'] ?? []) as List<dynamic>;

    return items
        .map((e) => UserSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserSummary>> fetchFollowing({
    required int targetUserId,
    int limit = 20,
    int offset = 0,
    String? q,
  }) async {
    final query = {
      'limit': '$limit',
      'offset': '$offset',
      if (q != null && q.isNotEmpty) 'q': q,
    };
    final uri = Uri.parse(
      '$baseUrl/users/$targetUserId/following',
    ).replace(queryParameters: query);

    final json = await _getJson(uri);
    print("FOLLOWING JSON: $json"); // debug log

    final data = json['data'] ?? {};
    final items = (data['items'] ?? []) as List<dynamic>;

    return items
        .map((e) => UserSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Recommend endpoint - change path if you have a different one
  Future<List<UserSummary>> fetchRecommendations({
    required int targetUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/users/$targetUserId/suggestions',
    ).replace(queryParameters: {'limit': '$limit', 'offset': '$offset'});
    final json = await _getJson(uri);
    final items = (json['data']?['items'] ?? []) as List<dynamic>;
    print("FOLLOWRS JSON: $items");
    return items
        .map((e) => UserSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> followUser(int targetUserId) async {
    final uri = Uri.parse('$baseUrl/follow/$targetUserId/follow');
    final r = await http.post(uri, headers: _headers());
    if (r.statusCode < 200 || r.statusCode >= 300)
      throw Exception('Follow failed: ${r.body}');
  }

  Future<void> unfollowUser(int targetUserId) async {
    final uri = Uri.parse('$baseUrl/follow/$targetUserId/unfollow');
    final r = await http.post(uri, headers: _headers());
    if (r.statusCode < 200 || r.statusCode >= 300)
      throw Exception('Unfollow failed: ${r.body}');
  }
}
