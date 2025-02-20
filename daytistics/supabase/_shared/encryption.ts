// Load SECRET_KEY from environment variables
const SECRET_KEY = Deno.env.get("SECRET_KEY")!;

// Convert key to a usable format
const encoder = new TextEncoder();
const keyData = new Uint8Array(
  Array.from(atob(SECRET_KEY), (c) => c.charCodeAt(0))
);
const cryptoKey = await crypto.subtle.importKey(
  "raw",
  keyData,
  { name: "AES-GCM" },
  false,
  ["encrypt", "decrypt"]
);

// Encrypt function
export async function encrypt(text: string): Promise<string> {
  const iv = crypto.getRandomValues(new Uint8Array(12)); // Generate IV (nonce)
  const encrypted = await crypto.subtle.encrypt(
    { name: "AES-GCM", iv },
    cryptoKey,
    encoder.encode(text)
  );

  // Encode IV + Encrypted Data as base64
  return btoa(String.fromCharCode(...iv, ...new Uint8Array(encrypted)));
}

// Decrypt function
export async function decrypt(encryptedText: string): Promise<string> {
  const data = Uint8Array.from(atob(encryptedText), (c) => c.charCodeAt(0));
  const iv = data.slice(0, 12);
  const encryptedData = data.slice(12);

  const decrypted = await crypto.subtle.decrypt(
    { name: "AES-GCM", iv },
    cryptoKey,
    encryptedData
  );

  return new TextDecoder().decode(decrypted);
}
