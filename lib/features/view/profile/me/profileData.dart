// me.dart (replace your existing file)
import 'dart:async';
import 'dart:math' as math;
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:stoqle/core/widget/constant.dart';
import 'package:stoqle/features/auth/state/profile_notifier.dart';
import 'package:stoqle/features/view/profile/other/other.dart';
import 'package:toast/toast.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../../component/colors/color.dart';
import '../../../auth/models/suggestion_param.dart';
import '../../../auth/provider/follow_provider.dart';
import '../../../auth/provider/suggestion_provider.dart';
import '../../../auth/state/suggestion_notifier.dart';
import '../follow/follow.dart';

// ---------- DelayedSlideIn (shows child after a delay, hides on close) ----------
class DelayedSlideIn extends StatefulWidget {
  final Widget Function(VoidCallback hide) builder;
  final Duration delay;
  final Duration duration;

  const DelayedSlideIn({
    super.key,
    required this.builder,
    this.delay = const Duration(seconds: 3),
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  State<DelayedSlideIn> createState() => _DelayedSlideInState();
}

class _DelayedSlideInState extends State<DelayedSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Timer? _timer;
  bool _removed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    // start hidden (value = 0). After delay, animate in.
    _timer = Timer(widget.delay, () {
      if (!mounted) return;
      _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> hide() async {
    // animate out and then remove from layout
    if (!_removed && mounted) {
      await _ctrl.reverse();
      if (!mounted) return;
      setState(() {
        _removed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_removed) return const SizedBox.shrink();

    // We'll combine SizeTransition (so it won't occupy space when hidden),
    // SlideTransition (for a slight slide) and FadeTransition (for opacity).
    final slideTween = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    );
    final slideAnim = _ctrl
        .drive(CurveTween(curve: Curves.easeOut))
        .drive(slideTween);
    final fadeAnim = _ctrl.drive(CurveTween(curve: Curves.easeOut));

    return SizeTransition(
      sizeFactor: _ctrl, // 0 -> 1 will collapse/expand vertically
      axis: Axis.vertical,
      axisAlignment: -1.0,
      child: SlideTransition(
        position: slideAnim,
        child: FadeTransition(opacity: fadeAnim, child: widget.builder(hide)),
      ),
    );
  }
}

// ---------- ProfileData (Adaptive header content) ----------
class ProfileData extends StatelessWidget {
  final String user_name,
      userProfileUrl,
      user_id,
      bio,
      following,
      followers,
      likes;
  final bool isBusinessOwner;

  const ProfileData({
    super.key,
    required this.user_name,
    required this.user_id,
    required this.bio,
    required this.following,
    required this.followers,
    required this.likes,
    required this.userProfileUrl,
    required this.isBusinessOwner,
  });

  static const SuggestionParams _suggestionParams = SuggestionParams(
    limit: 8,
    offset: 0,
    q: '',
  );

  Future<void> _pickAndCropProfile(BuildContext context) async {
    try {
      // 1️⃣ Pick an image
      final List<AssetEntity>? assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          requestType: RequestType.image,
          maxAssets: 1,
          specialItemPosition: SpecialItemPosition.none,
        ),
      );
      if (assets == null || assets.isEmpty) return;

      final file = await assets.first.file;
      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load the selected image.')),
        );
        return;
      }

      // 2️⃣ Compress image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 1080,
        minHeight: 1080,
        quality: 85,
      );
      if (compressedBytes == null || compressedBytes.isEmpty) return;

      // 3️⃣ Crop
      final cropController = CropController();
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Crop(
                      controller: cropController,
                      image: compressedBytes,
                      withCircleUi: true,
                      baseColor: Colors.black,
                      maskColor: Colors.black.withOpacity(0.7),
                      onCropped: (croppedData) async {
                        // Close crop page first
                        if (Navigator.of(context).canPop())
                          Navigator.of(context).pop();

                        // Show loader on parent context
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              Center(child: CustomCircularProgressIndicator()),
                        );

                        try {
                          final container = ProviderScope.containerOf(
                            context,
                            listen: false,
                          );
                          final notifier = container.read(
                            profileNotifierProvider.notifier,
                          );

                          final success = await notifier.uploadProfilePicture(
                            croppedData,
                            filename: 'profile.jpg',
                          );

                          // Close loader
                          if (Navigator.of(context).canPop())
                            Navigator.of(context).pop();

                          // Optionally, go back one more screen if needed:
                          if (success && Navigator.of(context).canPop())
                            Navigator.of(context).pop();

                          toastNotify(
                            success
                                ? 'Done ✅!'
                                : 'Upload failed, please try again.',
                          );
                        } catch (e) {
                          if (Navigator.of(context).canPop())
                            Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Upload error: $e')),
                          );
                        }
                      },
                    ),
                  ),

                  // Bottom buttons
                  Positioned(
                    bottom: 20,
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
                          child: const Text("Cancel"),
                        ),

                        // ✅ Show loader immediately when Complete is tapped
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kDefault,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            // Show loader
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => Center(
                                child: CustomCircularProgressIndicator(),
                              ),
                            );

                            // Trigger crop
                            cropController.crop();
                          },
                          child: const Text("Complete"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e, st) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      debugPrint('Error in _pickAndCropProfile: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: ${e.runtimeType}')),
      );
    }
  }

  void _openImageViewer(BuildContext context, String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      // ✅ If no image, directly open picker
      await _pickAndCropProfile(context);
      return;
    }

    // ✅ Else show fullscreen viewer
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kDefault,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context); // close viewer first
                        await _pickAndCropProfile(
                          context,
                        ); // go to picker+cropper
                      },
                      child: Text(
                        "Change Image",
                        style: TextStyle(color: kWhite),
                      ),
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
    ToastContext().init(context);
    // Use LayoutBuilder to adapt sizes when space is limited
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.4;

        final avatarRadius = math.min(35.0, math.max(22.0, maxH * 0.12));
        final spacing = math.max(6.0, maxH * 0.02);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              // Navigator.of(context).pushNamed("/edit_profile");
            },
            child: Column(
              // mainAxisSize.min so it doesn't try to expand beyond parent
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
                      // Avatar with overlay
                      GestureDetector(
                        onTap: () {
                          // if (userProfileUrl.isNotEmpty) {
                          _openImageViewer(context, userProfileUrl);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(0.5),
                                child: CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundColor: Colors.grey.shade200,
                                  child: ClipOval(
                                    child: userProfileUrl.isNotEmpty
                                        ? FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/images/favio.png',
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
                            ),

                            // Overlay camera if empty
                            if (userProfileUrl.isEmpty)
                              Container(
                                width: avatarRadius * 2.3,
                                height: avatarRadius * 2.3,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kWhite, width: 0.5),
                                ),
                                child: Icon(
                                  PhosphorIcons.camera(),
                                  size: avatarRadius,
                                  color: kWhite10,
                                ),
                              ),

                            // Plus icon → always open picker
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _pickAndCropProfile(context),
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
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Info - allow this side to shrink using Expanded
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

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _roundedButton('Edit Profile', context, height: 35),
                          const SizedBox(width: 10),
                          _roundedIconButton(
                            Icons.settings,
                            width: 50,
                            height: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: spacing),

                // --- Suggestions card that appears after delay ---
                DelayedSlideIn(
                  delay: const Duration(seconds: 3),
                  duration: const Duration(milliseconds: 380),
                  builder: (hide) {
                    return Consumer(
                      builder: (context, ref, _) {
                        // watch provider for these params
                        final suggestionsState = ref.watch(
                          suggestionNotifierProvider(_suggestionParams),
                        );
                        final loadingSet = ref.watch(followLoadingProvider);

                        return ProfileOrderContainer(
                          title: "You may be interested in",
                          subtitle: suggestionsState.when(
                            data: (users) {
                              if (users.isEmpty) {
                                return const Text(
                                  'No suggestions yet.',
                                  style: TextStyle(color: Colors.white70),
                                );
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: users.map((u) {
                                    final isLoading = loadingSet.contains(
                                      u.userId,
                                    );

                                    return Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => OtherProfile(
                                                    otherUserId: "${u.userId}",
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: Colors.white,
                                                  child: u.displayPic.isNotEmpty
                                                      ? ClipOval(
                                                          child: FadeInImage.assetNetwork(
                                                            placeholder:
                                                                'assets/images/favio.png',
                                                            image: u.displayPic,
                                                            fit: BoxFit.cover,
                                                            width:
                                                                avatarRadius *
                                                                2,
                                                            height:
                                                                avatarRadius *
                                                                2,
                                                          ),
                                                        )
                                                      : Icon(
                                                          PhosphorIcons.cat(),
                                                          size:
                                                              avatarRadius *
                                                              1.0,
                                                          color: Colors.orange,
                                                        ),
                                                ),

                                                const SizedBox(height: 10),
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    u.displayName,
                                                    style: TextStyle(
                                                      color: kWhite10,
                                                      fontFamily: "bold",
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    "@Stoqle_ID 00${u.userId}",
                                                    style: TextStyle(
                                                      color: kWhite10,
                                                      fontSize: 8,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 28,
                                            child: ElevatedButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () async {
                                                      // toggle loading state for the specific userId
                                                      ref
                                                          .read(
                                                            followLoadingProvider
                                                                .notifier,
                                                          )
                                                          .update((s) {
                                                            final copy =
                                                                Set<int>.from(
                                                                  s,
                                                                );
                                                            copy.add(u.userId);
                                                            return copy;
                                                          });

                                                      try {
                                                        // call notifier on the same params instance
                                                        final success = await ref
                                                            .read(
                                                              suggestionNotifierProvider(
                                                                _suggestionParams,
                                                              ).notifier,
                                                            )
                                                            .followUser(
                                                              u.userId,
                                                            );

                                                        // optional: small feedback
                                                        if (success) {
                                                          toastNotify(
                                                            "Followed",
                                                          );
                                                        } else {
                                                          toastNotify(
                                                            "Followed",
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
                                                        ref
                                                            .read(
                                                              followLoadingProvider
                                                                  .notifier,
                                                            )
                                                            .update((s) {
                                                              final copy =
                                                                  Set<int>.from(
                                                                    s,
                                                                  );
                                                              copy.remove(
                                                                u.userId,
                                                              );
                                                              return copy;
                                                            });
                                                      }
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.kDefault,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                              ),
                                              child: isLoading
                                                  ? SizedBox(
                                                      width: 14,
                                                      height: 14,
                                                      child:
                                                          CustomCircularProgressIndicator(),
                                                    )
                                                  : const Text(
                                                      "Follow",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                            loading: () => SizedBox(
                              height: 64,
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CustomCircularProgressIndicator(),
                                ),
                              ),
                            ),
                            error: (err, st) => SizedBox(
                              height: 64,
                              child: Center(
                                child: Text(
                                  'Failed to load',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ),
                          icon: PhosphorIcons.shoppingCartSimple(),
                          onClose: hide,
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: spacing),
                // three small cards - make them flexible and non-overflowing
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
                          title: isBusinessOwner ? "My Shop" : "Shopping",
                          subtitle: isBusinessOwner
                              ? "Manage Your Shop"
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
          ),
        );
      },
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
        onPressed: () {},
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

class ProfileOrderContainer extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final Widget? subtitle; // 👈 allow widget instead of string
  final VoidCallback? onClose;

  const ProfileOrderContainer({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(14, 255, 255, 255),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: "Bold",
                            ),
                          ),
                          if (icon != null)
                            InkWell(
                              onTap: onClose,
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: kWhite10,
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    if (subtitle != null) subtitle!, // 👈 directly place widget
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small widget reused for the three action boxes.
class profileOrderContainer extends StatelessWidget {
  final icon, title, subtitle;
  const profileOrderContainer({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // removed Expanded here — parent decides available width (we use Flexible there)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color.fromARGB(17, 255, 255, 255),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: "Bold",
                  ),
                ),
                Text(
                  "$subtitle",
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textColor2,
                    fontFamily: "Regular",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
