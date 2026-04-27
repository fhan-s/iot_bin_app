

/*
W1975147 - Mohammad Salik

The sensor_device table is searched using device serial number sent from esp32
if device serial number exists, use that row’s device_id to find associated bin id to store reading,
The ESP32 only sends its serial number for identification and never needs to know database primary keys.

*/
import 'jsr:@supabase/functions-js/edge-runtime.d.ts'
import { createClient } from 'npm:@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    //allow only post requests from esp
    if (req.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 })
    }

    const body = await req.json()
    const {
      device_serial_number,
      raw_distance_cm,
      battery_level
    } = body

    //return error for missing fields
    if (!device_serial_number || raw_distance_cm === undefined) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    // distance value must be valid, return error if invalid
    if (raw_distance_cm <= 0) {
      return new Response(
        JSON.stringify({ error: 'raw_distance_cm cannot be less than 0' }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    // request token must match with secret token so only trusted devices can submit readings.  
    const expectedToken = Deno.env.get('DEVICE_SHARED_TOKEN')
    const sentToken = req.headers.get('x-device-token')

    if (!expectedToken || sentToken !== expectedToken) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized device' }),
        {
          status: 401,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // find matching serial number from sensor_device table. Retrieve device and bin id from row.
    const { data: deviceRows, error: deviceError } = await supabase
      .from('sensor_device')
      .select('device_id, bin:bin_id (bin_height_cm)')
      .eq('device_serial_number', device_serial_number)
      .limit(1)

    if (deviceError) {
      return new Response(
        JSON.stringify({ error: 'Failed to look up device', details: deviceError }),
        {
          status: 500,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    if (!deviceRows || deviceRows.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Device not registered' }),
        {
          status: 404,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    const device_id = deviceRows[0].device_id
    const bin_height = deviceRows[0].bin?.[0]?.bin_height_cm

    if (!bin_height || bin_height <= 0) {
      return new Response(
        JSON.stringify({ error: 'Invalid bin height configuration' }),
        {
          status: 500, headers: { 'Content-Type': 'application/json'}}
      )
    }


    //converting raw distance to fill level using formula below
    const fill_ratio = (bin_height - raw_distance_cm) / bin_height
    const fill_level = Math.max(0, Math.min(100, Math.round(fill_ratio * 100)))//default to 0 prevent value errors


    const { error: readingError } = await supabase
      .from('sensor_reading')
      .insert({
        device_id,
        fill_level,
        raw_distance_cm,
        battery_level: battery_level ?? 0,
        runtime_timestamp: new Date().toISOString()
      })

    if (readingError) {
      return new Response(
        JSON.stringify({ error: 'Failed to insert reading', details: readingError }),
        {
          status: 500,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

  const { error: deviceUpdateError } = await supabase
  .from('sensor_device')
  .update({
    device_status: 'online',
    last_seen_at: new Date().toISOString()
    })
    .eq('device_id', device_id)

  if (deviceUpdateError) {
    return new Response(
      JSON.stringify({
        error: 'Failed to update sensor device',
        details: deviceUpdateError
      }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      }
    )
    }   
    return new Response(
      JSON.stringify({
        success: true,
        device_id,
        fill_level,
        raw_distance_cm
      }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'Unexpected error', details: String(err) }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }
})