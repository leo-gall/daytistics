create
or replace function "delete_account"() returns void language sql
set
    search_path = '' security definer as $$
delete from
    auth.users
where
    id = auth.uid();

$$;