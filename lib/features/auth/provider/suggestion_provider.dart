// lib/features/suggest/provider/suggestions_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/features/auth/models/suggestion_model.dart';

import '../../../core/services/suggestion_services.dart';

/// params map example: {'limit': 8, 'offset': 0, 'q': ''}
final suggestionsProvider = FutureProvider.autoDispose
    .family<List<SuggestionUser>, Map<String, dynamic>>((ref, params) async {
      final svc = ref.watch(suggestionServiceProvider);
      final limit = params['limit'] is int
          ? params['limit'] as int
          : (int.tryParse('${params['limit'] ?? 20}') ?? 20);
      final offset = params['offset'] is int
          ? params['offset'] as int
          : (int.tryParse('${params['offset'] ?? 0}') ?? 0);
      final q = params['q']?.toString() ?? '';
      return svc.fetchSuggestions(limit: limit, offset: offset, q: q);
    });

// per-user follow loading indicator (show spinner on each follow button)
final followLoadingProvider = StateProvider<Set<int>>((ref) => <int>{});
