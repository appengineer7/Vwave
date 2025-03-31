// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

StoryFeed _$StoryFeedFromJson(Map<String, dynamic> json) {
  return _StoryFeed.fromJson(json);
}

/// @nodoc
mixin _$StoryFeed {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_uid')
  String get userUid => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'preview_title')
  Map<String, dynamic> get previewTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'preview_image')
  String get previewImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'files')
  List<Map<String, dynamic>> get files => throw _privateConstructorUsedError;
  @JsonKey(name: 'views_count')
  Map<String, dynamic>? get viewsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_details')
  Map<String, dynamic> get otherDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_zone')
  String get timeZone => throw _privateConstructorUsedError;
  dynamic get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'story_privacy')
  String? get storyPrivacy => throw _privateConstructorUsedError;
  @JsonKey(name: 'allowed_uid')
  List<String>? get allowedUid => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_details')
  dynamic get locationDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_date')
  String? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'modified_date')
  String? get modifiedDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StoryFeedCopyWith<StoryFeed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryFeedCopyWith<$Res> {
  factory $StoryFeedCopyWith(StoryFeed value, $Res Function(StoryFeed) then) =
      _$StoryFeedCopyWithImpl<$Res, StoryFeed>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_uid') String userUid,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      @JsonKey(name: 'preview_title') Map<String, dynamic> previewTitle,
      @JsonKey(name: 'preview_image') String previewImage,
      @JsonKey(name: 'files') List<Map<String, dynamic>> files,
      @JsonKey(name: 'views_count') Map<String, dynamic>? viewsCount,
      @JsonKey(name: 'other_details') Map<String, dynamic> otherDetails,
      @JsonKey(name: 'time_zone') String timeZone,
      dynamic timestamp,
      @JsonKey(name: 'story_privacy') String? storyPrivacy,
      @JsonKey(name: 'allowed_uid') List<String>? allowedUid,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class _$StoryFeedCopyWithImpl<$Res, $Val extends StoryFeed>
    implements $StoryFeedCopyWith<$Res> {
  _$StoryFeedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userUid = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? previewTitle = null,
    Object? previewImage = null,
    Object? files = null,
    Object? viewsCount = freezed,
    Object? otherDetails = null,
    Object? timeZone = null,
    Object? timestamp = freezed,
    Object? storyPrivacy = freezed,
    Object? allowedUid = freezed,
    Object? locationDetails = freezed,
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
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      previewTitle: null == previewTitle
          ? _value.previewTitle
          : previewTitle // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      previewImage: null == previewImage
          ? _value.previewImage
          : previewImage // ignore: cast_nullable_to_non_nullable
              as String,
      files: null == files
          ? _value.files
          : files // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      viewsCount: freezed == viewsCount
          ? _value.viewsCount
          : viewsCount // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      otherDetails: null == otherDetails
          ? _value.otherDetails
          : otherDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      timeZone: null == timeZone
          ? _value.timeZone
          : timeZone // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      storyPrivacy: freezed == storyPrivacy
          ? _value.storyPrivacy
          : storyPrivacy // ignore: cast_nullable_to_non_nullable
              as String?,
      allowedUid: freezed == allowedUid
          ? _value.allowedUid
          : allowedUid // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      locationDetails: freezed == locationDetails
          ? _value.locationDetails
          : locationDetails // ignore: cast_nullable_to_non_nullable
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
abstract class _$$StoryFeedImplCopyWith<$Res>
    implements $StoryFeedCopyWith<$Res> {
  factory _$$StoryFeedImplCopyWith(
          _$StoryFeedImpl value, $Res Function(_$StoryFeedImpl) then) =
      __$$StoryFeedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_uid') String userUid,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      @JsonKey(name: 'preview_title') Map<String, dynamic> previewTitle,
      @JsonKey(name: 'preview_image') String previewImage,
      @JsonKey(name: 'files') List<Map<String, dynamic>> files,
      @JsonKey(name: 'views_count') Map<String, dynamic>? viewsCount,
      @JsonKey(name: 'other_details') Map<String, dynamic> otherDetails,
      @JsonKey(name: 'time_zone') String timeZone,
      dynamic timestamp,
      @JsonKey(name: 'story_privacy') String? storyPrivacy,
      @JsonKey(name: 'allowed_uid') List<String>? allowedUid,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class __$$StoryFeedImplCopyWithImpl<$Res>
    extends _$StoryFeedCopyWithImpl<$Res, _$StoryFeedImpl>
    implements _$$StoryFeedImplCopyWith<$Res> {
  __$$StoryFeedImplCopyWithImpl(
      _$StoryFeedImpl _value, $Res Function(_$StoryFeedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userUid = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? previewTitle = null,
    Object? previewImage = null,
    Object? files = null,
    Object? viewsCount = freezed,
    Object? otherDetails = null,
    Object? timeZone = null,
    Object? timestamp = freezed,
    Object? storyPrivacy = freezed,
    Object? allowedUid = freezed,
    Object? locationDetails = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
  }) {
    return _then(_$StoryFeedImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userUid: null == userUid
          ? _value.userUid
          : userUid // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      previewTitle: null == previewTitle
          ? _value._previewTitle
          : previewTitle // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      previewImage: null == previewImage
          ? _value.previewImage
          : previewImage // ignore: cast_nullable_to_non_nullable
              as String,
      files: null == files
          ? _value._files
          : files // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      viewsCount: freezed == viewsCount
          ? _value._viewsCount
          : viewsCount // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      otherDetails: null == otherDetails
          ? _value._otherDetails
          : otherDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      timeZone: null == timeZone
          ? _value.timeZone
          : timeZone // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      storyPrivacy: freezed == storyPrivacy
          ? _value.storyPrivacy
          : storyPrivacy // ignore: cast_nullable_to_non_nullable
              as String?,
      allowedUid: freezed == allowedUid
          ? _value._allowedUid
          : allowedUid // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      locationDetails: freezed == locationDetails
          ? _value.locationDetails
          : locationDetails // ignore: cast_nullable_to_non_nullable
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
class _$StoryFeedImpl extends _StoryFeed {
  const _$StoryFeedImpl(
      {this.id,
      @JsonKey(name: 'user_uid') required this.userUid,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      @JsonKey(name: 'preview_title')
      required final Map<String, dynamic> previewTitle,
      @JsonKey(name: 'preview_image') required this.previewImage,
      @JsonKey(name: 'files') required final List<Map<String, dynamic>> files,
      @JsonKey(name: 'views_count') final Map<String, dynamic>? viewsCount,
      @JsonKey(name: 'other_details')
      required final Map<String, dynamic> otherDetails,
      @JsonKey(name: 'time_zone') required this.timeZone,
      this.timestamp,
      @JsonKey(name: 'story_privacy') this.storyPrivacy,
      @JsonKey(name: 'allowed_uid') final List<String>? allowedUid,
      @JsonKey(name: 'location_details') this.locationDetails,
      @JsonKey(name: 'created_date') this.createdDate,
      @JsonKey(name: 'modified_date') this.modifiedDate})
      : _previewTitle = previewTitle,
        _files = files,
        _viewsCount = viewsCount,
        _otherDetails = otherDetails,
        _allowedUid = allowedUid,
        super._();

  factory _$StoryFeedImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryFeedImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'user_uid')
  final String userUid;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  final Map<String, dynamic> _previewTitle;
  @override
  @JsonKey(name: 'preview_title')
  Map<String, dynamic> get previewTitle {
    if (_previewTitle is EqualUnmodifiableMapView) return _previewTitle;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_previewTitle);
  }

  @override
  @JsonKey(name: 'preview_image')
  final String previewImage;
  final List<Map<String, dynamic>> _files;
  @override
  @JsonKey(name: 'files')
  List<Map<String, dynamic>> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  final Map<String, dynamic>? _viewsCount;
  @override
  @JsonKey(name: 'views_count')
  Map<String, dynamic>? get viewsCount {
    final value = _viewsCount;
    if (value == null) return null;
    if (_viewsCount is EqualUnmodifiableMapView) return _viewsCount;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic> _otherDetails;
  @override
  @JsonKey(name: 'other_details')
  Map<String, dynamic> get otherDetails {
    if (_otherDetails is EqualUnmodifiableMapView) return _otherDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_otherDetails);
  }

  @override
  @JsonKey(name: 'time_zone')
  final String timeZone;
  @override
  final dynamic timestamp;
  @override
  @JsonKey(name: 'story_privacy')
  final String? storyPrivacy;
  final List<String>? _allowedUid;
  @override
  @JsonKey(name: 'allowed_uid')
  List<String>? get allowedUid {
    final value = _allowedUid;
    if (value == null) return null;
    if (_allowedUid is EqualUnmodifiableListView) return _allowedUid;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'location_details')
  final dynamic locationDetails;
  @override
  @JsonKey(name: 'created_date')
  final String? createdDate;
  @override
  @JsonKey(name: 'modified_date')
  final String? modifiedDate;

  @override
  String toString() {
    return 'StoryFeed(id: $id, userUid: $userUid, firstName: $firstName, lastName: $lastName, previewTitle: $previewTitle, previewImage: $previewImage, files: $files, viewsCount: $viewsCount, otherDetails: $otherDetails, timeZone: $timeZone, timestamp: $timestamp, storyPrivacy: $storyPrivacy, allowedUid: $allowedUid, locationDetails: $locationDetails, createdDate: $createdDate, modifiedDate: $modifiedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryFeedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userUid, userUid) || other.userUid == userUid) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            const DeepCollectionEquality()
                .equals(other._previewTitle, _previewTitle) &&
            (identical(other.previewImage, previewImage) ||
                other.previewImage == previewImage) &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            const DeepCollectionEquality()
                .equals(other._viewsCount, _viewsCount) &&
            const DeepCollectionEquality()
                .equals(other._otherDetails, _otherDetails) &&
            (identical(other.timeZone, timeZone) ||
                other.timeZone == timeZone) &&
            const DeepCollectionEquality().equals(other.timestamp, timestamp) &&
            (identical(other.storyPrivacy, storyPrivacy) ||
                other.storyPrivacy == storyPrivacy) &&
            const DeepCollectionEquality()
                .equals(other._allowedUid, _allowedUid) &&
            const DeepCollectionEquality()
                .equals(other.locationDetails, locationDetails) &&
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
      firstName,
      lastName,
      const DeepCollectionEquality().hash(_previewTitle),
      previewImage,
      const DeepCollectionEquality().hash(_files),
      const DeepCollectionEquality().hash(_viewsCount),
      const DeepCollectionEquality().hash(_otherDetails),
      timeZone,
      const DeepCollectionEquality().hash(timestamp),
      storyPrivacy,
      const DeepCollectionEquality().hash(_allowedUid),
      const DeepCollectionEquality().hash(locationDetails),
      createdDate,
      modifiedDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryFeedImplCopyWith<_$StoryFeedImpl> get copyWith =>
      __$$StoryFeedImplCopyWithImpl<_$StoryFeedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryFeedImplToJson(
      this,
    );
  }
}

abstract class _StoryFeed extends StoryFeed {
  const factory _StoryFeed(
      {final String? id,
      @JsonKey(name: 'user_uid') required final String userUid,
      @JsonKey(name: 'first_name') required final String firstName,
      @JsonKey(name: 'last_name') required final String lastName,
      @JsonKey(name: 'preview_title')
      required final Map<String, dynamic> previewTitle,
      @JsonKey(name: 'preview_image') required final String previewImage,
      @JsonKey(name: 'files') required final List<Map<String, dynamic>> files,
      @JsonKey(name: 'views_count') final Map<String, dynamic>? viewsCount,
      @JsonKey(name: 'other_details')
      required final Map<String, dynamic> otherDetails,
      @JsonKey(name: 'time_zone') required final String timeZone,
      final dynamic timestamp,
      @JsonKey(name: 'story_privacy') final String? storyPrivacy,
      @JsonKey(name: 'allowed_uid') final List<String>? allowedUid,
      @JsonKey(name: 'location_details') final dynamic locationDetails,
      @JsonKey(name: 'created_date') final String? createdDate,
      @JsonKey(name: 'modified_date')
      final String? modifiedDate}) = _$StoryFeedImpl;
  const _StoryFeed._() : super._();

  factory _StoryFeed.fromJson(Map<String, dynamic> json) =
      _$StoryFeedImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'user_uid')
  String get userUid;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  @JsonKey(name: 'preview_title')
  Map<String, dynamic> get previewTitle;
  @override
  @JsonKey(name: 'preview_image')
  String get previewImage;
  @override
  @JsonKey(name: 'files')
  List<Map<String, dynamic>> get files;
  @override
  @JsonKey(name: 'views_count')
  Map<String, dynamic>? get viewsCount;
  @override
  @JsonKey(name: 'other_details')
  Map<String, dynamic> get otherDetails;
  @override
  @JsonKey(name: 'time_zone')
  String get timeZone;
  @override
  dynamic get timestamp;
  @override
  @JsonKey(name: 'story_privacy')
  String? get storyPrivacy;
  @override
  @JsonKey(name: 'allowed_uid')
  List<String>? get allowedUid;
  @override
  @JsonKey(name: 'location_details')
  dynamic get locationDetails;
  @override
  @JsonKey(name: 'created_date')
  String? get createdDate;
  @override
  @JsonKey(name: 'modified_date')
  String? get modifiedDate;
  @override
  @JsonKey(ignore: true)
  _$$StoryFeedImplCopyWith<_$StoryFeedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
