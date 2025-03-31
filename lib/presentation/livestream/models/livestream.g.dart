// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livestream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LivestreamImpl _$$LivestreamImplFromJson(Map<String, dynamic> json) =>
    _$LivestreamImpl(
      id: json['id'] as String?,
      userUid: json['user_uid'] as String,
      channelName: json['channel_name'] as String,
      title: json['title'] as String,
      clubName: json['club_name'] as String,
      link: json['link'] as String,
      duration: json['duration'] as int,
      views: json['views'] as int,
      liveViews: json['live_views'] as int?,
      hasEnded: json['has_ended'] as bool,
      timestamp: json['timestamp'],
      locationDetails: json['location_details'],
      images: json['images'],
      createdDate: json['created_date'] as String?,
      modifiedDate: json['modified_date'] as String?,
    );

Map<String, dynamic> _$$LivestreamImplToJson(_$LivestreamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_uid': instance.userUid,
      'channel_name': instance.channelName,
      'title': instance.title,
      'club_name': instance.clubName,
      'link': instance.link,
      'duration': instance.duration,
      'views': instance.views,
      'live_views': instance.liveViews,
      'has_ended': instance.hasEnded,
      'timestamp': instance.timestamp,
      'location_details': instance.locationDetails,
      'images': instance.images,
      'created_date': instance.createdDate,
      'modified_date': instance.modifiedDate,
    };
