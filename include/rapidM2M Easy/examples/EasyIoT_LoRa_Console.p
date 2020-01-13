/*
 * Console Example interfacing LoRa module on easyIoT
 *
 * LoRa module uses Semtech demo application 'AT_Slave' for STM32L072 (available via ST homepage)
 * With this example LoRa module acts like a modem that is controlled through AT command interface
 * over UART by an external host.
 *
 * LoRa module is controllable via external host (e.g. PC with Teraterm) connected
 * through RS232 or RS485 interface (selectable) with EasyIoT. Script Logic only tunnels
 * data to/from LoRa module from/to RS232/RS485 interface.
 * Installed Firmware Version on LoRa module is read automatically after startup.
 * LoRa Module Firmware Update is handled after startup, if a new update is
 * available.
 * 
 *  AT Command strings. Commands start with AT
 *  #define AT_RESET      "Z"
 *  #define AT_DEUI       "+DEUI"
 *  #define AT_DADDR      "+DADDR"
 *  #define AT_APPKEY     "+APPKEY"
 *  #define AT_NWKSKEY    "+NWKSKEY"
 *  #define AT_APPSKEY    "+APPSKEY"
 *  #define AT_JOINEUI     "+APPEUI" // to match with V1.0.x specification- For V1.1.x "+APPEUI" will be replaced by "+JOINEUI"
 *  #define AT_ADR        "+ADR"
 *  #define AT_TXP        "+TXP"
 *  #define AT_DR         "+DR"
 *  #define AT_DCS        "+DCS"
 *  #define AT_PNM        "+PNM"
 *  #define AT_RX2FQ      "+RX2FQ"
 *  #define AT_RX2DR      "+RX2DR"
 *  #define AT_RX1DL      "+RX1DL"
 *  #define AT_RX2DL      "+RX2DL"
 *  #define AT_JN1DL      "+JN1DL"
 *  #define AT_JN2DL      "+JN2DL"
 *  #define AT_NJM        "+NJM"
 *  #define AT_NWKID      "+NWKID"
 *  #define AT_FCU        "+FCU"
 *  #define AT_FCD        "+FCD"
 *  #define AT_CLASS      "+CLASS"
 *  #define AT_JOIN       "+JOIN"
 *  #define AT_NJS        "+NJS"
 *  #define AT_SENDB      "+SENDB"
 *  #define AT_SEND       "+SEND"
 *  #define AT_RECVB      "+RECVB"
 *  #define AT_RECV       "+RECV"
 *  #define AT_VER        "+VER"
 *  #define AT_CFM        "+CFM"
 *  #define AT_CFS        "+CFS"
 *  #define AT_SNR        "+SNR"
 *  #define AT_RSSI       "+RSSI"
 *  #define AT_BAT        "+BAT"
 *  #define AT_TRSSI      "+TRSSI"
 *  #define AT_TTONE      "+TTONE"
 *  #define AT_TTLRA      "+TTLRA"
 *  #define AT_TRLRA      "+TRLRA"
 *  #define AT_TCONF      "+TCONF"
 *  #define AT_TOFF       "+TOFF"
 *  #define AT_CERTIF     "+CERTIF"
 *  #define AT_PGSLOT     "+PGSLOT" 
 *  #define AT_BFREQ      "+BFREQ"
 *  #define AT_BTIME      "+BTIME"
 *  #define AT_BGW        "+BGW" 
 *  #define AT_LTIME      "+LTIME"  
 * 
 */
#include "rapidM2M EasyIoT\easyV3.inc"
#include "rapidM2M EasyIoT\easyIoT.inc"
#include string.inc

/* forward declarations of public functions */
forward public LoRa_ReadFwTag(iResult);
forward public Timer1s();
forward public LoRa_CmdTimeout();
forward public RS232_Rx(const data{}, len);
forward public RS485_Rx(const data{}, len);
forward public LoRa_Rx(const data{}, len);

