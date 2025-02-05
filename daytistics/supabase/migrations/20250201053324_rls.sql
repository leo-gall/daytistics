-- Daytistics is the central record  
CREATE TABLE IF NOT EXISTS public .daytistics (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    date date NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    CONSTRAINT daytistics_user_id_fkey FOREIGN KEY(user_id) REFERENCES auth.users(id) ON
    DELETE
        CASCADE
);

-- Activities depend on a daytistic  
CREATE TABLE IF NOT EXISTS public .activities (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    daytistic_id uuid NOT NULL,
    name text NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    CONSTRAINT activities_daytistic_id_fkey FOREIGN KEY(daytistic_id) REFERENCES public .daytistics(id) ON
    DELETE
        CASCADE
);

-- Diary entries become children of daytistics  
CREATE TABLE IF NOT EXISTS public .diary_entries (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    daytistic_id uuid NOT NULL,
    happiness_moment text NOT NULL,
    short_entry text,
    created_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    CONSTRAINT diary_entries_daytistic_id_fkey FOREIGN KEY(daytistic_id) REFERENCES public .daytistics(id) ON
    DELETE
        CASCADE
);

-- Wellbeings become children of daytistics  
CREATE TABLE IF NOT EXISTS public .wellbeings (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    daytistic_id uuid NOT NULL,
    time_for_me smallint,
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
    created_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    CONSTRAINT wellbeings_daytistic_id_fkey FOREIGN KEY(daytistic_id) REFERENCES public .daytistics(id) ON
    DELETE
        CASCADE,
        CONSTRAINT wellbeings_energy_check CHECK (
            energy IS NULL
            OR (
                energy >= 0
                AND energy <= 10
            )
        ),
        CONSTRAINT wellbeings_focus_check CHECK (
            focus IS NULL
            OR (
                focus >= 0
                AND focus <= 10
            )
        ),
        CONSTRAINT wellbeings_gratitude_check CHECK (
            gratitude IS NULL
            OR (
                gratitude >= 0
                AND gratitude <= 10
            )
        ),
        CONSTRAINT wellbeings_happiness_check CHECK (
            happiness IS NULL
            OR (
                happiness >= 0
                AND happiness <= 10
            )
        ),
        CONSTRAINT wellbeings_health_check CHECK (
            health IS NULL
            OR (
                health >= 0
                AND health <= 10
            )
        ),
        CONSTRAINT wellbeings_mood_check CHECK (
            mood IS NULL
            OR (
                mood >= 0
                AND mood <= 10
            )
        ),
        CONSTRAINT wellbeings_productivity_check CHECK (
            productivity IS NULL
            OR (
                productivity >= 0
                AND productivity <= 10
            )
        ),
        CONSTRAINT wellbeings_recovery_check CHECK (
            recovery IS NULL
            OR (
                recovery >= 0
                AND recovery <= 10
            )
        ),
        CONSTRAINT wellbeings_sleep_check CHECK (
            sleep IS NULL
            OR (
                sleep >= 0
                AND sleep <= 10
            )
        ),
        CONSTRAINT wellbeings_stress_check CHECK (
            stress IS NULL
            OR (
                stress >= 0
                AND stress <= 10
            )
        ),
        CONSTRAINT wellbeings_time_for_me_check CHECK (
            time_for_me IS NULL
            OR (
                time_for_me >= 0
                AND time_for_me <= 10
            )
        )
);

-- Conversations now also belong to a daytistic  
CREATE TABLE IF NOT EXISTS public .conversations (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    daytistic_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    user_id uuid,
    title text,
    CONSTRAINT conversations_daytistic_id_fkey FOREIGN KEY(daytistic_id) REFERENCES public .daytistics(id) ON
    DELETE
        CASCADE,
        CONSTRAINT conversations_user_id_fkey FOREIGN KEY(user_id) REFERENCES auth.users(id) ON
    DELETE
    SET
        NULL
);

-- Conversation messages are tied to conversations  
CREATE TABLE IF NOT EXISTS public .conversation_messages (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc' :: text, now()) NOT NULL,
    conversation_id uuid NOT NULL,
    query text NOT NULL,
    reply text NOT NULL,
    called_functions text [ ],
    CONSTRAINT conversation_messages_conversation_id_fkey FOREIGN KEY(conversation_id) REFERENCES public .conversations(id) ON
    DELETE
        CASCADE
);