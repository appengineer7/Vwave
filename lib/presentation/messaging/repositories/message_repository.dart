import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/common/providers/firebase.dart';
import 'package:vwave/presentation/auth/repositories/auth_repository.dart';
import 'package:vwave/presentation/messaging/models/message.dart';
import 'package:vwave/utils/exceptions.dart';
import 'package:vwave/utils/storage.dart';

import '../../../utils/general.dart';
import '../models/conversation.dart';

abstract class BaseMessageRepository {
  Future<List<Conversation>> getConversationsForUser();
  Future<Conversation> createOrGetConversation(
    String userId,
    String participantId,
    String userName,
    String participantName,
    String participantImage,
  );
  Future<List<Message>> getMessagesForConversation(String conversationId);
  Future<void> sendMessage({
    required String sender,
    required String recipient,
    required String senderName,
    required String recipientName,
    required String conversationId,
    required String text,
    required String timestamp,
    String? image,
  });

  Future<void> setLatestMessage(
    String conversationId,
    String text,
    DateTime createdAt,
  );
}

class MessageRepository implements BaseMessageRepository {
  final Ref ref;

  const MessageRepository(this.ref);
  @override
  Future<List<Conversation>> getConversationsForUser() async {
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    try {
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('conversations')
          .where("participants", arrayContains: user!.uid)
          .orderBy("latest_message_time", descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Conversation.fromDocument(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<Conversation> createOrGetConversation(
    String userId,
    String participantId,
    String userName,
    String participantName,
    String participantImage,
  ) async {
    // find conversation with participants

    String docId;

    final conversationsRef =
        ref.read(firebaseFirestoreProvider).collection('conversations');

    try {
      StorageSystem ss = StorageSystem();
      String userImage = "";
      String? user = await ss.getItem("user");
      if(user != null) {
        Map<String, dynamic> userData = jsonDecode(user);
        userImage = userData["picture"] ?? "";
      }
      // conversationsRef.where(
      //   "participants",
      //   arrayContains: userId,
      // );
      //
      // conversationsRef.where(
      //   "participants",
      //   arrayContains: participantId,
      // );
      //
      // conversationsRef.limit(1);

      final snapshot = await conversationsRef.where(Filter.or(
          Filter("unique_identifier", isEqualTo: "$userId/$participantId"),
          Filter("unique_identifier", isEqualTo: "$participantId/$userId")))
          .limit(1).get();

      // print(snapshot.docs);
      // .where(
      //         "unique_identifier",
      //         isEqualTo: "$userId/$participantId",
      //       )

      if (snapshot.docs.isEmpty) {
        final key = conversationsRef.doc().id;
        final newConversation = Conversation(
          id: key,
          latestMessage: "",
          latestMessageTime: FieldValue.serverTimestamp(),
          participantNames: [userName, participantName],
          participants: [userId, participantId],
          participantImages: [userImage, participantImage],
          participantTimeZone: 'America/Chicago',
          unreadCounts: 0,
          latestMessageSender: userId,
            uniqueIdentifier: "$userId/$participantId",
          conversationBlockedByUid: "",
          isConversationBlocked: false,
          participantsUserData: {
            userId: {
              "profile_picture": userImage,
              "username": userName,
              "time_zone": ""
            },
            participantId: {
              "profile_picture": participantImage,
              "username": participantName,
              "time_zone": ""
            }
          }
        );

        final toDoc = newConversation.toDocument();
        final doc = await conversationsRef.doc(key).set(toDoc);

        print("this is when it does not exist");
        // print(doc.id);

        docId = key; //doc.id;

        // await conversationsRef.doc(doc.id).update({'id': doc.id});

        // return doc.id;
      } else {
        // print("this is when it does exists");
        // print(snapshot.docs[0].id);
        docId = snapshot.docs[0].id;
        final data = snapshot.docs[0].data();
        List<dynamic> participants = data["participants"];
        if(participants.length <= 1) {
          await ref.read(firebaseFirestoreProvider).collection('conversations').doc(docId).update(
              {
                "participants": [userId, participantId],
                "participant_names": [userName, participantName],
                "participant_images": [userImage, participantImage],
                "participants_userdata": {
                  userId: {
                    "profile_picture": userImage,
                    "username": userName,
                    "time_zone": ""
                  },
                  participantId: {
                    "profile_picture": participantImage,
                    "username": participantName,
                    "time_zone": ""
                  }
                },
              });
        }
      }

      print("=====");
      print(docId);

      final docRef = await conversationsRef.doc(docId).get();

      return Conversation.fromDocument(docRef);
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }

    // if it doesn't exist, create one
  }

  @override
  Future<List<Message>> getMessagesForConversation(
      String conversationId) async {
    try {
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('messages')
          .where("conversationId", isEqualTo: conversationId)
          .get();

      return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> sendMessage({
    required String sender,
    required String recipient,
    required String senderName,
    required String recipientName,
    required String conversationId,
    required String text,
    required String timestamp,
    String? image,
  }) async {
    String key = ref.read(firebaseFirestoreProvider).collection('messages').doc().id;
    String timeZone = await GeneralUtils().currentTimeZone();
    final newMessage = Message(
      id: key,
      conversationId: conversationId,
      text: text,
      timestamp: timestamp,
      sender: sender,
      senderName: senderName,
      recipient: recipient,
      recipientName: recipientName,
      image: image,
      firebaseTimestamp: FieldValue.serverTimestamp(),
      timeZone: timeZone,
    );

    final toDoc = newMessage.toDocument();

    await ref.read(firebaseFirestoreProvider).collection('messages').doc(key).set({
      ...toDoc,
      "timestamp": Timestamp.fromDate(DateTime.parse(timestamp)),
    });
  }

  @override
  Future<void> setLatestMessage(
      String conversationId, String text, DateTime createdAt) async {
    final conversationsRef =
        ref.read(firebaseFirestoreProvider).collection('conversations');

    return await conversationsRef
        .doc(conversationId)
        .update({'latest_message': text, 'latest_message_time': '$createdAt'});
  }

  // @override
  // Stream<QuerySnapshot> getMessageStream(
  //   String conversationId,
  // ) {
  //   try {
  //     final snapshot = ref
  //         .read(firebaseFirestoreProvider)
  //         .collection('messages')
  //         .where("conversationId", isEqualTo: conversationId)
  //         .orderBy('timestamp', descending: false);

  //     return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
  //   } on FirebaseException catch (e) {
  //     throw CustomException(message: e.message);
  //   }
  // }
}

final messageRepository = Provider<MessageRepository>(
  (ref) => MessageRepository(ref),
);
