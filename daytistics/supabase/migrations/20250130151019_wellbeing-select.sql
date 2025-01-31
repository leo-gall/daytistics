ALTER POLICY "Users can select their own wellbeings" ON "public"."wellbeings" TO public USING (
    (
        "auth"."uid"() = (
            SELECT
                "daytistics"."user_id"
            FROM
                "public"."daytistics"
            WHERE
                ("daytistics"."wellbeing_id" = "wellbeings"."id")
        )
    )
);