#define LORA_CONSOLE_RS232     (0)   /** 1=Enable Console via RS232 interface */
#define LORA_CONSOLE_RS485     (1)   /** 1=Enable Console via RS485 interface */
#define LORA_LINE_MAXLEN     (256)   /** Line buffer size for receiving ASCII data */
#define LORA_SIZE_RXBUF      (512)   /** Size of UART Rx buffer for interfacing LoRa module */
#define LORA_SIZE_TXBUF      (512)   /** Size of UART Tx buffer for interfacing LoRa module */
#define LORA_SIZE_PRINTFBUF (2048)   /** Size of Printf buffer */
#define LORA_EUI_STRLEN       (23)
#define LORA_APPKEY_STRLEN    (47)
#define LORA_CMD_MAXLEN       (64)
#define LORA_VERSION_MAXLEN   (16)
#define LORA_FWID_MAXLEN      (64)

/* Supported Commands */
const
{
  LORA_CMD_VERSION = 0,
  LORA_N_CMD
}

/**< AT Command Response Types */
const
{
  AT_RSP_STRING = 0,
  AT_RSP_OK,
  AT_RSP_ERROR,
}

#define TLoRaCmd[.szCmd{LORA_CMD_MAXLEN}]
static asLoRaCmd[LORA_N_CMD][TLoRaCmd] =
[
  [ "AT+VER" ]  // LORA_CMD_VERSION
]

#define TLoRa_Vars[.szLineBuf{LORA_LINE_MAXLEN+1}, .iLineBuf,
                   .szVersion{LORA_VERSION_MAXLEN+1}, .szEUI{LORA_EUI_STRLEN+1}, .szAppKey{LORA_APPKEY_STRLEN+1},
                   .iCmdActive, .iCmdTimerActive, .iCmdTimeout ]
static sLoRa_Vars[TLoRa_Vars];
static aLoRa_RxBuf{LORA_SIZE_RXBUF};
static aLoRa_TxBuf{LORA_SIZE_TXBUF};
#if (LORA_CONSOLE_RS232 > 0)
static aLoRa_RxBufRS232{LORA_SIZE_RXBUF};
static aLoRa_TxBufRS232{LORA_SIZE_TXBUF};
#endif
#if (LORA_CONSOLE_RS485 > 0)
static aLoRa_RxBufRS485{LORA_SIZE_RXBUF};
static aLoRa_TxBufRS485{LORA_SIZE_TXBUF};
#endif
static aLoRa_PrintfBuf{LORA_SIZE_PRINTFBUF};

#define TLoRa_FwVars[.handle,
                     .szIdInstalled{LORA_FWID_MAXLEN+1}, .szIdUpdate{LORA_FWID_MAXLEN+1},
                     .aData{256}, .iTag, .iOfs, .iLen, .iCrcRead, .iCrcCalc,
                     .toUpdate]
static sLoRa_FwVars[TLoRa_FwVars];

