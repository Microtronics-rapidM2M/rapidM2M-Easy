#pragma library EasyIoT

/**
 * <summary>
 *   Available Devices for Module Firmware Update.
 * </summary>
 */
#define MODFW_LORA   "CMWX1ZZABZ"  /**< Murata Module (STM32L072/82 with Semtech SX1276) */
#define MODFW_BLE    "NINA-B11X"   /**< uBlox NINA-B11x Module (NRF52) */

/**
 * <summary>
 *   Turn on RS232 3V3 supply.
 * </summary>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> otherwise.
 * </returns>
 */
native RS232_3V3_On();

/**
 * <summary>
 *   Turn off RS232 3V3 supply.
 * </summary>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> otherwise.
 * </returns>
 */
native RS232_3V3_Off();

/**
 * <summary>
 *   LoRa interface (UART) configuration bits used with LoRa_Init().
 * </summary>
 */
const
{
  LORA_1_STOPBIT   = 0b0000000000000001, // 1 stop bit
  LORA_2_STOPBIT   = 0b0000000000000010, // 2 stop bits
  LORA_PARITY_NONE = 0b0000000000000000, // no parity
  LORA_PARITY_ODD  = 0b0000000000000100, // odd parity
  LORA_PARITY_EVEN = 0b0000000000001000, // even parity
  LORA_7_DATABIT   = 0b0000000000000000, // 7 data bits
  LORA_8_DATABIT   = 0b0000000000010000, // 8 data bits
  LORA_FLOW_NONE   = 0b0000000000000000, // no flow control
  LORA_FLOW_RTSCTS = 0b0000000001000000, // RTS/CTS handshake
  LORA_FULL_DUPLEX = 0b0000000000000000,
  LORA_HALF_DUPLEX = 0b0000000100000000,
};

/**
 * <summary>
 *   Initialise LoRa interface.
 * </summary>
 *
 * <param name="LoRa">
 *   LoRa interface number.
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
 *   Index of LoRa receive function.
 *   Has to be of type: public func(const data{}, len);
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if interface is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native LoRa_Init(LoRa, baudrate, mode, funcidx);

/**
 * <summary>
 *   Close LoRa interface.
 * </summary>
 *
 * <param name="LoRa">
 *   LoRa interface number.
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if interface is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native LoRa_Close(LoRa);

/**
 * <summary>
 *   Send data over LoRa interface.
 * </summary>
 *
 * <param name="LoRa">
 *   LoRa interface number.
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
native LoRa_Write(LoRa, const data{}, len);

/**
 * <summary>
 *   Provide rx and tx buffer for LoRa interface.
 *   Note: function must be called before opening Uart interface (<em>LoRa_Init</em>) !
 * </summary>
 *
 * <param name="LoRa">
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
native LoRa_Setbuf(LoRa, rxbuf{}, rxlen, txbuf{}, txlen);

/**
 * <summary>
 *   Init and configure lidcover interface.
 * </summary>
 *
 * <param name="mode">
 *   currently not used - use 0.
 * </param>
 * <param name="funcidx">
 *   Index of callback function if script mode. Function is called on lidcover state change.
 *   Has to be of type: public func(key);
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
native LidCover_Init(mode, funcidx=-1);

/**
 * <summary>
 *   Close and deactivate lidcover interface.
 * </summary>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
native LidCover_Close();
