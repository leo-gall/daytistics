import OpenAI from "https://deno.land/x/openai@v4.24.0/mod.ts";
import { z } from "npm:zod";
import { v4 as uuidv4 } from "npm:uuid";
import { encoding_for_model, TiktokenModel } from "npm:tiktoken";
import { createClient, User } from "jsr:@supabase/supabase-js@2";
import * as Sentry from "npm:@sentry/deno";

import { initPosthog, initSentry } from "@daytistics/adapters";

import { fetchDaytistics } from "@daytistics/database";
import {
  DatabaseConversation,
  DatabaseConversationMessage,
  Daytistic,
} from "@daytistics/types";
import prompts from "@daytistics/prompts";

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

interface ConversationFeatureFlags {
  max_output_tokens_per_day: number;
  model: string;
  title_model: string;
}

const inputSchema = z.object({
  query: z.string(),
  conversation_id: z.string().nullable(),
  timezone: z.string(),
});

const openai = new OpenAI({
  apiKey: Deno.env.get("OPENAI_API_KEY"),
});

Deno.serve(async (req) => {
  initSentry();
  const posthog = initPosthog();

  try {
    const authHeader = req.headers.get("Authorization")!;
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
      {
        global: { headers: { Authorization: authHeader } },
      }
    );

    const token = authHeader.replace("Bearer ", "");
    let user: User | null = null;
    try {
      user = (await supabase.auth.getUser(token)).data.user;
    } catch {
      return new Response(
        JSON.stringify({ error: "Invalid or missing token" }),
        {
          status: 401,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    let query: string;
    let conversationId: string | null;
    let timezone: string;

    try {
      const {
        query: q,
        conversation_id,
        timezone: tz,
      } = inputSchema.parse(await req.json());
      query = q;
      conversationId = conversation_id;
      timezone = tz;
    } catch (error) {
      return new Response(JSON.stringify({ error: "Invalid input schema" }), {
        status: 422,
        headers: { "Content-Type": "application/json" },
      });
    }

    const posthog = initPosthog();

    if (!(await posthog.isFeatureEnabled("conversations", user!.id))) {
      return new Response(
        JSON.stringify({ error: "Conversations feature is disabled" }),
        {
          status: 403,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const conversationFeatureFlags = (await posthog.getFeatureFlagPayload(
      "conversations",
      user!.id,
      true
    ))! as unknown as ConversationFeatureFlags;

    const today = new Date().toISOString().split("T")[0];
    const dailyTokensResponse = await supabase
      .from("daily_token_budgets")
      .select()
      .eq("date", today)
      .single();

    if (
      !dailyTokensResponse.error &&
      dailyTokensResponse.data.output_tokens >=
        conversationFeatureFlags.max_output_tokens_per_day
    ) {
      return new Response(
        JSON.stringify({ error: "Daily token budget exceeded" }),
        {
          status: 403,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const messages: OpenAI.ChatCompletionMessageParam[] = [
      {
        role: "system",
        content: prompts({
          timezone: timezone,
          currentDateTime: new Date().toISOString(),
        }).send_conversation_message,
      },
    ];

    if (conversationId) {
      const conversation_messages = await supabase
        .from("conversation_messages")
        .select()
        .eq("conversation_id", conversationId);

      if (conversation_messages.data && !conversation_messages.error) {
        for (const message of conversation_messages.data!) {
          messages.push({
            role: "user",
            content: message.query,
          });

          messages.push({
            role: "assistant",
            content: message.reply,
          });
        }
      }
    }

    messages.push({
      role: "user",
      content: query,
    });

    let outputTokens = 0;
    let inputTokens = 0;

    const completion = await openai.chat.completions.create({
      messages: messages,
      tools: tools,
      model: conversationFeatureFlags.model,
      stream: false,
    });

    outputTokens += completion.usage?.completion_tokens || 0;
    inputTokens += completion.usage?.prompt_tokens || 0;

    const toolCalls = completion.choices[0].message.tool_calls;

    let reply: string | null;
    if (toolCalls) {
      messages.push(completion.choices[0].message);
      for (const toolCall of toolCalls) {
        if (toolCall.function.name === "fetchDaytistics") {
          const args = JSON.parse(toolCall.function.arguments);
          let daytistics: Daytistic[] = [];

          if (args.date) {
            daytistics = await fetchDaytistics(supabase, { date: args.date });
          } else if (args.range) {
            daytistics = await fetchDaytistics(supabase, {
              range: {
                start: args.range.start,
                end: args.range.end,
              },
            });
          } else {
            daytistics = await fetchDaytistics(supabase);
          }

          messages.push({
            role: "tool",
            tool_call_id: toolCall.id,
            content: JSON.stringify(daytistics),
          });
        }
      }

      const feededCompletion = await openai.chat.completions.create({
        messages: messages,
        tools: tools,
        model: conversationFeatureFlags.model,
        stream: false,
      });

      outputTokens += feededCompletion.usage?.completion_tokens || 0;
      inputTokens += feededCompletion.usage?.prompt_tokens || 0;

      reply = feededCompletion.choices[0].message.content;
    } else {
      reply = completion.choices[0].message.content;
    }

    const conversation = await supabase
      .from("conversations")
      .select()
      .eq("id", conversationId)
      .single();

    let title: string = conversation.data?.title || "";

    let conversationId_: string = conversationId || "";
    if (!conversation.data) {
      const messages_ = messages.filter((message) => message.role !== "system");

      const titleCompletion = await openai.chat.completions.create({
        messages: [
          {
            role: "system",
            content:
              "Generate a short (1-3 words) title for this conversation.",
          },
          ...messages_,
        ],
        model: conversationFeatureFlags.title_model,
        stream: false,
      });

      outputTokens += titleCompletion.usage?.completion_tokens || 0;
      inputTokens += titleCompletion.usage?.prompt_tokens || 0;

      conversationId_ = uuidv4();
      title = titleCompletion.choices[0].message.content!;
      await supabase.from("conversations").insert([
        {
          user_id: user!.id,
          id: conversationId_,
          title: title,
          updated_at: new Date().toISOString(),
        } as DatabaseConversation,
      ]);
    } else {
      await supabase
        .from("conversations")
        .update({
          updated_at: new Date().toISOString(),
        })
        .eq("id", conversationId_);
    }

    await supabase.from("conversation_messages").insert([
      {
        id: uuidv4(),
        query: query,
        reply: reply!,
        conversation_id: conversationId_,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        called_functions:
          toolCalls?.map((toolCall) => JSON.stringify(toolCall)) || [],
      } as DatabaseConversationMessage,
    ]);

    if (dailyTokensResponse.error) {
      await supabase.from("daily_token_budgets").insert([
        {
          user_id: user!.id,
          date: today,
          input_tokens: inputTokens,
          output_tokens: outputTokens,
        },
      ]);
    } else {
      await supabase
        .from("daily_token_budgets")
        .update({
          input_tokens: dailyTokensResponse.data.input_tokens + inputTokens,
          output_tokens: dailyTokensResponse.data.output_tokens + outputTokens,
        })
        .eq("id", dailyTokensResponse.data.id);
    }

    await posthog.shutdown();

    return new Response(
      JSON.stringify({
        query: query,
        reply: reply!,
        conversation_id: conversationId_,
        title: title,
        called_functions:
          toolCalls?.map((toolCall) => JSON.stringify(toolCall)) || [],
      }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    Sentry.captureException(error);
    await Sentry.flush();
    await posthog.shutdown();
    return new Response(JSON.stringify({ error: "An unknown error occured" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
