import { createClient } from "jsr:@supabase/supabase-js@2";
import { assertEquals } from "jsr:@std/assert";
import { generateFakeDaytistics } from "./test-utils.ts";

Deno.test(
  "send_conversation_message returns data about the all daytistics of the user if asked",
  async () => {
    const supabaseApiUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const supabase = createClient(supabaseApiUrl!, supabaseAnonKey!);

    // Setup
    const {
      data: { user },
    } = await supabase.auth.signInAnonymously();

    const { daytistics, wellbeings, activities } = await generateFakeDaytistics(
      3,
      user!,
      supabase
    );

    const response = await supabase.functions.invoke(
      "send_conversation_message",
      {
        body: {
          query:
            "What are a) all my daytistics, b) all in the summer of 2021 and c) on jan.12.12",
        },
      }
    );

    console.log(response);

    // await cleanup();
    await supabase.auth.admin.deleteUser(user!.id);

    for (let i = 0; i < 1000; i++) {
      clearInterval(i);
      clearTimeout(i);
    }
  }
);
