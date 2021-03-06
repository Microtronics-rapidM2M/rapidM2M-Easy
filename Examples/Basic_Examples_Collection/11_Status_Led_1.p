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
 * Simple "LED" Example
 *
 * Toggles green LED every second
 *
 * Only compatible with myDatalogEASY V3
 *
 * @version 20190624  
 */

/* Path for hardware-specific include file */
#include ".\rapidM2M Easy\easyV3"

/* Forward declarations of public functions */
forward public MainTimer();                 // Called up 1x per sec. for the program sequence

/* Global variables declarations */
static iLedState;                           // Current state of LED 2 (1 =^ On; x =^ Off)

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
  
  /* Initialisation of the LED -> control via script activated */ 
  iResult = Led_Init(LED_MODE_SCRIPT);
  printf("Led_Init() = %d\r\n", iResult);
}

/* 1 sec. timer is used for the general program sequence */
public MainTimer()
{  
  if(iLedState)				 // If green LED is currently "On" ->
  { 
    Led_Off(false, true);    // Turns off green LED
    printf("[LED] off\r\n");
  }
  else                       // Otherwise (i.e. green LED is off)
  { 
    Led_On(false, true);     // Turns on green LED
    printf("[LED] on\r\n");
  }
  
  // Change state of LED
  iLedState = !iLedState;    // Toggles the variable which holds the current state of the green LED
}

