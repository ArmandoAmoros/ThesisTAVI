/* Wheatstone Bridge Interface - Library */

/*
	This library was created by Sébastien Parent-Charette for RobotShop.
	It is meant to be used with the RB-Onl-38 from RobotShop.
	This product is available here: http://www.robotshop.com/en/strain-gauge-load-cell-amplifier-shield-2ch.html
	This library may work with other WheatStone bridge interface boards that use an analog pin for input.
	
	Changes history:
	2016-07-28
	v1.10-16
	Changed output to be on one line.
	Corrected default init of strain1 to be 1000 (instead of 750).

	2016-04-21
	v1.10-08
	Added reading and display of both load cells to the basic example.
	
	2015-10-08
	v1.0
	First release of the library. Basic functionality is available.
*/

#include <WheatstoneBridge.h>
using namespace std; 

//WheatstoneBridge wsb_strain2(A1, 368, 380, 0, 191);
WheatstoneBridge wsb_strain2(A0, 369, 386, 0, 187);

void setup()
{
  Serial.begin(9600);
  Serial.println("< Wheatstone Bridge Interface to Serial >");
  Serial.println("");
}

int val2;
int valRaw2;
int iterations = 201;
int maxNum = 0;

void loop()
{
  int idxString[iterations];
  int valString[iterations];
  // Read strain 2
  for(int i = 0; i < iterations; i++){
    valString[i] = wsb_strain2.measureForce();
    idxString[i] = wsb_strain2.getLastForceRawADC();
  }
  for(int i = 0; i < iterations; i++) {
    for(int j = i+1; j < iterations; j++) {
      if(valString[i] > valString[j]) {
        int a =  valString[i];
        valString[i] = valString[j];
        valString[j] = a;
      }
      if(idxString[i] > idxString[j]) {
        int b =  idxString[i];
        idxString[i] = idxString[j];
        idxString[j] = b;
      }
    }
  }

  if (maxNum < valString[(iterations-1)/2]) {
    maxNum = valString[(iterations-1)/2];
  }
  
  val2 = valString[(iterations-1)/2];
  valRaw2 = idxString[(iterations-1)/2];
  Serial.println(">> Strain 2 << ");
  Serial.print("\tRaw value: ");
  Serial.print(valRaw2, DEC);
  Serial.print("\t");
  Serial.print("\tForce: ");
  Serial.print(val2, DEC);
  Serial.print("\t");
  Serial.print("\tMax: ");
  Serial.println(maxNum, DEC);
  Serial.println("");
}

/* Wheatstone Bridge Interface - Library */
