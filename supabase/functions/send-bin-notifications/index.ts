// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs

import { createClient } from "@supabase/supabase-js"
import { JWT } from "google-auth-library";
console.log("Supabase Functions send-bin-notifications function loaded");

interface NotifcationWebhookPayload {
    created_at?: string
    bin_id?: string
    status?: string
    fill_level?: number
}

type SupabaseWebhookPayload = {
  type?: 'Insert';
  table?: string;
  record?: NotifcationWebhookPayload;
  schema?: 'public';
  new?: NotifcationWebhookPayload;
  old?: NotifcationWebhookPayload; 
};



const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  // bypass role level security 
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
)
const {default: serviceAccount} = await import("../service-account.json" , { with: { type: "json" } });
// const raw = Deno.env.get("GOOGLE_SERVICE_ACCOUNT_JSON");
// if (!raw) throw new Error("Missing GOOGLE_SERVICE_ACCOUNT_JSON secret");
// const serviceAccount = JSON.parse(raw);

// const accessToken = 
Deno.serve(async (req) => {
  try {
    const payload: SupabaseWebhookPayload = await req.json();

    // find janitor assigned to this full bin in bin_assignment table
    const {data: assignments, error: assignmentError} = await supabase.from('bin_assignment')
      .select('janitor_id')
      .eq('bin_id', payload.record?.bin_id).single();
    if (assignmentError) throw assignmentError;

    // get all fcm tokens of the janitor
    const {data: tokensData, error: tokensError} = await supabase.from('fcm_push_token')
      .select('user_id, fcm_token')
      .eq ('user_id', assignments?.janitor_id);
    if (tokensError) throw tokensError;
    

    // extract multiple fcm tokens from janitor
    // const tokens = (tokensData ?? []).map(t => t.fcm_token).filter(Boolean);

    // send notification to each token
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    });
    for (const fcmToken of tokensData?.map(t => t.fcm_token) ?? []) {
    const response = await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: {
            title: 'Bin Alert',
            body: `Attention!: Bin ${payload.record?.bin_id} is ${payload.record?.fill_level}% full.`,
          },
        },
      }),
    });
    
    
    const resData = await response.json();
    if (response.status < 200 || response.status >= 300) {
      throw resData;
    }
    }
    return new Response(
      JSON.stringify({ message: "Notification sent successfully" }),
      { status: 200 },
    )
  } catch (error) {
    console.error("Error sending notification:", error);
    return new Response(
      JSON.stringify({ error: "Failed to send notification", details: error }),
      { status: 500, headers : { "Content-Type": "application/json" } },
    )
  }
})
// test
const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string;
  privateKey: string;
}): Promise<string> => {
  return new Promise((resolve,reject)  => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });
  
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(tokens!.access_token!);
     })
  })
}


