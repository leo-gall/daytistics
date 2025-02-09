export interface DatabaseWellbeing {
  daytistic_id: string;
  id: string;
  me_time?: number;
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

export interface DatabaseActivity {
  id: string;
  name: string;
  daytistic_id: string;
  start_time: string;
  end_time: string;
  created_at: string;
  updated_at: string;
}

export interface DatabaseDaytistic {
  user_id: string;
  id: string;
  date: string;
  created_at: string;
  updated_at: string;
}

export interface Daytistic extends DatabaseDaytistic {
  wellbeing: DatabaseWellbeing;
  activities: DatabaseActivity[];
}

export interface DatabaseConversationMessage {
  id: string;
  query: string;
  reply: string;
  conversation_id: string;
  created_at: string; // ISO-String
  updated_at: string; // ISO-String
  called_functions: string[];
}

export interface DatabaseConversation {
  id: string;
  title: string;
  created_at: string; // ISO-String
  updated_at: string; // ISO-String
  user_id: string;
}

export interface Conversation extends DatabaseConversation {
  messages: DatabaseConversationMessage[];
}
