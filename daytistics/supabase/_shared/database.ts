import { SupabaseClient, User } from "jsr:@supabase/supabase-js@2";
import {
  Conversation,
  ConversationMessage,
  DatabaseActivity,
  DatabaseWellbeing,
  Daytistic,
} from "./types.ts";
import { decrypt } from "./encryption.ts";

interface FetchDaytisticsOptions {
  date?: Date;
  range?: {
    start: Date;
    end: Date;
  };
}

export async function fetchDaytistics(
  supabase: SupabaseClient,
  options?: FetchDaytisticsOptions
): Promise<Daytistic[]> {
  let query = supabase.from("daytistics").select("*");

  if (options?.date) {
    query = query.eq("date", options.date);
  } else if (options?.range) {
    query = query
      .gte("date", options.range.start)
      .lte("date", options.range.end);
  }

  const daytistics = await query;

  for (const daytistic of daytistics.data ?? []) {
    daytistic.date = new Date(daytistic.date).toLocaleDateString();

    const wellbeing = (
      await supabase
        .from("wellbeings")
        .select("*")
        .eq("id", daytistic.wellbeing_id)
        .single()
    ).data as DatabaseWellbeing;
    if (wellbeing) {
      daytistic.wellbeing = wellbeing;
    }

    const activities = await supabase
      .from("activities")
      .select("*")
      .eq("daytistic_id", daytistic.id);
    daytistic.activities = activities.data as DatabaseActivity[];
  }
  return daytistics.data ?? [];
}

export async function hasConversationAnalyticsEnabled(
  user: User,
  supabase: SupabaseClient
): Promise<boolean> {
  const { data: settings } = await supabase
    .from("user_settings")
    .select("conversation_analytics")
    .eq("user_id", user.id)
    .single();

  return settings?.conversation_analytics ?? false;
}

export async function fetchConversations(
  user: User,
  supabase: SupabaseClient,
  options?: { encrypted: boolean; offset?: number; amount?: number }
): Promise<Conversation[]> {
  const offset = options?.offset ?? 0;
  const amount = options?.amount ?? 10;
  const { data: conversationsData, error: conversationsError } = await supabase
    .from("conversations")
    .select("*")
    .eq("user_id", user.id)
    .order("updated_at", { ascending: false })
    .range(offset, offset + amount);

  const conversations: Conversation[] = [];
  const messages: ConversationMessage[] = [];

  if (!conversationsError && conversationsData) {
    for (const conversation of conversationsData) {
      const { data: messagesData, error: messagesError } = await supabase
        .from("conversation_messages")
        .select("*")
        .order("created_at", { ascending: false })
        .eq("conversation_id", conversation.id);

      if (!messagesError && messagesData) {
        if (!options?.encrypted) {
          const decryptedMessages = await Promise.all(
            messagesData.map(async (message) => {
              return {
                ...message,
                query: await decrypt(message.query, user),
                reply: await decrypt(message.reply, user),
              };
            })
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
            (message) => message.conversation_id === conversation.id
          ),
        };
      })
    );
  }

  return conversations;
}
