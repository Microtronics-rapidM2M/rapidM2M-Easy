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
 * Simple "RS232" Example
 *
 * Issues the text "Data" every second via the RS232 interface and receives data via the RS232 interface.
 * Once data have been received via the RS232 interface, it is issued via the console.
 *
 * Only compatible with myDatalogEASY V3
 * 
 * @version 20190724
 */

/* Path for hardware-specific include file */
#include ".\rapidM2M Easy\easyV3.inc"

/* Forward declarations of public functions */
forward public Timer1s();                   // Called up 1x per sec. to issue the text "Data" via the RS232 interface
forward public RS232Rx(const data{}, len)   // Called up when characters are received via the RS232 interface

const
{
  PORT_RS232 = 0,                           // The first RS232 interface should be used
}

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
  printf("rM2M_TimerAdd(%d) = %d\r\n", iIdx, iResult);
  
  /* Initialisation of the RS232 interface that should be used 
     - Determining the function index that should be called up when characters are received
     - Transferring the index to the system and configure the interface                      
	   (115200 Baud, 8 data bits, no parity, 1 stop bit)                                     */ 
  iIdx = funcidx("RS232Rx");
  iResult = RS232_Init(PORT_RS232, 115200, RS232_8_DATABIT|RS232_PARITY_NONE|RS232_1_STOPBIT, iIdx);
}

/* 1s Timer used to issue the text "Data" via the RS232 interface every second */
public Timer1s()
{
  RS232_Write(PORT_RS232, "Data\r\n", 6);
}

/**
 * Callback function that is called up when characters are received via the RS232 interface
 *
 * @param data[]:u8 - Array that contains the received data 
 * @param len:s32   - Number of received bytes 
 */
public RS232Rx(const data{}, len)
{
  printf("RS232Rx (%d) %s\r\n", len, data);  // Issues the received characters via the console
}

