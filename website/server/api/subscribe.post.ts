export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const { emailOctopusApiKey, emailOctopusListId } = useRuntimeConfig();

  const tags = ["Website"];
  if (process.env.PHASE !== "released") {
    tags.push("Waiting List");
  }

  await $fetch(
    `https://api.emailoctopus.com/lists/${emailOctopusListId}/contacts`,
    {
      method: "POST",
      body: {
        email_address: body.email_address,
        tags: tags,
      },
      headers: {
        Authorization: `Bearer ${emailOctopusApiKey}`,
      },
    }
  );
});
