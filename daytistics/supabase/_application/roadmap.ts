const PROJECT_ID = parseInt(Deno.env.get("GITHUB_ROADMAP_PROJECT_ID") || "6");
const HEADERS = {
    Authorization: `Bearer ${Deno.env.get("GITHUB_AUTH_TOKEN")}`,
    "Content-Type": "application/json",
};
const GITHUB_API_URL = "https://api.github.com/graphql";

export async function getProjectNodeId(projectId: number) {
    const projectNodeIdResponse = await fetch(
        GITHUB_API_URL,
        {
            method: "POST",
            headers: HEADERS,
            body: JSON.stringify({
                query:
                    `query{user(login: "leo-gall") {projectV2(number: ${projectId}){id}}}`,
            }),
        },
    );

    const projectNodeId =
        (await projectNodeIdResponse.json()).data.user.projectV2
            .id;

    return projectNodeId;
}
