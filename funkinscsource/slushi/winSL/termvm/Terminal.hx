package slushi.winSL.termvm;

import haxe.ds.StringMap;
import haxe.io.Eof;
import haxe.ds.StringMap;
import haxe.io.Input;
import haxe.io.Output;
import haxe.io.Bytes;
import slushi.winSL.termvm.Parser;
import haxe.CallStack;
import fuzzaldrin.Fuzzaldrin;

/**
 * The main class of WinSL, the terminal for SLE.
 * 
 * Author: Trock (Modified by Slushi)
 */

class Terminal
{
	public var parser:Parser;
	public var stdin:Input;
	public var stdout:Output;
	public var metadata:Dynamic;
	public var commandModules:StringMap<CommandModule>;
	public var variables:StringMap<Dynamic>;

	public var numberOfCrashes:Int = 0;
	public var commandRoot:String = "";
	public var defaultString:String = "> ";
	public static var instance:Terminal = null;

	public function new(parser:Parser, stdin:Input, stdout:Output, ?metadata:Dynamic)
	{
		this.parser = parser;
		this.stdin = stdin;
		this.stdout = stdout;
		this.metadata = metadata != null ? metadata : {};
		this.commandModules = new StringMap<CommandModule>();
		this.variables = new StringMap<Dynamic>();

		instance = this;

		// register default commands
		registerCommandModule(new CommandModule(["exit", "EXIT"], ExitModule.execute));
		registerCommandModule(new CommandModule(["cls", "clear", "CLS", "CLEAR"], ClearModule.execute));
		registerCommandModule(new CommandModule(["stop", "STOP"], StopModule.execute));
        registerCommandModule(new CommandModule(["resetVM", "resetvm", "backToVM", "backtovm", "reset"], ResetVMModule.execute));
		registerCommandModule(new CommandModule(["set", "SET"], SetVariableModule.execute));
		registerCommandModule(new CommandModule(["get", "GET"], GetVariableModule.execute));
	}

	public function getVariable(name:String):Dynamic
	{
		return variables.exists(name) ? variables.get(name) : null;
	}

	public function setVariable(name:String, value:Dynamic):Void
	{
		variables.set(name, value);
	}

	public function registerCommandModule(module:CommandModule):Void
	{
		for (commandRoot in module.commandRoots)
		{
			commandModules.set(commandRoot, module);
		}
	}

	public static function extractCommandNames(commandModules:StringMap<CommandModule>):Array<String>
	{
		var commandNames:Array<String> = [];
		for (module in commandModules)
		{
			commandNames.push(module.commandRoots[0]);
		}
		return commandNames;
	}

    public function runOnce():Array<Dynamic> {
        stdout.writeString(defaultString);
        stdout.flush();
        try {
            var commandLine:String = stdin.readLine();
            if (commandLine != null && commandLine.length > 0 && commandLine != "") {
                var parsedCommands:Array<Dynamic> = parser.parse(commandLine);
                for (parsedCommand in parsedCommands) {
                    commandRoot = parsedCommand.command[0];
                    var args:Array<String> = processArguments(parsedCommand.command.slice(1));

                    if (commandModules.exists(commandRoot)) {
                        var module:CommandModule = commandModules.get(commandRoot);
                        module.execute(this, commandRoot, args, metadata);
                    } else {
						#if (fuzzaldrin && WINSL_SUGGEST_COMMAND)
                        var candidates = extractCommandNames(commandModules);
						var results = Fuzzaldrin.filter(candidates, commandRoot);
						if (results.length > 0)
							stdout.writeString("Command " + commandRoot + " not found. Did you mean: \"" + results[0] + "\"?\n");
						else
							stdout.writeString("Command " + commandRoot + " not found.\n");
						#else
						stdout.writeString("Command " + commandRoot + " not found.\n");
						#end
                    }
                }
                stdout.flush();
                return parsedCommands;
            }
            else {
                stdout.writeString("");
            }
        } catch (e:Eof) {
            getCrashHandler(e);
        }
        return [];
    }

	public function run():Void
	{
		while (true)
		{
			try
			{
				runOnce();
			}
			catch (e)
			{
				getCrashHandler(e);
			}
		}
	}

	private function processArguments(args:Array<String>):Array<String> {
        return args.map(function(arg:String):String {
            var regExp = ~/^\$\{(.+)\}$/;
            var result:String = arg;
            if (regExp.match(arg)) {
                var varName:String = regExp.replace(arg, "$1");
                var value:Dynamic = getVariable(varName);
                if (value != null) {
                    result = value.toString();
                } else {
                    result = "NullVar";
                    stdout.writeString("\x1b[38;5;235mVariable " + varName + " not found.\x1b[0m\n");
                }
            }
            return result;
        });
    }

	function getCrashHandler(input:Dynamic)
	{
		numberOfCrashes++;

		if (numberOfCrashes == 10)
		{
			WinSLCrashHandler.onVMCrash(input, true);
		}
		Sys.println('\n\x1b[38;5;236m-------\x1b[0m\n\x1b[38;5;1mWinSL Critical Error!\x1b[0m\nERROR: $input\n\x1b[38;5;236m-------\x1b[0m\nCall Stack:\n${getSomeInfoOfCrash()}\n\n');
	}

	function getSomeInfoOfCrash():String
	{
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var finaltxtString:String = "";
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					finaltxtString += file + " [line " + line + "]\n";
				default:
					Sys.println(stackItem);
			}
		}

		return finaltxtString;
	}
}

//////////////

/**
 * Internal or default commands for the terminal.
 */

class ExitModule
{
	public static function execute(terminal:Terminal, commandRoot:String, args:Array<String>, metadata:Dynamic):Void
	{
		terminal.stdout.writeString("Bye!\n");
		Sys.sleep(1.2);
		Sys.exit(0);
	}
}

class ClearModule
{
	public static function execute(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void
	{
		return slushi.winSL.Modules.ModuleUtils.clearConsole();
	}
}

class StopModule
{
	public static function execute(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void
	{
		Sys.exit(0);
	}
}

class SetVariableModule
{
	public static function execute(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void
	{
        if (args.length != 2 || args[0] == null || args[1] == "") {
            terminal.stdout.writeString("Usage: set <variableName> <value>\n");
            return;
        }
		
		terminal.setVariable(args[0], args[1]);
	}
}

class GetVariableModule
{
	public static function execute(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void
	{
		terminal.stdout.writeString(terminal.getVariable(args[0]).toString() + "\n");
	}
}

class ResetVMModule {
    public static function execute(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void {

        terminal.stdout.writeString("Resetting VM and exiting of WinSL terminal...\n");
        Sys.sleep(2);
		CustomFuncs.realResetGame();
        Sys.exit(0);
    }
}