export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const { EMAIL_OCTOPUS_LIST_ID, EMAIL_OCTOPUS_API_KEY } = process.env;

  await $fetch(
    `https://api.emailoctopus.com/lists/${EMAIL_OCTOPUS_LIST_ID}/contacts`,
    {
      method: "POST",
      body: {
        email_address: body.email_address,
      },
      headers: {
        Authorization: `Bearer ${EMAIL_OCTOPUS_API_KEY}`,
      },
    }
  );
});
