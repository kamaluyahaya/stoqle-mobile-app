import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:like_button/like_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stoqle/core/utils/constants.dart' show ApiConstants;
import 'package:stoqle/features/auth/state/comment_notifier.dart';

import '../../../../component/colors/color.dart';

class ProductContainer extends StatelessWidget {
  final String id;
  final String name;
  final String img; // can be full url OR filename OR empty
  final String likes;
  final int post_id;
  final int user_id;
  final onTap;
  final String post_title;
  final String user_img; // can be full url OR filename OR empty
  final Function(int postId, bool isFavorited) updateLikeCount;

  const ProductContainer({
    required this.id,
    required this.name,
    required this.img,
    required this.post_title,
    required this.likes,
    required this.user_img,
    required this.post_id,
    required this.user_id,
    required this.updateLikeCount,
    Key? key,
    this.onTap,
  }) : super(key: key);

  bool _isVideo(String filePath) {
    final lower = filePath.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm');
  }

  String _resolveImageUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    // already absolute
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
      return trimmed;

    // sometimes backend returns "localhost:4000/..." or "127.0.0.1:4000/..."
    final hostPortPattern = RegExp(
      r'^[0-9a-z\.-]+:\d+\/.*$',
      caseSensitive: false,
    );
    if (hostPortPattern.hasMatch(trimmed)) {
      return 'http://$trimmed';
    }

    // server relative or filename -> join with serverBaseUrl
    final server = ApiConstants.serverBaseUrl.replaceFirst(RegExp(r'\/+$'), '');
    if (trimmed.startsWith('/')) {
      return '$server$trimmed';
    }
    // assuming image is stored under /public/social/images/ when a filename was provided
    return '$server/public/social/images/$trimmed';
  }

  String _resolveUserImageUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
      return trimmed;
    final server = ApiConstants.serverBaseUrl.replaceFirst(RegExp(r'\/+$'), '');
    if (trimmed.startsWith('/')) return '$server$trimmed';
    return '$server/public/profile/$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPostUrl = _resolveImageUrl(img);
    final resolvedUserUrl = _resolveUserImageUrl(user_img);

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image / video area
            GestureDetector(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                ),
                child: _isVideo(resolvedPostUrl)
                    ? Container(
                        color: Colors.black,
                        height: 200,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 48,
                          color: kWhite20,
                        ),
                      )
                    : (resolvedPostUrl.isEmpty
                          ? Container(
                              height: 200,
                              color: kWhite20,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 48,
                              ),
                            )
                          : ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 180,
                                maxHeight: 250,
                              ),
                              child: Image.network(
                                resolvedPostUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: kWhite20,
                                    // child: const Center(
                                    //   child: CircularProgressIndicator(strokeWidth: 2),
                                    // ),
                                  );
                                },
                              ),
                            )),
              ),
            ),

            // title + user row
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post_title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Author info
                      Flexible(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: resolvedUserUrl.isNotEmpty
                                  ? NetworkImage(resolvedUserUrl)
                                  : null,
                              child: resolvedUserUrl.isEmpty
                                  ? Icon(
                                      PhosphorIcons.cat(),
                                      size: 16,
                                      color: Colors.orange,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            // Wrap name in Flexible to truncate
                            Flexible(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Likes using LikeButton
                      Consumer(
                        builder: (context, ref, _) {
                          final state = ref.watch(
                            commentsNotifierProvider(post_id),
                          );
                          final notifier = ref.read(
                            commentsNotifierProvider(post_id).notifier,
                          );

                          return LikeButton(
                            size: 26,
                            isLiked: state.userHasLiked,
                            likeCount: state.postTotalLike,
                            circleColor: const CircleColor(
                              start: Color(0xffff5722),
                              end: Color(0xfff44336),
                            ),
                            bubblesColor: const BubblesColor(
                              dotPrimaryColor: Color(0xfff44336),
                              dotSecondaryColor: Color(0xff2196f3),
                            ),
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey[700],
                                size: 26,
                              );
                            },
                            countBuilder:
                                (int? count, bool isLiked, String text) {
                                  return Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isLiked
                                          ? Colors.red
                                          : Colors.grey[700],
                                    ),
                                  );
                                },
                            onTap: (isLiked) async {
                              final oldLiked = state.userHasLiked;
                              final oldCount = state.postTotalLike;

                              final toggled = !oldLiked;

                              // Optimistic update
                              notifier.state = notifier.state.copyWith(
                                userHasLiked: toggled,
                                postTotalLike: toggled
                                    ? oldCount + 1
                                    : oldCount - 1,
                              );

                              try {
                                await notifier.likePost(
                                  post_id,
                                ); // toggle backend
                                return toggled;
                              } catch (e) {
                                // rollback on error
                                notifier.state = notifier.state.copyWith(
                                  userHasLiked: oldLiked,
                                  postTotalLike: oldCount,
                                );
                                return oldLiked;
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class VideoPlayerWidget extends StatefulWidget {
//   final String url;

//   const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
//     with AutomaticKeepAliveClientMixin {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideo;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo = _initializeVideoController();
//   }

//   Future<void> _initializeVideoController() async {
//     // final cacheManager = MyVideoCacheManager();
//     // final file = await cacheManager.getSingleFile(widget.url);

//     // _controller = VideoPlayerController.file(file)
//     //   ..initialize().then((_) {
//     //     setState(() {});
//     //   }).catchError((error) {
//     //     // Handle initialization error
//     //     print("Video initialization error: $error");
//     //   });

//     // Listen for errors
//     _controller.addListener(() {
//       if (_controller.value.hasError) {
//         print("Video player error: ${_controller.value.errorDescription}");
//       }
//     });
//   }

//   // @override
//   // void dispose() {
//   //   _controller.dispose();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // Necessary to call to keep alive functionality

//     return FutureBuilder<void>(
//       future: _initializeVideo,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error loading video'));
//         } else {
//           return Container(
//             height: 260.0,
//             width: double.infinity,
//             color: AppColors.background2,
//             child: _controller.value.isInitialized
//                 ? AspectRatio(
//                     aspectRatio: _controller.value.aspectRatio,
//                     child: Stack(
//                       children: [
//                         VideoPlayer(_controller),
//                         Align(
//                           alignment: AlignmentDirectional.topEnd,
//                           child: Opacity(
//                             opacity: 1.0,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Container(
//                                 height: 20,
//                                 width: 20,
//                                 padding: EdgeInsets.symmetric(
//                                   vertical: 5,
//                                   horizontal: 5,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(40),
//                                   color: Color.fromARGB(136, 18, 6, 6),
//                                 ),
//                                 child: Icon(
//                                   PhosphorIconsFill.play,
//                                   color: Colors.white,
//                                   size: 10,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Center(child: Container()),
//           );
//         }
//       },
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }
