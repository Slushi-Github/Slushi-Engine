package backend;

import lime.app.Application;
import flixel.system.debug.log.LogStyle;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import haxe.Log;
import haxe.PosInfos;
import flixel.util.FlxStringUtil;

/**
 * Credit to boloVevo for this is his class from his custom kadeEngine!
 *
 * Hey you, developer!
 * This class contains lots of utility functions for logging and debugging.
 * The goal is to integrate development more heavily with the HaxeFlixel debugger.
 * Use these methods to the fullest to produce mods efficiently!
 * @see https://haxeflixel.com/documentation/debugger/
 * @see https://github.com/BoloVEVO/Kade-Engine/tree/develop
 */
class Debug
{
  static final LOG_STYLE_ERROR:LogStyle = new LogStyle('[ERROR] ', 'FF8888', 12, true, false, false, 'flixel/sounds/beep', true);
  static final LOG_STYLE_WARN:LogStyle = new LogStyle('[WARN] ', 'D9F85C', 12, true, false, false, 'flixel/sounds/beep', true);
  static final LOG_STYLE_INFO:LogStyle = new LogStyle('[INFO] ', '5CF878', 12, false);
  static final LOG_STYLE_TRACE:LogStyle = new LogStyle('[TRACE] ', '5CF878', 12, false);

  static var logFileWriter:DebugLogWriter = null;

  /**
   * Log an error message to the game's console.
   * Plays a beep to the user and forces the console open if this is a debug build.
   * @param input The message to display.
   * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
   */
  public static inline function logError(input:Dynamic, ?pos:haxe.PosInfos):Void
  {
    if (input == null) return;
    var output = formatOutput(input, pos);
    writeToFlxGLog(output, LOG_STYLE_ERROR);
    writeToLogFile(output, 'ERROR');
  }

  /**
   * Log an warning message to the game's console.
   * Plays a beep to the user and forces the console open if this is a debug build.
   * @param input The message to display.
   * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
   */
  public static inline function logWarn(input:Dynamic, ?pos:haxe.PosInfos):Void
  {
    if (input == null) return;
    var output = formatOutput(input, pos);
    writeToFlxGLog(output, LOG_STYLE_WARN);
    writeToLogFile(output, 'WARN');
  }

  /**
   * Log an info message to the game's console. Only visible in debug builds.
   * @param input The message to display.
   * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
   */
  public static inline function logInfo(input:Dynamic, ?pos:haxe.PosInfos):Void
  {
    if (input == null) return;
    var output = formatOutput(input, pos);
    writeToFlxGLog(output, LOG_STYLE_INFO);
    writeToLogFile(output, 'INFO');
  }

  /**
   * Log a debug message to the game's console. Only visible in debug builds.
   * NOTE: We redirect all Haxe `Debug.logTrace()` calls to this function.
   * @param input The message to display.
   * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
   */
  public static function logTrace(input:Dynamic, ?pos:haxe.PosInfos):Void
  {
    #if debug
    if (input == null) return;
    var output = formatOutput(input, pos);
    writeToLogFile(output, 'TRACE');
    #end
  }

  /**
   * Displays a popup with the provided text.
   * This interrupts the game, so make sure it's REALLY important.
   * @param title The title of the popup.
   * @param description The description of the popup.
   */
  public static function displayAlert(title:String, description:String):Void
  {
    Application.current.window.alert(description, title);
  }

  /**
   * Display the value of a particular field of a given object
   * in the Debug watch window, labelled with the specified name.
       * Updates continuously.
   * @param object The object to watch.
   * @param field The string name of a field of the above object.
   * @param name
   */
  public static inline function watchVariable(object:Dynamic, field:String, name:String):Void
  {
    #if debug
    if (object == null)
    {
      Debug.logError("Tried to watch a variable on a null object!");
      return;
    }
    FlxG.watch.add(object, field, name == null ? field : name);
    #end
    // Else, do nothing outside of debug mode.
  }

  /**
   * Adds the specified value to the Debug Watch window under the current name.
   * A lightweight alternative to watchVariable, since it doesn't update until you call it again.
   *
   * @param value
   * @param name
   */
  public inline static function quickWatch(value:Dynamic, name:String)
  {
    #if debug
    FlxG.watch.addQuick(name == null ? "QuickWatch" : name, value);
    #end
    // Else, do nothing outside of debug mode.
  }

  /**
   * The Console window already supports most hScript, meaning you can do most things you could already do in Haxe.
       * However, you can also add custom commands using this function.
   */
  public inline static function addConsoleCommand(name:String, callbackFn:Dynamic)
  {
    FlxG.console.registerFunction(name, callbackFn);
  }

  /**
   * Add an object with a custom alias so that it can be accessed via the console.
   */
  public inline static function addObject(name:String, object:Dynamic)
  {
    FlxG.console.registerObject(name, object);
  }

