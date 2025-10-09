import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/core/widget/constant.dart';
import 'package:stoqle/features/auth/provider/auth_provider.dart';
import 'package:stoqle/features/view/business/edit/edit.dart';
import 'package:stoqle/features/view/profile/me/note_tab.dart';
import 'package:stoqle/features/view/profile/productModel.dart';
import 'package:stoqle/features/view/profile/me/profileData.dart';

import '../../../auth/models/profile_model.dart';
import '../../../auth/state/profile_notifier.dart';
import '../../business_registration/intro_page.dart';
import 'widget/drawer.dart';

class ProfileMe extends ConsumerStatefulWidget {
  const ProfileMe({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileMe> createState() => _ProfileMeState();
}

class _ProfileMeState extends ConsumerState<ProfileMe> {
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

  void _openImageViewer(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: PhotoViewGallery(
            pageOptions: [
              PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrl),
                heroAttributes: const PhotoViewHeroAttributes(
                  tag: "profileOrCover",
                ),
              ),
            ],
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await ref.read(profileNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: profileAsync.when(
        loading: () =>
            const Drawer(child: Center(child: CircularProgressIndicator())),
        error: (_, __) =>
            const Drawer(child: Center(child: Text("Failed to load profile"))),
        data: (profile) => Drawer(
          backgroundColor: isDark ? AppColors.kDarkMode : kWhiteSmoke,
          child: Column(
            children: [
              // ✅ Main scrollable drawer content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    const SizedBox(height: 40),

                    // Add Friends
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.accent2 : kWhite,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DrawerList(
                        onTap: () {},
                        title: "Add Friends",
                        icon: Icon(PhosphorIcons.userPlus()), // 👤➕
                      ),
                    ),

                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.accent2 : kWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DrawerList(
                        onTap: () {
                          if (profile.isBusinessOwner) {
                            // Navigate to My Shop page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => StoqleIntroSlidePage(),
                              ),
                            );
                          }
                        },
                        title: profile.isBusinessOwner
                            ? "My Shop"
                            : "Open Store",
                        icon: Icon(
                          profile.isBusinessOwner
                              ? PhosphorIcons.storefront() // 🏬
                              : PhosphorIcons.briefcase(), // 💼
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Business Section
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.accent2 : kWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          DrawerList(
                            onTap: () {},
                            title: "Orders",
                            icon: Icon(PhosphorIcons.package()), // 📦
                          ),
                          DrawerList(
                            onTap: () {},
                            title: "Cart",
                            icon: Icon(PhosphorIcons.shoppingCart()), // 🛒
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Other Items
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.accent2 : kWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DrawerList(
                        onTap: () {},
                        title: "My Followers",
                        icon: Icon(PhosphorIcons.users()), // 👥
                      ),
                    ),
                    // DrawerList(
                    //   onTap: () {},
                    //   title: "Unlimited Data",
                    //   icon: Icon(PhosphorIcons.wifiHigh()), // 📶
                    // ),
                    // DrawerList(
                    //   onTap: () {},
                    //   title: "Product Trial",
                    //   icon: Icon(PhosphorIcons.flask()), // 🧪
                    // ),
                  ],
                ),
              ),

              // ✅ Bottom Section (Help, Settings, Scan)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _bottomIcon(
                      icon: PhosphorIcons.signOut(),
                      label: "Log out",
                      onTap: () async {
                        final authNotifier = ref.read(
                          authServiceProvider.notifier,
                        );

                        await authNotifier.logout();
                        ref.invalidate(profileNotifierProvider);

                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/intro', (route) => false);
                        }
                        toastNotify("Sign out successfully, see you back soon");
                      },
                    ),

                    _bottomIcon(
                      icon: PhosphorIcons.question(),
                      label: "Help Center",
                      onTap: () {
                        // Navigate to Help Center
                      },
                    ),
                    _bottomIcon(
                      icon: PhosphorIcons.gear(),
                      label: "Settings",
                      onTap: () {
                        // Navigate to Settings
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ Reusable helper for bottom icons
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          profileAsync.when(
            data: (profile) {
              final hasBg =
                  profile.bgPhotoUrl != null && profile.bgPhotoUrl!.isNotEmpty;

              if (!hasBg) {
                return AnimatedOpacity(
                  opacity: _appBarOpacity <= 0.7 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.image(),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Edit Cover photo",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(PhosphorIcons.shareFat(), color: kWhite),
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
              children: [_buildHeader(null), _buildContentPlaceholder(false)],
            ),
          ),
          error: (err, st) => SingleChildScrollView(
            controller: _scrollController,
            // physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(null),
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
                        onPressed: () => ref
                            .read(profileNotifierProvider.notifier)
                            .refresh(),
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
                _buildHeader(profile),
                _buildContentPlaceholder(
                  profile.isBusinessOwner,
                ), // ✅ TabBar + content
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Profile? profile) {
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
          if (hasBg)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _openImageViewer(context, profile.bgPhotoUrl!),
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
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
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
                child: ProfileData(
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: kWhite20),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildContentPlaceholder(bool isBusinessOwner) {
    final tabs = <Tab>[
      const Tab(text: 'Posts'),
      if (isBusinessOwner) const Tab(text: 'Products'),
      const Tab(text: 'Engagement'),
    ];

    final tabViews = <Widget>[
      const NotesTab(),
      if (isBusinessOwner) const ProductsTab(),
      const PostsTab(),
    ];

    return DefaultTabController(
      length: tabs.length, // match tabs dynamically
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);

          return Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TabBar(
                  automaticIndicatorColorAdjustment: true,
                  // indicatorAnimation: true,
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
                    return IndexedStack(
                      index: tabController.index,
                      children: tabViews,
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
