

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";





SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."activities" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "daytistic_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "start_time" timestamp with time zone NOT NULL,
    "end_time" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."activities" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."daytistics" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "date" "date" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "wellbeing_id" "uuid",
    "diary_entry_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."daytistics" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."diary_entries" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "happiness_moment" "text" NOT NULL,
    "short_entry" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."diary_entries" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wellbeings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "time_for_me" smallint,
    "health" smallint,
    "productivity" smallint,
    "happiness" smallint,
    "recovery" smallint,
    "sleep" smallint,
    "stress" smallint,
    "energy" smallint,
    "focus" smallint,
    "mood" smallint,
    "gratitude" smallint,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "wellbeings_energy_check" CHECK ((("energy" >= 0) AND ("energy" <= 10))),
    CONSTRAINT "wellbeings_focus_check" CHECK ((("focus" >= 0) AND ("focus" <= 10))),
    CONSTRAINT "wellbeings_gratitude_check" CHECK ((("gratitude" >= 0) AND ("gratitude" <= 10))),
    CONSTRAINT "wellbeings_happiness_check" CHECK ((("happiness" >= 0) AND ("happiness" <= 10))),
    CONSTRAINT "wellbeings_health_check" CHECK ((("health" >= 0) AND ("health" <= 10))),
    CONSTRAINT "wellbeings_mood_check" CHECK ((("mood" >= 0) AND ("mood" <= 10))),
    CONSTRAINT "wellbeings_productivity_check" CHECK ((("productivity" >= 0) AND ("productivity" <= 10))),
    CONSTRAINT "wellbeings_recovery_check" CHECK ((("recovery" >= 0) AND ("recovery" <= 10))),
    CONSTRAINT "wellbeings_sleep_check" CHECK ((("sleep" >= 0) AND ("sleep" <= 10))),
    CONSTRAINT "wellbeings_stress_check" CHECK ((("stress" >= 0) AND ("stress" <= 10))),
    CONSTRAINT "wellbeings_time_for_me_check" CHECK ((("time_for_me" >= 0) AND ("time_for_me" <= 10)))
);


ALTER TABLE "public"."wellbeings" OWNER TO "postgres";


ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."daytistics"
    ADD CONSTRAINT "daytistics_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."diary_entries"
    ADD CONSTRAINT "diary_entries_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wellbeings"
    ADD CONSTRAINT "wellbeings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_daytistic_id_fkey" FOREIGN KEY ("daytistic_id") REFERENCES "public"."daytistics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."daytistics"
    ADD CONSTRAINT "daytistics_diary_entry_id_fkey" FOREIGN KEY ("diary_entry_id") REFERENCES "public"."diary_entries"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."daytistics"
    ADD CONSTRAINT "daytistics_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."daytistics"
    ADD CONSTRAINT "daytistics_wellbeing_id_fkey" FOREIGN KEY ("wellbeing_id") REFERENCES "public"."wellbeings"("id") ON DELETE SET NULL;



CREATE POLICY "Users can delete their own activities" ON "public"."activities" FOR DELETE USING (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."id" = "activities"."daytistic_id"))));



CREATE POLICY "Users can delete their own daytistics" ON "public"."daytistics" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own diary entries" ON "public"."diary_entries" FOR DELETE USING (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."diary_entry_id" = "diary_entries"."id"))));



CREATE POLICY "Users can delete their own wellbeings" ON "public"."wellbeings" FOR DELETE USING (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."wellbeing_id" = "wellbeings"."id"))));



CREATE POLICY "Users can insert their own activities" ON "public"."activities" FOR INSERT WITH CHECK (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."id" = "activities"."daytistic_id"))));



CREATE POLICY "Users can insert their own daytistics" ON "public"."daytistics" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own diary entries" ON "public"."diary_entries" FOR INSERT WITH CHECK (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."diary_entry_id" = "daytistics"."id"))));



CREATE POLICY "Users can insert their own wellbeings" ON "public"."wellbeings" FOR INSERT WITH CHECK (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."wellbeing_id" = "daytistics"."id"))));



CREATE POLICY "Users can select their own activities" ON "public"."activities" FOR SELECT USING (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."id" = "activities"."daytistic_id"))));



CREATE POLICY "Users can select their own daytistics" ON "public"."daytistics" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can select their own diary entries" ON "public"."diary_entries" FOR SELECT USING (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."diary_entry_id" = "daytistics"."id"))));



CREATE POLICY "Users can select their own wellbeings" ON "public"."wellbeings" FOR SELECT USING (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."wellbeing_id" = "daytistics"."id"))));



CREATE POLICY "Users can update their own activities" ON "public"."activities" FOR UPDATE USING (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."id" = "activities"."daytistic_id")))) WITH CHECK (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."id" = "activities"."daytistic_id"))));



CREATE POLICY "Users can update their own daytistics" ON "public"."daytistics" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own diary entries" ON "public"."diary_entries" FOR UPDATE USING (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."diary_entry_id" = "diary_entries"."id")))) WITH CHECK (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."diary_entry_id" = "diary_entries"."id"))));



CREATE POLICY "Users can update their own wellbeings" ON "public"."wellbeings" FOR UPDATE USING (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."wellbeing_id" = "wellbeings"."id")))) WITH CHECK (("auth"."uid"() = ( SELECT "daytistics"."user_id"
   FROM "public"."daytistics"
  WHERE ("daytistics"."wellbeing_id" = "wellbeings"."id"))));



ALTER TABLE "public"."activities" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."daytistics" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."diary_entries" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."wellbeings" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";









































































































































































































GRANT ALL ON TABLE "public"."activities" TO "anon";
GRANT ALL ON TABLE "public"."activities" TO "authenticated";
GRANT ALL ON TABLE "public"."activities" TO "service_role";



GRANT ALL ON TABLE "public"."daytistics" TO "anon";
GRANT ALL ON TABLE "public"."daytistics" TO "authenticated";
GRANT ALL ON TABLE "public"."daytistics" TO "service_role";



GRANT ALL ON TABLE "public"."diary_entries" TO "anon";
GRANT ALL ON TABLE "public"."diary_entries" TO "authenticated";
GRANT ALL ON TABLE "public"."diary_entries" TO "service_role";



GRANT ALL ON TABLE "public"."wellbeings" TO "anon";
GRANT ALL ON TABLE "public"."wellbeings" TO "authenticated";
GRANT ALL ON TABLE "public"."wellbeings" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;

--
-- Dumped schema changes for auth and storage
--

