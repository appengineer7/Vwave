import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'story.freezed.dart';
part 'story.g.dart';

@freezed
abstract class StoryFeed implements _$StoryFeed {
  const StoryFeed._();
  const factory StoryFeed({
    String? id,
    @JsonKey(name: 'user_uid') required String userUid,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'preview_title') required Map<String, dynamic> previewTitle,
    @JsonKey(name: 'preview_image') required String previewImage,
    @JsonKey(name: 'files') required List<Map<String, dynamic>> files,
    @JsonKey(name: 'views_count') Map<String, dynamic>? viewsCount,
    @JsonKey(name: 'other_details') required Map<String, dynamic> otherDetails,
    @JsonKey(name: 'time_zone') required String timeZone,
    dynamic timestamp,
    @JsonKey(name: 'story_privacy') String? storyPrivacy,
    @JsonKey(name: 'allowed_uid') List<String>? allowedUid,
    @JsonKey(name: 'location_details') dynamic locationDetails,
    @JsonKey(name: 'created_date') String? createdDate,
    @JsonKey(name: 'modified_date') String? modifiedDate,
  }) = _StoryFeed;

  factory StoryFeed.fromJson(Map<String, Object?> json) => _$StoryFeedFromJson(json);

  factory StoryFeed.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;
    return StoryFeed.fromJson(data).copyWith(id: documentSnapshot.id);
  }

  Map<String, dynamic> toDocument() => toJson();
}
