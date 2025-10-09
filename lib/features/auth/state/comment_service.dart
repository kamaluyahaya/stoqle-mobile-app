// lib/features/social/services/comments_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stoqle/core/utils/constants.dart';
import '../models/comment_model.dart';

class CommentsService {
  final http.Client client;

  CommentsService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchComments({
    required int postId,
    int page = 1,
    int limit = 50,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/social/$postId/comments/')
        .replace(
          queryParameters: {'page': page.toString(), 'limit': limit.toString()},
        );

    final response = await client.get(
      uri,
      headers: {'Accept': 'application/json', ...?extraHeaders},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};
      final count = data['count'] ?? 0;
      final post_likes = data['post_total_like'] ?? 0;
      final user_has_liked = data['user_has_liked'] ?? false;
      final commentsRaw = data['comments'] as List<dynamic>? ?? [];
      final comments = commentsRaw
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList();
      return {
        'count': count,
        'post_total_like': post_likes,
        'user_has_liked': user_has_liked,
        'comments': comments,

        'raw': body,
      };
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}');
    }
  }

  // lib/features/social/services/comments_service.dart
  Future<Comment> createComment({
    required int postId,
    required String content,
    Map<String, String>? extraHeaders,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw Exception('Comment cannot be empty (client)');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/social/$postId/comment');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?extraHeaders,
    };

    print('POST $uri');
    print('Headers: $headers');
    print('Body: ${jsonEncode({'content': trimmed})}');

    final response = await client.post(
      uri,
      headers: headers,
      body: jsonEncode({'content': trimmed}),
    );

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    debugPrint('createComment response (${response.statusCode}): $body');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map && body.containsKey('data')) {
        final data = body['data'];
        if (data is Map && data.containsKey('comment')) {
          return Comment.fromJson(Map<String, dynamic>.from(data['comment']));
        } else if (data is Map &&
            data.containsKey('comments') &&
            data['comments'] is List &&
            data['comments'].isNotEmpty) {
          return Comment.fromJson(
            Map<String, dynamic>.from(data['comments'][0]),
          );
        } else if (data is Map) {
          return Comment.fromJson(Map<String, dynamic>.from(data));
        }
      } else if (body is Map) {
        return Comment.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception('Unexpected createComment response shape: $body');
    } else {
      // prefer server message if present
      String message = 'Request failed (${response.statusCode})';
      if (body is Map && body['message'] != null)
        message = body['message'].toString();
      else if (body is Map && body['error'] != null)
        message = body['error'].toString();
      else if (body is String && body.isNotEmpty)
        message = body;
      debugPrint('createComment error: $message');
      throw Exception(message);
    }
  }

  /// LIKE / UNLIKE comment
  /// POST to like, DELETE to unlike
  Future<void> likeComment(
    int commentId, {
    Map<String, String>? extraHeaders,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/social/comments/$commentId/like',
    );

    final response = await client.post(
      uri,
      headers: {...?extraHeaders, 'Accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to toggle like: ${response.statusCode}');
    }
  }

  /// LIKE / UNLIKE post
  /// POST to like, DELETE to unlike
  Future<void> likePost(int postId, {Map<String, String>? extraHeaders}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/social/$postId/like');

    final response = await client.post(
      uri,
      headers: {...?extraHeaders, 'Accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to toggle like on post: ${response.statusCode}');
    }
  }
}
