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
 * Simple "LED and GPIO (ext. button)" Example
 *
 * As long as the external button connected to UI1 is pressed, the LED lights up green. If the external button is released, 
 * the LED is turned off.
 *
 * Note: The external button must be placed between UI1 and ground. Furthermore, a pullup between the UI1 and VEXT is required.
 * 
 * Only compatible with myDatalogEASY V3
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
  
  Led_Off(false, true); // Switches off green LED
  
  // Activates switchable 3.3V supply voltage
  iResult = Ext3V3_On();                 
  if(iResult < OK)
    printf("Ext3V3_On() = %d\r\n", iResult);
  
  // Initialises UI1 as digital input with 10ms filter time
  iResult = UI_Init(UI_CHANNEL1, UI_CHT_SI_DIGITAL, 10);
  if(iResult < OK)
    printf("UI_Init(%d) = %d\r\n", UI_CHANNEL1, iResult);
}

/* 100ms timer used to check the current state of the UI1 and control the green LED */
public Timer100ms()
{
  new iState;                   // Temporary memory for the current state of the UI1
  new iResult;                  // Temporary memory for the return value of a function
  
  // Reads the signal level at the UI1 (0 =^ "low" signal level, 1 =^ "high" signal level) 
  iResult = UI_GetValue(UI_CHANNEL1, iState);
  if(iResult != OK)
    printf("UI_GetValue(%d) = %d\r\n", UI_CHANNEL1, iResult);
  
  iState = !iState;             // Button has an inverted logic (0 =^ pressed, 1 ^= not released)
  
  if(iState)                    // If the button is pressed  ->
  {
    Led_On(false, true);        // Turns on the green LED
  }
  else                          // Otherwise -> button is released
  {
    Led_Off(false, true);       // Switches off green LED
  }
}
