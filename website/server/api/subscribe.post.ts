export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const { emailOctopusApiKey, emailOctopusListId } = useRuntimeConfig();

  await $fetch(
    `https://api.emailoctopus.com/lists/${emailOctopusListId}/contacts`,
    {
      method: "POST",
      body: {
        email_address: body.email_address,
      },
      headers: {
        Authorization: `Bearer ${emailOctopusApiKey}`,
      },
    }
  );
});
