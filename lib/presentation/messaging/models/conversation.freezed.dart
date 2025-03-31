// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return _Conversation.fromJson(json);
}

/// @nodoc
mixin _$Conversation {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'unique_identifier')
  String get uniqueIdentifier => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  @JsonKey(name: 'participant_names')
  List<String> get participantNames => throw _privateConstructorUsedError;
  @JsonKey(name: 'participant_images')
  List<String> get participantImages => throw _privateConstructorUsedError;
  @JsonKey(name: 'participant_time_zone')
  String get participantTimeZone => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_counts')
  int get unreadCounts => throw _privateConstructorUsedError;
  @JsonKey(name: 'latest_message')
  String get latestMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'latest_message_time')
  dynamic get latestMessageTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'latest_message_sender')
  String get latestMessageSender => throw _privateConstructorUsedError; //sentBy
  @JsonKey(name: 'is_conversation_blocked')
  bool? get isConversationBlocked =>
      throw _privateConstructorUsedError; //sentBy
  @JsonKey(name: 'participants_userdata')
  Map<String, dynamic> get participantsUserData =>
      throw _privateConstructorUsedError; //sentBy
  @JsonKey(name: 'conversation_blocked_by_uid')
  String? get conversationBlockedByUid => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
          Conversation value, $Res Function(Conversation) then) =
      _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'unique_identifier') String uniqueIdentifier,
      List<String> participants,
      @JsonKey(name: 'participant_names') List<String> participantNames,
      @JsonKey(name: 'participant_images') List<String> participantImages,
      @JsonKey(name: 'participant_time_zone') String participantTimeZone,
      @JsonKey(name: 'unread_counts') int unreadCounts,
      @JsonKey(name: 'latest_message') String latestMessage,
      @JsonKey(name: 'latest_message_time') dynamic latestMessageTime,
      @JsonKey(name: 'latest_message_sender') String latestMessageSender,
      @JsonKey(name: 'is_conversation_blocked') bool? isConversationBlocked,
      @JsonKey(name: 'participants_userdata')
      Map<String, dynamic> participantsUserData,
      @JsonKey(name: 'conversation_blocked_by_uid')
      String? conversationBlockedByUid});
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? uniqueIdentifier = null,
    Object? participants = null,
    Object? participantNames = null,
    Object? participantImages = null,
    Object? participantTimeZone = null,
    Object? unreadCounts = null,
    Object? latestMessage = null,
    Object? latestMessageTime = freezed,
    Object? latestMessageSender = null,
    Object? isConversationBlocked = freezed,
    Object? participantsUserData = null,
    Object? conversationBlockedByUid = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      uniqueIdentifier: null == uniqueIdentifier
          ? _value.uniqueIdentifier
          : uniqueIdentifier // ignore: cast_nullable_to_non_nullable
              as String,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantNames: null == participantNames
          ? _value.participantNames
          : participantNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantImages: null == participantImages
          ? _value.participantImages
          : participantImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantTimeZone: null == participantTimeZone
          ? _value.participantTimeZone
          : participantTimeZone // ignore: cast_nullable_to_non_nullable
              as String,
      unreadCounts: null == unreadCounts
          ? _value.unreadCounts
          : unreadCounts // ignore: cast_nullable_to_non_nullable
              as int,
      latestMessage: null == latestMessage
          ? _value.latestMessage
          : latestMessage // ignore: cast_nullable_to_non_nullable
              as String,
      latestMessageTime: freezed == latestMessageTime
          ? _value.latestMessageTime
          : latestMessageTime // ignore: cast_nullable_to_non_nullable
              as dynamic,
      latestMessageSender: null == latestMessageSender
          ? _value.latestMessageSender
          : latestMessageSender // ignore: cast_nullable_to_non_nullable
              as String,
      isConversationBlocked: freezed == isConversationBlocked
          ? _value.isConversationBlocked
          : isConversationBlocked // ignore: cast_nullable_to_non_nullable
              as bool?,
      participantsUserData: null == participantsUserData
          ? _value.participantsUserData
          : participantsUserData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      conversationBlockedByUid: freezed == conversationBlockedByUid
          ? _value.conversationBlockedByUid
          : conversationBlockedByUid // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
          _$ConversationImpl value, $Res Function(_$ConversationImpl) then) =
      __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'unique_identifier') String uniqueIdentifier,
      List<String> participants,
      @JsonKey(name: 'participant_names') List<String> participantNames,
      @JsonKey(name: 'participant_images') List<String> participantImages,
      @JsonKey(name: 'participant_time_zone') String participantTimeZone,
      @JsonKey(name: 'unread_counts') int unreadCounts,
      @JsonKey(name: 'latest_message') String latestMessage,
      @JsonKey(name: 'latest_message_time') dynamic latestMessageTime,
      @JsonKey(name: 'latest_message_sender') String latestMessageSender,
      @JsonKey(name: 'is_conversation_blocked') bool? isConversationBlocked,
      @JsonKey(name: 'participants_userdata')
      Map<String, dynamic> participantsUserData,
      @JsonKey(name: 'conversation_blocked_by_uid')
      String? conversationBlockedByUid});
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
      _$ConversationImpl _value, $Res Function(_$ConversationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? uniqueIdentifier = null,
    Object? participants = null,
    Object? participantNames = null,
    Object? participantImages = null,
    Object? participantTimeZone = null,
    Object? unreadCounts = null,
    Object? latestMessage = null,
    Object? latestMessageTime = freezed,
    Object? latestMessageSender = null,
    Object? isConversationBlocked = freezed,
    Object? participantsUserData = null,
    Object? conversationBlockedByUid = freezed,
  }) {
    return _then(_$ConversationImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      uniqueIdentifier: null == uniqueIdentifier
          ? _value.uniqueIdentifier
          : uniqueIdentifier // ignore: cast_nullable_to_non_nullable
              as String,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantNames: null == participantNames
          ? _value._participantNames
          : participantNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantImages: null == participantImages
          ? _value._participantImages
          : participantImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantTimeZone: null == participantTimeZone
          ? _value.participantTimeZone
          : participantTimeZone // ignore: cast_nullable_to_non_nullable
              as String,
      unreadCounts: null == unreadCounts
          ? _value.unreadCounts
          : unreadCounts // ignore: cast_nullable_to_non_nullable
              as int,
      latestMessage: null == latestMessage
          ? _value.latestMessage
          : latestMessage // ignore: cast_nullable_to_non_nullable
              as String,
      latestMessageTime: freezed == latestMessageTime
          ? _value.latestMessageTime
          : latestMessageTime // ignore: cast_nullable_to_non_nullable
              as dynamic,
      latestMessageSender: null == latestMessageSender
          ? _value.latestMessageSender
          : latestMessageSender // ignore: cast_nullable_to_non_nullable
              as String,
      isConversationBlocked: freezed == isConversationBlocked
          ? _value.isConversationBlocked
          : isConversationBlocked // ignore: cast_nullable_to_non_nullable
              as bool?,
      participantsUserData: null == participantsUserData
          ? _value._participantsUserData
          : participantsUserData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      conversationBlockedByUid: freezed == conversationBlockedByUid
          ? _value.conversationBlockedByUid
          : conversationBlockedByUid // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationImpl extends _Conversation {
  const _$ConversationImpl(
      {this.id,
      @JsonKey(name: 'unique_identifier') required this.uniqueIdentifier,
      required final List<String> participants,
      @JsonKey(name: 'participant_names')
      required final List<String> participantNames,
      @JsonKey(name: 'participant_images')
      required final List<String> participantImages,
      @JsonKey(name: 'participant_time_zone') required this.participantTimeZone,
      @JsonKey(name: 'unread_counts') required this.unreadCounts,
      @JsonKey(name: 'latest_message') required this.latestMessage,
      @JsonKey(name: 'latest_message_time') required this.latestMessageTime,
      @JsonKey(name: 'latest_message_sender') required this.latestMessageSender,
      @JsonKey(name: 'is_conversation_blocked') this.isConversationBlocked,
      @JsonKey(name: 'participants_userdata')
      required final Map<String, dynamic> participantsUserData,
      @JsonKey(name: 'conversation_blocked_by_uid')
      this.conversationBlockedByUid})
      : _participants = participants,
        _participantNames = participantNames,
        _participantImages = participantImages,
        _participantsUserData = participantsUserData,
        super._();

  factory _$ConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'unique_identifier')
  final String uniqueIdentifier;
  final List<String> _participants;
  @override
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  final List<String> _participantNames;
  @override
  @JsonKey(name: 'participant_names')
  List<String> get participantNames {
    if (_participantNames is EqualUnmodifiableListView)
      return _participantNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantNames);
  }

  final List<String> _participantImages;
  @override
  @JsonKey(name: 'participant_images')
  List<String> get participantImages {
    if (_participantImages is EqualUnmodifiableListView)
      return _participantImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantImages);
  }

  @override
  @JsonKey(name: 'participant_time_zone')
  final String participantTimeZone;
  @override
  @JsonKey(name: 'unread_counts')
  final int unreadCounts;
  @override
  @JsonKey(name: 'latest_message')
  final String latestMessage;
  @override
  @JsonKey(name: 'latest_message_time')
  final dynamic latestMessageTime;
  @override
  @JsonKey(name: 'latest_message_sender')
  final String latestMessageSender;
