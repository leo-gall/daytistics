// deno-lint-ignore no-explicit-any
type supabaseData = any;

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

export class ConversationMessage {
  id: string;
  query: string;
  reply: string;
  conversation_id: string;
  created_at: string;
  updated_at: string;
  called_functions: string[];

  constructor(
    id: string,
    query: string,
    reply: string,
    conversation_id: string,
    created_at: string,
    updated_at: string,
    called_functions: string[]
  ) {
    this.id = id;
    this.query = query;
    this.reply = reply;
    this.conversation_id = conversation_id;
    this.created_at = created_at;
    this.updated_at = updated_at;
    this.called_functions = called_functions;
  }

  static fromSupabase(supabaseData: supabaseData): ConversationMessage {
    return new ConversationMessage(
      supabaseData.id,
      supabaseData.query,
      supabaseData.reply,
      supabaseData.conversation_id,
      supabaseData.created_at,
      supabaseData.updated_at,
      supabaseData.called_functions
    );
  }

  toSupabase(): supabaseData {
    return {
      id: this.id,
      query: this.query,
      reply: this.reply,
      conversation_id: this.conversation_id,
      created_at: this.created_at,
      updated_at: this.updated_at,
      called_functions: this.called_functions,
    };
  }
}

export class Conversation {
  id: string;
  title: string;
  created_at: string;
  updated_at: string;
  user_id: string;
  messages: ConversationMessage[];

  constructor(
    id: string,
    title: string,
    created_at: string,
    updated_at: string,
    user_id: string,
    messages: ConversationMessage[]
  ) {
    this.id = id;
    this.title = title;
    this.created_at = created_at;
    this.updated_at = updated_at;
    this.user_id = user_id;
    this.messages = messages;
  }

  static fromSupabase(supabaseData: supabaseData): Conversation {
    return new Conversation(
      supabaseData.id,
      supabaseData.title,
      supabaseData.created_at,
      supabaseData.updated_at,
      supabaseData.user_id,
      (supabaseData.messages || []).map(ConversationMessage.fromSupabase)
    );
  }

  toSupabase() {
    return {
      conversation: {
        id: this.id,
        title: this.title,
        created_at: this.created_at,
        updated_at: this.updated_at,
        user_id: this.user_id,
      },
      messages: this.messages.map((message) => message.toSupabase()),
    };
  }
}

export interface AdminToken {
  partial: string;
  permissions: string[];
}
