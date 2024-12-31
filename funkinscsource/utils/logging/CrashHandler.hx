package utils.logging;

import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.FlxG.FlxRenderMethod;

/**
 * A custom crash handler that writes to a log file and displays a message box.
 */
@:nullSafety
class CrashHandler
{
  #if CRASH_HANDLER
  public static final CRASH_FOLDER = 'crashes';

  /**
   * Called before exiting the game when a standard error occurs, like a thrown exception.
   * @param message The error message.
   */
  public static var errorSignal(default, null):FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

  /**
   * Called before exiting the game when a critical error occurs, like a stack overflow or null object reference.
   * CAREFUL: The game may be in an unstable state when this is called.
   * @param message The error message.
   */
  public static var criticalErrorSignal(default, null):FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

  static final quotes:Array<String> = [
    "Ha, a null object reference?", // Slushi
    "What the fuck you did!?", // Edwhak
    "CAGASTE.", // Slushi
    "It was Bolo!" // Glowsoony
  ];

  /**
   * Initializes
   */
  public static function initialize():Void
  {
    Debug.logInfo('Enabling standard uncaught error handler...');
    Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

    #if cpp
    Debug.logInfo('Enabling C++ critical error handler...');
    untyped __global__.__hxcpp_set_critical_error_handler(onCriticalError);
    #end
  }

  /**
   * Called when an uncaught error occurs.
   * This handles most thrown errors, and is sufficient to handle everything alone on HTML5.
   * @param error Information on the error that was thrown.
   */
  static function onUncaughtError(error:UncaughtErrorEvent):Void
  {
    try
    {
      updateScreenBeforeCrash(FlxG.fullscreen);
      errorSignal.dispatch(generateErrorMessage(error));

      #if sys
      logError(error);
      #end

      var crashDialoguePath:String = "SCE-CrashDialog";

      #if windows
      crashDialoguePath += ".exe";
      #end

      if (FileSystem.exists(crashDialoguePath))
      {
        Debug.logInfo("\nFound crash dialog program " + "[" + crashDialoguePath + "]");
        new Process(crashDialoguePath, ["xd ", '$CRASH_FOLDER/crash-${DateUtil.generateTimestamp(true)}.txt']);
      }
      else
      {
        Debug.logError("No crash dialog found! Making a simple alert instead...");
        displayError(error);
      }

      #if DISCORD_ALLOWED
      DiscordClient.shutdown();
      #end
      System.exit(1);
    }
    catch (e:Dynamic)
    {
      Debug.logInfo('Error while handling crash: ' + e);
    }
  }

  static function onCriticalError(message:String):Void
  {
    try
    {
      updateScreenBeforeCrash(FlxG.fullscreen);
      criticalErrorSignal.dispatch(message);

      #if sys
      logErrorMessage(message, true);
      #end

      var crashDialoguePath:String = "SCE-CrashDialog";

      #if windows
      crashDialoguePath += ".exe";
      #end

      if (FileSystem.exists(crashDialoguePath))
      {
        Debug.logInfo("\nFound crash dialog program " + "[" + crashDialoguePath + "]");
        new Process(crashDialoguePath, ["xd ", '$CRASH_FOLDER/crash-critical${DateUtil.generateTimestamp(true)}.txt']);
      }
      else
      {
        Debug.logError("No crash dialog found! Making a simple alert instead...");
        displayErrorMessage(message);
      }
    }
    catch (e:Dynamic)
    {
      Debug.logError('Error while handling crash: $e');
      Debug.logError('Message: $message');
    }

    #if DISCORD_ALLOWED
    DiscordClient.shutdown();
    #end

    #if sys
    // Exit the game. Since it threw an error, we use a non-zero exit code.
    Sys.exit(1);
    #end
  }

  static function displayError(error:UncaughtErrorEvent):Void
  {
    displayErrorMessage(generateErrorMessage(error));
  }

  static function displayErrorMessage(message:String):Void
  {
    Debug.displayAlert(message, "Fatal Uncaught Exception");
  }

  #if sys
  static function logError(error:UncaughtErrorEvent):Void
  {
    logErrorMessage(generateErrorMessage(error));
  }

  static function logErrorMessage(message:String, critical:Bool = false):Void
  {
    FileUtil.createDirIfNotExists(CRASH_FOLDER);

    sys.io.File.saveContent('$CRASH_FOLDER/crash${critical ? '-critical' : ''}-${DateUtil.generateTimestamp(true)}.txt', buildCrashReport(message));
  }

