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
 * Receives the file "RS232.txt" from the server and issues the data via RS2320.
 * A new file will be registered at the start of the script. When the device connects to the 
 * server the server sends the file. The server does not send the entire file at once but 
 * split into 4kB blocks. If the device receives a 4kB block from the server a 256 byte block 
 * is issued via RS2320 every 100ms until the data of an entire 4kB block has been issued. After 
 * that the device confirms that the received data has been processed and the server is allowed 
 * to send the next 4kb block of the file.
 *  
 *  +-------+                    +--------+                     +--------+
 *  | RS232 | <-- (256 byte) <-- | Device | <-- (4096 byte) <-- | Server |
 *  +-------+                    +--------+                     +--------+
 * 
 * Only compatible with myDatalogEASY V3
 * 
 * Special hardware circuit necessary
 */

#include "rapidM2M Easy\easyv3.inc"

#pragma amxram  65536                                    // Sets the size of the RAM available to the script (max. 64kB)
#pragma dynamic  5120                                    // 5120 cells minimum stack/heap size

/* Forward declarations of public functions */
forward public Timer100ms();                             // Called up every 100ms to issue the received file in 256 byte blocks via the RS232 interface
forward public FileCmd(id, cmd, const data{}, len, ofs); // Called up when a file transfer command is received 
forward public Rs232Rx(data{}, len)                      // Called up when characters are received via the RS232 interface

const
{
  RS232_BUFFER_SIZE = 256,                               // Size of the buffer for issueing the received data via the RS232 interface
  PORT_RS232 = 0,                                        // The first RS232 interface should be used
}

static srRS232File[TFT_Info];                            // Contains the properties of the file entry
static aBufferRS232{4096};                               // Buffer containing a block of the file. It holds the data to be issued via the RS232 interface
static iBufferRS232Length;                               // Number of bytes stored in the Buffer for a block of the file
static iBufferRS232Pos;                                  // Number of bytes already issued via the RS232 interface

static iCurrentFileId = -1;                              // Unique identification of the last received file

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

  // Initializes the file entry (set filename to "RS232.txt", empty file)
  srRS232File.name    = "RS232.txt";
  srRS232File.size     = 0;
  srRS232File.stamp    = 0;
  srRS232File.stamp256 = 0;  
  srRS232File.crc      = 0x00;
  srRS232File.flags    = FT_FLAG_WRITE;

  /* Registers the file so that it can be accessed by the server
     - Determining the function index that should be called up when a file transfer command is received
     - Transferring the index to the system, setting the filename and setting the Unique identification 
	   with which the file is then referenced                                                           
     - Issues the return value of the "FT_Register()" function via the console                        */
  iIdx = funcidx("FileCmd");
  iResult = FT_Register(srRS232File.name, 0, iIdx);
  printf("FT_Register(%d) = %d\r\n", 0, iResult);
    
  /* Initialisation of a 100ms timer used to issue the received file in 256 byte blocks via the RS232 interface
     - Determining the function index that should be executed every 100ms
     - Transferring the index to the system and informing it that the timer should be restarted 
	   following expiry of the interval
	 - Issues the index and return value of the init function via the console  */  
  iIdx = funcidx("Timer100ms");
  iResult = rM2M_TimerAddExt(iIdx, true, 100);
  printf("rM2M_TimerAddExt(%d) = %d\r\n", iIdx, iResult);

  /* Initialisation of the RS232 interface that should be used 
     - Determining the function index that should be called up when characters are received
     - Transferring the index to the system and configuring the interface                      
	   (115200 Baud, 8 data bits, no parity, 1 stop bit)                                     
     - In case of a problem the index and return value of the init function are issued by the console  */
  iIdx = funcidx("Rs232Rx");
  iResult = RS232_Init(PORT_RS232, 115200, RS232_8_DATABIT|RS232_PARITY_NONE|RS232_1_STOPBIT, iIdx);
  if(iResult < OK)
    printf("RS232_Init(%d) = %d\r\n", iIdx, iResult);
  
  rM2M_TxSetMode(RM2M_TXMODE_WAKEUP);                    // Sets the connection type to "Wakeup" mode
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
  // Issues received unique identification, file transfer command (description string and value), length and offset  
  printf("FileCmd(%d, %s (%d), data{}, %d, %d)\r\n", id, cszFileCmd[cmd], cmd, len, ofs);

  switch(cmd)                                            // Switches the received file transfer command -> 
  {
    case FT_CMD_LIST:                                    // The server requests the properties of a file
    {
      FT_SetPropsExt(id, srRS232File);                   // Sets the properties of the file 
    }
    case FT_CMD_STORE:                                   // The server requests a file to be written (i.e. got file from server)
    {
      new iServerStamp;                                  // Timestamp of the file received from the server
      new iServerSize;                                   // Size of the received file in bytes
      new iServerCrc;                                    // Ethernet CRC32 of the received file  
      new iServerFlags;                                  // File flags
      new iServerName{256};                              // Name of the received file
      
      // Unpack the received file properties into the temporary variables	  
      rM2M_Pack(data, 0,  iServerStamp,  RM2M_PACK_GET|RM2M_PACK_U32);
      rM2M_Pack(data, 8,  iServerSize,   RM2M_PACK_GET|RM2M_PACK_U32);
      rM2M_Pack(data, 12, iServerCrc,    RM2M_PACK_GET|RM2M_PACK_U32);
      rM2M_Pack(data, 16, iServerFlags,  RM2M_PACK_GET|RM2M_PACK_U16);
      rM2M_GetPackedB(data, 18, iServerName, 256);
    
      FT_Accept(id);                                     // Accepts the file
      iCurrentFileId = id;                               // Stores current FileId (unique identification) for further usage (e.g. FT_Written() after processed current block)
      
      // Updates timestamp of local file structure
      // Size and CRC will be updated while receiving data
      srRS232File.stamp = iServerStamp;
      
      // Issues the timestamp, file size, file flags, CRC and filename of the received file via the console
      printf("%08X %6u %04X %08X %s\r\n", iServerStamp, iServerSize, iServerFlags, iServerCrc, iServerName);
    }
    case FT_CMD_WRITE:                                   // The server provides a block to be written in a file (i.e. write data from server to device) (in 4096 blocks)
    {
      if(ofs == 0)                                       // If the received byte offset within the file is 0 (i.e. got new file)
      {
        // Resets size and crc of the named array containing the properties of the file entry
        srRS232File.size  = 0;
        srRS232File.crc   = 0;
      }
      
      // If the number of bytes received from the server is too high for storing them in the buffer for a block of the file 
      if(len > 4096)
      {
        printf("Error Size\r\n");
        FT_Error(id);                                    // Display a file handling error and terminates any file command
      }
      else
      {
        rM2M_SetPackedB(aBufferRS232, 0, data, len);     // Copies the the data received from the server into the buffer for a block of the file  
        
        // Sets number of bytes stored in the Buffer for a block of the file to the number of bytes received from the server
		    iBufferRS232Length = len;                      
		    // Sets number of bytes already issued via the RS232 interface to 0 to start issueing data via the RS232 interface
        iBufferRS232Pos = 0; 
      }
    }
    case FT_CMD_UNLOCK:                                  // File transfer session terminated. The server releases the block again.
    {
      // File writing finished
      // Reset current FileID (unique identification) , file will not be processed anymore
      iCurrentFileId = -1;
    }
  }
}

