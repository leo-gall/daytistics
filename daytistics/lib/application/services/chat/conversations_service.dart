import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/providers/current_conversation/current_conversation.dart';
import 'package:daytistics/application/repositories/conversations/conversations_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'conversations_service.g.dart';

class ConversationsServiceState {}

@Riverpod(keepAlive: true)
class ConversationsService extends _$ConversationsService {
  @override
  ConversationsServiceState build() {
    return ConversationsServiceState();
  }

  Future<String> sendMessage(String query) async {
    final ConversationsRepository conversationsRepository =
        ref.read(conversationsRepositoryProvider);

    final reply = await Supabase.instance.client.functions
        .invoke('conversation', body: {'query': query});

    final title = RegExp('<title>(.*?)</title>', dotAll: true)
        .firstMatch(reply.data.toString())
        ?.group(1);

    final String processedReply = reply.data.toString().replaceAll(
          RegExp('<title>.*?</title>'),
          '',
        );

    ref.read(currentConversationProvider.notifier).updateTitle(title);

    ref.read(currentConversationProvider.notifier).addMessage(
          ConversationMessage(
            conversationId: ref.read(currentConversationProvider)!.id,
            query: query,
            reply: processedReply,
          ),
        );

    if (!await conversationsRepository.existsConversation(
      ref.read(currentConversationProvider)!,
    )) {
      await conversationsRepository.insertConversation(
        ref.read(currentConversationProvider)!,
      );
    }

    await conversationsRepository.insertMessage(
      ConversationMessage(
        query: query,
        reply: processedReply,
        conversationId: ref.read(currentConversationProvider)!.id,
      ),
    );

    return processedReply;
  }

  Future<List<Conversation>> fetchConversations({
    required int start,
    int? amount,
  }) async {
    final conversations =
        await ref.read(conversationsRepositoryProvider).fetchConversations(
              start: start,
              amount: amount,
            );

    for (final conversation in conversations) {
      final List<ConversationMessage> messages = await ref
          .read(conversationsRepositoryProvider)
          .fetchMessages(conversation.id);

      conversation.messages = messages;
    }

    return conversations;
  }

  Future<void> toggleUpvote(ConversationMessage message) async {
    final updatedMessage = message.copyWith(
      upvoted: true,
    );

    ref.read(currentConversationProvider.notifier).updateMessage(
          updatedMessage,
        );

    await ref
        .read(conversationsRepositoryProvider)
        .updateMessage(updatedMessage);
  }

  Future<void> toggleDownvote(ConversationMessage message) async {
    final updatedMessage = message.copyWith(
      downvoted: true,
    );

    ref.read(currentConversationProvider.notifier).updateMessage(
          updatedMessage,
        );

    await ref
        .read(conversationsRepositoryProvider)
        .updateMessage(updatedMessage);
  }

  Future<void> deleteConversation(Conversation conversation) async {
    await ref
        .read(conversationsRepositoryProvider)
        .deleteConversation(conversation);

    final Conversation? currentConversation =
        ref.read(currentConversationProvider);

    if (currentConversation != null) {
      if (currentConversation.id == conversation.id) {
        ref.read(currentConversationProvider.notifier).clear();
      }
    }

    for (final message in conversation.messages) {
      await ref.read(conversationsRepositoryProvider).deleteMessage(message);
    }
  }
}