  static function buildCrashReport(message:String):String
  {
    var fullContents:String = '=====================\n';
    fullContents += ' Funkin Crash Report\n';
    fullContents += '=====================\n';

    fullContents += '\n';

    fullContents += 'Generated by: Friday Night Funkin\n';
    fullContents += 'System timestamp: ${DateUtil.generateTimestamp(true)}\n';
    var driverInfo = FlxG?.stage?.context3D?.driverInfo ?? 'N/A';
    fullContents += 'Driver info: ${driverInfo}\n';
    fullContents += 'Platform: ${Sys.systemName()}\n';
    fullContents += 'Render method: ${renderMethod()}\n';

    fullContents += '\n';

    fullContents += '=====================\n';

    fullContents += '\n';

    fullContents += MemoryUtil.buildGCInfo();

    fullContents += '\n\n';

    fullContents += '=====================\n';

    fullContents += '\n';

    var currentState = FlxG.state != null ? Type.getClassName(Type.getClass(FlxG.state)) : 'No state loaded';

    fullContents += 'Flixel Current State: ${currentState}\n';

    fullContents += '\n';

    fullContents += '=====================\n';

    fullContents += '\n';

    fullContents += quotes[Std.random(quotes.length)];

    fullContents += '\n';

    fullContents += '=====================\n';

    fullContents += '\n';

    fullContents += 'Loaded mods: \n';

    if (backend.SafeNullArray.getModsList().length == 0)
    {
      fullContents += 'No mods loaded.\n';
    }
    else
    {
      for (mods in backend.SafeNullArray.getModsList())
      {
        fullContents += '- ${mods}\n';
      }
    }

    fullContents += '\n';

    fullContents += '=====================\n';

    fullContents += '\n';

    fullContents += message;

    fullContents += '\n';

    return fullContents;
  }
  #end

  static function generateErrorMessage(error:UncaughtErrorEvent):String
  {
    var errorMessage:String = "";
    var callStack:Array<haxe.CallStack.StackItem> = haxe.CallStack.exceptionStack(true);

    errorMessage += '${error.error}\n';

    for (stackItem in callStack)
    {
      switch (stackItem)
      {
        case FilePos(innerStackItem, file, line, column):
          errorMessage += '  in $file#$line';
          if (column != null) errorMessage += ':${column}';
        case CFunction:
          errorMessage += '[Function] ';
        case Module(m):
          errorMessage += '[Module($m)] ';
        case Method(classname, method):
          errorMessage += '[Function($classname.$method)] ';
        case LocalFunction(v):
          errorMessage += '[LocalFunction($v)] ';
      }
      errorMessage += '\n';
    }

    return errorMessage;
  }

  public static function queryStatus():Void
  {
    @:privateAccess
    var currentStatus = Lib.current.stage.__uncaughtErrorEvents.__enabled;
    Debug.logInfo('ERROR HANDLER STATUS: ' + currentStatus);

    #if openfl_enable_handle_error
    Debug.logInfo('Define: openfl_enable_handle_error is enabled');
    #else
    Debug.logInfo('Define: openfl_enable_handle_error is disabled');
    #end

    #if openfl_disable_handle_error
    Debug.logInfo('Define: openfl_disable_handle_error is enabled');
    #else
    Debug.logInfo('Define: openfl_disable_handle_error is disabled');
    #end
  }

  public static function induceBasicCrash():Void
  {
    throw "This is an example of an uncaught exception.";
  }

  public static function induceNullObjectReference():Void
  {
    var obj:Dynamic = null;
    var value = obj.test;
  }

  public static function induceNullObjectReference2():Void
  {
    var obj:Dynamic = null;
    var value = obj.test();
  }

  public static function induceNullObjectReference3():Void
  {
    var obj:Dynamic = null;
    var value = obj();
  }

  @:nullSafety(Off)
  static function renderMethod():String
  {
    try
    {
      return switch (FlxG.renderMethod)
      {
        case FlxRenderMethod.DRAW_TILES: 'DRAW_TILES';
        case FlxRenderMethod.BLITTING: 'BLITTING';
        default: 'UNKNOWN';
      }
    }
    catch (e)
    {
      return 'ERROR ON QUERY RENDER METHOD: ${e}';
    }
  }

  static function updateScreenBeforeCrash(isFullScreen:Bool)
  {
    FlxG.resizeWindow(1280, 720);

    @:privateAccess
    {
      FlxG.width = 1280;
      FlxG.height = 720;
    }

    if (!(FlxG.scaleMode is flixel.system.scaleModes.RatioScaleMode)) // just to be sure yk.
      FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();

    lime.app.Application.current.window.width = 1280;
    lime.app.Application.current.window.height = 720;
    lime.app.Application.current.window.borderless = false;

    // Add all this just in case it's not 1280 x 720 even without fullscreen
    if (isFullScreen)
    {
      FlxG.fullscreen = false;
    }
  }
  #end
}
