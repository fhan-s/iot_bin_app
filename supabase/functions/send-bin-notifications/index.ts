/*
W1975147 - Mohammad Salik
Code reference: https://supabase.com/docs/guides/functions/examples/push-notifications?queryGroups=platform&platform=fcm


Edge function is trigged using a webhook that listens in bin table for when a new bin status is inserted/updated.

The Edge function looks up the bin name, the janitor assigned to that bin and the janitor’s FCM device tokens
A Firebase access token is generated using a service account and a push notification is sent using FCM to the janitor’s device.


*/

import { createClient } from "@supabase/supabase-js"
import { JWT } from "google-auth-library";
console.log("Supabase Functions send-bin-notifications function loaded");

// defines the structure of the notification payload from webhook
interface NotifcationWebhookPayload {
    created_at?: string
    bin_id?: string
    status?: string
    fill_level?: number
}
// defines the structure of the Supabase webhook payload
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
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
)
const serviceAccountJSON = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON")!;
const serviceAccount= JSON.parse(serviceAccountJSON);

// Fix newline characters in private key
serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");

console.log("Firebase project:", serviceAccount.project_id);
console.log("PK header ok:", serviceAccount.private_key.includes("BEGIN PRIVATE KEY"));
console.log("PK has newlines:", serviceAccount.private_key.includes("\n"));

Deno.serve(async (req) => {
  try {
    const payload: SupabaseWebhookPayload = await req.json();

    // get bin name from bin table to be used in notification message
    const {data: binName, error: binError} = await supabase
    .from('bin')
    .select('bin_name')
    .eq('bin_id', payload.record?.bin_id)
    .single();
    if (binError) throw binError;

    // find janitor assigned to this full bin
    const {data: assignments, error: assignmentError} = await supabase
    .from('bin_assignment')
    .select('janitor_id')
    .eq('bin_id', payload.record?.bin_id)
    .single();
    if (assignmentError) throw assignmentError;

    // get all fcm tokens linked to that  janitor
    const {data: tokensData, error: tokensError} = await supabase
    .from('fcm_push_token')
    .select('user_id, fcm_token')
    .eq ('user_id', assignments?.janitor_id);

    if (tokensError) throw tokensError;
  

    // get OAuth access token for firebase api
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    });

    const tokens = (tokensData ?? [])
    .map((row) => row.fcm_token)
    .filter(Boolean);

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ error: "No FCM tokens found for assigned janitor" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    const results = [];

    // send to all device tokens associated with janitor.
    for (const token of tokens) {
      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            message: {
              token,
              notification: {
                title: "Bin Alert",
                body: `Attention!: Bin: "${binName?.bin_name}" is ${payload.record?.fill_level}% full.`,
              },
            },
          }),
        }
      );

      const resData = await response.json();

      results.push({
        token,
        ok: response.ok,
        status: response.status,
        data: resData,
      });
    }
    const successCount = results.filter((r) => r.ok).length;
    const failureCount = results.length - successCount;

    return new Response(
      JSON.stringify({
        message: "Notification send attempt completed",
        successCount,
        failureCount,
        results,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
    
  } catch (error) {
    console.error("Error sending notifications:", error);
    return new Response(
      JSON.stringify({ error: "Failed to send notifications", details: error }),
      { status: 500, headers : { "Content-Type": "application/json" } },
    )
  }
})

// Get access token for Firebase Cloud Messaging
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


