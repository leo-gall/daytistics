import 'package:daytistics/application/providers/services/conversations/conversations_service.dart';
import 'package:daytistics/application/providers/state/current_conversation/current_conversation.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:daytistics/shared/utils/dialogs.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptInputField extends ConsumerStatefulWidget {
  /// A callback function that is triggered when a chat event occurs.
  ///
  /// The function takes two parameters:
  /// - `String`: User input or message.
  /// - `String`: Response from the chat service.
  ///
  final void Function(String, String)? onChat;

  const PromptInputField({
    super.key,
    this.onChat,
  });

  @override
  ConsumerState<PromptInputField> createState() => _PromptInputFieldState();
}

class _PromptInputFieldState extends ConsumerState<PromptInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.only(
                    left: 10,
                    right: 60,
                    top: 10,
                    bottom: 10,
                  ),
                  hintText: 'What do you want to know about your well-being?',
                  hintStyle: GoogleFonts.figtree(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                ),
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _loading
                      ? Colors.transparent
                      : (_controller.text.isNotEmpty
                          ? ColorSettings.primary
                          : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: IconButton(
                    onPressed: _loading || _controller.text.isEmpty
                        ? null
                        // : () async => _handleSendMessage(),
                        : () async => _handleSubmit(),
                    icon: _loading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorSettings.primary,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (await maybeRedirectToConnectionErrorView(context)) return;
    await _handleSendMessage();
  }

  Future<void> _handleSendMessage() async {
    setState(() {
      _loading = true;
    });
    late String reply;
    try {
      reply = await ref.read(conversationsServiceProvider).sendMessage(
            _controller.text,
            conversation: ref.read(currentConversationProvider),
          );
    } on SupabaseException catch (e) {
      if (mounted) {
        showToast(
          context: context,
          message: e.message,
          type: ToastType.error,
          duration: 3,
        );
      }

      return;
    } finally {
      setState(() {
        _controller.clear();
        _loading = false;
      });
    }

    if (widget.onChat != null) {
      widget.onChat?.call(_controller.text, reply);
    }
  }
}
