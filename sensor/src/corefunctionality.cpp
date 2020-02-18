#include "corefunctionality.h"

void activateLowPowerMode(int sleepSeconds){
    //TODO fill in
    sleep(sleepSeconds);
}

void sampleAndStoreTemperature(){
    //TODO fill in
}
void sampleAndStoreMoisture(){
    //TODO fill in
}
void sampleAndStorePhosphate(){
    //TODO fill in
}
void sampleAndStoreSunlight(){
    //TODO fill in
}

void transmitStoredTemperature(){
    //TODO fill in
}
void transmitStoredMoisture(){
    //TODO fill in
}
void transmitStoredPhosphate(){
    //TODO fill in
}
void transmitStoredSunlight(){
    //TODO fill in
}

void turnOffWiFi() {
    Serial.print("Turned wifi off");
    WiFi.mode(WIFI_OFF);
}

void turnOnWifi() {
    Serial.println();
    if(WiFi.enableSTA(true)) {
        Serial.print("Turned wifi on");
    } else {
        Serial.print("Failed to turn on wifi");
    }
}

void connectToWifi(const char* ssid, const char* password) {
    turnOnWifi();
    // We start by connecting to a WiFi network
    // TODO at some point take out serial stuff
    Serial.println();
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);

    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println("");
    Serial.println("WiFi connected");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());
}
