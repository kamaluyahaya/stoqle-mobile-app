import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'enterprise/register.dart';
import 'individual/register.dart';

class SelectStoreTypePage extends StatelessWidget {
  const SelectStoreTypePage({Key? key}) : super(key: key);

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade600;

    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        240,
        240,
        240,
      ), // soft off-white background for Apple-like feel

      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Back',
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // Apple-like rounded corners
                        ),
                        title: const Text(
                          'Which one should I choose?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        content: const Text(
                          "If you don't have a registered business, choose Individual Identity. For registered companies, choose Enterprise Identity.",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.black54,
                          ),
                        ),
                        actionsAlignment:
                            MainAxisAlignment.center, // Center the button
                        actions: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.red, // Apple-style red button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    30,
                                  ), // Circular radius
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Got it',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(LucideIcons.circleQuestionMark300),
                ),
              ],
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Select Subject Type',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Bold",
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Individual Identity card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // Icon / avatar
                        Center(child: Icon(LucideIcons.userRound400, size: 30)),

                        const SizedBox(width: 14),

                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Individual Identity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Suitable for opening a store as an individual without a business license.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Button
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OpenStoreIndividualPage(),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: red, width: 0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            foregroundColor: red, // text color
                          ),
                          child: Text(
                            'Open store',
                            style: TextStyle(
                              color: red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Divider(height: 2.0),
                  ),

                  // Enterprise Identity card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // Icon / avatar
                        Center(child: Icon(LucideIcons.store, size: 30)),

                        const SizedBox(width: 14),

                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Enterprise Identity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Suitable for entities with a business license, where the business license type displays "Individual Industrial and Commercial Household" or "Company/Enterprise/Sole Proprietorship", etc.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Button
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OpenStoreEnterprisePage(),
                            ),
                          ),

                          //  Navigator.of(context).pushReplacement(
                          //       MaterialPageRoute(
                          //         builder: (_) => RegistrationSuccessPage(
                          //           businessName: 'E-Jays Project Ltd',
                          //           requestId: 'BR-20250930-0001',
                          //           onDone: () => Navigator.of(context)
                          //               .pushNamedAndRemoveUntil(
                          //                 '/dashboard',
                          //                 (r) => false,
                          //               ),
                          //           onViewRequest: () =>
                          //               Navigator.of(context).pushNamed(
                          //                 '/request-details',
                          //                 arguments: 'BR-20250930-0001',
                          //               ),
                          //         ),
                          //       ),
                          //     ),
                          // _navigate(context, '/open-store/enterprise'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: red, width: 0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            foregroundColor: red,
                          ),
                          child: Text(
                            'Open store',
                            style: TextStyle(color: red),
                          ),
                        ),
                      ],
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
