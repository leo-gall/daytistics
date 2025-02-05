export interface DatabaseWellbeing {
  id: string;
  health?: number;
  productivity?: number;
  happiness?: number;
  recovery?: number;
  sleep?: number;
  stress?: number;
  energy?: number;
  focus?: number;
  mood?: number;
  gratitude?: number;
  created_at: string;
  updated_at: string;
}
