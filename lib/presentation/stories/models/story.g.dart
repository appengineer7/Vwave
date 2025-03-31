// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryFeedImpl _$$StoryFeedImplFromJson(Map<String, dynamic> json) =>
    _$StoryFeedImpl(
      id: json['id'] as String?,
      userUid: json['user_uid'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      previewTitle: json['preview_title'] as Map<String, dynamic>,
      previewImage: json['preview_image'] as String,
      files: (json['files'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      viewsCount: json['views_count'] as Map<String, dynamic>?,
      otherDetails: json['other_details'] as Map<String, dynamic>,
      timeZone: json['time_zone'] as String,
      timestamp: json['timestamp'],
      storyPrivacy: json['story_privacy'] as String?,
      allowedUid: (json['allowed_uid'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      locationDetails: json['location_details'],
      createdDate: json['created_date'] as String?,
      modifiedDate: json['modified_date'] as String?,
    );

Map<String, dynamic> _$$StoryFeedImplToJson(_$StoryFeedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_uid': instance.userUid,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'preview_title': instance.previewTitle,
      'preview_image': instance.previewImage,
      'files': instance.files,
      'views_count': instance.viewsCount,
      'other_details': instance.otherDetails,
      'time_zone': instance.timeZone,
      'timestamp': instance.timestamp,
      'story_privacy': instance.storyPrivacy,
      'allowed_uid': instance.allowedUid,
      'location_details': instance.locationDetails,
      'created_date': instance.createdDate,
      'modified_date': instance.modifiedDate,
    };
