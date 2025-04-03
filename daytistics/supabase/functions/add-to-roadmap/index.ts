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
    const { user, error: supabaseInitError } = await initSupabase(req, {
      withAuth: true,
    });
    if (supabaseInitError) return supabaseInitError;

    const _body = await req.json();
    const { data: body, error: validateError } = await validateZodSchema(
      AddToRoadmapObject,
      _body,
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
  user: User,
) {
  const projectNodeIdResponse = await fetch(`https://api.github.com/graphql`, {
    method: "POST",
    headers,
    body: JSON.stringify({
      query:
        `query{user(login: "leo-gall") {projectV2(number: ${PROJECT_ID}){id}}}`,
    }),
  });

  const projectNodeId = (await projectNodeIdResponse.json()).data.user.projectV2
    .id;

  const statusFieldIdResponse = await fetch(
    `https://api.github.com/graphql`,
    {
      method: "POST",
      headers,
      body: JSON.stringify({
        query: `query {
          node(id: "${projectNodeId}") {
            ... on ProjectV2 {
              fields(first: 20) {
                nodes {
                  ... on ProjectV2Field {
                    id
                    name
                  }
                  ... on ProjectV2IterationField {
                    id
                    name
                    configuration {
                      iterations {
                        startDate
                        id
                      }
                    }
                  }
                  ... on ProjectV2SingleSelectField {
                    id
                    name
                    options {
                      id
                      name
                    }
                  }
                }
              }
            }
          }
        }`,
      }),
    },
  );

  const statusFieldData = (await statusFieldIdResponse.json()).data.node.fields
    .nodes
    .find((field: { name: string }) => field.name === "Status")!;

  const draftBody = description +
    "\n\n---\n\nThis item was automatically created from the app by " +
    user.id;

  const statusOptionId = statusFieldData.options.find(
    (option: { name: string }) =>
      option.name ===
        (roadmap === "features" ? "Todo (Features)" : "Todo (Bugs)"),
  )?.id;

  if (!statusOptionId) {
    throw new Error("Failed to find the appropriate status option ID.");
  }

  const addItemToProjectResponse = await fetch(
    `https://api.github.com/graphql`,
    {
      method: "POST",
      headers,
      body: JSON.stringify({
        query: `mutation {
          addProjectV2DraftIssue(input: {
            projectId: "${projectNodeId}",
            title: "[FROM-APP] ${title}",
            body: """${draftBody}""",
          }) {
            projectItem {
              id
            }
          }
        }`,
      }),
    },
  );

  if (!addItemToProjectResponse.ok) {
    throw new Error(
      `Failed to add draft issue to project: ${await addItemToProjectResponse
        .text()}`,
    );
  }

  const { data: { addProjectV2DraftIssue: { projectItem } } } =
    await addItemToProjectResponse.json();

  const updateStatusResponse = await fetch(
    `https://api.github.com/graphql`,
    {
      method: "POST",
      headers,
      body: JSON.stringify({
        query: `mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "${projectNodeId}",
            itemId: "${projectItem.id}",
            fieldId: "${statusFieldData.id}",
            value: { singleSelectOptionId: "${statusOptionId}" }
          }) {
            projectV2Item {
              id
            }
          }
        }`,
      }),
    },
  );

  if (!updateStatusResponse.ok) {
    throw new Error(
      `Failed to update status field: ${await updateStatusResponse.text()}`,
    );
  }

  if (!addItemToProjectResponse.ok) {
    throw new Error(
      `Failed to add item to project: ${await addItemToProjectResponse.text()}`,
    );
  }
}