  /**
   * Create a tracker window for an object.
   * This will display the properties of that object in
   * a fancy little Debug window you can minimize and drag around.
   *
   * @param obj The object to display.
   */
  public inline static function trackObject(obj:Dynamic)
  {
    if (obj == null)
    {
      Debug.logError("Tried to track a null object!");
      return;
    }
    FlxG.debugger.track(obj);
  }

  /**
   * The game runs this function immediately when it starts.
       * Use onGameStart() if it can wait until a little later.
   */
  public static function onInitProgram()
  {
    // Initialize logging tools.
    Debug.logTrace('Initializing Debug tools...');

    // Override Haxe's vanilla Debug.logTrace() calls to use the Flixel console.
    Log.trace = function(data:Dynamic, ?info:PosInfos) {
      var paramArray:Array<Dynamic> = [data];

      if (info != null)
      {
        if (info.customParams != null)
        {
          for (i in info.customParams)
          {
            paramArray.push(i);
          }
        }
      }

      logTrace(paramArray, info);
    };

    // Start the log file writer.
    // We have to set it to TRACE for now.
    logFileWriter = new DebugLogWriter("TRACE");

    logInfo("Debug logging initialized. Hello, developer.");

    var buildType:String = #if debug "DEBUG" #elseif release "RELEASE" #else "COMPLIED" #end;
    logInfo("This is a " + buildType + " build.");
    #if !web
    logInfo('Operating System: ${Sys.systemName()}');
    #end
    logInfo('Haxe Version: ' + haxe.macro.Compiler.getDefine("haxe"));
    logInfo('HaxeFlixel version: ${Std.string(FlxG.VERSION)}');
    logInfo('Friday Night Funkin\' version: 0.4');
    logInfo('SC Engine version: ${states.MainMenuState.SCEVersion}');
    logInfo('This is a custom build of PE. Current version: ${states.MainMenuState.psychEngineVersion}');
  }

  /**
   * The game runs this function when it starts, but after Flixel is initialized.
   */
  public static function onGameStart()
  {
    // Add the mouse position to the debug Watch window.
    FlxG.watch.addMouse();

    defineConsoleCommands();

    // Now we can remember the log level.
    if (FlxG.save.data.debugLogLevel == null) FlxG.save.data.debugLogLevel = "TRACE";

    logFileWriter.setLogLevel(FlxG.save.data.debugLogLevel);
    logInfo('Current Build Version: ' + flixel.FlxG.game.stage.application.meta["build"]);
  }

  public static function clearLogsFolder()
  {
    #if FEATURE_FILESYSTEM
    var logFilePath = 'logs/${Sys.time()}.log';
    var lastIndex:Int = logFilePath.lastIndexOf("/");
    var logFolderPath:String = logFilePath.substr(0, lastIndex);
    var files = FileSystem.readDirectory(logFolderPath); // Reading all logs in an array.

    for (file in files)
    {
      // To not consider the last one that is the current log text the game is writing to avoid crashes
      if (files.indexOf(file) != files.length - 1) FileSystem.deleteFile('$logFolderPath/$file'); // Deleting each one from the log directory.
    }

    logInfo('Cleared logs folder.');
    #else
    return;
    #end
  }

  static function writeToFlxGLog(data:Array<Dynamic>, logStyle:LogStyle)
  {
    if (FlxG != null && FlxG.game != null && FlxG.log != null)
    {
      FlxG.log.advanced(data, logStyle);
    }
  }

  static function writeToLogFile(data:Array<Dynamic>, logLevel:String = "TRACE")
  {
    if (logFileWriter != null && logFileWriter.isActive())
    {
      logFileWriter.write(data, logLevel);
    }
  }

  /**
   * Defines some commands you can run in the console for easy use of important debugging functions.
   * Feel free to add your own!
   */
  inline static function defineConsoleCommands()
  {
    // Example: This will display Boyfriend's sprite properties in a debug window.
    addConsoleCommand("trackBoyfriend", function() {
      Debug.logInfo("CONSOLE: Begin tracking Boyfriend...");
      trackObject(PlayState.instance.boyfriend);
    });
    addConsoleCommand("trackGirlfriend", function() {
      Debug.logInfo("CONSOLE: Begin tracking Girlfriend...");
      trackObject(PlayState.instance.gf);
    });
    addConsoleCommand("trackDad", function() {
      Debug.logInfo("CONSOLE: Begin tracking Dad...");
      trackObject(PlayState.instance.dad);
    });

    addConsoleCommand("setLogLevel", function(logLevel:String) {
      if (!DebugLogWriter.LOG_LEVELS.contains(logLevel))
      {
        Debug.logWarn('CONSOLE: Invalid log level $logLevel!');
        Debug.logWarn('  Expected: ${DebugLogWriter.LOG_LEVELS.join(', ')}');
      }
      else
      {
        Debug.logInfo('CONSOLE: Setting log level to $logLevel...');
        logFileWriter.setLogLevel(logLevel);
      }
    });
  }

