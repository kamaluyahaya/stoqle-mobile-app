// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:stoqle/features/view/profile/post.dart';
// import 'package:stoqle/features/view/profile/product.dart';
// import 'package:stoqle/features/view/profile/productModel.dart';

// import '../../../component/colors/color.dart';
// import '../../auth/models/profile_model.dart';
// import '../../auth/state/profile_notifier.dart';
// import 'notes.dart';
// import 'profileData.dart';

// class ProfileMe extends ConsumerStatefulWidget {
//   const ProfileMe({Key? key}) : super(key: key);

//   @override
//   ConsumerState<ProfileMe> createState() => _ProfileMeState();
// }

// class _ProfileMeState extends ConsumerState<ProfileMe> {
//   final ScrollController _scrollController = ScrollController();
//   double _appBarOpacity = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     final newOpacity = _scrollController.offset > 20 ? 1.0 : 0.0;
//     if (newOpacity != _appBarOpacity)
//       setState(() => _appBarOpacity = newOpacity);
//   }

//   @override
//   void dispose() {
//     _scrollController
//       ..removeListener(_onScroll)
//       ..dispose();
//     super.dispose();
//   }

//   Future<void> _handleRefresh() async {
//     await ref.read(profileNotifierProvider.notifier).refresh();
//   }

//   // Convert whatever shape your profile uses for products into ProductSample
//   List<ProductSample> _mapProductsFromProfile(Profile? profile, String kind) {
//     // If Profile has typed lists already, return them.
//     final dynamic maybeList = {
//       'notes': "kdk",
//       'products': "kdkd",
//       'posts': "ddkd",
//     }[kind];

//     if (maybeList is List<ProductSample>) return maybeList;
//     if (maybeList is List) {
//       // Attempt to map list items (commonly Map or domain objects)
//       return maybeList.map<ProductSample>((item) {
//         try {
//           if (item is ProductSample) return item;
//           if (item is Map) {
//             return ProductSample(
//               id:
//                   (item['id'] ??
//                           item['productId'] ??
//                           '${kind}_${item.hashCode}')
//                       .toString(),
//               imageUrl:
//                   (item['imageUrl'] ?? item['image'] ?? item['photo'] ?? '')
//                       .toString(),
//               name: (item['name'] ?? item['title'] ?? 'Item').toString(),
//               price:
//                   double.tryParse(
//                     (item['price'] ?? item['amount'] ?? '0').toString(),
//                   ) ??
//                   0.0,
//             );
//           }
//           // Try reflection-like access for object with fields (dart:mirrors not available)
//           // Best-effort: convert using toString fallback
//           return ProductSample(
//             id: '${kind}_${item.hashCode}',
//             imageUrl: '',
//             name: item.toString(),
//             price: 0.0,
//           );
//         } catch (_) {
//           return ProductSample(
//             id: '${kind}_${item.hashCode}',
//             imageUrl: '',
//             name: 'Item',
//             price: 0.0,
//           );
//         }
//       }).toList();
//     }

//     // Fallback: empty
//     return [];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profileAsync = ref.watch(profileNotifierProvider);

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 200),
//           transitionBuilder: (child, animation) {
//             final offsetAnim =
//                 Tween<Offset>(
//                   begin: const Offset(0, 1),
//                   end: Offset.zero,
//                 ).animate(
//                   CurvedAnimation(parent: animation, curve: Curves.easeOut),
//                 );
//             return SlideTransition(position: offsetAnim, child: child);
//           },
//           child: _appBarOpacity > 0.9
//               ? SafeArea(
//                   child: CircleAvatar(
//                     key: const ValueKey('avatar'),
//                     radius: 16,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       PhosphorIcons.cat(),
//                       size: 20,
//                       color: Colors.orange,
//                     ),
//                   ),
//                 )
//               : const SizedBox.shrink(key: ValueKey('empty')),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: Icon(Icons.menu, color: kWhite),
//         actions: [
//           AnimatedOpacity(
//             opacity: (1.0 - _appBarOpacity).clamp(
//               0.0,
//               1.0,
//             ), // actions visible when header is visible
//             duration: const Duration(milliseconds: 200),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.14),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Icon(
//                         PhosphorIcons.image(),
//                         size: 14,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(width: 6),
//                       const Text(
//                         'Edit Cover photo',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),

