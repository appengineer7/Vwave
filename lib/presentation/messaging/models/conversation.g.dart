// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String?,
      uniqueIdentifier: json['unique_identifier'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      participantNames: (json['participant_names'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      participantImages: (json['participant_images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      participantTimeZone: json['participant_time_zone'] as String,
      unreadCounts: json['unread_counts'] as int,
      latestMessage: json['latest_message'] as String,
      latestMessageTime: json['latest_message_time'],
      latestMessageSender: json['latest_message_sender'] as String,
      isConversationBlocked: json['is_conversation_blocked'] as bool?,
      participantsUserData:
          json['participants_userdata'] as Map<String, dynamic>,
      conversationBlockedByUid: json['conversation_blocked_by_uid'] as String?,
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unique_identifier': instance.uniqueIdentifier,
      'participants': instance.participants,
      'participant_names': instance.participantNames,
      'participant_images': instance.participantImages,
      'participant_time_zone': instance.participantTimeZone,
      'unread_counts': instance.unreadCounts,
      'latest_message': instance.latestMessage,
      'latest_message_time': instance.latestMessageTime,
      'latest_message_sender': instance.latestMessageSender,
      'is_conversation_blocked': instance.isConversationBlocked,
      'participants_userdata': instance.participantsUserData,
      'conversation_blocked_by_uid': instance.conversationBlockedByUid,
    };
