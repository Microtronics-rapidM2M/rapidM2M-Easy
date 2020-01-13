/*
 * Example using easyIoT interfaces
 */

/* NOTE: Native declarations for BLE functions removed from easyIoT.inc because functions
 * currently 'hidden' from customer because it is not yet known how to use BLE.
 */

/**
 * <summary>
 *   BLE interface (UART) configuration bits used with BLE_Init().
 * </summary>
 */
const
{
  BLE_1_STOPBIT   = 0b0000000000000001, // 1 stop bit
  BLE_2_STOPBIT   = 0b0000000000000010, // 2 stop bits
  BLE_PARITY_NONE = 0b0000000000000000, // no parity
  BLE_PARITY_ODD  = 0b0000000000000100, // odd parity
  BLE_PARITY_EVEN = 0b0000000000001000, // even parity
  BLE_7_DATABIT   = 0b0000000000000000, // 7 data bits
  BLE_8_DATABIT   = 0b0000000000010000, // 8 data bits
  BLE_FLOW_NONE   = 0b0000000000000000, // no flow control
  BLE_FLOW_RTSCTS = 0b0000000001000000, // RTS/CTS handshake
  BLE_FULL_DUPLEX = 0b0000000000000000,
  BLE_HALF_DUPLEX = 0b0000000100000000,
};

/**
 * <summary>
 *   Initialise BLE interface.
 * </summary>
 *
 * <param name="BLE">
 *   BLE interface number.
 * </param>
 * <param name="baudrate">
 *   Baudrate.
 * </param>
 * <param name="mode">
 *   Bit 0..1
 *     1 = 1 stop bit
 *     2 = 2 stop bit
 *   Bit 2..3
 *     0 = no parity
 *     1 = odd parity
 *     2 = even parity
 *   Bit 4..5
 *     0 = 7 data bits
 *     1 = 8 data bits
 *   Bit 6..7
 *     0 = no flow control
 *     1 = RTS/CTS handshake
 *   Bit 8
 * 	   0 = full duplex
 *     1 = half duplex
 * </param>
 * <param name="funcidx">
 *   Index of BLE receive function.
 *   Has to be of type: public func(const data{}, len);
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if interface is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native BLE_Init(BLE, baudrate, mode, funcidx);

/**
 * <summary>
 *   Close BLE interface.
 * </summary>
 *
 * <param name="BLE">
 *   BLE interface number.
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if interface is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native BLE_Close(BLE);

/**
 * <summary>
 *   Send data over BLE interface.
 * </summary>
 *
 * <param name="BLE">
 *   BLE interface number.
 * </param>
 * <param name="data">
 *   Array of data to send.
 * </param>
 * <param name="len">
 *   Number of bytes to send.
 * </param>
 *
 * <returns>
 *   Number of sent bytes if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if interface is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native BLE_Write(ble, const data{}, len);

/**
 * <summary>
 *   Provide rx and tx buffer for ble interface.
 *   Note: function must be called before opening Uart interface (<em>BLE_Init</em>) !
 * </summary>
 *
 * <param name="ble">
 *   Uart interface number.
 * </param>
 * <param name="rxbuf">
 *   used for buffering rxdata.
 * </param>
 * <param name="rxlen">
 *   size of provided rxbuf (number of bytes).
 * </param>
 * <param name="txbuf">
 *   used for buffering txdata.
 * </param>
 * <param name="txlen">
 *   size of provided txbuf (number of bytes).
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
native BLE_Setbuf(ble, rxbuf{}, rxlen, txbuf{}, txlen);


#include "rapidM2M EasyIoT\easyV3.inc"
#include "rapidM2M EasyIoT\easyIoT.inc"
#include string.inc
#include modFw_cfg.inc
#include modFw.inc
#include ble_app_scanner_cfg.inc
#include ble_app_scanner.inc

#define APP_CFG_USE_BLE_SCANNER_APP   (1)
#define APP_CFG_USE_LORA_AT_SLAVE     (1)

/* forward declarations of public functions */
forward public Timer1s();
forward public LidCover_OnChange(key);
forward public RS232_Rx(const data{}, len);
forward public RS485_Rx(const data{}, len);
forward public LoRa_Rx(const data{}, len);
forward public BLE_Rx(const data{}, len);

static hModFw_LoRa;
static hModFw_Ble;

#define APP_FLAGS_LORA_ON    (0x0001)
#define APP_FLAGS_BLE_ON     (0x0002)
static iAppFlags;

#define SIZE_PRINTFBUF  (4096)
static aPrintfBuf{SIZE_PRINTFBUF};

