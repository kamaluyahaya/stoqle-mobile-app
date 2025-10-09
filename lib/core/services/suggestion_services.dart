import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:stoqle/core/utils/constants.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';

import '../../features/auth/models/suggestion_model.dart';

class SuggestionService {
  final String baseUrl;
  final Ref ref;
  SuggestionService({required this.baseUrl, required this.ref});

  Future<List<SuggestionUser>> fetchSuggestions({
    int limit = 20,
    int offset = 0,
    String q = '',
  }) async {
    final auth = ref.read(authServiceProvider);
    final token = auth.token;
    if (token == null || token.isEmpty) {
      throw Exception('No auth token available');
    }

    final uri = Uri.parse('$baseUrl/users/suggestions');

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      final data = body['data'] ?? {};

      // Parse normal users
      final rawUsers = (data['users'] as List<dynamic>? ?? []);
      final users = rawUsers
          .map((e) => SuggestionUser.fromJson(e as Map<String, dynamic>))
          .toList();

      // Parse vendors as businesses
      final rawVendors = (data['vendors'] as List<dynamic>? ?? []);
      final vendors = rawVendors.map((e) {
        final u = SuggestionUser.fromJson(e as Map<String, dynamic>);
        if (u.business != null) {
          return SuggestionUser(
            userId: u.userId, // use business id
            fullName: u.business!.businessName,
            profilePic: u.business!.logo,
            bio: null,
            job: u.business!.category,
            location: null,
            isBusinessOwner: true,
            business: u.business,
          );
        }
        return u;
      }).toList();

      // Filter out users that are also vendors (avoid duplicates)
      final vendorUserIds = vendors.map((v) => v.userId).toSet();
      final filteredUsers = users
          .where((u) => !vendorUserIds.contains(u.userId))
          .toList();

      // Merge lists
      final all = [...filteredUsers, ...vendors];

      print('SuggestionService.fetchSuggestions => $body');
      return all;
    } else {
      throw Exception(
        'Failed to fetch suggestions: ${resp.statusCode} ${resp.body}',
      );
    }
  }

  Future<bool> followUser(int userId) async {
    final auth = ref.read(authServiceProvider);
    final token = auth.token;
    if (token == null || token.isEmpty) return false;

    final uri = Uri.parse('$baseUrl/follow/$userId/follow');
    final resp = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    return resp.statusCode >= 200 && resp.statusCode < 300;
  }
}

final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  return SuggestionService(baseUrl: ApiConstants.baseUrl, ref: ref);
});
