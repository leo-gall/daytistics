import { hasThrownGraphQLError } from "../_shared/validation.ts";

const PROJECT_ID = parseInt(Deno.env.get("GITHUB_ROADMAP_PROJECT_ID") || "6");
const HEADERS = {
  Authorization: `Bearer ${Deno.env.get("GITHUB_AUTH_TOKEN")}`,
  "Content-Type": "application/json",
};

const GITHUB_API_URL = "https://api.github.com/graphql";
const GITHUB_LOGIN = Deno.env.get("GITHUB_LOGIN") || "leo-gall";

async function getProjectNodeId(projectId: number) {
  const projectNodeIdResponse = await fetch(
    GITHUB_API_URL,
    {
      method: "POST",
      headers: HEADERS,
      body: JSON.stringify({
        query:
          `query{user(login: "${GITHUB_LOGIN}") {projectV2(number: ${projectId}){id}}}`,
      }),
    },
  );

  if (await hasThrownGraphQLError(projectNodeIdResponse)) {
    throw new Error(
      `Failed to get project node ID: ${await projectNodeIdResponse.text()}`,
    );
  }

  const projectNodeId = (await projectNodeIdResponse.json()).data.user.projectV2
    .id;

  return projectNodeId;
}

async function addDraftToProject(
  projectNodeId: string,
  title: string,
  description: string,
  kind: "bug" | "feature" = "feature",
) {
  const addItemToProjectResponse = await fetch(
    `https://api.github.com/graphql`,
    {
      method: "POST",
      headers: HEADERS,
      body: JSON.stringify({
        query: `mutation {
          addProjectV2DraftIssue(input: {
            projectId: "${projectNodeId}",
            title: "[${kind.toUpperCase()}] ${title}",
            body: """${description}""",
          }) {
            projectItem {
              id
            }
          }
        }`,
      }),
    },
  );

  if (await hasThrownGraphQLError(addItemToProjectResponse)) {
    throw new Error(
      `Failed to add draft issue to project: ${await addItemToProjectResponse
        .text()}`,
    );
  }

  const { data: { addProjectV2DraftIssue: { projectItem } } } =
    await addItemToProjectResponse.json();

  return projectItem.id as string;
}

async function updateDraftStatus(
  projectNodeId: string,
  projectItemId: string,
) {
  const statusFieldIdResponse = await fetch(
    `https://api.github.com/graphql`,
    {
      method: "POST",
      headers: HEADERS,
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

  if (await hasThrownGraphQLError(statusFieldIdResponse)) {
    throw new Error(
      `Failed to get status field ID: ${await statusFieldIdResponse.text()}`,
    );
  }

  const statusFieldData = (await statusFieldIdResponse.json()).data.node
    .fields
    .nodes
    .find((field: { name: string }) => field.name === "Status")!;

  const statusOptionId = statusFieldData.options.find(
    (option: { name: string }) => option.name === "Todo (From App)",
  )?.id;

  const updateStatusResponse = await fetch(
    GITHUB_API_URL,
    {
      method: "POST",
      headers: HEADERS,
      body: JSON.stringify({
        query: `mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "${projectNodeId}",
            itemId: "${projectItemId}",
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

  if (await hasThrownGraphQLError(updateStatusResponse)) {
    throw new Error(
      `Failed to update draft issue status in project: ${await updateStatusResponse
        .text()}`,
    );
  }
}

export async function addToRoadmap(
  title: string,
  description: string,
  kind: "bug" | "feature" = "feature",
) {
  const projectNodeId = await getProjectNodeId(PROJECT_ID);
  const projectItemId = await addDraftToProject(
    projectNodeId,
    title,
    description,
    kind,
  );
  await updateDraftStatus(projectNodeId, projectItemId);
}