//sentBy
  @override
  @JsonKey(name: 'is_conversation_blocked')
  final bool? isConversationBlocked;
//sentBy
  final Map<String, dynamic> _participantsUserData;
//sentBy
  @override
  @JsonKey(name: 'participants_userdata')
  Map<String, dynamic> get participantsUserData {
    if (_participantsUserData is EqualUnmodifiableMapView)
      return _participantsUserData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_participantsUserData);
  }

//sentBy
  @override
  @JsonKey(name: 'conversation_blocked_by_uid')
  final String? conversationBlockedByUid;

  @override
  String toString() {
    return 'Conversation(id: $id, uniqueIdentifier: $uniqueIdentifier, participants: $participants, participantNames: $participantNames, participantImages: $participantImages, participantTimeZone: $participantTimeZone, unreadCounts: $unreadCounts, latestMessage: $latestMessage, latestMessageTime: $latestMessageTime, latestMessageSender: $latestMessageSender, isConversationBlocked: $isConversationBlocked, participantsUserData: $participantsUserData, conversationBlockedByUid: $conversationBlockedByUid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uniqueIdentifier, uniqueIdentifier) ||
                other.uniqueIdentifier == uniqueIdentifier) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            const DeepCollectionEquality()
                .equals(other._participantNames, _participantNames) &&
            const DeepCollectionEquality()
                .equals(other._participantImages, _participantImages) &&
            (identical(other.participantTimeZone, participantTimeZone) ||
                other.participantTimeZone == participantTimeZone) &&
            (identical(other.unreadCounts, unreadCounts) ||
                other.unreadCounts == unreadCounts) &&
            (identical(other.latestMessage, latestMessage) ||
                other.latestMessage == latestMessage) &&
            const DeepCollectionEquality()
                .equals(other.latestMessageTime, latestMessageTime) &&
            (identical(other.latestMessageSender, latestMessageSender) ||
                other.latestMessageSender == latestMessageSender) &&
            (identical(other.isConversationBlocked, isConversationBlocked) ||
                other.isConversationBlocked == isConversationBlocked) &&
            const DeepCollectionEquality()
                .equals(other._participantsUserData, _participantsUserData) &&
            (identical(
                    other.conversationBlockedByUid, conversationBlockedByUid) ||
                other.conversationBlockedByUid == conversationBlockedByUid));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      uniqueIdentifier,
      const DeepCollectionEquality().hash(_participants),
      const DeepCollectionEquality().hash(_participantNames),
      const DeepCollectionEquality().hash(_participantImages),
      participantTimeZone,
      unreadCounts,
      latestMessage,
      const DeepCollectionEquality().hash(latestMessageTime),
      latestMessageSender,
      isConversationBlocked,
      const DeepCollectionEquality().hash(_participantsUserData),
      conversationBlockedByUid);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationImplToJson(
      this,
    );
  }
}

