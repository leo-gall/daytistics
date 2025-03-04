GRANT
SELECT
    ON vault.decrypted_secrets TO postgres;

CREATE
OR REPLACE FUNCTION "supabase_functions"."http_request"() RETURNS TRIGGER AS $$
DECLARE
    response jsonb;

url text := 'https://api.github.com/graphql';

github_token text := (
    SELECT
        decrypted_secret
    FROM
        vault.decrypted_secrets
    WHERE
        name = 'GITHUB_TOKEN'
    ORDER BY
        created_at DESC
    LIMIT
        1
);

github_bugtracker_project_id text := (
    SELECT
        decrypted_secret
    FROM
        vault.decrypted_secrets
    WHERE
        name = 'GITHUB_BUGTRACKER_PROJECT_ID'
    ORDER BY
        created_at DESC
    LIMIT
        1
);

method text := 'POST';

headers jsonb := jsonb_build_object(
    'Authorization', format('Bearer %s', github_token), 'Content-Type', 'application/json'
);

body jsonb := jsonb_build_object(
    'query',
    format(
        'mutation {addProjectV2DraftIssue(input: {projectId: ''%s'', title: ''%s'', body: ''%s''}) {projectItem {id}}}',
        github_bugtracker_project_id,
        NEW .title,
        NEW .description
    )
);

BEGIN
    -- Make the HTTP request using pgnet
    response := pgnet.http_post(url, body, headers);

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER "my_webhook" AFTER
INSERT
    ON "public"."bug_reports" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"();