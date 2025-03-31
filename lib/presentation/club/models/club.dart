import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club.freezed.dart';
part 'club.g.dart';

@freezed
abstract class Club implements _$Club {
  const Club._();
  const factory Club({
    String? id,
    @JsonKey(name: 'user_uid') required String userUid,
    @JsonKey(name: 'club_name') required String clubName,
    @JsonKey(name: 'opening_days') required String openingDays,
    @JsonKey(name: 'opening_times') required String openingTimes,
    @JsonKey(name: 'phone_number') required dynamic phoneNumber,
    @JsonKey(name: 'link') required String link,
    required String description,
    required String country,
    required String state,
    @JsonKey(name: 'total_reviews') required int totalReviews,
    @JsonKey(name: 'total_rating') required dynamic totalRating,
    @JsonKey(name: 'rating_count') required int ratingCount,
    @JsonKey(name: 'rating_count_object') required dynamic ratingCountObject,
    required List<dynamic> gallery,
    @JsonKey(name: 'recent_reviews') required List<dynamic> recentReviews,
    @JsonKey(name: 'cover_images') required List<dynamic> coverImages,
    List<dynamic>? msgId,
    required String email,
    required dynamic location,
    dynamic timestamp,
    @JsonKey(name: 'location_details') dynamic locationDetails,
    required bool verified,
    @JsonKey(name: 'created_date') String? createdDate,
    @JsonKey(name: 'modified_date') String? modifiedDate,
  }) = _Club;

  factory Club.fromJson(Map<String, Object?> json) => _$ClubFromJson(json);

  factory Club.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;
    return Club.fromJson(data).copyWith(id: documentSnapshot.id);
  }

  Map<String, dynamic> toDocument() => toJson();
}
