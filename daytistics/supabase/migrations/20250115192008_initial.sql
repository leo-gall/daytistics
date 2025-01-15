-- TODO: Add Security (Row Level Security, Policies, etc.)

-- Table: wellbeing_entry
CREATE TABLE wellbeing_entry (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    time_for_me SMALLINT CHECK (time_for_me BETWEEN 0 AND 10),
    health SMALLINT CHECK (health BETWEEN 0 AND 10),
    productivity SMALLINT CHECK (productivity BETWEEN 0 AND 10),
    happiness SMALLINT CHECK (happiness BETWEEN 0 AND 10),
    recovery SMALLINT CHECK (recovery BETWEEN 0 AND 10),
    gratitude SMALLINT CHECK (gratitude BETWEEN 0 AND 10),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: diary_entry
CREATE TABLE diary_entry (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    happiness_moment TEXT NOT NULL,
    short_entry TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: daytistic_entry
CREATE TABLE daytistic_entry (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    wellbeing_entry_id UUID REFERENCES wellbeing_entry(id) ON DELETE SET NULL,
    diary_entry_id UUID REFERENCES diary_entry(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: activity_entry
CREATE TABLE activity_entry (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    daytistic_entry_id UUID NOT NULL REFERENCES daytistic_entry(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);


