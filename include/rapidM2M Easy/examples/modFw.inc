/**
 * <summary>
 *   This file includes functions for Module Firmware Update
 * </summary>
 */
#if !defined HAVE_MODFW_CFG
#error "Configuration is missing, see modFw_cfg.inc !"
#endif

forward public ModFw_rM2M_Callback(iResult);

#if !defined MODFW_LEN_CMD_QUEUE
#define MODFW_LEN_CMD_QUEUE       (10)
#endif
#if !defined MODFW_LEN_READ_BUFFER
#define MODFW_LEN_READ_BUFFER   (4096)
#endif
#if !defined MODFW_INFO_MAXLEN
#define MODFW_INFO_MAXLEN         (64)
#endif

/** Command flags */
#define MODFW_CMDFLAG_VERIFY_CRC      (0x0001)

static sModFw_Vars[.iCmdActive, .hVerifyCrc, .iCrcLen, .iCrcOfs, .iCrcRead, .iCrcCalc];
static aModFwRead{MODFW_LEN_READ_BUFFER};
static aModFwReadUnpacked{MODFW_LEN_READ_BUFFER};

#define TModFwReadCmd[.hModFw, .iTag, .iLen, .iOfs, .iFlags]
static asModFwCmdQueue[MODFW_LEN_CMD_QUEUE][TModFwReadCmd];
static iModFwPosCmdQueue;

/**
 * <summary>
 *   Init Module Firmware handling.
 * </summary>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
ModFw_Init()
{
  sModFw_Vars.iCmdActive = -1;
  sModFw_Vars.hVerifyCrc = -1;
  return(OK);
}

/**
 * <summary>
 *   Register Module Firmware. Handle information will be filled if firmware
 *   is available. This handle will be necessary for all following operations.
 *   INFO tag is read automatically if handle was found.
 * </summary>
 *
 * <param name="szId">
 *   Identification string for Module Firmware
 * </param>
 * <param name="hModFw">
 *   Handle identifying the firmware
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
ModFw_Register(szId{}, &hModFw)
{
  new iResult, i;
  new szIdAvail{MODFW_INFO_MAXLEN+1};

  /* Search index for LoRa Module Firmware handling */
  i = 0;
  hModFw = -1;
  iResult = OK;
  while((iResult >= OK) && (hModFw < 0))
  {
    /* Read FW Id string (installed firmware) */
    iResult = rM2M_ModFwGetId(i, szIdAvail);
    if((iResult >= OK) && (strcmp(szIdAvail, szId, strlen(szId)) == 0))
    {
      /* ModFw was found -> store handle information */
      hModFw = i;
#if defined MODFW_DEBUG
      printf("ModFw_Register(%d): %s\r\n", hModFw, szId);
#endif
      /* Read INFO tag (FW Id string) */
      iResult = int_SendCmd(hModFw, RM2M_MODFW_TAG_INFO, MODFW_LEN_READ_BUFFER, 0, 0);
      if(iResult < OK)
      {
        printf("ModFw_Register(%d): Error reading INFO tag!\r\n", hModFw);
        return(ERROR);
      }
    }
    else
    {
      /* proceed search */
      i++;
    }
  }
  return(hModFw);
}

/**
 * <summary>
 *   Start Reading Module Firmware tag. Operation is asynchronous, function 
 *   MODFW_READ_TAG_CB is called if results will be available.
 * </summary>
 *
 * <param name="hModFw">
 *   Handle identifying the firmware
 * </param>
 * <param name="tag">
 *   Selected tag that should be read
 * </param>
 * <param name="ofs">
 *   Byteoffset within data area for selected tag
 * </param>
 *
 * <returns>
 *   <em>OK</em> if command was started, otherwise <em>ERROR</em>.
 * </returns>
 */
stock ModFw_ReadTag(hModFw, tag, ofs=0)
{
  return(int_SendCmd(hModFw, tag, MODFW_LEN_READ_BUFFER, ofs));
}

/**
 * <summary>
 *   Start Reading Length of Module Firmware tag. Operation is asynchronous, function 
 *   MODFW_READ_TAGLEN_CB is called if results will be available.
 * </summary>
 *
 * <param name="hModFw">
 *   Handle identifying the firmware
 * </param>
 * <param name="tag">
 *   Selected tag that should be read
 * </param>
 *
 * <returns>
 *   <em>OK</em> if command was started, otherwise <em>ERROR</em>.
 * </returns>
 */
stock ModFw_ReadTagLen(hModFw, tag)
{
  return(int_SendCmd(hModFw, tag, 0, 0));
}

stock ModFw_VerifyCrc(hModFw)
{
  new iResult;

  if(hModFw == sModFw_Vars.hVerifyCrc)
  {
    /* CRC verification for this handle currently in progress */
    return(ERROR);
  }
  
  /* read CRC entry */
  iResult = int_SendCmd(hModFw, RM2M_MODFW_TAG_CRC, MODFW_LEN_READ_BUFFER, 0, MODFW_CMDFLAG_VERIFY_CRC);
#if defined MODFW_DEBUG
  printf("ModFw_VerifyCrc(%d): %d\r\n", hModFw, iResult);
#endif
  return(iResult);
}

