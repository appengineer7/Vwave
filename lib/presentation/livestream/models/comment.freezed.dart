// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return _Comment.fromJson(json);
}

/// @nodoc
mixin _$Comment {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'livestream_id')
  String get livestreamId => throw _privateConstructorUsedError;
  @JsonKey(name: 'uid')
  String get userUid => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_conversations')
  String get allowConversations => throw _privateConstructorUsedError;
  @JsonKey(name: 'comment_body')
  String get commentBody => throw _privateConstructorUsedError;
  @JsonKey(name: 'picture')
  String get picture => throw _privateConstructorUsedError;
  dynamic get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_date')
  String? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'modified_date')
  String? get modifiedDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommentCopyWith<Comment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentCopyWith<$Res> {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) then) =
      _$CommentCopyWithImpl<$Res, Comment>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'livestream_id') String livestreamId,
      @JsonKey(name: 'uid') String userUid,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      @JsonKey(name: 'allow_conversations') String allowConversations,
      @JsonKey(name: 'comment_body') String commentBody,
      @JsonKey(name: 'picture') String picture,
      dynamic timestamp,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class _$CommentCopyWithImpl<$Res, $Val extends Comment>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? livestreamId = null,
    Object? userUid = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? allowConversations = null,
    Object? commentBody = null,
    Object? picture = null,
    Object? timestamp = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      livestreamId: null == livestreamId
          ? _value.livestreamId
          : livestreamId // ignore: cast_nullable_to_non_nullable
              as String,
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
      allowConversations: null == allowConversations
          ? _value.allowConversations
          : allowConversations // ignore: cast_nullable_to_non_nullable
              as String,
      commentBody: null == commentBody
          ? _value.commentBody
          : commentBody // ignore: cast_nullable_to_non_nullable
              as String,
      picture: null == picture
          ? _value.picture
          : picture // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CommentImplCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$CommentImplCopyWith(
          _$CommentImpl value, $Res Function(_$CommentImpl) then) =
      __$$CommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'livestream_id') String livestreamId,
      @JsonKey(name: 'uid') String userUid,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      @JsonKey(name: 'allow_conversations') String allowConversations,
      @JsonKey(name: 'comment_body') String commentBody,
      @JsonKey(name: 'picture') String picture,
      dynamic timestamp,
      @JsonKey(name: 'created_date') String? createdDate,
      @JsonKey(name: 'modified_date') String? modifiedDate});
}

/// @nodoc
class __$$CommentImplCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$CommentImpl>
    implements _$$CommentImplCopyWith<$Res> {
  __$$CommentImplCopyWithImpl(
      _$CommentImpl _value, $Res Function(_$CommentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? livestreamId = null,
    Object? userUid = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? allowConversations = null,
    Object? commentBody = null,
    Object? picture = null,
    Object? timestamp = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
  }) {
    return _then(_$CommentImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      livestreamId: null == livestreamId
          ? _value.livestreamId
          : livestreamId // ignore: cast_nullable_to_non_nullable
              as String,
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
      allowConversations: null == allowConversations
          ? _value.allowConversations
          : allowConversations // ignore: cast_nullable_to_non_nullable
              as String,
      commentBody: null == commentBody
          ? _value.commentBody
          : commentBody // ignore: cast_nullable_to_non_nullable
              as String,
      picture: null == picture
          ? _value.picture
          : picture // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
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
class _$CommentImpl extends _Comment {
  const _$CommentImpl(
      {this.id,
      @JsonKey(name: 'livestream_id') required this.livestreamId,
      @JsonKey(name: 'uid') required this.userUid,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      @JsonKey(name: 'allow_conversations') required this.allowConversations,
      @JsonKey(name: 'comment_body') required this.commentBody,
      @JsonKey(name: 'picture') required this.picture,
      this.timestamp,
      @JsonKey(name: 'created_date') this.createdDate,
      @JsonKey(name: 'modified_date') this.modifiedDate})
      : super._();

  factory _$CommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'livestream_id')
  final String livestreamId;
  @override
  @JsonKey(name: 'uid')
  final String userUid;
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
  @JsonKey(name: 'comment_body')
  final String commentBody;
  @override
  @JsonKey(name: 'picture')
  final String picture;
  @override
  final dynamic timestamp;
  @override
  @JsonKey(name: 'created_date')
  final String? createdDate;
  @override
  @JsonKey(name: 'modified_date')
  final String? modifiedDate;

  @override
  String toString() {
    return 'Comment(id: $id, livestreamId: $livestreamId, userUid: $userUid, firstName: $firstName, lastName: $lastName, allowConversations: $allowConversations, commentBody: $commentBody, picture: $picture, timestamp: $timestamp, createdDate: $createdDate, modifiedDate: $modifiedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.livestreamId, livestreamId) ||
                other.livestreamId == livestreamId) &&
            (identical(other.userUid, userUid) || other.userUid == userUid) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.allowConversations, allowConversations) ||
                other.allowConversations == allowConversations) &&
            (identical(other.commentBody, commentBody) ||
                other.commentBody == commentBody) &&
            (identical(other.picture, picture) || other.picture == picture) &&
            const DeepCollectionEquality().equals(other.timestamp, timestamp) &&
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
      livestreamId,
      userUid,
      firstName,
      lastName,
      allowConversations,
      commentBody,
      picture,
      const DeepCollectionEquality().hash(timestamp),
      createdDate,
      modifiedDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      __$$CommentImplCopyWithImpl<_$CommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentImplToJson(
      this,
    );
  }
}

abstract class _Comment extends Comment {
  const factory _Comment(
          {final String? id,
          @JsonKey(name: 'livestream_id') required final String livestreamId,
          @JsonKey(name: 'uid') required final String userUid,
          @JsonKey(name: 'first_name') required final String firstName,
          @JsonKey(name: 'last_name') required final String lastName,
          @JsonKey(name: 'allow_conversations')
          required final String allowConversations,
          @JsonKey(name: 'comment_body') required final String commentBody,
          @JsonKey(name: 'picture') required final String picture,
          final dynamic timestamp,
          @JsonKey(name: 'created_date') final String? createdDate,
          @JsonKey(name: 'modified_date') final String? modifiedDate}) =
      _$CommentImpl;
  const _Comment._() : super._();

  factory _Comment.fromJson(Map<String, dynamic> json) = _$CommentImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'livestream_id')
  String get livestreamId;
  @override
  @JsonKey(name: 'uid')
  String get userUid;
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
  @JsonKey(name: 'comment_body')
  String get commentBody;
  @override
  @JsonKey(name: 'picture')
  String get picture;
  @override
  dynamic get timestamp;
  @override
  @JsonKey(name: 'created_date')
  String? get createdDate;
  @override
  @JsonKey(name: 'modified_date')
  String? get modifiedDate;
  @override
  @JsonKey(ignore: true)
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
