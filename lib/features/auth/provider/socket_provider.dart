import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/core/utils/constants.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';
import 'package:stoqle/features/auth/state/auth_state.dart';
import 'package:stoqle/features/auth/state/socket_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final svc = SocketService();
  final auth = ref.watch(authServiceProvider);

  if (auth != null && auth.token != null && auth.user_id != null) {
    svc.init(
      serverBaseUrl: ApiConstants.serverBaseUrl,
      userId: auth.user_id.toString(),
      token: auth.token,
    );
  }

  ref.listen<AuthState?>(authServiceProvider, (prev, next) {
    if (next != null && next.token != null && next.user_id != null) {
      svc.init(
        serverBaseUrl: ApiConstants.serverBaseUrl,
        userId: next.user_id.toString(),
        token: next.token,
      );
    } else {
      svc.dispose();
    }
  });

  ref.onDispose(() => svc.dispose());

  return svc;
});
