package slushi.slushiUtils.crashHandler;

import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import flixel.system.scaleModes.*;
import flixel.group.FlxGroup;
import lime.system.System;
import utils.DateUtil;
import states.StoryMenuState;
import states.freeplay.FreeplayState;
import states.MainMenuState;

/*
 * Crash Handler in game by Edwhak_KillBot, Niz, and Slushi
 */
class CrashHandler
{
	public static var inCrash:Bool = false;
	public static var crashes:Int = 0;
	public static var crashesLimit:Int = 5;
	public static var createdCrashInGame:Bool = false;
	private static var flxFuncNum:Int = -1;

	public static function symbolPrevent(error:Dynamic, ?flxFuncInt:Int = -1):Void
	{
		onUncaughtError(error);
		flxFuncNum = flxFuncInt;
	}

	public static function initCrashHandler()
	{
		initCPPCrashHandler();
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
	}

	static function initCPPCrashHandler()
	{
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onCPPError);
		#end
	}

	private static function onCPPError(message:Dynamic):Void
	{
		var mainText:String = 'C++ side critical error!:\n';

		#if cpp
		throw Std.string(message);
		System.exit(1);
		#if windows
		CppAPI.showMessageBox(mainText + message, "Slushi Engine [C++]: Crash Handler", MSG_ERROR);
		System.exit(1);
		#else
		WindowFuncs.windowAlert(mainText + message, "Slushi Engine [C++]: Crash Handler");
		System.exit(1);
		#end
		#end
	}

	static final quotes:Array<String> = [
		"Ha, a null object reference?", // Slushi
		"What the fuck you did!?", // Edwhak
		"CAGASTE.", // Slushi
		"It was Bolo!", // Glowsoony
		"El pollo ardiente", // Edwhak
		"Apuesto que este error viene de SCE y no SLE, verdad..?", // Slushi
		"Null References: The Billion Dollar Mistake", // Trock
		"GLOW PAGAME EL POLLO", // Slushi
	];

	static function onUncaughtError(e:Dynamic):Void
	{
		if (inCrash)
		{
			Debug.logSLEWarn("Trying to make a another crash while is already in a crash with error: [" + e + "]. Crash counter: [" + crashes + "], skipping it...");
			crashes++;
			if (crashes == crashesLimit)
			{
				Debug.logSLEWarn("Too many crashes, quitting...");
				#if windows
				CppAPI.showMessageBox("Many crashes occurred in a short time, SLE will close to avoid entering a loop.\n\nThe logs can be found in [./assets/debugLogs/crashes/]\nPlease contact with @slushi_ds in Discord or add an issue in the engine repository if you think it is a bug in SLE.",
					"Slushi Engine: Crash Handler", MSG_INFORMATION);
				#else
				WindowFuncs.windowAlert("Too many crashes, the engine will close!\n\nThe logs can be found in [./assets/debugLogs/crashes/]\nPlease contact with @slushi_ds in Discord or add an issue in the engine repository if you think it is a bug in SLE.",
					"Slushi Engine: Crash Handler");
				#end
				System.exit(1);
			}
			return;
		};
		
		inCrash = true;

		var randomsMsg:String = "";
		var callStackText:String = "";
		var callStackForEditorText:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");
		var build = System.platformLabel;

		path = "./assets/debugLogs/crashes/" + "SLEngineCrash_" + dateNow + ".log";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					callStackText += file + " (line " + line + ")\n";
					if (callStackForEditorText == "")
					{
						// Underline only the first line
						callStackForEditorText += "\033[4m" + file + "#" + line + "\033[24m\n";
					}
					else
					{
						callStackForEditorText += file + "#" + line + "\n";
					}
				case CFunction:
					callStackText += "Non-Haxe (C) Function";
				case Module(c):
					callStackText += 'Module ${c}';
				default:
					Sys.println(stackItem);
			}
		}

		randomsMsg = quotes[Std.random(quotes.length)];

		var finalTerminalText:String = "";
		finalTerminalText += "Call Stack:\n" + callStackForEditorText;
		finalTerminalText += "\nUncaught Error:\n" + e;

		var finalGameplayText:String = "";
		finalGameplayText += "Call Stack:\n" + callStackText;
		finalGameplayText += "\n---------------------"
			+ "\nCrash on Flixel function: [" + whereItCrashes(flxFuncNum) + "]\n"
			+ randomsMsg
			+ "\n---------------------"
			+ "\n\nThis build is running in "
			+ build
			+ "\nSLE v"
			+ SlushiMain.slushiEngineVersion
			+ " -- SCE v"
			+ MainMenuState.SCEVersion
			+ " ("
			+ SlushiMain.sceGitCommit
			+ ")"
			+ "\nPlease contact with @slushi_ds in Discord or add an issue in the repository \nif you think this is a bug of SLE."
			+ "\n\n"
			+ "Uncaught Error:\n"
			+ e
			+ "\n\n"
			+ "For more info go to: [assets/debugLogs/crashes/SLEngineCrash_"
			+ dateNow
			+ ".log]";

		if (!FileSystem.exists("./assets/debugLogs/crashes/"))
			FileSystem.createDirectory("./assets/debugLogs/crashes/");

		File.saveContent(path, buildCrashReportForFile(e, callStackText, randomsMsg));

		Debug.logError("\nCRASH:\n\x1b[38;5;1m" + finalTerminalText + "\033[0m\n\n");

		GameplayCrashHandler.crashHandlerTerminal(finalGameplayText);
		Debug.logInfo("Starting Crash Handler in game");

		#if SLUSHI_CPP_CODE
		WindowsFuncs.resetAllCPPFunctions();
		#end
		WindowFuncs.resetWindowParameters();
	}

	static function buildCrashReportForFile(errorMessage:String, callStack:String, randomQuote:String):String
	{
		var fullContents:String = '=====================\n';
		fullContents += 'Slushi Engine Crash Report\n';
		fullContents += '=====================\n';

		fullContents += 'Slushi Engine Crash Handler Util v${SlushiMain.sleThingsVersions.slCrashHandlerVersion}\n';

		fullContents += '=====================\n';

		fullContents += '\n';

		fullContents += 'Generated by: Slushi Engine v${SlushiMain.slushiEngineVersion} - SC Engine v${MainMenuState.SCEVersion} (${SlushiMain.sceGitCommit})\n';
		fullContents += 'System timestamp: ${DateUtil.generateTimestamp(true)}\n';
		var driverInfo = FlxG?.stage?.context3D?.driverInfo ?? 'N/A';
		fullContents += 'GPU Driver info: \n${driverInfo}\n';
		fullContents += 'Platform: ${System.platformLabel}\n';
		@:privateAccess
		fullContents += 'Render method: ${utils.logging.CrashHandler.renderMethod()}\n';

		fullContents += '\n';

		fullContents += '=====================\n';

		fullContents += '\n';

		fullContents += randomQuote;

		fullContents += '\n\n';

		fullContents += 'Crash message: ${errorMessage}\n';

		fullContents += '\n';

		fullContents += '=====================\n';

		fullContents += '\n';

		fullContents += 'More info:\n';

		fullContents += 'Please contact with @slushi_ds in Discord or add an issue in the engine repository if you think it is a bug in SLE.\n';

		fullContents += '\n';

		var currentState = FlxG.state != null ? Type.getClassName(Type.getClass(FlxG.state)) : 'No state loaded.';
		var currentSubState = FlxG.state.subState != null ? Type.getClassName(Type.getClass(FlxG.state.subState)) : 'No substate loaded.';

		fullContents += 'Flixel Current State: ${currentState}\n';
		fullContents += 'Flixel Current SubState: ${currentSubState}\n';
		fullContents += 'Crashed on Flixel function: [${whereItCrashes(flxFuncNum)}]\n';

		fullContents += '\n';

		fullContents += 'Call Stack: \n${callStack}\n';

		fullContents += '=====================\n';

		fullContents += '\n';

		fullContents += utils.MemoryUtil.buildGCInfo();

		fullContents += '\n\n';

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

		fullContents += 'Slushi Engine build info:\n';

		fullContents += 'Version: ${SlushiMain.slushiEngineVersion}\n';
		fullContents += 'Build number: ${SlushiMain.buildNumber}\n';
		fullContents += 'SCE build Github commit: ${SlushiMain.sceGitCommit}\n';
		fullContents += 'C++ Code: ' + #if SLUSHI_CPP_CODE 'YES' #else 'NO' #end + '\n';
		fullContents += 'Slushi Lua: ' + #if SLUSHI_LUA 'YES' #else 'NO' #end + '\n';
		fullContents += 'Custom build: ' + #if CUSTOM_BUILD 'YES' #else 'NO' #end + '\n';

		return fullContents;
	}

	private static function whereItCrashes(number:Int):String
	{
		switch (number) {
			case 0:
				return "Create";
			case 1:
				return "Update";
			case 2:
				return "Draw";
			default:
				return "Unknown";
		}

		return "Unknown";
	}
}
