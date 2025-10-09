import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;
  String? _userId;
  String? _baseUrl;
  String? _token;

  final Map<String, List<void Function(dynamic)>> _listeners = {};

  bool get connected => _socket?.connected ?? false;
  String? get id => _socket?.id;

  void init({
    required String serverBaseUrl,
    required String userId,
    String? token,
  }) {
    // if already connected with same creds, skip
    if (_socket != null &&
        _userId == userId &&
        _baseUrl == serverBaseUrl &&
        _socket!.connected) {
      return;
    }

    _disposeSocket();

    _baseUrl = serverBaseUrl;
    _userId = userId;
    _token = token;

    final options = <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 9999,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'query': {'userId': userId},
      if (token != null && token.isNotEmpty)
        'extraHeaders': {'Authorization': 'Bearer $token'},
    };

    _socket = IO.io(serverBaseUrl, options);

    _socket!.onConnect(
      (_) => print("🔌 SocketService connected ${_socket?.id}"),
    );
    _socket!.onDisconnect(
      (reason) => print("❌ SocketService disconnected: $reason"),
    );
    _socket!.onConnectError(
      (err) => print("⚠️ SocketService connect error: $err"),
    );
    _socket!.onError((err) => print("⚠️ SocketService error: $err"));

    // restore previous listeners
    _listeners.forEach((event, callbacks) {
      for (final cb in callbacks) {
        _socket!.on(event, cb);
      }
    });
  }

  void on(String event, void Function(dynamic) cb) {
    _listeners.putIfAbsent(event, () => []).add(cb);
    _socket?.on(event, cb);
  }

  void off(String event, [void Function(dynamic)? cb]) {
    if (cb == null) {
      _listeners.remove(event);
      _socket?.off(event);
    } else {
      _listeners[event]?.remove(cb);
      _socket?.off(event, cb);
    }
  }

  void emit(String event, dynamic data) {
    if (connected) {
      _socket!.emit(event, data);
    } else {
      print("⚠️ emit failed — socket not connected");
    }
  }

  void _disposeSocket() {
    try {
      _socket?.disconnect();
      _socket?.close();
    } catch (_) {}
    _socket = null;
    _userId = null;
    _baseUrl = null;
    _token = null;
  }

  void dispose() {
    _disposeSocket();
    _listeners.clear();
  }
}
