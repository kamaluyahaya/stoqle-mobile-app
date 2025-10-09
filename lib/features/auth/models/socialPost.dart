// Rewritten NotesService, PostImage, SocialPost, and NotesNotifier
// - NotesService now has a shared _parsePosts helper to reduce duplication
// - NotesNotifier accepts a fetch function and an optional `filterToMyPosts` flag
// - Two providers are exposed: notesNotifierProvider (my notes) and notesAllNotifierProvider (all notes)

import 'package:stoqle/core/utils/constants.dart';

// Models
class PostImage {
  final int postImageId;
  final int postId;
  final String imageUrl;
  final int position;
  final bool isCover;
  final DateTime? createdAt;

  PostImage({
    required this.postImageId,
    required this.postId,
    required this.imageUrl,
    required this.position,
    required this.isCover,
    this.createdAt,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    String raw = (json['image_url'] ?? '') as String;

    String normalize(String url) {
      url = url.trim();
      if (url.isEmpty) return '';

      final u = Uri.tryParse(url);

      if (u != null && u.hasScheme) {
        final hostLower = u.host.toLowerCase();
        if (hostLower == 'localhost' || hostLower == '127.0.0.1') {
          final base = Uri.parse(ApiConstants.serverBaseUrl);
          final replaced = u.replace(
            host: base.host,
            port: u.hasPort ? u.port : (base.hasPort ? base.port : null),
          );
          return replaced.toString();
        }
        return url;
      }

      if (url.startsWith('//')) return 'http:$url';
      final hostPortPattern = RegExp(
        r'^[a-z0-9\.-]+:\d+(/.*)?\$',
        caseSensitive: false,
      );
      if (hostPortPattern.hasMatch(url)) return 'http://$url';
      if (url.startsWith('/')) {
        final trimmedBase = ApiConstants.serverBaseUrl.endsWith('/')
            ? ApiConstants.serverBaseUrl.substring(
                0,
                ApiConstants.serverBaseUrl.length - 1,
              )
            : ApiConstants.serverBaseUrl;
        return '$trimmedBase$url';
      }
      final sep = ApiConstants.serverBaseUrl.endsWith('/') ? '' : '/';
      return '${ApiConstants.serverBaseUrl}$sep$url';
    }

    final normalized = normalize(raw);

    return PostImage(
      postImageId: (json['post_image_id'] ?? 0) as int,
      postId: (json['post_id'] ?? 0) as int,
      imageUrl: normalized,
      position: (json['position'] ?? 0) as int,
      isCover: (json['is_cover'] ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class SocialPost {
  final int id;
  final int userId;
  final String text;
  final String? quoteAuthor;
  final String? postDate;
  final Map<String, dynamic>? config;
  final String privacy;
  final String coverType;
  final int? coverId;
  final DateTime createdAt;
  final List<PostImage> images;
  final int likesCount;
  final int commentsCount;
  final bool likedByMe;
  final bool isFollowing;
  final bool isMine;
  final String authorName;
  final String authorPic;
  final String? coverImage;

  SocialPost({
    required this.id,
    required this.userId,
    required this.text,
    this.quoteAuthor,
    this.postDate,
    this.config,
    required this.privacy,
    required this.coverType,
    this.coverId,
    required this.createdAt,
    required this.images,
    required this.likesCount,
    required this.commentsCount,
    required this.likedByMe,
    required this.isFollowing,
    required this.isMine,
    required this.authorName,
    required this.authorPic,
    this.coverImage,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    final rawImages = (json['images'] as List<dynamic>?) ?? const [];
    final images = rawImages
        .map<PostImage>((i) => PostImage.fromJson(i as Map<String, dynamic>))
        .toList();

    final int? coverId = json['cover_id'] is int
        ? json['cover_id'] as int
        : (json['cover_id'] != null
              ? int.tryParse('${json['cover_id']}')
              : null);

    final cfg = json['config'];
    final bool configIsEmpty = cfg == null || (cfg is Map && cfg.isEmpty);

    String? pickCover() {
      if (coverId != null) {
        final match = images.firstWhere(
          (img) => img.postImageId == coverId,
          orElse: () => PostImage(
            postImageId: 0,
            postId: 0,
            imageUrl: '',
            position: 0,
            isCover: false,
          ),
        );
        if (match.postImageId != 0 && match.imageUrl.isNotEmpty)
          return match.imageUrl;
      }

      final isCover = images.firstWhere(
        (img) => img.isCover,
        orElse: () => PostImage(
          postImageId: 0,
          postId: 0,
          imageUrl: '',
          position: 0,
          isCover: false,
        ),
      );
      if (isCover.postImageId != 0 && isCover.imageUrl.isNotEmpty)
        return isCover.imageUrl;

      if (configIsEmpty && images.isNotEmpty) {
        final first = images.firstWhere(
          (img) => img.imageUrl.isNotEmpty,
          orElse: () => PostImage(
            postImageId: 0,
            postId: 0,
            imageUrl: '',
            position: 0,
            isCover: false,
          ),
        );
        if (first.postImageId != 0 && first.imageUrl.isNotEmpty)
          return first.imageUrl;
      }
      return null;
    }

    String authorName = (json['author_name'] ?? '').toString();
    String authorPic = (json['author_pic'] ?? '').toString();

    if (json['business_name'] != null) {
      authorName = json['business_name'];
      authorPic = (json['logo'] != null && (json['logo'] as String).isNotEmpty)
          ? json['logo']
          : authorPic;
    }

    return SocialPost(
      id: json['social_post_id'] as int,
      userId: json['user_id'] as int,
      text: (json['text'] ?? '') as String,
      quoteAuthor: json['quote_author'] as String?,
      postDate: json['post_date'] as String?,
      config: cfg is Map ? cfg as Map<String, dynamic> : null,
      privacy: (json['privacy'] ?? 'public') as String,
      coverType: (json['cover_type'] ?? 'note') as String,
      coverId: coverId,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      images: images,
      likesCount: (json['likes_count'] ?? 0) as int,
      commentsCount: (json['comments_count'] ?? 0) as int,
      likedByMe: (json['liked_by_me'] ?? false) as bool,
      isFollowing: (json['is_following'] ?? false) as bool,
      isMine: (json['is_mine'] ?? false) as bool,
      authorName: authorName,
      authorPic: authorPic,
      coverImage: pickCover(),
    );
  }

  List<String> get imageUrls =>
      images.map((i) => i.imageUrl).where((u) => u.isNotEmpty).toList();
}
