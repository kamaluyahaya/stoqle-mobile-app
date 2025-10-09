// lib/index/user_login.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/core/utils/constants.dart' hide AppColors;
import 'package:toast/toast.dart';

import '../../../component/colors/color.dart';
import '../../../component/default/defaultButton.dart';
import '../../../core/widget/google_sign_in_manager.dart';
import '../../../core/widget/terms_and_conditions_text.dart';

import '../provider/auth_provider.dart';
import '../state/auth_state.dart';

//

class UserLogin extends ConsumerStatefulWidget {
  const UserLogin({super.key});

  @override
  ConsumerState<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends ConsumerState<UserLogin> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String accountStatus = "";
  bool isOtpSent = false;
  bool usePassword = false;
  bool isButtonEnabled = false;
  bool inputIsPhone = false;

  int countdown = 60;
  bool showResendButton = false;
  Timer? timer;

  final RegExp emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$");
  final RegExp phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  void toastNotify(String msg) {
    Toast.show(
      msg,
      duration: Toast.lengthShort,
      gravity: Toast.center,
      backgroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 14, color: Colors.black),
    );
  }

  void startCountdown() {
    timer?.cancel();
    setState(() {
      countdown = 60;
      showResendButton = false;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          showResendButton = true;
          t.cancel();
        }
      });
    });
  }

  void resendOTP() {
    setState(() {
      showResendButton = false;
      countdown = 60;
    });
    startCountdown();

    final id = identifierController.text.trim();
    if (id.isNotEmpty) {
      ref.read(authServiceProvider.notifier).login(email: id); // ✅ resend OTP
      toastNotify("OTP resent");
    } else {
      toastNotify("Enter phone or email to resend OTP");
    }
  }

  bool _navigatedFromOtp = false;

  @override
  void dispose() {
    otpController.dispose();
    identifierController.dispose();
    passwordController.dispose();
    timer?.cancel();
    super.dispose();
  }

  bool _isValidIdentifier(String input) {
    final s = input.trim();
    if (s.isEmpty) return false;
    if (emailRegex.hasMatch(s)) return true;
    final digits = s.replaceAll(RegExp(r'[\s\-]'), '');
    if (phoneRegex.hasMatch(digits)) return true;
    return false;
  }

  void _updateButtonState() {
    if (isOtpSent) {
      isButtonEnabled = otpController.text.trim().length >= 4;
    } else if (usePassword) {
      isButtonEnabled =
          _isValidIdentifier(identifierController.text) &&
          passwordController.text.trim().length >= 5;
    } else {
      isButtonEnabled = _isValidIdentifier(identifierController.text);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    final state = ref.watch(authServiceProvider);
    ref.listen<AuthState>(authServiceProvider, (previous, next) {
      if (next.toastMessage != null) {
        toastNotify(next.toastMessage!);
      }

      // OTP sent -> start countdown
      if (next.isOtpSent && !(previous?.isOtpSent ?? false)) {
        setState(() {
          isOtpSent = true;
          accountStatus = next.accountStatus ?? "";
        });
        startCountdown();
      }

      // OTP flow ended -> reset UI and nav guard
      if (!next.isOtpSent && (previous?.isOtpSent ?? false)) {
        timer?.cancel();
        setState(() {
          isOtpSent = false;
          showResendButton = false;
        });
        _navigatedFromOtp = false;
      }

      // debug: helps you see what the state actually contains when listener fires
      debugPrint(
        'AuthListener: otpVerified=${next.otpVerified}, needsProfile=${next.needsProfile}, accountStatus=${next.accountStatus}, token=${next.token}',
      );

      // navigation guard
      if (next.otpVerified &&
          !(previous?.otpVerified ?? false) &&
          !_navigatedFromOtp) {
        _navigatedFromOtp = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (next.needsProfile == true ||
              next.accountStatus == "new_account") {
            Navigator.pushReplacementNamed(
              context,
              '/user_fullname',
              arguments: {'email': next.email ?? identifierController.text},
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              '/dashboard',
              arguments: {'email': next.email ?? identifierController.text},
            );
          }

          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _navigatedFromOtp = false);
          });
        });
      }

      if ((next.accountStatus ?? "").isNotEmpty &&
          next.accountStatus != accountStatus) {
        accountStatus = next.accountStatus ?? "";
      }
    });

    const String serverClientId =
        '1027100901898-5ug90fp54epnjk16cpu6540b05qj3b3a.apps.googleusercontent.com';
    final isChecked = ref.watch(checkBoxProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Text("Help"),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    Text(
                      isOtpSent ? "Verify OTP" : "Login with phone or email",
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: "Medium",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Unregistered identifier will be automatically registered if login succeeds",
                      style: TextStyle(color: kWhite20, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Identifier
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1, color: kWhite30),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.person_outline, color: kWhite20, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: identifierController,
                              readOnly: isOtpSent,
                              keyboardType: inputIsPhone
                                  ? TextInputType.phone
                                  : TextInputType.emailAddress,
                              onChanged: (value) {
                                if (isOtpSent) return;
                                final trimmed = value.trim();
                                final digits = trimmed.replaceAll(
                                  RegExp(r'[\s\-]'),
                                  '',
                                );
                                final isEmail = emailRegex.hasMatch(trimmed);
                                final isPhone = phoneRegex.hasMatch(digits);
                                setState(
                                  () => inputIsPhone = isPhone && !isEmail,
                                );
                                _updateButtonState();
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Phone number or Email',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              style: const TextStyle(
                                fontFamily: "Medium",
                                fontSize: 12,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: isOtpSent
                                ? null
                                : () {
                                    identifierController.clear();
                                    _updateButtonState();
                                  },
                            child: Icon(
                              Icons.cancel,
                              size: 15,
                              color: isOtpSent ? Colors.grey[700] : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Password field
                    if (!isOtpSent && usePassword)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1, color: kWhite30),
                          ),
                        ),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          onChanged: (_) => _updateButtonState(),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter password (min 5 chars)',
                            hintStyle: TextStyle(color: kWhite20),
                          ),
                          style: const TextStyle(
                            fontFamily: "Medium",
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    // OTP field
                    if (isOtpSent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1, color: kWhite30),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _updateButtonState(),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter OTP',
                                  hintStyle: TextStyle(color: kWhite20),
                                ),
                                style: const TextStyle(
                                  fontFamily: "Medium",
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (showResendButton)
                              TextButton(
                                onPressed: resendOTP,
                                child: const Text(
                                  "Resend OTP",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                            else
                              Text(
                                "Resend ($countdown)",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),

                    // Mode switchers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (isOtpSent) {
                              toastNotify("Can't switch while OTP is active");
                              return;
                            }
                            setState(() {
                              usePassword = !usePassword;
                              _updateButtonState();
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.key_outlined, color: kWhite20),
                              const SizedBox(width: 5),
                              Text(
                                usePassword
                                    ? "Use OTP instead"
                                    : "Login with password",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => usePassword = true),
                          child: Text(
                            usePassword ? "Forgot Password" : "Can't use Pin",
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Login button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: DefaultButton(
                        title: isOtpSent ? "Verify OTP" : "Log In",
                        loader: state.isLoading
                            ? Image.asset(
                                "assets/icons/loader_spinner1.gif",
                                width: 30,
                                height: 20,
                              )
                            : const Text(""),
                        color: isChecked ? AppColors.kDefault : kWhite10,
                        onPressed: isChecked && isButtonEnabled
                            ? () {
                                final id = identifierController.text.trim();
                                final password = passwordController.text.trim();
                                final otp = otpController.text.trim();

                                if (isOtpSent) {
                                  ref
                                      .read(authServiceProvider.notifier)
                                      .verifyOtp(
                                        email: emailRegex.hasMatch(id)
                                            ? id
                                            : null,
                                        phone: phoneRegex.hasMatch(id)
                                            ? id
                                            : null,
                                        otp: otp,
                                      );
                                } else {
                                  if (usePassword && password.isNotEmpty) {
                                    ref
                                        .read(authServiceProvider.notifier)
                                        .login(
                                          email: emailRegex.hasMatch(id)
                                              ? id
                                              : null,
                                          phone: phoneRegex.hasMatch(id)
                                              ? id
                                              : null,
                                          password: password,
                                        );
                                  } else {
                                    ref
                                        .read(authServiceProvider.notifier)
                                        .login(
                                          email: emailRegex.hasMatch(id)
                                              ? id
                                              : null,
                                          phone: phoneRegex.hasMatch(id)
                                              ? id
                                              : null,
                                        );
                                  }
                                }
                              }
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Terms + Google login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            ref.read(checkBoxProvider.notifier).state =
                                !isChecked;
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.red, // border color
                                width: 2,
                              ),
                              color: isChecked
                                  ? Colors.red
                                  : Colors.transparent,
                            ),
                            child: isChecked
                                ? const Center(
                                    child: Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: Colors.white, // inner dot color
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TermsAndConditionsText(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GoogleSignInManager.instance.buildSignInButton(
                      ref: ref,
                      context: context,
                      serverClientId: serverClientId,
                      backendApiUrl:
                          "${ApiConstants.baseUrl}/auth/register-or-login",
                      enabled: isChecked,
                      onBlockedTap: () {
                        toastNotify(
                          "Please accept the terms and conditions to continue",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
