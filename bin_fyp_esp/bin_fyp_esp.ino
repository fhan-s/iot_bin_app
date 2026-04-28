  /*

  Mohammad Salik - W1975147
  Code References:

  WiFi connection and reconnection using events: https://randomnerdtutorials.com/solved-reconnect-esp32-to-wifi/

  Sleep mode: https://randomnerdtutorials.com/esp32-deep-sleep-arduino-ide-wake-up-sources/

  Device wakes from deep sleep, connects to WiFi, takes ultrasonic distance readings, takes median value
  sends the processed reading to a Supabase Edge Function,
  and then returns to deep sleep to conserve power.

  */
  #include <esp_sleep.h>
  #include <WiFi.h>
  #include <HTTPClient.h>
  #include <algorithm>
  #include <WiFiClientSecure.h>

  //wifi/hotspot credentials
  const char* ssid = "Ifjdhx";
  const char* password = "farhan87";

  const int internalLedPin = 2;
  volatile bool wifiConnected = false;

  //ultrasonic sensor gpio pins
  const int TRIG_PIN = 13;
  const int ECHO_PIN = 27;

  const uint64_t SLEEP_TIME_US = 300ULL * 1000000ULL; // 300 second sleep interval for readings 

  const unsigned long WIFI_CONNECT_TIMEOUT_MS = 10000;  // 10 second wifi timeout

  //supabase edge function endpoint
  const char* SUPABASE_EDGE_URL = "https://ikbjcupnufrhgrwalqjz.supabase.co/functions/v1/processing-sensor-reading";
 
  String DEVICE_SERIAL = "";
  const char* DEVICE_TOKEN = "binFYP";

  
  const int number_readings = 5;

  void WiFiStationConnected(WiFiEvent_t event, WiFiEventInfo_t info) {
    Serial.println("Connected to AP successfully");
  }

  void WiFiGotIP(WiFiEvent_t event, WiFiEventInfo_t info) {
    wifiConnected = true;
    DEVICE_SERIAL = WiFi.macAddress();
    DEVICE_SERIAL.replace(":", "");
    Serial.print("Device Serial Number: ");
    Serial.println(DEVICE_SERIAL);

    Serial.println("WiFi connected");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    digitalWrite(internalLedPin, HIGH); // Turn LED when device is connected to wifi

    Serial.print("RSSI: ");
    Serial.print(WiFi.RSSI());// display received signal strength indicator
    Serial.println(" dBm");
  }

  void WiFiStationDisconnected(WiFiEvent_t event, WiFiEventInfo_t info) {
    wifiConnected = false;
    digitalWrite(internalLedPin, LOW);

    Serial.println("Disconnected from WiFi access point");
    Serial.print("Reason: ");
    Serial.println(info.wifi_sta_disconnected.reason);
  }

  void setupWiFi(){
    wifiConnected = false;
    WiFi.mode(WIFI_STA);

    WiFi.persistent(false);
    WiFi.setSleep(true);
    WiFi.setAutoReconnect(false);
    WiFi.disconnect(true);

    delay(1000);
    // WiFi event handlers which reacts to connection changes
    WiFi.onEvent(WiFiStationConnected, ARDUINO_EVENT_WIFI_STA_CONNECTED);
    WiFi.onEvent(WiFiGotIP, ARDUINO_EVENT_WIFI_STA_GOT_IP);
    WiFi.onEvent(WiFiStationDisconnected, ARDUINO_EVENT_WIFI_STA_DISCONNECTED);

    WiFi.begin(ssid, password);

    Serial.println();
    Serial.println("Waiting for WiFi...");
  }

  void setupUltrasonicSensor(){
    pinMode(TRIG_PIN, OUTPUT);
    pinMode(ECHO_PIN, INPUT);
    digitalWrite(TRIG_PIN, LOW);
  }



  float getSensorReadingDistanceCM() {
    digitalWrite(TRIG_PIN, LOW);
    delayMicroseconds(2);
    digitalWrite(TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG_PIN, LOW);

    unsigned long duration = pulseIn(ECHO_PIN, HIGH, 30000);

  // timeout, no echo or reading
    if (duration == 0) {
      return -1.0;
    }

    // 0.0343 cm/us
    const float soundSpeed = 0.0343;

    //distance = speed * time
    float rawDistanceCm = (soundSpeed * duration ) / 2.0f;
    return rawDistanceCm;
  }


  float getMedianDistanceCM(int samples) {
    float readings[number_readings];
    int length = 0;

    //create array containing sensor readings
    for (int i = 0; i < samples && length < number_readings; i++)  {
      float reading = getSensorReadingDistanceCM();
      if (reading > 0) {
        readings[length] = reading;
        length++;
        Serial.println(reading);

      }
      delay(50);
    }

    //if all readings timeout then return -1
    if (length == 0) {
      return -1.0f;
    }
    // Asc Order for unsorted array
    std::sort(readings, readings + length);
    Serial.println("Sorted readings:");
    for (int i = 0; i < length; i++) {
      Serial.println(readings[i]);
    }
    
    float medianValue = readings[length / 2];
    Serial.println(medianValue);
    return medianValue;
  }

  void sendDataToSupabase(float medianDistance) {
    if (!wifiConnected) {
      Serial.println("Error: WiFi not connected - Unable to send sensor reading to server.");
      return;
    }
    if (medianDistance < 0) {
      Serial.println("Invalid Distance reading.");
      return;
    }

    WiFiClientSecure client;
    client.setTimeout(15000); // 15 seconds
    client.setInsecure();
    
    HTTPClient http;

    Serial.print("Connecting to: ");
    Serial.println(SUPABASE_EDGE_URL);

    http.begin(client, SUPABASE_EDGE_URL);

    http.addHeader("Content-Type", "application/json");
    http.addHeader("x-device-token", DEVICE_TOKEN);

    String jsonPayload = "{";
    jsonPayload += "\"device_serial_number\":\"" + DEVICE_SERIAL + "\",";
    jsonPayload += "\"raw_distance_cm\":" + String(medianDistance, 2) + ",";
    jsonPayload += "\"battery_level\":100";
    jsonPayload += "}";
    
    Serial.println("Sending JSON:");
    Serial.println(jsonPayload);

    int httpResponseCode = http.POST(jsonPayload);
    
    Serial.print("HTTP code: ");
    Serial.println(httpResponseCode);

    if (httpResponseCode <= 0) {
      Serial.print("HTTP request failed, error: ");
      Serial.println(http.errorToString(httpResponseCode));
    } else if (httpResponseCode < 200 || httpResponseCode >= 300) {
      Serial.print("Server returned error HTTP code: ");
      Serial.println(httpResponseCode);
      Serial.println(http.getString());
    } else {
      String response = http.getString();
      Serial.println("Success:");
      Serial.println(response);
    }
      
    http.end();
  }
  void takeReading() {
    //takes 5 readings that gets median to reduce noise
    float medianDistance = getMedianDistanceCM(number_readings);

    Serial.print("Median reading is: ");
    Serial.println(medianDistance);   

    //if connected to wifi send readings.
    if (wifiConnected) {
      Serial.println("WiFi OK");
      sendDataToSupabase(medianDistance);
    } else {
      Serial.println("WiFi not connected");
    }
  }

  bool waitForWiFi(unsigned long timeoutMs) {
    unsigned long startTime = millis();

    while (!wifiConnected && (millis() - startTime < timeoutMs)) {
      delay(100);
    }

    if (!wifiConnected) {
      Serial.println("WiFi connection timeout");
      return false;
    }

    return true;
  }

  void goSleepMode() {
    Serial.println("Turning WiFi off.");
    digitalWrite(internalLedPin, LOW);
    wifiConnected = false;
    WiFi.disconnect(true);
    WiFi.mode(WIFI_OFF);

    Serial.println("Going into sleep mode");
    Serial.flush();

    //enter deep sleep mode
    esp_sleep_enable_timer_wakeup(SLEEP_TIME_US);
    esp_deep_sleep_start();
  }
  void setup() {
    Serial.begin(115200);
    delay(1000);

    pinMode(internalLedPin, OUTPUT);
    digitalWrite(internalLedPin, LOW);
    setupUltrasonicSensor();
    

    esp_sleep_wakeup_cause_t wakeupReason = esp_sleep_get_wakeup_cause();
    Serial.print("Wakeup reason: ");
    Serial.println((int)wakeupReason);

    setupWiFi();
    
    if (waitForWiFi(WIFI_CONNECT_TIMEOUT_MS)) {
      takeReading();
    } else {
      Serial.println("Skipping send because WiFi did not connect");
    }
    Serial.setDebugOutput(true);
    goSleepMode();  
  }

  void loop() {
    //  loop not used because device sleeps and only code execute once
  }