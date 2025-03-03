import { SupabaseClient, User } from "jsr:@supabase/supabase-js@2";

export async function hasExceededTokensToday(
  supabase: SupabaseClient,
  user: User,
  maxTokens: number
): Promise<{ exceeded: boolean; error: Response | null }> {
  const today = new Date().toISOString().split("T")[0];
  const dailyTokensResponse = await supabase
    .from("daily_token_budgets")
    .select()
    .eq("user_id", user.id)
    .eq("date", today)
    .single();

  if (
    !dailyTokensResponse.error &&
    dailyTokensResponse.data.output_tokens >= maxTokens
  ) {
    return {
      exceeded: true,
      error: new Response(
        JSON.stringify({
          error: "You have exceeded the number of tokens for today",
        }),
        { status: 429 }
      ),
    };
  }

  return { exceeded: false, error: null };
}

export async function updateTokensBudget(
  supabase: SupabaseClient,
  user: User,
  options: {
    inputTokens: number;
    outputTokens: number;
  }
): Promise<void> {
  const today = new Date().toISOString().split("T")[0];
  const { inputTokens, outputTokens } = options;

  const dailyTokensResponse = await supabase
    .from("daily_token_budgets")
    .select()
    .eq("user_id", user.id)
    .eq("date", today)
    .single();

  if (dailyTokensResponse.error) {
    await supabase.from("daily_token_budgets").insert([
      {
        user_id: user.id,
        date: today,
        input_tokens: inputTokens,
        output_tokens: outputTokens,
      },
    ]);
  } else {
    await supabase
      .from("daily_token_budgets")
      .update({
        input_tokens: dailyTokensResponse.data.input_tokens + inputTokens,
        output_tokens: dailyTokensResponse.data.output_tokens + outputTokens,
      })
      .eq("id", dailyTokensResponse.data.id);
  }
}