/* application entry point */
main()
{
  new iIdx, iResult, handle;

  printf("**************************\r\n");
  printf("easyIoT: LoRa Console Demo\r\n");
  printf("**************************\r\n");

  /* init 1s Timer */
  iIdx = funcidx("Timer1s");
  iResult = rM2M_TimerAddExt(iIdx, true, 1000);
  printf("rM2M_TimerAddExt(%d) = %d\r\n", iIdx, iResult);

  /* Provide memory from script for printf() buffering */
  iResult = setbuf(aLoRa_PrintfBuf, LORA_SIZE_PRINTFBUF);
  printf("setbuf(%d): %d\r\n", LORA_SIZE_PRINTFBUF, iResult);
  
#if (LORA_CONSOLE_RS232 > 0)
  /* Provide memory from script for RS232 UART Rx/Tx buffering */
  iResult = RS232_Setbuf(0, aLoRa_RxBufRS232, LORA_SIZE_RXBUF, aLoRa_TxBufRS232, LORA_SIZE_TXBUF);
  printf("RS232_Setbuf: %d\r\n", iResult);

  /* Initialize RS232 interface */
  iIdx = funcidx("RS232_Rx");
  iResult = RS232_Init(0, 9600, RS232_8_DATABIT | RS232_PARITY_NONE | RS232_1_STOPBIT, iIdx);
  printf("RS232_Init: %d\r\n", iResult);
#endif
  
#if (LORA_CONSOLE_RS485 > 0)
  /* Provide memory from script for RS485 UART Rx/Tx buffering */
  iResult = RS485_Setbuf(0, aLoRa_RxBufRS485, LORA_SIZE_RXBUF, aLoRa_TxBufRS485, LORA_SIZE_TXBUF);
  printf("RS485_Setbuf: %d\r\n", iResult);

  /* Initialize RS485 interface */
  iIdx = funcidx("RS485_Rx");
  iResult = RS485_Init(0, 9600, RS485_8_DATABIT | RS485_PARITY_NONE | RS485_1_STOPBIT, iIdx);
  printf("RS485_Init: %d\r\n", iResult);
#endif  
  
  /* select 'triggered mode' for server synchronization */
  iResult = rM2M_TxSetMode(RM2M_TXMODE_TRIG);
  printf("rM2M_TxSetMode(%d): %d\r\n", RM2M_TXMODE_TRIG, iResult);

  /* LED handled by script */
  iResult = Led_Init(LED_MODE_SCRIPT);
  printf("Led_Init(): %d\r\n", iResult);

  /* Blink with GREEN Led indicating that script is active */
  Led_Blink(-1, 0);

  /* Search handle for LoRa Module Firmware handling */
  handle = 0;
  sLoRa_FwVars.handle = -1;
  iResult = OK;
  while((iResult >= OK) && (sLoRa_FwVars.handle < 0))
  {
    /* Read FW Id string (installed firmware) */
    iResult = rM2M_ModFwGetId(handle, sLoRa_FwVars.szIdInstalled);
    if((iResult >= OK) && (strcmp(sLoRa_FwVars.szIdInstalled, MODFW_LORA, strlen(MODFW_LORA)) == 0))
    {
      /* store Module Firmware Handle */
      sLoRa_FwVars.handle = handle;
      printf("rM2M_ModFwGetId: %d, \"%s\" (handle=%d)\r\n", iResult, sLoRa_FwVars.szIdInstalled, sLoRa_FwVars.handle);
      /* Read INFO tag (FW Id string) */
      sLoRa_FwVars.iTag = RM2M_MODFW_TAG_INFO;
      iResult = rM2M_ModFwReadTag(sLoRa_FwVars.handle, RM2M_MODFW_TAG_INFO, funcidx("LoRa_ReadFwTag"), sLoRa_FwVars.szIdUpdate);
      if(iResult < OK)
      {
        printf("rM2M_ModFwReadTag (INFO): %d\r\n", iResult);
        /* Enable/Power-On LoRa Module immediately */
        LoRa_Enable();
      }
    }
    else
    {
      /* proceed search */
      handle++;
    }
  }
}

