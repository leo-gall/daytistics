import { Session, SupabaseClient, User } from "jsr:@supabase/supabase-js@2";
import { faker } from "npm:@faker-js/faker";
import { v4 as uuidv4 } from "npm:uuid";
import {
  Conversation,
  DatabaseActivity,
  DatabaseDaytistic,
  DatabaseWellbeing,
} from "../_shared/types.ts";

export async function doAsTempUser(
  supabase: SupabaseClient,
  callback: (user: User, session: Session) => Promise<void>
) {
  const {
    data: { user, session },
    error,
  } = await supabase.auth.signInAnonymously();
  if (error) throw error;

  await callback(user!, session!);

  await supabase.auth.signOut();
}

export async function generateFakeDaytistics(
  amount: number,
  user: User,
  supabase: SupabaseClient
) {
  const daytistics: DatabaseDaytistic[] = [];
  const wellbeings: DatabaseWellbeing[] = [];
  const activities: DatabaseActivity[] = [];
  const startingDate = new Date();

  startingDate.setDate(startingDate.getDate() - amount);

  for (let i = 0; i < amount; i++) {
    const date = new Date(startingDate);
    date.setDate(startingDate.getDate() + i);

    const daytistic: DatabaseDaytistic = {
      user_id: user.id,
      id: faker.string.uuid(),
      date: date.toISOString(),
      created_at: date.toISOString(),
      updated_at: date.toISOString(),
    };

    const wellbeing: DatabaseWellbeing = {
      id: faker.string.uuid(),
      daytistic_id: daytistic.id,
      me_time: faker.number.int({ min: 1, max: 5 }),
      health: faker.number.int({ min: 1, max: 5 }),
      productivity: faker.number.int({ min: 1, max: 5 }),
      happiness: faker.number.int({ min: 1, max: 5 }),
      recovery: faker.number.int({ min: 1, max: 5 }),
      sleep: faker.number.int({ min: 1, max: 5 }),
      stress: faker.number.int({ min: 1, max: 5 }),
      energy: faker.number.int({ min: 1, max: 5 }),
      focus: faker.number.int({ min: 1, max: 5 }),
      mood: faker.number.int({ min: 1, max: 5 }),
      gratitude: faker.number.int({ min: 1, max: 5 }),
      created_at: date.toISOString(),
      updated_at: date.toISOString(),
    };

    const amountOfActivities = faker.number.int({ min: 1, max: 5 });

    for (let j = 0; j < amountOfActivities; j++) {
      const activity: DatabaseActivity = {
        id: faker.string.uuid(),
        name: faker.hacker.verb(),
        daytistic_id: daytistic.id,
        start_time: new Date(
          date.getTime() +
            faker.number.int({ min: 0, max: 12 * 60 * 60 * 1000 })
        ).toISOString(),
        end_time: new Date(
          date.getTime() +
            faker.number.int({
              min: 12 * 60 * 60 * 1000,
              max: 24 * 60 * 60 * 1000,
            })
        ).toISOString(),
        created_at: date.toISOString(),
        updated_at: date.toISOString(),
      };

      activities.push(activity);
    }

    wellbeings.push(wellbeing);
    daytistics.push(daytistic);
  }

  // insert all the data
  await supabase.from("daytistics").insert(daytistics);
  await supabase.from("wellbeings").insert(wellbeings);
  await supabase.from("activities").insert(activities);

  return { daytistics, wellbeings, activities };
}

export async function generateConversations(
  user: User,
  supabase: SupabaseClient,
  conversationsCount: number,
  messagesPerConversation: number
) {
  for (let i = 0; i < conversationsCount; i++) {
    const conversationId = uuidv4();
    const conv: Conversation = {
      id: conversationId,
      title: `Conversation ${i}`,
      user_id: user.id,
      created_at: new Date(Date.now() - i * 86400000).toISOString(),
      updated_at: new Date().toISOString(),
      messages: Array.from({
        length: messagesPerConversation,
      }).map(() => ({
        id: uuidv4(),
        query: faker.lorem.sentence(),
        reply: faker.lorem.sentence(),
        conversation_id: conversationId,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        called_functions: [],
        toSupabase: function () {
          return {
            id: this.id,
            query: this.query,
            reply: this.reply,
            conversation_id: this.conversation_id,
            created_at: this.created_at,
            updated_at: this.updated_at,
            called_functions: this.called_functions,
          };
        },
      })),
      toSupabase: function () {
        return {
          conversation: {
            id: this.id,
            title: this.title,
            user_id: this.user_id,
            created_at: this.created_at,
            updated_at: this.updated_at,
          },
          messages: this.messages.map((msg) => msg.toSupabase()),
        };
      },
    };
    const { error } = await supabase
      .from("conversations")
      .insert(conv.toSupabase().conversation);
    if (error) throw error;

    const { error: messagesError } = await supabase
      .from("conversation_messages")
      .insert(conv.toSupabase().messages);
    if (messagesError) throw messagesError;
  }
}
