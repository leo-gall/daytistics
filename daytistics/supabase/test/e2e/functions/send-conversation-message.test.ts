import {
  createClient,
  SupabaseClient,
  User,
} from "jsr:@supabase/supabase-js@2";
import {
  assert,
  assertEquals,
  assertFalse,
  assertGreater,
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
  inputTokens: number;
  outputTokens: number;
}

async function testContainsNoDailyTokenBudgets(
  supabase: SupabaseClient,
  date: Date,
) {
  const { data: dailyTokenBudgets } = await supabase
    .from("daily_token_budgets")
    .select()
    .eq("date", date.toISOString())
    .single();

  assertEquals(dailyTokenBudgets, null);
}

async function testWithoutConversationId(supabase: SupabaseClient, date: Date) {
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

  // Ensure the daily token budget was created and its fields are correct
  const { data: dailyTokenBudgetsData } = await supabase
    .from("daily_token_budgets")
    .select()
    .eq("date", date.toISOString())
    .single();

  assert(dailyTokenBudgetsData !== null);
  const inputTokens = dailyTokenBudgetsData.input_tokens;
  const outputTokens = dailyTokenBudgetsData.output_tokens;
  assertEquals(typeof inputTokens, "number");
  assertEquals(typeof outputTokens, "number");

  return {
    conversation,
    inputTokens,
    outputTokens,
  };
}

async function testWithConversationId(
  supabase: SupabaseClient,
  user: User,
  date: Date,
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

  // Check that the daily token budget was updated
  const { data: dailyTokenBudgetsData } = await supabase
    .from("daily_token_budgets")
    .select()
    .eq("user_id", user.id)
    .eq("date", date.toISOString())
    .single();

  assert(dailyTokenBudgetsData !== null);
  const inputTokens = dailyTokenBudgetsData.input_tokens;
  const outputTokens = dailyTokenBudgetsData.output_tokens;
  assertEquals(typeof inputTokens, "number");
  assertEquals(typeof outputTokens, "number");

  const conversation: Conversation = (
    await supabase
      .from("conversations")
      .select()
      .eq("id", conversationId)
      .single()
  ).data!;

  return {
    conversation,
    inputTokens,
    outputTokens,
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

  const { error } = await supabase.functions.invoke(
    "send-conversation-message",
    {
      body: {
        query: query1,
      },
    },
  );

  assertFalse(error === null);
}

function testTokensIncreased(step1Result: StepResult, step2Result: StepResult) {
  assertGreater(step2Result.inputTokens, step1Result.inputTokens);
  assertGreater(step2Result.outputTokens, step1Result.outputTokens);
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

    await t.step(
      "Contains no daily token budgets before doing a request",
      async () => {
        await testContainsNoDailyTokenBudgets(supabase, date);
      },
    );

    let testWithoutConversationIdResult: StepResult;
    await t.step("Without conversation ID", async () => {
      testWithoutConversationIdResult = await testWithoutConversationId(
        supabase,
        date,
      );
    });

    let testWithConversationIdResult: StepResult;
    await t.step("With conversation ID", async () => {
      testWithConversationIdResult = await testWithConversationId(
        supabase,
        user!,
        date,
        testWithoutConversationIdResult.conversation.id,
      );
    });

    await t.step("Exceeded token budget", async () => {
      await testWithExceededConversationMessages(supabase);
    });

    await t.step("Tokens increased", () => {
      testTokensIncreased(
        testWithoutConversationIdResult,
        testWithConversationIdResult,
      );
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
