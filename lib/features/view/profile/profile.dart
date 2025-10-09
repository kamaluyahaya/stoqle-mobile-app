// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:stoqle/features/view/profile/productModel.dart';

// import '../../../component/colors/color.dart';
// import '../../auth/models/profile_model.dart';
// import '../../auth/state/profile_notifier.dart';
// import 'other/otherProfileData.dart';
// // import 'other/otherProfileData.dart';

// // Adjust this import path to where your Profile model actually lives in your project

// class OtherUserProfile extends ConsumerStatefulWidget {
//   const OtherUserProfile({Key? key}) : super(key: key);

//   @override
//   ConsumerState<OtherUserProfile> createState() => _OtherUserProfileState();
// }

// class _OtherUserProfileState extends ConsumerState<OtherUserProfile> {
//   final ScrollController _scrollController = ScrollController();
//   double _appBarOpacity = 0.0;

//   final List<Color> _topColors = const [Color(0xFF675662), Color(0xFFA87B85)];

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     final offset = _scrollController.offset;
//     final newOpacity = offset > 20 ? 1.0 : 0.0;
//     if (newOpacity != _appBarOpacity) {
//       setState(() => _appBarOpacity = newOpacity);
//     }
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

//   @override
//   Widget build(BuildContext context) {
//     final profileAsync = ref.watch(profileNotifierProvider);

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 200),
//           transitionBuilder: (child, animation) {
//             final offsetAnimation =
//                 Tween<Offset>(
//                   begin: const Offset(0, 1),
//                   end: Offset.zero,
//                 ).animate(
//                   CurvedAnimation(parent: animation, curve: Curves.easeOut),
//                 );
//             return SlideTransition(position: offsetAnimation, child: child);
//           },
//           child: _appBarOpacity > 0.9
//               ? SafeArea(
//                   child: CircleAvatar(
//                     key: const ValueKey("avatar"),
//                     radius: 15,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       PhosphorIcons.cat(),
//                       size: 20,
//                       color: Colors.orange,
//                     ),
//                   ),
//                 )
//               : const SizedBox.shrink(key: ValueKey("empty")),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: Icon(Icons.menu, color: kWhite),
//         actions: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AnimatedOpacity(
//                 opacity: _appBarOpacity <= 0.7 ? 1.0 : 0.0,
//                 duration: const Duration(milliseconds: 400),
//                 curve: Curves.easeInOut,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2), // transparent white
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
//                         "Edit Cover photo",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Icon(PhosphorIcons.qrCode(), color: kWhite),
//               const SizedBox(width: 6),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Icon(PhosphorIcons.shareFat(), color: kWhite),
//               ),
//             ],
//           ),
//         ],
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: _topColors
//                   .map((c) => c.withOpacity(_appBarOpacity))
//                   .toList(),
//             ),
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: profileAsync.when(
//           loading: () => SingleChildScrollView(
//             controller: _scrollController,
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: Column(
//               children: [_buildHeader(null), _buildContentPlaceholder()],
//             ),
//           ),
//           error: (err, st) => SingleChildScrollView(
//             controller: _scrollController,
//             // physics: const AlwaysScrollableScrollPhysics(),
//             child: Column(
//               children: [
//                 _buildHeader(null),
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   alignment: Alignment.center,
//                   child: Column(
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 48,
//                         color: Colors.redAccent,
//                       ),
//                       const SizedBox(height: 12),
//                       Text('Failed to load profile: $err'),
//                       const SizedBox(height: 12),
//                       ElevatedButton(
//                         onPressed: () => ref
//                             .read(profileNotifierProvider.notifier)
//                             .refresh(),
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           data: (profile) => SingleChildScrollView(
//             controller: _scrollController,
//             child: Column(
//               children: [
//                 _buildHeader(profile),
//                 _buildContentPlaceholder(), // ✅ TabBar + content
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(Profile? profile) {
//     final hasBg =
//         profile?.bgPhotoUrl != null && profile!.bgPhotoUrl!.isNotEmpty;
//     profile?.profilePic != null && profile!.profilePic!.isNotEmpty;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: !hasBg
//             ? LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF3A3A5B),
//                   Color(0xFF675662),
//                   Color(0xFFA87B85),
//                 ],
//               )
//             : null,
//       ),
//       // alignment: Alignment.center,
//       child: Stack(
//         children: [
//           // Background image with dark overlay
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
//                         Colors.black.withOpacity(0.4), // whole image darker
//                         Colors.black.withOpacity(0.9), // bottom extra dark
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//           // Content stays on top of the darkened image
//           Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               const SizedBox(height: 70),
//               Material(
//                 color: Colors.transparent,
//                 child: OtherProfileData(
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

//   Widget _buildContentPlaceholder() {
//     return DefaultTabController(
//       length: 3,
//       child: Builder(
//         builder: (context) {
//           final TabController tabController = DefaultTabController.of(context);

//           return Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const TabBar(
//                   labelColor: Colors.black,
//                   indicatorColor: Colors.blue,
//                   tabs: [
//                     Tab(text: 'Notes'),
//                     Tab(text: 'Products'),
//                     Tab(text: 'Post'),
//                   ],
//                 ),
//                 const SizedBox(height: 12),

//                 /// Watch tab index
//                 AnimatedBuilder(
//                   animation: tabController,
//                   builder: (context, _) {
//                     return IndexedStack(
//                       index: tabController.index,
//                       children: const [NotesTab(), ProductsTab(), PostsTab()],
//                     );
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// /// -------------------- NOTES TAB --------------------
// class NotesTab extends StatelessWidget {
//   final List<ProductSample>? items;
//   const NotesTab({Key? key, this.items}) : super(key: key);

//   List<ProductSample> _default() {
//     return List.generate(
//       8,
//       (i) => ProductSample(
//         id: 'note-$i',
//         imageUrl: 'https://picsum.photos/seed/note_$i/400/400',
//         name: 'Note ${i + 1}',
//         price: (500 + i * 120).toDouble(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final list = items == null || items!.isEmpty ? _default() : items!;
//     return GridView.builder(
//       key: const PageStorageKey('notes-grid'),
//       padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         childAspectRatio: 0.7,
//       ),
//       itemCount: list.length,
//       itemBuilder: (ctx, i) => ProductCard(product: list[i]),
//     );
//   }
// }

// /// -------------------- PRODUCTS TAB --------------------
// class ProductsTab extends StatelessWidget {
//   final List<ProductSample>? items;
//   const ProductsTab({Key? key, this.items}) : super(key: key);

//   List<ProductSample> _default() {
//     return List.generate(
//       10,
//       (i) => ProductSample(
//         id: 'product-$i',
//         imageUrl: 'https://picsum.photos/seed/product_$i/400/400',
//         name: 'Product ${i + 1}',
//         price: (1000 + i * 250).toDouble(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final list = items == null || items!.isEmpty ? _default() : items!;
//     return GridView.builder(
//       key: const PageStorageKey('products-grid'),
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       shrinkWrap: true,
//       // physics: const AlwaysScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         childAspectRatio: 0.7,
//       ),
//       itemCount: list.length,
//       itemBuilder: (ctx, i) => ProductCard(product: list[i]),
//     );
//   }
// }

// /// -------------------- POSTS TAB --------------------
// class PostsTab extends StatelessWidget {
//   final List<ProductSample>? items;
//   const PostsTab({Key? key, this.items}) : super(key: key);

//   List<ProductSample> _default() {
//     return List.generate(
//       6,
//       (i) => ProductSample(
//         id: 'post-$i',
//         imageUrl: 'https://picsum.photos/seed/post_$i/400/400',
//         name: 'Post ${i + 1}',
//         price: (0).toDouble(), // posts can have 0 or dummy value
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final list = items == null || items!.isEmpty ? _default() : items!;
//     return GridView.builder(
//       key: const PageStorageKey('posts-grid'),
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       shrinkWrap: true,
//       // physics: const AlwaysScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         childAspectRatio: 0.7,
//       ),
//       itemCount: list.length,
//       itemBuilder: (ctx, i) => ProductCard(product: list[i]),
//     );
//   }
// }
