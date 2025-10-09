import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';
import 'package:stoqle/features/auth/state/profile_notifier.dart';
import 'package:toast/toast.dart';
import '../component/colors/color.dart';
import '../component/default/defaultButton.dart';
import '../core/widget/loginBottomSheet.dart';
import '../core/widget/terms_and_conditions_text.dart';
import '../features/view/business_registration/help-center/general-help.dart';

class WelcomePage extends ConsumerWidget {
  WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authServiceProvider.notifier);
    final isChecked = ref.watch(checkBoxProvider);
    ToastContext().init(context);
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    isDarkMode
        ? SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(
              statusBarColor: AppColors.transparent,
            ),
          )
        : SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
          );
    final customBackgroundColor = isDarkMode
        ? kBlack10
        : AppColors.lightBackground;
    return Scaffold(
      backgroundColor: customBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, top: 50, right: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StoqleHelpPages(),
                      ),
                    );
                  },
                  child: Text("Help"),
                  // style: TextStyle(
                  //     fontFamily: "Bold", fontSize: 20, color: kWhite),
                ),
              ),
              // Text(""),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Stoqle",
                    style: TextStyle(
                      color: AppColors.kDefault,
                      fontSize: 35,
                      fontFamily: "Extra",
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 00.0),
                      child: Text(
                        "Connect, Sell, Discover",
                        style: TextStyle(
                          // color: kWhite,
                          fontFamily: "Medium",
                          fontSize: 10,
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: DefaultButton(
                      title: "Log In",
                      color: AppColors.kDefault,
                      loader: Text(""),
                      onPressed: () async {
                        await authNotifier.logout();
                        ref.invalidate(profileNotifierProvider);
                        Navigator.of(context).pushNamed("/login_screen");
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          LoginBottomSheet(isDarkMode: isDarkMode),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Other login method"),
                        Icon(Icons.arrow_right_sharp),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
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
                  const SizedBox(height: 50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
