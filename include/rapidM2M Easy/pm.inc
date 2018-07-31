/**
 * PowerManagement module
 *
 * Includes functions to control charging, backup and retrieval of
 * actual power related values.
 */
#pragma library PM

/**
 * <summary>
 *   Charger Modes.
 * </summary>
 */
const
{
  PM_CHARGING_OFF = 0,   /* no charging */
  PM_CHARGING_NORMAL,    /* charging if SOC < 50 % */
  PM_CHARGING_SOLAR,     /* charge whenever it is possible and input voltage is high enough 
                            (start charging not untill 12h after last full charging or SOC < 95%) */
  PM_CHARGING_FORCED,    /* start charging independent from SOC 
                            ATTENTION: this mode is for service only and could damage accu! */
};

/**
 * <summary>
 *   Init Charging mode.
 * </summary>
 *
 * <param name="mode">
 *   Charger mode (see Charger Modes).
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> in case of invalid parameter.
 * </returns>
 */
native PM_SetChargingMode(mode);

/**
 * <summary>
 *   Init and configure backup functionality.
 * </summary>
 *
 * <param name="funcidx">
 *   Index of backup function, which gets called when backup is activated.
 *   Has to be of type: public func();
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> in case of invalid parameter.
 * </returns>
 */
native PM_BackupInit(funcidx);

/**
 * <summary>
 *   Close and deactivates backup functionality.
 * </summary>
 *
 * <returns>
 *   <em>OK</em>.
 * </returns>
 */
native PM_BackupClose();

/**
 * <summary>
 *   PM Battery types.
 * </summary>
 */
const
{
  PM_BATT_TYPE_NONE = 0,  /* no battery or external power supply */
  PM_BATT_TYPE_NORMAL,    /* normal battery, only discharging */
  PM_BATT_TYPE_LIIO,      /* LiIo akku pack */
};

/**
 * <summary>
 *   PM Flags.
 * </summary>
 */
const
{
  PM_FLAG_CHARGING   = 0x00000001, /* charging active */
  PM_FLAG_BACKUP     = 0x00000002, /* backup active (only if backup functionality is activated) */
  PM_FLAG_AKKU_ERROR = 0x00000004, /* set if different akkus are present */
  PM_FLAG_ERROR      = 0x00000008, /* set if error in PM (no loading, no SOC calculation), f.e. E2Prom of akku could not read */
};

/**
 * <summary>
 *   PM Coulomb counter.
 * </summary>
 */
const
{
  PM_CC_RESET   = 0x00000001, /* reset coulomb counter */
};

/**
 * <summary>
 *   PM info structure.
 * </summary>
 *
 * <param name="BatteryType">
 *   see PM Battery types.
 * </param>
 * <param name="Flags">
 *   see PM Flags.
 * </param>
 * <param name="VIn">
 *   Input Voltage [mV]
 * </param>
 * <param name="VBatt">
 *   Battery voltage [mV]
 * </param>
 * <param name="SOC">
 *   State of Charge [0,01%].
 * </param>
 * <param name="PIn">
 *   Input Power [mW]
 * </param>
 * <param name="ChargingMode">
 *   see Charger Modes
 * </param>
 * <param name="Description{">
 *   Description of battery
 * </param>
 */
#define TPM_Info[.BatteryType, .Flags, .VIn, .VBatt, .SOC, .PIn, .ChargingMode, .Description{16}]

/**
 * <summary>
 *   Get common PM information
 * </summary>
 *
 * <param name="info">
 *   Structure where PM information is filled in (see TPM_Info).
 * </param>
 *
 * <param name="len">
 *   length of structure to be filled.
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> in case of invalid parameter.
 * </returns>
 */
native PM_GetInfo(info[TPM_Info], len=sizeof info);

/**
 * <summary>
 *   Get coulomb counter
 * </summary>
 *
 * <param name="flags">
 *   Flags (see PM Coulomb counter).
 * </param>
 *
 * <returns>
 *   Coulomb counter [mAs].
 * </returns>
 */
native PM_GetCoulombCounter(flags=0);
