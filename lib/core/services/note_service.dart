import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:stoqle/core/utils/constants.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';
import '../../features/auth/models/socialPost.dart';

// NotesService + provider
final notesServiceProvider = Provider<NotesService>((ref) {
  return NotesService(baseUrl: ApiConstants.baseUrl, ref: ref);
});

class NotesService {
  final String baseUrl;
  final Ref ref;

  NotesService({required this.baseUrl, required this.ref});

  List<SocialPost> _parsePosts(Map<String, dynamic> body) {
    final data = body['data'] as Map<String, dynamic>?;
    final posts = (data?['posts'] as List<dynamic>?) ?? [];
    return posts
        .map<SocialPost>((p) => SocialPost.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialPost>> fetchMyNotes() async {
    final auth = ref.read(authServiceProvider);
    final token = auth.token;

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    final uri = Uri.parse('$baseUrl/social/me');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      return _parsePosts(body);
    } else {
      throw Exception(
        'Failed to fetch notes (${resp.statusCode}): ${resp.body}',
      );
    }
  }

  // inside NotesService
  Future<SocialPost> fetchPost(int postId) async {
    final auth = ref.read(authServiceProvider);
    final token = auth.token;
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    final uri = Uri.parse('$baseUrl/social/$postId');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      final postMap = data?['post'] as Map<String, dynamic>?;
      if (postMap == null) throw Exception('No post returned');
      return SocialPost.fromJson(postMap);
    } else {
      throw Exception(
        'Failed to fetch post (${resp.statusCode}): ${resp.body}',
      );
    }
  }

  Future<List<SocialPost>> fetchByUser(String userId) async {
    final auth = ref.read(authServiceProvider);
    final token = auth.token;

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    final uri = Uri.parse('$baseUrl/social/user/$userId');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      return _parsePosts(body);
    } else {
      throw Exception(
        'Failed to fetch user posts (${resp.statusCode}): ${resp.body}',
      );
    }
  }

  Future<List<SocialPost>> fetchAll() async {
    final auth = ref.read(authServiceProvider);
    final token = auth.token;

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    final uri = Uri.parse('$baseUrl/social/');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      return _parsePosts(body);
    } else {
      throw Exception(
        'Failed to fetch notes (${resp.statusCode}): ${resp.body}',
      );
    }
  }
}
