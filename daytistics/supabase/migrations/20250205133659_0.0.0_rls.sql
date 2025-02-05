alter table
    public .daytistics enable row level security;

create policy daytistics_select_policy on public .daytistics for
select
    using (user_id = auth.uid());

create policy daytistics_insert_policy on public .daytistics for
insert
    with check (user_id = auth.uid());

create policy daytistics_update_policy on public .daytistics for
update
    using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy daytistics_delete_policy on public .daytistics for
delete
    using (user_id = auth.uid());

alter table
    public .activities enable row level security;

create policy activities_select_policy on public .activities for
select
    using (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = activities.daytistic_id
                and d.user_id = auth.uid()
        )
    );

create policy activities_insert_policy on public .activities for
insert
    with check (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = activities.daytistic_id
                and d.user_id = auth.uid()
        )
    );

create policy activities_update_policy on public .activities for
update
    using (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = activities.daytistic_id
                and d.user_id = auth.uid()
        )
    ) with check (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = activities.daytistic_id
                and d.user_id = auth.uid()
        )
    );

create policy activities_delete_policy on public .activities for
delete
    using (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = activities.daytistic_id
                and d.user_id = auth.uid()
        )
    );

alter table
    public .diary_entries enable row level security;

create policy diary_entries_select_policy on public .diary_entries for
select
    using (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = diary_entries.daytistic_id
                and d.user_id = auth.uid()
        )
    );

create policy diary_entries_insert_policy on public .diary_entries for
insert
    with check (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = diary_entries.daytistic_id
                and d.user_id = auth.uid()
        )
    );

create policy diary_entries_update_policy on public .diary_entries for
update
    using (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = diary_entries.daytistic_id
                and d.user_id = auth.uid()
        )
    ) with check (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = diary_entries.daytistic_id
                and d.user_id = auth.uid()
        )
    );

create policy diary_entries_delete_policy on public .diary_entries for
delete
    using (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = diary_entries.daytistic_id
                and d.user_id = auth.uid()
        )
    );

alter table
    public .wellbeings enable row level security;

create policy wellbeings_select_policy on public .wellbeings for
select
    using (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = wellbeings.daytistic_id
                and d.user_id = auth.uid()
        )
    );

create policy wellbeings_insert_policy on public .wellbeings for
insert
    with check (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = wellbeings.daytistic_id
                and d.user_id = auth.uid()
        )
    );

create policy wellbeings_update_policy on public .wellbeings for
update
    using (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = wellbeings.daytistic_id
                and d.user_id = auth.uid()
        )
    ) with check (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = wellbeings.daytistic_id
                and d.user_id = auth.uid()
        )
    );

create policy wellbeings_delete_policy on public .wellbeings for
delete
    using (
        exists (
            select
                1
            from
                public .daytistics d
            where
                d.id = wellbeings.daytistic_id
                and d.user_id = auth.uid()
        )
    );

alter table
    public .conversations enable row level security;

create policy conversations_select_policy on public .conversations for
select
    using (user_id = auth.uid());

create policy conversations_insert_policy on public .conversations for
insert
    with check (user_id = auth.uid());

create policy conversations_update_policy on public .conversations for
update
    using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy conversations_delete_policy on public .conversations for
delete
    using (user_id = auth.uid());

alter table
    public .conversation_messages enable row level security;

create policy conversation_messages_select_policy on public .conversation_messages for
select
    using (
        exists (
            select
                1
            from
                public .conversations c
            where
                c .id = conversation_messages.conversation_id
                and c .user_id = auth.uid()
        )
    );

create policy conversation_messages_insert_policy on public .conversation_messages for
insert
    with check (
        exists (
            select
                1
            from
                public .conversations c
            where
                c .id = conversation_messages.conversation_id
                and c .user_id = auth.uid()
        )
    );

create policy conversation_messages_update_policy on public .conversation_messages for
update
    using (
        exists (
            select
                1
            from
                public .conversations c
            where
                c .id = conversation_messages.conversation_id
                and c .user_id = auth.uid()
        )
    ) with check (
        exists (
            select
                1
            from
                public .conversations c
            where
                c .id = conversation_messages.conversation_id
                and c .user_id = auth.uid()
        )
    );

create policy conversation_messages_delete_policy on public .conversation_messages for
delete
    using (
        exists (
            select
                1
            from
                public .conversations c
            where
                c .id = conversation_messages.conversation_id
                and c .user_id = auth.uid()
        )
    );