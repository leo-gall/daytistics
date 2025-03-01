import 'dart:io';

import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/providers/state/current_conversation/current_conversation.dart';
import 'package:daytistics/shared/widgets/application/prompt_input_field.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/chat/widgets/llm_chat_message.dart';
import 'package:daytistics/ui/chat/widgets/user_chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final List<ConversationMessage> messages =
        ref.watch(currentConversationProvider)?.messages ?? [];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: StyledText(
          ref.read(currentConversationProvider)?.title ?? 'Chat',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: Platform.isIOS
              ? const Icon(Icons.arrow_back_ios)
              : const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            ref
                .read(currentConversationProvider.notifier)
                .setConversation(null);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.all_inbox_outlined),
            onPressed: () async =>
                Navigator.pushNamed(context, '/conversations-list'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  // sample message on the right
                  for (final ConversationMessage message in messages) ...[
                    UserChatMessage(
                      message.query,
                    ),
                    LLMChatMessage(
                      message,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // adds a shadow to the input field
          PromptInputField(
            onChat: (query, reply) async {
              // scroll to the bottom of the list
              await _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
        ],
      ),
    );
  }
}
