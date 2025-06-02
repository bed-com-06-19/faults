#define TINY_GSM_MODEM_SIM7000
#define TINY_GSM_RX_BUFFER 1024
#define SerialAT Serial1

#include <TinyGsmClient.h>
#include <TinyGPS++.h>

#define SENSOR_PIN 34
#define SPIKE_THRESHOLD 300
#define MIN_SPIKES 3
#define NUM_READINGS 100

const char apn[] = "internet.tnm.mw";
const char gprsUser[] = "tnm";
const char gprsPass[] = "tnm";
const char* server = "api.thingspeak.com";
const int port = 80;
const char* apiKey = "5M1CR2RBEUGIVE1T";

#define UART_BAUD 115200
#define MODEM_PWR 23
#define MODEM_TX 27
#define MODEM_RX 26
#define LED_PIN 12

TinyGsm modem(SerialAT);
TinyGsmClient client(modem);
TinyGPSPlus gps;

String pairName = "Pole-6426";

int lastStatus = -1; // Initialize with invalid value

void setup() {
  Serial.begin(115200);
  delay(10);

  pinMode(MODEM_PWR, OUTPUT);
  digitalWrite(MODEM_PWR, HIGH);
  delay(1000);
  digitalWrite(MODEM_PWR, LOW);

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  Serial.println("Booting modem...");
  SerialAT.begin(UART_BAUD, SERIAL_8N1, MODEM_RX, MODEM_TX);
  delay(3000);

  modem.restart();
  if (!modem.waitForNetwork()) {
    Serial.println("❌ Network connection failed");
    while (true);
  }

  if (!modem.gprsConnect(apn, gprsUser, gprsPass)) {
    Serial.println("❌ GPRS connection failed");
    while (true);
  }

  Serial.println("✅ GPRS connected");
  modem.enableGPS();
  analogReadResolution(12);
  Serial.println("System ready.");
}

void loop() {
  // Read GPS data
  while (SerialAT.available()) {
    gps.encode(SerialAT.read());
  }

  // Sample current sensor
  int spikeCount = 0;
  for (int i = 0; i < NUM_READINGS; i++) {
    int reading = analogRead(SENSOR_PIN);
    if (reading > SPIKE_THRESHOLD) {
      spikeCount++;
    }
    delay(2);
  }

  int currentStatus = spikeCount >= MIN_SPIKES ? 1 : 0;

  Serial.print("Spike count: ");
  Serial.print(spikeCount);
  Serial.print(" -> Status: ");
  Serial.println(currentStatus);
  Serial.println(currentStatus == 1 ? "fixed" : "fault");

  // Only send to ThingSpeak if status has changed
  if (currentStatus != lastStatus) {
    Serial.println("⚡ Status changed. Sending to ThingSpeak...");

    if (client.connect(server, port)) {
      String latitude = gps.location.isValid() ? String(gps.location.lat(), 6) : "-15.3833";
      String longitude = gps.location.isValid() ? String(gps.location.lng(), 6) : "35.3333";
      String timestamp;

      if (gps.date.isValid() && gps.time.isValid()) {
        timestamp = String(gps.date.day()) + "-" + String(gps.date.month()) + "-" + String(gps.date.year()) + " " +
                    String(gps.time.hour()) + ":" + String(gps.time.minute()) + ":" + String(gps.time.second());
      } else {
        timestamp = "unknown";
      }

      String url = "/update?api_key=" + String(apiKey) +
                   "&field1=" + String(currentStatus) +
                   "&field2=" + pairName +
                   "&field3=" + latitude +
                   "&field4=" + longitude +
                   "&field5=Chancellor%20College" +
                   "&field6=true" +
                   "&field7=" + (currentStatus == 1 ? "fixed" : "fault") +
                   "&field8=" + timestamp;

      String request = "GET " + url + " HTTP/1.1\r\n" +
                       "Host: " + String(server) + "\r\n" +
                       "Connection: close\r\n\r\n";

      client.print(request);

      unsigned long timeout = millis();
      while (client.connected() && millis() - timeout < 10000) {
        while (client.available()) {
          char c = client.read();
          Serial.write(c);
          timeout = millis();  // Reset timeout
        }
      }

      client.stop();
      Serial.println("\n🔌 Disconnected from server");

      digitalWrite(LED_PIN, currentStatus ? HIGH : LOW);

      // Update last status only after successful send
      lastStatus = currentStatus;
    } else {
      Serial.println("❌ Failed to connect to ThingSpeak");
    }
  }

  delay(1000); // Check every second
}
