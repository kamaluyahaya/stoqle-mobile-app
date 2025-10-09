// lib/providers/follow_params.dart
import 'package:stoqle/features/auth/provider/follow_provider.dart'; // update path if needed

class FollowParams {
  final FollowTab tab;
  final int userId;
  const FollowParams({required this.tab, required this.userId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowParams &&
          runtimeType == other.runtimeType &&
          tab == other.tab &&
          userId == other.userId;

  @override
  int get hashCode => tab.hashCode ^ userId.hashCode;
}
