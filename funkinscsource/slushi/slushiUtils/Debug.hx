package slushi.slushiUtils;

import lime.app.Application;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.debug.log.LogStyle;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.util.FlxStringUtil;
import haxe.Log;
import haxe.PosInfos;

class Debug
{
	static final LOG_STYLE_ERROR:LogStyle = new LogStyle('[ERROR] ', 'FF8888', 12, true, false, false, 'flixel/sounds/beep', true);
	static final LOG_STYLE_WARN:LogStyle = new LogStyle('[WARN] ', 'D9F85C', 12, true, false, false, 'flixel/sounds/beep', true);
	static final LOG_STYLE_INFO:LogStyle = new LogStyle('[INFO] ', '5CF878', 12, false);
	static final LOG_STYLE_TRACE:LogStyle = new LogStyle('[TRACE] ', '5CF878', 12, false);

	static final LOG_STYLE_SLE_ERROR:LogStyle = new LogStyle('[ERROR] ', 'FF8888', 12, true, false, false, 'flixel/sounds/beep', true);
	static final LOG_STYLE_SLE_WARN:LogStyle = new LogStyle('[WARN] ', 'D9F85C', 12, true, false, false, 'flixel/sounds/beep', true);
	static final LOG_STYLE_SLE_INFO:LogStyle = new LogStyle('[INFO] ', '5CF878', 12, false);
	

	static var logFileWriter:DebugLogWriter = null;

	/**
	 * Log an error message to the game's console.
	 * Plays a beep to the user and forces the console open if this is a debug build.
	 * @param input The message to display.
	 * @param pos This magic type is auto-populated, and includes the line number and class it was called from.
	 */
	public static inline function logError(input:Dynamic, ?pos:haxe.PosInfos):Void
	{
		if (input == null)
			return;
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
		if (input == null)
			return;
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
		if (input == null)
			return;
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
		if (input == null)
			return;
		var output = formatOutput(input, pos);
		writeToLogFile(output, 'TRACE');
		#end
	}

	public static inline function logSLEInfo(input:Dynamic, ?pos:haxe.PosInfos):Void
		{
			if (input == null)
				return;
			var output = formatOutput(input, pos);
			writeToFlxGLog(output, LOG_STYLE_SLE_INFO);
			writeToLogFile(output, 'SLE_INFO');
		}

	public static inline function logSLEWarn(input:Dynamic, ?pos:haxe.PosInfos):Void
		{
			if (input == null)
				return;
			var output = formatOutput(input, pos);
			writeToFlxGLog(output, LOG_STYLE_SLE_WARN);
			writeToLogFile(output, 'SLE_WARN');
		}

