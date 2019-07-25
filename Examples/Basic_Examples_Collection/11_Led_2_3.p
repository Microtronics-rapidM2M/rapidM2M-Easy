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
 * Extended "LED" Example
 *
 * Toggles external LED2 (VEXT) and external LED3 (VOUT) every second
 * If external LED2 is on, then external LED3 is off and vice versa.
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
static iLedState;                           // Current LED state (1=^ external LED2 "On" and external LED3 "Off"
                                            //                    x=^ external LED2 "Off" and external LED3 "On")

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
  if(iLedState)                             // If external LED2 is currently "On" and external LED3 is currently "Off" ->  
  { 
    /* Deactivates the switchable 3.3V supply voltage VEXT used to control the external LED2 */
    Ext3V3_Off();                           // Turns off external LED2
    /* Activates the switchable sensor supply voltage VOUT used to control the external LED3
       In this case the lower voltage mode (15V/45mA) is used */
    Vsens_On(VSENS_15V);                    // Turns on external LED3
    printf("[LED] 2:off 3:on\r\n");
  }
  else                                      // Otherwise (i.e. external LED2 "Off" and external LED3 "On")
  { 
    /* Activates the switchable 3.3V supply voltage VEXT used to control the external LED2 */
    Ext3V3_On();                            // Turns on external LED2
    /* Deactivates the switchable sensor supply voltage VOUT used to control the external LED3 */
    Vsens_Off();                            // Turns off external LED3
    printf("[LED] 2:on 3:off\r\n");
  }
  
  iLedState = !iLedState;                   // Toggles the variable which holds the current LED state
}
