/**
 * <summary>
 *   User Configuration File for 'ble_app_scanner.inc'
 * </summary>
 */
#define HAVE_BLE_APP_SCANNER_CFG

/* Uncomment to activate detailed debug output */
#define BLEAPP_DEBUG

/** Size of Line Buffer */
#define BLEAPP_LINE_SIZE (100)

/**
 * Following section contains all available Callback Functions.
 * To disable a specific callback function, line must be commented //
 */

/**
 * <summary>
 *   BLEAPP_DEVICE_SCANNED(sScan[TBLE_Scan])
 *   Function is called if SCAN response is available.
 * </summary>
 *
 * <param name="sScan">
 *   Scan results (TBLE_Scan)
 * </param>
 */
#define BLEAPP_DEVICE_SCANNED         BleApp_DeviceScannedCallback


/**
 * <summary>
 *   BLE_DEVICE_NOTIFY(handle, data{}, len)
 *   Function is called if NOTIFY response was received.
 * </summary>
 *
 * <param name="handle">
 *   BLE handle
 * </param>
 * <param name="data">
 *   Notify response
 * </param>
 * <param name="len">
 *   Number of bytes within response buffer
 * </param>
 */
// #define BLE_DEVICE_NOTIFY             BleApp_DeviceNotifyCallback

/**
 * <summary>
 *   BLE_DEVICE_READ(handle, offset, data{}, len)
 *   Function is called if READ response was received.
 * </summary>
 *
 * <param name="handle">
 *   BLE handle
 * </param>
 * <param name="offset">
 *   Read Offset
 * </param>
 * <param name="data">
 *   Notify response
 * </param>
 * <param name="len">
 *   Number of bytes within data buffer
 * </param>
 */
// #define BLE_DEVICE_READ                  BleApp_DeviceReadCallback

