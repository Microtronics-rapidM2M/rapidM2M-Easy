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
 * Simple "LED and reed switch" Example
 *
 * As long as a magnetic field is present at the reed switch, the LED lights up green.
 * If no magnetic field is present, the LED is turned off.
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
  
  Led_Off(false, true);                  // Switches off green LED
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
  if(iState)                               // If the reed switch closed 
  {
    Led_On(false, true);                   // Turns on the green LED
  }
  else                                     // Otherwise -> the reed switch opened
  {
    Led_Off(false, true);                  // Switches off green LED
  }
}