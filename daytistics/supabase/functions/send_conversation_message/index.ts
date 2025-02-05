import OpenAI from "https://deno.land/x/openai@v4.24.0/mod.ts";
import {
  requireAuthWrapper,
  catchExceptionWrapper,
} from "@daytistics/utils/wrappers.ts";
import { fetchDaytistics } from "@daytistics/database/daytistics.ts";

const tools: OpenAI.ChatCompletionTool[] = [
  {
    type: "function",
    function: {
      name: "fetchDaytistics",
      description:
        "Fetches daytistics from the database based on the given date or date range.",
      parameters: {
        type: "object",
        properties: {
          date: {
            type: "string",
            format: "date",
            description:
              "The specific date to fetch daytistics for (YYYY-MM-DD).",
          },
          range: {
            type: "object",
            properties: {
              start: {
                type: "string",
                format: "date-time",
                description: "The start of the date range (ISO 8601 format).",
              },
              end: {
                type: "string",
                format: "date-time",
                description: "The end of the date range (ISO 8601 format).",
              },
            },
            required: ["start", "end"],
            description:
              "The date range to fetch daytistics for. Cannot be used with 'date'.",
          },
        },
        description: "The options to fetch daytistics with.",
      },
    },
  },
];

Deno.serve(async (req) => {
  return await requireAuthWrapper(req, async (supabase, _user) => {
    return await catchExceptionWrapper(async () => {
      const { query } = await req.json();
      const apiKey = Deno.env.get("OPENAI_API_KEY");

      const openai = new OpenAI({
        apiKey: apiKey,
      });

      const d1 = await fetchDaytistics(supabase);
      const d2 = await fetchDaytistics(supabase, {
        range: { start: new Date(), end: new Date() },
      });
      const d3 = await fetchDaytistics(supabase, {
        date: new Date(),
      });

      const chatCompletion = await openai.chat.completions.create({
        messages: [
          {
            role: "system",
            content:
              "You always wanna call a function with random arguments for options",
            //  + fetchedDaytistics,
          },
          { role: "user", content: query },
        ],
        tools: tools,
        model: "gpt-3.5-turbo",
        stream: false,
      });

      const reply = chatCompletion.choices[0].message.tool_calls!;

      return new Response(JSON.stringify({ reply }), {
        headers: { "Content-Type": "application/json" },
      });
    });
  });
});
