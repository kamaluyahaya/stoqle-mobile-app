// lib/services/google_sign_in_manager.dart
import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:toast/toast.dart';

import '../../features/auth/provider/auth_provider.dart';
import 'constant.dart'; // for toastNotify

class GoogleSignInManager {
  GoogleSignInManager._private();
  static final GoogleSignInManager instance = GoogleSignInManager._private();

  bool _initialized = false;
  bool _listenerAttached = false;
  late final GoogleSignIn _googleSignIn;

  String? _lastIdToken;
  UserCredential? _lastFirebaseCred;

  ValueChanged<User?>? _onUserChanged;

  // loader flag to prevent multiple pops
  bool _loaderVisible = false;

  Future<void> init({
    required BuildContext context,
    required String serverClientId,
    ValueChanged<User?>? onUserChanged,
  }) async {
    if (_initialized) {
      if (onUserChanged != null) _onUserChanged = onUserChanged;
      return;
    }

    ToastContext().init(context);
    _onUserChanged = onUserChanged;

    _googleSignIn = GoogleSignIn.instance;
    await _googleSignIn.initialize(serverClientId: serverClientId);

    try {
      _attachListenerIfNeeded();

      // ❌ remove this line:
      // await _googleSignIn.attemptLightweightAuthentication();
    } catch (e, st) {
      debugPrint('GoogleSignIn initialize error: $e\n$st');
    }

    _initialized = true;
  }

  void _attachListenerIfNeeded() {
    if (_listenerAttached) return;

    _googleSignIn.authenticationEvents.listen((event) async {
      try {
        switch (event) {
          case GoogleSignInAuthenticationEventSignIn():
            final googleUser = event.user;
            // ignore: unnecessary_null_comparison
            if (googleUser == null) {
              _notifyUserChanged(null);
              return;
            }

            final googleAuth = await googleUser.authentication;
            final idToken = googleAuth.idToken;

            if (idToken == null) {
              toastNotify("Google sign-in failed: no idToken");
              _notifyUserChanged(null);
              return;
            }

            try {
              // Firebase sign-in (for validation)
              final credential = GoogleAuthProvider.credential(
                idToken: idToken,
              );
              final userCred = await FirebaseAuth.instance.signInWithCredential(
                credential,
              );

              _lastIdToken = idToken;
              _lastFirebaseCred = userCred;
              _notifyUserChanged(userCred.user);
            } catch (e) {
              toastNotify("Sign-in failed");
              _notifyUserChanged(null);
            }
            break;

          case GoogleSignInAuthenticationEventSignOut():
            await FirebaseAuth.instance.signOut();
            _notifyUserChanged(null);
            break;
        }
      } catch (e, st) {
        debugPrint('Error in auth listener: $e\n$st');
      }
    });

    _listenerAttached = true;
  }

  void _notifyUserChanged(User? u) {
    if (_onUserChanged != null) {
      _onUserChanged!(u);
    }
  }

