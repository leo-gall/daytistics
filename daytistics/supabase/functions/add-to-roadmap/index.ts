// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import * as Sentry from "npm:@sentry/deno";
import { initSentry, initSupabase } from "@shared/adapters";
import { validateZodSchema } from "@shared/validation";
import { z } from "npm:zod";
import { User } from "https://jsr.io/@supabase/supabase-js/2.48.1/src/index.ts";

const AddToRoadmapObject = z.object({
  // union of features and bugs
  roadmap: z.union([z.literal("features"), z.literal("bugs")]),
  title: z.string(),
  description: z.string(),
});

Deno.serve(async (req) => {
  initSentry();

  try {
    const {
      user,
      error: supabaseInitError,
      supabase,
    } = await initSupabase(req, {
      withAuth: true,
    });
    if (supabaseInitError) return supabaseInitError;

    const _body = await req.json();
    const { data: body, error: validateError } = await validateZodSchema(
      AddToRoadmapObject,
      _body
    );
    if (validateError) return validateError;

    try {
      await updateRoadmap(body.roadmap, body.title, body.description, user!);
    } catch (error) {
      Sentry.captureException(error as Error);
      await Sentry.flush();
      return new Response(null, {
        status: 500,
        headers: { "Content-Type": "application/json" },
        statusText: (error as Error).message,
      });
    }

    return new Response(null, {
      status: 201,
      statusText: "Successfully added to roadmap",
      headers: {
        "Content-Type": "application/json",
      },
    });
  } catch (error) {
    Sentry.captureException(error as Error);
    await Sentry.flush();
    return new Response(null, {
      status: 500,
      headers: { "Content-Type": "application/json" },
      statusText: (error as Error).message,
    });
  }
});

async function updateRoadmap(
  roadmap: "features" | "bugs",
  title: string,
  description: string,
  user: User
) {
  const headers = {
    Authorization: `Bearer ${Deno.env.get("GITHUB_AUTH_TOKEN")}`,
    "Content-Type": "application/json",
  };

  const projectId = roadmap === "features" ? 6 : 7;

  const projectNodeIdResponse = await fetch(`https://api.github.com/graphql`, {
    method: "POST",
    headers,
    body: JSON.stringify({
      query: `query{user(login: "leo-gall") {projectV2(number: ${projectId}){id}}}`,
    }),
  });

  const projectNodeId = (await projectNodeIdResponse.json()).data.user.projectV2
    .id;

  const draftBody =
    description +
    "\n\n---\n\nThis item was automatically created from the app by " +
    user.id;

  const addItemToProjectResponse = await fetch(
    `https://api.github.com/graphql`,
    {
      method: "POST",
      headers,
      body: JSON.stringify({
        query: `mutation {addProjectV2DraftIssue(input: {projectId: "${projectNodeId}" title: "[FROM-APP] ${title}" body: "${draftBody}"}) {projectItem {id}}}`,
      }),
    }
  );

  if (!addItemToProjectResponse.ok) {
    throw new Error(
      `Failed to add item to project: ${await addItemToProjectResponse.text()}`
    );
  }
}
