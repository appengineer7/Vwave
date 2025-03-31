// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestream.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Livestream _$LivestreamFromJson(Map<String, dynamic> json) {
  return _Livestream.fromJson(json);
}

/// @nodoc
mixin _$Livestream {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_uid')
  String get userUid => throw _privateConstructorUsedError;
  @JsonKey(name: 'channel_name')
  String get channelName => throw _privateConstructorUsedError;
  @JsonKey(name: 'title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_name')
  String get clubName => throw _privateConstructorUsedError;
  @JsonKey(name: 'link')
  String get link => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  @JsonKey(name: 'live_views')
  int? get liveViews => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_ended')
  bool get hasEnded => throw _privateConstructorUsedError;
  dynamic get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_details')
  dynamic get locationDetails => throw _privateConstructorUsedError;
  dynamic get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_date')
  String? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'modified_date')
  String? get modifiedDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LivestreamCopyWith<Livestream> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LivestreamCopyWith<$Res> {
  factory $LivestreamCopyWith(
          Livestream value, $Res Function(Livestream) then) =
      _$LivestreamCopyWithImpl<$Res, Livestream>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_uid') String userUid,
      @JsonKey(name: 'channel_name') String channelName,
      @JsonKey(name: 'title') String title,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'link') String link,
      int duration,
      int views,
      @JsonKey(name: 'live_views') int? liveViews,
      @JsonKey(name: 'has_ended') bool hasEnded,
      dynamic timestamp,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      dynamic images,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class _$LivestreamCopyWithImpl<$Res, $Val extends Livestream>
    implements $LivestreamCopyWith<$Res> {
  _$LivestreamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userUid = null,
    Object? channelName = null,
    Object? title = null,
    Object? clubName = null,
    Object? link = null,
    Object? duration = null,
    Object? views = null,
    Object? liveViews = freezed,
    Object? hasEnded = null,
    Object? timestamp = freezed,
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
      channelName: null == channelName
          ? _value.channelName
          : channelName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      liveViews: freezed == liveViews
          ? _value.liveViews
          : liveViews // ignore: cast_nullable_to_non_nullable
              as int?,
      hasEnded: null == hasEnded
          ? _value.hasEnded
          : hasEnded // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
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
abstract class _$$LivestreamImplCopyWith<$Res>
    implements $LivestreamCopyWith<$Res> {
  factory _$$LivestreamImplCopyWith(
          _$LivestreamImpl value, $Res Function(_$LivestreamImpl) then) =
      __$$LivestreamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_uid') String userUid,
      @JsonKey(name: 'channel_name') String channelName,
      @JsonKey(name: 'title') String title,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'link') String link,
      int duration,
      int views,
      @JsonKey(name: 'live_views') int? liveViews,
      @JsonKey(name: 'has_ended') bool hasEnded,
      dynamic timestamp,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      dynamic images,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class __$$LivestreamImplCopyWithImpl<$Res>
    extends _$LivestreamCopyWithImpl<$Res, _$LivestreamImpl>
    implements _$$LivestreamImplCopyWith<$Res> {
  __$$LivestreamImplCopyWithImpl(
      _$LivestreamImpl _value, $Res Function(_$LivestreamImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userUid = null,
    Object? channelName = null,
    Object? title = null,
    Object? clubName = null,
    Object? link = null,
    Object? duration = null,
    Object? views = null,
    Object? liveViews = freezed,
    Object? hasEnded = null,
    Object? timestamp = freezed,
    Object? locationDetails = freezed,
    Object? images = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
  }) {
    return _then(_$LivestreamImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userUid: null == userUid
          ? _value.userUid
          : userUid // ignore: cast_nullable_to_non_nullable
              as String,
      channelName: null == channelName
          ? _value.channelName
          : channelName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      liveViews: freezed == liveViews
          ? _value.liveViews
          : liveViews // ignore: cast_nullable_to_non_nullable
              as int?,
      hasEnded: null == hasEnded
          ? _value.hasEnded
          : hasEnded // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
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
class _$LivestreamImpl extends _Livestream {
  const _$LivestreamImpl(
      {this.id,
      @JsonKey(name: 'user_uid') required this.userUid,
      @JsonKey(name: 'channel_name') required this.channelName,
      @JsonKey(name: 'title') required this.title,
      @JsonKey(name: 'club_name') required this.clubName,
      @JsonKey(name: 'link') required this.link,
      required this.duration,
      required this.views,
      @JsonKey(name: 'live_views') this.liveViews,
      @JsonKey(name: 'has_ended') required this.hasEnded,
      this.timestamp,
      @JsonKey(name: 'location_details') this.locationDetails,
      this.images,
      @JsonKey(name: 'created_date') this.createdDate,
      @JsonKey(name: 'modified_date') this.modifiedDate})
      : super._();

  factory _$LivestreamImpl.fromJson(Map<String, dynamic> json) =>
      _$$LivestreamImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'user_uid')
  final String userUid;
  @override
  @JsonKey(name: 'channel_name')
  final String channelName;
  @override
  @JsonKey(name: 'title')
  final String title;
  @override
  @JsonKey(name: 'club_name')
  final String clubName;
  @override
  @JsonKey(name: 'link')
  final String link;
  @override
  final int duration;
  @override
  final int views;
  @override
  @JsonKey(name: 'live_views')
  final int? liveViews;
  @override
  @JsonKey(name: 'has_ended')
  final bool hasEnded;
  @override
  final dynamic timestamp;
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
    return 'Livestream(id: $id, userUid: $userUid, channelName: $channelName, title: $title, clubName: $clubName, link: $link, duration: $duration, views: $views, liveViews: $liveViews, hasEnded: $hasEnded, timestamp: $timestamp, locationDetails: $locationDetails, images: $images, createdDate: $createdDate, modifiedDate: $modifiedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LivestreamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userUid, userUid) || other.userUid == userUid) &&
            (identical(other.channelName, channelName) ||
                other.channelName == channelName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.liveViews, liveViews) ||
                other.liveViews == liveViews) &&
            (identical(other.hasEnded, hasEnded) ||
                other.hasEnded == hasEnded) &&
            const DeepCollectionEquality().equals(other.timestamp, timestamp) &&
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
      channelName,
      title,
      clubName,
      link,
      duration,
      views,
      liveViews,
      hasEnded,
      const DeepCollectionEquality().hash(timestamp),
      const DeepCollectionEquality().hash(locationDetails),
      const DeepCollectionEquality().hash(images),
      createdDate,
      modifiedDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LivestreamImplCopyWith<_$LivestreamImpl> get copyWith =>
      __$$LivestreamImplCopyWithImpl<_$LivestreamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LivestreamImplToJson(
      this,
    );
  }
}

abstract class _Livestream extends Livestream {
  const factory _Livestream(
          {final String? id,
          @JsonKey(name: 'user_uid') required final String userUid,
          @JsonKey(name: 'channel_name') required final String channelName,
          @JsonKey(name: 'title') required final String title,
          @JsonKey(name: 'club_name') required final String clubName,
          @JsonKey(name: 'link') required final String link,
          required final int duration,
          required final int views,
          @JsonKey(name: 'live_views') final int? liveViews,
          @JsonKey(name: 'has_ended') required final bool hasEnded,
          final dynamic timestamp,
          @JsonKey(name: 'location_details') final dynamic locationDetails,
          final dynamic images,
          @JsonKey(name: 'created_date') final String? createdDate,
          @JsonKey(name: 'modified_date') final String? modifiedDate}) =
      _$LivestreamImpl;
  const _Livestream._() : super._();

  factory _Livestream.fromJson(Map<String, dynamic> json) =
      _$LivestreamImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'user_uid')
  String get userUid;
  @override
  @JsonKey(name: 'channel_name')
  String get channelName;
  @override
  @JsonKey(name: 'title')
  String get title;
  @override
  @JsonKey(name: 'club_name')
  String get clubName;
  @override
  @JsonKey(name: 'link')
  String get link;
  @override
  int get duration;
  @override
  int get views;
  @override
  @JsonKey(name: 'live_views')
  int? get liveViews;
  @override
  @JsonKey(name: 'has_ended')
  bool get hasEnded;
  @override
  dynamic get timestamp;
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
  _$$LivestreamImplCopyWith<_$LivestreamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
