package slushi.slushiLua;

/*
 * This class contains ALL Lua functions for Slushi Engine, it is one of the most important files since it 
 * is what allows to make modcharts using the features of the engine through Lua, and more.
 * 
 * Author: Slushi
*/

import psychlua.FunkinLua;

class SlushiLua
{
	public static var apliedWindowTransparent:Bool = false;
	public static var slushi_InternalSprites:Map<String, FlxSprite> = new Map<String, FlxSprite>();

	public static function loadSlushiLua(funkLua:FunkinLua)
	{
		Debug.logSLEInfo("Loading Slushi Lua functions...");
		#if (SLUSHI_LUA && LUA_ALLOWED)
		WindowsLua.loadWindowsLua(funkLua);
		WindowsLua.WindowsGDI.loadWindowsGDILua(funkLua);
		WindowLua.loadWindowLua(funkLua);
		ShadersLua.loadShadersLua(funkLua);
		OthersLua.loadOthersLua(funkLua);
		WinSLLua.loadWinSLLua(funkLua);
		#else
		Debug.logSLEInfo("Slushi Lua functions are not loaded! SLUSHI_LUA and LUA_ALLOWED is set to false in this build.");
		#end
	}
}