	public static inline function logSLEError(input:Dynamic, ?pos:haxe.PosInfos):Void
		{
			if (input == null)
				return;
			var output = formatOutput(input, pos);
			writeToFlxGLog(output,LOG_STYLE_SLE_ERROR);
			writeToLogFile(output, 'SLEERROR');
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
		Log.trace = function(data:Dynamic, ?info:PosInfos)
		{
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

		#if debug
		logInfo("This is a DEBUG build.");
		#else
		logInfo("This is a RELEASE build.");
		#end
		logInfo('HaxeFlixel version: ${Std.string(FlxG.VERSION)}');
		logSLEInfo('Slushi Engine version: ${slushi.SlushiMain.slushiEngineVersion}');
		logInfo('SC Engine version: ${states.MainMenuState.SCEVersion} (${SlushiMain.sceGitCommit})');
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
		if (FlxG.save.data.debugLogLevel == null)
			FlxG.save.data.debugLogLevel = "TRACE";

		//logFileWriter.setLogLevel(FlxG.save.data.debugLogLevel);
	}

	public static function clearLogsFolder()
	{
		#if FEATURE_FILESYSTEM
		var logFilePath = 'assets/logs/${Sys.time()}.log';
		var lastIndex:Int = logFilePath.lastIndexOf("/");
		var logFolderPath:String = logFilePath.substr(0, lastIndex);
		var files = FileSystem.readDirectory(logFolderPath); // Reading all logs in an array.

		for (file in files)
		{
			// To not consider the last one that is the current log text the game is writing to avoid crashes
			if (files.indexOf(file) != files.length - 1)
				FileSystem.deleteFile('$logFolderPath/$file'); // Deleting each one from the log directory.
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
		addConsoleCommand("trackBoyfriend", function()
		{
			Debug.logInfo("CONSOLE: Begin tracking Boyfriend...");
			trackObject(PlayState.instance.boyfriend);
		});
		addConsoleCommand("trackGirlfriend", function()
		{
			Debug.logInfo("CONSOLE: Begin tracking Girlfriend...");
			trackObject(PlayState.instance.gf);
		});
		addConsoleCommand("trackDad", function()
		{
			Debug.logInfo("CONSOLE: Begin tracking Dad...");
			trackObject(PlayState.instance.dad);
		});

		addConsoleCommand("setLogLevel", function(logLevel:String)
		{
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

		/*// Console commands let you do WHATEVER you want.
		addConsoleCommand("playSong", function(songName:String, ?difficulty:Int = 1)
		{
			Debug.logInfo('CONSOLE: Opening song $songName ($difficulty) in Free Play...');
			FreeplayState.instance.loadSongInFreePlay(songName, difficulty, false);
		});
		addConsoleCommand("chartSong", function(songName:String, ?difficulty:Int = 1)
		{
			Debug.logInfo('CONSOLE: Opening song $songName ($difficulty) in Chart Editor...');
			FreeplayState.instance.loadSongInFreePlay(songName, difficulty, true, true);
		});*/
	}

	static function formatOutput(input:Dynamic, pos:haxe.PosInfos):Array<Dynamic>
	{
		// This code is junk but I kept getting Null Function References.
		var inArray:Array<Dynamic> = null;
		if (input == null)
		{
			inArray = ['<NULL>'];
		}
		else if (!Std.isOfType(input, Array))
		{
			inArray = [input];
		}
		else
		{
			inArray = input;
		}

		if (pos == null)
			return inArray;

		// Format the position ourselves.
		var output:Array<Dynamic> = ['\033[4;90m[${pos.className}/${pos.methodName}#${pos.lineNumber}]:\033[0m '];

		return output.concat(inArray);
	}
}

class DebugLogWriter
{
	static final LOG_FOLDER = "assets/debugLogs/logs";
	public static final LOG_LEVELS = ['SLE_INFO', 'SLE_WARN', 'SLE_ERROR', 'ERROR', 'WARN', 'INFO', 'TRACE'];

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

	function shouldLog(input:String):Bool
	{
		var levelIndex = LOG_LEVELS.indexOf(input);
		// Could not find this log level.
		if (levelIndex == -1)
			return false;
		return levelIndex <= logLevel;
	}

	public function setLogLevel(input:String):Void
	{
		var levelIndex = LOG_LEVELS.indexOf(input);
		// Could not find this log level.
		if (levelIndex == -1)
			return;

		logLevel = levelIndex;
		FlxG.save.data.debugLogLevel = logLevel;
	}

	public function setANSIcolorForLogLevel(logLevel:String):String{
		switch(logLevel){
			case 'SLE_INFO':
				return "\033[96m";
			case 'SLE_WARN':
				return "\033[33;2m";
			case 'SLE_ERROR':
				return "\033[31;2m";
			case 'ERROR':
				return "\033[31m";
			case 'WARN':
				return "\033[33m";
			case 'INFO':
				return "\033[97m";
			case 'TRACE':
				return "\033[100m";
			default:
				return "\033[0m";
		}
	}

	//Updated DEBUG USAGE BY SLUSHI
	/**
	 * Output text to the log file.
	 */
	public function write(input:Array<Dynamic>, logLevel = 'TRACE'):Void
	{
		var ts = FlxStringUtil.formatTime(getTime(), true);
		var dateNow = getDate();
		var msgWithoutColors = '$dateNow | $ts [${logLevel.rpad('', 5)}] - ${input.join('')}';
		var msg = '\033[90m$dateNow\033[0m \x1b[38;5;8m|\033[0m \033[32m$ts\033[0m ${setANSIcolorForLogLevel(logLevel)}[${logLevel.rpad('', 5)}]\033[0m - ${input.join('')}';

		#if sys
		if (active && file != null)
		{
			if (shouldLog(logLevel))
			{
				file.writeString('$msgWithoutColors\n');
				file.flush();
				file.flush();
			}
		}
		#end

		// Output text to the debug console directly.
		if (shouldLog(logLevel)) {
			printDebug(msg);
		}
	}

	public static function getDate()
    {
		var dateNow = Date.now();
		var year = dateNow.getFullYear();
		var mouth = dateNow.getMonth() + 1;
		var day = dateNow.getDate();
		var all = year + "-" + (mouth < 10 ? "0" : "") + mouth + "-" + (day < 10 ? "0" : "") + day;
            
        return all;
    }

	function printDebug(msg:String)
	{
		#if sys
		Sys.println(msg);
		#else
		// Pass null to exclude the position.
		haxe.Log.trace(msg, null);
		#end
	}
}
