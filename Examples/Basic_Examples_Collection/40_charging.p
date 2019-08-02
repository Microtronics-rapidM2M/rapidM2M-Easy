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
 * Simple "Changing Application" example
 *
 * If a Power Supply Unit (PSU), which contains a rechargeable li-ion battery, is inserted into the
 * myDatalogEASY V3 and the state of charge of the rechargeable battery is below 50% charging control
 * is activated. The rechargeable battery is charged to the maximum voltage and the charge control 
 * is then deactivated again. If the state of charge of the rechargeable battery is above 50% the 
 * charging control is not activated and "Battery is fully charged" is indicated immediately.
 * The current state of the charging control is displayed via the status LED (see blink codes below)
 *
 * Blink codes:
 * 1x red: Error battery type - battery is not LiOn
 * 2x red: Error battery - battery has an error
 * 3x red: Error voltage - is lower than 5V
 *
 * Green blinking: charging active
 * Green constantly on: charging finished
 * 
 * Off: charging not active
 *
 * Only compatible with myDatalogEASY V3
 *
 * @version 20190722  
 */

#include ".\rapidM2M Easy\easyV3.inc"

/* Forward declarations of public functions */
forward public Timer1s();                   // Called up 1x per sec. for the program sequence

const
{
  INTERVAL_TX     = 120 * 60,               // Interval of transmission [s]
  INTERVAL_UPDATE = 5,                      // Update interval for indicating the error blink codes  
}

// States of the charging control that can be displayed via status LED
const
{
  STATE_NONE          = 0,                  // Idle
  STATE_CHARGING,                           // Charging control is active
  STATE_CHARGING_FINISHED,                  // Battery is fully charged
  STATE_ERROR_BATTERY_TYPE,                 // Error: Inserted PSU is not a rechargeable li-ion battery 
  STATE_ERROR_BATTERY,                      // Error: Power management indicates an error
  STATE_ERROR_VOLTAGE,                      // Error: Supply voltage (V IN) of the myDatalogEASY V3 is too low  
}

static iTimerTx;                            // Sec. until the next transmission 
static iTimerLed;                           // Counter used to control the status LED
static iState;                              // Current state of the charging control 

/* Application entry point */
main()
{
 /* Temporary memory for the index of a public function and the return value of a function  */
  new iIdx, iResult;

  /* Initialisation of a 1 sec. timer used for the general program sequence
     - Determining the function index that should be executed 1x per sec.
     - Transferring the index to the system
	 - In case of a problem the index and return value of the init function are issued by the console  */
  iIdx = funcidx("Timer1s");
  iResult = rM2M_TimerAdd(iIdx);
  if(iResult < OK)
    printf("rM2M_TimerAdd(%d) = %d\r\n", iIdx, iResult);  
  
   /* Initialisation of the status LED -> control via script activated */ 
  iResult = Led_Init(LED_MODE_SCRIPT);
  
  iTimerTx  = INTERVAL_TX;                  // Sets counter variable to defined transmission interval
  
  PM_SetChargingMode(PM_CHARGING_NORMAL);   // Sets the charging mode to "Charge if the state of charge of the rechargeable battery is <50%"
  
  rM2M_TxSetMode(RM2M_TXMODE_WAKEUP);       // Sets the connection type to "Wakeup" mode
  rM2M_TxStart();                           // Initiates a connection to the server
}

/* 1 sec. timer is used for the general program sequence */
public Timer1s()
{
  Handle_ChargingState();                   // Control of the indication of the current charging state 
  Handle_StatusLed();                       // Control of the LED 
  Handle_Transmission();                    // Control of the transmission
}

/**
 * Changes the state that should be displayed via the status LED 
 *
 * @param iNewState:s32 - New state that should be displayed via the status LED
 */
