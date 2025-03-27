DROP TRIGGER IF EXISTS handle_updated_at ON public .bug_reports;

DROP TRIGGER IF EXISTS handle_updated_at ON public .feature_requests;

DROP TABLE IF EXISTS public .bug_reports;

DROP TABLE IF EXISTS public .feature_requests;