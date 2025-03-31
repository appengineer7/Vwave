// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ClubEvent _$ClubEventFromJson(Map<String, dynamic> json) {
  return _ClubEvent.fromJson(json);
}

/// @nodoc
mixin _$ClubEvent {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_uid')
  String get userUid => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_id')
  String get clubId => throw _privateConstructorUsedError;
  @JsonKey(name: 'title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_name')
  String get clubName => throw _privateConstructorUsedError;
  @JsonKey(name: 'link')
  String get link => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_timestamp')
  dynamic get createdTimestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_date_timestamp')
  dynamic get eventDateTimestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_date')
  String get eventDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_zone')
  String get timeZone => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_details')
  dynamic get locationDetails => throw _privateConstructorUsedError;
  dynamic get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_date')
  String? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'modified_date')
  String? get modifiedDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClubEventCopyWith<ClubEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClubEventCopyWith<$Res> {
  factory $ClubEventCopyWith(ClubEvent value, $Res Function(ClubEvent) then) =
      _$ClubEventCopyWithImpl<$Res, ClubEvent>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_uid') String userUid,
      @JsonKey(name: 'club_id') String clubId,
      @JsonKey(name: 'title') String title,
      @JsonKey(name: 'description') String description,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'link') String link,
      @JsonKey(name: 'created_timestamp') dynamic createdTimestamp,
      @JsonKey(name: 'event_date_timestamp') dynamic eventDateTimestamp,
      @JsonKey(name: 'event_date') String eventDate,
      @JsonKey(name: 'time_zone') String timeZone,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      dynamic images,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class _$ClubEventCopyWithImpl<$Res, $Val extends ClubEvent>
    implements $ClubEventCopyWith<$Res> {
  _$ClubEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userUid = null,
    Object? clubId = null,
    Object? title = null,
    Object? description = null,
    Object? clubName = null,
    Object? link = null,
    Object? createdTimestamp = freezed,
    Object? eventDateTimestamp = freezed,
    Object? eventDate = null,
    Object? timeZone = null,
    Object? locationDetails = freezed,
    Object? images = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userUid: null == userUid
          ? _value.userUid
          : userUid // ignore: cast_nullable_to_non_nullable
              as String,
      clubId: null == clubId
          ? _value.clubId
          : clubId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      createdTimestamp: freezed == createdTimestamp
          ? _value.createdTimestamp
          : createdTimestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      eventDateTimestamp: freezed == eventDateTimestamp
          ? _value.eventDateTimestamp
          : eventDateTimestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as String,
      timeZone: null == timeZone
          ? _value.timeZone
          : timeZone // ignore: cast_nullable_to_non_nullable
              as String,
      locationDetails: freezed == locationDetails
          ? _value.locationDetails
          : locationDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as dynamic,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as String?,
      modifiedDate: freezed == modifiedDate
          ? _value.modifiedDate
          : modifiedDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClubEventImplCopyWith<$Res>
    implements $ClubEventCopyWith<$Res> {
  factory _$$ClubEventImplCopyWith(
          _$ClubEventImpl value, $Res Function(_$ClubEventImpl) then) =
      __$$ClubEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_uid') String userUid,
      @JsonKey(name: 'club_id') String clubId,
      @JsonKey(name: 'title') String title,
      @JsonKey(name: 'description') String description,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'link') String link,
      @JsonKey(name: 'created_timestamp') dynamic createdTimestamp,
      @JsonKey(name: 'event_date_timestamp') dynamic eventDateTimestamp,
      @JsonKey(name: 'event_date') String eventDate,
      @JsonKey(name: 'time_zone') String timeZone,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      dynamic images,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class __$$ClubEventImplCopyWithImpl<$Res>
    extends _$ClubEventCopyWithImpl<$Res, _$ClubEventImpl>
    implements _$$ClubEventImplCopyWith<$Res> {
  __$$ClubEventImplCopyWithImpl(
      _$ClubEventImpl _value, $Res Function(_$ClubEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userUid = null,
    Object? clubId = null,
    Object? title = null,
    Object? description = null,
    Object? clubName = null,
    Object? link = null,
    Object? createdTimestamp = freezed,
    Object? eventDateTimestamp = freezed,
    Object? eventDate = null,
    Object? timeZone = null,
    Object? locationDetails = freezed,
    Object? images = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
  }) {
    return _then(_$ClubEventImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userUid: null == userUid
          ? _value.userUid
          : userUid // ignore: cast_nullable_to_non_nullable
              as String,
      clubId: null == clubId
          ? _value.clubId
          : clubId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      createdTimestamp: freezed == createdTimestamp
          ? _value.createdTimestamp
          : createdTimestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      eventDateTimestamp: freezed == eventDateTimestamp
          ? _value.eventDateTimestamp
          : eventDateTimestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as String,
      timeZone: null == timeZone
          ? _value.timeZone
          : timeZone // ignore: cast_nullable_to_non_nullable
              as String,
      locationDetails: freezed == locationDetails
          ? _value.locationDetails
          : locationDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as dynamic,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as String?,
      modifiedDate: freezed == modifiedDate
          ? _value.modifiedDate
          : modifiedDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClubEventImpl extends _ClubEvent {
  const _$ClubEventImpl(
      {this.id,
      @JsonKey(name: 'user_uid') required this.userUid,
      @JsonKey(name: 'club_id') required this.clubId,
      @JsonKey(name: 'title') required this.title,
      @JsonKey(name: 'description') required this.description,
      @JsonKey(name: 'club_name') required this.clubName,
      @JsonKey(name: 'link') required this.link,
      @JsonKey(name: 'created_timestamp') this.createdTimestamp,
      @JsonKey(name: 'event_date_timestamp') this.eventDateTimestamp,
      @JsonKey(name: 'event_date') required this.eventDate,
      @JsonKey(name: 'time_zone') required this.timeZone,
      @JsonKey(name: 'location_details') this.locationDetails,
      this.images,
      @JsonKey(name: 'created_date') this.createdDate,
      @JsonKey(name: 'modified_date') this.modifiedDate})
      : super._();

  factory _$ClubEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClubEventImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'user_uid')
  final String userUid;
  @override
  @JsonKey(name: 'club_id')
  final String clubId;
  @override
  @JsonKey(name: 'title')
  final String title;
  @override
  @JsonKey(name: 'description')
  final String description;
  @override
  @JsonKey(name: 'club_name')
  final String clubName;
  @override
  @JsonKey(name: 'link')
  final String link;
  @override
  @JsonKey(name: 'created_timestamp')
  final dynamic createdTimestamp;
  @override
  @JsonKey(name: 'event_date_timestamp')
  final dynamic eventDateTimestamp;
  @override
  @JsonKey(name: 'event_date')
  final String eventDate;
  @override
  @JsonKey(name: 'time_zone')
  final String timeZone;
  @override
  @JsonKey(name: 'location_details')
  final dynamic locationDetails;
  @override
  final dynamic images;
  @override
  @JsonKey(name: 'created_date')
  final String? createdDate;
  @override
  @JsonKey(name: 'modified_date')
  final String? modifiedDate;

  @override
  String toString() {
    return 'ClubEvent(id: $id, userUid: $userUid, clubId: $clubId, title: $title, description: $description, clubName: $clubName, link: $link, createdTimestamp: $createdTimestamp, eventDateTimestamp: $eventDateTimestamp, eventDate: $eventDate, timeZone: $timeZone, locationDetails: $locationDetails, images: $images, createdDate: $createdDate, modifiedDate: $modifiedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClubEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userUid, userUid) || other.userUid == userUid) &&
            (identical(other.clubId, clubId) || other.clubId == clubId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName) &&
            (identical(other.link, link) || other.link == link) &&
            const DeepCollectionEquality()
                .equals(other.createdTimestamp, createdTimestamp) &&
            const DeepCollectionEquality()
                .equals(other.eventDateTimestamp, eventDateTimestamp) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.timeZone, timeZone) ||
                other.timeZone == timeZone) &&
            const DeepCollectionEquality()
                .equals(other.locationDetails, locationDetails) &&
            const DeepCollectionEquality().equals(other.images, images) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.modifiedDate, modifiedDate) ||
                other.modifiedDate == modifiedDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userUid,
      clubId,
      title,
      description,
      clubName,
      link,
      const DeepCollectionEquality().hash(createdTimestamp),
      const DeepCollectionEquality().hash(eventDateTimestamp),
      eventDate,
      timeZone,
      const DeepCollectionEquality().hash(locationDetails),
      const DeepCollectionEquality().hash(images),
      createdDate,
      modifiedDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClubEventImplCopyWith<_$ClubEventImpl> get copyWith =>
      __$$ClubEventImplCopyWithImpl<_$ClubEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClubEventImplToJson(
      this,
    );
  }
}

