import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/presentation/messaging/models/message.dart';

import '../repositories/message_repository.dart';

class MessagesNotifier extends AsyncNotifier<List<Message>> {
  @override
  FutureOr<List<Message>> build() {
    return [];
  }

  Future<void> fetchMessagesForConversation(String conversationId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final List<Message> messages = await ref
          .read(messageRepository)
          .getMessagesForConversation(conversationId);
      return messages;
    });
  }

  Future<void> sendMessage({
    required String sender,
    required String recipient,
    required String conversationId,
    required String senderName,
    required String recipientName,
    required String text,
    required String timestamp,
    String? image,
  }) async {
    await ref.read(messageRepository).sendMessage(
          sender: sender,
          recipient: recipient,
          conversationId: conversationId,
          senderName: senderName,
          recipientName: recipientName,
          text: text,
          timestamp: timestamp,
          image: image
        );
  }
}

final asyncMessagesProvider =
    AsyncNotifierProvider<MessagesNotifier, List<Message>>(() {
  return MessagesNotifier();
});
