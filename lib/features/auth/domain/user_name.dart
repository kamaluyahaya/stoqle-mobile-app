// lib/features/auth/domain/user_name.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toast/toast.dart';

import '../../../component/colors/color.dart';
import '../../../component/default/defaultButton.dart';
import '../../../component/user/user_login_header.dart';
import '../provider/auth_provider.dart'; // contains authRepositoryProvider + authServiceProvider

class UserFullnamePage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? args;
  const UserFullnamePage({super.key, this.args});

  @override
  ConsumerState<UserFullnamePage> createState() => _UserFullnamePageState();
}

class _UserFullnamePageState extends ConsumerState<UserFullnamePage> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;
  bool _submitting = false;

  String? _email;
  String? _phone;
  int? _userId;

  static final _invalidChars = RegExp(r'[@<>/]');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ToastContext().init(context);

      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      debugPrint('UserFullnamePage args => $args');

      // try arg keys
      final dynamic argId =
          args?['user_id'] ?? args?['userId'] ?? args?['id'] ?? args?['uid'];
      int? userIdFromArgs = argId is int
          ? argId
          : (argId is String ? int.tryParse(argId) : null);

      // try raw_user map if present
      final rawUser = args?['raw_user'] as Map<String, dynamic>?;
      int? userIdFromRaw;
      if (userIdFromArgs == null && rawUser != null) {
        final dynamic raw =
            rawUser['user_id'] ?? rawUser['id'] ?? rawUser['userId'];
        userIdFromRaw = raw is int
            ? raw
            : (raw is String ? int.tryParse(raw) : null);
      }

      // fallback to auth state
      final auth = ref.read(authServiceProvider);
      int? userIdFromState = auth.user_id;

      _userId = userIdFromArgs ?? userIdFromRaw ?? userIdFromState;

      _email = args?['email'] as String? ?? rawUser?['email'] as String?;
      _phone = args?['phone'] as String? ?? rawUser?['phone_no'] as String?;
      final prefill =
          args?['name'] as String? ?? rawUser?['full_name'] as String? ?? '';

      debugPrint(
        'UserFullname resolved userId=$_userId, email=$_email, phone=$_phone, prefill=$prefill',
      );

      if (prefill.isNotEmpty) {
        _controller.text = prefill;
        _isValid = _validateName(prefill);
      }
      setState(() {});
    });
  }

  bool _validateName(String t) {
    final s = t.trim();
    if (s.length < 2 || s.length > 24) return false;
    if (_invalidChars.hasMatch(s)) return false;
    return true;
  }

  void _toast(String msg) {
    if (!mounted) return;
    Toast.show(
      msg,
      duration: Toast.lengthShort,
      gravity: Toast.center,
      backgroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 14, color: Colors.black),
    );
  }

  Future<void> _submit() async {
    final fullName = _controller.text.trim();
    if (!_validateName(fullName)) return;

    setState(() => _submitting = true);

    try {
      if (_userId == null) {
        _toast('Missing user id — go back and re-verify OTP.');
        return;
      }

      final repo = ref.read(authRepositoryProvider);
      final resp = await repo.updateName(userId: _userId!, fullName: fullName);

      debugPrint('updateName response: $resp');

      final payload = resp['data'] ?? {};
      final token = payload['token'];
      final user = payload['user'] ?? {};

      if (token != null && user.isNotEmpty) {
        // ✅ 1. Update in-memory state first
        await ref.read(authServiceProvider.notifier).setAuth(token, user);

        // ✅ 2. Navigate to dashboard immediately
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/dashboard', (r) => false);
        }

        // ✅ 3. Show toast after navigation
        final msg = resp['message']?.toString() ?? 'Name updated successfully';
        Future.microtask(() => _toast(msg));
      } else {
        final msg = resp['message']?.toString() ?? 'Unable to complete update';
        _toast(msg);
      }
    } catch (e, st) {
      debugPrint('UserFullname submit error: $e\n$st');
      if (mounted) _toast('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StoqleUserLoginHeader(),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 30, right: 30),
              child: Column(
                children: [
                  if (_email != null) Text(_email!),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your name",
                    style: TextStyle(fontSize: 18, fontFamily: "Medium"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Provide your real name",
                    style: TextStyle(color: kWhite20, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: kWhite30),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.person, color: kWhite20, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            autofocus: true,
                            controller: _controller,
                            keyboardType: TextInputType.name,
                            onChanged: (v) {
                              final valid = _validateName(v);
                              if (valid != _isValid) {
                                setState(() => _isValid = valid);
                              }
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your full name',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            style: const TextStyle(
                              fontFamily: "Medium",
                              fontSize: 14,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() => _isValid = false);
                          },
                          child: const Icon(
                            Icons.cancel,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Pls set 2-24 characters, excluding invalid characters such as @ </ >",
                    style: TextStyle(color: kWhite20, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: DefaultButton(
                      title: "Next",
                      color: _isValid ? AppColors.kDefault : kWhite10,
                      loader: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(""),
                      onPressed: _isValid && !_submitting ? _submit : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
