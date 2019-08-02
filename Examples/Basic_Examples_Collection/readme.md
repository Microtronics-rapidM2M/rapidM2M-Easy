## Explanation
The examples included in the basic example collection are designed to demonstrate how to use the rapidM2M Device API. In addition to the basic handling you also find best practice examples. With the increasing number at the beginning of the name, the complexity of the example increases as well. 

## Example overview
* **[00_common_0_Main.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/00_common_0_Main.p)** <br/>
*Simple rapidM2M "Hello World"* <br/>
Prints "Hello World" to the development console once after starting the script.
* **[00_common_1_Timer_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/00_common_1_Timer_1.p)** <br/>
*Extended rapidM2M "Hello World" Example* <br/>
Prints "Hello World" every second to the development console
* **[00_common_1_Timer_2.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/00_common_1_Timer_2.p)** <br/>
*Extended rapidM2M "Hello World" Example* <br/>
Prints "Hello World" every 5 seconds to the development console
* **[00_common_2_get_module_info.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/00_common_2_get_module_info.p)** <br/>
Prints the information for identifying the rapidM2M hardware and the implemented API level to the development console.
* **[00_common_5_data_types.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/00_common_5_data_types.p)** <br/>
*Simple "Data Types" Example* <br/>
Example on how to implement, handle and convert integer, floating-point and boolean variables in rapidM2M projects. <br/>
* **[00_common_6_array.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/00_common_6_array.p)** <br/>
*Simple "Array" Example* <br/>
Declarations and handling of arrays and the sizeof operator <br/>
* **[00_common_7_conditional.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/00_common_7_conditional.p)** <br/>
*Simple rapidM2M "Conditional" Example* <br/>
Example on how to use if and switch statements in rapidM2M projects <br/>
* **[00_common_8_loop.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/00_common_8_loop.p)** <br/>
*Simple rapidM2M "Loop" Example* <br/>
Example on how to use loops in rapidM2M projects <br/>
* **[10_Switch.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/10_Switch.p)** <br/>
*Simple "Button" Example* <br/>
Evaluates the state of the button <br/>
* **[10_Switch_Long.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/10_Switch_Long.p)** <br/>
*Extended "Button" Example* <br/>
 Evaluates the state of the button and also detects if the button was pressed only briefly or for a longer time <br/>
* **[11_Led_2.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/11_Led_2.p)** <br/>
*Simple "LED" Example* <br/>
Toggles an external LED connected to VEXT every second <br/>
* **[11_Led_2_3.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/11_Led_2_3.p)** <br/>
*Extended "LED" Example* <br/>
Toggles external LED2 (VEXT) and external LED3 (VOUT) every second. If external LED2 is on, then external LED3 is off and vice versa. <br/>
* **[11_Status_Led_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/11_Status_Led_1.p)** <br/>
*Simple "LED" Example* <br/>
Toggles green LED every second <br/>
* **[11_Status_Led_and_Button_0.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/11_Status_Led_and_Button_0.p)** <br/>
*Simple "LED and reed switch" Example* <br/>
As long as a magnetic field is present at the reed switch, the LED lights up green. If no magnetic field is present, the LED is turned off. <br/>
* **[11_Status_Led_and_Button_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/11_Status_Led_and_Button_1.p)** <br/>
*Extended "LED and Reed switch" Example* <br/>
Changes the colour and mode of the red and green LEDs each time the reed switch is closed. <br/>
* **[11_Status_Led_and_Input_0.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/11_Status_Led_and_Input_0.p)** <br/>
*Simple "LED and GPIO (ext. button)" Example* <br/>
As long as the external button connected to UI1 is pressed, the LED lights up green. If the external button is released, the LED is turned off. <br/>
* **[11_Status_Led_and_Input_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/11_Status_Led_and_Input_1.p)** <br/>
*Extended "LED and GPIO (ext. button)" Example* <br/>
Changes the colour and mode of the red and green LEDs each time the external button connected to UI1 is pressed. <br/>
* **[11_Status_Led_rgb_v1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/11_Status_Led_rgb_v1.p)** <br/>
*"Red and Green LED" Example V1* <br/>
Changes the color of the red and green LED each second. To do this, a counter is repeatedly increased from 0 to 3. Each bit of the counter is assigned a color of the red and green LED. <br/>
* **[11_Status_Led_rgb_v2.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/11_Status_Led_rgb_v2.p)** <br/>
*"Red and Green LED" Example V2* <br/>
Changes the color of the red and green LED each second. To do this, a counter is repeatedly increased from 0 to 3. Each bit of the counter is assigned a color of the red and green LED. <br/>
* **[12_Transmission_0.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/12_Transmission_0.p)** <br/>
*Simple "Transmission" Example*<br/>
Initiates a connection to the server. The synchronisation of the configuration, registration and measurement data is automatically done by the firmware. <br/>
* **[12_Transmission_2_cyclic_connection.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/12_Transmission_2_cyclic_connection.p)** <br/>
*Extended "Transmission" Example*<br/>
Initiates a connection to the server every 2 hours. The synchronisation of the configuration, registration and measurement data is automatically done by the firmware. <br/>
* **[12_Transmission_3_ForceOnline.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/12_Transmission_3_ForceOnline.p)** <br/>
*Extended "Online Mode Transmission" Example*<br/>
Establishes and tries to maintain an online connection to the server. As long as the device is in online mode, a synchronisation of the configuration, registration and measurement data is initiated every 2 hours.<br/>
 * **[13_Transmission_Status_Led_0.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/13_Transmission_Status_Led_0.p)** <br/>
