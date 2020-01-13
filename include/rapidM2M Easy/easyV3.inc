/**
 * rapidM2M Easy HW3.x specific include file
 */
#pragma library EasyV3

#include "ui"
#include "led"
#include "pm"

/**
 * <summary>
 *   Available UI Channels.
 * </summary>
 */
const
{
  UI_CHANNEL1 = 0,
  UI_CHANNEL2,
  UI_CHANNEL3,
  UI_CHANNEL4,
  UI_NUM_CHANNELS,
};

/**
 * <summary>
 *   Available Digout Channels.
 * </summary>
 */
const 
{
  DIGOUT_CHANNEL1 = 0,
  DIGOUT_NUM_CHANNELS,
}

/**
 * <summary>
 *   Available TEMP Channels.
 * </summary>
 */
const 
{
  TEMP_CHANNEL1 = 0,
  TEMP_NUM_CHANNELS,
}

/**
 * <summary>
 *   Available RS232 interfaces.
 * </summary>
 */
const
{
  RS232_ITF1 = 0,
  RS232_NUM_ITF,
};

/**
 * <summary>
 *   Available RS485 interfaces.
 * </summary>
 */
const
{
  RS485_ITF1 = 0,
  RS485_NUM_ITF,
};

/**
 * <summary>
 *   RS232 configuration bits used with RS232_Init().
 * </summary>
 */
const
{
  RS232_1_STOPBIT   = 0b0000000000000001, // 1 stop bit
  RS232_2_STOPBIT   = 0b0000000000000010, // 2 stop bits
  RS232_PARITY_NONE = 0b0000000000000000, // no parity
  RS232_PARITY_ODD  = 0b0000000000000100, // odd parity
  RS232_PARITY_EVEN = 0b0000000000001000, // even parity
  RS232_7_DATABIT   = 0b0000000000000000, // 7 data bits
  RS232_8_DATABIT   = 0b0000000000010000, // 8 data bits
  RS232_FLOW_NONE   = 0b0000000000000000, // no flow control
  RS232_FLOW_RTSCTS = 0b0000000001000000, // RTS/CTS handshake
  RS232_FULL_DUPLEX = 0b0000000000000000,
  RS232_HALF_DUPLEX = 0b0000000100000000,
};

/**
 * <summary>
 *   Initialise RS232 interface.
 * </summary>
 *
 * <param name="rs232">
 *   RS232 interface number.
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
 *   Index of RS232 receive function.
 *   Has to be of type: public func(const data{}, len);
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if interface is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native RS232_Init(rs232, baudrate, mode, funcidx);

/**
 * <summary>
 *   Close RS232 interface.
 * </summary>
 *
 * <param name="rs232">
 *   RS232 interface number.
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if interface is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native RS232_Close(rs232);

/**
 * <summary>
 *   Send data over RS232 interface.
 * </summary>
 *
 * <param name="rs232">
 *   RS232 interface number.
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
native RS232_Write(rs232, const data{}, len);

/**
 * <summary>
 *   Provide rx and tx buffer for RS232 interface.
 *   Note: function must be called before opening RS232 interface (<em>RS232_Init</em>) !
 * </summary>
 *
 * <param name="RS232">
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
native RS232_Setbuf(rs232, rxbuf{}, rxlen, txbuf{}, txlen);

/**
 * <summary>
 *   RS485 configuration bits used with RS485_Init().
 * </summary>
 */
const
{
  RS485_1_STOPBIT   = 0b0000000000000001, // 1 stop bit
  RS485_2_STOPBIT   = 0b0000000000000010, // 2 stop bits
  RS485_PARITY_NONE = 0b0000000000000000, // no parity
  RS485_PARITY_ODD  = 0b0000000000000100, // odd parity
  RS485_PARITY_EVEN = 0b0000000000001000, // even parity
  RS485_7_DATABIT   = 0b0000000000000000, // 7 data bits
  RS485_8_DATABIT   = 0b0000000000010000, // 8 data bits
  RS485_HALF_DUPLEX = 0b0000000000000000,
  RS485_FULL_DUPLEX = 0b0000000100000000,
  RS485_120_OHM_NONE= 0b0000000000000000,
  RS485_120_OHM_ACT = 0b0000001000000000,
};

