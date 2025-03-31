// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClubImpl _$$ClubImplFromJson(Map<String, dynamic> json) => _$ClubImpl(
      id: json['id'] as String?,
      userUid: json['user_uid'] as String,
      clubName: json['club_name'] as String,
      openingDays: json['opening_days'] as String,
      openingTimes: json['opening_times'] as String,
      phoneNumber: json['phone_number'],
      link: json['link'] as String,
      description: json['description'] as String,
      country: json['country'] as String,
      state: json['state'] as String,
      totalReviews: json['total_reviews'] as int,
      totalRating: json['total_rating'],
      ratingCount: json['rating_count'] as int,
      ratingCountObject: json['rating_count_object'],
      gallery: json['gallery'] as List<dynamic>,
      recentReviews: json['recent_reviews'] as List<dynamic>,
      coverImages: json['cover_images'] as List<dynamic>,
      msgId: json['msgId'] as List<dynamic>?,
      email: json['email'] as String,
      location: json['location'],
      timestamp: json['timestamp'],
      locationDetails: json['location_details'],
      verified: json['verified'] as bool,
      createdDate: json['created_date'] as String?,
      modifiedDate: json['modified_date'] as String?,
    );

Map<String, dynamic> _$$ClubImplToJson(_$ClubImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_uid': instance.userUid,
      'club_name': instance.clubName,
      'opening_days': instance.openingDays,
      'opening_times': instance.openingTimes,
      'phone_number': instance.phoneNumber,
      'link': instance.link,
      'description': instance.description,
      'country': instance.country,
      'state': instance.state,
      'total_reviews': instance.totalReviews,
      'total_rating': instance.totalRating,
      'rating_count': instance.ratingCount,
      'rating_count_object': instance.ratingCountObject,
      'gallery': instance.gallery,
      'recent_reviews': instance.recentReviews,
      'cover_images': instance.coverImages,
      'msgId': instance.msgId,
      'email': instance.email,
      'location': instance.location,
      'timestamp': instance.timestamp,
      'location_details': instance.locationDetails,
      'verified': instance.verified,
      'created_date': instance.createdDate,
      'modified_date': instance.modifiedDate,
    };