abstract class _ClubEvent extends ClubEvent {
  const factory _ClubEvent(
      {final String? id,
      @JsonKey(name: 'user_uid') required final String userUid,
      @JsonKey(name: 'club_id') required final String clubId,
      @JsonKey(name: 'title') required final String title,
      @JsonKey(name: 'description') required final String description,
      @JsonKey(name: 'club_name') required final String clubName,
      @JsonKey(name: 'link') required final String link,
      @JsonKey(name: 'created_timestamp') final dynamic createdTimestamp,
      @JsonKey(name: 'event_date_timestamp') final dynamic eventDateTimestamp,
      @JsonKey(name: 'event_date') required final String eventDate,
      @JsonKey(name: 'time_zone') required final String timeZone,
      @JsonKey(name: 'location_details') final dynamic locationDetails,
      final dynamic images,
      @JsonKey(name: 'created_date') final String? createdDate,
      @JsonKey(name: 'modified_date')
      final String? modifiedDate}) = _$ClubEventImpl;
  const _ClubEvent._() : super._();

  factory _ClubEvent.fromJson(Map<String, dynamic> json) =
      _$ClubEventImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'user_uid')
  String get userUid;
  @override
  @JsonKey(name: 'club_id')
  String get clubId;
  @override
  @JsonKey(name: 'title')
  String get title;
  @override
  @JsonKey(name: 'description')
  String get description;
  @override
  @JsonKey(name: 'club_name')
  String get clubName;
  @override
  @JsonKey(name: 'link')
  String get link;
  @override
  @JsonKey(name: 'created_timestamp')
  dynamic get createdTimestamp;
  @override
  @JsonKey(name: 'event_date_timestamp')
  dynamic get eventDateTimestamp;
  @override
  @JsonKey(name: 'event_date')
  String get eventDate;
  @override
  @JsonKey(name: 'time_zone')
  String get timeZone;
  @override
  @JsonKey(name: 'location_details')
  dynamic get locationDetails;
  @override
  dynamic get images;
  @override
  @JsonKey(name: 'created_date')
  String? get createdDate;
  @override
  @JsonKey(name: 'modified_date')
  String? get modifiedDate;
  @override
  @JsonKey(ignore: true)
  _$$ClubEventImplCopyWith<_$ClubEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
