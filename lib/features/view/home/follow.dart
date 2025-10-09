// follow_page_with_suggestions.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/features/auth/models/suggestion_param.dart';
import 'package:stoqle/features/auth/provider/suggestion_provider.dart';
import 'package:stoqle/features/auth/state/suggestion_notifier.dart';
import 'package:stoqle/features/view/profile/other/other.dart';
import 'package:toast/toast.dart'; // for ProfileOrderContainer if needed

class FollowPage extends ConsumerStatefulWidget {
  const FollowPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends ConsumerState<FollowPage>
    with SingleTickerProviderStateMixin {
  static const SuggestionParams _suggestionParams = SuggestionParams(
    limit: 8,
    offset: 0,
    q: '',
  );

  // empty follow message
  Widget _emptyFollowView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(height: 12),
          Text(
            "You're not following anyone yet",
            style: TextStyle(fontFamily: "bold", fontSize: 16),
          ),
          SizedBox(height: 8),
          Text("Follow more people and view their latest updates here"),
        ],
      ),
    );
  }

  // Navigate to OtherProfile
  void _openOtherProfile(BuildContext context, String otherUserId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtherProfile(otherUserId: otherUserId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    // Use LayoutBuilder to adapt sizes when space is limited
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.4;

        final avatarRadius = math.min(35.0, math.max(22.0, maxH * 0.12));

        final loadingSet = ref.watch(followLoadingProvider);

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _emptyFollowView(),
                const SizedBox(height: 12),

                // suggestions list (vertical)
                Consumer(
                  builder: (context, r, _) {
                    final sState = r.watch(
                      suggestionNotifierProvider(_suggestionParams),
                    );

                    return sState.when(
                      data: (list) {
                        if (list.isEmpty) return const SizedBox.shrink();

                        return Column(
                          children: list.map((u) {
                            final loading = loadingSet.contains(u.userId);
                            final otherId = "${u.userId}";
                            final displayName = u.displayName ?? '';

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),

                              // make avatar tappable
                              leading: GestureDetector(
                                onTap: () =>
                                    _openOtherProfile(context, otherId),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: u.displayPic.isNotEmpty
                                      ? ClipOval(
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/images/favio.png',
                                            image: u.displayPic,
                                            fit: BoxFit.cover,
                                            width: avatarRadius * 2,
                                            height: avatarRadius * 2,
                                          ),
                                        )
                                      : Icon(
                                          PhosphorIcons.cat(),
                                          size: avatarRadius * 1.0,
                                          color: Colors.orange,
                                        ),
                                ),
                              ),

                              // title area tappable (name)
                              title: GestureDetector(
                                onTap: () =>
                                    _openOtherProfile(context, otherId),
                                child: Text(
                                  displayName,
                                  style: const TextStyle(fontFamily: "bold"),
                                ),
                              ),

                              subtitle: Text(
                                "@Stoqle_ID 00${u.userId}",
                                style: const TextStyle(fontSize: 12),
                              ),

                              // tapping the whole tile also opens profile (nice UX)
                              onTap: () => _openOtherProfile(context, otherId),

                              trailing: SizedBox(
                                height: 30,
                                child: OutlinedButton(
                                  onPressed: loading
                                      ? null
                                      : () async {
                                          // add to loading set
                                          r
                                              .read(
                                                followLoadingProvider.notifier,
                                              )
                                              .update((s) {
                                                final c = Set<int>.from(s);
                                                c.add(u.userId);
                                                return c;
                                              });

                                          try {
                                            final success = await r
                                                .read(
                                                  suggestionNotifierProvider(
                                                    _suggestionParams,
                                                  ).notifier,
                                                )
                                                .followUser(u.userId);

                                            if (success) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Followed'),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error: ${e.toString()}',
                                                ),
                                              ),
                                            );
                                          } finally {
                                            // remove from loading set
                                            r
                                                .read(
                                                  followLoadingProvider
                                                      .notifier,
                                                )
                                                .update((s) {
                                                  final c = Set<int>.from(s);
                                                  c.remove(u.userId);
                                                  return c;
                                                });
                                          }
                                        },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.kDefault),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Follow',
                                          style: TextStyle(
                                            color: AppColors.kDefault,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, st) => Center(
                        child: Text(
                          'Error loading suggestions',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
