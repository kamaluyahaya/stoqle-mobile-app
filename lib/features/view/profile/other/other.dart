import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:stoqle/core/widget/constant.dart';
import 'package:stoqle/features/auth/models/suggestion_param.dart';
import 'package:stoqle/features/auth/provider/suggestion_provider.dart';
import 'package:stoqle/features/auth/state/suggestion_notifier.dart';
import 'package:stoqle/features/view/profile/other/otherNotes.dart';
import 'package:stoqle/features/view/profile/productModel.dart';

import '../../../auth/models/profile_model.dart';
import '../../../auth/provider/other_profile_provider.dart';
import '../../../auth/state/profile_notifier.dart';
import 'otherProfileData.dart';

class OtherProfile extends ConsumerStatefulWidget {
  /// if otherUserId is provided, this screen shows other user's profile
  final String? otherUserId;

  const OtherProfile({Key? key, this.otherUserId}) : super(key: key);

  @override
  ConsumerState<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends ConsumerState<OtherProfile> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  final List<Color> _topColors = const [Color(0xFF675662), Color(0xFFA87B85)];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final newOpacity = offset > 20 ? 1.0 : 0.0;
    if (newOpacity != _appBarOpacity) {
      setState(() => _appBarOpacity = newOpacity);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (widget.otherUserId == null) {
      await ref.read(profileNotifierProvider.notifier).refresh();
    } else {
      await ref
          .read(profileByIdProvider(widget.otherUserId!).notifier)
          .refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOther = widget.otherUserId != null;

    final profileAsync = isOther
        ? ref.watch(profileByIdProvider(widget.otherUserId!))
        : ref.watch(profileNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Replace your existing appBar: AppBar(...) with this block
      appBar: AppBar(
        title: profileAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (profile) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              final offsetAnimation =
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  );
              return SlideTransition(position: offsetAnimation, child: child);
            },
            child: _appBarOpacity > 0.9
                ? SafeArea(
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey.shade200,
                      child:
                          (profile.profilePic != null &&
                              profile.profilePic!.isNotEmpty)
                          ? ClipOval(
                              child: Image.network(
                                profile.profilePic!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              ),
                            )
                          : Icon(
                              PhosphorIcons.cat(),
                              size: 20,
                              color: Colors.orange,
                            ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey("empty")),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: kWhite),
        ),

        // ---------- Actions: show functioning Follow button when viewing other profile ----------
        // ---------- Replace your existing actions: [ ... ] with this ----------
        actions: [
          profileAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (profile) {
              if (!isOther) return const SizedBox.shrink();

              final int? userId = profile.userId;
              if (userId == null) return const SizedBox.shrink();

              final loadingSet = ref.watch(followLoadingProvider);
              final isLoading = loadingSet.contains(userId);
              final isFollowed = profile.isFollowing;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    opacity: _appBarOpacity > 0.7 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () async {
                              // guard
                              if (userId == null) return;

                              // add to loading set
                              ref.read(followLoadingProvider.notifier).update((
                                s,
                              ) {
                                final copy = Set<int>.from(s);
                                copy.add(userId);
                                return copy;
                              });

                              try {
                                const params = SuggestionParams(
                                  limit: 8,
                                  offset: 0,
                                  q: '',
                                );
                                final success = await ref
                                    .read(
                                      suggestionNotifierProvider(
                                        params,
                                      ).notifier,
                                    )
                                    .followUser(userId);

                                if (success) {
                                  // message depends on previous state
                                  final msg = isFollowed
                                      ? 'Unfollowed'
                                      : 'Followed';
                                  try {
                                    toastNotify(msg);
                                  } catch (_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  }

                                  // Refresh profile so isFollowing & counts update
                                  if (widget.otherUserId != null) {
                                    await ref
                                        .read(
                                          profileByIdProvider(
                                            widget.otherUserId!,
                                          ).notifier,
                                        )
                                        .refresh();
                                  } else {
                                    await ref
                                        .read(profileNotifierProvider.notifier)
                                        .refresh();
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to update follow status',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                  ),
                                );
                              } finally {
                                // remove loading
                                ref.read(followLoadingProvider.notifier).update(
                                  (s) {
                                    final copy = Set<int>.from(s);
                                    copy.remove(userId);
                                    return copy;
                                  },
                                );
                              }
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFollowed
                              ? const Color.fromARGB(40, 255, 255, 255)
                              : AppColors.kDefault,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CustomCircularProgressIndicator(),
                              )
                            : Text(
                                isFollowed ? 'Followed' : 'Follow',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(PhosphorIcons.shareFat(), color: kWhite),
                  ),
                ],
              );
            },
          ),
        ],

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _topColors
                  .map((c) => c.withOpacity(_appBarOpacity))
                  .toList(),
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: profileAsync.when(
          loading: () => SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(null, isOther: isOther),
                _buildContentPlaceholder(
                  isOther ? widget.otherUserId : null,
                  false,
                ),
              ],
            ),
          ),
          error: (err, st) => SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeader(null, isOther: isOther),
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      Text('Failed to load profile: $err'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (isOther) {
                            ref
                                .read(
                                  profileByIdProvider(
                                    widget.otherUserId!,
                                  ).notifier,
                                )
                                .refresh();
                          } else {
                            ref
                                .read(profileNotifierProvider.notifier)
                                .refresh();
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          data: (profile) => SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeader(profile, isOther: isOther),
                // _buildContentPlaceholder(isOther ? widget.otherUserId : 0),
                _buildContentPlaceholder(
                  isOther ? widget.otherUserId : null,
                  profile.isBusinessOwner,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Profile? profile, {required bool isOther}) {
    final hasBg =
        profile?.bgPhotoUrl != null && profile!.bgPhotoUrl!.isNotEmpty;
    profile?.profilePic != null && profile!.profilePic!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: !hasBg
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3A3A5B),
                  Color(0xFF675662),
                  Color(0xFFA87B85),
                ],
              )
            : null,
      ),
      // alignment: Alignment.center,
      child: Stack(
        children: [
          // Background image with dark overlay
          if (hasBg)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(profile.bgPhotoUrl!),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4), // whole image darker
                        Colors.black.withOpacity(0.9), // bottom extra dark
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Content stays on top of the darkened image
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 70),
              Material(
                color: Colors.transparent,
                child: // inside _buildHeader(...)
                OtherProfileData(
                  isBusinessOwner: profile != null
                      ? profile.isBusinessOwner
                      : false,
                  userProfileUrl: profile != null
                      ? '${profile.profilePic}'
                      : '',
                  user_name: profile?.displayName ?? '—',
                  user_id: profile != null ? '${profile.userId}' : '—',
                  following: profile != null ? '${profile.following}' : '—',
                  followers: profile != null ? '${profile.followers}' : '—',
                  likes: profile != null ? '${profile.posts}' : '—',
                  bio: profile?.bio ?? 'No bio yet',
                  isOtherProfile: isOther,
                  isFollowing: profile != null ? profile.isFollowing : false,
                  onFollowToggle: isOther
                      ? () async {
                          // Ensure we have a user id
                          final userId = profile?.userId;
                          if (userId == null) return;

                          // Add to loading set so UI shows spinner (same pattern you use elsewhere)
                          ref.read(followLoadingProvider.notifier).update((s) {
                            final copy = Set<int>.from(s);
                            copy.add(userId);
                            return copy;
                          });

                          try {
                            // Use same SuggestionParams instance you used for suggestions
                            const params = SuggestionParams(
                              limit: 8,
                              offset: 0,
                              q: '',
                            );

                            // Call followUser (assumes this toggles follow/unfollow and returns success bool)
                            final success = await ref
                                .read(
                                  suggestionNotifierProvider(params).notifier,
                                )
                                .followUser(userId);

                            if (success) {
                              // Give quick feedback (you used toastNotify earlier)
                              try {
                                toastNotify(
                                  'Follow',
                                ); // consistent with your other usages

                                setState(() {
                                  isOther = true;
                                });
                              } catch (_) {}
                            } else {}

                            // Refresh this profile so counts & follow status show updated values
                            if (widget.otherUserId != null) {
                              await ref
                                  .read(
                                    profileByIdProvider(
                                      widget.otherUserId!,
                                    ).notifier,
                                  )
                                  .refresh();
                            } else {
                              // if somehow no widget.otherUserId, refresh generic profile provider
                              await ref
                                  .read(profileNotifierProvider.notifier)
                                  .refresh();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          } finally {
                            // Remove from loading set
                            ref.read(followLoadingProvider.notifier).update((
                              s,
                            ) {
                              final copy = Set<int>.from(s);
                              copy.remove(userId);
                              return copy;
                            });
                          }
                        }
                      : null,
                  onChatPressed: isOther
                      ? () {
                          // open chat screen
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // _buildContentPlaceholder unchanged...
  Widget _buildContentPlaceholder(String? otherUserId, bool isBusinessOwner) {
    final tabs = <Tab>[
      const Tab(text: 'Notes'),
      if (isBusinessOwner) const Tab(text: 'Products'),
      const Tab(text: 'Posts'),
    ];

    final tabViews = <Widget>[
      if (otherUserId != null)
        OtherUserPost(userId: otherUserId)
      else
        const Center(child: Text("Your notes go here")),
      if (isBusinessOwner) const ProductsTab(),
      const PostsTab(),
    ];

    return DefaultTabController(
      length: tabs.length, // ✅ match tabs dynamically
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);

          return Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  automaticIndicatorColorAdjustment: true,
                  labelStyle: const TextStyle(fontFamily: "Bold"),
                  indicatorColor: AppColors.kDefault,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Theme.of(context).iconTheme.color,
                  unselectedLabelColor: Colors.grey,
                  dividerColor: AppColors.transparent,
                  tabs: tabs,
                ),
                const SizedBox(height: 12),

                AnimatedBuilder(
                  animation: tabController,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        IndexedStack(
                          index: tabController.index,
                          children: tabViews,
                        ),

                        if (tabController.indexIsChanging)
                          Container(
                            color: Colors.black.withOpacity(0.05),
                            child: Center(
                              child: CustomCircularProgressIndicator(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// -------------------- NOTES TAB --------------------

/// -------------------- PRODUCTS TAB --------------------
class ProductsTab extends StatelessWidget {
  final List<ProductSample>? items;
  const ProductsTab({Key? key, this.items}) : super(key: key);

  List<ProductSample> _default() {
    return List.generate(
      10,
      (i) => ProductSample(
        id: 'product-$i',
        imageUrl: 'https://picsum.photos/seed/product_$i/400/400',
        name: 'Product ${i + 1}',
        price: (1000 + i * 250).toDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = items == null || items!.isEmpty ? _default() : items!;
    return GridView.builder(
      key: const PageStorageKey('products-grid'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      shrinkWrap: true,
      // physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) => ProductCard(product: list[i]),
    );
  }
}

/// -------------------- POSTS TAB --------------------
class PostsTab extends StatelessWidget {
  final List<ProductSample>? items;
  const PostsTab({Key? key, this.items}) : super(key: key);

  List<ProductSample> _default() {
    return List.generate(
      6,
      (i) => ProductSample(
        id: 'post-$i',
        imageUrl: 'https://picsum.photos/seed/post_$i/400/400',
        name: 'Post ${i + 1}',
        price: (0).toDouble(), // posts can have 0 or dummy value
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = items == null || items!.isEmpty ? _default() : items!;
    return GridView.builder(
      key: const PageStorageKey('posts-grid'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      shrinkWrap: true,
      // physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) => ProductCard(product: list[i]),
    );
  }
}
