// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs

// import { createClient } from "@supabase/supabase-js"
// import { rejects } from "node:assert";
// import { resolve } from "node:path";
// console.log("Supabase Functions send-bin-notifications function loaded");

// interface WebhookPayload {
//   bin_id: string
//   status: string
//   fill_level: number
//   created_at: string
// };

// type SupabaseWebhookPayload = {
//   type?: string;
//   table?: string;
//   record?: WebhookPayload;
//   new?: WebhookPayload;
//   old?: WebhookPayload;
// };

// const supabase = createClient(
//   Deno.env.get("SUPABASE_URL")!,
//   // bypass role level security 
//   Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
// )
// const {default: serviceAccount} = await import("../service-account.json" , { with: { type: "json" } });
// const accessToken = 
// Deno.serve(async (req) => {
//   const payload: SupabaseWebhookPayload = await req.json();
//   const record = payload.record ?? payload.new!;
//   if (!record) {
//     return new Response(
//       JSON.stringify({ message: "No record found in payload" }),
//       { status: 400 , headers : { "Content-Type": "application/json" } },
//     )
//   }

//   const binID = record.bin_id;
//   const fillLevel = record.fill_level;
//   const status = record.status;

//   // find janitor assigned to this bin
//   const {data: assignments, error: assignmentError} = await supabase.from('bin_assignment')
//     .select('janitor_id')
//     .eq('bin_id', binID)

//   if (assignmentError) throw assignmentError;

//   // extract janitor ids
//   const janitorIds = (assignments ?? []).map(a => a.janitor_id).filter(Boolean);
//   if (janitorIds.length === 0) {
//     return new Response(
//       JSON.stringify({ message: "No janitors assigned to this bin" }),
//       { status: 200, headers : { "Content-Type": "application/json" } },
//     )
//   };

//   // get fcm tokens of janitors
//   const {data: tokensData, error: tokensError} = await supabase.from('fcm_push_token')
//     .select('user_id, fcm_token')
//     .in ('user_id', janitorIds);

//   if (tokensError) throw tokensError;
  

//   const tokens = (tokensData ?? []).map(t => t.fcm_token).filter(Boolean);
//   if (tokens.length === 0){
//     return new Response(
//       JSON.stringify({ message:"No FCM tokens found for assigned janitors" }),
//       { status: 200, headers : { "Content-Type": "application/json" } },
//     )
//   };

  
//   for (const fcmToken of tokens){
//   const response = await fetch(`https://fcm.googleapis.com/v1/projects/${project_id}/messages:send`, {
//     method: 'POST',
//     headers: {
//       'Content-Type': 'application/json',
//       Authorization: `Bearer ${accessToken}`,
//     },
//     body: JSON.stringify({
//       message: {
//         token: fcmToken,
//         notification: {
//           title: 'Bin Alert',
//           body: `Attention!: Bin ${payload.record.bin_id} is ${payload.record.fill_level}% full.`,
//         },
//       },
//     }),
//   });
//     const fcmResponse = await response.json();
//   if (!response.ok) {
//     throw fcmResponse;
//   }
//   }
//   return new Response(
//     JSON.stringify({ message: "Notification sent successfully" }),
//     { status: 200 },
//   )
// })

// const getAccessToken = ({
//   clientEmail,
//   privateKey,
// }: {
//   clientEmail: string
//   privateKey: string
// }: Promise <String> ((resolve, reject) =>{
//   const jwtClient = new JWT({
//     email: clientEmail,
//     key: preivateKey,
//   })
// })
// )