*Simple "Indicating the Transmission state" Example*<br/>
Initiates a connection to the server and uses LED to indicate the current connection state <br/>
* **[13_Transmission_Status_Led_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/13_Transmission_Status_Led_1.p)** <br/>
*Simple "Indicating the Transmission state" Example*<br/>
Initiates a connection to the server and uses LED to indicate the current connection state. <br/>
* **[13_Transmission_Status_Led_2.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/13_Transmission_Status_Led_2.p)** <br/>
*Extended "Indicating the Transmission state" Example*<br/>
Initiates a connection to the server and uses LED to indicate the current connection state. <br/>
* **[20_rs232_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/20_rs232_1.p)** <br/>
*Simple "RS232" Example* <br/>
Issues the text "Data" every secound via the RS232 interface and receives data via the RS232 interface. <br/>
* **[20_rs232_2.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/20_rs232_2.p)** <br/>
*Extended "RS232" Example* <br/>
Receives data via the RS232 interface and scans it for data frames that start with the character "+" and end either with a carriage return or line feed. If a complete data frame was received, a string is created that is composed as follows: "RS232Rx (<data frame received via RS232>) <number of characters of data frame> OK". This string is then issued via the console and the RS232 interface. <br/>
* **[20_rs232_3.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/20_rs232_3.p)** <br/>
*Extended "RS232" Example* <br/>
Receives data via the RS232 interface and scans it for data frames that start with the character "+" and end either with a carriage return or line feed. The received data is issued again immediately after receiving it via the RS232 interface. If a complete data frame was received, a string is created that is composed as follows: "RS232Rx (<data frame received via RS232>) <number of characters of data frame> OK". This string is then issued via the console and the RS232 interface. <br/>
* **[20_rs232_4.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/20_rs232_4.p)** <br/>
*Extended "RS232" Example* <br/>
Receives data via the RS232 interface and scans it for data frames that start with the character "+" and end either with a carriage return or line feed. The received data is issued again immediately after receiving it via the RS232 interface. If a complete data frame was received, a string is created that is composed as follows: "RS232Rx (<data frame received via RS232>) <number of characters of data frame> OK". This string is then issued via the console and the RS232 interface. <br/>
* **[30_System_Values_0.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/30_System_Values_0.p)** <br/>
*Simple "System Values" Example* <br/>
Reads the last valid values for Temp and RH from the system and issues them every second via the console <br/>
* **[30_System_Values_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/30_System_Values_1.p)** <br/>
*Extended "System Values" Example* <br/>
Reads the last valid values for Temp and RH periodically (record interval) from the system and stores the generated data record in the flash of the system. The measurement data generated this way is then transmitted periodically (transmission interval) to the server. <br/>
* **[30_System_Values_2.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/30_System_Values_2.p)** <br/>
*Extended "System Values" Example* <br/>
Reads the last valid values for Temp and RH periodically (record interval) from the system and stores the generated data record in the flash of the system. The measurement data generated this way is then transmitted periodically (transmission interval) to the server. The interval for recording and transmitting measurement data can be configured via the server. <br/>
* **[30_System_Values_3.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/30_System_Values_3.p)** <br/>
*Extended "System Values" Example* <br/>
Reads the last valid values for Temp and RH periodically (record interval) from the system and stores the generated data record in the flash of the system. The measurement data generated this way is then transmitted periodically (transmission interval) to the server. The interval for recording and transmitting measurement data as well as the transmission mode (interval, wakeup or online) can be configured via the server.
* **[30_ui_0.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/30_ui_0.p)** <br/>
*Simple "UI" Test application* <br/>
Demonstrates how to initialise UI channels and read out measurement values. <br/>
* **[30_ui_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/30_ui_1.p)** <br/>
*Extended "UI" Test application* <br/>
Reads the last valid values of all four UI channels periodically (record interval) and stores the generated data record in the flash of the system. The measurement data generated this way is then transmitted periodically (transmission interval) to the server.  <br/>
* **[30_ui_2.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/30_ui_2.p)** <br/>
*Extended "UI" Test application* <br/>
Reads the last valid values of all four UI channels periodically (record interval) and stores the generated data record in the flash of the system. The measurement data generated this way is then transmitted periodically (transmission interval) to the server. The interval for recording and transmitting measurement data can be configured via the server. <br/>
* **[30_ui_3.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/30_ui_3.p)** <br/>
*Extended "UI" Test application* <br/>
Reads the last valid values of all four UI channels periodically (record interval) and stores the generated data record in the flash of the system. The measurement data generated this way is then transmitted periodically (transmission interval) to the server. The interval for recording and transmitting measurement data as well as the transmission mode (interval, wakeup or online) can be configured via the server. <br/>
* **[40_charging.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/40_charging.p)** <br/>
*Simple "Changing Application" example* <br/>
 If a Power Supply Unit (PSU), which contains a rechargeable li-ion battery, is inserted into the myDatalogEASY V3 and the state of charge of the rechargeable battery is below 50% charging control is activated. The rechargeable battery is charged to the maximum voltage and the charge control is then deactivated again. If the state of charge of the rechargeable battery is above 50% the charging control is not activated and "Battery is fully charged" is indicated immediately. The current state of the charging control is displayed via the status LED (see blink codes below). <br/>
