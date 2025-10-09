// pages/follow_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/lib/follow_params.dart';
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:stoqle/features/auth/provider/follow_provider.dart';
import 'package:stoqle/features/auth/state/user_summary.dart';
import '../../../auth/provider/auth_provider.dart';

class Follow extends ConsumerStatefulWidget {
  final int profileUserId;
  final FollowTab initialTab;

  const Follow({
    Key? key,
    required this.profileUserId,
    this.initialTab = FollowTab.friends, // default to friends
  }) : super(key: key);

  @override
  ConsumerState<Follow> createState() => _FollowState();
}

class _FollowState extends ConsumerState<Follow>
    with SingleTickerProviderStateMixin {
  late FollowTab selectedTab;
  late TabController _tabController;

  // order requested: (Friends, Following, Followers, Recommend)
  final tabs = ['Friends', 'Following', 'Followers', 'Recommend'];

  // track which tabs we've requested data for so we can show loader instead of empty state
  final Map<FollowTab, bool> _requested = {
    FollowTab.friends: false,
    FollowTab.following: false,
    FollowTab.followers: false,
    FollowTab.recommend: false,
  };

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
    _tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: selectedTab.index,
    );

    // mark initial tab requested and trigger load immediately
    _requested[selectedTab] = true;
    Future.microtask(() {
      final key = FollowParams(tab: selectedTab, userId: widget.profileUserId);
      ref.read(paginatedNotifierProvider(key).notifier).refresh();
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final newTab = FollowTab.values[_tabController.index];
      if (newTab != selectedTab) {
        setState(() => selectedTab = newTab);
        // mark requested before calling refresh so UI shows loader immediately
        _requested[newTab] = true;
        final key = FollowParams(
          tab: selectedTab,
          userId: widget.profileUserId,
        );
        ref.read(paginatedNotifierProvider(key).notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshCurrent() {
    final key = FollowParams(tab: selectedTab, userId: widget.profileUserId);
    ref.read(paginatedNotifierProvider(key).notifier).refresh();
  }

  Future<void> _onToggleFollow(int targetId, bool currentlyFollowing) async {
    final key = FollowParams(tab: selectedTab, userId: widget.profileUserId);
    final notifier = ref.read(paginatedNotifierProvider(key).notifier);

    try {
      await notifier.toggleFollow(
        targetId,
        currentlyFollowing: currentlyFollowing,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Action failed')));
    }
  }

  Widget _avatar(UserSummary u) {
    if (u.profilePic != null && u.profilePic!.isNotEmpty) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[200],
        backgroundImage: CachedNetworkImageProvider(u.profilePic!),
      );
    }
    final fallbackUrl =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(u.fullName)}';
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.grey[200],
      backgroundImage: CachedNetworkImageProvider(fallbackUrl),
    );
  }

  Widget _buildRow(UserSummary u) {
    final currentUserId = ref.read(authServiceProvider).user_id;
    final isMutual =
        (u.isFollowedByViewer ?? false) && (u.isFollowingViewer ?? false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _avatar(u),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.fullName, style: const TextStyle(fontFamily: "Bold")),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Text(
                        '${u.totalFollowers} followers',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${u.totalPosts} posts',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (u.userId != currentUserId)
            SizedBox(
              height: 35,
              child: OutlinedButton(
                onPressed: () async {
                  if (u.isFollowedByViewer ?? false) {
                    final confirmed =
                        await showCupertinoDialog<bool>(
                          context: context,
                          builder: (ctx) => CupertinoAlertDialog(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                isMutual
                                    ? 'Unfriend the Author'
                                    : 'Unfollow the Author',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(
                                  isMutual ? 'Unfriend' : 'Unfollow',
                                  style: const TextStyle(
                                    fontFamily: "Bold",
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (confirmed) await _onToggleFollow(u.userId, true);
                  } else {
                    await _onToggleFollow(u.userId, false);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isMutual
                        ? Colors.green
                        : ((u.isFollowedByViewer ?? false)
                              ? kWhite40
                              : AppColors.kDefault),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Text(
                  isMutual
                      ? 'Friends'
                      : ((u.isFollowedByViewer ?? false)
                            ? 'Following'
                            : 'Follow'),
                  style: TextStyle(
                    color: isMutual
                        ? Colors.green
                        : ((u.isFollowedByViewer ?? false)
                              ? kWhiteSmoke
                              : AppColors.kDefault),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(FollowTab tab) {
    String title = '',
        subtitle = '',
        assetPath = 'assets/images/message-icon.png';
    switch (tab) {
      case FollowTab.following:
        title = 'Not following anyone';
        subtitle = 'You haven\'t followed any accounts yet.';
        break;
      case FollowTab.followers:
        title = 'No followers yet';
        subtitle = 'People will appear here when someone follows this account.';
        break;
      case FollowTab.friends:
        title = 'No friends yet';
        subtitle = 'Mutual followers will appear here.';
        break;
      case FollowTab.recommend:
        title = 'No recommendations';
        subtitle = 'We\'ll show suggested accounts to follow here.';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(18),
            child: Image.asset(assetPath, height: 70, fit: BoxFit.contain),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _loadingSkeleton() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 2),
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        height: 84,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // color: Colors.white,
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: 6,
    );
  }

  Widget _buildListForTab(FollowTab tab) {
    final key = FollowParams(tab: tab, userId: widget.profileUserId);
    final state = ref.watch(paginatedNotifierProvider(key));

    // If the tab has been requested and there are no items yet -> show loader while waiting
    if (_requested[tab] == true && (state.items.isEmpty)) {
      if (state.loading) {
        return _loadingSkeleton();
      }
      // if we requested but not loading and still empty -> show empty state (request completed)
      if (state.error != null)
        return Center(child: Text('Error: ${state.error}'));
      return _buildEmptyState(tab);
    }

    // normal behaviour when items exist or when tab not requested yet
    if (state.loading && state.items.isEmpty) {
      // fallback skeleton
      return _loadingSkeleton();
    }

    if (state.error != null && state.items.isEmpty)
      return Center(child: Text('Error: ${state.error}'));
    if (!state.loading && state.items.isEmpty) return _buildEmptyState(tab);

    final totalCount = _getTotalFromState(state, state.items.length);

    final headerTitle = {
      FollowTab.following: 'Following',
      FollowTab.followers: 'Followers',
      FollowTab.friends: 'Friends',
      FollowTab.recommend: 'Recommendations',
    }[tab]!;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(paginatedNotifierProvider(key).notifier).refresh(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.accent2,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        headerTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '($totalCount)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 120) {
                      ref
                          .read(paginatedNotifierProvider(key).notifier)
                          .loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    itemBuilder: (ctx, idx) {
                      if (idx < state.items.length)
                        return _buildRow(state.items[idx]);
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CustomCircularProgressIndicator()),
                      );
                    },
                    shrinkWrap: true,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemCount: state.hasMore
                        ? state.items.length + 1
                        : state.items.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalFromState(dynamic state, int fallback) {
    try {
      final dyn = state as dynamic;
      final cand =
          dyn.total ??
          dyn.totalItems ??
          dyn.meta?.total ??
          dyn.meta?.count ??
          dyn.count ??
          dyn.total_count;
      if (cand != null) {
        if (cand is int) return cand;
        if (cand is String) return int.tryParse(cand) ?? fallback;
        if (cand is num) return cand.toInt();
      }
    } catch (_) {}
    try {
      return (state.items as List).length;
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: kWhite),
        ),
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          indicatorWeight: 0.5,
          labelColor: kWhite,
          indicatorColor: AppColors.kDefault,
          dividerColor: AppColors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: "Bold"),
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Following'),
            Tab(text: 'Followers'),
            Tab(text: 'Recommend'),
          ],
          onTap: (idx) {
            final newTab = FollowTab.values[idx];
            setState(() {
              selectedTab = newTab;
              _requested[newTab] =
                  true; // mark requested so loader shows immediately
            });
            final key = FollowParams(
              tab: selectedTab,
              userId: widget.profileUserId,
            );
            // schedule refresh asap
            Future.microtask(
              () => ref.read(paginatedNotifierProvider(key).notifier).refresh(),
            );
          },
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildListForTab(FollowTab.friends),
            _buildListForTab(FollowTab.following),
            _buildListForTab(FollowTab.followers),
            _buildListForTab(FollowTab.recommend),
          ],
        ),
      ),
    );
  }
}
