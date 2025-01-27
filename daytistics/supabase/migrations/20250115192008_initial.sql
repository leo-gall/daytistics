
-- Table: wellbeing_entries
CREATE TABLE wellbeings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    time_for_me SMALLINT CHECK (time_for_me BETWEEN 0 AND 10),
    health SMALLINT CHECK (health BETWEEN 0 AND 10),
    productivity SMALLINT CHECK (productivity BETWEEN 0 AND 10),
    happiness SMALLINT CHECK (happiness BETWEEN 0 AND 10),
    recovery SMALLINT CHECK (recovery BETWEEN 0 AND 10),
    sleep SMALLINT CHECK (sleep BETWEEN 0 AND 10),
    stress SMALLINT CHECK (stress BETWEEN 0 AND 10),
    energy SMALLINT CHECK (energy BETWEEN 0 AND 10),
    focus SMALLINT CHECK (focus BETWEEN 0 AND 10),
    mood SMALLINT CHECK (mood BETWEEN 0 AND 10),
    gratitude SMALLINT CHECK (gratitude BETWEEN 0 AND 10),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: diary_entries
CREATE TABLE diary_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    happiness_moment TEXT NOT NULL,
    short_entry TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: daytistic_entries
CREATE TABLE daytistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    wellbeing_id UUID REFERENCES wellbeings(id) ON DELETE SET NULL,
    diary_entry_id UUID REFERENCES diary_entries(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: activity_entries
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    daytistic_id UUID NOT NULL REFERENCES daytistics(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
