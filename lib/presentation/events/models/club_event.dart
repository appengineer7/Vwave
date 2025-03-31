import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_event.freezed.dart';
part 'club_event.g.dart';

@freezed
abstract class ClubEvent implements _$ClubEvent {
  const ClubEvent._();
  const factory ClubEvent({
    String? id,
    @JsonKey(name: 'user_uid') required String userUid,
    @JsonKey(name: 'club_id') required String clubId,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'club_name') required String clubName,
    @JsonKey(name: 'link') required String link,
    @JsonKey(name: 'created_timestamp') dynamic createdTimestamp,
    @JsonKey(name: 'event_date_timestamp') dynamic eventDateTimestamp,
    @JsonKey(name: 'event_date') required String eventDate,
    @JsonKey(name: 'time_zone') required String timeZone,
    @JsonKey(name: 'location_details') dynamic locationDetails,
    dynamic images,
    @JsonKey(name: 'created_date') String? createdDate,
    @JsonKey(name: 'modified_date') String? modifiedDate,
  }) = _ClubEvent;

  factory ClubEvent.fromJson(Map<String, Object?> json) => _$ClubEventFromJson(json);

  factory ClubEvent.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;
    return ClubEvent.fromJson(data).copyWith(id: documentSnapshot.id);
  }

  Map<String, dynamic> toDocument() => toJson();
}
