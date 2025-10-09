import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/colors/color.dart';
import '../component/default/defaultButton.dart';

class IntroScreen extends StatefulWidget {
  static const routeName = '/intro';
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    // show the dialog once the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDialog());
  }

  Future<void> _maybeShowDialog() async {
    if (_hasShownDialog) return;
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('stoqle_privacy_accepted') ?? false;

    // If already accepted, skip dialog and go straight to Welcome
    if (accepted) {
      _goToWelcome();
      return;
    }

    _showIntroDialog();
  }

  void _goToWelcome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  void _showIntroDialog() {
    setState(() => _hasShownDialog = true);

    showDialog(
      context: context,
      barrierDismissible: false, // force user to choose
      builder: (ctx) {
        final maxHeight = MediaQuery.of(ctx).size.height * 0.50;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 40,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Center(
                        child: Text(
                          'Welcome to Stoqle',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "bold",
                            // fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Connect, Sell, Discover. And Your Privacy Matter.',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 0),

                // scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // intro paragraph
                        const Text(
                          'What Stoqle is',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Stoqle helps you growth and sell your business product fast, and discover new product and vendors. '
                          'We store the minimal data needed to make features work — like your account details and preferences. '
                          'We never sell your personal data to third parties.',
                        ),
                        const SizedBox(height: 14),

                        // data protection section
                        const Text(
                          'How we protect your data',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Encryption: Sensitive data is encrypted both in transit and at rest.\n'
                          '• Access control: Only authorized systems and people can access your data.\n'
                          '• Minimal retention: We only keep what we need for operations and legally required periods.\n'
                          '• You control what you share: you can edit or delete your data in Settings.',
                        ),
                        const SizedBox(height: 14),

                        // examples / callouts
                        const Text(
                          'Quick examples',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'If you add a payment method, we tokenise it so we do not store full card numbers. '
                          'Push notifications can be disabled at any time from the app settings.',
                        ),

                        const SizedBox(height: 18),

                        // small privacy note
                        const Text(
                          'By tapping Agree you accept that we collect and process the data described above for providing Stoqle features. '
                          'Tap Not Agree to continue without consenting. Some features may not work without consent.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Not Agree: proceed to welcome but do NOT save acceptance
                            Navigator.of(context).pop(); // dismiss dialog
                            _goToWelcome();
                          },
                          child: const Text('Not Agree'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DefaultButton(
                          title: "Agree",
                          color: AppColors.kDefault,
                          loader: Text(""),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool(
                              'stoqle_privacy_accepted',
                              true,
                            );
                            Navigator.of(context).pop(); // dismiss dialog
                            _goToWelcome();
                            Navigator.of(context).pushNamed(
                              "/login_screen",
                              // PageAnimationTransition(
                              //   page: const UserLogin(),
                              //   pageAnimationType: RightToLeftTransition(),
                              // ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // subtle neutral gradient like Apple apps
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey.shade900, Colors.black]
                : [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // logo container
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Stoqle",
                      style: TextStyle(
                        color: AppColors.kDefault,
                        fontSize: 40,
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

                const SizedBox(height: 18),

                // App name
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