* **[50_filetransfer_receive.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/50_filetransfer_receive.p)** <br/>
*Simple "File transfer" Example* <br/>
Receives the file "RS232.txt" from the server and issues the data via RS2320. <br/>
* **[50_filetransfer_send.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/50_filetransfer_send.p)** <br/>
*Simple "File transfer" Example* <br/>
Sends data received via RS2320 to the server <br/>
* **[50_filetransfer_send_multiple.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/50_filetransfer_send_multiple.p)** <br/>
*Extended "File transfer" Example* <br/>
Simulates receiving a big file (Uart.txt) from e.g. UART and sends it to the server. <br/>
* **[60_statemachine_0.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/60_statemachine_0.p)** <br/>
*Simple "State machine" example* <br/>
The state machine has four different states that are indicated by the two colour LED <br/>
* **[60_statemachine_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/60_statemachine_1.p)** <br/>
*Simple "State machine" example* <br/>
The state machine has six different states that are indicated by the status LED. <br/>
* **[60_statemachine_2.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/60_statemachine_2.p)** <br/>
*Extended "State machine" example* <br/>
The state machine has seven different states that are indicated by the status LED. <br/>
* **[61_alarm_1.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/61_alarm_1.p)** <br/>
*Simple "Alarm" Example* <br/>
Simulates and records (record interval) a temperature value that changes between 19°C and 31°C in 1°C steps. The measurement data generated this way is then transmitted periodically (transmission interval) to the server. If the temperature exceeds 25°C, an alarm is triggered. Once an alarm has been triggered and the temperature falls below 25°C again, the alarm is released. In both cases (when triggering or releasing the alarm) an alarm record is generated and transmitted to the server immediately.<br/>
* **[61_alarm_2.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/61_alarm_2.p)** <br/>
*Extended "Alarm" Example* <br/>
Simulates and records (record interval) a temperature value that changes between 19°C and 31°C in 1°C steps. The measurement data generated this way is then transmitted periodically (transmission interval) to the server. If the temperature is greater than or equal to 25°C, an alarm is triggered. Once an alarm has been triggered and the temperature falls to or below 25°C - 5% (i.e. 23,75°C) again, the alarm is released. In both cases (when triggering or releasing the alarm) an alarm record is generated and transmitted to the server immediately. </br>
* **[61_alarm_3.p](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/61_alarm_3.p)** <br/>
*Extended "Alarm" Example* <br/>
Simulates and records (record interval) a temperature value that changes between 19°C and 31°C in 1°C steps. The measurement data generated this way is then transmitted periodically (transmission interval) to the server. If the temperature is greater than or equal to 25°C, an alarm is triggered. Once an alarm has been triggered and the temperature falls to or below 25°C - 5% (i.e. 23,75°C) again, the alarm is released. In both cases (when triggering or releasing the alarm) an alarm record is generated and transmitted to the server immediately. </br>
* **[Alarm.inc](https://github.com/Microtronics-rapidM2M/rapidM2M-Easy/blob/master/Examples/Basic_Examples_Collection/Alarm.inc)** <br/>
*Alarm interface functions* <br/>
Provides generic functions and constants for alarm implementation. <br/>

## rapidM2M Device API functions used in the examples 

Click on the name of the function to view in which example it is used.

### [Timer, date & time](http://support.microtronics.com/Developer_Documentation/Content/Developer_Documentation/sw/Pawn_rM2M_Time.htm)

<details>
<summary>**rM2M_GetTime(&hour=0, &minute=0, &second=0, timestamp=0)**</summary>
+ 50_filetransfer_send.p <br/>
+ 50_filetransfer_send_multiple.p <br/>
</details>

<details>
<summary>**rM2M_GetDate(&year=0, &month=0, &day=0, timestamp=0)**</summary>
+ 50_filetransfer_send.p  <br/>
</details>

<details>
<summary>**rM2M_GetDateTime(datetime[TrM2M_DateTime])**</summary>
+ 00_common_7_conditional.p <br/>
</details>

<details>
<summary>**rM2M_TimerAdd(funcidx)**</summary>
+ 00_common_1_Timer_1.p<br/> 
+ 11_Led_2.p<br/>  
+ 11_Led_2_3.p<br/>  
+ 11_Status_Led_1.p <br/>  
+ 11_Status_Led_rgb_v1.p <br/>
+ 11_Status_Led_rgb_v2.p <br/>
+ 12_Transmission_2_cyclic_connection.p<br/>  
+ 12_Transmission_3_ForceOnline.p<br/>  
+ 13_Transmission_Status_Led_0.p<br/>  
+ 13_Transmission_Status_Led_1.p<br/> 
+ 13_Transmission_Status_Led_2.p<br/> 
+ 20_rs232_1.p<br/>  
+ 30_ui_0<br/>  
+ 30_ui_1.p<br/>  
+ 30_ui_2.p<br/>
+ 30_ui_3.p<br/>
+ 31_i2c_sht21_0.p<br/>
+ 31_i2c_sht21_1.p<br/>
+ 31_i2c_sht21_2.p  <br/>
+ 31_i2c_tmp112_0.p<br/>
+ 31_i2c_tmp112_1.p<br/>
+ 31_i2c_tmp112_2.p<br/>
+ 40_charging.p<br/>   
+ 60_statemachine_1.p<br/>  
+ 60_statemachine_2.p<br/>  
+ 61_alarm_1.p<br/>  
+ 61_alarm_2.p<br/>  
+ 61_alarm_3.p<br/>
</details>


<details>
<summary>**rM2M_TimerRemove(funcidx)**</summary>
+ 10_Switch_Long.p<br/>
</details>

<details>
<summary>**rM2M_TimerAddExt(funcidx, bool:cyclic, time)**</summary>
+ 00_common_1_Timer_1.p<br/>
+ 00_common_1_Timer_2.p<br/>  
+ 10_Switch_Long.p<br/>
+ 11_Led_2.p<br/>
+ 11_Led_2_3.p<br/>
+ 11_Status_Led_1.p <br/>
+ 11_Status_Led_and_Input_0.p <br/>
+ 11_Status_Led_and_Input_1.p <br/>
+ 11_Status_Led_rgb_v1.p<br/>
+ 11_Status_Led_rgb_v2.p<br/>
+ 50_filetransfer_receive.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
+ 60_statemachine_0.p<br/>
</details>

<details>
<summary>**rM2M_TimerRemoveExt(funcidx)**</summary>
+ 10_Switch_Long.p<br/>
</details>

### [Uplink](http://support.microtronics.com/Developer_Documentation/Content/Developer_Documentation/sw/Pawn_rM2M_Uplink.htm)

<details>
<summary>**rM2M_TxStart(flags=0)**</summary>
+ 12_Transmission_0.p<br/>
+ 12_Transmission_2_cyclic_connection.p<br/>
+ 12_Transmission_3_ForceOnline.p<br/>>
+ 13_Transmission_Status_Led_0.p<br/>
+ 13_Transmission_Status_Led_1.p<br/>
+ 13_Transmission_Status_Led_2.p<br/>
+ 30_System_Values_1.p<br/>
+ 30_System_Values_2.p<br/>
+ 30_System_Values_3.p<br/>
+ 30_ui_1.p<br/>
+ 30_ui_2.p<br/>
+ 30_ui_3.p<br/>
+ 40_charging.p<br/>
+ 61_alarm_1.p<br/>
+ 61_alarm_2.p<br/>
+ 61_alarm_3.p<br/>
</details>

<details>
<summary>**rM2M_TxSetMode(mode, flags=0)**</summary>
+ 12_Transmission_3_ForceOnline.p<br/>
+ 13_Transmission_Status_Led_0.p<br/>
+ 13_Transmission_Status_Led_1.p<br/>
+ 13_Transmission_Status_Led_2.p<br/>
+ 30_System_Values_2.p<br/>
+ 30_System_Values_3.p<br/>
+ 30_ui_3.p <br/>
+ 40_charging.p <br/>
+ 50_filetransfer_receive.p<br/>
+ 50_filetransfer_send.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
</details>

<details>
<summary>**rM2M_TxGetStatus(&errorcode=0)**</summary>
+ 12_Transmission_3_ForceOnline.p<br/> 
+ 13_Transmission_Status_Led_0.p<br/>
+ 13_Transmission_Status_Led_1.p<br/>
+ 13_Transmission_Status_Led_2.p<br/>
</details>

<details>
<summary>**rM2M_RecData(timestamp, const data{}, len)**</summary>
+ 30_System_Values_1.p<br/>
+ 30_System_Values_2.p<br/>
+ 30_System_Values_3.p<br/>
+ 30_ui_1.p<br/>
+ 30_ui_2.p<br/>
+ 30_ui_3.p<br/>
+ 61_alarm_1.p<br/>
+ 61_alarm_2.p<br/>
+ 61_alarm_3.p<br/>
+ Alarm.inc <br/>
</details>

<details>
<summary>**rM2M_CfgRead(cfg, pos, data{}, size)**</summary>
+ 30_System_Values_2.p<br/>
+ 30_System_Values_3.p<br/>
+ 30_ui_2.p<br/>
+ 30_ui_3.p<br/>
</details>

<details>
<summary>**rM2M_CfgOnChg(funcidx)**</summary>
+ 30_System_Values_2.p<br/>
+ 30_System_Values_3.p<br/>
+ 30_ui_2.p<br/>
+ 30_ui_3.p<br/>
</details>

### [Encoding](http://support.microtronics.com/Developer_Documentation/Content/Developer_Documentation/sw/Pawn_rM2M_Encoding.htm)

<details>
<summary>**rM2M_SetPackedB(data{}, pos, const block[], size)**</summary>
+ 50_filetransfer_receive.p <br/>
+ 50_filetransfer_send.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
</details>

<details>
<summary>**rM2M_GetPackedB(const data{}, pos, block[], size)**</summary>
+ 50_filetransfer_receive.p <br/>
</details>

<details>
<summary>**rM2M_Pack(const data{}, pos, &{Float,Fixed,_}:value, type)**</summary>
+ 00_common_4_pack.p <br/> 
+ 30_System_Values_1.p<br/>
+ 30_System_Values_2.p<br/>
+ 30_System_Values_3.p<br/>
+ 30_ui_1.p<br/>
+ 30_ui_2.p<br/>
+ 30_ui_3.p<br/>
+ 50_filetransfer_receive.p <br/>
+ 61_alarm_1.p<br/>
+ 61_alarm_2.p<br/>
+ 61_alarm_3.p<br/>
+ Alarm.inc <br/>
</details>

### [Char & String](http://support.microtronics.com/Developer_Documentation/Content/Developer_Documentation/sw/Pawn_Erweiterungen_String_Funktionen.htm)

<details>
<summary>**strlen(const string[])**</summary>
+ 50_filetransfer_send_multiple.p<br/>
</details>

<details>
<summary>**sprintf(dest[], maxlength=sizeof dest, const format[], {Float,Fixed,_}:...)**</summary>
+ 20_rs232_2.p<br/>
+ 20_rs232_3.p<br/>
+ 20_rs232_4.p<br/>
+ 50_filetransfer_send.p<br/>
</details>

<details>
<summary>**strcmp(const string1[], const string2[], length=cellmax)**</summary>
+ 20_rs232_3.p<br/>
+ 20_rs232_4.p<br/>
</details>

### [Various](http://support.microtronics.com/Developer_Documentation/Content/Developer_Documentation/sw/Pawn_Erweiterungen_Hilfsfunktionen.htm)

<details>
<summary>**getapilevel()**</summary>
+ 00_common_2_get_module_info.p<br/>
</details>

<details>
<summary>**CRC32(data{}, len, initial=0)**</summary>
+ 50_filetransfer_receive.p <br/>
+ 50_filetransfer_send.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
</details>

<details>
<summary>**rM2M_GetId(id[TrM2M_Id], len=sizeof id)**</summary>
+ 00_common_2_get_module_info.p<br/>
</details>

<details>
<summary>**funcidx(const name[])**</summary>
+ 00_common_1_Timer_1.p<br/>
+ 00_common_1_Timer_2.p<br/> 
+ 10_Switch.p<br/>
+ 10_Switch_Long.p<br/>
+ 11_Led_2.p<br/>
+ 11_Led_2_3.p<br/>
+ 11_Status_Led_1.p <br/> 
+ 11_Status_Led_and_Button_0.p <br/>   
+ 11_Status_Led_and_Button_1.p <br/>  
+ 11_Status_Led_and_Input_0.p <br/>   
+ 11_Status_Led_and_Input_1.p <br/>  
+ 11_Status_Led_rgb_v1.p<br/>
+ 11_Status_Led_rgb_v2.p<br/>
+ 12_Transmission_2_cyclic_connection.p<br/>
+ 12_Transmission_3_ForceOnline.p<br/>
+ 13_Transmission_Status_Led_0.p <br/>
+ 13_Transmission_Status_Led_1.p <br/>
+ 13_Transmission_Status_Led_2.p <br/>
+ 20_rs232_1.p<br/>
+ 20_rs232_2.p<br/>
+ 20_rs232_3.p<br/>
+ 20_rs232_4.p<br/>
+ 30_System_Values_0.p<br/>
+ 30_System_Values_1.p<br/>
+ 30_System_Values_2.p<br/>
+ 30_System_Values_3.p<br/>
+ 30_ui_1.p<br/>
+ 30_ui_2.p<br/>
+ 30_ui_3.p<br/>
+ 40_charging.p<br/>
+ 50_filetransfer_receive.p <br/>
+ 50_filetransfer_send.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
+ 60_statemachine_0.p<br/>  
+ 60_statemachine_1.p<br/>
+ 60_statemachine_2.p<br/>
+ 61_alarm_1.p<br/>
+ 61_alarm_2.p<br/>
+ 61_alarm_3.p<br/>
</details>

### [Console](http://support.microtronics.com/Developer_Documentation/Content/Developer_Documentation/sw/Pawn_Erweiterungen_Consolen_Funktionen.htm)

<details>
<summary>**print(const string[])**</summary>
+ 00_common_0_Main.p<br/>
+ 00_common_7_conditional.p<br/>
+ 00_common_8_loop.p<br/>
+ 10_Switch_Long.p<br/>
+ 13_Transmission_Status_Led_0.p <br/>
+ 13_Transmission_Status_Led_1.p <br/>
+ 13_Transmission_Status_Led_2.p <br/>
+ 20_rs232_2.p<br/>
+ 20_rs232_3.p<br/>
+ 20_rs232_4.p<br/>
+ 30_System_Values_1.p<br/>
+ 30_System_Values_2.p<br/>
+ 30_System_Values_3.p<br/>
+ 30_ui_1.p<br/>
+ 30_ui_2.p<br/>
+ 30_ui_3.p<br/>
+ 40_charging.p <br/>
+ 60_statemachine_0.p<br/>  
+ 61_alarm_1.p<br/>
+ 61_alarm_2.p<br/>
+ 61_alarm_3.p<br/>
</details>

<details>
<summary>**printf(const format[], {Float,Fixed,_}:...)**</summary>
+ 00_common_1_Timer_1.p<br/>
+ 00_common_1_Timer_2.p<br/> 
+ 00_common_2_get_module_info.p<br/>
+ 00_common_3_NamedArray.p<br/> 
+ 00_common_4_pack.p<br/> 
+ 00_common_5_data_types.p<br/>
+ 00_common_6_array.p<br/>
+ 00_common_8_loop.p<br/>
+ 10_Switch.p<br/>
+ 10_Switch_Long.p<br/> 
+ 11_Led_2.p<br/>
+ 11_Led_2_3.p<br/>
+ 11_Led_rgb_v1.p<br/>
+ 11_Led_rgb_v2.p<br/>
+ 11_Status_Led_1.p <br/> 
+ 11_Status_Led_and_Button_0.p <br/>   
+ 11_Status_Led_and_Button_1.p <br/>  
+ 11_Status_Led_and_Input_0.p <br/>   
+ 11_Status_Led_and_Input_1.p <br/>  
+ 11_Status_Led_rgb_v1.p<br/>
+ 11_Status_Led_rgb_v2.p<br/>
+ 12_Transmission_0.p<br/>
+ 12_Transmission_2_cyclic_connection.p<br/>
+ 12_Transmission_3_ForceOnline.p<br/>
+ 13_Transmission_Status_Led_0.p <br/>
+ 13_Transmission_Status_Led_1.p <br/>
+ 13_Transmission_Status_Led_2.p <br/>
+ 20_rs232_1.p<br/>
+ 20_rs232_2.p<br/>
+ 20_rs232_3.p<br/>
+ 20_rs232_4.p<br/>
+ 30_System_Values_0.p<br/>
+ 30_System_Values_1.p<br/>
+ 30_System_Values_2.p<br/>
+ 30_System_Values_3.p<br/>
+ 30_ui_0.p<br/>
+ 30_ui_1.p<br/>
+ 30_ui_2.p<br/>
+ 30_ui_3.p<br/>
+ 40_charging.p<br/>
+ 50_filetransfer_receive.p <br/>
+ 50_filetransfer_send.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
+ 60_statemachine_0.p<br/> 
+ 60_statemachine_1.p<br/>
+ 60_statemachine_2.p<br/>
+ 61_alarm_1.p<br/>
+ 61_alarm_2.p<br/>
+ 61_alarm_3.p<br/>
</details>

### [File Transfer](https://support.microtronics.com/Developer_Documentation/Content/Developer_Documentation/sw/Pawn_Erweiterungen_File_Transfer_Funktionen.htm)

<details>
<summary>**FT_Register(const name{}, id, funcidx)**</summary>
+ 50_filetransfer_receive.p <br/>
+ 50_filetransfer_send.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
</details>

<details>
<summary>**FT_Unregister(id)**</summary>
+ 50_filetransfer_send.p<br/>
</details>

<details>
<summary>**FT_SetPropsExt(id, props[TFT_Info], len=sizeof props)**</summary>
+ 50_filetransfer_receive.p <br/>
+ 50_filetransfer_send.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
</details>

<details>
<summary>**FT_Read(id, const data{}, len)**</summary>
+ 50_filetransfer_send.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
</details>

<details>
<summary>**FT_Accept(id, newid=-1)**</summary>
+ 50_filetransfer_receive.p <br/>
</details>

<details>
<summary>**FT_Written(id, len)**</summary>
+ 50_filetransfer_receive.p <br/>
</details>

<details>
<summary>**FT_Error(id)**</summary>
+ 50_filetransfer_receive.p <br/>
+ 50_filetransfer_send.p<br/>
+ 50_filetransfer_send_multiple.p<br/>
</details>