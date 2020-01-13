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
 * BLE Scanner APP interface library
 */
#if !defined HAVE_BLE_APP_SCANNER_CFG
#error "Configuration is missing, see ble_app_scanner_cfg.inc !"
#endif

/** Configuration Flags for <em>BLEApp_Init</em> */
#define BLEAPP_INIT_FLAGS_1S_TIMER_APPL   (0x0001)  /** 1s timer function is called from application */

/** Internal Configuration */
#if !defined BLEAPP_LINE_SIZE
#define BLEAPP_LINE_SIZE (100)
#endif

#define TBLEApp_Vars[.state, .line{BLEAPP_LINE_SIZE+1}, .len, .timeout, .connected]
#define TBLEApp_Scan[.addr_type, .addr{6}, .rssi, .name{32+1}, .msd_len, .msd{32}]

const
{
  BLEAPP_STATE_OFF = 0,
  BLEAPP_STATE_INIT,
  BLEAPP_STATE_READY,
  BLEAPP_STATE_SCANNING,
  BLEAPP_STATE_CONNECTING,
  BLEAPP_STATE_CONNECTED,
  BLEAPP_STATE_WRITING,
  BLEAPP_STATE_READING,
  BLEAPP_STATE_TIMEOUT
};

/* Supported IO Controller Commands */
const
{
  BLEAPP_CMD_NONE = 0,      
  BLEAPP_CMD_ADVERTISE,     /* CMD # 1 */
  BLEAPP_CMD_ADVERTISE_CFG, /* CMD # 2 */
  BLEAPP_N_CMD
}

/* forward declarations of public functions */
forward public int_BLEApp_Timer1s();

static sBLEApp_Vars[TBLEApp_Vars];

stock BLEApp_Init(iFlags=0)
{
  new iIdx, iResult;

  /* check if own 1s Timer should be created */
  if(!(iFlags & BLEAPP_INIT_FLAGS_1S_TIMER_APPL))
  {
    /* init a cyclic 1s Timer */
    iIdx = funcidx("int_BLEApp_Timer1s");
    iResult = rM2M_TimerAdd(iIdx);
    if(iResult < OK)
    {
#if defined BLEAPP_DEBUG
      printf("BLEAPP: rM2M_TimerAdd(%d) = %d\r\n", iIdx, iResult);
#endif
      return(ERROR);
    }
  }
  return(OK);
}

stock BLEApp_GetState()
{
  if((sBLEApp_Vars.state == BLEAPP_STATE_READY) &&
     (sBLEApp_Vars.connected != 0))
    return(BLEAPP_STATE_CONNECTED);

  return(sBLEApp_Vars.state);
}

stock BLEApp_PowerOn()
{
  int_UpdateState(BLEAPP_STATE_INIT);
  sBLEApp_Vars.timeout = 5;
  sBLEApp_Vars.connected = 0;
  return(OK);
}

stock BLEApp_PowerOff()
{
  int_UpdateState(BLEAPP_STATE_OFF);
  sBLEApp_Vars.connected = 0;
}

stock BLEApp_Scan(time = 10)
{
  new szCmd{30};

  /* start a timed scan */
  sprintf(szCmd, sizeof(szCmd), "at+scan=%d", time);
  if(BLEApp_Cmd(szCmd) >= OK)
  {
    int_UpdateState(BLEAPP_STATE_SCANNING);
    return(OK);
  }
  return(ERROR);
}

stock BLEApp_Char2Nibble(c)
{
  if((c >= '0') && (c <= '9'))
    return(c-'0');
  else if((c >= 'a') && (c <= 'f'))
    return(c-'a'+0xa);
  else if((c >= 'A') && (c <= 'F'))
    return(c-'A'+0xA);

  return(0xFF);
}

stock BLEApp_AsciiHex2Buf(string{}, buf{}, buflen)
{
  new len;
  new i;

  for(len = 0; len<buflen;)
  {
    new nibble;
    new c;

    c = string{i++};
    if(c == '\0')
      break;
    nibble = BLEApp_Char2Nibble(c);
    if(nibble != 0xFF)
    {
      buf{len} = nibble<<4;

      c = string{i++};
      if(c == '\0')
        break;
      nibble = BLEApp_Char2Nibble(c);
      if(nibble != 0xFF)
      {
        buf{len} |= nibble;
      }
      len++;
    }
  }

  return(len);
}

