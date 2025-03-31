// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String?,
      conversationId: json['conversation'] as String,
      text: json['text'] as String,
      recipient: json['recipient'] as String,
      sender: json['sender'] as String,
      recipientName: json['recipientName'] as String,
      senderName: json['senderName'] as String,
      timestamp: json['timestamp'] as String,
      timeZone: json['timeZone'] as String,
      firebaseTimestamp: json['firebaseTimestamp'],
      image: json['image'] as String?,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation': instance.conversationId,
      'text': instance.text,
      'recipient': instance.recipient,
      'sender': instance.sender,
      'recipientName': instance.recipientName,
      'senderName': instance.senderName,
      'timestamp': instance.timestamp,
      'timeZone': instance.timeZone,
      'firebaseTimestamp': instance.firebaseTimestamp,
      'image': instance.image,
    };
