/*
 *                  _     _  __  __ ___  __  __
 *                 (_)   | ||  \/  |__ \|  \/  |
 *  _ __ __ _ _ __  _  __| || \  / |  ) | \  / |
 * | '__/ _` | '_ \| |/ _` || |\/| | / /| |\/| |
 * | | | (_| | |_) | | (_| || |  | |/ /_| |  | |
 * |_|  \__,_| .__/|_|\__,_||_|  |_|____|_|  |_|
 *           | |
 *           |_|
 * 
 * 
 * Simple "UI" Test application
 * 
 * Demonstrates how to initialise UI channels and read out measurement values.
 * The results are issued by the console.
 * 
 * Only compatible with myDatalogEASY V3
 * 
 * @version 20190705  
 */

/* Path for hardware-specific include file */
#include ".\rapidM2M Easy\easyV3"
 
/* Forward declarations of public functions */
forward public Timer1s();

/* Application entry point */
main()
{
  /* Temporary memory for the index of a public function and the return value of a function  */
  new iIdx, iResult;

  /* Initialisation of a 1 sec. timer used for the general program sequence
     - Determining the function index that should be executed 1x per sec.
     - Transferring the index to the system
     - Index and function return value used to generate the timer are issued via the console */
  iIdx = funcidx("Timer1s");
  iResult = rM2M_TimerAdd(iIdx);
  printf("rM2M_TimerAdd(%d) = %d\r\n", iIdx, iResult);
  
  // Sets sample rate to 128 Hz (default: 16Hz)
  UI_SetSampleRate(UI_SAMPLE_RATE_128);
  
  /* Initialisation of the four UI channels:
     Channel | Mode            | Filtertime
     ------------------------------------
     UI 1    | Digital input   |   10 ms
     UI 2    | Digital counter |   10 ms
     UI 3    | 0 ... 20 mA     |   10 ms
     UI 4    | 0 ... 10 V      |   10 ms
     
     When a channel is used as digital input or digital counter, the filtertime determines
     how long a signal level must be constant to trigger a level change. When a channel
     is used as 0...20mA interface or 0...10V interface, the filtertime determines the time
     in which the analog signal is averaged. */
  UI_Init(UI_CHANNEL1, UI_CHT_SI_DIGITAL, 10);
  UI_Init(UI_CHANNEL2, UI_CHT_SI_DCTR, 10);
  UI_Init(UI_CHANNEL3, UI_CHT_SI_A020MA, 10);
  UI_Init(UI_CHANNEL4, UI_CHT_SI_A010V, 10);
}

/* 1s Timer used to get UI channel values and issue them via the console */
public Timer1s()
{
  new iValue, iResult;  // Temporary memory for the channel value and the return value of a function
  
  /* The for loop prints the determined measurement values of all four myDatalogEASY V3 channels.
     An index variable counts up until it reaches the maximum UI channel number UI_NUM_CHANNELS */
  for(new iIdx=0; iIdx < UI_NUM_CHANNELS; iIdx++)
  {
      /* Gets the measurement value for the specific channel
     - Reading value from channel
     - In case of a problem the index and return value of the UI_GetValue() function are issued by the console  */
    iResult = UI_GetValue(iIdx, iValue);
    if(iResult != OK)
      printf("UI_GetValue(%d) = %d\r\n", iIdx, iResult);
    
    // Prints the measured channel value to the console
    printf("Channel%d = %d\r\n", iIdx, iValue);
  }
}
