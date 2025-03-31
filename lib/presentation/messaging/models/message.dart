import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
abstract class Message implements _$Message {
  const Message._();
  const factory Message({
    String? id,
    @JsonKey(name: 'conversation') required String conversationId,
    required String text,
    required String recipient,
    required String sender,
    required String recipientName,
    required String senderName,
    required String timestamp,
    required String timeZone,
    required dynamic firebaseTimestamp,
    String? image,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);

  factory Message.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;
    return Message.fromJson(data).copyWith(id: documentSnapshot.id);
  }

  Map<String, dynamic> toDocument() => toJson()..remove(id);
}
