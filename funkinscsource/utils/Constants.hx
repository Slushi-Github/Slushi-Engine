package utils;

import flixel.util.FlxColor;
import lime.app.Application;

/**
 * A store of unchanging, globally relevant values.
 */
class Constants
{
  /**
   * ENGINE AND VERSION DATA
   */
  // ==============================

  /**
   * The title of the game, for debug printing purposes.
   * Change this if you're making an engine.
   */
  public static final TITLE:String = "Friday Night Funkin'";

  /**
   * The current version number of the game.
   * Modify this in the `project.xml` file.
   */
  public static var VERSION(get, never):String;

  /**
   * The generatedBy string embedded in the chart files made by this application.
   */
  public static var GENERATED_BY(get, never):String;

  static function get_GENERATED_BY():String
  {
    return '${Constants.TITLE} - ${Constants.VERSION}';
  }

  /**
   * A suffix to add to the game version.
   * Add a suffix to prototype builds and remove it for releases.
   */
  public static final VERSION_SUFFIX:String = #if (DEBUG || FORCE_DEBUG_VERSION) ' PROTOTYPE' #else '' #end;

  static function get_VERSION():String
  {
    return 'v${Application.current.meta.get('version')}' + VERSION_SUFFIX;
  }

  /**
   * GAME DEFAULTS
   */
  // ==============================

  /**
   * Default player character for charts.
   */
  public static final DEFAULT_CHARACTER:String = 'bf';

  /**
   * Default player character for health icons.
   */
  public static final DEFAULT_HEALTH_ICON:String = 'face';

  /**
   * Default stage for charts.
   */
  public static final DEFAULT_STAGE:String = 'mainStage';

  /**
   * Default song for if the PlayState messes up.
   */
  public static final DEFAULT_SONG:String = 'tutorial';

  /**
   * The default BPM for charts, so things don't break if none is specified.
   */
  public static final DEFAULT_BPM:Float = 100.0;

  /**
   * The default name for songs.
   */
  public static final DEFAULT_SONGNAME:String = 'Unknown';

  /**
   * The default artist for songs.
   */
  public static final DEFAULT_ARTIST:String = 'Unknown';

  /**
   * The default charter for songs.
   */
  public static final DEFAULT_CHARTER:String = 'Unknown';

  /**
   * TIMING
   */
  // ==============================

  /**
   * Constant for the number of seconds in a minute.
   *
   * sex per min
   */
  public static final SECS_PER_MIN:Int = 60;

  /**
   * Constant for the number of milliseconds in a second.
   */
  public static final MS_PER_SEC:Int = 1000;

  /**
   * The number of microseconds in a millisecond.
   */
  public static final US_PER_MS:Int = 1000;

  /**
   * The number of microseconds in a second.
   */
  public static final US_PER_SEC:Int = US_PER_MS * MS_PER_SEC;

  /**
   * The number of nanoseconds in a microsecond.
   */
  public static final NS_PER_US:Int = 1000;

  /**
   * The number of nanoseconds in a millisecond.
   */
  public static final NS_PER_MS:Int = NS_PER_US * US_PER_MS;

  /**
   * The number of nanoseconds in a second.
   */
  public static final NS_PER_SEC:Int = NS_PER_US * US_PER_MS * MS_PER_SEC;

  /**
   * Duration, in milliseconds, until toast notifications are automatically hidden.
   */
  public static final NOTIFICATION_DISMISS_TIME:Int = 5 * MS_PER_SEC;

  /**
   * Duration to wait before autosaving the chart.
   */
  public static final AUTOSAVE_TIMER_DELAY_SEC:Float = 5.0 * SECS_PER_MIN;

  /**
   * Number of steps in a beat.
   * One step is one 16th note and one beat is one quarter note.
   */
  public static final STEPS_PER_BEAT:Int = 4;

  /**
   * All MP3 decoders introduce a playback delay of `528` samples,
   * which at 44,100 Hz (samples per second) is ~12 ms.
   */
  public static final MP3_DELAY_MS:Float = 528 / 44100 * Constants.MS_PER_SEC;

  /**
   * The maximum number of previous file paths for the Chart Editor to remember.
   */
  public static final MAX_PREVIOUS_WORKING_FILES:Int = 10;

  /**
   * The separator between an asset library and the asset path.
   */
  public static final LIBRARY_SEPARATOR:String = ':';
}
