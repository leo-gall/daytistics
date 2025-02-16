import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LLMChatMessage extends ConsumerWidget {
  final ConversationMessage message;

  const LLMChatMessage(this.message, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Column(
                    children: [
                      StyledText(
                        message.reply,
                        style: const TextStyle(color: ColorSettings.textDark),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     IconButton(
                      //       icon: Icon(
                      //         Icons.thumb_up,
                      //         color: message.upvoted
                      //             ? ColorSettings.primary
                      //             : ColorSettings.textDark,
                      //         size: 20,
                      //       ),
                      //       onPressed: () => ref
                      //           .read(conversationsServiceProvider.notifier)
                      //           .toggleUpvote(message),
                      //     ),
                      //     IconButton(
                      //       icon: const Icon(
                      //         Icons.thumb_down,
                      //         color: ColorSettings.textDark,
                      //         size: 20,
                      //       ),
                      //       onPressed: () {},
                      //     ),
                      //     IconButton(
                      //       icon: const Icon(
                      //         Icons.copy,
                      //         color: ColorSettings.textDark,
                      //         size: 20,
                      //       ),
                      //       onPressed: () {},
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
