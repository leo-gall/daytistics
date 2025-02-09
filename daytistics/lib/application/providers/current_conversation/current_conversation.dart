import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_conversation.g.dart';

@Riverpod(keepAlive: true)
class CurrentConversation extends _$CurrentConversation {
  @override
  Conversation? build() {
    return null;
  }

  void setConversation(Conversation? conversation) {
    state = conversation;
  }

  void clear() {
    state = null;
  }

  void addMessage(ConversationMessage message) {
    if (state != null) {
      state = state!.copyWith(messages: [...state!.messages, message]);
    } else {
      state = Conversation();
      final ConversationMessage identifiedMessage = message.copyWith(
        conversationId: state!.id,
      );
      state = state!.copyWith(messages: [identifiedMessage]);
    }
  }

  void updateMessage(ConversationMessage message) {
    if (state != null) {
      final index = state!.messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        state = state!.copyWith(
          messages: [
            ...state!.messages.sublist(0, index),
            message,
            ...state!.messages.sublist(index + 1),
          ],
        );
      }
    }
  }

  void updateTitle(String? title) {
    if (state != null) {
      state = state!.copyWith(title: title);
    } else {
      state = Conversation(title: title);
    }
  }
}
