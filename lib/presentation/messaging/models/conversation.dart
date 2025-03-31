import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
abstract class Conversation implements _$Conversation {
  const Conversation._();
  const factory Conversation({
    String? id,
    @JsonKey(name: 'unique_identifier')required String uniqueIdentifier,
    required List<String> participants,
    @JsonKey(name: 'participant_names') required List<String> participantNames,
    @JsonKey(name: 'participant_images') required List<String> participantImages,
    @JsonKey(name: 'participant_time_zone') required String participantTimeZone,
    @JsonKey(name: 'unread_counts') required int unreadCounts,
    @JsonKey(name: 'latest_message') required String latestMessage,
    @JsonKey(name: 'latest_message_time') required dynamic latestMessageTime,
    @JsonKey(name: 'latest_message_sender') required String latestMessageSender, //sentBy
    @JsonKey(name: 'is_conversation_blocked') bool? isConversationBlocked, //sentBy
    @JsonKey(name: 'participants_userdata') required Map<String, dynamic> participantsUserData, //sentBy
    @JsonKey(name: 'conversation_blocked_by_uid') String? conversationBlockedByUid, //sentBy
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, Object?> json) =>
      _$ConversationFromJson(json);

  factory Conversation.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;
    return Conversation.fromJson(data).copyWith(id: documentSnapshot.id);
  }

  Map<String, dynamic> toDocument() => toJson()..remove(id);
}
