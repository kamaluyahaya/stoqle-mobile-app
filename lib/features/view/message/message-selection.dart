// follow_page_with_suggestions.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/features/auth/models/suggestion_param.dart';
import 'package:stoqle/features/auth/provider/suggestion_provider.dart';
import 'package:stoqle/features/auth/state/suggestion_notifier.dart';
import 'package:stoqle/features/view/profile/other/other.dart';

class MessageDashboard extends ConsumerStatefulWidget {
  const MessageDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<MessageDashboard> createState() => _MessageDashboardState();
}

class _MessageDashboardState extends ConsumerState<MessageDashboard>
    with SingleTickerProviderStateMixin {
  static const SuggestionParams _suggestionParams = SuggestionParams(
    limit: 8,
    offset: 0,
    q: '',
  );

  // Empty follow view with 3 items in a row
  Widget _emptyFollowView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row with 3 items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEmptyFollowItem(
                icon: Icons.favorite,
                label: "Likes & Collect",
                color: Colors.pinkAccent,
              ),
              _buildEmptyFollowItem(
                icon: Icons.person_add,
                label: "New Follower",
                color: Colors.blueAccent,
              ),
              _buildEmptyFollowItem(
                icon: Icons.comment,
                label: "Comments & @",
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for each item
  Widget _buildEmptyFollowItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withOpacity(0.2),
            // shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 25, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
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
    // watch the follow loading set so UI updates per-item
    final loadingSet = ref.watch(followLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Message"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _emptyFollowView(),

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
                        final displayPic = u.displayPic ?? '';
                        final displayName = u.displayName ?? '';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),

                          // make avatar tappable
                          leading: GestureDetector(
                            onTap: () => _openOtherProfile(context, otherId),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage: displayPic.isNotEmpty
                                  ? NetworkImage(displayPic)
                                  : null,
                              child: displayPic.isEmpty
                                  ? Icon(
                                      PhosphorIcons.cat(),
                                      color: Colors.orange,
                                    )
                                  : null,
                            ),
                          ),

                          // title area tappable (name)
                          title: GestureDetector(
                            onTap: () => _openOtherProfile(context, otherId),
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
                                          .read(followLoadingProvider.notifier)
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
                                              followLoadingProvider.notifier,
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
  }
}