/* application entry point */
main()
{
  new iResult, iIdx;

  printf("**************\r\n");
  printf("easyIoT: Demo\r\n");
  printf("**************\r\n");

  /* init 1s Timer */
  iIdx = funcidx("Timer1s");
  iResult = rM2M_TimerAddExt(iIdx, true, 1000);
  printf("rM2M_TimerAddExt(%d) = %d\r\n", iIdx, iResult);

  /* Provide memory from script for printf() buffering */
  iResult = setbuf(aPrintfBuf, SIZE_PRINTFBUF);
  printf("setbuf(%d): %d\r\n", SIZE_PRINTFBUF, iResult);
  
  /* Initialize RS232 interface */
  iIdx = funcidx("RS232_Rx");
  iResult = RS232_Init(0, 115200, RS232_8_DATABIT | RS232_PARITY_NONE | RS232_1_STOPBIT, iIdx);
  printf("RS232_Init: %d\r\n", iResult);

  /* Initialize RS485 interface */
  iIdx = funcidx("RS485_Rx");
  iResult = RS485_Init(0, 9600, RS485_8_DATABIT | RS485_PARITY_NONE | RS485_1_STOPBIT, iIdx);
  printf("RS485_Init: %d\r\n", iResult);

  /* select 'triggered mode' for server synchronization */
  iResult = rM2M_TxSetMode(RM2M_TXMODE_TRIG);
  printf("rM2M_TxSetMode(%d): %d\r\n", RM2M_TXMODE_TRIG, iResult);

  /* LED handled by script */
  iResult = Led_Init(LED_MODE_SCRIPT);
  printf("Led_Init(): %d\r\n", iResult);

  /* Blink with GREEN Led indicating that script is active */
  Led_Blink(-1, 0);

  /* Init ModFw Abstraction Layer */
  ModFw_Init();
  
  /* Register LORA Firmware */
  iResult = ModFw_Register(MODFW_LORA, hModFw_LoRa);
  printf("hModFw_LoRa: %d\r\n", hModFw_LoRa);

  /* Register BLE Firmware */
  iResult = ModFw_Register(MODFW_BLE, hModFw_Ble);
  printf("hModFw_Ble: %d\r\n", hModFw_Ble);

#if (APP_CFG_USE_BLE_SCANNER_APP > 0)
  /* use BLE scanner application, 1s timer called from application */
  BLEApp_Init(BLEAPP_INIT_FLAGS_1S_TIMER_APPL);
#endif
}

public Timer1s()
{
#if (APP_CFG_USE_LORA_AT_SLAVE > 0)
  {
    static iLoRaCnt_ReadVer;

    iLoRaCnt_ReadVer++;
    if(iLoRaCnt_ReadVer >= 10)
    {
      LoRa_Write(0, "AT+VER=?\r", 9);
      iLoRaCnt_ReadVer = 0;
    }
  }
#endif  
#if (APP_CFG_USE_BLE_SCANNER_APP > 0)
  {
    static iBLECnt_Scan;

    BLEApp_Timer1s();
    iBLECnt_Scan++;
    if(iBLECnt_Scan >= 10)
    {
      BLEApp_Scan();
      iBLECnt_Scan = 0;
    }
  }
#endif
}

App_LoRaInit()
{
  new iResult, iIdx;

  if(!(iAppFlags & APP_FLAGS_LORA_ON))
  {
    /* Initialize LoRa interface */
    iIdx = funcidx("LoRa_Rx");
    iResult = LoRa_Init(0, 9600, LORA_8_DATABIT | LORA_PARITY_NONE | LORA_1_STOPBIT, iIdx);
    printf("LoRa_Init: %d\r\n", iResult);
    if(iResult >= OK)
      iAppFlags |= APP_FLAGS_LORA_ON;
  }
}

App_LoRaClose()
{
  new iResult;

  iResult = LoRa_Close(0);
  printf("LoRa_Close: %d\r\n", iResult);
}

App_BleInit()
{
  new iResult, iIdx;

  if(!(iAppFlags & APP_FLAGS_BLE_ON))
  {
    iIdx = funcidx("BLE_Rx");
    iResult = BLE_Init(0, 115200, BLE_8_DATABIT | BLE_PARITY_NONE | BLE_1_STOPBIT, iIdx);
    printf("BLE_Init: %d\r\n", iResult);
    if(iResult >= OK)
      iAppFlags |= APP_FLAGS_BLE_ON;
#if (APP_CFG_USE_BLE_SCANNER_APP > 0)
    BLEApp_PowerOn();
#endif
  }
}

App_BleClose()
{
  new iResult;

  iResult = BLE_Close(0);
  printf("BLE_Close: %d\r\n", iResult);
#if (APP_CFG_USE_BLE_SCANNER_APP > 0)
  BLEApp_PowerOff();
#endif
}

