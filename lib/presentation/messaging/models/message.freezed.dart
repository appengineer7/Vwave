// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'conversation')
  String get conversationId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get recipient => throw _privateConstructorUsedError;
  String get sender => throw _privateConstructorUsedError;
  String get recipientName => throw _privateConstructorUsedError;
  String get senderName => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;
  String get timeZone => throw _privateConstructorUsedError;
  dynamic get firebaseTimestamp => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'conversation') String conversationId,
      String text,
      String recipient,
      String sender,
      String recipientName,
      String senderName,
      String timestamp,
      String timeZone,
      dynamic firebaseTimestamp,
      String? image});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? conversationId = null,
    Object? text = null,
    Object? recipient = null,
    Object? sender = null,
    Object? recipientName = null,
    Object? senderName = null,
    Object? timestamp = null,
    Object? timeZone = null,
    Object? firebaseTimestamp = freezed,
    Object? image = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      recipient: null == recipient
          ? _value.recipient
          : recipient // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      recipientName: null == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: null == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      timeZone: null == timeZone
          ? _value.timeZone
          : timeZone // ignore: cast_nullable_to_non_nullable
              as String,
      firebaseTimestamp: freezed == firebaseTimestamp
          ? _value.firebaseTimestamp
          : firebaseTimestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'conversation') String conversationId,
      String text,
      String recipient,
      String sender,
      String recipientName,
      String senderName,
      String timestamp,
      String timeZone,
      dynamic firebaseTimestamp,
      String? image});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? conversationId = null,
    Object? text = null,
    Object? recipient = null,
    Object? sender = null,
    Object? recipientName = null,
    Object? senderName = null,
    Object? timestamp = null,
    Object? timeZone = null,
    Object? firebaseTimestamp = freezed,
    Object? image = freezed,
  }) {
    return _then(_$MessageImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      recipient: null == recipient
          ? _value.recipient
          : recipient // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      recipientName: null == recipientName
          ? _value.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: null == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      timeZone: null == timeZone
          ? _value.timeZone
          : timeZone // ignore: cast_nullable_to_non_nullable
              as String,
      firebaseTimestamp: freezed == firebaseTimestamp
          ? _value.firebaseTimestamp
          : firebaseTimestamp // ignore: cast_nullable_to_non_nullable
              as dynamic,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl extends _Message {
  const _$MessageImpl(
      {this.id,
      @JsonKey(name: 'conversation') required this.conversationId,
      required this.text,
      required this.recipient,
      required this.sender,
      required this.recipientName,
      required this.senderName,
      required this.timestamp,
      required this.timeZone,
      required this.firebaseTimestamp,
      this.image})
      : super._();

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'conversation')
  final String conversationId;
  @override
  final String text;
  @override
  final String recipient;
  @override
  final String sender;
  @override
  final String recipientName;
  @override
  final String senderName;
  @override
  final String timestamp;
  @override
  final String timeZone;
  @override
  final dynamic firebaseTimestamp;
  @override
  final String? image;

  @override
  String toString() {
    return 'Message(id: $id, conversationId: $conversationId, text: $text, recipient: $recipient, sender: $sender, recipientName: $recipientName, senderName: $senderName, timestamp: $timestamp, timeZone: $timeZone, firebaseTimestamp: $firebaseTimestamp, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.recipient, recipient) ||
                other.recipient == recipient) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.timeZone, timeZone) ||
                other.timeZone == timeZone) &&
            const DeepCollectionEquality()
                .equals(other.firebaseTimestamp, firebaseTimestamp) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      conversationId,
      text,
      recipient,
      sender,
      recipientName,
      senderName,
      timestamp,
      timeZone,
      const DeepCollectionEquality().hash(firebaseTimestamp),
      image);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message extends Message {
  const factory _Message(
      {final String? id,
      @JsonKey(name: 'conversation') required final String conversationId,
      required final String text,
      required final String recipient,
      required final String sender,
      required final String recipientName,
      required final String senderName,
      required final String timestamp,
      required final String timeZone,
      required final dynamic firebaseTimestamp,
      final String? image}) = _$MessageImpl;
  const _Message._() : super._();

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'conversation')
  String get conversationId;
  @override
  String get text;
  @override
  String get recipient;
  @override
  String get sender;
  @override
  String get recipientName;
  @override
  String get senderName;
  @override
  String get timestamp;
  @override
  String get timeZone;
  @override
  dynamic get firebaseTimestamp;
  @override
  String? get image;
  @override
  @JsonKey(ignore: true)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