static int_ProcessCmdQueue()
{
  new iResult;
  new iSend = 1;
  new hModFw, iTag, iFlags;
  // new iLen, iOfs;

  if((sModFw_Vars.iCmdActive == -1) && 
     (asModFwCmdQueue[iModFwPosCmdQueue].iTag != 0))
  {
    /* select next command */
    sModFw_Vars.iCmdActive = iModFwPosCmdQueue;
    hModFw = asModFwCmdQueue[iModFwPosCmdQueue].hModFw;
    iTag = asModFwCmdQueue[iModFwPosCmdQueue].iTag;
    //iLen = asModFwCmdQueue[iModFwPosCmdQueue].iLen;
    //iOfs = asModFwCmdQueue[iModFwPosCmdQueue].iOfs;
    iFlags = asModFwCmdQueue[iModFwPosCmdQueue].iFlags;

    if(iFlags & MODFW_CMDFLAG_VERIFY_CRC)
    {
      /* this is a command used for CRC verification */
      if(sModFw_Vars.hVerifyCrc == -1)
      {
        /* start CRC verification (several read operations required) */
        sModFw_Vars.hVerifyCrc = hModFw;
        sModFw_Vars.iCrcLen = 0;
        sModFw_Vars.iCrcOfs = 0;
        sModFw_Vars.iCrcCalc = 0;
        sModFw_Vars.iCrcRead = -1;
      }
      else if(hModFw != sModFw_Vars.hVerifyCrc)
      {
        /* another CRC verification is currently active -> queue */
        ModFw_VerifyCrc(hModFw);

        /* finish command immediately */
        iSend = 0;
        int_CmdDone();
      }
    }

    if(iSend)
    {
      /* Send Read command */
      iResult = rM2M_ModFwReadTag(hModFw,
                                  iTag,
                                  funcidx("ModFw_rM2M_Callback"),
                                  aModFwRead,
                                  asModFwCmdQueue[iModFwPosCmdQueue].iLen/4,
                                  asModFwCmdQueue[iModFwPosCmdQueue].iOfs);
      if(iResult < OK)
      {
#if defined MODFW_DEBUG
        printf("rM2M_ModFwReadTag(hModFw=%d, tag=%xh): %d\r\n", hModFw, asModFwCmdQueue[iModFwPosCmdQueue].iTag, iResult);
#endif
        if(iFlags & MODFW_CMDFLAG_VERIFY_CRC)
          int_CrcVerifyDone(hModFw, ERROR);
        else if(iTag == RM2M_MODFW_TAG_INFO)
          int_InfoDone(hModFw, ERROR);

        /* finish command */
        int_CmdDone();
      }
    }
  }
}

static int_CmdDone()
{
  if(sModFw_Vars.iCmdActive >= 0)
  {
    /* finish ongoing command */
    asModFwCmdQueue[iModFwPosCmdQueue].iTag = 0;
    iModFwPosCmdQueue++;
    if(iModFwPosCmdQueue >= MODFW_LEN_CMD_QUEUE)
      iModFwPosCmdQueue = 0;
    sModFw_Vars.iCmdActive = -1;

    /* proceed with next command (if available) */
    int_ProcessCmdQueue();
  }
}

static int_InfoDone(hModFw, iResult)
{
  new szInfoInstalled{MODFW_INFO_MAXLEN+1};
  new szInfoUpdate{MODFW_INFO_MAXLEN+1};

#if defined MODFW_DEBUG
  printf("int_InfoDone(%d): %d\r\n", hModFw, iResult);
#endif
  /* Info Tag was read -> read currently installed ID and provide both INFO strings
   * to the user for check if update is required/available. */
  rM2M_ModFwGetId(hModFw, szInfoInstalled);
  if(iResult >= OK)
    rM2M_GetPackedB(aModFwRead, 0, szInfoUpdate, iResult);
#if defined MODFW_INFO_CB
  MODFW_INFO_CB(hModFw, szInfoInstalled, szInfoUpdate);
#endif        
}

static int_CrcVerifyDone(hModFw, iResult)
{
#if defined MODFW_DEBUG
  printf("int_CrcVerifyDone(%d): %d\r\n", hModFw, iResult);
#endif
  sModFw_Vars.hVerifyCrc = -1;
#if defined MODFW_VERIFYCRC_CB
  MODFW_VERIFYCRC_CB(hModFw, iResult);
#endif        
}

static int_SendCmd(hModFw, iTag, iLen, iOfs, iFlags=0)
{
  new i;
  new iPosCmdQueue;

  /* search free position within command queue */
  i = 0;
  iPosCmdQueue = iModFwPosCmdQueue;
  while((i < MODFW_LEN_CMD_QUEUE) && (asModFwCmdQueue[iPosCmdQueue].iTag != 0))
  {
    i++;
	iPosCmdQueue++;
	if(iPosCmdQueue >= MODFW_LEN_CMD_QUEUE)
	  iPosCmdQueue = 0;
  }
  
  /* return immediately if command queue is full */
  if(i >= MODFW_LEN_CMD_QUEUE)
  {
    printf("modFw (int_SendCmd): cmd queue full!\r\n");
    return(ERROR);
  }

  /* add command to queue */
  asModFwCmdQueue[iPosCmdQueue].hModFw = hModFw;
  asModFwCmdQueue[iPosCmdQueue].iTag = iTag;
  asModFwCmdQueue[iPosCmdQueue].iLen = iLen;
  asModFwCmdQueue[iPosCmdQueue].iOfs = iOfs;
  asModFwCmdQueue[iPosCmdQueue].iFlags = iFlags;
  int_ProcessCmdQueue();
  return(OK);
}

