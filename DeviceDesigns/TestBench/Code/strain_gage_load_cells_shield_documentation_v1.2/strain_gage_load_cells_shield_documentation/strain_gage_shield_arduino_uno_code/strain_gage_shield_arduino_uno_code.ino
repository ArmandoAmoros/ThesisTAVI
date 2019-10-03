// SGS Calibration by linear interpolation for Strain 1 and Strain 2

// Put two known loads on the Strain Gauge sensor and write obtained values below :  (You can use Strain 1 or Strain 2 or the two Strains) 

float ReadingA_Strain1 = 301.0;
float LoadA_Strain1 = 0.0; //  (Kg,lbs..) 
float ReadingB_Strain1 = 302.0;
float LoadB_Strain1 = 80.0; //  (Kg,lbs..) 

float ReadingA_Strain2 = 1.0;
float LoadA_Strain2 = 0.0; //  (Kg,lbs..) 
float ReadingB_Strain2 = 60.0;
float LoadB_Strain2 = 80.0; //  (Kg,lbs..) 


int time_step = 2500 ; // reading every 2.5s
long time = 0;

void setup() {
  Serial.begin(9600); //  setup serial baudrate
}

void loop() {
  float newReading_Strain1 = analogRead(0);  // analog in 0 for Strain 1
  float newReading_Strain2 = analogRead(1);  // analog in 1 for Strain 2
  
  // Calculate load by interpolation 
  float load_Strain1 = ((LoadB_Strain1 - LoadA_Strain1)/(ReadingB_Strain1 - ReadingA_Strain1)) * (newReading_Strain1 - ReadingA_Strain1) + LoadA_Strain1;
  float load_Strain2 = ((LoadB_Strain2 - LoadA_Strain2)/(ReadingB_Strain2 - ReadingA_Strain2)) * (newReading_Strain2 - ReadingA_Strain2) + LoadA_Strain2;
  
  // millis returns the number of milliseconds since the board started the current program
  if(millis() > time_step+time) {
    Serial.print("Reading_Strain1 : ");
    Serial.print(newReading_Strain1);     // display strain 1 reading
    Serial.print("  Load_Strain1 : ");
    Serial.println(load_Strain1);     // display strain 1 load
    Serial.println('\n'); 
    Serial.print("Reading_Strain2 : ");
    Serial.print(newReading_Strain2);     // display strain 2 reading
    Serial.print("  Load_Strain2 : ");
    Serial.println(load_Strain2);         // display strain 2 load 
    Serial.println('\n');
    time = millis();
  }
}