//                 // Icon(PhosphorIcons.qrCode(), color: kWhite),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Icon(PhosphorIcons.shareFat(), color: kWhite),
//           ),
//         ],
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 const Color(0xFF675662).withOpacity(_appBarOpacity),
//                 const Color(0xFFA87B85).withOpacity(_appBarOpacity),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: DefaultTabController(
//         length: 3,
//         child: profileAsync.when(
//           loading: () => _buildNestedScrollView(
//             profile: null,
//             notesProducts: const [],
//             products: const [],
//             postsProducts: const [],
//             body: const TabBarView(
//               physics: ClampingScrollPhysics(),
//               children: [
//                 Center(child: CircularProgressIndicator()),
//                 Center(child: CircularProgressIndicator()),
//                 Center(child: CircularProgressIndicator()),
//               ],
//             ),
//           ),
//           error: (err, st) => _buildNestedScrollView(
//             profile: null,
//             notesProducts: const [],
//             products: const [],
//             postsProducts: const [],
//             body: ListView(
//               padding: const EdgeInsets.all(24),
//               children: [
//                 Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
//                 const SizedBox(height: 12),
//                 Text('Failed to load profile: $err'),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: _handleRefresh,
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           ),
//           data: (profile) {
//             final notes = _mapProductsFromProfile(profile, 'notes');
//             final prods = _mapProductsFromProfile(profile, 'products');
//             final posts = _mapProductsFromProfile(profile, 'posts');

//             return _buildNestedScrollView(
//               profile: profile,
//               notesProducts: notes,
//               products: prods,
//               postsProducts: posts,
//               body: TabBarView(
//                 physics: const ClampingScrollPhysics(),
//                 children: [
//                   NotesTab(items: notes),
//                   ProductsTab(items: prods),
//                   PostsTab(items: posts),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildNestedScrollView({
//     required Profile? profile,
//     required List<ProductSample> notesProducts,
//     required List<ProductSample> products,
//     required List<ProductSample> postsProducts,
//     required Widget body,
//   }) {
//     return NestedScrollView(
//       controller: _scrollController,
//       // physics: const AlwaysScrollableScrollPhysics(),
//       // floatHeaderSlivers: true,
//       headerSliverBuilder: (context, innerBoxIsScrolled) => [
//         // SliverToBoxAdapter(child: _buildHeader(profile)),
//         SliverToBoxAdapter(
//           child: SizedBox(
//             // height: _kHeaderHeight,
//             child: _buildHeader(profile),
//           ),
//         ),
//         SliverPersistentHeader(
//           pinned: true,
//           delegate: _TabBarDelegate(
//             TabBar(
//               isScrollable: true,
//               tabs: const [
//                 Tab(text: 'Notes'),
//                 Tab(text: 'Products'),
//                 Tab(text: 'Post'),
//               ],
//               labelStyle: const TextStyle(fontFamily: "Bold"),
//               indicatorColor: AppColors.kDefault,
//               indicatorSize: TabBarIndicatorSize.label,
//               labelColor: Theme.of(context).iconTheme.color,
//               unselectedLabelColor: Colors.grey,
//             ),
//           ),
//         ),
//       ],
//       body: RefreshIndicator(onRefresh: _handleRefresh, child: body),
//     );
//   }

//   Widget _buildHeader(Profile? profile) {
//     final hasBg =
//         profile?.bgPhotoUrl != null && profile!.bgPhotoUrl!.isNotEmpty;
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: !hasBg
//             ? LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: const [
//                   Color(0xFF3A3A5B),
//                   Color(0xFF675662),
//                   Color(0xFFA87B85),
//                 ],
//               )
//             : null,
//       ),
//       child: Stack(
//         children: [
//           if (hasBg)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     fit: BoxFit.cover,
//                     image: NetworkImage(profile.bgPhotoUrl!),
//                   ),
//                 ),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.black.withOpacity(0.4),
//                         Colors.black.withOpacity(0.9),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               const SizedBox(height: 70),
//               Material(
//                 color: Colors.transparent,
//                 child: ProfileData(
//                   userProfileUrl: profile != null
//                       ? '${profile?.profilePic}'
//                       : '',
//                   user_name: profile?.fullName ?? '—',
//                   user_id: profile != null ? '${profile.userId}' : '—',
//                   following: profile != null ? '${profile.following}' : '—',
//                   followers: profile != null ? '${profile.followers}' : '—',
//                   likes: profile != null ? '${profile.posts}' : '—',
//                   bio: profile?.bio ?? 'No bio yet',
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Delegate used to pin tab bar and provide background
// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   _TabBarDelegate(this.tabBar);

//   @override
//   double get minExtent => tabBar.preferredSize.height;
//   @override
//   double get maxExtent => tabBar.preferredSize.height;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: Theme.of(context).scaffoldBackgroundColor,
//       child: tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
//       oldDelegate.tabBar != tabBar;
// }
