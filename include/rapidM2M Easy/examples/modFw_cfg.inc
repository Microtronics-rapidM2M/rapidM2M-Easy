/**
 * <summary>
 *   User Configuration File for 'modfw.inc'
 * </summary>
 */
#define HAVE_MODFW_CFG

/* Uncomment to activate detailed debug output */
// #define MODFW_DEBUG

/** Number of entries within command queue due to asynchronous communication */
#define MODFW_LEN_CMD_QUEUE   (10)

/** Size of Read Buffer */
#define MODFW_LEN_READ_BUFFER (4096)

/** Bytelength max. for INFO tag */
#define MODFW_INFO_MAXLEN     (64)

/**
 * Following section contains all available Callback Functions.
 * To disable a specific callback function, line must be commented //
 */

/**
 * <summary>
 *   MODFW_INFO_CB(hModFw, szInfoInstalled{}, szInfoUpdate{})
 *   Function is called if INFO tag was read.
 * </summary>
 *
 * <param name="hModFw">
 *   Handle for assigning modFw
 * </param>
 * <param name="szInfoInstalled">
 *   Info/ID string currently installed
 * </param>
 * <param name="szInfoUpdate">
 *   Info string available within updatefile
 * </param>
 */
#define MODFW_INFO_CB              ModFw_InfoCallback

/**
 * <summary>
 *   MODFW_READ_TAG_CB(hModFw, iTag, iOfs, aData, iResult)
 *   Function is called if TAG read operation has finished.
 * </summary>
 *
 * <param name="hModFw">
 *   Handle for assigning modFw
 * </param>
 * <param name="iTag">
 *   TAG that was read
 * </param>
 * <param name="iOfs">
 *   Byte-Offset within TAG data field
 * </param>
 * <param name="aData">
 *   Data Buffer
 * </param>
 * <param name="iResult">
 *   Number of bytes available within Data Buffer
 * </param>
 */
//#define MODFW_READ_TAG_CB             ModFw_ReadTagCallback

/**
 * <summary>
 *   MODFW_READ_TAGLEN_CB(hModFw, iTag, iResult)
 *   Function is called if TAG read operation (only length) has finished.
 * </summary>
 *
 * <param name="hModFw">
 *   Handle for assigning modFw
 * </param>
 * <param name="iTag">
 *   TAG that was read
 * </param>
 * <param name="iResult">
 *   Number of bytes available within TAG data field
 * </param>
 */
//#define MODFW_READ_TAGLEN_CB           ModFw_ReadTagLenCallback

/**
 * <summary>
 *   MODFW_VERIFYCRC_CB(hModFw, iResult)
 *   Function is called if CRC verification has finished.
 * </summary>
 *
 * <param name="hModFw">
 *   Handle for assigning modFw
 * </param>
 * <param name="iResult">
 *   <em>OK</em> if CRC's match, otherwise <em>ERROR</em>
 * </param>
 */
#define MODFW_VERIFYCRC_CB               ModFw_VerifyCrcCallback
