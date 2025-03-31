import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User implements _$User {
  const User._();
  const factory User({
    String? id,
    @JsonKey(name: 'numeric_uid') String? numericUid,
    @JsonKey(name: 'auth_type') String? authType,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'allow_conversations') required String allowConversations,
    @JsonKey(name: 'allow_search_visibility') required bool allowSearchVisibility,
    @JsonKey(name: 'story_privacy') String? storyPrivacyOption,
    List<String>? devices,
    List<String>? msgId,
    String? picture,
    required String email,
    String? bio,
    @JsonKey(name: 'referral_code') String? referralCode,
    @JsonKey(name: 'facebook_link') String? facebookLink,
    @JsonKey(name: 'twitter_link') String? twitterLink,
    @JsonKey(name: 'instagram_link') String? instagramLink,
    @JsonKey(name: 'tiktok_link') String? tiktokLink,
    String? location,
    @JsonKey(name: 'user_role_type') String? userRoleType,
    @JsonKey(name: 'user_type') String? userType,
    dynamic timestamp,
    @JsonKey(name: 'location_details') dynamic locationDetails,
    @JsonKey(name: 'documents') dynamic documents,
    required bool blocked,
    required bool verified,
    @JsonKey(name: 'account_setup') required bool accountSetup,
    @JsonKey(name: 'device_fingerprint') String? deviceFingerprint,
    @JsonKey(name: 'created_date') String? createdDate,
    @JsonKey(name: 'modified_date') String? modifiedDate,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);

  factory User.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;
    return User.fromJson(data).copyWith(id: documentSnapshot.id);
  }

  Map<String, dynamic> toDocument() => toJson();
}
