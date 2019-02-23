#include <Servo.h>
#include <Ethernet.h>

byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xEmD};
IPAddress ip(10, 0, 0, 12);
IPAddress myDns(192, 168, 1, 1);
IPAddress gateway(192, 168, 1, 1);
IPAddress subnet(255, 255, 255, 0);
EthernetServer server(25565);
boolean alreadyConnected = false;

int off = 1500;
int readByte;
int x, y, by, z, button;
const int syncByte = 200;
const int openByte = 100;
const int closeByte = 300;
int count = 0;

Servo motor0;
Servo motor1;
Servo motor2;
Servo motor3;
Servo motor4;
Servo arm;

void setup() {
  motor0.attach(12);
  motor1.attach(11);
  motor2.attach(2);
  motor3.attach(6);
  motor4.attach(8);
  arm.attach(53);

  delay(100);
  Ethernet.begin(mac, ip, myDns, gateway, subnet);
  server.begin();
  Serial.begin(9600);
  while (!Serial) {
    ;
  }
  Serial.println("Server Reset: Searching....");
  Serial.println(Ethernet.localIP());

}

int driveToMotorFreq (int drive)
{
  if (drive > 128) drive -= 256;
  drive = drive * 4;
  return drive;
}

void loop() {

  EthernetClient client = server.available();
  char freq;
  count++;

  if (client) {
    if (!alreadyConnected) {
      // clear out the input buffer:
      client.flush();
      Serial.println("Connection Established");
      client.println("Correct Driver Station!");
      alreadyConnected = true;
    }

    if (client.available() > 0) { // Because you're flushing characters, you might be out of sync at some point. You might want to start by sending a known pattern, else you might end up out of sync with the 6 words you're sending
      readByte = client.read();
      if (readByte == syncByte) {
        y = client.read();
        x = client.read();
        by = client.read();
        z = client.read();
        button = client.read();

        y = driveToMotorFreq(y);
        x = driveToMotorFreq(x);
        z = driveToMotorFreq(z);
        by = driveToMotorFreq(by);

        motor4.writeMicroseconds(x + off);
        motor0.writeMicroseconds(z + off);
        motor1.writeMicroseconds(z + off);

        if ((y > 0 || y < 0) && by == 0)
        {
          motor2.writeMicroseconds(y + off);
          motor3.writeMicroseconds(y + off);
        }
        else if ((by > 0 || by < 0) && (y > 0 || y < 0))
        {
          motor2.writeMicroseconds(-by + off);
          motor3.writeMicroseconds(by + off);
        }
        if (button == openByte)
        {
          arm.write(90);
        }
        else if (button == closeByte)
        {
          arm.write(180);
        }
        if ((count % 10) == 0)
        {
          Serial.print("x = ");
          Serial.print(x);
          Serial.print(", y + off");
          Serial.print(y);
          Serial.print(", z + off");
          Serial.print(z);
          Serial.print(", by + off");
          Serial.print(by);
        }
        else
        {
          freq = char(readByte);
          Serial.println(freq);
        }
      }
    }
  }
}





