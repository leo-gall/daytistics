ALTER TABLE
    public .user_settings DROP COLUMN notifications;

ALTER TABLE
    public .user_settings
ADD
    COLUMN daily_reminder_time TIME;