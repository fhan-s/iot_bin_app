

/*
This edge function looks in sensor_device table for device_serial_number eg = "ESP32-BIN-001".
if serial number found or matches, use that row’s device_id
if serial number not found, insert a new row and get the new device_id
ESP32 never needs to know the sensor device primary key directly from arduino code.
test
*/
import 'jsr:@supabase/functions-js/edge-runtime.d.ts'
import { createClient } from 'npm:@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    if (req.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 })
    }

    const body = await req.json()
    const {
      device_serial_number,
      raw_distance_cm,
      battery_level
    } = body

    if (!device_serial_number || raw_distance_cm === undefined) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    if (raw_distance_cm <= 0) {
      return new Response(
        JSON.stringify({ error: 'raw_distance_cm must be > 0' }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

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

    const { data: deviceRows, error: deviceError } = await supabase
      .from('sensor_device')
      .select('device_id, bin_id')
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
    const fill_level = Math.abs(Math.floor(raw_distance_cm)) % 100

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

    await supabase
      .from('sensor_device')
      .update({
        device_status: 'online',
        latest_battery_level: battery_level ?? 0
      })
      .eq('device_id', device_id)

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