public ModFw_rM2M_Callback(iResult)
{
  new hModFw, iTag, iLen, iFlags;

  if(sModFw_Vars.iCmdActive >= 0)
  {
    hModFw = asModFwCmdQueue[iModFwPosCmdQueue].hModFw;
    iTag = asModFwCmdQueue[iModFwPosCmdQueue].iTag;
    iLen = asModFwCmdQueue[iModFwPosCmdQueue].iLen;
    iFlags = asModFwCmdQueue[iModFwPosCmdQueue].iFlags;

#if defined MODFW_DEBUG
    printf("ModFw_rM2M_Callback(%d): hModFw=%d, iTag=%xh, iOfs=%d\r\n", iResult, hModFw, iTag, asModFwCmdQueue[iModFwPosCmdQueue].iOfs);
#endif

    if(iFlags & MODFW_CMDFLAG_VERIFY_CRC)
    {
      /* Read Command is used for CRC verification */
      if(iTag == RM2M_MODFW_TAG_CRC)
      {
        /* read stored CRC */
        if(iResult == 4)
        {
          /* read CRC (u32, little-endian) */
          rM2M_Pack(aModFwRead, 0, sModFw_Vars.iCrcRead, RM2M_PACK_GET | RM2M_PACK_U32);

          /* proceed reading length of BIN tag (firmware size) */
          iResult = int_SendCmd(hModFw, RM2M_MODFW_TAG_BIN, 0, 0, MODFW_CMDFLAG_VERIFY_CRC);
          if(iResult < OK)
          {
            printf("MODFW_CMDFLAG_VERIFY_CRC: Error reading length of BIN tag!\r\n");
            int_CrcVerifyDone(hModFw, ERROR);
          }
        }
        else
        {
          printf("RM2M_MODFW_TAG_CRC: invalid length %d!\r\n", iResult);
          int_CrcVerifyDone(hModFw, ERROR);
        }
      }
      else if(iTag == RM2M_MODFW_TAG_BIN)
      {
        if(iResult > 0)
        {
          new readNext = 0;

          if(iLen == 0)
          {
            /* Length of BIN tag (length of firmwarecode) was read */
            sModFw_Vars.iCrcLen = iResult;
            sModFw_Vars.iCrcOfs = 0;
            
            /* start reading first block */
            readNext = 1;
          }
          else if(iResult <= MODFW_LEN_READ_BUFFER)
          {
            /* Data Block was read -> update CRC */
            rM2M_GetPackedB(aModFwRead, 0, aModFwReadUnpacked, iResult);
            sModFw_Vars.iCrcCalc = CRC32(aModFwReadUnpacked, iResult, sModFw_Vars.iCrcCalc);
            sModFw_Vars.iCrcOfs += iResult;
            if(sModFw_Vars.iCrcOfs >= sModFw_Vars.iCrcLen)
            {
              /* BIN read finished -> verify CRC */
              if(sModFw_Vars.iCrcCalc == sModFw_Vars.iCrcRead)
                int_CrcVerifyDone(hModFw, OK);
              else
                int_CrcVerifyDone(hModFw, ERROR);
            }
            else
            {
              /* proceed reading next block */
              readNext = 1;
            }
          }
          else
          {
            int_CrcVerifyDone(hModFw, ERROR);
          }

          if(readNext)
          {
            iResult = int_SendCmd(hModFw, RM2M_MODFW_TAG_BIN, MODFW_LEN_READ_BUFFER, sModFw_Vars.iCrcOfs, MODFW_CMDFLAG_VERIFY_CRC);
            if(iResult < OK)
            {
              int_CrcVerifyDone(hModFw, ERROR);
            }
          }
        }
        else
        {
          /* Error reading data for BIN tag */
          int_CrcVerifyDone(hModFw, ERROR);
        }
      }
    }
    else if(iTag == RM2M_MODFW_TAG_INFO)
    {
      int_InfoDone(hModFw, iResult);
    }
    else
    {  
      if(iLen == 0)
      {
#if defined MODFW_READ_TAGLEN_CB
        /* call userfunction (only length of TAG field was read) */
        MODFW_READ_TAGLEN_CB(hModFw, iTag, iResult);
#endif
      }
      else
      {
#if defined MODFW_READ_TAG_CB
        /* call userfunction */
        MODFW_READ_TAG_CB(hModFw, iTag, iOfs, aModFwRead, iResult);
#endif
      }
    }

    /* proceed with next command */
    int_CmdDone();
  }
}