/**
 * <summary>
 *   Initialise RS485 interface.
 * </summary>
 *
 * <param name="rs485">
 *   RS485 interface number.
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
 *   Bit 8
 * 	   0 = half duplex
 *     1 = full duplex
 *   Bit 9
 *     0 = no 120 ohm resistor
 *     1 = 120 ohm resistor active
 * </param>
 * <param name="funcidx">
 *   Index of RS485 receive function.
 *   Has to be of type: public func(const data{}, len);
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if interface is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native RS485_Init(rs485, baudrate, mode, funcidx);

/**
 * <summary>
 *   Close RS485 interface.
 * </summary>
 *
 * <param name="rs485">
 *   RS485 interface number.
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if interface is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native RS485_Close(rs485);

/**
 * <summary>
 *   Send data over RS485 interface.
 * </summary>
 *
 * <param name="rs485">
 *   RS485 interface number.
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
native RS485_Write(rs485, const data{}, len);

/**
 * <summary>
 *   Provide rx and tx buffer for rs485 interface.
 *   Note: function must be called before opening Uart interface (<em>RS485_Init</em>) !
 * </summary>
 *
 * <param name="rs485">
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
native RS485_Setbuf(rs485, rxbuf{}, rxlen, txbuf{}, txlen);

/**
 * <summary>
 *   Vsens modes.
 * </summary>
 */
const
{
  VSENS_15V = 0, // 15V sensor supply voltage
  VSENS_24V,     // 24V sensor supply voltage
};

/**
 * <summary>
 *   Turn on sensor supply.
 * </summary>
 *
 * <param name="mode">
 *   EasyV3:  Sensor supply mode (see Vsens modes).
 *   EasyIoT: Sensor voltgae (5000 .. 24000 [mV]).
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> otherwise.
 * </returns>
 */
native Vsens_On(mode);

/**
 * <summary>
 *   Turn off sensor supply.
 * </summary>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> otherwise.
 * </returns>
 */
native Vsens_Off();

/**
 * <summary>
 *   Turn on external 3V3 supply.
 * </summary>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> otherwise.
 * </returns>
 */
native Ext3V3_On();

/**
 * <summary>
 *   Turn off external 3V3 supply.
 * </summary>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> otherwise.
 * </returns>
 */
native Ext3V3_Off();

/**
 * <summary>
 *   Temperature conversion modes.
 * </summary>
 */
const
{
  TEMP_MODE_SINGLE_CONV = 0, // single conversion mode
  TEMP_MODE_CONT_CONV        // continuous conversion mode
};

/**
 * <summary>
 *   Init and configure temperature module.
 * </summary>
 *
 * <param name="temp">
 *   temperature module number.
 * </param>
 * <param name="mode">
 *   see Temperature conversion modes.
 * </param>
 *
 * <returns>
 *   Conversion time in [ms] if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if module is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native Temp_Init(temp, mode);

/**
 * <summary>
 *   Close and deactivate temperature module.
 * </summary>
 *
 * <param name="temp">
 *   temperature module number.
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if module is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native Temp_Close(temp);

/**
 * <summary>
 *   Get actual value from temperature module.
 * </summary>
 *
 * <param name="temp">
 *   temperature module number.
 * </param>
 * <param name="value">
 *   Returns the temperature value in [0,1°C].
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful
 *   <em>ERROR_FEATURE_LOCKED</em> if module is not unlocked on this device (see rM2M.inc)
 *   <em>ERROR</em> if any other error occured.
 * </returns>
 */
native Temp_GetValue(temp, &value);

/**
 * <summary>
 *   Switch Modes.
 * </summary>
 */
const
{
  SWITCH_MODE_INTERNAL = 0, // switch is controlled by FW
  SWITCH_MODE_SCRIPT,       // switch is controlled by Script
};

