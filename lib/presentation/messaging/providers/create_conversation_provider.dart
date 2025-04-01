import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/presentation/messaging/models/conversation.dart';

import '../repositories/message_repository.dart';

class CreateConversationProvider extends AsyncNotifier<Conversation?> {
  @override
  FutureOr<Conversation?> build() {
    return null;
  }

  Future<Conversation> createOrGetConversation(
    String userId,
    String participantId,
    String userName,
    String participantName,
    String participantImage,
  ) async {
    final Conversation conversation =
          await ref.read(messageRepository).createOrGetConversation(
                userId,
                participantId,
                userName,
                participantName,
                participantImage,
              );

      return conversation;
    // state = const AsyncValue.loading();
    //
    // state = await AsyncValue.guard(() async {
    //   final Conversation conversation =
    //       await ref.read(messageRepository).createOrGetConversation(
    //             userId,
    //             participantId,
    //             userName,
    //             participantName,
    //             participantImage,
    //           );
    //
    //   return conversation;
    // });
  }
}

final asyncCreateConversationProvider =
    AsyncNotifierProvider<CreateConversationProvider, Conversation?>(() {
  return CreateConversationProvider();
});
