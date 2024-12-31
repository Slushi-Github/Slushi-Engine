package slushi.winSL;

import Sys;
import haxe.Timer;
import sys.io.File;
import sys.FileSystem;
import sys.io.FileInput;
import sys.io.FileOutput;
import slushi.winSL.termvm.Terminal;
import slushi.winSL.termvm.CommandModule;
import slushi.winSL.termvm.Parser;
import slushi.winSL.termvm.Module;
import slushi.winSL.termvm.ModuleType;
import slushi.winSL.termvm.Others;
import haxe.io.Path;

/**
 * The main class for the initialization of the WinSL terminal.
 * 
 * Author: Trock (Modified by Slushi)
 */
class Main
{
	public static var finishedStartup:Bool = false;

	static function clear():Void
	{
		Modules.ModuleUtils.clearConsole();
	}

	static function startup():Void
	{
		clear();

		Sys.sleep(0.5);
		Sys.println('WinSL [${SlushiMain.sleThingsVersions.winSLVersion}] - Running on ${Sys.systemName()}');
		Sys.sleep(1.2);
		var userName:String = Sys.environment().get("USERNAME");
		if (userName == null)
			userName = Sys.environment().get("USER");
		Sys.println("Started by " + (userName != null ? userName : "an unknown user"));
		Sys.sleep(1.2);
        #if windows
		Sys.println("Already initialized all Microsoft Windows API functions");
        #else
        Sys.println("Cannot initialize Microsoft Windows API functions, platform not supported");
        #end
		Sys.sleep(0.6);
		// Sys.println('Warning: Possible [MODCHARTS] detected in WinSL/SlushiEngine_${SlushiMain.buildNumber}.vm that may cause an overload and break the Sandbox provided by WinSL.');
		Sys.sleep(0.6);
		Sys.println("Loading WinSL environment...");
		WinSLConsoleUtils.printLetterByLetter('Loading internal Modules....Done\n', 0.035);
		Sys.sleep(0.6);
		WinSLConsoleUtils.printLetterByLetter('Finalizing WinSL environment initialization....Done\n', 0.035);
		WinSLConsoleUtils.printLetterByLetter('-------------\n\n', 0.045);
		Sys.sleep(0.4);
	}

	static public function main():Void
	{
		startup();

		var parser = new Parser([
			new Module(ModuleType.TOKENIZER, Others.tokenize),
			new Module(ModuleType.EXTRACTOR, Others.extract),
			new Module(ModuleType.OPERATOR_HANDLER, Others.process)
		]);

		var stdin = Sys.stdin();
		var stdout = Sys.stdout();

		var cwd = Sys.getCwd() + "/assets/slushiEngineAssets/WinSL_Assets/";
		var pathStr = Path.join([cwd, 'sandbox']);

		if (!FileSystem.exists(pathStr))
		{
			FileSystem.createDirectory(pathStr);
		}

		var path = FileSystem.exists(pathStr) ? pathStr : FileSystem.fullPath("sandbox");

		var terminal = new Terminal(parser, stdin, stdout, {'path': path, 'sandbox_path': path});

		for (module in Modules.getModules())
		{
			terminal.registerCommandModule(module);
		}

		terminal.run();
	}
}
