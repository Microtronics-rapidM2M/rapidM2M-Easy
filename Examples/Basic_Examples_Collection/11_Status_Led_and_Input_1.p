/**
 *                  _     _  __  __ ___  __  __
 *                 (_)   | ||  \/  |__ \|  \/  |
 *  _ __ __ _ _ __  _  __| || \  / |  ) | \  / |
 * | '__/ _` | '_ \| |/ _` || |\/| | / /| |\/| |
 * | | | (_| | |_) | | (_| || |  | |/ /_| |  | |
 * |_|  \__,_| .__/|_|\__,_||_|  |_|____|_|  |_|
 *           | |
 *           |_|
 * 
 * Extended "LED and GPIO (ext. button)" Example
 * 
 * Changes the colour and mode of the red and green LEDs each time the external button connected to UI1 is pressed.
 * 
 * The following sequence arises: Off - Red flashing - Green blinking - Yellow flickering - Yellow on
 * 
 * Note: The external button must be placed between UI1 and ground. Furthermore, a pullup between the UI1 and VEXT is required.
 * 
 * Only compatible with myDatalogEASYv3
 * Special hardware circuit necessary
 * 
 * @version 20190625
 */
 
/* Path for hardware-specific include file */
#include ".\rapidM2M Easy\easyV3"

/* Forward declarations of public functions */
forward public Timer100ms();                     // Called up every 100ms to check the current state of the UI1 and control the LED

/* Application entry point */
main()
{
  /* Temporary memory for the index of a public function and the return value of a function             */
  new iIdx, iResult;

  printf("Led Demo\r\n");                        // Issues the name of the example via the console 

  /* Initialisation of a 100ms timer used to check the current state of the UI1 and control the LED
     - Determining the function index that should be executed every 100ms
     - Transferring the index to the system and informing it that the timer should be restarted 
	   following expiry of the interval
     - Index and return value of the init function are issued by the console                            */   
  iIdx = funcidx("Timer100ms");
  iResult = rM2M_TimerAddExt(iIdx, true, 100);
  printf("rM2M_TimerAddExt(%d) = %d\r\n", iIdx, iResult);

  /* Initialisation of the LED -> Control via script activated */ 
  iResult = Led_Init(LED_MODE_SCRIPT);
  printf("Led_Init() = %d\r\n", iResult);
  
  Led_Off(true, true);           // Turns off both LEDs
  
  // Activates switchable 3.3V supply voltage
  iResult = Ext3V3_On();                 
  if(iResult < OK)
    printf("Ext3V3_On() = %d\r\n", iResult);
  
  // Initialises UI1 as digital input with 10ms filter time
  iResult = UI_Init(UI_CHANNEL1, UI_CHT_SI_DIGITAL, 10);
  if(iResult < OK)
    printf("UI_Init(%d) = %d\r\n", UI_CHANNEL1, iResult);
}

/* 100ms timer used to check the current state of the UI1 and control the LEDs */
public Timer100ms()
{
  static iLed;       // Current state of LEDs (0 =^ off; 1 =^ red flashing, 2 ^= green blinking, 3 ^= yellow flickering, 4 ^= yellow on)
  static iStatePrev; // Last determined state of the UI1
  new iState;        // Temporary memory for the current state of the UI1
  new iResult;       // Temporary memory for the return value of a function

  // Reads the signal level at the UI1 (0 =^ "low" signal level, 1 =^ "high" signal level) 
  iResult = UI_GetValue(UI_CHANNEL1, iState);
  if(iResult != OK)
    printf("UI_GetValue(%d) = %d\r\n", UI_CHANNEL1, iResult);
										 // Button has an inverted logic (0 =^ pressed, 1 ^= not released)
  
  // If the UI1 state has changed and the button is currently pressed ->
  if((iState != iStatePrev) && !iState) 
  {
    iLed = (iLed + 1) % 5;             // Increases counter for the LED state. It is ensured that the counter reading does not exceed 4.
    printf("Led-State: %d\r\n", iLed); // Issues newly determined LED state via the console
    
    switch(iLed)                       // Switches the newly determined LED state ->
    {
      case 0:
      {
        Led_Off(true, true);           // Turns off both LED
      }
      case 1:
	    {
	      Led_Off(true, true);
        Led_Flash(0, -1);              // Makes the LED flash red
      }
	    case 2:
	    {
	      Led_Off(true, true);
        Led_Blink(-1, 0);              // Makes the LED blink green
      }
	    case 3:
      {
        Led_Flicker(0, 0);             // Makes the LED flicker yellow
      }
      case 4: 
      {
        Led_On(true, true);            // Makes the LED light up yellow
      }
    }
  }
  iStatePrev = iState;                 // Copies current UI1 status to the variable for the last determined UI1 status 
}
