import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.192.0/testing/asserts.ts";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";
console.log("1" + JSON.stringify(Deno.env.toObject(), null, 2));

const testHelloWorld = async () => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const options = {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
      detectSessionInUrl: false,
    },
  };
  console.log("2" + JSON.stringify(Deno.env.toObject(), null, 2));
  var client: SupabaseClient = createClient(supabaseUrl, supabaseKey, options);

  // Invoke the 'hello-world' function with a parameter
  const { data: func_data, error: func_error } = await client.functions.invoke(
    "test"
  );

  const containsSUPABASE_ANON_KEY = func_data.includes(supabaseKey);

  // Check for errors from the function invocation
  if (func_error) {
    throw new Error("Invalid response: " + func_error.message);
  }

  assertEquals(containsSUPABASE_ANON_KEY, true);
};

Deno.test("Hello-world Function Test", testHelloWorld);
