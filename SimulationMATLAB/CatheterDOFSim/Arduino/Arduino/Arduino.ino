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

#define keyboardAxialGain 5.0
#define keyboardRotatGain 0.1
#define remoteAxialGain 5.0
#define remoteRotatGain 0.01
#define joystickAxialGain 0.1
#define joystickRotatGain 0.001
#define catheterAxialGain 0.01
#define catheterRotatGain 0.01

void setup() {
  Serial.begin(9600);
  pinMode(pushOne, INPUT_PULLUP); // Set pushOne as INPUT
  pinMode(pushTwo, INPUT_PULLUP); // Set pushOne as INPUT
  pinMode(ledPin, OUTPUT); // Set pushOne as INPUT
}

void loop() {
  switch(device){
    case 1:
      axVel = keyboardAxialGain;
      rotVel = keyboardRotatGain;
      break;
    case 2:
      axVel = - remoteAxialGain * (float)(digitalRead(pushOne) - digitalRead(pushTwo));
      
      rotCountTemp = analogRead(potOne);
      rotVel = getRotation(rotCountPrev, rotCountTemp, remoteRotatGain);
      rotCountPrev = rotCountTemp;
      break;
    case 3:
      axVel = getPotMove(analogRead(potOne), 513, joystickAxialGain, 20);
      
      rotVel = -getPotMove(analogRead(potTwo), 359, joystickRotatGain, 20);
      break;
    case 4:
      axVel = getPotMove(analogRead(potOne), 513, catheterAxialGain, 20);
      
      rotCountTemp = analogRead(potTwo);
      rotVel = -getRotation(rotCountPrev, rotCountTemp, catheterRotatGain);
      rotCountPrev = rotCountTemp;
      break;
    default:
      digitalWrite(ledPin, HIGH);
      break;
  }
  Serial.println(rotVel);
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

float getRotation(float prev, float next, float gain) {
  float temp;

  temp = (next - prev) * gain;
  if ((next - prev) > 900) {
    temp = ((next - prev) - 1024) * gain;
  }
  if ((next - prev) < -900) {
    temp = ((next - prev) + 1024) * gain;
  }
  if (abs(next - prev) < 5) {
     temp = 0;
  }
  return temp;
}

float getPotMove(float val, float zero, float gain, float tolerance) {
  float temp;

  if (abs(val - zero) < tolerance) {
    temp = 0;
  } else {
    temp = (val - zero) * gain;
  }
  return temp;
}
