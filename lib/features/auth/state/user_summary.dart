// lib/models/user_summary.dart
class UserSummary {
  final int userId;
  final String fullName;
  final String? profilePic;
  final DateTime? followAt;
  final bool isFollowedByViewer;
  final bool isFollowingViewer;
  final int totalFollowers;
  final int totalPosts;

  UserSummary({
    required this.userId,
    required this.fullName,
    this.profilePic,
    this.followAt,
    this.isFollowedByViewer = false,
    this.isFollowingViewer = false,
    this.totalFollowers = 0,
    this.totalPosts = 0,
  });

  factory UserSummary.fromJson(Map<String, dynamic> j) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    return UserSummary(
      userId: j['user_id'] is int
          ? j['user_id']
          : int.tryParse('${j['user_id']}') ?? 0,
      fullName: j['full_name'] ?? '',
      profilePic: (j['profile_pic'] ?? '') == '' ? null : j['profile_pic'],
      followAt: j['follow_at'] != null
          ? DateTime.tryParse(j['follow_at'])
          : null,
      isFollowedByViewer: j['is_followed_by_viewer'] == true,
      isFollowingViewer: j['is_following_viewer'] == true,
      totalFollowers: parseInt(
        j['total_followers'] ??
            j['total_followers_count'] ??
            j['followersCount'] ??
            j['followers_count'],
      ),
      totalPosts: parseInt(
        j['total_posts'] ?? j['post_count'] ?? j['posts_count'],
      ),
    );
  }

  UserSummary copyWith({
    int? userId,
    String? fullName,
    String? profilePic,
    DateTime? followAt,
    bool? isFollowedByViewer,
    bool? isFollowingViewer,
    int? totalFollowers,
    int? totalPosts,
  }) {
    return UserSummary(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      profilePic: profilePic ?? this.profilePic,
      followAt: followAt ?? this.followAt,
      isFollowedByViewer: isFollowedByViewer ?? this.isFollowedByViewer,
      isFollowingViewer: isFollowingViewer ?? this.isFollowingViewer,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      totalPosts: totalPosts ?? this.totalPosts,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'full_name': fullName,
    'profile_pic': profilePic,
    'follow_at': followAt?.toIso8601String(),
    'is_followed_by_viewer': isFollowedByViewer,
    'is_following_viewer': isFollowingViewer,
    'total_followers': totalFollowers,
    'total_posts': totalPosts,
  };
}
