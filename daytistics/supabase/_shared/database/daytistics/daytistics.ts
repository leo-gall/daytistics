import { SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { Daytistic } from "../../types/daytistics.ts";
import { DatabaseWellbeing } from "../../types/wellbeings.ts";
import { DatabaseActivity } from "../../types/activities.ts";

export async function fetchAllDaytistics(
  supabase: SupabaseClient
): Promise<Daytistic[]> {
  const daytistics = await supabase.from("daytistics").select("*");
  if (!daytistics.data) {
    throw new Error("No daytistics found.");
  }
  for (const daytistic of daytistics.data) {
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
  return daytistics.data;
}

export async function fetchSingleDaytistic(
  supabase: SupabaseClient,
  date: string
): Promise<Daytistic> {
  const daytistic = (
    await supabase.from("daytistics").select("*").eq("date", date).single()
  ).data as Daytistic;
  if (!daytistic) {
    throw new Error("Daytistic not found.");
  }
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

  return daytistic;
}

export async function fetchDaytisticsInRange(
  supabase: SupabaseClient,
  startDate: string,
  endDate: string
): Promise<Daytistic[]> {
  const daytistics = await supabase
    .from("daytistics")
    .select("*")
    .gte("date", startDate)
    .lte("date", endDate);
  if (!daytistics.data) {
    throw new Error("No daytistics found.");
  }
  for (const daytistic of daytistics.data) {
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
  return daytistics.data;
}
