// // // daytistics.test.ts
// // import {
// //   fetchAllDaytistics,
// //   fetchSingleDaytistic,
// //   fetchDaytisticsInRange,
// // } from "./daytistics.ts";
// // import { expect } from "jsr:@std/expect";
// // import { SupabaseClient } from "jsr:@supabase/supabase-js@2";
// // import { describe, it } from "jsr:@std/testing/bdd";
// // import { generateFakeDaytistics } from "../../testing/fakes.ts";

// // const DAYTISTICS_COUNT = 4;
// // const ACTIVITIES_COUNT = 4;

// // const {
// //   activities: fakeActivities,
// //   daytistics: fakeDaytistics,
// //   wellbeings: fakeWellbeings,
// // } = generateFakeDaytistics(DAYTISTICS_COUNT, ACTIVITIES_COUNT);

// // const createMockClient = (
// //   daytisticsNotFound = false,
// //   wellbeingNotFound = false,
// //   activitiesNotFound = false
// // ) =>
// //   ({
// //     from: (table: string) => ({
// //       select: () => ({
// //         eq: (_col: string, val: string) => ({
// //           single: () => ({
// //             then: (fn: (arg: unknown) => unknown) =>
// //               Promise.resolve(
// //                 fn({
// //                   data:
// //                     table === "wellbeings"
// //                       ? wellbeingNotFound
// //                         ? null
// //                         : fakeWellbeings.find((w) => w.id === val)
// //                       : activitiesNotFound
// //                       ? []
// //                       : fakeActivities.filter((a) => a.daytistic_id === val),
// //                   error: null,
// //                 })
// //               ),
// //           }),
// //           then: (fn: (arg: unknown) => unknown) =>
// //             Promise.resolve(
// //               fn({
// //                 data:
// //                   table === "activities"
// //                     ? activitiesNotFound
// //                       ? []
// //                       : fakeActivities.filter((a) => a.daytistic_id === val)
// //                     : [],
// //                 error: null,
// //               })
// //             ),
// //         }),
// //         then: (fn: (arg: unknown) => unknown) =>
// //           Promise.resolve(
// //             fn({
// //               data:
// //                 table === "daytistics"
// //                   ? daytisticsNotFound
// //                     ? []
// //                     : fakeDaytistics
// //                   : [],
// //               error: null,
// //             })
// //           ),
// //       }),
// //     }),
// //   } as unknown as SupabaseClient);

// // describe("fetchAllDaytistics", () => {
// //   it("fetches all daytistics", async () => {
// //     const client = createMockClient();
// //     const result = await fetchAllDaytistics(client);

// //     expect(result.length).toBe(DAYTISTICS_COUNT);
// //     for (const daytistic of result) {
// //       expect(daytistic.wellbeing).toBeDefined();
// //       expect(daytistic.activities).toBeDefined();
// //       expect(daytistic.activities.length).toBe(ACTIVITIES_COUNT);
// //       expect(daytistic.date).toBeDefined();
// //       expect(daytistic.created_at).toBeDefined();
// //       expect(daytistic.updated_at).toBeDefined();
// //     }
// //   });

// //   it("throws an error if no daytistics are found", async () => {
// //     const client = createMockClient(true);

// //     try {
// //       await fetchAllDaytistics(client);
// //     } catch (error) {
// //       expect(error).toBeDefined();
// //     }
// //   });

// //   it("the returned daytistics doesn't contain the the wellbeing key if the wellbeing is not found", async () => {
// //     const client = createMockClient(false, true);

// //     const result = await fetchAllDaytistics(client);

// //     for (const daytistic of result) {
// //       expect(daytistic.wellbeing).toBeUndefined();
// //     }
// //   });
// // });

// // // Deno.test("fetchDaytisticsInRange filtert korrekt", async () => {
// // //   const client = createMockClient();

// // //   const result = await fetchDaytisticsInRange<object>(
// // //     client,
// // //     "2024-01-01",
// // //     "2024-01-02"
// // //   );

// // //   expect(result.length).toBe(2);
// // //   expect(result[0].date).toBe("1/1/2024");
// // //   expect(result[1].date).toBe("1/2/2024");
// // // });

// Deno.test("test", async () => {});
