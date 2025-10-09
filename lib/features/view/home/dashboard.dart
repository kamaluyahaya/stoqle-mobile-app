import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/core/widget/constant.dart';
import 'package:stoqle/features/view/home/explore.dart';
import 'package:stoqle/features/view/home/nearby.dart';
import 'package:stoqle/features/view/profile/me/widget/drawer.dart';

import '../../auth/provider/auth_provider.dart';
import '../../auth/state/profile_notifier.dart';
import 'follow.dart';

// -------------------- DASHBOARD --------------------
class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(profileNotifierProvider);
    return DefaultTabController(
      initialIndex: 1,
      length: 3, // Number of tabs
      child: Scaffold(
        drawer: profileAsync.when(
          loading: () =>
              const Drawer(child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const Drawer(
            child: Center(child: Text("Failed to load profile")),
          ),
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
                            } else {
                              // Navigate to Business Registration page
                            }
                          },
                          title: profile.isBusinessOwner
                              ? "My Shop"
                              : "Become a Merchant",
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
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/intro',
                              (route) => false,
                            );
                          }
                          toastNotify(
                            "Sign out successfully, see you back soon",
                          );
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
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TabBar(
                  // isScrollable: true,
                  dividerColor: Theme.of(context).appBarTheme.backgroundColor,
                  tabs: const [
                    Tab(text: 'Follow'),
                    Tab(text: 'Explore'),
                    Tab(text: 'Nearby'),
                  ],
                  labelStyle: const TextStyle(fontFamily: "Bold"),
                  indicatorColor: AppColors.kDefault,
                  indicatorSize: TabBarIndicatorSize.label,
                  // labelColor: ,
                  unselectedLabelColor: Colors.grey,
                ),
              ),
              IconButton(
                icon: Icon(
                  PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold),
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  // Action for search icon
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: const [FollowPage(), ExplorePage(), NearbyPage()],
        ),
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
}