stock BLEApp_ScanResponse(line{})
{
  /* +SCAN: 2,"74:E1:4A:80:02:6C",-98,"ariTag", */
  /* +SCAN: <state>,<addr>,<rssi>,<name>,<msd> */
  if(strcmp(line, "+SCAN:", 6) == 0)
  {
    new iStart, iEnd;
    new szToken{BLEAPP_LINE_SIZE};
    new iIdx;
    new sScan[TBLEApp_Scan];

    iStart = 6;
    iEnd = strlen(line);

    while(iStart < iEnd)
    {
      new iPos;

      /* split with ',' */
      if((iPos = strpbrk(line, ",")) < 0)
        iPos = iEnd;
      else
        line{iPos} = ' ';

      rM2M_GetPackedB(line, iStart, szToken, iPos-iStart);
      szToken{iPos-iStart} = '\0';
      if(iIdx == 0)
      {
        new iState;

        iState = atoi(szToken);
        if(iState < 2)
          return;
        sScan.addr_type = atoi(szToken)-2;
      }
      else if(iIdx == 1)
      {
        /* token has to be enclosed by " */
        if((szToken{0} == '"') && (szToken{iPos-iStart-1} == '"'))
        {
          new i;
          new szTmp{3};

          for(i=0; i<6; i++)
          {
            rM2M_GetPackedB(szToken, 1+i*3, szTmp, 2);
            sScan.addr{i} = strtol(szTmp, 16);
          }
        }
        else
        {
#if defined BLEAPP_DEBUG
          printf("BLEApp_ScanResponse: err %s\r\n", szToken);
#endif
          return;
        }
      }
      else if(iIdx == 2)
      {
        sScan.rssi = atoi(szToken);
      }
      else if(iIdx == 3)
      {
        /* token has to be enclosed by " */
        if((szToken{0} == '"') && (szToken{iPos-iStart-1} == '"'))
        {
          rM2M_GetPackedB(szToken, 1, sScan.name, iPos-iStart-2);
          sScan.name{iPos-iStart-2} = '\0';
        }
        else
        {
          /* no name available */
          sScan.name{0} = '\0';
        }
      }
      else if(iIdx == 4)
      {
        /* token has to be enclosed by " */
        if((szToken{0} == '"') && (szToken{iPos-iStart-1} == '"'))
        {
          sScan.msd_len = BLEApp_AsciiHex2Buf(szToken, sScan.msd, 32);
        }
        else
        {
          /* no msd available */
          sScan.msd_len = 0;
        }
      }
      iStart = iPos + 1;
      iIdx++
    }

#if defined BLEAPP_DEVICE_SCANNED
    BLEAPP_DEVICE_SCANNED(sScan);
#elseif defined BLEAPP_DEBUG
    printf("  TYPE: %d\r\n", sScan.addr_type);
    printf("  ADDR: %02X:%02X:%02X:%02X:%02X:%02X\r\n",
      sScan.addr{0}, sScan.addr{1}, sScan.addr{2},
      sScan.addr{3}, sScan.addr{4}, sScan.addr{5});
    printf("  RSSI: %d\r\n", sScan.rssi);
    printf("  NAME: %s\r\n", sScan.name);
#endif
  }
}

stock BLEApp_Connect(addr{6}, itv = -1)
{
  new szCmd{40};

  if((itv >= 8) && (itv <= 1000))
  {
    /* connect with specified interval */
    sprintf(szCmd, sizeof(szCmd), "at+connect=\"%02X:%02X:%02X:%02X:%02X:%02X\",0,%d",
        addr{0}, addr{1}, addr{2},
        addr{3}, addr{4}, addr{5}, itv);
  }
  else
  {
    /* connect without any defined interval */
    sprintf(szCmd, sizeof(szCmd), "at+connect=\"%02X:%02X:%02X:%02X:%02X:%02X\",0",
        addr{0}, addr{1}, addr{2},
        addr{3}, addr{4}, addr{5});
  }

  /* connect to a device */
  if(BLEApp_Cmd(szCmd) >= OK)
  {
    int_UpdateState(BLEAPP_STATE_CONNECTING);
    sBLEApp_Vars.timeout = 10;
    return(OK);
  }
  return(ERROR);
}

stock BLEApp_ConnectResponse(line{})
{
  /* +CONNECT: 1,"74:E1:4A:80:02:6C" */
  /* +CONNECT: 0 */
  if(strcmp(line, "+CONNECT: ", 10) == 0)
  {
    new iState;

    iState = line{10} - '0';
    if(iState == 1)
    {
      if(!sBLEApp_Vars.connected)
        sBLEApp_Vars.timeout = 0;
      sBLEApp_Vars.connected = 1;
    }
    else
    {
      if(sBLEApp_Vars.connected)
        sBLEApp_Vars.timeout = 0;
      sBLEApp_Vars.connected = 0;
    }
  }
}

stock BLEApp_Disconnect()
{
  if(sBLEApp_Vars.connected)
  {
    /* disconnect from a device */
    if(BLE_Cmd("at+disconnect") >= OK)
    {
      sBLEApp_Vars.timeout = 10;
      return(OK);
    }
  }
  return(ERROR);
}

