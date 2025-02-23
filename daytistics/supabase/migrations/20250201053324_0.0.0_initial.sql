create table if not exists public .daytistics (
    id uuid default gen_random_uuid() primary key,
    date date not null,
    user_id uuid not null,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    constraint daytistics_user_id_fkey foreign key(user_id) references auth.users(id) on
    delete
        cascade
);

create table if not exists public .activities (
    id uuid default gen_random_uuid() primary key,
    daytistic_id uuid not null,
    name text not null,
    start_time timestamp with time zone not null,
    end_time timestamp with time zone not null,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    constraint activities_daytistic_id_fkey foreign key(daytistic_id) references public .daytistics(id) on
    delete
        cascade
);

create table if not exists public .diary_entries (
    id uuid default gen_random_uuid() primary key,
    daytistic_id uuid not null,
    happiness_moment text not null,
    short_entry text,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    constraint diary_entries_daytistic_id_fkey foreign key(daytistic_id) references public .daytistics(id) on
    delete
        cascade
);

create table if not exists public .wellbeings (
    id uuid default gen_random_uuid() primary key,
    daytistic_id uuid not null,
    me_time smallint,
    health smallint,
    productivity smallint,
    happiness smallint,
    recovery smallint,
    sleep smallint,
    stress smallint,
    energy smallint,
    focus smallint,
    mood smallint,
    gratitude smallint,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    constraint wellbeings_daytistic_id_fkey foreign key(daytistic_id) references public .daytistics(id) on
    delete
        cascade,
        constraint wellbeings_energy_check check (
            energy is null
            or (
                energy >= 0
                and energy <= 5
            )
        ),
        constraint wellbeings_focus_check check (
            focus is null
            or (
                focus >= 0
                and focus <= 5
            )
        ),
        constraint wellbeings_gratitude_check check (
            gratitude is null
            or (
                gratitude >= 0
                and gratitude <= 5
            )
        ),
        constraint wellbeings_happiness_check check (
            happiness is null
            or (
                happiness >= 0
                and happiness <= 5
            )
        ),
        constraint wellbeings_health_check check (
            health is null
            or (
                health >= 0
                and health <= 5
            )
        ),
        constraint wellbeings_mood_check check (
            mood is null
            or (
                mood >= 0
                and mood <= 5
            )
        ),
        constraint wellbeings_productivity_check check (
            productivity is null
            or (
                productivity >= 0
                and productivity <= 5
            )
        ),
        constraint wellbeings_recovery_check check (
            recovery is null
            or (
                recovery >= 0
                and recovery <= 5
            )
        ),
        constraint wellbeings_sleep_check check (
            sleep is null
            or (
                sleep >= 0
                and sleep <= 5
            )
        ),
        constraint wellbeings_stress_check check (
            stress is null
            or (
                stress >= 0
                and stress <= 5
            )
        ),
        constraint wellbeings_me_time_check check (
            me_time is null
            or (
                me_time >= 0
                and me_time <= 5
            )
        )
);

create table if not exists public .conversations (
    id uuid default gen_random_uuid() primary key,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    user_id uuid,
    title text,
    constraint conversations_user_id_fkey foreign key(user_id) references auth.users(id) on
    delete
        cascade
);

create table if not exists public .conversation_messages (
    id uuid default gen_random_uuid() primary key,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    conversation_id uuid not null,
    query text not null,
    reply text not null,
    called_functions text array,
    constraint conversation_messages_conversation_id_fkey foreign key(conversation_id) references public .conversations(id) on
    delete
        cascade
);

CREATE TABLE IF NOT EXISTS public .daily_token_budgets (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL,
    date date NOT NULL,
    input_tokens integer NOT NULL,
    output_tokens integer NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    CONSTRAINT daily_token_budgets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON
    DELETE
        CASCADE,
        CONSTRAINT unique_user_date UNIQUE (user_id, date)
);

create table if not exists public .user_settings (
    id uuid default gen_random_uuid() primary key,
    user_id uuid not null unique,
    conversation_analytics boolean default false,
    notifications boolean default true,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    constraint user_settings_user_id_fkey foreign key(user_id) references auth.users(id) on
    delete
        cascade
);

create table if not exists public .bug_reports (
    id uuid default gen_random_uuid() primary key,
    user_id uuid,
    title text not null,
    description text not null,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    constraint bug_reports_user_id_fkey foreign key(user_id) references auth.users(id) on
    delete
        cascade
);

create table if not exists public .feature_requests (
    id uuid default gen_random_uuid() primary key,
    user_id uuid,
    title text not null,
    description text not null,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    updated_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    constraint feature_requests_user_id_fkey foreign key(user_id) references auth.users(id) on
    delete
        cascade
);

create extension if not exists moddatetime schema extensions;

create trigger handle_updated_at before
update
    on public .daytistics for each row execute procedure moddatetime (updated_at);

create trigger handle_updated_at before
update
    on public .activities for each row execute procedure moddatetime (updated_at);

create trigger handle_updated_at before
update
    on public .diary_entries for each row execute procedure moddatetime (updated_at);

create trigger handle_updated_at before
update
    on public .wellbeings for each row execute procedure moddatetime (updated_at);

create trigger handle_updated_at before
update
    on public .conversations for each row execute procedure moddatetime (updated_at);

create trigger handle_updated_at before
update
    on public .conversation_messages for each row execute procedure moddatetime (updated_at);

create trigger handle_updated_at before
update
    on public .daily_token_budgets for each row execute procedure moddatetime (updated_at);

create trigger handle_updated_at before
update
    on public .user_settings for each row execute procedure moddatetime (updated_at);

create trigger handle_updated_at before
update
    on public .bug_reports for each row execute procedure moddatetime (updated_at);

create trigger handle_updated_at before
update
    on public .feature_requests for each row execute procedure moddatetime (updated_at);