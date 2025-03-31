import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@freezed
abstract class Review implements _$Review {
  const Review._();
  const factory Review({
    required String id,
    @JsonKey(name: 'club_id') required String clubId,
    @JsonKey(name: 'uid') required String userUid,
    required String image,
    required String name,
    required dynamic rating,
    required String body,
    required String date,
    required dynamic timestamp,
  }) = _Review;

  factory Review.fromJson(Map<String, Object?> json) => _$ReviewFromJson(json);

  factory Review.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;
    return Review.fromJson(data).copyWith(id: documentSnapshot.id);
  }

  Map<String, dynamic> toDocument() => toJson();
}