stock BLEApp_NotifyResponse(line{})
{
  new iStart, iEnd;
  new szToken{BLEAPP_LINE_SIZE};
  new iIdx;
  new handle, len;
  new data{32};

  /* +NOTIFY: "0034","81" */
  iStart = 9;
  iEnd = strlen(line);
  handle = -1;

  while(iStart < iEnd)
  {
    new iPos;

    /* split with ',' */
    if((iPos = strpbrk(line, ",")) < 0)
      iPos = iEnd;
    else
      line{iPos} = ' ';

    rM2M_GetPackedB(line, iStart, szToken, iPos-iStart);
    szToken{iPos-iStart} = '\0';
    if(iIdx == 0)
    {
      /* token has to be enclosed by " */
      if((szToken{0} == '"') && (szToken{iPos-iStart-1} == '"'))
      {
        szToken{0} = ' ';
        handle = strtol(szToken, 16);
      }
      else if((szToken{0} >= '0') && (szToken{0} <= '9'))
      {
        handle = strtol(szToken, 10);
      }
      else
      {
#if defined BLEAPP_DEBUG
        printf("BLE_NotifyResponse: err %s\r\n", szToken);
#endif
        return;
      }
    }
    else if(iIdx == 1)
    {
      /* token has to be enclosed by " */
      if((szToken{0} == '"') && (szToken{iPos-iStart-1} == '"'))
      {
        new szTmp{3};

        for(len=0; len<32;)
        {
          rM2M_GetPackedB(szToken, 1+len*2, szTmp, 2);
          data{len++} = strtol(szTmp, 16);
          if((1+len*2) >= (iPos-iStart-1))
            break;
        }
      }
      else
      {
#if defined BLEAPP_DEBUG
        printf("BLE_NotifyResponse: err %s\r\n", szToken);
#endif
        return;
      }
    }
    iStart = iPos + 1;
    iIdx++
  }

  if(handle >= 0)
  {
#if defined BLE_DEVICE_NOTIFY
    BLE_DEVICE_NOTIFY(handle, data, len);
#elseif defined BLEAPP_DEBUG
    printf("  NOTIFY: %d, %d\r\n", handle, len);
#endif
  }
}

stock BLEApp_ReadResponse(line{})
{
  new iStart, iEnd;
  new szToken{BLEAPP_LINE_SIZE};
  new iIdx;
  new handle, offset, len;
  new data{32};

  /* +READ: "0034",0,"81" */
  iStart = 7;
  iEnd = strlen(line);
  handle = -1;

  while(iStart < iEnd)
  {
    new iPos;

    /* split with ',' */
    if((iPos = strpbrk(line, ",")) < 0)
      iPos = iEnd;
    else
      line{iPos} = ' ';

    rM2M_GetPackedB(line, iStart, szToken, iPos-iStart);
    szToken{iPos-iStart} = '\0';
    if(iIdx == 0)
    {
      /* token has to be enclosed by " */
      if((szToken{0} == '"') && (szToken{iPos-iStart-1} == '"'))
      {
        szToken{0} = ' ';
        handle = strtol(szToken, 16);
      }
      else if((szToken{0} >= '0') && (szToken{0} <= '9'))
      {
        handle = strtol(szToken, 10);
      }
      else
      {
#if defined BLEAPP_DEBUG
        printf("BLE_ReadResponse: err %s\r\n", szToken);
#endif
        return;
      }
    }
    else if(iIdx == 1)
    {
      if((szToken{0} >= '0') && (szToken{0} <= '9'))
      {
        offset = strtol(szToken, 10);
      }
      else
      {
#if defined BLEAPP_DEBUG
        printf("BLE_ReadResponse: err %s\r\n", szToken);
#endif
        return;
      }
    }
    else if(iIdx == 2)
    {
      /* token has to be enclosed by " */
      if((szToken{0} == '"') && (szToken{iPos-iStart-1} == '"'))
      {
        new szTmp{3};

        for(len=0; len<32;)
        {
          rM2M_GetPackedB(szToken, 1+len*2, szTmp, 2);
          data{len++} = strtol(szTmp, 16);
          if((1+len*2) >= (iPos-iStart-1))
            break;
        }
      }
      else
      {
#if defined BLEAPP_DEBUG
        printf("BLE_ReadResponse: err %s\r\n", szToken);
#endif
        return;
      }
    }
    iStart = iPos + 1;
    iIdx++
  }

  if(handle >= 0)
  {
#if defined BLE_DEVICE_READ
    BLE_DEVICE_READ(handle, offset, data, len);
#elseif defined BLEAPP_DEBUG
    printf("  READ: %d, %d, %d\r\n", handle, offset, len);
#endif
  }
}

