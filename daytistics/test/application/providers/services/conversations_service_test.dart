import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
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

  setUpAll(() {
    mockHttpClient = MockSupabaseHttpClient();

    mockSupabase = SupabaseClient(
      'https://mock.supabase.co',
      'fakeAnonKey',
      httpClient: mockHttpClient,
    );
  });

  setUp(() {
    container = createContainer(
      overrides: [
        supabaseClientDependencyProvider.overrideWith((ref) => mockSupabase),
        posthogDependencyProvider.overrideWith((ref) => FakePosthog()),
      ],
    );
    conversationsService =
        container.read(conversationsServiceProvider.notifier);
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
    });
  });

  group('hasAnyConversations', () {
    test('returns true if there are conversations', () async {
      // Setup
      await mockSupabase.from('conversations').insert([
        {
          'id': 'conversation-1',
          'title': 'Conversation 1',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ]);

      // Act
      final result = await conversationsService.hasAnyConversations();

      // Assert
      expect(result, isTrue);
    });

    test('returns false if there are no conversations', () async {
      // Act
      final result = await conversationsService.hasAnyConversations();

      // Assert
      expect(result, isFalse);
    });
  });
}
