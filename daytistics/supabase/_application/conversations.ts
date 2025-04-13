import { SupabaseClient, User } from "jsr:@supabase/supabase-js@2";
import { v4 as uuidv4 } from "npm:uuid";
import OpenAI from "jsr:@openai/openai";
import {
  Conversation,
  ConversationMessage,
  Daytistic,
} from "../_shared/types.ts";
import { fetchDaytistics } from "./daytistics.ts";
import config from "../config.ts";

const TOOLS: OpenAI.ChatCompletionTool[] = [
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

export async function sendConversationMessage(
  supabase: SupabaseClient,
  openai: OpenAI,
  user: User,
  options: {
    query: string;
    conversationId: string | null | undefined;
    model: string;
    systemPrompt: string;
  },
) {
  const messages: OpenAI.ChatCompletionMessageParam[] = [
    {
      role: "system",
      content:
        `${options.systemPrompt} - The current time in your timezone is ${
          new Date().toISOString()
        } and you are using UTC`,
    },
  ];

  if (options.conversationId) {
    const conversationContext = await fetchConversationContext(supabase, {
      conversationId: options.conversationId,
      user,
    });
    messages.push(...conversationContext);
  }

  messages.push({
    role: "user",
    content: options.query,
  });

  const completion = await generateCompletion(
    openai,
    messages,
    options.model,
    TOOLS,
  );

  let outputTokens = completion!.usage?.completion_tokens || 0;
  let inputTokens = completion!.usage?.prompt_tokens || 0;

  const toolCalls = completion!.choices[0].message.tool_calls;

  let reply: string | null;
  if (toolCalls) {
    messages.push(completion!.choices[0].message);
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

    const feededCompletion = await generateCompletion(
      openai,
      messages,
      options.model,
      TOOLS,
    );

    outputTokens += feededCompletion.usage?.completion_tokens || 0;
    inputTokens += feededCompletion.usage?.prompt_tokens || 0;

    reply = feededCompletion.choices[0].message.content;
  } else {
    reply = completion!.choices[0].message.content;
  }

  return {
    reply,
    outputTokens,
    inputTokens,
    messages,
    toolCalls,
  };
}

async function fetchConversationContext(
  supabase: SupabaseClient,
  options: {
    conversationId: string;
    user: User;
  },
): Promise<OpenAI.Chat.Completions.ChatCompletionMessageParam[]> {
  const messages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] = [];
  const conversation_messages = await supabase
    .from("conversation_messages")
    .select()
    .eq("conversation_id", options.conversationId);

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

  return messages;
}

export async function addMessageToConversation(
  supabase: SupabaseClient,
  options: {
    conversationId: string;
    query: string;
    reply: string;
    toolCalls: OpenAI.Chat.Completions.ChatCompletionMessageToolCall[];
  },
) {
  await supabase.from("conversation_messages").insert([
    {
      id: uuidv4(),
      query: options.query,
      reply: options.reply,
      conversation_id: options.conversationId,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      called_functions: options.toolCalls?.map(
        (toolCall: OpenAI.Chat.Completions.ChatCompletionMessageToolCall) =>
          JSON.stringify(toolCall),
      ) || [],
    },
  ]);
}

export async function createConversation(
  supabase: SupabaseClient,
  user: User,
  title: string,
) {
  const id = uuidv4();
  await supabase.from("conversations").insert([
    {
      user_id: user!.id,
      id: id,
      title: title,
    },
  ]);

  return id;
}

export async function existsConversation(
  supabase: SupabaseClient,
  conversationId: string,
): Promise<boolean> {
  const conversation = await supabase
    .from("conversations")
    .select()
    .eq("id", conversationId)
    .single();

  return !conversation.error && conversation.data;
}

export async function generateConversationTitleFromQuery(
  openai: OpenAI,
  options: {
    query: string;
    model: string;
    prompt: string;
  },
) {
  const completion = await generateCompletion(
    openai,
    [
      {
        role: "system",
        content: options.prompt,
      },
      {
        role: "user",
        content: options.query,
      },
    ],
    options.model,
  );

  return {
    title: (completion.choices[0].message.content as string).replaceAll(
      '"',
      "",
    ),
    outputTokens: completion.usage?.completion_tokens || 0,
    inputTokens: completion.usage?.prompt_tokens || 0,
  };
}

async function generateCompletion(
  openai: OpenAI,
  messages: OpenAI.Chat.Completions.ChatCompletionMessageParam[],
  model: string,
  tools?: OpenAI.ChatCompletionTool[],
): Promise<OpenAI.Chat.Completions.ChatCompletion> {
  return await (openai as OpenAI).chat.completions.create({
    messages: messages,
    tools: tools,
    model: model,
    stream: false,
  });
}

export async function fetchConversations(
  user: User,
  supabase: SupabaseClient,
  options?: {
    encrypted: boolean;
    offset?: number;
    amount?: number;
    id?: string;
  },
): Promise<Conversation[]> {
  const offset = options?.offset ?? 0;
  const amount = options?.amount ?? 10;
  const query = supabase
    .from("conversations")
    .select("*")
    .eq("user_id", user.id)
    .order("updated_at", { ascending: false })
    .range(offset, offset + amount);

  if (options?.id) query.eq("id", options.id);

  const { data: conversationsData, error: conversationsError } = await query;

  const conversations: Conversation[] = [];
  const messages: ConversationMessage[] = [];

  if (!conversationsError && conversationsData) {
    for (const conversation of conversationsData) {
      const { data: messagesData, error: messagesError } = await supabase
        .from("conversation_messages")
        .select("*")
        .order("created_at", { ascending: true })
        .eq("conversation_id", conversation.id);

      if (!messagesError && messagesData) {
        if (!options?.encrypted) {
          const decryptedMessages = await Promise.all(
            messagesData.map((message) => {
              return {
                ...message,
                query: message.query,
                reply: message.reply,
              };
            }),
          );
          messages.push(...decryptedMessages);
        } else {
          messages.push(...messagesData);
        }
      }
    }

    conversations.push(
      ...conversationsData.map((conversation) => {
        return {
          ...conversation,
          messages: messages.filter(
            (message) => message.conversation_id === conversation.id,
          ),
        };
      }),
    );
  }

  return conversations;
}

export async function hasExceededDaytisticMessageLimit(
  supabase: SupabaseClient,
  conversationId: string | null | undefined,
): Promise<boolean> {
  const messages = await supabase.from("conversation_messages").select(
    "id",
  ).eq(
    "conversation_id",
    conversationId,
  );

  if (messages.error) {
    return false;
  }

  return messages.data.length >=
    config.conversations.options.freeMessagesPerDaytistic;
}

export async function hasConversationAnalyticsEnabled(
  user: User,
  supabase: SupabaseClient,
): Promise<boolean> {
  const { data: settings } = await supabase
    .from("user_settings")
    .select("conversation_analytics")
    .eq("user_id", user.id)
    .single();

  return settings?.conversation_analytics ?? false;
}

export interface FeatureFlags {
  max_free_output_tokens_per_day: number;
  model: string;
  prompt: string;
  title_model: string;
  title_prompt: string;
}
