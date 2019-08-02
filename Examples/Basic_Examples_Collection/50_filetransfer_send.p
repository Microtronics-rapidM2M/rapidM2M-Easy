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
 * Simple "File transfer" Example 
 *
 * Sends data received via RS2320 to the server
 * A new file will be registered with the first data received from RS2320. Filesize max. 4096 bytes
 * When the device connects to the server the file will be sent to the server. The file will be 
 * unregistered after being successfully sent to the server and a new file will be registered with 
 * the first data received from RS2320 after that.
 *  
 * Only compatible with myDatalogEASY V3
 * 
 * Special hardware circuit necessary
 */
 
#include "rapidM2M Easy\easyv3.inc"
#include "string.inc"
 
#pragma amxram  65536                                    // Sets the size of the RAM available to the script (max. 64kB)
#pragma dynamic  5120                                    // 5120 cells minimum stack/heap size

/* Forward declarations of public functions */
forward public FileCmd(id, cmd, const data{}, len, ofs); // Called up when a file transfer command is received 
forward public Rs232Rx(data{}, len)                      // Called up when characters are received via the RS232 interface

const
{
  PORT_RS232 = 0,                                        // The first RS232 interface should be used
}

static srRS232File[TFT_Info];                            // Contains the properties of the file entry
static aBufferFile{4096};                                // Buffer containing the file

static iPrevFileCmd;                                     // Previously received file transfer command  

static cszFileCmd[]{} = [                                // Array containing a description string for each possible file transfer command 
  "FT_CMD_NONE",
  "FT_CMD_UNLOCK",
  "FT_CMD_LIST",
  "FT_CMD_READ",
  "FT_CMD_STORE",
  "FT_CMD_WRITE",
  "FT_CMD_DELETE"
];


/* Application entry point */
main()
{
  /* Temporary memory for the index of a public function and the return value of a function  */
  new iIdx, iResult;
    

  // Initialises the file entry (empty entry)
  srRS232File.name     = "";
  srRS232File.size     = 0;
  srRS232File.stamp    = 0;
  srRS232File.stamp256 = 0;
  srRS232File.crc      = 0x00;
  srRS232File.flags    = FT_FLAG_READ;
  
  /* Initialisation of the RS232 interface that should be used 
     - Determining the function index that should be called up when characters are received
     - Transferring the index to the system and configuring the interface                      
	   (115200 Baud, 8 data bits, no parity, 1 stop bit)                                     
     - In case of a problem the index and return value of the init function are issued by the console. */
  iIdx = funcidx("Rs232Rx");
  iResult = RS232_Init(PORT_RS232, 115200, RS232_8_DATABIT|RS232_PARITY_NONE|RS232_1_STOPBIT, iIdx);
  if(iResult < OK)
    printf("RS232_Init(%d) = %d\r\n", iIdx, iResult);

  rM2M_TxSetMode(RM2M_TXMODE_WAKEUP);                   // Sets the connection type to "Wakeup" mode   
}

/**
 * Callback function that is called up when a file transfer command is received 
 *
 * @param id:s32    - Unique identification with which the file is referenced (specified during registration) 
 * @param cmd:s32   - File transfer command that was received from the system 
 * @param data[]:u8 - Only relevant for following file transfer commands:
 *                     FT_CMD_STORE: Array that contains the properties of the file that should be newly created. Structure:
 *                        Offset    Bytes   Explanation
                          0         4       Time stamp of the file
                          8         4       File size in bytes
                         12         4       Ethernet CRC32 of the file
                         16         2       File flags
                         18       256       File name
 *                    FT_CMD_WRITE: Array that contains the data received from the server
 * @param len:s32   - Only relevant for following file transfer commands:
 *                     FT_CMD_READ: Number of bytes requested by the server
 *                     FT_CMD_STORE: Size of the file property block received from the server
 *                     FT_CMD_WRITE: Number of bytes received from the server
 * @param ofs:s32   - Only relevant for following file transfer commands:
 *                     FT_CMD_READ: Byte offset within the file of the data block to be transferred to the server
 *                     FT_CMD_WRITE: Byte offset within the file of the data block received from the server
 */
