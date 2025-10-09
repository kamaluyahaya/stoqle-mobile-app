// lib/features/auth/provider/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../state/auth_service.dart';
import '../state/auth_state.dart';

// Provide repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Provide unified AuthService (single, authoritative provider)
final authServiceProvider = StateNotifierProvider<AuthService, AuthState>((
  ref,
) {
  final repo = ref.read(authRepositoryProvider);
  return AuthService(repo: repo)..loadFromStorage();
});

/// ✅ Checkbox provider
final checkBoxProvider = StateProvider<bool>((ref) => false);
