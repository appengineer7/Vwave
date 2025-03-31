import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/presentation/messaging/models/conversation.dart';

import '../repositories/message_repository.dart';

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() {
    return fetchConversationsForUser();
  }

  Future<List<Conversation>> fetchConversationsForUser() async {
    final List<Conversation> conversations =
        await ref.read(messageRepository).getConversationsForUser();
    return conversations;
  }

  Future<void> setLatestMessage(
      String conversationId, String text, DateTime createdAt) async {
    await ref
        .read(messageRepository)
        .setLatestMessage(conversationId, text, createdAt);
  }
}

final asyncConversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(() {
  return ConversationsNotifier();
});
