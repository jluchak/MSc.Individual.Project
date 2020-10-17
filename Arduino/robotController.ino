// Add in neccessary Libraries
#include <Wire.h>
#include <SPI.h>
#include <EEPROM.h>
#include <Adafruit_MotorShield.h> // for the Adafruit Motor Shield v2.1
#include <boards.h> // for writing and reading digital/analog pins
#include <RBL_nRF8001.h> // for Red Bear Lab BLE Shield connection
#include <math.h> // for calculations in script

// Define the Pins used for the switches
#define home_switchX 3 // Pin 3 connected to Home Switch #1 (MicroSwitch)
#define home_switchY 7 // Pin 7 connected to Home Switch #2 (MicroSwitch)

// Initialize variables of types string, char, and int
String readString, value;
char command;
int n, L, xHome, yHome, xCord, yCord; //declare as number 

// Define the motor shields in use
Adafruit_MotorShield AFMSbottom(0x60); // no jumpers closed
Adafruit_MotorShield AFMStop(0x61); // Rightmost jumper closed

// Define the motors in use
Adafruit_StepperMotor *myStepperX = AFMStop.getStepper(200,1); // M1 and M2
Adafruit_StepperMotor *myStepperY = AFMStop.getStepper(200,2); // M3 and M4
Adafruit_StepperMotor *myStepper3 = AFMSbottom.getStepper(200,2); // M1 and M2

/////////////////////////////////////////////////////////////////////////////////////////////////  

void setup() 
{  
  // Initialize Serial communication
  Serial.begin(9600); // Begin Serial at baud rate 9600
  Serial.setTimeout(50);
  Serial.println ("Starting ...");

  // Initialize Bluetooth communication
  ble_set_pins(9,8); 
  ble_begin ();
  
  // Initialize baud rates of bottom and top motor shields
  AFMSbottom.begin();  // default frequency 1.6KHz
  AFMStop.begin();  // default frequency 1.6KHz
   
  //////////////////////////////////////////////////////////////////////
  // Start Homing procedure of Stepper Motor in X direction at startup
  //////////////////////////////////////////////////////////////////////
  myStepperX->setSpeed(10);
  pinMode(home_switchX, INPUT_PULLUP);
  
  while (digitalRead(home_switchX)) // Do this until switch X is activated 
  {    
    myStepperX->step(1, FORWARD, SINGLE); 
    Serial.println("Switch Activated");
    delay(10); //wait a few seconds
  }
  while (!digitalRead(home_switchX)) // Do this until switch X is not activated
  { 
    myStepperX->step(1, BACKWARD, SINGLE);
    Serial.println("Switch De-activated");
    delay(500);
  }
  myStepperX->step(50, BACKWARD, SINGLE); //
  delay(100); // wait a bit
  
  xHome = 0;  // Reset position variable to zero
  Serial.println("X direction is calibrated!");

//  //////////////////////////////////////////////////////////////////////
//  // Start Homing procedure of Stepper Motors in Y direction at startup
//  //////////////////////////////////////////////////////////////////////
  myStepperY->setSpeed(10);
  pinMode(home_switchY, INPUT_PULLUP);
  
  while (digitalRead(home_switchY)) // Do this until switch Y is activated 
  {    
    myStepperY->step(1, FORWARD, SINGLE); 
    Serial.println("Switch Activated");
    delay(10); //wait a few seconds
  }
  while (!digitalRead(home_switchY)) // Do this until switch Y is not activated
  { 
    myStepperY->step(1, BACKWARD, SINGLE);
    Serial.println("Switch De-activated");
    delay(500);
  }
  myStepperY->step(50, BACKWARD, SINGLE); //
  delay(100); // wait a bit
  
  yHome = 0;  // Reset position variable to zero
  Serial.println("Y direction is calibrated!");



myStepper3->setSpeed(10);



}
//////////////////////////////////////////////////////////////////////////////////////////////////

