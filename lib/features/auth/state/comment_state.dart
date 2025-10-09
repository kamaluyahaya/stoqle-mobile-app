import 'package:stoqle/features/auth/models/comment_model.dart';

class CommentsState {
  final bool isLoading;
  final String? error;
  final List<Comment> comments;
  final int count;
  final int page;
  final bool hasMore;
  final int postTotalLike;
  final bool userHasLiked; // 👈 new

  CommentsState({
    this.isLoading = false,
    this.error,
    List<Comment>? comments,
    this.count = 0,
    this.page = 1,
    this.hasMore = true,
    this.postTotalLike = 0,
    this.userHasLiked = false, // 👈 default
  }) : comments = comments ?? [];

  CommentsState copyWith({
    bool? isLoading,
    String? error,
    List<Comment>? comments,
    int? count,
    int? page,
    bool? hasMore,
    int? postTotalLike,
    bool? userHasLiked, // 👈 add
  }) {
    return CommentsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      comments: comments ?? this.comments,
      count: count ?? this.count,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      postTotalLike: postTotalLike ?? this.postTotalLike,
      userHasLiked: userHasLiked ?? this.userHasLiked, // 👈 preserve/override
    );
  }
}