abstract class _Conversation extends Conversation {
  const factory _Conversation(
      {final String? id,
      @JsonKey(name: 'unique_identifier')
      required final String uniqueIdentifier,
      required final List<String> participants,
      @JsonKey(name: 'participant_names')
      required final List<String> participantNames,
      @JsonKey(name: 'participant_images')
      required final List<String> participantImages,
      @JsonKey(name: 'participant_time_zone')
      required final String participantTimeZone,
      @JsonKey(name: 'unread_counts') required final int unreadCounts,
      @JsonKey(name: 'latest_message') required final String latestMessage,
      @JsonKey(name: 'latest_message_time')
      required final dynamic latestMessageTime,
      @JsonKey(name: 'latest_message_sender')
      required final String latestMessageSender,
      @JsonKey(name: 'is_conversation_blocked')
      final bool? isConversationBlocked,
      @JsonKey(name: 'participants_userdata')
      required final Map<String, dynamic> participantsUserData,
      @JsonKey(name: 'conversation_blocked_by_uid')
      final String? conversationBlockedByUid}) = _$ConversationImpl;
  const _Conversation._() : super._();

  factory _Conversation.fromJson(Map<String, dynamic> json) =
      _$ConversationImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'unique_identifier')
  String get uniqueIdentifier;
  @override
  List<String> get participants;
  @override
  @JsonKey(name: 'participant_names')
  List<String> get participantNames;
  @override
  @JsonKey(name: 'participant_images')
  List<String> get participantImages;
  @override
  @JsonKey(name: 'participant_time_zone')
  String get participantTimeZone;
  @override
  @JsonKey(name: 'unread_counts')
  int get unreadCounts;
  @override
  @JsonKey(name: 'latest_message')
  String get latestMessage;
  @override
  @JsonKey(name: 'latest_message_time')
  dynamic get latestMessageTime;
  @override
  @JsonKey(name: 'latest_message_sender')
  String get latestMessageSender;
  @override //sentBy
  @JsonKey(name: 'is_conversation_blocked')
  bool? get isConversationBlocked;
  @override //sentBy
  @JsonKey(name: 'participants_userdata')
  Map<String, dynamic> get participantsUserData;
  @override //sentBy
  @JsonKey(name: 'conversation_blocked_by_uid')
  String? get conversationBlockedByUid;
  @override
  @JsonKey(ignore: true)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