public LoRa_ReadFwTag(iResult)
{
  new bool:bLoRa_Enable = false;

  if(sLoRa_FwVars.iTag == RM2M_MODFW_TAG_INFO)
  {
    printf("LoRa_ReadFwTag (INFO): %d, \"%s\"\r\n", iResult, sLoRa_FwVars.szIdUpdate);
    sLoRa_FwVars.iTag = RM2M_MODFW_TAG_BIN;
    sLoRa_FwVars.iLen = 0;
    iResult = rM2M_ModFwReadTag(sLoRa_FwVars.handle, RM2M_MODFW_TAG_BIN, funcidx("LoRa_ReadFwTag"), {0}, 0);
    if(iResult < OK)
      printf("LoRa_ReadFwTag (BIN): %d\r\n", iResult);
  }
  else if(sLoRa_FwVars.iTag == RM2M_MODFW_TAG_BIN)
  {
    if(sLoRa_FwVars.iLen == 0)
    {
      printf("LoRa_ReadFwTag (BIN): %d\r\n", iResult);
      if(iResult > 0)
      {
        sLoRa_FwVars.iLen = iResult;
        sLoRa_FwVars.iOfs = 0;
        iResult = rM2M_ModFwReadTag(sLoRa_FwVars.handle, RM2M_MODFW_TAG_BIN, funcidx("LoRa_ReadFwTag"), sLoRa_FwVars.aData, sizeof(sLoRa_FwVars.aData), sLoRa_FwVars.iOfs);
        if(iResult < OK)
          printf("LoRa_ReadFwTag (BIN): %d\r\n", iResult);
      }
    }
    else
    {
      if(iResult >= OK)
      {
        new aFwDataVerify{256};

        sLoRa_FwVars.iOfs += iResult;
        /* Update CRC */
        rM2M_GetPackedB(sLoRa_FwVars.aData, 0, aFwDataVerify, iResult);
        sLoRa_FwVars.iCrcCalc = CRC32(aFwDataVerify, iResult, sLoRa_FwVars.iCrcCalc);
        if(sLoRa_FwVars.iOfs < sLoRa_FwVars.iLen)
        {
          iResult = rM2M_ModFwReadTag(sLoRa_FwVars.handle, RM2M_MODFW_TAG_BIN, funcidx("LoRa_ReadFwTag"), sLoRa_FwVars.aData, sizeof(sLoRa_FwVars.aData), sLoRa_FwVars.iOfs);
          if(iResult < OK)
            printf("LoRa_ReadFwTag (BIN): %d\r\n", iResult);
        }
        else
        {
          printf("LoRa_ReadFwTag (CRC Calc): %08xh\r\n", sLoRa_FwVars.iCrcCalc);
          /* read CRC tag next */
          sLoRa_FwVars.iTag = RM2M_MODFW_TAG_CRC;
          iResult = rM2M_ModFwReadTag(sLoRa_FwVars.handle, RM2M_MODFW_TAG_CRC, funcidx("LoRa_ReadFwTag"), sLoRa_FwVars.aData);
          if(iResult < OK)
            printf("rM2M_ModFwReadTag (CRC): %d\r\n", iResult);
        }
      }
      else
      {
        printf("LoRa_ReadFwTag (BIN): %d, ofs=%d\r\n", iResult, sLoRa_FwVars.iOfs);
      }
    }
  }
  else if(sLoRa_FwVars.iTag == RM2M_MODFW_TAG_CRC)
  {
    rM2M_Pack(sLoRa_FwVars.aData, 0, sLoRa_FwVars.iCrcRead, RM2M_PACK_GET | RM2M_PACK_U32);
    printf("LoRa_ReadFwTag (CRC Read): %08xh\r\n", sLoRa_FwVars.iCrcRead);

    if(sLoRa_FwVars.iCrcRead == sLoRa_FwVars.iCrcCalc)
    {
      if(strcmp(sLoRa_FwVars.szIdUpdate, sLoRa_FwVars.szIdInstalled) != 0)
      {
        sLoRa_FwVars.toUpdate = 5;
        printf("LoRa Firmware: Install in %d seconds!\r\n", sLoRa_FwVars.toUpdate);
      }
      else
      {
        /* Firmware update is not required -> activate LoRa module */
        bLoRa_Enable = true;
      }
    }
  }

  if(iResult < OK)
    bLoRa_Enable = true;
  
  if(bLoRa_Enable)
  {
    /* Enable/Power-On LoRa Module */
    LoRa_Enable();
  }
}