SetState(iNewState)
{
  if(iState != iNewState)                   // If the status to be set differs from the current status ->
  {
    iState = iNewState;                     // Copies new status to the variable for the current state that should be displayed via the status LED 
    
	// Sets the counter used to control the status LED to "0" so that the "HandleLed" function can change the mode of the status LED immediately
	iTimerLed = 0;                          
  }
}
/* Determines the current state of the charging control and changes the state that should be displayed via the status LED if necessary */
Handle_ChargingState()
{
  // Temporary memory for information on the energy source used and power management status
  new aPmInfo[TPM_Info];                    // [.BatteryType, .Flags, .VIn, .VBatt, .SOC, .PIn, .ChargingMode]
  
  PM_GetInfo(aPmInfo);                      // Reads out information regarding the energy source used and power management status  
  
  /* Issues the type of the inserted Power Supply Unit (PSU), the power management status, the supply voltage V IN, the voltage of the rechargeable
      battery, the state of charge of the battery, the power consumption and the currently selected charging mode via the console                 */
  printf("BatteryType=%d Flags=%02X VIn=%d VBatt=%d SOC=%d PIn=%d ChargingMode=%02X\r\n",
    aPmInfo.BatteryType, aPmInfo.Flags, aPmInfo.VIn, aPmInfo.VBatt, aPmInfo.SOC, aPmInfo.PIn, aPmInfo.ChargingMode);
    
  if(aPmInfo.VIn < 5000)                    // If the supply voltage (V IN) of the myDatalogEASY V3 is too low -> 
  {
    SetState(STATE_ERROR_VOLTAGE);          // Status LED should blink 3x slowly red every 5 seconds
  }
  else if(aPmInfo.Flags & PM_FLAG_ERROR)    // Otherwise -> if power management indicates an error    
  {
    SetState(STATE_ERROR_BATTERY);          // Status LED should blink 2x slowly red every 5 seconds
  }
  else if(aPmInfo.BatteryType != PM_BATT_TYPE_LIIO)// Otherviese -> if the inserted PSU is not a rechargeable li-ion battery 
  {
    SetState(STATE_ERROR_BATTERY_TYPE);     // Status LED should blink 1x slowly red every 5 seconds
  }
  else                                      // Otherwise (no errors) -> 
  {
    if (aPmInfo.Flags & PM_FLAG_CHARGING)   // If the charging control is active 
    {
      SetState(STATE_CHARGING);             // Status LED should blink continuously slowly green
    }
    else                                    // Otherwise (battery is fully charged)
    {
      SetState(STATE_CHARGING_FINISHED);    // Status LED should light up green
    }
  }
}

/* Function to generate the transmission interval */
Handle_Transmission()
{
  iTimerTx--;                               // Counter counting down the sec. to the next transmission
  if(iTimerTx <= 0)                         // When the counter has expired ->
  {
    print("Start Transmission\r\n");
    rM2M_TxStart();                         // Initiates a connection to the server 
    iTimerTx = INTERVAL_TX;                 // Resets counter var. to defined transmission interval [sec.] 
  }
}

/* Function to control the status LED */
Handle_StatusLed()
{
  iTimerLed--;                              // Decrements the counter used to control the status LED
  if(iTimerLed <= 0)                        // If the counter used to control the status LED has expired ->
  {
    switch(iState)                          // Switches current state that should be displayed via the status LED 
    {
      case STATE_NONE:                      // Charging control idle
      {
        Led_Off(true, true);                // Switches off status LED
      }
      case STATE_CHARGING:                  // Charging control is active
      {
        // Makes the status LED blink green until the state that should be displayed is changed again
		Led_Off(true, true);
        Led_Blink(-1, 0);
        iTimerLed = cellmax;                // Update on new state
      }
      case STATE_CHARGING_FINISHED:         // Battery is fully charged
      {
        // Makes the status LED light up green until the state that should be displayed is changed again
		Led_On(false, true);
        iTimerLed = cellmax;                // Update on new state
      }
      case STATE_ERROR_BATTERY_TYPE:        // Inserted PSU is not a rechargeable li-ion battery 
      {
        // LED should blink 1x red every 5sec.
		Led_Off(true, true);
        Led_Blink(1, -1);
        iTimerLed = INTERVAL_UPDATE;        // Sets counter used to control the status LED to 5sec. (LED blinks 1x again in 5sec.)
      }
      case STATE_ERROR_BATTERY:             // Power management indicates an error
      {
        // LED should blink 2x red every 5sec.
        Led_Off(true, true);
        Led_Blink(2, -1);
        iTimerLed = INTERVAL_UPDATE;        // Sets counter used to control the status LED to 5sec. (LED blinks 2x again in 5sec.)
      }
      case STATE_ERROR_VOLTAGE:             // Supply voltage (V IN) of the myDatalogEASY V3 is too low 
      {
        // LED should blink 3x red every 5sec.	  
        Led_Off(true, true);
        Led_Blink(3, -1);
        iTimerLed = INTERVAL_UPDATE;        // Sets counter used to control the status LED to 5sec. (LED blinks 3x again in 5sec.)
      }
    }
  }
}
