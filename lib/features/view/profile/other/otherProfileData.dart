// Replace your existing OtherProfileData class with this one
// me.dart (replace your existing file)
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:stoqle/features/auth/provider/follow_provider.dart';
import 'package:stoqle/features/view/profile/follow/follow.dart';
import 'package:stoqle/features/view/profile/productModel.dart';

import '../../../../component/colors/color.dart';

class OtherProfileData extends StatelessWidget {
  final String user_name,
      userProfileUrl,
      user_id,
      bio,
      following,
      followers,
      likes;

  /// When viewing another user's profile set this to true.
  final bool isOtherProfile;
  final bool isBusinessOwner;

  /// When isOtherProfile is true, this indicates whether current user follows them
  final bool isFollowing;

  /// Callback when follow/following button pressed
  final VoidCallback? onFollowToggle;

  /// Callback for chat icon pressed
  final VoidCallback? onChatPressed;

  const OtherProfileData({
    super.key,
    required this.user_name,
    required this.user_id,
    required this.bio,
    required this.following,
    required this.followers,
    required this.likes,
    required this.userProfileUrl,
    this.isOtherProfile = false,
    this.isFollowing = false,
    this.onFollowToggle,
    this.onChatPressed,
    required this.isBusinessOwner,
  });

  void _openImageViewer(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ✅ Fullscreen viewer
              PhotoViewGallery(
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

              // ✅ Buttons at bottom
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.4;

        final avatarRadius = math.min(35.0, math.max(22.0, maxH * 0.12));
        final spacing = math.max(6.0, maxH * 0.02);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing),

              // main row with avatar and user info
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () {
                        if (userProfileUrl.isNotEmpty) {
                          _openImageViewer(context, userProfileUrl);
                        } else {
                          // _pickAndCropProfile(
                          // context,
                          // ); // open picker if no photo
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: Colors.grey.shade200,
                              child: ClipOval(
                                child: userProfileUrl.isNotEmpty
                                    ? FadeInImage.assetNetwork(
                                        placeholder: 'assets/images/favio.png',
                                        image: userProfileUrl,
                                        fit: BoxFit.cover,
                                        width: avatarRadius * 2,
                                        height: avatarRadius * 2,
                                      )
                                    : Icon(
                                        PhosphorIcons.cat(),
                                        size: avatarRadius * 1.4,
                                        color: Colors.orange,
                                      ),
                              ),
                            ),
                          ),

                          // only show camera overlay when this is your own profile
                          if (!isOtherProfile) ...[
                            Container(
                              width: avatarRadius * 2,
                              height: avatarRadius * 2,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                PhosphorIcons.camera(),
                                size: avatarRadius * 0.6,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: math.max(10, avatarRadius * 0.34),
                                backgroundColor: Colors.yellow,
                                child: Icon(
                                  PhosphorIcons.plus(),
                                  size: math.max(12, avatarRadius * 0.4),
                                  color: kBlack,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          AutoSizeText(
                            user_name,
                            style: TextStyle(
                              color: kWhite,
                              fontFamily: "bold",
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: spacing),
                          Text(
                            'stoqle_id: $user_id',
                            style: TextStyle(color: kWhite),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // bio
              Padding(
                padding: const EdgeInsets.only(right: 50.0, left: 8.0),
                child: Text(bio, style: TextStyle(color: kWhite)),
              ),

              SizedBox(height: spacing),

              // follow / stats and buttons; use Wrap to avoid overflow on smaller widths
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _statColumn(
                          following.toString(),
                          'Following',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    // Follow(profileUserId: int.parse(user_id)),
                                    Follow(
                                      profileUserId: int.parse(user_id),
                                      initialTab: FollowTab.following,
                                    ),
                              ),
                            ).then((_) {
                              // inside FollowPage you set the default tab = Following
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _statColumn(
                          followers.toString(),
                          'Followers',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    // Follow(profileUserId: int.parse(user_id)),
                                    Follow(
                                      profileUserId: int.parse(user_id),
                                      initialTab: FollowTab.followers,
                                    ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _statColumn(
                          likes.toString(),
                          'Likes&Col',
                          onTap: () {
                            // Navigate to likes/collection page separately
                            Navigator.pushNamed(context, '/likesPage');
                          },
                        ),
                      ],
                    ),

                    // Right-side buttons: Edit Profile + Settings for your profile
                    // or Follow/Following + Chat for other user's profile
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isOtherProfile) ...[
                          _roundedButton('Edit Profile', context, height: 35),
                          const SizedBox(width: 10),
                          _roundedIconButton(
                            Icons.settings,
                            width: 50,
                            height: 30,
                          ),
                        ] else ...[
                          _followButton(
                            context,
                            isFollowing: isFollowing,
                            onPressed: onFollowToggle,
                            height: 30,
                          ),
                          const SizedBox(width: 10),
                          _roundedIconButton(
                            Icons.chat_bubble_outline,
                            width: 40,
                            height: 35,
                            onPressed: onChatPressed,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing),

              SizedBox(height: spacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        if (isBusinessOwner) {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const CustomerOrderPage(),
                          //   ),
                          // );
                        } else {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const CartPage(),
                          //   ),
                          // );
                        }
                      },
                      child: profileOrderContainer(
                        title: isBusinessOwner ? "Customer Order" : "Cart",
                        subtitle: isBusinessOwner
                            ? "Manage Orders"
                            : "Shopping Cart",
                        icon: PhosphorIcons.shoppingCartSimple(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        if (isBusinessOwner) {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const MyShopPage(),
                          //   ),
                          // );
                        } else {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const ShoppingPage(),
                          //   ),
                          // );
                        }
                      },
                      child: profileOrderContainer(
                        icon: PhosphorIcons.storefront(),
                        title: isBusinessOwner ? "Visit Shop" : "Shopping",
                        subtitle: isBusinessOwner
                            ? "Check My Shop"
                            : "Creative Inspiration",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _followButton(
    BuildContext context, {
    required bool isFollowing,
    VoidCallback? onPressed,
    required double height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isFollowing
            ? const Color.fromARGB(40, 255, 255, 255)
            : AppColors.kDefault,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: TextStyle(color: isFollowing ? kWhite : Colors.white),
        ),
      ),
    );
  }

  Widget _roundedButton(String text, context, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(24, 255, 255, 255),
        border: Border.all(color: kWhite),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/edit_profile");
        },
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _roundedIconButton(
    IconData icon, {
    required double width,
    required double height,
    VoidCallback? onPressed,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color.fromARGB(24, 255, 255, 255),
        border: Border.all(color: kWhite),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextButton(
        onPressed: onPressed ?? () {},
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _statColumn(
    String value,
    String label, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontFamily: "Regular",
            ),
          ),
        ],
      ),
    );
  }
}
