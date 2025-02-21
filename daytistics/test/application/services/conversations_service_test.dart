import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/providers/current_conversation/current_conversation.dart';
import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/application/services/chat/conversations_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../container.dart';

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
        supabaseClientProvider.overrideWith((ref) => mockSupabase),
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

  group('sendMessage', () {
    // group('fetchConversations', () {
    //   test('fetches conversations with messages in correct order', () async {
    //     // Insert test data
    //     final convos = List.generate(
    //       3,
    //       (i) => Conversation(
    //         id: 'convo-$i',
    //         title: 'Convo $i',
    //         updatedAt: DateTime.now().add(Duration(days: i)),
    //       ),
    //     );

    //     for (final convo in convos) {
    //       await mockSupabase.from('conversations').insert(
    //             convo.toSupabase(
    //               userId: 'user-id',
    //             ),
    //           );
    //       await mockSupabase.from('conversation_messages').insert({
    //         'id': 'msg-${convo.id}',
    //         'conversation_id': convo.id,
    //         'query': 'Query',
    //         'reply': 'Reply',
    //         'created_at': DateTime.now().toIso8601String(),
    //         'updated_at': DateTime.now().toIso8601String(),
    //         'called_functions': ['func'],
    //       });
    //     }

    //     // Act
    //     final results = await conversationsService.fetchConversations(start: 0);

    //     // Assert
    //     expect(results.length, 3);
    //     expect(results[0].id, 'convo-2'); // Should be latest first
    //     expect(results[0].messages, isNotEmpty);
    //   });
    // });

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
  });
}
