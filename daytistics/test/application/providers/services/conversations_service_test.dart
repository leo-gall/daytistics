import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/application/providers/services/conversations/conversations_service.dart';
import 'package:daytistics/application/providers/state/current_conversation/current_conversation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../container.dart';
import '../../../fakes.dart';

void main() {
  late ConversationsService conversationsService;
  late final SupabaseClient mockSupabase;
  late final MockSupabaseHttpClient mockHttpClient;
  late ProviderContainer container;
  late final FakeAnalytics fakeAnalytics;
  late final User mockUser;

  setUpAll(() {
    mockHttpClient = MockSupabaseHttpClient();
    fakeAnalytics = FakeAnalytics();

    mockSupabase = SupabaseClient(
      'https://mock.supabase.co',
      'fakeAnonKey',
      httpClient: mockHttpClient,
    );

    mockUser = User(
      id: 'user-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'aud',
      createdAt: DateTime.now().toIso8601String(),
    );
  });

  setUp(() {
    container = createContainer(
      overrides: [
        supabaseClientDependencyProvider.overrideWith((ref) => mockSupabase),
        analyticsDependencyProvider.overrideWith((ref) => fakeAnalytics),
        userDependencyProvider.overrideWith((ref) => mockUser),
      ],
    );
    conversationsService = container.read(conversationsServiceProvider);
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('deleteConversation', () {
    test('deletes conversation and clears current if matches', () async {
      // Setup
      final conversation = Conversation(id: 'to-delete', title: 'Delete Me');
      await mockSupabase.from('conversations').insert(
            conversation.toSupabase(
              userId: 'user-id',
            ),
          );
      container
          .read(currentConversationProvider.notifier)
          .setConversation(conversation);

      // Act
      await conversationsService.deleteConversation(conversation);

      // Assert
      final dbResult = await mockSupabase.from('conversations').select();
      expect(dbResult, isEmpty);
      expect(container.read(currentConversationProvider), isNull);

      expect(
        fakeAnalytics.capturedEvents.contains('conversation_deleted'),
        isTrue,
      );
    });
  });

  group('fetchConversations', () {
    test('fetches conversations and their messages', () async {
      // Setup
      final conversation1 = Conversation(id: 'conv1', title: 'Conversation 1');
      final conversation2 = Conversation(id: 'conv2', title: 'Conversation 2');
      final message1 = ConversationMessage(
        id: 'msg1',
        conversationId: 'conv1',
        query: 'Hello',
        reply: 'Hi',
        createdAt: DateTime.now(),
      );
      final message2 = ConversationMessage(
        id: 'msg2',
        conversationId: 'conv1',
        query: 'How are you?',
        reply: 'I am fine',
        createdAt: DateTime.now(),
      );

      await mockSupabase.from('conversations').insert([
        conversation1.toSupabase(userId: mockUser.id),
        conversation2.toSupabase(userId: mockUser.id),
      ]);
      await mockSupabase.from('conversation_messages').insert([
        message1.toSupabase(),
        message2.toSupabase(),
      ]);

      // Act
      final conversations = await conversationsService.fetchConversations(
        offset: 0,
        amount: 10,
      );

      expect(conversations.length, 2);

      final sortedConversations = conversations
        ..sort((a, b) => a.id.compareTo(b.id));

      expect(sortedConversations[0].id, conversation1.id);
      expect(sortedConversations[0].messages.length, 2);
      expect(sortedConversations[0].messages[0].query, message1.query);
      expect(sortedConversations[0].messages[1].query, message2.query);
      expect(sortedConversations[1].id, conversation2.id);
      expect(sortedConversations[1].messages, isEmpty);
      expect(sortedConversations[1].title, conversation2.title);
      expect(sortedConversations[0].title, conversation1.title);

      expect(
        fakeAnalytics.capturedEvents.contains('conversations_fetched'),
        isTrue,
      );
    });

    test('returns empty list when no conversations exist', () async {
      final conversations = await conversationsService.fetchConversations(
        offset: 0,
        amount: 10,
      );

      expect(conversations, isEmpty);
    });
  });
}
