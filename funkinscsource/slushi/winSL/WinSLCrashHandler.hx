package slushi.winSL;

import haxe.CallStack;
import haxe.io.Path;
import lime.system.System;

/**
 * A crash handler for the WinSL terminal, and for the game (It is not used in the game XD).
 * 
 * Author: Slushi
 */

class WinSLCrashHandler {
    
    public static function onVMCrash(e:Dynamic, ?stopedTerminal:Bool):Void{
        var randomsMsg:String = "";
		var errMsg:String = "";
		var callstackText:String = "Call Stack:\n";
		var build = Sys.systemName();
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		var build = System.platformLabel;

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./assets/debugLogs/crashes/" + "SLEWinSLCrash_" + dateNow + ".log";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
				callstackText += errMsg + file + " (line " + line + ")\n";
				case CFunction: callstackText += "Non-Haxe (C) Function";
				case Module(c): callstackText += 'Module ${c}';
				default:
					Sys.println(stackItem);
			}
		}

		var finalText:String = "";

		if (stopedTerminal)
			finalText = 'The WinSL Terminal has had several critical errors. execution aborted.\n\nUncontrollable error: $e\n\n------\n$callstackText';
		else if (!stopedTerminal)
			finalText = 'The VM [SlushiEngine_${SlushiMain.buildNumber}.vm] has had a critical error. execution aborted to protect the user.\n\nUncontrollable error: $e\n\n------\n$callstackText';

		if (!FileSystem.exists("./debugLogs/crashes/"))
			FileSystem.createDirectory("./debugLogs/crashes/");

		File.saveContent(path, finalText + "\n");

		if(!stopedTerminal) {
			#if windows
			CppAPI.showMessageBox(finalText, "WinSL: Critical Error", MSG_ERROR);
			#else
			WindowFuncs.windowAlert(finalText, "WinSL: Critical Error");
			#end
		}
		else {
			#if windows
			CppAPI.showMessageBox(finalText, "WinSL: STOPED TERMINAL.", MSG_ERROR);
			#else
			WindowFuncs.windowAlert(finalText, "WinSL: STOPED TERMINAL.");
			#end
		}

		Sys.exit(1);
    }
}