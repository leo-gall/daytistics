import OpenAI from "jsr:@openai/openai";

import { z } from "npm:zod";
import * as Sentry from "npm:@sentry/deno";
import { validateZodSchema } from "@shared/validation";

import { initSentry, initSupabase } from "@shared/adapters";

import * as Conversations from "@application/conversations";
import config from "@config";

const BodySchema = z.object({
  query: z.string(),
  conversation_id: z.string().nullable().optional(),
});

Deno.serve(async (req) => {
  initSentry();

  try {
    if (!config.conversations.enabled) {
      return new Response(
        JSON.stringify({ error: "Conversations feature is disabled" }),
        {
          status: 403,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

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

    const openai: OpenAI = new OpenAI({
      apiKey: Deno.env.get("OPENAI_API_KEY") as string,
    });

    if (
      await Conversations.hasExceededDaytisticMessageLimit(
        supabase,
        validatedBody.data.conversation_id,
      )
    ) {
      return new Response(
        JSON.stringify({
          error:
            `You have reached the maximum number of messages for this conversation. Please try again tomorrow.`,
        }),
        {
          status: 403,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const llmResponse = await Conversations.sendConversationMessage(
      supabase,
      openai,
      user!,
      {
        query: validatedBody.data.query,
        conversationId: validatedBody.data.conversation_id,
        model: config.conversations.options.model,
        systemPrompt: config.conversations.options.prompt,
      },
    );

    let conversationId = validatedBody.data.conversation_id;
    let titleLlmResponse;
    if (!conversationId) {
      titleLlmResponse = await Conversations.generateConversationTitleFromQuery(
        openai,
        {
          query: validatedBody.data.query,
          model: config.conversations.options.title.model,
          prompt: config.conversations.options.title.prompt,
        },
      );

      conversationId = await Conversations.createConversation(
        supabase,
        user!,
        titleLlmResponse.title || "Untitled",
      );
    }

    await Conversations.addMessageToConversation(supabase, {
      query: validatedBody.data.query,
      reply: llmResponse.reply!,
      conversationId: conversationId,
      toolCalls: llmResponse.toolCalls || [],
    });

    return new Response(
      JSON.stringify({
        query: validatedBody.data.query,
        reply: llmResponse.reply,
        conversation_id: conversationId,
        title: titleLlmResponse?.title ??
          (
            await Conversations.fetchConversations(user!, supabase, {
              encrypted: true,
              id: conversationId,
            })
          ).at(0)?.title,
        called_functions: llmResponse.toolCalls?.map(
          (toolCall: OpenAI.Chat.Completions.ChatCompletionMessageToolCall) =>
            JSON.stringify(toolCall),
        ) || [],
      }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    Sentry.captureException(error);
    await Sentry.flush();
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