ModFw_InfoCallback(hModFw, szInfoInstalled{}, szInfoUpdate{})
{
  if(hModFw == hModFw_LoRa)
  {
    printf("ModFw_InfoCallback (LORA):\r\n\t\"%s\" (installed)\r\n\t\"%s\" (Update)\r\n", szInfoInstalled, szInfoUpdate);
    if((szInfoUpdate{0} != '\0') &&
       (strcmp(szInfoUpdate, MODFW_LORA, strlen(MODFW_LORA)) == 0) &&
       (strcmp(szInfoUpdate, szInfoInstalled) != 0))
    {
      /* verify CRC before installing update */
      ModFw_VerifyCrc(hModFw);
    }
    else
    {
      /* Initialize LoRa interface */
      App_LoRaInit();
    }
  }
  else if(hModFw == hModFw_Ble)
  {
    printf("ModFw_InfoCallback (BLE):\r\n\t\"%s\" (installed)\r\n\t\"%s\" (Update)\r\n", szInfoInstalled, szInfoUpdate);
    if((szInfoUpdate{0} != '\0') &&
       (strcmp(szInfoUpdate, MODFW_BLE, strlen(MODFW_BLE)) == 0) &&
       (strcmp(szInfoUpdate, szInfoInstalled) != 0))
    {
      /* verify CRC before installing update */
      ModFw_VerifyCrc(hModFw);
    }
    else
    {
      /* Initialize BLE interface */
      App_BleInit();
    }
  }
}

ModFw_VerifyCrcCallback(hModFw, iResult)
{
  if(hModFw == hModFw_LoRa)
  {
    printf("ModFw_VerifyCrcCallback (LORA): %s\r\n", (iResult >= OK) ? "OK" : "ERROR");
    if(iResult >= OK)
    {
      /* Install Update */
      iResult = rM2M_ModFwInstall(hModFw);
      printf("rM2M_ModFwInstall(%d): %d\r\n", hModFw, iResult);
    }
  }
  else if(hModFw == hModFw_Ble)
  {
    printf("ModFw_VerifyCrcCallback (BLE): %s\r\n", (iResult >= OK) ? "OK" : "ERROR");
    if(iResult >= OK)
    {
      /* Install Update */
      iResult = rM2M_ModFwInstall(hModFw_Ble);
      printf("rM2M_ModFwInstall(BLE): %d\r\n", iResult);
    }
  }
}

#if (APP_CFG_USE_BLE_SCANNER_APP > 0)
stock BleApp_Tx(const cmd{}, len)
{
  return(BLE_Write(0, cmd, len));
}

stock BleApp_DeviceScannedCallback(sScan[TBLEApp_Scan])
{
#if defined BLEAPP_DEBUG
  #pragma unused sScan
#else
  printf("BLE Scan: NAME=\"%s\" RSSI=%d ADDR=%02X:%02X:%02X:%02X:%02X:%02X\r\n",
    sScan.name, sScan.rssi,
    sScan.addr{0}, sScan.addr{1}, sScan.addr{2},
    sScan.addr{3}, sScan.addr{4}, sScan.addr{5});
#endif
}
#endif

Rx_Process(szLine{}, iLen)
{
  new iResult, iIdx;
  new bool:bError = true;

  if(szLine{0} == 'r')
  {
    /* RS485 */
    if(iLen == 2)
    {
      if(szLine{1} == '1')
      {
        /* Initialize RS485 interface */
        iIdx = funcidx("RS485_Rx");
        iResult = RS485_Init(0, 9600, RS485_8_DATABIT | RS485_PARITY_NONE | RS485_1_STOPBIT, iIdx);
        printf("RS485_Init: %d\r\n", iResult);
        bError = false;
      }
      else if(szLine{1} == '0')
      {
        iResult = RS485_Close(0);
        printf("RS485_Close: %d\r\n", iResult);
        bError = false;
      }
    }
  }
  else if(szLine{0} == 'b')
  {
    /* BLE */
    if(iLen == 2)
    {
      if(szLine{1} == '1')
      {
        /* Initialize BLE interface */
        App_BleInit();
        bError = false;
      }
      else if(szLine{1} == '0')
      {
        App_BleClose();
        bError = false;
      }
    }
  }
  else if(szLine{0} == 'l')
  {
    /* LORA */
    if(iLen == 2)
    {
      if(szLine{1} == '1')
      {
        /* Initialize LoRa interface */
        App_LoRaInit();
        bError = false;
      }
      else if(szLine{1} == '0')
      {
        App_LoRaClose();
        bError = false;
      }
    }
  }
  else if(szLine{0} == 'v')
  {
    /* RS232 3V3 */
    if(iLen == 2)
    {
      if(szLine{1} == '1')
      {
        iResult = RS232_3V3_On();
        printf("RS232_3V3_On: %d\r\n", iResult);
        bError = false;
      }
      else if(szLine{1} == '0')
      {
        iResult = RS232_3V3_Off();
        printf("RS232_3V3_Off: %d\r\n", iResult);
        bError = false;
      }
    }
  }
  else if(szLine{0} == 'c')
  {
    /* LidCover Funktionen */
    if(iLen == 2)
    {
      if(szLine{1} == '1')
      {
        if(exists("LidCover_Init"))
        {
          iResult = LidCover_Init(0, funcidx("LidCover_OnChange"));
          printf("LidCover_Init: %d\r\n", iResult);
        }
        else
        {
          printf("LidCover_Init does not exist!\r\n");
        }
        bError = false;
      }
      else if(szLine{1} == '0')
      {
        iResult = LidCover_Close();
        printf("LidCover_Close: %d\r\n", iResult);
        bError = false;
      }
    }
  }
  
  if(bError)
    printf("Rx_Process: Error parsing \"%s\"\r\n", szLine);
}

