package slushi.slushiLua;

import psychlua.FunkinLua;
import psychlua.LuaUtils;

import slushi.winSL.WinSLConsoleUtils;

class WinSLLua
{
	public static function loadWinSLLua(funkLua:FunkinLua)
	{
		#if windows
		Debug.logSLEInfo("WinSL Console Lua initialized");

		funkLua.set("winSL_console_getVersion", function()
		{
			return SlushiMain.sleThingsVersions.winSLVersion;
		});

		funkLua.set("winSL_console_printLetterByLetter", function(text:String, time:Float)
		{
			WinSLConsoleUtils.printLetterByLetter(text, time);
		});

		funkLua.set("winSL_console_showWindow", function(mode:Bool)
		{
			switch (mode)
			{
				case true:
					WindowsTerminalCPP.allocConsole();
					WindowsTerminalCPP.setConsoleTitle('WinSL ${SlushiMain.sleThingsVersions.winSLVersion}');
					WindowsTerminalCPP.setConsoleWindowIcon(SlushiMain.getSLEPath("WinSL_Assets/windowIcon.ico"));
					WindowsTerminalCPP.setWinConsoleColor();
				case false:
					WindowsTerminalCPP.hideConsoleWindow();
			}
		});

		funkLua.set("winSL_console_disableResize", function()
		{
			WindowsTerminalCPP.disableResizeWindow();
		});

		funkLua.set("winSL_console_disableClose", function()
		{
			WindowsTerminalCPP.disableCloseWindow();
		});

		funkLua.set("winSL_console_setTitle", function(title:String)
		{
			WindowsTerminalCPP.setConsoleTitle(title);
		});

		funkLua.set("winSL_console_setWinPos", function(mode:String, value:Int)
		{
			switch (mode)
			{
				case "X":
					WindowsTerminalCPP.setConsoleWindowPositionX(value);
				case "Y" :
					WindowsTerminalCPP.setConsoleWindowPositionY(value);
				default:
					printInDisplay("winSL_console_setWinPos: Invalid mode!", FlxColor.RED);
			}
		});

		funkLua.set("winSL_console_tweenWinPos", function(mode:String, value:Int, time:Float, ease:String = "linear")
		{
			switch (mode)
			{
				case "X":
					var numTween:NumTween = FlxTween.num(WindowsTerminalCPP.returnConsolePositionX(), value, time, {
						ease: LuaUtils.getTweenEaseByString(ease),
					});
					numTween.onUpdate = function(twn:FlxTween)
					{
						WindowsTerminalCPP.setConsoleWindowPositionX(Std.int(numTween.value));
					}
				case "Y":
					var numTween:NumTween = FlxTween.num(WindowsTerminalCPP.returnConsolePositionY(), value, time, {
						ease: LuaUtils.getTweenEaseByString(ease),
					});
					numTween.onUpdate = function(twn:FlxTween)
					{
						WindowsTerminalCPP.setConsoleWindowPositionY(Std.int(numTween.value));
					}
				default:
					printInDisplay("winSL_console_tweenWinPos: Invalid mode!", FlxColor.RED);
			}
		});

		funkLua.set("winSL_console_getWinPos", function(mode:String)
		{
			switch (mode)
			{
				case "X":
					return WindowsTerminalCPP.returnConsolePositionX();
				case "Y":
					return WindowsTerminalCPP.returnConsolePositionY();
				default:
					printInDisplay("winSL_console_getWinPos: Invalid mode!", FlxColor.RED);
					return 0;
			}
		});

		funkLua.set("winSL_console_centerWindow", function()
		{
			WindowsTerminalCPP.centerConsoleWindow();
		});
		#end
	}
}
