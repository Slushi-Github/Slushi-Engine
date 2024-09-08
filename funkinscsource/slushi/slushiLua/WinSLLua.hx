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
			return SlushiMain.winSLVersion;
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
					WinConsoleUtils.allocConsole();
					WinConsoleUtils.setConsoleTitle('WinSL ${SlushiMain.winSLVersion}');
					WinConsoleUtils.setConsoleWindowIcon(SlushiMain.getSLEPath("WinSL_Assets/windowIcon.ico"));
					WinConsoleUtils.setWinConsoleColor();
				case false:
					WinConsoleUtils.hideConsoleWindow();
			}
		});

		funkLua.set("winSL_console_disableResize", function()
		{
			WinConsoleUtils.disableResizeWindow();
		});

		funkLua.set("winSL_console_disableClose", function()
		{
			WinConsoleUtils.disableCloseWindow();
		});

		funkLua.set("winSL_console_setTitle", function(title:String)
		{
			WinConsoleUtils.setConsoleTitle(title);
		});

		funkLua.set("winSL_console_setWinPos", function(mode:String, value:Int)
		{
			switch (mode)
			{
				case "X":
					WinConsoleUtils.setConsoleWindowPositionX(value);
				case "Y" :
					WinConsoleUtils.setConsoleWindowPositionY(value);
				default:
					printInDisplay("winSL_console_setWinPos: Invalid mode!", FlxColor.RED);
			}
		});

		funkLua.set("winSL_console_tweenWinPos", function(mode:String, value:Int, time:Float, ease:String = "linear")
		{
			switch (mode)
			{
				case "X":
					var numTween:NumTween = FlxTween.num(WinConsoleUtils.returnConsolePositionX(), value, time, {
						ease: LuaUtils.getTweenEaseByString(ease),
					});
					numTween.onUpdate = function(twn:FlxTween)
					{
						WinConsoleUtils.setConsoleWindowPositionX(Std.int(numTween.value));
					}
				case "Y":
					var numTween:NumTween = FlxTween.num(WinConsoleUtils.returnConsolePositionY(), value, time, {
						ease: LuaUtils.getTweenEaseByString(ease),
					});
					numTween.onUpdate = function(twn:FlxTween)
					{
						WinConsoleUtils.setConsoleWindowPositionY(Std.int(numTween.value));
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
					return WinConsoleUtils.returnConsolePositionX();
				case "Y":
					return WinConsoleUtils.returnConsolePositionY();
				default:
					printInDisplay("winSL_console_getWinPos: Invalid mode!", FlxColor.RED);
					return 0;
			}
		});

		funkLua.set("winSL_console_centerWindow", function()
		{
			WinConsoleUtils.centerConsoleWindow();
		});
		#end
	}
}
