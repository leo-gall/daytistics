import OpenAI from "jsr:@openai/openai";

import { z } from "npm:zod";
import * as Sentry from "npm:@sentry/deno";
import { OpenAI as PostHogOpenAI } from "npm:@posthog/ai";
import { validateZodSchema } from "@shared/validation";

import { initPosthog, initSentry, initSupabase } from "@shared/adapters";

import * as Conversations from "@application/conversations";
import * as DailyTokenBudgets from "@application/tokens_budgets";

const BodySchema = z.object({
  query: z.string(),
  conversation_id: z.string().nullable().optional(),
});

Deno.serve(async (req) => {
  initSentry();
  const posthog = initPosthog();

  try {
    // Initialize Supabase client and get the user
    const {
      supabase,
      user,
      error: supabaseInitError,
    } = await initSupabase(req, { withAuth: true });
    if (supabaseInitError) return supabaseInitError;

    // Validate the request body
    const validatedBody = validateZodSchema(BodySchema, await req.json());
    if (!validatedBody || !validatedBody.data) {
      return validatedBody.error;
    }

    // Only if the users allows conversation analytics we use the PostHogOpenAI client to track the conversation
    const openai: OpenAI | PostHogOpenAI =
      (await Conversations.hasConversationAnalyticsEnabled(user!, supabase))
        ? new PostHogOpenAI({
            apiKey: Deno.env.get("OPENAI_API_KEY") as string,
            posthog: posthog,
          })
        : new OpenAI({
            apiKey: Deno.env.get("OPENAI_API_KEY") as string,
          });

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
    ))! as unknown as Conversations.FeatureFlags;

    // Check if the user has exceeded the number of tokens for today
    const { error: exceededError } =
      await DailyTokenBudgets.hasExceededTokensToday(
        supabase,
        user!,
        conversationFeatureFlags.max_free_output_tokens_per_day
      );
    if (exceededError) return exceededError;

    const llmResponse = await Conversations.sendConversationMessage(
      supabase,
      openai,
      user!,
      {
        query: validatedBody.data.query,
        conversationId: validatedBody.data.conversation_id,
        model: conversationFeatureFlags.model,
        systemPrompt: conversationFeatureFlags.prompt,
      }
    );

    let conversationId = validatedBody.data.conversation_id;
    let titleLlmResponse;
    if (!conversationId) {
      titleLlmResponse = await Conversations.generateConversationTitleFromQuery(
        openai,
        user!,
        {
          query: validatedBody.data.query,
          model: conversationFeatureFlags.title_model,
          prompt: conversationFeatureFlags.title_prompt,
        }
      );

      conversationId = await Conversations.createConversation(
        supabase,
        user!,
        titleLlmResponse.title || "Untitled"
      );
    }

    await Conversations.addMessageToConversation(supabase, user!, {
      query: validatedBody.data.query,
      reply: llmResponse.reply!,
      conversationId: conversationId,
      toolCalls: llmResponse.toolCalls || [],
    });

    await DailyTokenBudgets.updateTokensBudget(supabase, user!, {
      inputTokens: validatedBody.data.query.length,
      outputTokens: llmResponse.reply!.length,
    });

    return new Response(
      JSON.stringify({
        query: validatedBody.data.query,
        reply: llmResponse.reply,
        conversation_id: conversationId,
        title:
          titleLlmResponse?.title ??
          (
            await Conversations.fetchConversations(user!, supabase, {
              encrypted: true,
              id: conversationId,
            })
          ).at(0)?.title,
        called_functions:
          llmResponse.toolCalls?.map(
            (toolCall: OpenAI.Chat.Completions.ChatCompletionMessageToolCall) =>
              JSON.stringify(toolCall)
          ) || [],
      }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    Sentry.captureException(error);
    await Sentry.flush();
    return new Response(JSON.stringify({ error: "An unknown error occured" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  } finally {
    await posthog.shutdown();
  }
});
