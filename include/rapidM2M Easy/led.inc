/**
 * Led functions
 */
#pragma library Led

/**
 * <summary>
 *   Led Modes.
 * </summary>
 */
const
{
  LED_MODE_INTERNAL = 0, // led's are controlled by FW
  LED_MODE_SCRIPT,       // led's are controlled by Script
};

/**
 * <summary>
 *   Init Led usage.
 * </summary>
 *
 * <param name="mode">
 *   Led mode (see Led Modes).
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> in case of invalid parameters.
 * </returns>
 */
native Led_Init(mode);

/**
 * <summary>
 *   Close Led usage (neither FW nor Script control led's).
 * </summary>
 *
 * <returns>
 *   <em>OK</em>.
 * </returns>
 */
native Led_Close();

/**
 * <summary>
 *   Turn on led's.
 * </summary>
 *
 * <param name="red">
 *   Red led on if true.
 * </param>
 * <param name="green">
 *   Green led on if true.
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> in case of invalid parameters.
 * </returns>
 */
native Led_On(bool:red, bool:green);

/**
 * <summary>
 *   Turn off led's.
 * </summary>
 *
 * <param name="red">
 *   Red led off if true.
 * </param>
 * <param name="green">
 *   Green led off if true.
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> in case of invalid parameters.
 * </returns>
 */
native Led_Off(bool:red, bool:green);

/**
 * <summary>
 *   Blink with led's (500ms On, 500ms Off).
 * </summary>
 *
 * <param name="red">
 *   Red led blink count or forever if 0 (-1 if not used).
 * </param>
 * <param name="green">
 *   Green led blink count or forever if 0 (-1 if not used).
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> in case of invalid parameters.
 * </returns>
 */
native Led_Blink(red, green);

/**
 * <summary>
 *   Flash with led's (500ms period, single flash On).
 * </summary>
 *
 * <param name="red">
 *   Red led flash count or forever if 0 (-1 if not used).
 * </param>
 * <param name="green">
 *   Green led flash count or forever if 0 (-1 if not used).
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> in case of invalid parameters.
 * </returns>
 */
native Led_Flash(red, green);

/**
 * <summary>
 *   Flicker with led
 * </summary>
 *
 * <param name="red">
 *   Red led flicker count or forever if 0 (-1 if not used).
 * </param>
 * <param name="green">
 *   Green led flicker count or forever if 0 (-1 if not used).
 * </param>
 *
 * <returns>
 *   <em>OK</em> if successful, <em>ERROR</em> in case of invalid parameters.
 * </returns>
 */
native Led_Flicker(red, green);

