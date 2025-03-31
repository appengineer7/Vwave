// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as String?,
      livestreamId: json['livestream_id'] as String,
      userUid: json['uid'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      allowConversations: json['allow_conversations'] as String,
      commentBody: json['comment_body'] as String,
      picture: json['picture'] as String,
      timestamp: json['timestamp'],
      createdDate: json['created_date'] as String?,
      modifiedDate: json['modified_date'] as String?,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'livestream_id': instance.livestreamId,
      'uid': instance.userUid,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'allow_conversations': instance.allowConversations,
      'comment_body': instance.commentBody,
      'picture': instance.picture,
      'timestamp': instance.timestamp,
      'created_date': instance.createdDate,
      'modified_date': instance.modifiedDate,
    };
