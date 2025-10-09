// lib/features/social/models/comment_model.dart
import 'dart:convert';

class Comment {
  final int commentId;
  final int postId;
  final int userId;
  final String commentContent;
  final DateTime commentAt;
  final bool isAuthor;
  final bool isFirstComment;
  final String authorName;
  final String authorPic; // empty string when not present
  final int likesCount;
  final int followersCount;
  final int postsCount;
  final bool likedByUser;
  final bool authorLiked;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.commentContent,
    required this.commentAt,
    required this.isAuthor,
    required this.isFirstComment,
    required this.authorName,
    required this.authorPic,
    required this.likesCount,
    required this.followersCount,
    required this.postsCount,
    required this.likedByUser,
    required this.authorLiked,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // helper to parse int-like values safely
    int parseInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    bool parseBoolFromIntOrBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is int) return v == 1;
      final s = v.toString().toLowerCase();
      return s == '1' || s == 'true';
    }

    final commentAtRaw = json['comment_at']?.toString() ?? '';
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(commentAtRaw);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return Comment(
      commentId: parseInt(json['comment_id']),
      postId: parseInt(json['post_id']),
      userId: parseInt(json['user_id']),
      commentContent: json['comment_content']?.toString() ?? '',
      commentAt: parsedDate,
      isAuthor: parseBoolFromIntOrBool(json['is_author']),
      isFirstComment: parseBoolFromIntOrBool(json['is_first_comment']),
      authorName: json['author_name']?.toString() ?? '',
      authorPic: json['author_pic']?.toString() ?? '',
      likesCount: parseInt(json['likes_count']),
      followersCount: parseInt(json['followers_count']),
      postsCount: parseInt(json['posts_count']),
      likedByUser: parseBoolFromIntOrBool(json['liked_by_user']),
      authorLiked: parseBoolFromIntOrBool(json['author_liked']),
    );
  }

  Map<String, dynamic> toJson() => {
    'comment_id': commentId,
    'post_id': postId,
    'user_id': userId,
    'comment_content': commentContent,
    'comment_at': commentAt.toIso8601String(),
    'is_author': isAuthor ? 1 : 0,
    'is_first_comment': isFirstComment ? 1 : 0,
    'author_name': authorName,
    'author_pic': authorPic,
    'likes_count': likesCount,
    'followers_count': followersCount,
    'posts_count': postsCount,
    'liked_by_user': likedByUser,
    'author_liked': authorLiked,
  };

  Comment copyWith({
    int? commentId,
    int? postId,
    int? userId,
    String? commentContent,
    DateTime? commentAt,
    String? authorName,
    String? authorPic,
    int? likesCount,
    bool? authorLiked,
    int? followersCount,
    int? postsCount,
    bool? likedByUser,
    bool? isAuthor,
    bool? isFirstComment,
  }) {
    return Comment(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      commentContent: commentContent ?? this.commentContent,
      commentAt: commentAt ?? this.commentAt,
      authorName: authorName ?? this.authorName,
      authorPic: authorPic ?? this.authorPic,
      likesCount: likesCount ?? this.likesCount,
      authorLiked: authorLiked ?? this.authorLiked,
      followersCount: followersCount ?? this.followersCount,
      postsCount: postsCount ?? this.postsCount,
      likedByUser: likedByUser ?? this.likedByUser,
      isAuthor: isAuthor ?? this.isAuthor,
      isFirstComment: isFirstComment ?? this.isFirstComment,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
