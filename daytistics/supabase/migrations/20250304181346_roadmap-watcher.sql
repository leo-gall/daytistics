CREATE
OR REPLACE FUNCTION "supabase_functions"."http_request"() RETURNS TRIGGER AS $$
DECLARE
    response jsonb;

url text := 'https://api.github.com/graphql';

method text := 'POST';

headers jsonb := jsonb_build_object(
    'Authorization',
    format('Bearer %s', current_setting('GITHUB_TOKEN')),
    'Content-Type',
    'application/json'
);

body jsonb := jsonb_build_object(
    'query',
    format(
        'mutation {addProjectV2DraftIssue(input: {projectId: ''%s'', title: ''%s'', body: ''%s''}) {projectItem {id}}}',
        current_setting('GITHUB_BUGTRACKER_PROJECT_ID'),
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

CREATE TRIGGER "Update Github Bugtracker" AFTER
INSERT
    ON "public"."bug_reports" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"();