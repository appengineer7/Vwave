// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'numeric_uid')
  String? get numericUid => throw _privateConstructorUsedError;
  @JsonKey(name: 'auth_type')
  String? get authType => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_conversations')
  String get allowConversations => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_search_visibility')
  bool get allowSearchVisibility => throw _privateConstructorUsedError;
  @JsonKey(name: 'story_privacy')
  String? get storyPrivacyOption => throw _privateConstructorUsedError;
  List<String>? get devices => throw _privateConstructorUsedError;
  List<String>? get msgId => throw _privateConstructorUsedError;
  String? get picture => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'referral_code')
  String? get referralCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'facebook_link')
  String? get facebookLink => throw _privateConstructorUsedError;
  @JsonKey(name: 'twitter_link')
  String? get twitterLink => throw _privateConstructorUsedError;
  @JsonKey(name: 'instagram_link')
  String? get instagramLink => throw _privateConstructorUsedError;
  @JsonKey(name: 'tiktok_link')
  String? get tiktokLink => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_role_type')
  String? get userRoleType => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_type')
  String? get userType => throw _privateConstructorUsedError;
  dynamic get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_details')
  dynamic get locationDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'documents')
  dynamic get documents => throw _privateConstructorUsedError;
  bool get blocked => throw _privateConstructorUsedError;
  bool get verified => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_setup')
  bool get accountSetup => throw _privateConstructorUsedError;
  @JsonKey(name: 'device_fingerprint')
  String? get deviceFingerprint => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_date')
  String? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'modified_date')
  String? get modifiedDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'numeric_uid') String? numericUid,
      @JsonKey(name: 'auth_type') String? authType,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      @JsonKey(name: 'allow_conversations') String allowConversations,
      @JsonKey(name: 'allow_search_visibility') bool allowSearchVisibility,
      @JsonKey(name: 'story_privacy') String? storyPrivacyOption,
      List<String>? devices,
      List<String>? msgId,
      String? picture,
      String email,
      String? bio,
      @JsonKey(name: 'referral_code') String? referralCode,
      @JsonKey(name: 'facebook_link') String? facebookLink,
      @JsonKey(name: 'twitter_link') String? twitterLink,
      @JsonKey(name: 'instagram_link') String? instagramLink,
      @JsonKey(name: 'tiktok_link') String? tiktokLink,
      String? location,
      @JsonKey(name: 'user_role_type') String? userRoleType,
      @JsonKey(name: 'user_type') String? userType,
      dynamic timestamp,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      @JsonKey(name: 'documents') dynamic documents,
      bool blocked,
      bool verified,
      @JsonKey(name: 'account_setup') bool accountSetup,
      @JsonKey(name: 'device_fingerprint') String? deviceFingerprint,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? numericUid = freezed,
    Object? authType = freezed,
    Object? firstName = null,
    Object? lastName = null,
    Object? allowConversations = null,
    Object? allowSearchVisibility = null,
    Object? storyPrivacyOption = freezed,
    Object? devices = freezed,
    Object? msgId = freezed,
    Object? picture = freezed,
    Object? email = null,
    Object? bio = freezed,
    Object? referralCode = freezed,
    Object? facebookLink = freezed,
    Object? twitterLink = freezed,
    Object? instagramLink = freezed,
    Object? tiktokLink = freezed,
    Object? location = freezed,
    Object? userRoleType = freezed,
    Object? userType = freezed,
    Object? timestamp = freezed,
    Object? locationDetails = freezed,
    Object? documents = freezed,
    Object? blocked = null,
    Object? verified = null,
    Object? accountSetup = null,
    Object? deviceFingerprint = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      numericUid: freezed == numericUid
          ? _value.numericUid
          : numericUid // ignore: cast_nullable_to_non_nullable
              as String?,
      authType: freezed == authType
          ? _value.authType
          : authType // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      allowConversations: null == allowConversations
          ? _value.allowConversations
          : allowConversations // ignore: cast_nullable_to_non_nullable
              as String,
      allowSearchVisibility: null == allowSearchVisibility
          ? _value.allowSearchVisibility
          : allowSearchVisibility // ignore: cast_nullable_to_non_nullable
              as bool,
      storyPrivacyOption: freezed == storyPrivacyOption
          ? _value.storyPrivacyOption
          : storyPrivacyOption // ignore: cast_nullable_to_non_nullable
              as String?,
      devices: freezed == devices
          ? _value.devices
          : devices // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      msgId: freezed == msgId
          ? _value.msgId
          : msgId // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      picture: freezed == picture
          ? _value.picture
          : picture // ignore: cast_nullable_to_non_nullable
              as String?,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      referralCode: freezed == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String?,
      facebookLink: freezed == facebookLink
          ? _value.facebookLink
          : facebookLink // ignore: cast_nullable_to_non_nullable
              as String?,
      twitterLink: freezed == twitterLink
          ? _value.twitterLink
          : twitterLink // ignore: cast_nullable_to_non_nullable
              as String?,
      instagramLink: freezed == instagramLink
          ? _value.instagramLink
          : instagramLink // ignore: cast_nullable_to_non_nullable
              as String?,
      tiktokLink: freezed == tiktokLink
          ? _value.tiktokLink
          : tiktokLink // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      userRoleType: freezed == userRoleType
          ? _value.userRoleType
          : userRoleType // ignore: cast_nullable_to_non_nullable
              as String?,
      userType: freezed == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      locationDetails: freezed == locationDetails
          ? _value.locationDetails
          : locationDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      documents: freezed == documents
          ? _value.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as dynamic,
      blocked: null == blocked
          ? _value.blocked
          : blocked // ignore: cast_nullable_to_non_nullable
              as bool,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      accountSetup: null == accountSetup
          ? _value.accountSetup
          : accountSetup // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceFingerprint: freezed == deviceFingerprint
          ? _value.deviceFingerprint
          : deviceFingerprint // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'numeric_uid') String? numericUid,
      @JsonKey(name: 'auth_type') String? authType,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      @JsonKey(name: 'allow_conversations') String allowConversations,
      @JsonKey(name: 'allow_search_visibility') bool allowSearchVisibility,
      @JsonKey(name: 'story_privacy') String? storyPrivacyOption,
      List<String>? devices,
      List<String>? msgId,
      String? picture,
      String email,
      String? bio,
      @JsonKey(name: 'referral_code') String? referralCode,
      @JsonKey(name: 'facebook_link') String? facebookLink,
      @JsonKey(name: 'twitter_link') String? twitterLink,
      @JsonKey(name: 'instagram_link') String? instagramLink,
      @JsonKey(name: 'tiktok_link') String? tiktokLink,
      String? location,
      @JsonKey(name: 'user_role_type') String? userRoleType,
      @JsonKey(name: 'user_type') String? userType,
      dynamic timestamp,
      @JsonKey(name: 'location_details') dynamic locationDetails,
      @JsonKey(name: 'documents') dynamic documents,
      bool blocked,
      bool verified,
      @JsonKey(name: 'account_setup') bool accountSetup,
      @JsonKey(name: 'device_fingerprint') String? deviceFingerprint,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? numericUid = freezed,
    Object? authType = freezed,
    Object? firstName = null,
    Object? lastName = null,
    Object? allowConversations = null,
    Object? allowSearchVisibility = null,
    Object? storyPrivacyOption = freezed,
    Object? devices = freezed,
    Object? msgId = freezed,
    Object? picture = freezed,
    Object? email = null,
    Object? bio = freezed,
    Object? referralCode = freezed,
    Object? facebookLink = freezed,
    Object? twitterLink = freezed,
    Object? instagramLink = freezed,
    Object? tiktokLink = freezed,
    Object? location = freezed,
    Object? userRoleType = freezed,
    Object? userType = freezed,
    Object? timestamp = freezed,
    Object? locationDetails = freezed,
    Object? documents = freezed,
    Object? blocked = null,
    Object? verified = null,
    Object? accountSetup = null,
    Object? deviceFingerprint = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
  }) {
    return _then(_$UserImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      numericUid: freezed == numericUid
          ? _value.numericUid
          : numericUid // ignore: cast_nullable_to_non_nullable
              as String?,
      authType: freezed == authType
          ? _value.authType
          : authType // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      allowConversations: null == allowConversations
          ? _value.allowConversations
          : allowConversations // ignore: cast_nullable_to_non_nullable
              as String,
      allowSearchVisibility: null == allowSearchVisibility
          ? _value.allowSearchVisibility
          : allowSearchVisibility // ignore: cast_nullable_to_non_nullable
              as bool,
      storyPrivacyOption: freezed == storyPrivacyOption
          ? _value.storyPrivacyOption
          : storyPrivacyOption // ignore: cast_nullable_to_non_nullable
              as String?,
      devices: freezed == devices
          ? _value._devices
          : devices // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      msgId: freezed == msgId
          ? _value._msgId
          : msgId // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      picture: freezed == picture
          ? _value.picture
          : picture // ignore: cast_nullable_to_non_nullable
              as String?,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      referralCode: freezed == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String?,
      facebookLink: freezed == facebookLink
          ? _value.facebookLink
          : facebookLink // ignore: cast_nullable_to_non_nullable
              as String?,
      twitterLink: freezed == twitterLink
          ? _value.twitterLink
          : twitterLink // ignore: cast_nullable_to_non_nullable
              as String?,
      instagramLink: freezed == instagramLink
          ? _value.instagramLink
          : instagramLink // ignore: cast_nullable_to_non_nullable
              as String?,
      tiktokLink: freezed == tiktokLink
          ? _value.tiktokLink
          : tiktokLink // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      userRoleType: freezed == userRoleType
          ? _value.userRoleType
          : userRoleType // ignore: cast_nullable_to_non_nullable
              as String?,
      userType: freezed == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      locationDetails: freezed == locationDetails
          ? _value.locationDetails
          : locationDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      documents: freezed == documents
          ? _value.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as dynamic,
      blocked: null == blocked
          ? _value.blocked
          : blocked // ignore: cast_nullable_to_non_nullable
              as bool,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      accountSetup: null == accountSetup
          ? _value.accountSetup
          : accountSetup // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceFingerprint: freezed == deviceFingerprint
          ? _value.deviceFingerprint
          : deviceFingerprint // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$UserImpl extends _User {
  const _$UserImpl(
      {this.id,
      @JsonKey(name: 'numeric_uid') this.numericUid,
      @JsonKey(name: 'auth_type') this.authType,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      @JsonKey(name: 'allow_conversations') required this.allowConversations,
      @JsonKey(name: 'allow_search_visibility')
      required this.allowSearchVisibility,
      @JsonKey(name: 'story_privacy') this.storyPrivacyOption,
      final List<String>? devices,
      final List<String>? msgId,
      this.picture,
      required this.email,
      this.bio,
      @JsonKey(name: 'referral_code') this.referralCode,
      @JsonKey(name: 'facebook_link') this.facebookLink,
      @JsonKey(name: 'twitter_link') this.twitterLink,
      @JsonKey(name: 'instagram_link') this.instagramLink,
      @JsonKey(name: 'tiktok_link') this.tiktokLink,
      this.location,
      @JsonKey(name: 'user_role_type') this.userRoleType,
      @JsonKey(name: 'user_type') this.userType,
      this.timestamp,
      @JsonKey(name: 'location_details') this.locationDetails,
      @JsonKey(name: 'documents') this.documents,
      required this.blocked,
      required this.verified,
      @JsonKey(name: 'account_setup') required this.accountSetup,
      @JsonKey(name: 'device_fingerprint') this.deviceFingerprint,
      @JsonKey(name: 'created_date') this.createdDate,
      @JsonKey(name: 'modified_date') this.modifiedDate})
      : _devices = devices,
        _msgId = msgId,
        super._();

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'numeric_uid')
  final String? numericUid;
  @override
  @JsonKey(name: 'auth_type')
  final String? authType;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  @JsonKey(name: 'allow_conversations')
  final String allowConversations;
  @override
  @JsonKey(name: 'allow_search_visibility')
  final bool allowSearchVisibility;
  @override
  @JsonKey(name: 'story_privacy')
  final String? storyPrivacyOption;
  final List<String>? _devices;
  @override
  List<String>? get devices {
    final value = _devices;
    if (value == null) return null;
    if (_devices is EqualUnmodifiableListView) return _devices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _msgId;
  @override
  List<String>? get msgId {
    final value = _msgId;
    if (value == null) return null;
    if (_msgId is EqualUnmodifiableListView) return _msgId;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? picture;
  @override
  final String email;
  @override
  final String? bio;
  @override
  @JsonKey(name: 'referral_code')
  final String? referralCode;
  @override
  @JsonKey(name: 'facebook_link')
  final String? facebookLink;
  @override
  @JsonKey(name: 'twitter_link')
  final String? twitterLink;
  @override
  @JsonKey(name: 'instagram_link')
  final String? instagramLink;
  @override
  @JsonKey(name: 'tiktok_link')
  final String? tiktokLink;
  @override
  final String? location;
  @override
  @JsonKey(name: 'user_role_type')
  final String? userRoleType;
  @override
  @JsonKey(name: 'user_type')
  final String? userType;
  @override
  final dynamic timestamp;
  @override
  @JsonKey(name: 'location_details')
  final dynamic locationDetails;
  @override
  @JsonKey(name: 'documents')
  final dynamic documents;
  @override
  final bool blocked;
  @override
  final bool verified;
  @override
  @JsonKey(name: 'account_setup')
  final bool accountSetup;
  @override
  @JsonKey(name: 'device_fingerprint')
  final String? deviceFingerprint;
  @override
  @JsonKey(name: 'created_date')
  final String? createdDate;
  @override
  @JsonKey(name: 'modified_date')
  final String? modifiedDate;

  @override
  String toString() {
    return 'User(id: $id, numericUid: $numericUid, authType: $authType, firstName: $firstName, lastName: $lastName, allowConversations: $allowConversations, allowSearchVisibility: $allowSearchVisibility, storyPrivacyOption: $storyPrivacyOption, devices: $devices, msgId: $msgId, picture: $picture, email: $email, bio: $bio, referralCode: $referralCode, facebookLink: $facebookLink, twitterLink: $twitterLink, instagramLink: $instagramLink, tiktokLink: $tiktokLink, location: $location, userRoleType: $userRoleType, userType: $userType, timestamp: $timestamp, locationDetails: $locationDetails, documents: $documents, blocked: $blocked, verified: $verified, accountSetup: $accountSetup, deviceFingerprint: $deviceFingerprint, createdDate: $createdDate, modifiedDate: $modifiedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.numericUid, numericUid) ||
                other.numericUid == numericUid) &&
            (identical(other.authType, authType) ||
                other.authType == authType) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.allowConversations, allowConversations) ||
                other.allowConversations == allowConversations) &&
            (identical(other.allowSearchVisibility, allowSearchVisibility) ||
                other.allowSearchVisibility == allowSearchVisibility) &&
            (identical(other.storyPrivacyOption, storyPrivacyOption) ||
                other.storyPrivacyOption == storyPrivacyOption) &&
            const DeepCollectionEquality().equals(other._devices, _devices) &&
            const DeepCollectionEquality().equals(other._msgId, _msgId) &&
            (identical(other.picture, picture) || other.picture == picture) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.referralCode, referralCode) ||
                other.referralCode == referralCode) &&
            (identical(other.facebookLink, facebookLink) ||
                other.facebookLink == facebookLink) &&
            (identical(other.twitterLink, twitterLink) ||
                other.twitterLink == twitterLink) &&
            (identical(other.instagramLink, instagramLink) ||
                other.instagramLink == instagramLink) &&
            (identical(other.tiktokLink, tiktokLink) ||
                other.tiktokLink == tiktokLink) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.userRoleType, userRoleType) ||
                other.userRoleType == userRoleType) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            const DeepCollectionEquality().equals(other.timestamp, timestamp) &&
            const DeepCollectionEquality()
                .equals(other.locationDetails, locationDetails) &&
            const DeepCollectionEquality().equals(other.documents, documents) &&
            (identical(other.blocked, blocked) || other.blocked == blocked) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.accountSetup, accountSetup) ||
                other.accountSetup == accountSetup) &&
            (identical(other.deviceFingerprint, deviceFingerprint) ||
                other.deviceFingerprint == deviceFingerprint) &&
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
        numericUid,
        authType,
        firstName,
        lastName,
        allowConversations,
        allowSearchVisibility,
        storyPrivacyOption,
        const DeepCollectionEquality().hash(_devices),
        const DeepCollectionEquality().hash(_msgId),
        picture,
        email,
        bio,
        referralCode,
        facebookLink,
        twitterLink,
        instagramLink,
        tiktokLink,
        location,
        userRoleType,
        userType,
        const DeepCollectionEquality().hash(timestamp),
        const DeepCollectionEquality().hash(locationDetails),
        const DeepCollectionEquality().hash(documents),
        blocked,
        verified,
        accountSetup,
        deviceFingerprint,
        createdDate,
        modifiedDate
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User extends User {
  const factory _User(
      {final String? id,
      @JsonKey(name: 'numeric_uid') final String? numericUid,
      @JsonKey(name: 'auth_type') final String? authType,
      @JsonKey(name: 'first_name') required final String firstName,
      @JsonKey(name: 'last_name') required final String lastName,
      @JsonKey(name: 'allow_conversations')
      required final String allowConversations,
      @JsonKey(name: 'allow_search_visibility')
      required final bool allowSearchVisibility,
      @JsonKey(name: 'story_privacy') final String? storyPrivacyOption,
      final List<String>? devices,
      final List<String>? msgId,
      final String? picture,
      required final String email,
      final String? bio,
      @JsonKey(name: 'referral_code') final String? referralCode,
      @JsonKey(name: 'facebook_link') final String? facebookLink,
      @JsonKey(name: 'twitter_link') final String? twitterLink,
      @JsonKey(name: 'instagram_link') final String? instagramLink,
      @JsonKey(name: 'tiktok_link') final String? tiktokLink,
      final String? location,
      @JsonKey(name: 'user_role_type') final String? userRoleType,
      @JsonKey(name: 'user_type') final String? userType,
      final dynamic timestamp,
      @JsonKey(name: 'location_details') final dynamic locationDetails,
      @JsonKey(name: 'documents') final dynamic documents,
      required final bool blocked,
      required final bool verified,
      @JsonKey(name: 'account_setup') required final bool accountSetup,
      @JsonKey(name: 'device_fingerprint') final String? deviceFingerprint,
      @JsonKey(name: 'created_date') final String? createdDate,
      @JsonKey(name: 'modified_date') final String? modifiedDate}) = _$UserImpl;
  const _User._() : super._();

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'numeric_uid')
  String? get numericUid;
  @override
  @JsonKey(name: 'auth_type')
  String? get authType;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  @JsonKey(name: 'allow_conversations')
  String get allowConversations;
  @override
  @JsonKey(name: 'allow_search_visibility')
  bool get allowSearchVisibility;
  @override
  @JsonKey(name: 'story_privacy')
  String? get storyPrivacyOption;
  @override
  List<String>? get devices;
  @override
  List<String>? get msgId;
  @override
  String? get picture;
  @override
  String get email;
  @override
  String? get bio;
  @override
  @JsonKey(name: 'referral_code')
  String? get referralCode;
  @override
  @JsonKey(name: 'facebook_link')
  String? get facebookLink;
  @override
  @JsonKey(name: 'twitter_link')
  String? get twitterLink;
  @override
  @JsonKey(name: 'instagram_link')
  String? get instagramLink;
  @override
  @JsonKey(name: 'tiktok_link')
  String? get tiktokLink;
  @override
  String? get location;
  @override
  @JsonKey(name: 'user_role_type')
  String? get userRoleType;
  @override
  @JsonKey(name: 'user_type')
  String? get userType;
  @override
  dynamic get timestamp;
  @override
  @JsonKey(name: 'location_details')
  dynamic get locationDetails;
  @override
  @JsonKey(name: 'documents')
  dynamic get documents;
  @override
  bool get blocked;
  @override
  bool get verified;
  @override
  @JsonKey(name: 'account_setup')
  bool get accountSetup;
  @override
  @JsonKey(name: 'device_fingerprint')
  String? get deviceFingerprint;
  @override
  @JsonKey(name: 'created_date')
  String? get createdDate;
  @override
  @JsonKey(name: 'modified_date')
  String? get modifiedDate;
  @override
  @JsonKey(ignore: true)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
