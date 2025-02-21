// fetch-conversations.test.ts
import {
  createClient,
  SupabaseClient,
  User,
} from "jsr:@supabase/supabase-js@2";
import { assertEquals, assert } from "jsr:@std/assert";
import { generateConversations } from "./test-utils.ts";
import { Conversation } from "../../_shared/types.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.test("fetch-conversations", { sanitizeResources: false }, async (t) => {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const serviceRoleClient = createClient(
    SUPABASE_URL,
    SUPABASE_SERVICE_ROLE_KEY
  );
  let testUser: User;

  await t.step("Setup test user and data", async () => {
    const {
      data: { user },
      error,
    } = await supabase.auth.signInAnonymously();
    assert(!error);
    testUser = user!;
    await generateConversations(testUser, serviceRoleClient, 15, 3);
  });

  await t.step("Requires authentication", async () => {
    await supabase.auth.signOut();
    const { error } = await supabase.functions.invoke("fetch-conversations");
    assert(error);
    assertEquals(error.context.status, 401);
  });

  await t.step("Fetch with default parameters", async () => {
    await supabase.auth.signInAnonymously();
    const { data, error } = await supabase.functions.invoke(
      "fetch-conversations"
    );

    assert(!error);
    assertEquals(data.length, 10);
    const timestamps = data.map((c: Conversation) =>
      new Date(c.updated_at).getTime()
    );
    const isDescending = timestamps.every(
      (ts: number, i: number) => i === 0 || ts <= timestamps[i - 1]
    );
    assert(isDescending);
  });

  await t.step("Fetch with custom pagination", async () => {
    const { data } = await serviceRoleClient
      .from("conversations")
      .select()
      .order("updated_at", { ascending: false });
    const expectedIds = data!.slice(10, 15).map((c) => c.id);

    const { data: response } = await supabase.functions.invoke(
      "fetch-conversations?amount=5&offset=10"
    );
    assertEquals(
      response.map((c: Conversation) => c.id),
      expectedIds
    );
  });

  await t.step("Parameter validation", async () => {
    const { error: invalidAmount } = await supabase.functions.invoke(
      "fetch-conversations?amount=-5"
    );
    assertEquals(invalidAmount?.context.status, 400);

    const { error: invalidOffset } = await supabase.functions.invoke(
      "fetch-conversations?offset=invalid"
    );
    assertEquals(invalidOffset?.context.status, 400);
  });

  await t.step("User isolation", async () => {
    const { data: otherUser } = await supabase.auth.signInAnonymously();
    await generateConversations(otherUser.user!, serviceRoleClient, 5, 1);

    const { data } = await supabase.functions.invoke("fetch-conversations");
    const userIDs = [...new Set(data.map((c: Conversation) => c.user_id))];
    assertEquals(userIDs, [testUser.id]);
  });

  await t.step("Cleanup", async () => {
    await serviceRoleClient
      .from("conversations")
      .delete()
      .eq("user_id", testUser.id);

    await supabase.auth.admin.deleteUser(testUser.id);
  });
});
