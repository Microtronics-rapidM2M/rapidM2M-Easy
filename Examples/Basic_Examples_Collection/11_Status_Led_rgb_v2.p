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
 * "Red and Green LED" Example V2
 *
 * Changes the color of the red and green LED each second. To do this, a counter is repeatedly increased 
 * from 0 to 3. Each bit of the counter is assigned a color of the red and green LED.
 *
 * Bit0 = Red
 * Bit1 = Green
 *
 * This results in the following color sequence: Off - Red - Green - Yellow
 *
 * Only compatible with myDatalogEASY V3
 *
 * @version 20190625
 */

/* Path for hardware-specific include file */
#include ".\rapidM2M Easy\easyV3"

/* Specifies which bit is assigned to the individual colors of the red and green LED */
const
{
  LED_R = 0, //Bit that is assigned to the red LED   (0 =^ Off; 1 =^ On)
  LED_G = 1, //Bit that is assigned to the green LED (0 =^ Off; 1 =^ On)
}

/* Forward declarations of public functions */
forward public MainTimer();                 // Called up 1x per sec. for the program sequence

/* Global variable declarations */
static iLedState;

/* Application entry point */
main()
{
 /* Temporary memory for the index of a public function and the return value of a function  */
  new iIdx, iResult;
  
  /* Initialisation of a 1 sec. timer used for the general program sequence
     - Determining the function index that should be executed 1x per sec.
     - Transferring the index to the system
     - In case of a problem the index and return value of the init function are issued by the console  */
  iIdx = funcidx("MainTimer");
  iResult = rM2M_TimerAdd(iIdx);
  if(iResult < OK)
    printf("rM2M_TimerAddExt(%d) = %d\r\n", iIdx, iResult);
  
  /* Initialisation of the LED -> Control via script activated */ 
  iResult = Led_Init(LED_MODE_SCRIPT);
  printf("Led_Init() = %d\r\n", iResult);
  
  Led_Off(true, true);     // Switches off LED
}

/* 1 sec. timer is used for the general program sequence */
public MainTimer()
{  
  printf("[LED] State: %d\r\n", iLedState);    // Issues the current LED state via the console
  
  /* Shifts the content of the variable holding the LED status so that the bit assigned to the 
     respective colour is at position 0 (bit0). This is followed by an "and" conjunction with the 
	 value "1". If the result is 0, the respective colour is switched off. If the result is 1, 
	 the respective colour is switched on.                                                      */  
  Led_On((iLedState >> LED_R) & 1, (iLedState >> LED_G) & 1);        // Switches on colours if corresponding bit is set
  Led_Off(!((iLedState >> LED_R) & 1), !((iLedState >> LED_G) & 1)); // Switches off colours if corresponding bit is cleared

  // Increases counter for the LED state. It is ensured that the counter reading does not exceed 3.
  iLedState = (iLedState + 1) & (0x03);
}

