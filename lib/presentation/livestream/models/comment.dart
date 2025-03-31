import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
abstract class Comment implements _$Comment {
  const Comment._();
  const factory Comment({
    String? id,
    @JsonKey(name: 'livestream_id') required String livestreamId,
    @JsonKey(name: 'uid') required String userUid,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'allow_conversations') required String allowConversations,
    @JsonKey(name: 'comment_body') required String commentBody,
    @JsonKey(name: 'picture') required String picture,
    dynamic timestamp,
    @JsonKey(name: 'created_date') String? createdDate,
    @JsonKey(name: 'modified_date') String? modifiedDate,
  }) = _Comment;

  factory Comment.fromJson(Map<String, Object?> json) => _$CommentFromJson(json);

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data()! as Map<String, dynamic>;
    return Comment.fromJson(data).copyWith(id: documentSnapshot.id);
  }

  Map<String, dynamic> toDocument() => toJson();
}
