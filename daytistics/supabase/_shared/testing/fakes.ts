// import faker from npm
import { faker } from "npm:@faker-js/faker";
import { DatabaseDaytistic } from "../types/daytistics.ts";
import { DatabaseActivity } from "../types/activities.ts";
import { DatabaseWellbeing } from "../types/wellbeings.ts";

export function generateFakeDaytistics(count: number, activitiesCount: number) {
  const daytistics: DatabaseDaytistic[] = [];
  const activities: DatabaseActivity[] = [];
  const wellbeings: DatabaseWellbeing[] = [];

  for (let i = 0; i < count; i++) {
    const date = faker.date.recent().toISOString();
    const wellbeing = generateFakeWellbeing();
    wellbeings.push(wellbeing);
    const daytistic: DatabaseDaytistic = {
      id: faker.string.uuid(),
      date,
      wellbeing_id: wellbeing.id,
      created_at: date,
      updated_at: date,
    };
    daytistics.push(daytistic);

    for (let j = 0; j < activitiesCount; j++) {
      const activity: DatabaseActivity = {
        id: faker.string.uuid(),
        daytistic_id: daytistic.id,
        name: faker.person.jobArea(),
        created_at: date,
        updated_at: date,
        start_time: faker.date.recent().toISOString(),
        end_time: faker.date.recent().toISOString(),
      };
      activities.push(activity);
    }
  }

  return { daytistics, activities, wellbeings };
}

export function generateFakeWellbeing(): DatabaseWellbeing {
  return {
    id: faker.string.uuid(),
    health: faker.number.int({ min: 0, max: 5 }),
    productivity: faker.number.int({ min: 0, max: 5 }),
    happiness: faker.number.int({ min: 0, max: 5 }),
    recovery: faker.number.int({ min: 0, max: 5 }),
    sleep: faker.number.int({ min: 0, max: 5 }),
    stress: faker.number.int({ min: 0, max: 5 }),
    energy: faker.number.int({ min: 0, max: 5 }),
    focus: faker.number.int({ min: 0, max: 5 }),
    mood: faker.number.int({ min: 0, max: 5 }),
    gratitude: faker.number.int({ min: 0, max: 5 }),
    created_at: faker.date.recent().toISOString(),
    updated_at: faker.date.recent().toISOString(),
  };
}
