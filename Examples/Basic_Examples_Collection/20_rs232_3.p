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
 * Extended "RS232" Example
 *
 * Receives data via the RS232 interface and scans it for data frames that start with the character "+" and 
 * end either with a carriage return or line feed. The received data is issued again immediately after receiving 
 * it via the RS232 interface. If a complete data frame was received, a string is created that is composed as follows: 
 * "RS232Rx (<number of characters of data frame>) <data frame received via RS232> OK".
 * This string is then issued via the console and the RS232 interface. The received data frame is also evaluated as 
 * follows:
 *  "on":  LED is turned on
 *  "off": LED is turned off   
 *
 * Only compatible with myDatalogEASY V3
 * 
 * @version 20190724
 */

/* Path for hardware-specific include file */
#include ".\rapidM2M Easy\easyV3.inc"

#include "string.inc"

/* Forward declarations of public functions */
forward public RS232Rx(const data{}, len)   // Called up when characters are received via the RS232 interface

const
{
  PORT_RS232 = 0,                           // The first RS232 interface should be used
  MAX_LENGTH = 100,                         // Maximum length for a data frame
  
  /* State of the reception task for data frames  */
  STATE_WAIT_STX = 0,                      // Waits for the start character 
  STATE_WAIT_ETX,                          // Waits for the stop character
  STATE_FINISHED,                          // Complete data frame was received
}

/* Application entry point */
main()
{
  /* Temporary memory for the index of a public function and the return value of a function  */
  new iIdx, iResult;
  
  /* Initialisation of the LED -> Control via script activated */ 
  iResult = Led_Init(LED_MODE_SCRIPT);
  printf("Led_Init() = %d\r\n", iResult);
  Led_Off(true, true);
  
  /* Initialisation of the RS232 interface that should be used 
     - Determining the function index that should be called up when characters are received
     - Transferring the index to the system and configure the interface                      
	     (115200 Baud, 8 data bits, no parity, 1 stop bit)                                     
     - In case of a problem the index and return value of the init function are issued by the console  */	   
  iIdx = funcidx("RS232Rx");
  iResult = RS232_Init(PORT_RS232, 115200, RS232_8_DATABIT|RS232_PARITY_NONE|RS232_1_STOPBIT, iIdx);
  if(iResult < OK)
    printf("RS232_Init(%d) = %d\r\n", iIdx, iResult);
}

/**
 * Callback function that is called up when characters are received via the RS232 interface
 *
 * Receives data via the RS232 interface and scans it for data frames that start with the character "+" and 
 * end either with a carriage return or line feed. If a complete data frame was received, the function to process 
 * the received data frame is called up.
 *
 * @param data[]:u8 - Array that contains the received data 
 * @param len:s32   - Number of received bytes 
 */
public RS232Rx(const data{}, len)
{
  static iState = STATE_WAIT_STX;          // State of the reception task for the data frames   
  static aFrame{MAX_LENGTH};               // Array to store a received data frame 
  static iFrameLength = 0;                 // Number of characters of the received data frame
  
  new iChar;                                // Temporary memory for a character   
  
  RS232_Write(PORT_RS232, data, len);       // Issues the received data via the RS232 interface (Echo Data)
  
  for(new iIdx=0; iIdx < len; iIdx++)       // For all characters just received -> 
  {
    iChar = data{iIdx};                     // Copies the character from the current examined position of the array to temporary memory  
    
    switch(iState)                          // Switches state of the reception of the data frames ->
    {
      case STATE_WAIT_STX:                  // Waits for the start character
      {
        if(iChar=='+')                      // If the start character was received ->
        {
          iState = STATE_WAIT_ETX;          // Sets state to "Wait for the stop character"  
        }
      }
      case STATE_WAIT_ETX:                  // Waits for the stop character
      {
        if(iChar == '\r' || iChar == '\n')  // If the stop character (carriage return or line feed) ->
        {
          aFrame{iFrameLength} = '\0';      // Writes a "0" to the current postion in the array for storing a data frame in order to terminate the string  
          iState = STATE_FINISHED;          // Sets state to "Complete data frame was received"
        }
        else                                // Otherwise (a character that is part of the data frame was received) ->   
        {
          if(iFrameLength < MAX_LENGTH)     // If the maximum length for a data frame is not exceeded ->
          {
            aFrame{iFrameLength++} = iChar; // Copies the current character into the array for storing a data frame and 
                                            // increases the number of received characters   
          }
          else                              // Otherwise (maximum length for the data frame exceeded) -> 
          { 
		    //Restarts the reception of the data frames
            iFrameLength = 0;               // Sets number of characters to 0
            iState = STATE_WAIT_STX;        // Sets state to "Wait for the start character" 
          }
        }
      }
    }
  }
  
  if(iState == STATE_FINISHED)              // If a complete data frame was received ->
  {
    ExecuteCmd(aFrame, iFrameLength);	      // Calls up the function to process the received data frame 
	
    // Restarts the reception of the data frames
    iFrameLength = 0;						            // Sets number of characters to 0
    iState = STATE_WAIT_STX;                // Sets state to "Wait for the start character"
  }
}

/**
 * Function to process the received data frame
 *
 * Creates a string that is composed as follows and issues it via the console and the RS232 interface.
 * "RS232Rx (<number of characters of data frame>) <data frame received via RS232> OK".
 * 
 * The received data frame is also evaluated as follows:
 *  "on":  LED is turned on (yellow)
 *  "off": LED is turned off
 * 
 * @param aData[]:u8  - Array that contains the received data frame
 * @param iLength:s32 - Number of characters of the received data frame
 */
ExecuteCmd(aData{}, iLength)
{
  new sString{256};                         // Temporary memory for the string to be issued via the console and the RS232 interface 
  new iStringLength;                        // Temporary memory for number of characters of the string to be issued
  
  // Creates the string to be issued. It is composed as follows: "RS232Rx (<number of characters of data frame>) <data frame received via RS232> OK". 
  iStringLength = sprintf(sString, sizeof(sString), "RS232Rx (%d) %s OK\r\n", iLength, aData)
  print(sString);										        // Issues the created string via the console	
  RS232_Write(PORT_RS232, sString, iStringLength);    // Issues the created string via the RS232 interface
  
  if(strcmp(aData, "on", 2) == 0)           // If the received data frame is "on" ->
  {
    Led_On(true, true);                     // Turns on LED (yellow)
  }
  else if(strcmp(aData, "off", 3) == 0)     // Otherwise, if the received data frame is "off" -> 
  {
    Led_Off(true, true);                    // Turns off LED
  }
}