stock BLEApp_Write(handle, data{}, len)
{
  new szCmd{100};
  new i;

  if(sBLEApp_Vars.connected == 0)
    return(ERROR);

  sprintf(szCmd, sizeof(szCmd), "at+write=%d,\"", handle);
  for(i=0; i<len; i++)
  {
    new szHex{3};

    sprintf(szHex, sizeof(szHex), "%02X", data{i});
    strcat(szCmd, szHex);
  }
  strcat(szCmd, "\"");

  /* write to connected device */
  if(BLE_Cmd(szCmd) >= OK)
  {
    int_UpdateState(BLEAPP_STATE_WRITING);
    return(OK);
  }
  return(ERROR);
}

stock BLEApp_Read(handle)
{
  new szCmd{30};

  if(sBLEApp_Vars.connected == 0)
    return(ERROR);

  sprintf(szCmd, sizeof(szCmd), "at+read=%d", handle);

  /* read from connected device */
  if(BLE_Cmd(szCmd) >= OK)
  {
    int_UpdateState(BLEAPP_STATE_READING);
    return(OK);
  }
  return(ERROR);
}

stock BLEApp_Cmd(const cmd{})
{
  if(sBLEApp_Vars.state == BLEAPP_STATE_READY)
  {
    BleApp_Tx(cmd, strlen(cmd));
    BleApp_Tx("\r\n", 2);
    return(OK);
  }
  return(ERROR);
}

stock BLEApp_Rx(const data{}, len)
{
  new i, ch;

  if(sBLEApp_Vars.state == BLEAPP_STATE_OFF)
    return;

  for(i=0; i<len; i++)
  {
    ch = data{i};
    if((ch == '\r') && (sBLEApp_Vars.len > 0))
    {
      /* print received data */
      sBLEApp_Vars.line{sBLEApp_Vars.len} = '\0';
#if defined BLEAPP_DEBUG
      printf("BLEAPP: \"%s\", %d\r\n", sBLEApp_Vars.line, sBLEApp_Vars.len);
#endif
      if(strcmp(sBLEApp_Vars.line, "+POWERON") == 0)
      {
        if(sBLEApp_Vars.state == BLEAPP_STATE_INIT)
        {
          sBLEApp_Vars.state = BLEAPP_STATE_READY;
          sBLEApp_Vars.timeout = 0;
#if defined BLEAPP_DEBUG
          printf("BLEAPP: ready\r\n");
#endif
        }
        else
        {
          /* unexpected power on detected! */
          int_UpdateState(BLEAPP_STATE_TIMEOUT);
        }
      }
      else if(sBLEApp_Vars.state != BLEAPP_STATE_READY)
      {
        if((sBLEApp_Vars.len == 2) && (strcmp(sBLEApp_Vars.line, "OK") == 0))
          int_UpdateState(BLEAPP_STATE_READY);
        else if((sBLEApp_Vars.len == 5) && (strcmp(sBLEApp_Vars.line, "ERROR") == 0))
          int_UpdateState(BLEAPP_STATE_READY);
      }
      if(sBLEApp_Vars.state == BLEAPP_STATE_SCANNING)
      {
        BLEApp_ScanResponse(sBLEApp_Vars.line);
      }
      if((sBLEApp_Vars.state == BLEAPP_STATE_CONNECTING) ||
         (sBLEApp_Vars.connected != 0))
      {
        BLEApp_ConnectResponse(sBLEApp_Vars.line);
      }
      if(sBLEApp_Vars.connected != 0)
      {
        if(strcmp(sBLEApp_Vars.line, "+NOTIFY: ", 9) == 0)
          BLEApp_NotifyResponse(sBLEApp_Vars.line);
        else if(strcmp(sBLEApp_Vars.line, "+READ: ", 7) == 0)
          BLEApp_ReadResponse(sBLEApp_Vars.line);
      }

      sBLEApp_Vars.len = 0;
    }
    else if((ch >= 0x20) && (ch <= 0x7F))
    {
      if(sBLEApp_Vars.len < BLEAPP_LINE_SIZE)
        sBLEApp_Vars.line{sBLEApp_Vars.len++} = ch;
    }
  }
}

BLEApp_Timer1s()
{
  if(sBLEApp_Vars.timeout > 0)
  {
    sBLEApp_Vars.timeout--;
    if(sBLEApp_Vars.timeout == 0)
    {
#if defined BLEAPP_DEBUG
      printf("BLEAPP: Timeout!\r\n");
#endif
      int_UpdateState(BLEAPP_STATE_TIMEOUT);
    }
  }
}

public int_BLEApp_Timer1s()
{
  BLEApp_Timer1s();
}


/*******************************************************************************
 **************************   LOCAL FUNCTIONS   ********************************
 ******************************************************************************/

static int_UpdateState(newstate)
{
  if(newstate != sBLEApp_Vars.state)
  {
    if(newstate == BLEAPP_STATE_READY)
    {
      /* ready for sending (new) commands */
      /* xxxx */
    }
    sBLEApp_Vars.state = newstate;
  }
}

