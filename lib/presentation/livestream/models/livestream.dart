import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'livestream.freezed.dart';
part 'livestream.g.dart';

@freezed
abstract class Livestream implements _$Livestream {
  const Livestream._();
  const factory Livestream({
    String? id,
    @JsonKey(name: 'user_uid') required String userUid,
    @JsonKey(name: 'channel_name') required String channelName,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'club_name') required String clubName,
    @JsonKey(name: 'link') required String link,
    required int duration,
    required int views,
    @JsonKey(name: 'live_views') int? liveViews,
    @JsonKey(name: 'has_ended') required bool hasEnded,
    dynamic timestamp,
    @JsonKey(name: 'location_details') dynamic locationDetails,
    dynamic images,
    @JsonKey(name: 'created_date') String? createdDate,
    @JsonKey(name: 'modified_date') String? modifiedDate,
  }) = _Livestream;

  factory Livestream.fromJson(Map<String, Object?> json) => _$LivestreamFromJson(json);

  factory Livestream.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;
    return Livestream.fromJson(data).copyWith(id: documentSnapshot.id);
  }

  Map<String, dynamic> toDocument() => toJson();
}
