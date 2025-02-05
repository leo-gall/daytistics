import { DatabaseActivity } from "./activities.ts";
import { DatabaseWellbeing } from "./wellbeings.ts";

export interface DatabaseDaytistic {
  user_id: string;
  id: string;
  date: string;
  wellbeing_id: string;
  created_at: string;
  updated_at: string;
}

export interface Daytistic extends DatabaseDaytistic {
  wellbeing: DatabaseWellbeing;
  activities: DatabaseActivity[];
}
