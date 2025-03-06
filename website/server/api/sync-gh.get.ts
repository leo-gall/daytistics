export default defineEventHandler(async (event) => {
  if (
    event.headers.get("Authorization") !== `Bearer ${process.env.CRON_SECRET}`
  ) {
    return setResponseStatus(event, 401, "Unauthorized");
  }

  let latestBugReports: BugReport[] = [];
  let latestFeatureRequests: FeatureRequest[] = [];
  try {
    latestBugReports = await fetchDataOfLastDay<BugReport>("bug_reports");
    latestFeatureRequests = await fetchDataOfLastDay<FeatureRequest>(
      "feature_requests"
    );
  } catch (error) {
    setResponseStatus(event, 500, "Failed to fetch data from Supabase.");
  }

  try {
    const bugReportsNodeId = await getProjectNodeId("leo-gall", 7);
    const featureRequestsNodeId = await getProjectNodeId("leo-gall", 6);

    latestBugReports.forEach(async (bugReport) => {
      await addItemToProject({
        id: bugReportsNodeId,
        title: bugReport.title,
        body: bugReport.description,
      });
    });

    latestFeatureRequests.forEach(async (featureRequest) => {
      await addItemToProject({
        id: featureRequestsNodeId,
        title: featureRequest.title,
        body: featureRequest.description,
      });
    });
  } catch (error) {
    setResponseStatus(event, 500, "Failed to interact with GitHub API.");
  }

  setResponseStatus(
    event,
    200,
    "Successfully synced bug reports and feature requests with GitHub projects."
  );
});

async function fetchDataOfLastDay<T>(table: string): Promise<T[]> {
  let data: T[] = [];
  const timestamp = new Date(Date.now() - 5 * 60 * 1000).toISOString();
  await $fetch(`${process.env.SUPABASE_ADDRESS}/graphql/v1`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apiKey: process.env.SUPABASE_SERVICE_ROLE_KEY || "",
      Authorization: `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY || ""}`,
    },
    body: {
      query: `
      query {
        ${table}Collection(filter: {created_at: {gte: "${timestamp}"}}) { 
          edges {
            node {
              title,
              description
            }
          }
        }
      }
    `,
    },
    onResponse: ({ response, error }) => {
      data = response._data?.data[`${table}Collection`]?.edges.map(
        (edge: any) => edge.node as T
      );
    },
  });

  return data || [];
}

async function addItemToProject(options: {
  id: string;
  title: string;
  body: string;
}): Promise<void> {
  const headers = {
    Authorization: `Bearer ${process.env.GITHUB_TOKEN}`,
    "Content-Type": "application/json",
  };

  const draftBody =
    options.body +
    "\n\n---\n\nThis item was automatically fetched from the Supabase database on " +
    new Date().toISOString();

  const body = {
    query: `mutation {addProjectV2DraftIssue(input: {projectId: "${options.id}" title: "[SB] ${options.title}" body: "${draftBody}"}) {projectItem {id}}}`,
  };

  await $fetch(`https://api.github.com/graphql`, {
    method: "POST",
    headers,
    body,
  });
}

async function getProjectNodeId(user: string, projectId: number) {
  const headers = {
    Authorization: `Bearer ${process.env.GITHUB_TOKEN}`,
    "Content-Type": "application/json",
  };

  const body = {
    query: `query{user(login: "${user}") {projectV2(number: ${projectId}){id}}}`,
  };

  let data: string;
  await $fetch(`https://api.github.com/graphql`, {
    method: "POST",
    headers,
    body,
    onResponse: ({ response: { _data } }) => {
      data = _data.data.user.projectV2.id;
    },
  });

  return data!;
}

type BugReport = {
  title: string;
  description: string;
};

type FeatureRequest = {
  title: string;
  description: string;
};