/**
 * <summary>
 *   Init and configure switch interface.
 * </summary>
 *
 * <param name="mode">
 *   see Switch Modes.
 * </param>
 * <param name="funcidx">
 *   Index of callback function if script mode. Function is called on switch state change.
 *   Has to be of type: public func(key);
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
native Switch_Init(mode, funcidx=-1);

/**
 * <summary>
 *   Close and deactivate switch interface.
 * </summary>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
native Switch_Close();

/**
 * <summary>
 *   Digout modes.
 * </summary>
 */
const
{
  DIGOUT_OFF = 0,
  DIGOUT_DIG,
  DIGOUT_FREQ,
  DIGOUT_PWM,
  DIGOUT_IMPULSE_PER_MINUTE,
  DIGOUT_IMPULSE_ONCE,
};

/**
 * <summary>
 *   Init and configure digout interface.
 * </summary>
 *
 * <param name="digout">
 *   Digout interface number.
 * </param>
 * <param name="mode">
 *   see Digout modes.
 * </param>
 * <param name="cfg1">
 *   Digout mode dependant
 *     DIGOUT_DIG: not used
 *     DIGOUT_FREQ: output duty cycle (1<= xx <=100 [%], standard = 50%) for frequency
 *     DIGOUT_PWM: output frequency (0 <= xx <= 1000 [Hz], standard = 100 Hz) for PWM
 *     DIGOUT_IMPULSE_PER_MINUTE: impulse length (depends on UI_Samplerate, standard = 100 ms)
 *     DIGOUT_IMPULSE_ONCE: impulse length (1ms <= xx <= 500 [ms], standard = 100 ms)
 * </param>
 * <param name="cfg2">
 *   Digout mode dependant
 *     DIGOUT_DIG: not used
 *     DIGOUT_FREQ: not used
 *     DIGOUT_PWM: not used
 *     DIGOUT_IMPULSE_PER_MINUTE: not used
 *     DIGOUT_IMPULSE_ONCE: impulse pause (1ms <= xx <= 500 [ms], standard = 100 ms)
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
native DigOut_Init(digout, mode, cfg1 = -1, cfg2 = -1);

/**
 * <summary>
 *   Close and deactivate digout interface.
 * </summary>
 *
 * <param name="digout">
 *   Digout interface number.
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
native DigOut_Close(digout);

/**
 * <summary>
 *   Set digout value.
 * </summary>
 *
 * <param name="digout">
 *   Digout interface number.
 * </param>
 * <param name="value">
 *   Digout mode dependant
 *     DIGOUT_DIG: 0 = LOW, >0 = HIGH
 *     DIGOUT_FREQ: frequency (1<= xx <=1000)
 *     DIGOUT_PWM: pwm (0 <= xx <= 100)
 *     DIGOUT_IMPULSE_PER_MINUTE: impulse per minute
 *     DIGOUT_IMPULSE_ONCE: impulse once
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, otherwise <em>ERROR</em>.
 * </returns>
 */
native DigOut_SetValue(digout, value);

/**
 * <summary>
 *   Sys info structure.
 * </summary>
 * <param name="Temp">
 *   Temperatur [0.1°C]
 * </param>
 * <param name="RH">
 *   Relative Humidity [0.1%RH]
 * </param>
 */
#define TEasyV3_SysValue[.Temp, .RH]

/**
 * <summary>
 *   Retrieve sys values of device.
 * </summary>
 *
 * <param name="values">
 *   Structure where sys values are filled in.
 * </param>
 * <param name="len">
 *   length of values Structure, max size according to TEasyV3_SysValue
 * </param>
 *
 * <returns>
 *   Returns:
 *   <ul>
 *     <li><em>used size of id struct</em></li>
 *     <li><em>ERROR</em> - if address/length pair for id struct is invalid or a sys value is invalid.</li>
 *   </ul>
 * </returns>
 */
native EasyV3_GetSysValues(values[TEasyV3_SysValue], len=sizeof values);