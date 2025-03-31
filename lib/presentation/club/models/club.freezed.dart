// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Club _$ClubFromJson(Map<String, dynamic> json) {
  return _Club.fromJson(json);
}

/// @nodoc
mixin _$Club {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_uid')
  String get userUid => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_name')
  String get clubName => throw _privateConstructorUsedError;
  @JsonKey(name: 'opening_days')
  String get openingDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'opening_times')
  String get openingTimes => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  dynamic get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'link')
  String get link => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_reviews')
  int get totalReviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_rating')
  dynamic get totalRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating_count')
  int get ratingCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating_count_object')
  dynamic get ratingCountObject => throw _privateConstructorUsedError;
  List<dynamic> get gallery => throw _privateConstructorUsedError;
  @JsonKey(name: 'recent_reviews')
  List<dynamic> get recentReviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_images')
  List<dynamic> get coverImages => throw _privateConstructorUsedError;
  List<dynamic>? get msgId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  dynamic get location => throw _privateConstructorUsedError;
  dynamic get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_details')
  dynamic get locationDetails => throw _privateConstructorUsedError;
  bool get verified => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_date')
  String? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'modified_date')
  String? get modifiedDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClubCopyWith<Club> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClubCopyWith<$Res> {
  factory $ClubCopyWith(Club value, $Res Function(Club) then) =
      _$ClubCopyWithImpl<$Res, Club>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_uid') String userUid,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'opening_days') String openingDays,
      @JsonKey(name: 'opening_times') String openingTimes,
      @JsonKey(name: 'phone_number') dynamic phoneNumber,
      @JsonKey(name: 'link') String link,
      String description,
      String country,
      String state,
      @JsonKey(name: 'total_reviews') int totalReviews,
      @JsonKey(name: 'total_rating') dynamic totalRating,
      @JsonKey(name: 'rating_count') int ratingCount,
      @JsonKey(name: 'rating_count_object') dynamic ratingCountObject,
      List<dynamic> gallery,
      @JsonKey(name: 'recent_reviews') List<dynamic> recentReviews,
      @JsonKey(name: 'cover_images') List<dynamic> coverImages,
      List<dynamic>? msgId,
      String email,
      dynamic location,
      dynamic timestamp,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      bool verified,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class _$ClubCopyWithImpl<$Res, $Val extends Club>
    implements $ClubCopyWith<$Res> {
  _$ClubCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userUid = null,
    Object? clubName = null,
    Object? openingDays = null,
    Object? openingTimes = null,
    Object? phoneNumber = freezed,
    Object? link = null,
    Object? description = null,
    Object? country = null,
    Object? state = null,
    Object? totalReviews = null,
    Object? totalRating = freezed,
    Object? ratingCount = null,
    Object? ratingCountObject = freezed,
    Object? gallery = null,
    Object? recentReviews = null,
    Object? coverImages = null,
    Object? msgId = freezed,
    Object? email = null,
    Object? location = freezed,
    Object? timestamp = freezed,
    Object? locationDetails = freezed,
    Object? verified = null,
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
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      openingDays: null == openingDays
          ? _value.openingDays
          : openingDays // ignore: cast_nullable_to_non_nullable
              as String,
      openingTimes: null == openingTimes
          ? _value.openingTimes
          : openingTimes // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as dynamic,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      totalRating: freezed == totalRating
          ? _value.totalRating
          : totalRating // ignore: cast_nullable_to_non_nullable
              as dynamic,
      ratingCount: null == ratingCount
          ? _value.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int,
      ratingCountObject: freezed == ratingCountObject
          ? _value.ratingCountObject
          : ratingCountObject // ignore: cast_nullable_to_non_nullable
              as dynamic,
      gallery: null == gallery
          ? _value.gallery
          : gallery // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      recentReviews: null == recentReviews
          ? _value.recentReviews
          : recentReviews // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      coverImages: null == coverImages
          ? _value.coverImages
          : coverImages // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      msgId: freezed == msgId
          ? _value.msgId
          : msgId // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as dynamic,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      locationDetails: freezed == locationDetails
          ? _value.locationDetails
          : locationDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$ClubImplCopyWith<$Res> implements $ClubCopyWith<$Res> {
  factory _$$ClubImplCopyWith(
          _$ClubImpl value, $Res Function(_$ClubImpl) then) =
      __$$ClubImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_uid') String userUid,
      @JsonKey(name: 'club_name') String clubName,
      @JsonKey(name: 'opening_days') String openingDays,
      @JsonKey(name: 'opening_times') String openingTimes,
      @JsonKey(name: 'phone_number') dynamic phoneNumber,
      @JsonKey(name: 'link') String link,
      String description,
      String country,
      String state,
      @JsonKey(name: 'total_reviews') int totalReviews,
      @JsonKey(name: 'total_rating') dynamic totalRating,
      @JsonKey(name: 'rating_count') int ratingCount,
      @JsonKey(name: 'rating_count_object') dynamic ratingCountObject,
      List<dynamic> gallery,
      @JsonKey(name: 'recent_reviews') List<dynamic> recentReviews,
      @JsonKey(name: 'cover_images') List<dynamic> coverImages,
      List<dynamic>? msgId,
      String email,
      dynamic location,
      dynamic timestamp,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      bool verified,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class __$$ClubImplCopyWithImpl<$Res>
    extends _$ClubCopyWithImpl<$Res, _$ClubImpl>
    implements _$$ClubImplCopyWith<$Res> {
  __$$ClubImplCopyWithImpl(_$ClubImpl _value, $Res Function(_$ClubImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userUid = null,
    Object? clubName = null,
    Object? openingDays = null,
    Object? openingTimes = null,
    Object? phoneNumber = freezed,
    Object? link = null,
    Object? description = null,
    Object? country = null,
    Object? state = null,
    Object? totalReviews = null,
    Object? totalRating = freezed,
    Object? ratingCount = null,
    Object? ratingCountObject = freezed,
    Object? gallery = null,
    Object? recentReviews = null,
    Object? coverImages = null,
    Object? msgId = freezed,
    Object? email = null,
    Object? location = freezed,
    Object? timestamp = freezed,
    Object? locationDetails = freezed,
    Object? verified = null,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
  }) {
    return _then(_$ClubImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userUid: null == userUid
          ? _value.userUid
          : userUid // ignore: cast_nullable_to_non_nullable
              as String,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      openingDays: null == openingDays
          ? _value.openingDays
          : openingDays // ignore: cast_nullable_to_non_nullable
              as String,
      openingTimes: null == openingTimes
          ? _value.openingTimes
          : openingTimes // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as dynamic,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      totalRating: freezed == totalRating
          ? _value.totalRating
          : totalRating // ignore: cast_nullable_to_non_nullable
              as dynamic,
      ratingCount: null == ratingCount
          ? _value.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int,
      ratingCountObject: freezed == ratingCountObject
          ? _value.ratingCountObject
          : ratingCountObject // ignore: cast_nullable_to_non_nullable
              as dynamic,
      gallery: null == gallery
          ? _value._gallery
          : gallery // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      recentReviews: null == recentReviews
          ? _value._recentReviews
          : recentReviews // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      coverImages: null == coverImages
          ? _value._coverImages
          : coverImages // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      msgId: freezed == msgId
          ? _value._msgId
          : msgId // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as dynamic,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      locationDetails: freezed == locationDetails
          ? _value.locationDetails
          : locationDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$ClubImpl extends _Club {
  const _$ClubImpl(
      {this.id,
      @JsonKey(name: 'user_uid') required this.userUid,
      @JsonKey(name: 'club_name') required this.clubName,
      @JsonKey(name: 'opening_days') required this.openingDays,
      @JsonKey(name: 'opening_times') required this.openingTimes,
      @JsonKey(name: 'phone_number') required this.phoneNumber,
      @JsonKey(name: 'link') required this.link,
      required this.description,
      required this.country,
      required this.state,
      @JsonKey(name: 'total_reviews') required this.totalReviews,
      @JsonKey(name: 'total_rating') required this.totalRating,
      @JsonKey(name: 'rating_count') required this.ratingCount,
      @JsonKey(name: 'rating_count_object') required this.ratingCountObject,
      required final List<dynamic> gallery,
      @JsonKey(name: 'recent_reviews')
      required final List<dynamic> recentReviews,
      @JsonKey(name: 'cover_images') required final List<dynamic> coverImages,
      final List<dynamic>? msgId,
      required this.email,
      required this.location,
      this.timestamp,
      @JsonKey(name: 'location_details') this.locationDetails,
      required this.verified,
      @JsonKey(name: 'created_date') this.createdDate,
      @JsonKey(name: 'modified_date') this.modifiedDate})
      : _gallery = gallery,
        _recentReviews = recentReviews,
        _coverImages = coverImages,
        _msgId = msgId,
        super._();

  factory _$ClubImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClubImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'user_uid')
  final String userUid;
  @override
  @JsonKey(name: 'club_name')
  final String clubName;
  @override
  @JsonKey(name: 'opening_days')
  final String openingDays;
  @override
  @JsonKey(name: 'opening_times')
  final String openingTimes;
  @override
  @JsonKey(name: 'phone_number')
  final dynamic phoneNumber;
  @override
  @JsonKey(name: 'link')
  final String link;
  @override
  final String description;
  @override
  final String country;
  @override
  final String state;
  @override
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @override
  @JsonKey(name: 'total_rating')
  final dynamic totalRating;
  @override
  @JsonKey(name: 'rating_count')
  final int ratingCount;
  @override
  @JsonKey(name: 'rating_count_object')
  final dynamic ratingCountObject;
  final List<dynamic> _gallery;
  @override
  List<dynamic> get gallery {
    if (_gallery is EqualUnmodifiableListView) return _gallery;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gallery);
  }

  final List<dynamic> _recentReviews;
  @override
  @JsonKey(name: 'recent_reviews')
  List<dynamic> get recentReviews {
    if (_recentReviews is EqualUnmodifiableListView) return _recentReviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentReviews);
  }

  final List<dynamic> _coverImages;
  @override
  @JsonKey(name: 'cover_images')
  List<dynamic> get coverImages {
    if (_coverImages is EqualUnmodifiableListView) return _coverImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coverImages);
  }

  final List<dynamic>? _msgId;
  @override
  List<dynamic>? get msgId {
    final value = _msgId;
    if (value == null) return null;
    if (_msgId is EqualUnmodifiableListView) return _msgId;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String email;
  @override
  final dynamic location;
  @override
  final dynamic timestamp;
  @override
  @JsonKey(name: 'location_details')
  final dynamic locationDetails;
  @override
  final bool verified;
  @override
  @JsonKey(name: 'created_date')
  final String? createdDate;
  @override
  @JsonKey(name: 'modified_date')
  final String? modifiedDate;

  @override
  String toString() {
    return 'Club(id: $id, userUid: $userUid, clubName: $clubName, openingDays: $openingDays, openingTimes: $openingTimes, phoneNumber: $phoneNumber, link: $link, description: $description, country: $country, state: $state, totalReviews: $totalReviews, totalRating: $totalRating, ratingCount: $ratingCount, ratingCountObject: $ratingCountObject, gallery: $gallery, recentReviews: $recentReviews, coverImages: $coverImages, msgId: $msgId, email: $email, location: $location, timestamp: $timestamp, locationDetails: $locationDetails, verified: $verified, createdDate: $createdDate, modifiedDate: $modifiedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClubImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userUid, userUid) || other.userUid == userUid) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName) &&
            (identical(other.openingDays, openingDays) ||
                other.openingDays == openingDays) &&
            (identical(other.openingTimes, openingTimes) ||
                other.openingTimes == openingTimes) &&
            const DeepCollectionEquality()
                .equals(other.phoneNumber, phoneNumber) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            const DeepCollectionEquality()
                .equals(other.totalRating, totalRating) &&
            (identical(other.ratingCount, ratingCount) ||
                other.ratingCount == ratingCount) &&
            const DeepCollectionEquality()
                .equals(other.ratingCountObject, ratingCountObject) &&
            const DeepCollectionEquality().equals(other._gallery, _gallery) &&
            const DeepCollectionEquality()
                .equals(other._recentReviews, _recentReviews) &&
            const DeepCollectionEquality()
                .equals(other._coverImages, _coverImages) &&
            const DeepCollectionEquality().equals(other._msgId, _msgId) &&
            (identical(other.email, email) || other.email == email) &&
            const DeepCollectionEquality().equals(other.location, location) &&
            const DeepCollectionEquality().equals(other.timestamp, timestamp) &&
            const DeepCollectionEquality()
                .equals(other.locationDetails, locationDetails) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.modifiedDate, modifiedDate) ||
                other.modifiedDate == modifiedDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userUid,
        clubName,
        openingDays,
        openingTimes,
        const DeepCollectionEquality().hash(phoneNumber),
        link,
        description,
        country,
        state,
        totalReviews,
        const DeepCollectionEquality().hash(totalRating),
        ratingCount,
        const DeepCollectionEquality().hash(ratingCountObject),
        const DeepCollectionEquality().hash(_gallery),
        const DeepCollectionEquality().hash(_recentReviews),
        const DeepCollectionEquality().hash(_coverImages),
        const DeepCollectionEquality().hash(_msgId),
        email,
        const DeepCollectionEquality().hash(location),
        const DeepCollectionEquality().hash(timestamp),
        const DeepCollectionEquality().hash(locationDetails),
        verified,
        createdDate,
        modifiedDate
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClubImplCopyWith<_$ClubImpl> get copyWith =>
      __$$ClubImplCopyWithImpl<_$ClubImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClubImplToJson(
      this,
    );
  }
}

abstract class _Club extends Club {
  const factory _Club(
      {final String? id,
      @JsonKey(name: 'user_uid') required final String userUid,
      @JsonKey(name: 'club_name') required final String clubName,
      @JsonKey(name: 'opening_days') required final String openingDays,
      @JsonKey(name: 'opening_times') required final String openingTimes,
      @JsonKey(name: 'phone_number') required final dynamic phoneNumber,
      @JsonKey(name: 'link') required final String link,
      required final String description,
      required final String country,
      required final String state,
      @JsonKey(name: 'total_reviews') required final int totalReviews,
      @JsonKey(name: 'total_rating') required final dynamic totalRating,
      @JsonKey(name: 'rating_count') required final int ratingCount,
      @JsonKey(name: 'rating_count_object')
      required final dynamic ratingCountObject,
      required final List<dynamic> gallery,
      @JsonKey(name: 'recent_reviews')
      required final List<dynamic> recentReviews,
      @JsonKey(name: 'cover_images') required final List<dynamic> coverImages,
      final List<dynamic>? msgId,
      required final String email,
      required final dynamic location,
      final dynamic timestamp,
      @JsonKey(name: 'location_details') final dynamic locationDetails,
      required final bool verified,
      @JsonKey(name: 'created_date') final String? createdDate,
      @JsonKey(name: 'modified_date') final String? modifiedDate}) = _$ClubImpl;
  const _Club._() : super._();

  factory _Club.fromJson(Map<String, dynamic> json) = _$ClubImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'user_uid')
  String get userUid;
  @override
  @JsonKey(name: 'club_name')
  String get clubName;
  @override
  @JsonKey(name: 'opening_days')
  String get openingDays;
  @override
  @JsonKey(name: 'opening_times')
  String get openingTimes;
  @override
  @JsonKey(name: 'phone_number')
  dynamic get phoneNumber;
  @override
  @JsonKey(name: 'link')
  String get link;
  @override
  String get description;
  @override
  String get country;
  @override
  String get state;
  @override
  @JsonKey(name: 'total_reviews')
  int get totalReviews;
  @override
  @JsonKey(name: 'total_rating')
  dynamic get totalRating;
  @override
  @JsonKey(name: 'rating_count')
  int get ratingCount;
  @override
  @JsonKey(name: 'rating_count_object')
  dynamic get ratingCountObject;
  @override
  List<dynamic> get gallery;
  @override
  @JsonKey(name: 'recent_reviews')
  List<dynamic> get recentReviews;
  @override
  @JsonKey(name: 'cover_images')
  List<dynamic> get coverImages;
  @override
  List<dynamic>? get msgId;
  @override
  String get email;
  @override
  dynamic get location;
  @override
  dynamic get timestamp;
  @override
  @JsonKey(name: 'location_details')
  dynamic get locationDetails;
  @override
  bool get verified;
  @override
  @JsonKey(name: 'created_date')
  String? get createdDate;
  @override
  @JsonKey(name: 'modified_date')
  String? get modifiedDate;
  @override
  @JsonKey(ignore: true)
  _$$ClubImplCopyWith<_$ClubImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