public Timer1s()
{
  new iResult;

  if(sLoRa_FwVars.toUpdate)
  {
    sLoRa_FwVars.toUpdate--;
    if(sLoRa_FwVars.toUpdate == 0)
    {
      iResult = rM2M_ModFwInstall(sLoRa_FwVars.handle);
      printf("rM2M_ModFwInstall(%d): %d\r\n", sLoRa_FwVars.handle, iResult);
    }
    else
    {
      printf("LoRa Firmware: Install in %d seconds!\r\n", sLoRa_FwVars.toUpdate);
    }
  }

  /* send version query command until version was received */
  if((sLoRa_Vars.iCmdActive == -1) && (sLoRa_Vars.szVersion{0} == '\0'))
    LoRa_SendQueryCmd(LORA_CMD_VERSION);
}  

LoRa_Enable()
{
  new iIdx, iResult;

  /* Provide memory from script for LoRa UART Rx/Tx buffering */
  iResult = LoRa_Setbuf(0, aLoRa_RxBuf, LORA_SIZE_RXBUF, aLoRa_TxBuf, LORA_SIZE_TXBUF);
  printf("LoRa_Setbuf: %d\r\n", iResult);

  /* Power-Up LoRa chip and initialize UART interface
   * Semtech 'AT Slave' example uses 9600 8N1 configuration */
  iIdx = funcidx("LoRa_Rx");
  iResult = LoRa_Init(0, 9600, RS232_8_DATABIT | RS232_PARITY_NONE | RS232_1_STOPBIT, iIdx);
  printf("LoRa_Init: %d\r\n", iResult);
  sLoRa_Vars.iCmdActive = -1;

  /* read current LoRa Firmware Version */
  LoRa_SendQueryCmd(LORA_CMD_VERSION);
}

LoRa_CheckATResult(szLine{}, len)
{
#pragma unused len
  new result = AT_RSP_STRING;

  if(strcmp(szLine, "OK") == 0)
    result = AT_RSP_OK;
  else if(strcmp(szLine, "AT_ERROR") == 0)
    result = AT_RSP_ERROR;
  return(result);
}

/* Send Command to LoRa module */
LoRa_SendQueryCmd(iCmd, timeout=100)
{
  new lenCmd;
  new iResult;
  new szCmd{LORA_CMD_MAXLEN+1};

  if(iCmd >= LORA_N_CMD)
    return(ERROR);
  
  /* build command */
  sprintf(szCmd, sizeof(szCmd), "%s=?\r\n", asLoRaCmd[iCmd].szCmd);
  lenCmd = strlen(szCmd);
  
  /* send command */
  iResult = LoRa_Write(0, szCmd, lenCmd);
  if(iResult != lenCmd)
    return(ERROR);
  
  /* start timeout monitoring */
  iResult = rM2M_TimerAddExt(funcidx("LoRa_CmdTimeout"), false, timeout);
  if(iResult < OK)
    return(ERROR);

  sLoRa_Vars.iCmdActive = iCmd;
  sLoRa_Vars.iCmdTimeout = timeout;
  sLoRa_Vars.iCmdTimerActive = 1;
  return(OK);
}

LoRa_CmdDone(iResult)
{
#pragma unused iResult

  sLoRa_Vars.iCmdActive = -1;
  sLoRa_Vars.iCmdTimeout = 0;
  if(sLoRa_Vars.iCmdTimerActive > 0)
  {
    rM2M_TimerRemoveExt(funcidx("LoRa_CmdTimeout"));
    sLoRa_Vars.iCmdTimerActive = 0;
  }
}

