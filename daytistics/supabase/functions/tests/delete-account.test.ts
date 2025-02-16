import { createClient } from "jsr:@supabase/supabase-js@2";
import { generateFakeDaytistics } from "./test-utils.ts";
import { assert } from "jsr:@std/assert";

Deno.test("delete-account", async (t) => {
  const supabaseApiUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const supabase = createClient(supabaseApiUrl!, supabaseAnonKey!);

  const {
    data: { user },
  } = await supabase.auth.signInAnonymously();

  await generateFakeDaytistics(2, user!, supabase);

  await t.step("Deletes the user's account", async () => {
    const response = await supabase.functions.invoke("delete-account");
    console.log(await supabase.auth.admin.getUserById(user!.id));
    assert((await supabase.auth.admin.getUserById(user!.id)).data === null);

    assert(
      (await supabase.from("daytistics").select().eq("user_id", user!.id)).data!
        .length === 0
    );
  });

  await supabase.auth.signOut();

  await t.step("Requires authentication", async () => {
    const { error } = await supabase.functions.invoke("delete-account");

    assert(error !== null);
  });
});
