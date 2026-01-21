// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs

import { createClient } from "@supabase/supabase-js"
console.log("Hello from Functions!")

interface WebhookPayload {
  bin_id: string
  status: string
  fill_level: number
  created_at: string
};

type SupabaseWebhookPayload = {
  type?: string;
  table?: string;
  record: WebhookPayload;
  new?: WebhookPayload;
  old?: WebhookPayload;
};

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  // bypass role level security 
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
)

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json()
  return new Response(
    JSON.stringify({ message: "Notification sent successfully" }),
    { status: 200 },
  )
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/send-bin-notifications' \
    --header 'Authorization: Bearer eyJhbGciOiJFUzI1NiIsImtpZCI6ImI4MTI2OWYxLTIxZDgtNGYyZS1iNzE5LWMyMjQwYTg0MGQ5MCIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjIwODQzMTY5MjV9.m3LSXC3kZ0_oeC5H2lcFlH1oaxzTDdP2GB-KjfbNZ9aFVLbJnlqCPdiK6RDnRBHmt1uVOOR5awtkXohZGnJi0Q' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
