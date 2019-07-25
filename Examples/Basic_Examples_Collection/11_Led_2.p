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
 * Toggles an external LED connected to VEXT every second
 *
 * Only compatible with myDatalogEASY V3
 * Special hardware circuit necessary
 *
 * @version 20190701
 */

/* Path for hardware-specific include file */
#include ".\rapidM2M Easy\easyV3"

/* Forward declarations of public functions */
forward public MainTimer();                 // Called up 1x per sec. for the program sequence

/* Global variables declarations */
static iLedState;                           // Current state of external LED on VEXT (1=^ On; x=^Off)

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
}

/* 1 sec. timer is used for the general program sequence */
public MainTimer()
{  
  if(iLedState)								// If external LED is currently "On" ->
  {
    /* Deactivates the switchable 3.3V supply voltage VEXT used to control the external LED */
    Ext3V3_Off();                            // Turns off external LED
    printf("[LED] off\r\n");
  }
  else                                      // Otherwise (i.e. external LED is off)
  {
    /* Activates the switchable 3.3V supply voltage VEXT used to control the external LED */
    Ext3V3_On();                            // Turns on external LED2
    printf("[LED] on\r\n");
  }
  
  // Change state of external LED
  iLedState = !iLedState;                   // Toggles the variable which holds the current state of external LED
}
