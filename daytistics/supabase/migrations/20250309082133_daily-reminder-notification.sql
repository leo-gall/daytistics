ALTER TABLE
    public .user_settings DROP COLUMN notifications;

ALTER TABLE
    public .user_settings
ADD
    COLUMN daily_reminder_time TIME;

CREATE EXTENSION pg_cron;

-- Increase work_mem to avoid out of memory error
select
    cron.schedule(
        'invoke-function-every-minute',
        '* * * * *',
        -- every minute
        $$
        select
            net.http_post(
                url := (
                    select
                        decrypted_secret
                    from
                        vault.decrypted_secrets
                    where
                        name = 'PROJECT_URL'
                ) || '/functions/v1/send-notifications',
                headers := jsonb_build_object(
                    'Content-type',
                    'application/json',
                    'Authorization',
                    'Bearer ' || (
                        select
                            decrypted_secret
                        from
                            vault.decrypted_secrets
                        where
                            name = 'SERVICE_ROLE_KEY'
                    )
                )
            ) as request_id;

$$
);

SET
    work_mem = '1024MB';