import { signJWT, validateJWT } from "jsr:@cross/jwt";
import { AdminToken } from "../_shared/types.ts";

export async function verifyAdminToken(token: string): Promise<AdminToken> {
  const decoded = await validateJWT(token, Deno.env.get("ADMIN_AUTH_SECRET")!);
  return decoded as AdminToken;
}

export async function createAdminToken(permissions: string[]): Promise<string> {
  if (!permissions.includes("login")) {
    throw new Error("Permissions must include 'login'");
  }

  const partial =
    "day-admin_" +
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!.slice(0, 8) +
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!.slice(-8);
  return await signJWT(
    {
      partial,
      permissions,
    },
    Deno.env.get("ADMIN_AUTH_SECRET")!
  );
}

export function isValidPartialAdminToken(token: string) {
  return (
    token.startsWith(
      "day-admin_" + Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!.slice(0, 8)
    ) && token.endsWith(Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!.slice(-8))
  );
}
