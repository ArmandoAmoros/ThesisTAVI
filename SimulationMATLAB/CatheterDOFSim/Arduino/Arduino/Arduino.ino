int potOne = A0; // Potentiometer 1
int potTwo = A1; // Potentiometer 2
int pushOne = 2; // Pushbutton 1
int pushTwo = 3; // Pushbutton 2 
int device = 5; // 1 - Keyboard, 2 - Remote, 3 - Joystick, 4 - Catheter
int ledPin = 13; // Led arduino board for error messages

float rotCountPrev = 0; // Rotation velocit
float rotVel = 0; // Rotation velocity
float rotCountTemp = 0; // Rotation velocity
float axCountPrev = 0; // Axial velocity
float axVel = 0; // Axial velocity
float axCountTemp = 0; // Axial velocity

#define remoteAxialGain 5
#define remoteRotatGain 0.1

void setup() {
  Serial.begin(9600);
  pinMode(pushOne, INPUT); // Set pushOne as INPUT
  pinMode(pushTwo, INPUT); // Set pushOne as INPUT
  pinMode(ledPin, OUTPUT); // Set pushOne as INPUT
}

void loop() {
  switch(device){
    case 1:
      axVel = remoteAxialGain;
      rotVel = remoteRotatGain;
      break;
    case 2:
      axVel = remoteAxialGain * (float)(digitalRead(pushOne) - digitalRead(pushOne));
      
      rotCountTemp = analogRead(potTwo);
      rotVel = (rotCountTemp - rotCountPrev) * remoteRotatGain;
      rotCountPrev = rotCountTemp;
      break;
    case 3:
      axCountTemp = analogRead(potOne);
      axVel = (axCountTemp - axCountPrev) * remoteAxialGain;
      axCountPrev = axCountTemp;
      
      rotCountTemp = analogRead(potTwo);
      rotVel = (rotCountTemp - rotCountPrev) * remoteRotatGain;
      rotCountPrev = rotCountTemp;
      break;
    case 4:
      axCountTemp = analogRead(potOne);
      axVel = (axCountTemp - axCountPrev) * remoteAxialGain;
      axCountPrev = axCountTemp;
      
      rotCountTemp = analogRead(potTwo);
      rotVel = (rotCountTemp - rotCountPrev) * remoteRotatGain;
      rotCountPrev = rotCountTemp;
      break;
    default:
      digitalWrite(ledPin, HIGH);
      break;
  }
}

void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    switch(inChar) {
      case '1':
        device = 1;
        Serial.println(device);
        digitalWrite(ledPin, LOW);
        break;
      case '2':
        device = 2;
        Serial.println(device);
        digitalWrite(ledPin, LOW);
        break;
      case '3':
        device = 3;
        Serial.println(device);
        digitalWrite(ledPin, LOW);
        break;
      case '4':
        device = 4;
        Serial.println(device);
        digitalWrite(ledPin, LOW);
        break;
      case 'R':
        Serial.print(device);
        Serial.print("a");
        Serial.print(axVel, 4);
        Serial.print("r");
        Serial.println(rotVel, 4);
        break;
      case '\n':
        break;
      default:
        digitalWrite(ledPin, HIGH);
        Serial.println("Error");
        break;
    }
  }
}
