import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/providers/current_conversation/current_conversation.dart';
import 'package:daytistics/application/services/chat/conversations_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ChatListModal extends ConsumerStatefulWidget {
  const ChatListModal({super.key});

  @override
  ConsumerState<ChatListModal> createState() => _ChatListModalState();

  static void showModal(BuildContext context) {
    showMaterialModalBottomSheet<ChatListModal>(
      context: context,
      builder: (context) {
        return const ChatListModal();
      },
    );
  }
}

class _ChatListModalState extends ConsumerState<ChatListModal> {
  final int _pageSize = 10;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<Conversation> _conversations = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMore);
    _fetchInitialConversations();
  }

  Future<void> _fetchInitialConversations() async {
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final conversations = await ref
          .read(conversationsServiceProvider.notifier)
          .fetchConversations(
            start: _currentPage * _pageSize,
            amount: _pageSize,
          );

      setState(() {
        _currentPage++;
        _isLoading = false;
        _conversations.addAll(conversations);
        _hasMore = conversations.length >= _pageSize;
      });

      print('Fetched ${conversations.length} conversations');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  void _loadMore() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _hasMore) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      color: ColorSettings.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: _conversations.isEmpty && !_isLoading
                ? const Center(child: Text('No conversations found'))
                : _buildConversationList(),
          ),
          if (_isLoading) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _conversations.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _conversations.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final conversation = _conversations[index];
        return _buildConversationItem(conversation);
      },
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: ColorSettings.text),
      ),
      onDismissed: (direction) async {
        await ref
            .read(conversationsServiceProvider.notifier)
            .deleteConversation(conversation);
        setState(() => _conversations.remove(conversation));
      },
      child: Card(
        child: ListTile(
          title: conversation.title.length > 30
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      ColorSettings.text,
                      ColorSettings.text.withAlpha(50),
                    ],
                    stops: const [0.7, 1.0],
                  ).createShader(bounds),
                  child: StyledText(
                    '${conversation.title.substring(0, 28)}...',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : StyledText(conversation.title),
          subtitle: StyledText(
            DateFormat('MM/dd/yyyy').format(conversation.updatedAt),
          ),
          trailing: TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(currentConversationProvider.notifier)
                  .setConversation(conversation);
              Navigator.pushNamed(context, '/chat');
            },
            child: const StyledText('View'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
