import {
  createClient,
  FunctionsHttpError,
  SupabaseClient,
  User,
} from "jsr:@supabase/supabase-js@2";
import {
  assertEquals,
  assert,
  assertGreaterOrEqual,
  assertFalse,
  assertGreater,
} from "jsr:@std/assert";
import { generateFakeDaytistics } from "./test-utils.ts";
import { DatabaseConversation } from "../../_shared/types.ts";
import { initPosthog } from "../../_shared/adapters.ts";

const query1 =
  "What would you recommend to improve my wellbeing? Based on: a) my activities in the last week, b) my activities yesterday, c) all my activities. Answer 3 times.";

const query2 = "What have we talked about so far?";

interface StepResult {
  conversation: DatabaseConversation;
  inputTokens: number;
  outputTokens: number;
}

async function testContainsNoDailyTokenBudgets(
  supabase: SupabaseClient,
  date: Date
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
    "send_conversation_message",
    {
      body: {
        query: query1,
        timezone: "Berlin",
      },
    }
  );

  if (response.data?.error) {
    throw new Error(`Something went wrong: ${response.data?.error}`);
  } else {
    console.log(`Response is ${response}`);
  }

  const conversation: DatabaseConversation = (
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

  // assert that daily token budget was created and its fields are correct
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
  conversationId: string
) {
  const response = await supabase.functions.invoke(
    "send_conversation_message",
    {
      body: {
        query: query2,
        conversation_id: conversationId,
        timezone: "Berlin",
      },
    }
  );

  console.log(response);

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

  // check that daily token budget was updated

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

  const conversation: DatabaseConversation = (
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

async function testWithExceededTokenBudget(
  supabase: SupabaseClient,
  date: Date,
  user: User
) {
  const posthog = initPosthog();
  const featureFlagPayload = (await posthog.getFeatureFlagPayload(
    "conversations",
    user.id
  )) as { max_output_tokens_per_day: number };
  const maxOutputTokensPerDay =
    await featureFlagPayload?.max_output_tokens_per_day;

  const _ = await supabase
    .from("daily_token_budgets")
    .update({
      output_tokens: maxOutputTokensPerDay! + 1,
    })
    .eq("date", date.toISOString().split("T")[0])
    .select();

  const { error } = await supabase.functions.invoke(
    "send_conversation_message",
    {
      body: {
        query: query1,
        timezone: "Berlin",
      },
    }
  );

  assertFalse(error === null);

  await posthog.shutdown();
}

function testTokensIncreased(step1Result: StepResult, step2Result: StepResult) {
  assertGreater(step2Result.inputTokens, step1Result.inputTokens);
  assertGreater(step2Result.outputTokens, step1Result.outputTokens);
}

function testConversationUpdated(
  step1Result: StepResult,
  step2Result: StepResult
) {
  assertGreater(
    new Date(step2Result.conversation.updated_at).getTime(),
    new Date(step1Result.conversation.updated_at).getTime()
  );
}

async function testRequiresAuthentication(supabase: SupabaseClient) {
  await supabase.auth.signOut();
  const { error } = await supabase.functions.invoke(
    "send_conversation_message",
    {
      body: {
        query: query1,
        timezone: "Berlin",
      },
    }
  );

  assert(error !== null);
}

Deno.test(
  "send_conversation_message",
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
      }
    );

    let testWithoutConversationIdResult: StepResult;
    await t.step("Without conversation ID", async () => {
      testWithoutConversationIdResult = await testWithoutConversationId(
        supabase,
        date
      );
    });

    let testWithConversationIdResult: StepResult;
    await t.step("With conversation ID", async () => {
      testWithConversationIdResult = await testWithConversationId(
        supabase,
        user!,
        date,
        testWithoutConversationIdResult.conversation.id
      );
    });

    await t.step("Exceeded token budget", async () => {
      await testWithExceededTokenBudget(supabase, date, user!);
    });

    await t.step("Tokens increased", () => {
      testTokensIncreased(
        testWithoutConversationIdResult,
        testWithConversationIdResult
      );
    });

    await t.step("Conversation updated", () => {
      testConversationUpdated(
        testWithoutConversationIdResult,
        testWithConversationIdResult
      );
    });

    await t.step("Requires authentication", async () => {
      await testRequiresAuthentication(supabase);
    });

    await supabase.auth.admin.deleteUser(user!.id);

    for (let i = 0; i < 1000; i++) {
      clearInterval(i);
      clearTimeout(i);
    }
  }
);
