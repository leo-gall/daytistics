export class MockSupabaseClient {
  from(_table: string) {
    return {
      select: () => this,
      insert: () => this,
      eq: () => this, // Basis-Implementierung ohne Parameter
      gte: () => this,
      lte: () => this,
      single: () => this,
      then: async () => ({ data: [], error: null }),
    };
  }
}
