import { SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { DatabaseActivity } from "../types/activities.ts";
import { DatabaseWellbeing } from "../types/wellbeings.ts";
import { Daytistic } from "../types/daytistics.ts";

interface FetchDaytisticsOptions {
  date?: Date;
  range?: {
    start: Date;
    end: Date;
  };
}

export async function fetchDaytistics(
  supabase: SupabaseClient,
  options?: FetchDaytisticsOptions
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
        .eq("id", daytistic.wellbeing_id)
        .single()
    ).data as DatabaseWellbeing;
    if (wellbeing) {
      daytistic.wellbeing = wellbeing;
    }

    const activities = await supabase
      .from("activities")
      .select("*")
      .eq("daytistic_id", daytistic.id);
    daytistic.activities = activities.data as DatabaseActivity[];
  }
  return daytistics.data ?? [];
}
