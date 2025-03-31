// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
      id: json['id'] as String,
      clubId: json['club_id'] as String,
      userUid: json['uid'] as String,
      image: json['image'] as String,
      name: json['name'] as String,
      rating: json['rating'],
      body: json['body'] as String,
      date: json['date'] as String,
      timestamp: json['timestamp'],
    );

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'club_id': instance.clubId,
      'uid': instance.userUid,
      'image': instance.image,
      'name': instance.name,
      'rating': instance.rating,
      'body': instance.body,
      'date': instance.date,
      'timestamp': instance.timestamp,
    };