  static function formatOutput(input:Dynamic, pos:haxe.PosInfos):Array<Dynamic>
  {
    // This code is junk but I kept getting Null Function References.
    var inArray:Array<Dynamic> = null;
    var stringArray:Array<String> = [];
    if (input == null) inArray = ['<NULL>'];
    else if (!Std.isOfType(input, Array)) inArray = [input];
    else
      inArray = input;

    if (pos == null) return inArray;

    // Format the position ourselves.
    var output:Array<Dynamic> = ['(${pos.className}/${pos.methodName}#${pos.lineNumber}): '];
    return output.concat(inArray);
  }
}

class DebugLogWriter
{
  static final LOG_FOLDER = "logs";
  public static final LOG_LEVELS = ['ERROR', 'WARN', 'INFO', 'TRACE'];

  /**
   * Set this to the current timestamp that the game started.
   */
  var startTime:Float = 0;

  var logLevel:Int;

  var active = false;
  #if sys
  var file:sys.io.FileOutput;
  #end

  public function new(logLevelParam:String)
  {
    logLevel = LOG_LEVELS.indexOf(logLevelParam);

    #if sys
    printDebug("Initializing log file...");

    var logFilePath = '$LOG_FOLDER/${Sys.time()}.log';

    // Make sure that the path exists
    if (logFilePath.indexOf("/") != -1)
    {
      var lastIndex:Int = logFilePath.lastIndexOf("/");
      var logFolderPath:String = logFilePath.substr(0, lastIndex);
      printDebug('Creating log folder $logFolderPath');
      FileSystem.createDirectory(logFolderPath);
    }
    // Open the file
    printDebug('Creating log file $logFilePath');
    file = File.write(logFilePath, false);
    active = true;
    #else
    printDebug("Won't create log file; no file system access.");
    active = false;
    #end

    // Get the absolute time in seconds. This lets us show relative time in log, which is more readable.
    startTime = getTime(true);
  }

  public function isActive()
  {
    return active;
  }

  /**
   * Get the time in seconds.
   * @param abs Whether the timestamp is absolute or relative to the start time.
   */
  public inline function getTime(abs:Bool = false):Float
  {
    #if sys
    // Use this one on CPP and Neko since it's more accurate.
    return abs ? Sys.time() : (Sys.time() - startTime);
    #else
    // This one is more accurate on non-CPP platforms.
    return abs ? Date.now().getTime() : (Date.now().getTime() - startTime);
    #end
  }

  inline function shouldLog(input:String):Bool
  {
    final levelIndex = LOG_LEVELS.indexOf(input);
    // Could not find this log level.
    if (levelIndex == -1) return false;
    return levelIndex <= logLevel;
  }

  public function setLogLevel(input:String):Void
  {
    final levelIndex = LOG_LEVELS.indexOf(input);
    // Could not find this log level.
    if (levelIndex == -1) return;

    logLevel = levelIndex;
    FlxG.save.data.debugLogLevel = logLevel;
  }

  // Updated DEBUG USAGE BY SLUSHI

  /**
   * Output text to the log file.
   */
  public function write(input:Array<Dynamic>, logLevel = 'TRACE'):Void
  {
    final ts = FlxStringUtil.formatTime(getTime(), true);
    final dateNow = getDate();
    final arguments = transformToArguments(input);
    final msg = '$dateNow || $ts [$logLevel] - $arguments';

    #if sys
    if (active && file != null)
    {
      if (shouldLog(logLevel))
      {
        file.writeString('$msg\n');
        file.flush();
        file.flush();
      }
    }
    #end

    // Output text to the debug console directly.
    if (shouldLog(logLevel)) printDebug(msg);
  }

  public static function getDate()
  {
    final dateNow = Date.now();
    final year = dateNow.getFullYear();
    final month = dateNow.getMonth() + 1;
    final day = dateNow.getDate();
    return '$year/${month < 10 ? "0" : ""}$month/${day < 10 ? "0" : ""}$day';
  }

  inline function printDebug(msg:String)
  {
    #if sys
    Sys.println(msg);
    #else
    // Pass null to exclude the position.
    haxe.Log.trace(msg, null);
    #end
  }

  inline function transformToArguments(input:Array<Dynamic>):String
  {
    final call:String = Std.string(input[0]);
    input.shift();
    var value:String = "";
    for (item in input)
      value += (value.length > 0 ? ", " : "") + Std.string(item);
    return call + value;
  }
}