LoRa_CmdResponse(szLine{}, len)
{
  new i;
  new iResult=ERROR;
  new atResult;

  atResult = LoRa_CheckATResult(szLine, len);
  if(sLoRa_Vars.iCmdActive == LORA_CMD_VERSION)
  {
    if(atResult == AT_RSP_STRING)
    {
      /* Validate response: only '.' and digits (0-9) allowed */
      for(i=0 ; i<len ; i++)
      {
        if((szLine{i} != '.') && ((szLine{i} < '0') || (szLine{i} > '9')))
          break;
      }

      if(i == len)
      {
        strcpy(sLoRa_Vars.szVersion, szLine);
        printf("LORA_CMD_VERSION: %s\r\n", sLoRa_Vars.szVersion);
        iResult = OK;
      }
    }
    else
    {
      if(atResult != AT_RSP_OK)
        printf("LoRa_CmdResponse (LORA_CMD_VERSION): %d %s\r\n", atResult, szLine);
      LoRa_CmdDone(OK);
    }
  }
  return(iResult);
}

public LoRa_CmdTimeout()
{
  // printf("LoRa_CmdTimeout (%d)!\r\n", sLoRa_Vars.iCmdActive);
  sLoRa_Vars.iCmdTimerActive = 0;
  LoRa_CmdDone(ERROR);
}

/* UART Receive from LoRa module */
public LoRa_Rx(const data{}, len)
{
  new i, ch;
  new src, dest;
  new iResult;

#if (LORA_CONSOLE_RS232 > 0)
  /* pass data to RS232 interface */
  RS232_Write(0, data, len);
#endif

#if (LORA_CONSOLE_RS485 > 0)
  /* pass data to RS485 interface */
  RS485_Write(0, data, len);
#endif

  for(i=0 ; i<len ; i++)
  {
    ch = data{i};
    
    if(((ch == '\r') || (ch == '\n')) && (sLoRa_Vars.iLineBuf > 0))
    {
      sLoRa_Vars.szLineBuf{sLoRa_Vars.iLineBuf} = '\0';
      // printf("LoRa_Rx: \"%s\"\r\n", sLoRa_Vars.szLineBuf);
      
      if(sLoRa_Vars.iCmdActive >= 0)
      {
        /* Process Command Response */
        iResult = LoRa_CmdResponse(sLoRa_Vars.szLineBuf, sLoRa_Vars.iLineBuf);
      }
      else
      {
        /* No Command Active -> probably unsolicited data */
        iResult = ERROR;
      }

      if(iResult < OK)
      {
        if(strcmp(sLoRa_Vars.szLineBuf, "DevEui= ", 8) == 0)
        {
          /* parse out EUI string */
          for(src=8, dest=0 ; (src<sLoRa_Vars.iLineBuf) && (dest<LORA_EUI_STRLEN) ; src++, dest++)
            sLoRa_Vars.szEUI{dest} = sLoRa_Vars.szLineBuf{src};
          sLoRa_Vars.szEUI{dest} = '\0';
          printf("LoRa DevEui=%s\r\n", sLoRa_Vars.szEUI);
        }
        else if(strcmp(sLoRa_Vars.szLineBuf, "AppKey= ", 8) == 0)
        {
          /* parse out AppKey string */
          for(src=8, dest=0 ; (src<sLoRa_Vars.iLineBuf) && (dest<LORA_APPKEY_STRLEN) ; src++, dest++)
            sLoRa_Vars.szAppKey{dest} = sLoRa_Vars.szLineBuf{src};
          sLoRa_Vars.szAppKey{dest} = '\0';
          printf("LoRa AppKey=%s\r\n", sLoRa_Vars.szAppKey);
        }
      }
      sLoRa_Vars.iLineBuf = 0;
    }
    else if((ch >= 0x20) && (ch <= 0x7F))
    {
      /* valid ASCII character -> store within line buffer */
      if(sLoRa_Vars.iLineBuf < LORA_LINE_MAXLEN)
        sLoRa_Vars.szLineBuf{sLoRa_Vars.iLineBuf++} = ch;
    }
  }
}

/* UART Receive from RS232 interface */
public RS232_Rx(const data{}, len)
{
  /* pass data to LoRa module */
  LoRa_Write(0, data, len);
}

/* UART Receive from RS485 interface */
public RS485_Rx(const data{}, len)
{
  /* pass data to LoRa module */
  LoRa_Write(0, data, len);
}
