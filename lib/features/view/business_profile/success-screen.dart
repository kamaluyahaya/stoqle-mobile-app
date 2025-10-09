import 'package:flutter/material.dart';

class RegistrationSuccessPage extends StatelessWidget {
  final String? businessName;
  final String? requestId;
  final VoidCallback? onDone;
  final VoidCallback? onViewRequest;

  const RegistrationSuccessPage({
    Key? key,
    this.businessName,
    this.requestId,
    this.onDone,
    this.onViewRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 26),
          child: Column(
            children: [
              // top small close/back row (apple-like)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () {
                      // default: pop one route; allow override via onDone
                      if (onDone != null) {
                        onDone!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // main card
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.symmetric(
                      vertical: 36,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // success icon
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 52,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // headline
                        Text(
                          'Request Submitted',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // subtitle
                        Text(
                          businessName != null
                              ? '$businessName registration request is received and is now waiting for review.'
                              : 'Your registration request has been received and is now waiting for review.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 14),

                        if (requestId != null)
                          Column(
                            children: [
                              Text(
                                'Reference: $requestId',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),

                        const SizedBox(height: 6),

                        // helper text
                        Text(
                          'We will review your submission and notify you once it\'s approved. Typically this takes 1–3 business days.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 26),

                        // actions
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (onDone != null) {
                                    onDone!();
                                  } else {
                                    // default: pop to first (dashboard)
                                    Navigator.of(
                                      context,
                                    ).popUntil((r) => r.isFirst);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red, // use app accent color
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Back to dashboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // optional footer (small info)
              Text(
                'You can find your request in the “My requests” section.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
