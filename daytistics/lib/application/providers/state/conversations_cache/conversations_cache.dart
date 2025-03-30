import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/providers/services/conversations/conversations_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversations_cache.g.dart';

@Riverpod(keepAlive: true)
class ConversationsCache extends _$ConversationsCache {
  @override
  Future<List<Conversation>> build() async {
    final conversations = await ref
        .read(conversationsServiceProvider)
        .fetchConversations(offset: 0, amount: 20);

    return conversations;
  }

  void addConversations(List<Conversation> conversations) {
    final currentState = state.value ?? [];
    state = AsyncValue.data([
      ...currentState,
      ...conversations.where(
        (conversation) =>
            !currentState.any((existing) => existing.id == conversation.id),
      ),
    ]);
  }
}
