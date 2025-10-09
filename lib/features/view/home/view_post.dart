import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:like_button/like_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:stoqle/core/widget/constant.dart';
import 'package:stoqle/features/auth/models/comment_model.dart';
import 'package:stoqle/features/auth/models/socialPost.dart'; // your model
// import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:stoqle/features/auth/models/suggestion_param.dart';
import 'package:toast/toast.dart';

import '../../auth/state/comment_notifier.dart';

class _CommentBottomSheet extends StatefulWidget {
  const _CommentBottomSheet({Key? key}) : super(key: key);

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet>
    with WidgetsBindingObserver {
  late FocusNode _focusNode;
  final TextEditingController _controller = TextEditingController();

  // keyboard tracking & debounce
  double _lastBottom = 0.0;
  Timer? _debounceTimer;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = FocusNode();

    // wait one frame so MediaQuery is available, then request focus and record inset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _lastBottom = MediaQuery.of(context).viewInsets.bottom;
      // request focus so keyboard shows
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();

    // unfocus safely before disposing the node to avoid _dependents.isEmpty asserts
    try {
      _focusNode.unfocus();
    } catch (_) {}
    _focusNode.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // defer to next frame so MediaQuery is up to date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bottom = MediaQuery.of(context).viewInsets.bottom;

      // if nothing changed, ignore
      if (bottom == _lastBottom) return;

      // case: keyboard hidden (was visible, now 0)
      if (_lastBottom > 0 && bottom == 0 && !_isPopping) {
        // debounce a bit to ensure keyboard is actually hidden and avoid re-entrancy
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 150), () {
          if (!mounted) return;

          final current = MediaQuery.of(context).viewInsets.bottom;
          if (current == 0 && !_isPopping) {
            _isPopping = true;
            final route = ModalRoute.of(context);
            // only pop if this sheet is still the current route
            if (route != null && route.isCurrent) {
              Navigator.of(context).maybePop();
            } else {
              // fallback: safe scheduled pop
              Future.microtask(() {
                if (mounted) Navigator.of(context).maybePop();
              });
            }
          }
        });
      }

      // update last bottom
      _lastBottom = bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // backgroundColor:
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color.fromARGB(255, 17, 17, 19) : kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  // color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // TextField as textarea
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.kDarkMode : kWhiteSmoke,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Say something...',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {}); // updates Send button state
                      },
                    ),
                  ),

                  const SizedBox(height: 8), // vertical spacing
                  // Send Button
                  Container(
                    height: 36,
                    // width: 20,
                    decoration: BoxDecoration(
                      color: AppColors.kDefault,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: _controller.text.trim().isEmpty
                          ? null
                          : () {
                              final text = _controller.text.trim();
                              if (text.isNotEmpty) {
                                Navigator.of(context).pop(text);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kDefault,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Send', style: TextStyle(color: kWhite)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostViewPage extends StatefulWidget {
  final SocialPost post;
  const PostViewPage({Key? key, required this.post}) : super(key: key);

  @override
  State<PostViewPage> createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  static const SuggestionParams _suggestionParams = SuggestionParams(
    limit: 8,
    offset: 0,
    q: '',
  );
  late PageController _pageController;
  int _pageIndex = 0;
  bool _isLiked = false;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _isLiked = widget.post.likedByMe ?? false;
    _isFollowing = widget.post.isFollowing ?? false;

    final post = widget.post;
    final images = (post.imageUrls != null && post.imageUrls!.isNotEmpty)
        ? post.imageUrls
        : (post.coverImage != null && post.coverImage!.isNotEmpty
              ? [post.coverImage!]
              : []);

    if (images.isNotEmpty) {
      _resolveAspect(images.first); // ✅ only the first image decides aspect
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatCommentDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays == 1) return 'Yesterday ${_formatTime(dt)}';
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[dt.month]} ${dt.day}, ${dt.year} ${_formatTime(dt)}';
  }

  String _formatPostDate(dynamic createdAt) {
    // handle DateTime or ISO string; fallback to now
    DateTime dt;
    if (createdAt is DateTime)
      dt = createdAt;
    else {
      try {
        dt = DateTime.parse(createdAt.toString());
      } catch (_) {
        dt = DateTime.now();
      }
    }
    final now = DateTime.now();
    final sameDay =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final time = _formatTime(dt);
    if (sameDay) return 'Today $time at Kano';
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[dt.month]} ${dt.day}, ${dt.year} $time at Kaduna';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute$ampm';
  }

  Future<void> _openCommentInput(WidgetRef ref) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CommentBottomSheet(),
    );

    // defensive: normalize result
    final text = result?.trim() ?? '';
    if (text.isEmpty) {
      // Nothing to send — show friendly message instead of calling backend
      if (result != null) {
        // user attempted to send whitespace / empty string
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment cannot be empty')),
        );
      }
      return;
    }

    final postId = widget.post.id ?? 0;
    final notifier = ref.read(commentsNotifierProvider(postId).notifier);

    try {
      final created = await notifier.createComment(text);
      toastNotify("Good ✅");
    } catch (e, st) {
      debugPrint('createComment failed: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 6 : 6,
      height: active ? 6 : 6,
      decoration: BoxDecoration(
        color: active ? AppColors.kDefault : AppColors.lightBackground,
        shape: BoxShape.circle,
      ),
    );
  }

  double? _currentAspect;

  void _resolveAspect(String url) {
    final image = Image.network(url);
    image.image
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((info, _) {
            final aspect = info.image.width / info.image.height;
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _currentAspect = aspect);
              });
            }
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final post = widget.post;
    final images = (post.imageUrls != null && post.imageUrls!.isNotEmpty)
        ? post.imageUrls!
        : (post.coverImage != null && post.coverImage!.isNotEmpty
              ? [post.coverImage!]
              : []);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.only(left: 0),
              child: const Icon(Icons.arrow_back_ios_new_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  (post.authorPic != null && post.authorPic!.isNotEmpty)
                  ? NetworkImage(post.authorPic!)
                  : null,
              child: (post.authorPic == null || post.authorPic!.isEmpty)
                  ? Icon(PhosphorIcons.cat(), size: 20, color: Colors.orange)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                post.authorName ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon((PhosphorIcons.shareFat())),
              onPressed: () {
                // TODO: share logic
              },
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Carousel + dots + description + header
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // images carousel with auto height
                  SizedBox(
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: _currentAspect ?? 1,
                      child: Stack(
                        children: [
                          if (images.isEmpty)
                            const Center(child: Icon(Icons.image, size: 48))
                          else
                            PageView.builder(
                              controller: _pageController,
                              // physics: const AlwaysScrollableScrollPhysics(),
                              // physics: const NeverScrollableScrollPhysics(),
                              itemCount: images.length,
                              onPageChanged: (i) {
                                setState(() => _pageIndex = i);
                                _resolveAspect(
                                  images[i],
                                ); // recalc aspect when new image is visible
                              },
                              itemBuilder: (context, index) {
                                final url = images[index];
                                return InteractiveViewer(
                                  minScale: 1,
                                  maxScale: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => PhotoViewGalleryPage(
                                            images: images.cast<String>(),
                                            initialIndex: index,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: url,
                                      child: CachedNetworkImage(
                                        imageUrl: url,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
                                        placeholder: (context, _) => Center(
                                          child:
                                              CustomCircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, _, __) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 42,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                          // page count
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_pageIndex + 1}/${images.length}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => _buildDot(i == _pageIndex),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.text ?? '',
                          style: const TextStyle(fontSize: 15, height: 1.35),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${_formatPostDate(post.createdAt)}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: kWhite50),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final postId = widget.post.id ?? 0;
                        final state = ref.watch(
                          commentsNotifierProvider(postId),
                        );

                        final int displayCount =
                            (state.count > 0 || !state.isLoading)
                            ? state.count
                            : (post.commentsCount ?? 0);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Comments',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$displayCount',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  Consumer(
                    builder: (context, ref, _) {
                      final postId = widget.post.id ?? 0;
                      final state = ref.watch(commentsNotifierProvider(postId));
                      final notifier = ref.read(
                        commentsNotifierProvider(postId).notifier,
                      );

                      return Container(
                        // decoration: const BoxDecoration(
                        //   border: Border(
                        //     top: BorderSide(
                        //       color: AppColors.textColor3,
                        //       width: 0.1,
                        //     ),
                        //   ),
                        // ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // Add comment input
                            CircleAvatar(
                              radius: 15,
                              backgroundImage:
                                  (post.authorPic != null &&
                                      post.authorPic!.isNotEmpty)
                                  ? NetworkImage(post.authorPic!)
                                  : null,
                              child:
                                  (post.authorPic == null ||
                                      post.authorPic!.isEmpty)
                                  ? Icon(
                                      PhosphorIcons.cat(),
                                      size: 20,
                                      color: Colors.orange,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _openCommentInput(ref),
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? kWhite50 : kWhiteSmoke,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Say something...',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            LikeButton(
                                              size: 30,
                                              isLiked: state
                                                  .userHasLiked, // ✅ always from state
                                              likeCount: state.postTotalLike,
                                              circleColor: const CircleColor(
                                                start: Color(0xffff5722),
                                                end: Color(0xfff44336),
                                              ),
                                              bubblesColor: const BubblesColor(
                                                dotPrimaryColor: Color(
                                                  0xfff44336,
                                                ),
                                                dotSecondaryColor: Color(
                                                  0xff2196f3,
                                                ),
                                              ),
                                              likeBuilder: (bool isLiked) {
                                                return Icon(
                                                  isLiked
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isLiked
                                                      ? Colors.red
                                                      : Colors.grey[700],
                                                  size: 20,
                                                );
                                              },
                                              countBuilder:
                                                  (
                                                    int? count,
                                                    bool isLiked,
                                                    String text,
                                                  ) {
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
                                                final oldLiked =
                                                    notifier.state.userHasLiked;
                                                final oldCount = notifier
                                                    .state
                                                    .postTotalLike;

                                                final toggled = !oldLiked;

                                                // Optimistic update
                                                notifier.state = notifier.state
                                                    .copyWith(
                                                      userHasLiked: toggled,
                                                      postTotalLike: toggled
                                                          ? oldCount + 1
                                                          : oldCount - 1,
                                                    );

                                                try {
                                                  await notifier.likePost(
                                                    postId,
                                                  ); // backend confirms
                                                  return toggled;
                                                } catch (e) {
                                                  // rollback
                                                  notifier.state = notifier
                                                      .state
                                                      .copyWith(
                                                        userHasLiked: oldLiked,
                                                        postTotalLike: oldCount,
                                                      );
                                                  return oldLiked;
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 18),
                                            Icon(
                                              PhosphorIcons.note(),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '${state.count > 0 || !state.isLoading ? state.count : (widget.post.commentsCount ?? 0)}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 💬 Comment button with count
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // Comments list
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final postId = widget.post.id ?? 0;
                  final state = ref.watch(commentsNotifierProvider(postId));
                  // final notifier = ref.read(
                  //   commentsNotifierProvider(postId).notifier,
                  // );
                  final notifier = ref.read(
                    commentsNotifierProvider(postId).notifier,
                  );

                  if (state.isLoading && state.comments.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CustomCircularProgressIndicator()),
                    );
                  }

                  if ((state.comments.isEmpty) && (state.isLoading == false)) {
                    return _buildEmptyComments();
                  }

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        state.comments.length +
                        (state.hasMore
                            ? 1
                            : (state.comments.isNotEmpty ? 1 : 0)),
                    separatorBuilder: (_, __) => const SizedBox.shrink(),
                    itemBuilder: (context, index) {
                      // Case 1: Normal comment row
                      if (index < state.comments.length) {
                        final c = state.comments[index];
                        return _buildCommentTile(c, isDark, notifier);
                      }

                      // Case 2: Loading more (infinite scroll pagination)
                      if (state.hasMore) {
                        notifier.loadComments(); // fire-and-forget
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CustomCircularProgressIndicator(),
                          ),
                        );
                      }

                      // Case 3: End marker
                      if (state.comments.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              '— THE END —',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                    // 👉 Last item ("THE END")
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final postId = widget.post.id ?? 0;
          final state = ref.watch(commentsNotifierProvider(postId));
          final notifier = ref.read(commentsNotifierProvider(postId).notifier);

          return Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.textColor3, width: 0.1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Add comment input
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openCommentInput(ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? kWhite50 : kWhiteSmoke,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_note, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Comment',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Likes + Comments row
                Row(
                  children: [
                    LikeButton(
                      size: 30,
                      isLiked: state.userHasLiked, // ✅ always from state
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
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey[700],
                          size: 26,
                        );
                      },
                      countBuilder: (int? count, bool isLiked, String text) {
                        return Text(
                          text,
                          style: TextStyle(
                            fontSize: 13,
                            color: isLiked ? Colors.red : Colors.grey[700],
                          ),
                        );
                      },
                      onTap: (isLiked) async {
                        final oldLiked = notifier.state.userHasLiked;
                        final oldCount = notifier.state.postTotalLike;

                        final toggled = !oldLiked;

                        // Optimistic update
                        notifier.state = notifier.state.copyWith(
                          userHasLiked: toggled,
                          postTotalLike: toggled ? oldCount + 1 : oldCount - 1,
                        );

                        try {
                          await notifier.likePost(postId); // backend confirms
                          return toggled;
                        } catch (e) {
                          // rollback
                          notifier.state = notifier.state.copyWith(
                            userHasLiked: oldLiked,
                            postTotalLike: oldCount,
                          );
                          return oldLiked;
                        }
                      },
                    ),

                    const SizedBox(width: 18),

                    // 💬 Comment button with count
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () => _openCommentInput(ref),
                    ),
                    Text(
                      '${state.count > 0 || !state.isLoading ? state.count : (widget.post.commentsCount ?? 0)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentTile(Comment c, bool isDark, CommentsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: (c.authorPic != null && c.authorPic!.isNotEmpty)
                ? NetworkImage(c.authorPic!)
                : null,
            child: (c.authorPic == null || c.authorPic!.isEmpty)
                ? Text(_initials(c.authorName), style: const TextStyle())
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        "${c.authorName}",
                        style: TextStyle(
                          // replace color variable with your theme variable
                          // style: TextStyle(color: kWhite20, fontSize: 16),
                          fontSize: 16,
                          color: kWhite20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (c.isAuthor)
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(24, 153, 68, 81),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            "Author",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.kDefault,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  c.commentContent,
                  style: const TextStyle(
                    // color: kWhiteSmoke,
                    height: 1.28,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${_formatCommentDate(c.commentAt)} Kaduna",
                  style: TextStyle(color: kWhite20, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (c.isFirstComment)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? kWhite40 : kWhite10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            "First comment",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    SizedBox(width: 10),
                    if (c.authorLiked)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? kWhite40 : kWhite10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            "Author liked",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          LikeButton(
            size: 30,
            isLiked: c.likedByUser, // comes from your Comment model
            circleColor: const CircleColor(
              start: Color.fromARGB(255, 255, 72, 0),
              end: Color.fromARGB(255, 204, 0, 0),
            ),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color.fromARGB(255, 229, 51, 51),
              dotSecondaryColor: Color(0xff0099cc),
            ),
            likeBuilder: (bool isLiked) {
              return Icon(
                isLiked ? PhosphorIconsFill.heart : PhosphorIcons.heart(),
                color: isLiked ? Colors.red : Theme.of(context).iconTheme.color,
                size: 26,
              );
            },
            likeCount: c.likesCount ?? 0,
            countBuilder: (int? count, bool isLiked, String text) {
              return Text(
                count == 0 ? '' : text,
                style: TextStyle(
                  color: isLiked
                      ? Colors.red
                      : Theme.of(context).iconTheme.color,
                  fontSize: 12,
                ),
              );
            },
            onTap: (bool isCurrentlyLiked) async {
              final toggledLike = !isCurrentlyLiked; // optimistic UI

              try {
                // ✅ Just call toggle API — backend decides like/unlike
                await notifier.likeComment(c.commentId);

                return toggledLike; // update UI
              } catch (_) {
                return isCurrentlyLiked; // rollback if API fails
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Prefer an asset: add file at assets/images/no-comments.png and register in pubspec.yaml
          SizedBox(
            height: 50,
            child: Image.asset(
              'assets/images/message-icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                // fallback to network placeholder icon
                return Icon(
                  Icons.chat_bubble_outline,
                  size: 96,
                  color: Colors.grey[400],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No comments yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to comment and start the conversation.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class PhotoViewGalleryPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const PhotoViewGalleryPage({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<PhotoViewGalleryPage> createState() => _PhotoViewGalleryPageState();
}

class _PhotoViewGalleryPageState extends State<PhotoViewGalleryPage> {
  late PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: kBlack,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${_index + 1}/${widget.images.length}'),
      ),
      body: Center(
        child: PhotoViewGallery.builder(
          pageController: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _index = i),
          builder: (context, i) {
            final url = widget.images[i];
            return PhotoViewGalleryPageOptions.customChild(
              child: Hero(
                tag: url,
                child: CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (c, _) =>
                      Center(child: CustomCircularProgressIndicator()),
                  errorWidget: (c, _, __) => const Icon(Icons.broken_image),
                ),
              ),
            );
          },
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          scrollPhysics: const BouncingScrollPhysics(),
        ),
      ),
    );
  }
}
