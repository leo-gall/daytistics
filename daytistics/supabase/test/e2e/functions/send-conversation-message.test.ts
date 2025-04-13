import { afterAll, beforeAll, describe, it } from "jsr:@std/testing/bdd";
import { expect } from "jsr:@std/expect";
import {
    createClient,
    SupabaseClient,
    User,
} from "jsr:@supabase/supabase-js@2";
import { generateFakeDaytistics } from "../../e2e-utils.ts";
import { ConversationMessage } from "../../../_shared/types.ts";
import config from "../../../config.ts";
import { randomUUID } from "node:crypto";

const QUERY_1 =
    "What would you recommend to improve my wellbeing? Based on: a) my activities in the last week, b) my activities yesterday, c) all my activities. Answer 3 times.";
const QUERY_2 = "What have we talked about so far?";

describe("send-conversation-message", {
    "sanitizeResources": false,
}, () => {
    let supabase: SupabaseClient;
    let user: User;

    beforeAll(async () => {
        const supabaseUrl: string | undefined = Deno.env.get("SUPABASE_URL");
        const supabaseServiceRoleKey: string | undefined = Deno.env.get(
            "SUPABASE_SERVICE_ROLE_KEY",
        );

        if (!supabaseUrl || !supabaseServiceRoleKey) {
            throw new Error(
                "SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set",
            );
        }

        supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

        user = (await supabase.auth.signInAnonymously()).data.user!;
        await generateFakeDaytistics(3, user!, supabase);
    });

    afterAll(async () => {
        await supabase.auth.admin.deleteUser(user!.id);

        for (let i = 0; i < 1000; i++) {
            clearInterval(i);
            clearTimeout(i);
        }
    });

    it("should send a conversation message & create a conversation if none exists", async () => {
        const response = await supabase.functions.invoke(
            "send-conversation-message",
            {
                body: {
                    query: QUERY_1,
                },
            },
        );

        const { data: conversationMessages } = await supabase
            .from("conversation_messages")
            .select()
            .eq("conversation_id", response.data.conversation_id);

        expect(response.error).toBeNull();
        expect(response.data.query).toBe(QUERY_1);
        expect(typeof response.data.reply).toBe("string");
        expect(typeof response.data.conversation_id).toBe("string");
        expect(typeof response.data.title).toBe("string");
        expect(response.data.called_functions.length).toBeGreaterThanOrEqual(1);

        expect(conversationMessages).not.toBeNull();
        expect(conversationMessages!.length).toBeGreaterThanOrEqual(1);
    });

    it("should send a conversation message & use an existing conversation", async () => {
        const createConversationResponse = await supabase.functions.invoke(
            "send-conversation-message",
            {
                body: {
                    query: QUERY_1,
                },
            },
        );

        const response = await supabase.functions.invoke(
            "send-conversation-message",
            {
                body: {
                    query: QUERY_2,
                    conversation_id: await createConversationResponse.data
                        .conversation_id,
                },
            },
        );

        expect(response.error).toBeNull();
        expect(response.data.query).toBe(QUERY_2);
        expect(typeof response.data.reply).toBe("string");
        expect(typeof response.data.conversation_id).toBe("string");
        expect(typeof response.data.title).toBe("string");
        expect(response.data.called_functions.length).toBe(0);

        const { data: conversationMessages } = await supabase
            .from("conversation_messages")
            .select()
            .eq("conversation_id", response.data.conversation_id);

        expect(conversationMessages).not.toBeNull();
        expect(conversationMessages!.length).toBeGreaterThanOrEqual(2);
    });

    it("should not send a conversation message if the maximum number of messages in a conversation is reached", async () => {
        const createConversationResponse = await supabase.functions.invoke(
            "send-conversation-message",
            {
                body: {
                    query: QUERY_1,
                },
            },
        );

        const messages = Array.from(
            {
                length: config.conversations.options.freeMessagesPerDaytistic +
                    1,
            },
            (_) =>
                new ConversationMessage(
                    randomUUID(),
                    "query",
                    "reply",
                    createConversationResponse.data.conversation_id,
                    new Date().toISOString(),
                    new Date().toISOString(),
                    [],
                ),
        );

        await supabase.from("conversation_messages").insert(
            messages,
        );

        const limitExceededResponse = await supabase.functions.invoke(
            "send-conversation-message",
            {
                body: {
                    query: QUERY_2,
                    conversation_id: await createConversationResponse.data
                        .conversation_id,
                },
            },
        );

        expect(limitExceededResponse.error).not.toBeNull();
        expect(limitExceededResponse.data).toBeNull();
    });
});
