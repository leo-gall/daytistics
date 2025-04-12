import { SupabaseClient } from "jsr:@supabase/supabase-js@2";
import {
  DatabaseActivity,
  DatabaseDiaryEntry,
  DatabaseWellbeing,
  Daytistic,
} from "../_shared/types.ts";

export async function fetchDaytistics(
  supabase: SupabaseClient,
  options?: {
    date?: Date;
    range?: {
      start: Date;
      end: Date;
    };
  },
): Promise<Daytistic[]> {
  let query = supabase.from("daytistics").select("*");

  if (options?.date) {
    query = query.eq("date", options.date);
  } else if (options?.range) {
    query = query
      .gte("date", options.range.start)
      .lte("date", options.range.end);
  }

  const daytistics = await query;

  for (const daytistic of daytistics.data ?? []) {
    daytistic.date = new Date(daytistic.date).toLocaleDateString();

    const wellbeing = (
      await supabase
        .from("wellbeings")
        .select("*")
        .eq("daytistic_id", daytistic.id)
        .single()
    ).data as DatabaseWellbeing;
    if (wellbeing) {
      daytistic.wellbeing = wellbeing;
    }

    const diaryEntry = (
      await supabase
        .from("diary_entries")
        .select("*")
        .eq("daytistic_id", daytistic.id)
        .single()
    ).data as DatabaseDiaryEntry;
    if (diaryEntry) {
      daytistic.diary_entry = diaryEntry;
    }

    const activities = await supabase
      .from("activities")
      .select("*")
      .eq("daytistic_id", daytistic.id);
    daytistic.activities = activities.data as DatabaseActivity[];
  }
  return daytistics.data ?? [];
}
