// lib/ui/login/login_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/core/widget/constant.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';
import 'package:toast/toast.dart';

import '../../component/colors/color.dart';
import '../utils/constants.dart' hide AppColors;
import 'google_sign_in_manager.dart';
import 'terms_and_conditions_text.dart';

class LoginBottomSheet extends ConsumerStatefulWidget {
  final bool isDarkMode;
  const LoginBottomSheet({super.key, required this.isDarkMode});

  @override
  ConsumerState<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends ConsumerState<LoginBottomSheet> {
  static const String serverClientId =
      '1027100901898-5ug90fp54epnjk16cpu6540b05qj3b3a.apps.googleusercontent.com';

  @override
  void initState() {
    super.initState();
    // Initialize Toast context
    ToastContext().init(context);
  }

  @override
  Widget build(BuildContext context) {
    final isChecked = ref.watch(checkBoxProvider);
    return GestureDetector(
      onTap: () {}, // prevent dismiss when tapping inside
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? AppColors.background2
              : AppColors.lightBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                const Text(
                  'Log in to continue',
                  style: TextStyle(fontSize: 14, fontFamily: "Medium"),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),

            /// ✅ Google Sign-In button with Riverpod ref
            GoogleSignInManager.instance.buildSignInButton(
              ref: ref,
              context: context,
              serverClientId: serverClientId,
              backendApiUrl: "${ApiConstants.baseUrl}/auth/register-or-login",
              enabled: isChecked,
              onBlockedTap: () {
                toastNotify(
                  "Please accept the terms and conditions to continue",
                );
              },
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    ref.read(checkBoxProvider.notifier).state = !isChecked;
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
                      color: isChecked ? Colors.red : Colors.transparent,
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

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
