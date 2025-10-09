// profile_model.dart
import 'package:flutter/foundation.dart';

class Business {
  final int id;
  final String name;
  final String? slug;
  final String? category;
  final String? email;
  final String? phone;
  final String? logo;
  final String? address;

  Business({
    required this.id,
    required this.name,
    this.slug,
    this.category,
    this.email,
    this.phone,
    this.logo,
    this.address,
  });

  factory Business.fromJson(Map<String, dynamic> j) {
    return Business(
      id: j['business_id'] is int
          ? j['business_id']
          : int.tryParse('${j['business_id']}') ?? 0,
      name: j['business_name'] ?? '',
      slug: j['business_slug'],
      category: j['business_category'],
      email: j['email'],
      phone: j['phone'],
      logo: j['logo'],
      address: j['business_address'],
    );
  }
}

class Profile {
  final int userId;
  final String fullName;
  final String? bio;
  final String? bgPhotoUrl;
  final String? profilePic;
  final bool isBusinessOwner;
  final Business? business;
  final bool isFollowing;
  final int followers;
  final int following;
  final int posts;

  Profile({
    required this.userId,
    required this.fullName,
    this.bio,
    this.bgPhotoUrl,
    this.profilePic,
    required this.isBusinessOwner,
    this.business,
    required this.isFollowing,
    required this.followers,
    required this.following,
    required this.posts,
  });

  String get displayName {
    if (isBusinessOwner && business != null && business!.name.isNotEmpty) {
      return business!.name;
    }
    return fullName;
  }

  factory Profile.fromJson(Map<String, dynamic> j) {
    // Support both passing `data` root or full response
    final userData = (j['user'] ?? j) as Map<String, dynamic>;
    final businessJson = j['business'] ?? j['data']?['business'];
    final stats = j['stats'] ?? j['data']?['stats'] ?? {};

    return Profile(
      userId: userData['user_id'] is int
          ? userData['user_id']
          : int.tryParse('${userData['user_id']}') ?? 0,
      fullName: userData['full_name'] ?? '',
      bio: userData['bio'],
      bgPhotoUrl: userData['bg_photo_url'],
      profilePic: userData['profile_pic'],
      isBusinessOwner:
          j['is_business_owner'] == true ||
          j['data']?['is_business_owner'] == true,
      business: businessJson != null ? Business.fromJson(businessJson) : null,
      isFollowing: stats['is_following'] == true,
      followers: stats['followers'] is int
          ? stats['followers']
          : int.tryParse('${stats['followers'] ?? 0}') ?? 0,
      following: stats['following'] is int
          ? stats['following']
          : int.tryParse('${stats['following'] ?? 0}') ?? 0,
      posts: stats['posts'] is int
          ? stats['posts']
          : int.tryParse('${stats['posts'] ?? 0}') ?? 0,
    );
  }
}
