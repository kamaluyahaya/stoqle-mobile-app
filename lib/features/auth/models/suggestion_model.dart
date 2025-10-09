class SuggestionUser {
  final int userId;
  final String fullName;
  final String profilePic;
  final String? bio;
  final String? job;
  final String? location;
  final bool isBusinessOwner;
  final BusinessInfo? business; // <-- add business

  SuggestionUser({
    required this.userId,
    required this.fullName,
    required this.profilePic,
    this.bio,
    this.job,
    this.location,
    this.isBusinessOwner = false,
    this.business,
  });

  factory SuggestionUser.fromJson(Map<String, dynamic> json) {
    return SuggestionUser(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse('${json['user_id']}'),
      fullName: (json['full_name'] ?? '') as String,
      profilePic: (json['profile_pic'] ?? '') as String,
      bio: json['bio'] as String?,
      job: json['job'] as String?,
      location: json['location'] as String?,
      isBusinessOwner: json['is_business_owner'] ?? false,
      business: json['business'] != null
          ? BusinessInfo.fromJson(json['business'])
          : null,
    );
  }

  /// This is what you’ll actually display in UI
  String get displayName {
    if (isBusinessOwner && business != null) {
      return business!.businessName;
    }
    return fullName;
  }

  String get displayPic {
    if (isBusinessOwner && business != null && business!.logo.isNotEmpty) {
      return business!.logo;
    }
    return profilePic;
  }
}

class BusinessInfo {
  final int businessId;
  final String businessName;
  final String logo;
  final String slug;
  final String category;

  BusinessInfo({
    required this.businessId,
    required this.businessName,
    required this.logo,
    required this.slug,
    required this.category,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      businessId: json['business_id'] is int
          ? json['business_id']
          : int.parse('${json['business_id']}'),
      businessName: json['business_name'] ?? '',
      logo: json['logo'] ?? '',
      slug: json['slug'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
