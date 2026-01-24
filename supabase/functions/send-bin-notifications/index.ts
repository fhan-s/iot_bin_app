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


// Create a single supabase client for interacting with database
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
)

// Load Firebase service account from supabase --> edge function --> secrets (environment variables)
const serviceAccountJSON = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON")!;
const serviceAccount= JSON.parse(serviceAccountJSON);
console.log("Firebase project:", serviceAccount.project_id);

Deno.serve(async (req) => {
  try {
    const payload: SupabaseWebhookPayload = await req.json();

    const {data: binName, error: binError} = await supabase.from('bin').select('bin_name').eq('bin_id', payload.record?.bin_id).single();
    if (binError) throw binError;

    // find janitor assigned to this full bin in bin_assignment table
    const {data: assignments, error: assignmentError} = await supabase.from('bin_assignment')
      .select('janitor_id')
      .eq('bin_id', payload.record?.bin_id).single();
    if (assignmentError) throw assignmentError;

    // get all fcm tokens for the janitor
    const {data: tokensData, error: tokensError} = await supabase.from('fcm_push_token')
      .select('user_id, fcm_token')
      .eq ('user_id', assignments?.janitor_id);
    if (tokensError) throw tokensError;
  

    // get access token for firebase project
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    });

    // send notification to each token
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
            body: `Attention!: Bin: "${binName?.bin_name}" is ${payload.record?.fill_level}% full.`,
          },
        },
      }),
    });
    
    // Check response status
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

// Function to get OAuth2 access token using JWT
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