void serialRead() 
{ 
  while (ble_available()) 
  {
    delay(5);  
    if (ble_available() > 0) 
    {
      char c = ble_read(); // gets one byte from serial buffer
      if (c == '>')
      {
        // Store the read data into variables
         L = readString.length();
         command = readString.charAt(0); // get the first character         
         value = readString.substring(1,L); // get the rest of characters into a string
         n = value.toInt();  //convert into a number
      }
      else
      {
        readString += c; // Add each char into string
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////

void loop() 
{
  ble_do_events(); // Discover BLE
  if (ble_available() > 0)
  {
    // Read the data received from BLE
    readString=""; //clears variable for new input
    serialRead(); 
    Serial.print(command);
    switch(command)
    {
      case'F':  // translate forward i.e. ADVANCE
        {
          ADVANCE();
        }
        break;
        
      case 'B':  // translate backward i.e. REVERSE
        {
          REVERSE();
        }
        break;
        
      case 'S':  // stop translation
        {
          // Do nothing, let stepper motors hold position
        }
        break;
        
      case'R': // positive x direction i.e. RIGHT
        {
          xCord = n;
          RIGHT();
        }
        break;
        
      case'L': // negative x direction i.e LEFT
        {
          xCord = n;
          LEFT();
        }
        break;
        
      case'U': // positive y direction i.e. UP
        {
          yCord = n;
          UP();
        }
        break;
        
      case'D': // negative y direction i.e. DOWN
        {
          yCord = n;
          DOWN();
        }
        break;
    }
    ble_do_events(); // Discover BLE
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////

void ADVANCE() 
{ 
  myStepper3->step(1, FORWARD, MICROSTEP);
}

////////////////////////////////////////////////////////////////////////////////////////////////

void REVERSE() 
{
  myStepper3->step(1, BACKWARD, MICROSTEP);
}

////////////////////////////////////////////////////////////////////////////////////////////////

void RIGHT()
{
  delay(50);
  while (xCord > xHome)
  {
    myStepperX->step(1, FORWARD, SINGLE);
    //myStepperX->step(4, FORWARD, MICROSTEP);
    delay(1);
    xHome++;  // Increase the number of steps taken
  }
  while (xCord < xHome)
  {
    myStepperX->step(1, BACKWARD, SINGLE);
    //myStepperX->step(4, BACKWARD, MICROSTEP);
    delay(1);
    xHome--;  // Decrease the number of steps taken
  }
  if (xCord == xHome)
  {
    delay(1);
    return;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////

void LEFT()
{
  delay(50);
  while (xCord < xHome)
  {
    myStepperX->step(1, BACKWARD, SINGLE);
    //myStepperX->step(4, BACKWARD, MICROSTEP);
    delay(1);
    xHome--;  // Increase the number of steps taken in negative direction
  }
  while (xCord > xHome)
  {
    myStepperX->step(1, FORWARD, SINGLE);
    //myStepperX->step(4, FORWARD, MICROSTEP);
    delay(1);
    xHome++;  // Decrease the number of steps taken in negaive direction
  }
  if (xCord == xHome)
  {
    delay(1);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////

void UP()
{
  delay(50);
  while (yCord > yHome)
  {
    myStepperY->step(1, FORWARD, SINGLE);
    //myStepperY->step(4, FORWARD, MICROSTEP);
    delay(1);
    yHome++;  // Increase the number of steps taken
  }
  while (yCord < yHome)
  {
    myStepperY->step(1, BACKWARD, SINGLE);
    //myStepperY->step(4, BACKWARD, MICROSTEP);
    delay(1);
    yHome--;  // Decrease the number of steps taken
  }
  if (yCord == yHome)
  {
    delay(1);
    return;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////

void DOWN()
{
  delay(50);
  while (yCord < yHome)
  {
    myStepperY->step(1, BACKWARD, SINGLE);
    //myStepperY->step(4, BACKWARD, MICROSTEP);
    delay(1);
    yHome--;  // Increase the number of steps taken in negative direction
  }
  while (yCord > yHome)
  {
    myStepperY->step(1, FORWARD, SINGLE);
    //myStepperY->step(4, FORWARD, MICROSTEP);
    delay(1);
    yHome++;  // Decrease the number of steps taken in negaive direction
  }
  if (yCord == yHome)
  {
    delay(1);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////
