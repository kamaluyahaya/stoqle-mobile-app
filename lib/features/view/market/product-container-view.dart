import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stoqle/core/utils/constants.dart' show ApiConstants;

import '../../../component/colors/color.dart';

class ProductContainerView extends StatelessWidget {
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

  const ProductContainerView({
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
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Author info
                      Flexible(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 7,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: resolvedUserUrl.isNotEmpty
                                  ? NetworkImage(resolvedUserUrl)
                                  : null,
                              child: resolvedUserUrl.isEmpty
                                  ? Icon(
                                      PhosphorIcons.cat(),
                                      size: 16,
                                      color: const Color.fromARGB(
                                        255,
                                        221,
                                        134,
                                        4,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            // Wrap name in Flexible to truncate
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: Color(0xFFFFC371),
                                  fontFamily: "Bold",
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Likes using LikeButton
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color(
                                0xFF9C6B2F,
                              ), // brown/golden background
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Central Market",
                              style: TextStyle(
                                color: Colors.white, // white text
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: " "), // space between badges
                        // Promo Badge (teal like Friendly Market)
                        WidgetSpan(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(
                                255,
                                15,
                                107,
                                98,
                              ), // teal background
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Eid Promo",
                              style: TextStyle(
                                color: Colors.white, // white text
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(
                          text: " ",
                        ), // space between tag and post title
                        TextSpan(
                          text: post_title,
                          style: const TextStyle(
                            fontFamily: "Regular",
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "New buyer ₦ 30% Discount Off",
                    style: TextStyle(
                      fontFamily: "",
                      fontSize: 12,
                      color: kWhite20,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "₦",
                        style: TextStyle(
                          // color: kWhite10,
                          fontSize: 10,
                          fontFamily: "",
                        ),
                      ),
                      Text(
                        "1,256,400",
                        style: TextStyle(
                          // color: kWhite10,
                          fontSize: 16,
                          fontFamily: "Bold",
                        ),
                      ),
                      const Spacer(), // pushes next text to the right
                      Text(
                        "4030 sold",
                        style: TextStyle(
                          color: kWhite20,
                          fontSize: 10,
                          fontFamily: "",
                        ),
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