public FileCmd(id, cmd, const data{}, len, ofs)
{
  new iResult;                                           // Temporary memory for the return value of a function
  
  // Issues received unique identification, file transfer command (description string and value), length and offset  
  printf("FileCmd(%d, %s (%d), data{}, %d, %d)\r\n", id, cszFileCmd[cmd], cmd, len, ofs);

  switch(cmd)                                            // Switches the received file transfer command -> 
  {
    case FT_CMD_LIST:                                    // The server requests the properties of a file
    {
      // Issues the timestamp, file size, CRC and file flags via the console
      printf("Props %08X %d %08X %04X\r\n", srRS232File.stamp, srRS232File.size, srRS232File.crc, srRS232File.flags);
      
      FT_SetPropsExt(id, srRS232File);                   // Sets the properties of the file 
    }
    case FT_CMD_READ:                                    // The server requests part of a file.
    {
      printf("FT_Read %d\r\n", len);                     // Issues the number of bytes requested by the server via the console
      
      // Hands over the data to the system to transfer it to the server. The return value of FT_Read is issued via the console in case of a problem.
      iResult = FT_Read(id, aBufferFile, len);
      if(iResult < OK)
        printf("FT_Read()=%d\r\n", iResult);
    }
    case FT_CMD_UNLOCK:                                  // File transfer session terminated. The server releases the block again. 
    {
      if(iPrevFileCmd == FT_CMD_READ)                    // If the last file transfer command was the request read command ->
      {
        // Resets file when finished reading
        srRS232File.size = 0;
        srRS232File.stamp = 0;
        srRS232File.crc = 0;
        FT_Unregister(0);
      }
    }
    default:                                             // Received file transfer command is not handled by this script 
    {
      FT_Error(id);                                      // Displays a file handling error and terminates any file command
    }
  }
  iPrevFileCmd = cmd;                                    // Copies current file transfer command to the variable for the previously received file transfer command 
}

/**
 * Callback function that is called up when characters are received via the RS232 interface
 *
 * @param data[]:u8 - Array that contains the received data 
 * @param len:s32   - Number of received bytes 
 */
public Rs232Rx(data{}, len)
{
  new iResult;                                           // Temporary memory for the return value of a function

  if(srRS232File.size == 0)                               // If the file is still empty (file not yet registered -> new file with timestamp)
  {
    // Temporary memory for the current time/date
	  new year, month, day;
    new hour, minute, second;
    
    rM2M_GetDate(year, month, day);                      // Determines the current date  
    rM2M_GetTime(hour, minute, second);                  // Determines the current time  

    /* Sets the filename to "RS2321_<yyyy><mm><dd>_<hh><mm><ss>.txt", 
	   registers the file so that it can be accessed by the server
	   and issues the return value of the "FT_Register()" function  via the console                    */        
    sprintf(srRS232File.name, sizeof(srRS232File.name), "RS2321_%04d%02d%02d_%02d%02d%02d.txt",
      year, month, day, hour, minute, second);
    iResult = FT_Register(srRS232File.name, 0, funcidx("FileCmd"));
    printf("FT_Register(%d) = %d\r\n", 0, iResult);
    
	// Resets file size, timestamp and CRC. The new values are set in the next if
    srRS232File.size = 0;
    srRS232File.stamp = 0;
    srRS232File.crc = 0;
    
	// Sets the properties of the file and issues the return value of the function via the console
    iResult = FT_SetPropsExt(0, srRS232File);
    printf("FT_SetPropsExt(%d) = %d\r\n", 0, iResult);
  }

  // If the space in the buffer for the file is still sufficient to store the characters received via the RS232
  if((srRS232File.size + len) <= 4096)                     
  {
    rM2M_SetPackedB(aBufferFile, srRS232File.size, data, len);//Copies the received data into the buffer for the file 
    srRS232File.size += len;                             // Updates the file size in properties of the file entry
    
    
    srRS232File.crc = CRC32(data, len, srRS232File.crc); // Updates the CRC in properties of the file entry
    srRS232File.stamp = rM2M_GetTime();                  // Updates the timestamp in properties of the file entry

    // Issues the received data, the number of received bytes, the current file size and the current CRC via the console
    printf("Rs232Rx(\"%s\", %d) %d %08X\r\n", data, len, srRS232File.size, srRS232File.crc);
  }
}
