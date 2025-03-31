// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClubEventImpl _$$ClubEventImplFromJson(Map<String, dynamic> json) =>
    _$ClubEventImpl(
      id: json['id'] as String?,
      userUid: json['user_uid'] as String,
      clubId: json['club_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      clubName: json['club_name'] as String,
      link: json['link'] as String,
      createdTimestamp: json['created_timestamp'],
      eventDateTimestamp: json['event_date_timestamp'],
      eventDate: json['event_date'] as String,
      timeZone: json['time_zone'] as String,
      locationDetails: json['location_details'],
      images: json['images'],
      createdDate: json['created_date'] as String?,
      modifiedDate: json['modified_date'] as String?,
    );

Map<String, dynamic> _$$ClubEventImplToJson(_$ClubEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_uid': instance.userUid,
      'club_id': instance.clubId,
      'title': instance.title,
      'description': instance.description,
      'club_name': instance.clubName,
      'link': instance.link,
      'created_timestamp': instance.createdTimestamp,
      'event_date_timestamp': instance.eventDateTimestamp,
      'event_date': instance.eventDate,
      'time_zone': instance.timeZone,
      'location_details': instance.locationDetails,
      'images': instance.images,
      'created_date': instance.createdDate,
      'modified_date': instance.modifiedDate,
    };