// 100ms Timer, used  to issue the received file in 256 byte blocks via the RS232 interface
public Timer100ms()
{
  new iResult;                                           // Temporary memory for the return value of a function
  
  if(iBufferRS232Length)                                 // If data is availabe (in the buffer for a block of the file) for issueing via the RS232 interface
  {
    new iLength;                                         // Temporary memory for the number of bytes which should be issued via the RS232 interface 
    new aData{RS232_BUFFER_SIZE};                        // Buffer for issueing the received data via the RS232 interface
    
    iLength = iBufferRS232Length - iBufferRS232Pos;      // Calculates the number of bytes in the buffer for a block of the file which are not already issued via the RS232 interface  
    
    if(iLength > RS232_BUFFER_SIZE)                      // If the Buffer for issuing the data via the RS232 interface is too small for the remaining bytes
      iLength = RS232_BUFFER_SIZE;                       // limit the number of bytes to be issued to the Size of the RS232 send buffer  

    // Copies the data to be issued via the RS232 interface from the buffer for a block of the file to the Buffer for issuing the data via the RS232 interface 
	  rM2M_GetPackedB(aBufferRS232, iBufferRS232Pos, aData, iLength);
    printf("# %d/%d\r\n", iBufferRS232Pos, iBufferRS232Length);
    
    iResult = RS232_Write(PORT_RS232, aData, iLength);   // Issues the data via the RS232 interface 
    if (iResult < OK)                                    // In case of a problem the return value of the write function is issued via the console
      printf("RS232_Write()=%d\r\n", iResult);
      
    iBufferRS232Pos += iLength;                          // Add the number of currently send bytes to the counter for the bytes already issued via the RS232 interface

    // If the Number of bytes stored in the buffer for a block of the file matches the number of bytes already issued via the RS232 interface (i.e. writing to RS232 finished)
    if(iBufferRS232Pos == iBufferRS232Length)
    {
      // Update local file structure
      srRS232File.size += iBufferRS232Length;            // Updates the file size in properties of the file entry
      srRS232File.crc = CRC32(aBufferRS232, iBufferRS232Length, srRS232File.crc); // Updates the CRC in properties of the file entry
      
      // Confirms that the data received from the server has been written (i.e. ready to receive next block of the file from the server)
      FT_Written(iCurrentFileId, iBufferRS232Length);
	    // Resets the number of bytes stored in the Buffer for a block of the file(i. clears Buffer and wait for new data)
      iBufferRS232Length = 0; 
      
	  // Issues unique identification, size and crc of the files via the console
      printf("# written %d %d %08X\r\n", iCurrentFileId, srRS232File.size, srRS232File.crc);
    }
  }
}

/**
 * Callback function that is called up when characters are received via the RS232 interface
 *
 * @param data[]:u8 - Array that contains the received data 
 * @param len:s32   - Number of received bytes 
 */
public Rs232Rx(data{}, len)
{
  printf("Rs232Rx(\"%s\", %d)\r\n", data, len);          // Issues the received characters via the console
}
