#include <SoftwareSerial.h>
#define RX 11
#define TX 10
SoftwareSerial esp8266(RX,TX); 
#include <dht11.h>
dht11 dhtObject;
#define dht_apin 2 
#define land A0 
#define rain A1
#define light A2
#define role 4


String AP = "TurkTelekom_ZJFWE";       
String PASS = "1216x2713H"; 
String API = "SA189FM4TIRSUS0Y";  
String HOST = "api.thingspeak.com";
String PORT = "80";
String tcp = "\"TCP\"";
int countTrueCommand;
int countTimeCommand; 
boolean found = false; 


int valSensor = 1;
int landValue = 0;
int rainValue = 0;
int lightValue = 0;
int topraknem = 0; 

void setup() {
pinMode(role,OUTPUT);
esp8266.begin(115200);
sendCommand("AT",5,"OK");
sendCommand("AT+CWMODE=1",5,"OK");
sendCommand("AT+CWJAP=\""+ AP +"\",\""+ PASS +"\"",20,"OK");
Serial.begin(9600);
}

void loop() {
  
  String getData = "GET /update?api_key="+ API +"&field1="+getTemperatureValue()+"&field2="+
   getHumidityValue()+"&field3="+getLandValue()+"&field4="+getRainValue()+"&field5="+getLightValue();
   sendCommand("AT+CIPMUX=1",5,"OK");
   sendCommand("AT+CIPSTART=0,\"TCP\",\""+ HOST +"\","+ PORT,15,"OK");
   sendCommand("AT+CIPSEND=0," +String(getData.length()+4),4,">");
   esp8266.println(getData);
   delay(1500);countTrueCommand++;
  sendCommand("AT+CIPCLOSE=0",5,"OK");
}
String getTemperatureValue(){
   dhtObject.read(dht_apin);
   Serial.print(" Temperature(C)= ");
   int temp = dhtObject.temperature;
   Serial.println(temp); 
   delay(50);
   return String(temp);}

String getRainValue(){
  rainValue = analogRead(rain);        
  Serial.print(" RV :");                
  Serial.println(rainValue);
  delay(50);
  return String(rainValue);}

String getLandValue(){
  landValue = analogRead(land);        
  Serial.print(" LHV :");                
  Serial.println(landValue);
  delay(50);
  return String(landValue);}

String getLightValue(){
  lightValue = analogRead(light);
  Serial.print(" Light:");
  Serial.println(lightValue);
  delay(50);
  return String(lightValue);}

String getHumidityValue(){
   dhtObject.read(dht_apin);
   Serial.print(" Humidity in %= ");
   int humidity = dhtObject.humidity;
   Serial.println(humidity);
   delay(50);
   return String(humidity);}

void sendCommand(String command, int maxTime, char readReplay[]) {
  Serial.print(countTrueCommand);
  Serial.print(". at command => ");
  Serial.print(command);
  Serial.print(" ");
  while(countTimeCommand < (maxTime*1))
  {
    esp8266.println(command);
    if(esp8266.find(readReplay))
    {
      found = true;
      break;
    }
    countTimeCommand++;
  }
  
  if(found == true)
  {
    Serial.println("OK");
    countTrueCommand++;
    countTimeCommand = 0;
  }
  
  if(found == false)
  {
    Serial.println("Fail");
    countTrueCommand = 0;
    countTimeCommand = 0;
  }
  found = false;
 }
