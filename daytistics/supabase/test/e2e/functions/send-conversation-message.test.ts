import {
  createClient,
  SupabaseClient,
  User,
} from "jsr:@supabase/supabase-js@2";
import {
  assert,
  assertEquals,
  assertFalse,
  assertGreaterOrEqual,
} from "jsr:@std/assert";
import { generateFakeDaytistics } from "../../e2e-utils.ts";
import { Conversation, ConversationMessage } from "../../../_shared/types.ts";
import config from "../../../config.ts";

const query1 =
  "What would you recommend to improve my wellbeing? Based on: a) my activities in the last week, b) my activities yesterday, c) all my activities. Answer 3 times.";
const query2 = "What have we talked about so far?";

interface StepResult {
  conversation: Conversation;
}

async function testWithoutConversationId(
  supabase: SupabaseClient,
  _date: Date,
) {
  const response = await supabase.functions.invoke(
    "send-conversation-message",
    {
      body: {
        query: query1,
      },
    },
  );

  console.log(response);

  const conversation: Conversation = (
    await supabase
      .from("conversations")
      .select()
      .eq("id", response.data.conversation_id)
      .single()
  ).data!;

  assertEquals(response.error, null);
  assertEquals(response.data.query, query1);
  assertEquals(typeof response.data.reply, "string");
  assertEquals(typeof response.data.conversation_id, "string");
  assertEquals(typeof response.data.title, "string");
  assertGreaterOrEqual(response.data.called_functions.length, 1);

  const { data: conversationMessages } = await supabase
    .from("conversation_messages")
    .select()
    .eq("conversation_id", response.data.conversation_id);

  assertFalse(conversationMessages === null);
  assertGreaterOrEqual(conversationMessages!.length, 1);

  return {
    conversation,
  };
}

async function testWithConversationId(
  supabase: SupabaseClient,
  _user: User,
  conversationId: string,
) {
  const response = await supabase.functions.invoke(
    "send-conversation-message",
    {
      body: {
        query: query2,
        conversation_id: conversationId,
      },
    },
  );

  assertEquals(response.error, null);
  assertEquals(response.data.query, query2);
  assertEquals(typeof response.data.reply, "string");
  assertEquals(typeof response.data.conversation_id, "string");
  assertEquals(typeof response.data.title, "string");
  assertEquals(response.data.called_functions.length, 0);

  const { data: conversationMessages } = await supabase
    .from("conversation_messages")
    .select()
    .eq("conversation_id", response.data.conversation_id);

  assertFalse(conversationMessages === null);
  assertGreaterOrEqual(conversationMessages!.length, 2);

  const conversation: Conversation = (
    await supabase
      .from("conversations")
      .select()
      .eq("id", conversationId)
      .single()
  ).data!;

  return {
    conversation,
  };
}

async function testWithExceededConversationMessages(
  supabase: SupabaseClient,
) {
  const messages = Array.from(
    { length: config.conversations.options.freeMessagesPerDaytistic + 1 },
    (_, i) =>
      new ConversationMessage(
        i.toString(),
        "query",
        "reply",
        "conversation_id",
        new Date().toISOString(),
        new Date().toISOString(),
        [],
      ),
  );

  await supabase.from("conversation_messages").insert(messages);

  // list messages
  const { data: conversationMessages } = await supabase
    .from("conversation_messages")
    .select()
    .eq("conversation_id", messages[0].conversation_id);

  const { error, data } = await supabase.functions.invoke(
    "send-conversation-message",
    {
      body: {
        query: query1,
      },
    },
  );

  // dbeug print
  console.log("Error:", error);
  console.log("Data:", data);
  console.log(conversationMessages);

  assertFalse(error === null);
}

async function testRequiresAuthentication(supabase: SupabaseClient) {
  await supabase.auth.signOut();

  const { error } = await supabase.functions.invoke(
    "send-conversation-message",
    {
      body: {
        query: query1,
      },
    },
  );

  assert(error !== null);
}

Deno.test(
  "send-conversation-message",
  { sanitizeResources: false },
  async (t) => {
    // Arrange
    const supabaseApiUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const supabase = createClient(supabaseApiUrl!, supabaseAnonKey!);

    const {
      data: { user },
    } = await supabase.auth.signInAnonymously();

    await generateFakeDaytistics(3, user!, supabase);
    const date = new Date();

    let testWithoutConversationIdResult: StepResult;
    await t.step("Without conversation ID", async () => {
      testWithoutConversationIdResult = await testWithoutConversationId(
        supabase,
        date,
      );
    });

    await t.step("With conversation ID", async () => {
      await testWithConversationId(
        supabase,
        user!,
        testWithoutConversationIdResult.conversation.id,
      );
    });

    await t.step("Exceeded conversation messaged", async () => {
      await testWithExceededConversationMessages(supabase);
    });

    await t.step("Requires authentication", async () => {
      await testRequiresAuthentication(supabase);
    });

    await supabase.auth.admin.deleteUser(user!.id);

    // Cleanup: clear any active intervals or timeouts
    for (let i = 0; i < 1000; i++) {
      clearInterval(i);
      clearTimeout(i);
    }
  },
);
