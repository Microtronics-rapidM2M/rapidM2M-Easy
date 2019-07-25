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
 * Extended "LED and Reed switch" Example
 *
 * Changes the colour and mode of the red and green LEDs each time the reed switch is closed.
 * 
 * The following sequence arises: Off - Red flashing - Green blinking - Yellow flickering - Yellow on
 * 
 * Only compatible with myDatalogEASY V3
 * 
 * @version 20190624
 */
 
/* Path for hardware-specific include file */
#include ".\rapidM2M Easy\easyV3"

/* Forward declarations of public functions */
forward public KeyChanged(iState);       // Called up when the reed switch opens or closes

/* Application entry point */
main()
{
  /* Temporary memory for the index of a public function and the return value of a function             */
  new iIdx, iResult;

  printf("Led Demo\r\n");          // Issues the name of the example via the console 

  /* Initialisation of the reed switch -> Evaluation by the script activated
     - Determining the function index that should be called up when opening or closing the reed switch
     - Transferring the index to the system and informing it that the reed switch is controlled by the script
     - Index and return value of the init function are issued by the console                            */
  iIdx = funcidx("KeyChanged");                        
  iResult = Switch_Init(SWITCH_MODE_SCRIPT, iIdx);     
  printf("Switch_Init(%d) = %d\r\n", iIdx, iResult); 

  /* Initialisation of the LED -> Control via script activated */ 
  iResult = Led_Init(LED_MODE_SCRIPT);
  printf("Led_Init() = %d\r\n", iResult);
  
  Led_Off(true, true);                  // Switches off both LEDs
}

/**
 * Function that should be called up when the reed switch closes or opens
 *
 * @param iState:s32 - Signal level
 *					   0: Reed switch opened
 *                     1: Reed switch closed
 */
public KeyChanged(iState)
{
  static iLed;                         // Current state of LED (0 =^ off; 1 =^ red flashing, 2 ^= green blinking, 3 ^= yellow flickering, 4 ^= yellow on)

  if(iState)                           // If the reed switch is closed 
  {
    iLed = (iLed + 1) % 5;             // Increases counter for the LED state. It is ensured that the counter reading does not exceed 4.
    printf("Led-State: %d\r\n", iLed); // Issues newly determined LED state via the console
    
    switch(iLed)                       // Switches the newly determined LED state ->
    {
      case 0:
        Led_Off(true, true);           // Turns off both LEDs
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
        Led_Flicker(0, 0);             // Makes the LED flicker yellow
      case 4: 
        Led_On(true, true);            // Makes the LED light up yellow
    }
  }
}