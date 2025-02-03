import OpenAI from "https://deno.land/x/openai@v4.24.0/mod.ts";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { fetchDaytistics } from "database/daytistics.ts";

const SYSTEM_PROMPT = `
You are a helpful assistant that analyzes the user's daily activities and provides insights to improve well-being and productivity.  
You respond to user questions based on the available data, offering insights on well-being, daytistics, productivity, and any patterns you can infer.  

---

RESPONSE:  
Keep responses short, friendly, and positive. Use emojis and humor to make conversations engaging. If relevant, provide actionable suggestions.  
If the user asks something unrelated to daily activities, well-being, or productivity, let them know you can't answer.  
Do not use markdown in responses. End each response with a fitting title in this format: <title>Your Title Here</title>.  

---

You have access to the following data:  
`;

Deno.serve(async (req) => {
  const { query } = await req.json();
  const apiKey = Deno.env.get("OPENAI_API_KEY");

  const authHeader = req.headers.get("Authorization")!;
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } }
  );

  const openai = new OpenAI({
    apiKey: apiKey,
  });

  const token = authHeader.replace("Bearer ", "");
  const { data } = await supabase.auth.getUser(token);

  const fetchedDaytistics = await fetchDaytistics(supabase);

  const chatCompletion = await openai.chat.completions.create({
    messages: [
      {
        role: "system",
        content: SYSTEM_PROMPT + fetchedDaytistics,
      },
      { role: "user", content: query },
    ],
    model: "gpt-3.5-turbo",
    stream: false,
  });

  const reply = chatCompletion.choices[0].message.content;

  return new Response(reply, {
    headers: { "Content-Type": "text/plain" },
  });
});
