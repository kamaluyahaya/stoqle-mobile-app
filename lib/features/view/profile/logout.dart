// -------------------- Logout TAB --------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';
import 'package:stoqle/features/auth/state/profile_notifier.dart';

class Logout extends ConsumerWidget {
  const Logout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authServiceProvider.notifier);

    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          await authNotifier.logout();
          ref.invalidate(profileNotifierProvider);

          if (context.mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/intro', (route) => false);
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