  Future<bool> signIn(BuildContext context) async {
    try {
      await GoogleSignIn.instance.authenticate();
      return true; // success
    } on GoogleSignInException catch (e) {
      _hideDefaultLoader(context);
      debugPrint('GoogleSignInException: ${e.code} - ${e.description}');

      if (e.code == GoogleSignInExceptionCode.canceled) {
        toastNotify("Google sign-in was cancelled by user");
      } else {
        toastNotify("Google sign-in failed: ${e.description ?? e.code}");
      }
      return false;
    } catch (e) {
      _hideDefaultLoader(context);
      debugPrint('Sign-in error: $e');
      toastNotify("Sign-in failed");
      return false;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.disconnect();
    await FirebaseAuth.instance.signOut();
    _notifyUserChanged(null);
  }

  /// Wait for _lastIdToken to be set by the listener.
  /// Returns true if token was set within [timeout], false otherwise.
  Future<bool> _waitForIdToken({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (_lastIdToken != null) return true;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  /// Call this to sync Google user with backend auth
  Future<Map<String, dynamic>> signInAndSendToBackend({
    required String apiUrl,
    Map<String, String>? headers,
    String? fcmToken,
  }) async {
    if (_lastIdToken == null) {
      throw Exception('No idToken available to send to backend.');
    }

    final payload = {
      'provider': 'google',
      'idToken': _lastIdToken,
      'email': _lastFirebaseCred?.user?.email,
      'full_name': _lastFirebaseCred?.user?.displayName,
      'photo_url': _lastFirebaseCred?.user?.photoURL,
      'uid': _lastFirebaseCred?.user?.uid,
      'fcm_token': fcmToken,
      "device_id": "android-01",
      "platform": "android",
    };

    final mergedHeaders = {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    final resp = await http.post(
      Uri.parse(apiUrl),
      headers: mergedHeaders,
      body: jsonEncode(payload),
    );

    // DEBUG: always log status and body for investigation
    debugPrint('Backend HTTP status: ${resp.statusCode}');
    debugPrint('Backend body: ${resp.body}');

    // Treat any 2xx as success
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // try to parse to show better error, otherwise include raw body
      String msg;
      try {
        final parsed = jsonDecode(resp.body);
        msg = parsed.toString();
      } catch (_) {
        msg = resp.body;
      }
      throw Exception('Backend sign-in failed (HTTP ${resp.statusCode}): $msg');
    }

    // Parse body (defensive)
    Map<String, dynamic> body;
    try {
      final parsed = jsonDecode(resp.body);
      if (parsed is Map<String, dynamic>) {
        body = parsed;
      } else {
        // server returned JSON but not an object (unlikely)
        body = {'status': 'success', 'raw': parsed};
      }
    } catch (e) {
      // Not JSON — return raw body in a map
      body = {'status': 'success', 'raw_body': resp.body};
    }

    // If backend uses 'status' field, honor it — otherwise assume success since HTTP was 2xx
    if (body.containsKey('status') && body['status'] != 'success') {
      throw Exception('Backend responded with non-success status: $body');
    }

    return body;
  }

  // ---------- Loader helpers ----------
  Future<void> _showDefaultLoader(BuildContext context, {String? label}) async {
    if (_loaderVisible) return;
    _loaderVisible = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user cannot dismiss by tapping outside
      useRootNavigator: true,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false, // disable back button
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent, // white overlay background
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CustomCircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _hideDefaultLoader(BuildContext context) {
    if (!_loaderVisible) return;
    _loaderVisible = false;
    try {
      // Use root navigator to match showDialog's useRootNavigator
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error hiding loader: $e');
    }
  }

  /// buildSignInButton now accepts optional navigation targets:
  /// - dashboardRouteName: named route to pushReplacementNamed to (preferred)
  /// - dashboardPage: a WidgetBuilder to pushReplacement to if you don't use named routes
  ///
  /// If neither provided, will try '/dashboard' as a default route name.
  Widget buildSignInButton({
    required BuildContext context,
    required WidgetRef ref,
    required String serverClientId,
    required String backendApiUrl,
    bool enabled = true,
    String assetPath = 'assets/icons/google_icon.png',
    String label = 'Continue with Google',
    Map<String, String>? backendHeaders,
    ValueChanged<User?>? onUserChanged,
    String? dashboardRouteName,
    WidgetBuilder? dashboardPage,
    VoidCallback? onBlockedTap,
  }) {
    init(
      context: context,
      serverClientId: serverClientId,
      onUserChanged: onUserChanged,
    );

    final button = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      onPressed: !enabled
          ? null
          : () async {
              _lastIdToken = null;
              _lastFirebaseCred = null;

              await _showDefaultLoader(
                context,
                label: 'Signing in with Google...',
              );

              final success = await signIn(context);
              if (!success) return;

              final gotToken = await _waitForIdToken(
                timeout: const Duration(seconds: 6),
              );
              if (!gotToken) {
                _hideDefaultLoader(context);
                toastNotify('Sign-in did not complete. Please try again.');
                return;
              }

              final fcmToken = await FirebaseMessaging.instance.getToken();

              try {
                final resp = await signInAndSendToBackend(
                  apiUrl: backendApiUrl,
                  headers: backendHeaders,
                  fcmToken: fcmToken,
                );

                debugPrint("Backend login response: $resp");

                _hideDefaultLoader(context);

                final token = resp['token'] ?? resp['data']?['token'];
                final user = resp['user'] ?? resp['data']?['user'];
                if (token != null && user != null) {
                  await ref
                      .read(authServiceProvider.notifier)
                      .setAuth(token, user);
                }

                final msg = resp['message']?.toString() ?? '';
                if (msg.contains('Account created')) {
                  toastNotify('Welcome to Stoqle');
                } else if (msg.contains('Logged in')) {
                  toastNotify('Welcome back!');
                } else {
                  toastNotify(msg.isNotEmpty ? msg : 'Logged in');
                }

                if (dashboardRouteName != null &&
                    dashboardRouteName.isNotEmpty) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(dashboardRouteName);
                } else if (dashboardPage != null) {
                  Navigator.of(
                    context,
                  ).pushReplacement(MaterialPageRoute(builder: dashboardPage));
                } else {
                  Navigator.of(context).pushReplacementNamed('/dashboard');
                }
              } catch (e, st) {
                debugPrint('Backend sync failed: $e\n$st');
                _hideDefaultLoader(context);
                toastNotify('Backend login failed. Please try again.');
              }
            },
      icon: Image.asset(assetPath, height: 24, width: 24),
      label: Text(label),
    );

    return GestureDetector(
      onTap: () {
        if (!enabled && onBlockedTap != null) {
          onBlockedTap();
        }
      },
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6, // dim when disabled
        child: AbsorbPointer(
          absorbing: !enabled, // block button only when disabled
          child: button,
        ),
      ),
    );
  }
}