public LidCover_OnChange(key)
{
  printf("LidCover_OnChange: %d\r\n", key);
}

/* UART Receive from RS232 interface */
public RS232_Rx(const data{}, len)
{
  new i, ch;
  static szLineBuf{128};
  static iLineBuf;

  for(i=0 ; i<len ; i++)
  {
    ch = data{i};
    
    if(((ch == '\r') || (ch == '\n')) && (iLineBuf > 0))
    {
      szLineBuf{iLineBuf} = '\0';
      printf("RS232_Rx: \"%s\"\r\n", szLineBuf);
      Rx_Process(szLineBuf, iLineBuf);
      iLineBuf = 0;
    }
    else if((ch >= 0x20) && (ch <= 0x7F))
    {
      /* valid ASCII character -> store within line buffer */
      if(iLineBuf < 127)
        szLineBuf{iLineBuf++} = ch;
    }
  }
}

/* UART Receive from RS485 interface */
public RS485_Rx(const data{}, len)
{
  new i, ch;
  static szLineBuf{128};
  static iLineBuf;

  for(i=0 ; i<len ; i++)
  {
    ch = data{i};
    
    if(((ch == '\r') || (ch == '\n')) && (iLineBuf > 0))
    {
      szLineBuf{iLineBuf} = '\0';
      printf("RS485_Rx: \"%s\"\r\n", szLineBuf);
      Rx_Process(szLineBuf, iLineBuf);
      iLineBuf = 0;
    }
    else if((ch >= 0x20) && (ch <= 0x7F))
    {
      /* valid ASCII character -> store within line buffer */
      if(iLineBuf < 127)
        szLineBuf{iLineBuf++} = ch;
    }
  }
}

/* UART Receive from LoRa module */
public LoRa_Rx(const data{}, len)
{
  new i, ch;
  static szLineBuf{128};
  static iLineBuf;

  for(i=0 ; i<len ; i++)
  {
    ch = data{i};
    
    if(((ch == '\r') || (ch == '\n')) && (iLineBuf > 0))
    {
      szLineBuf{iLineBuf} = '\0';
      printf("LoRa_Rx: \"%s\"\r\n", szLineBuf);
      iLineBuf = 0;
    }
    else if((ch >= 0x20) && (ch <= 0x7F))
    {
      /* valid ASCII character -> store within line buffer */
      if(iLineBuf < 127)
        szLineBuf{iLineBuf++} = ch;
    }
  }
}

/* UART Receive from BLE module */
public BLE_Rx(const data{}, len)
{
#if (APP_CFG_USE_BLE_SCANNER_APP > 0)
  /* pass on to BLE SCANNER APP library */
  BLEApp_Rx(data, len);
#else
  new i, ch;
  static szLineBuf{128};
  static iLineBuf;
  
  for(i=0 ; i<len ; i++)
  {
    ch = data{i};
    
    if(((ch == '\r') || (ch == '\n')) && (iLineBuf > 0))
    {
      szLineBuf{iLineBuf} = '\0';
      printf("Ble_Rx: \"%s\"\r\n", szLineBuf);
      iLineBuf = 0;
    }
    else if((ch >= 0x20) && (ch <= 0x7F))
    {
      /* valid ASCII character -> store within line buffer */
      if(iLineBuf < 127)
        szLineBuf{iLineBuf++} = ch;
    }
  }
#endif
}
