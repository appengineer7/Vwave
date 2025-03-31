// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String?,
      numericUid: json['numeric_uid'] as String?,
      authType: json['auth_type'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      allowConversations: json['allow_conversations'] as String,
      allowSearchVisibility: json['allow_search_visibility'] as bool,
      storyPrivacyOption: json['story_privacy'] as String?,
      devices:
          (json['devices'] as List<dynamic>?)?.map((e) => e as String).toList(),
      msgId:
          (json['msgId'] as List<dynamic>?)?.map((e) => e as String).toList(),
      picture: json['picture'] as String?,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      referralCode: json['referral_code'] as String?,
      facebookLink: json['facebook_link'] as String?,
      twitterLink: json['twitter_link'] as String?,
      instagramLink: json['instagram_link'] as String?,
      tiktokLink: json['tiktok_link'] as String?,
      location: json['location'] as String?,
      userRoleType: json['user_role_type'] as String?,
      userType: json['user_type'] as String?,
      timestamp: json['timestamp'],
      locationDetails: json['location_details'],
      documents: json['documents'],
      blocked: json['blocked'] as bool,
      verified: json['verified'] as bool,
      accountSetup: json['account_setup'] as bool,
      deviceFingerprint: json['device_fingerprint'] as String?,
      createdDate: json['created_date'] as String?,
      modifiedDate: json['modified_date'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'numeric_uid': instance.numericUid,
      'auth_type': instance.authType,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'allow_conversations': instance.allowConversations,
      'allow_search_visibility': instance.allowSearchVisibility,
      'story_privacy': instance.storyPrivacyOption,
      'devices': instance.devices,
      'msgId': instance.msgId,
      'picture': instance.picture,
      'email': instance.email,
      'bio': instance.bio,
      'referral_code': instance.referralCode,
      'facebook_link': instance.facebookLink,
      'twitter_link': instance.twitterLink,
      'instagram_link': instance.instagramLink,
      'tiktok_link': instance.tiktokLink,
      'location': instance.location,
      'user_role_type': instance.userRoleType,
      'user_type': instance.userType,
      'timestamp': instance.timestamp,
      'location_details': instance.locationDetails,
      'documents': instance.documents,
      'blocked': instance.blocked,
      'verified': instance.verified,
      'account_setup': instance.accountSetup,
      'device_fingerprint': instance.deviceFingerprint,
      'created_date': instance.createdDate,
      'modified_date': instance.modifiedDate,
    };
