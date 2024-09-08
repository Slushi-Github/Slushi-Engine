package slushi.slushiLua;

import psychlua.FunkinLua;
import slushi.windows.WindowsGDIEffects;

class WindowsLua
{
	public static function loadWindowsLua(funkLua:FunkinLua)
	{
		Debug.logSLEInfo("Loaded Slushi Windows Lua functions!");

		funkLua.set("resetAllCPPFunctions", function()
		{
			#if windows
			WindowsFuncs.resetAllCPPFunctions();
			#else
			printInDisplay("resetAllCPPFunctions: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("getRAM", function()
		{
			#if windows
			return CppAPI.obtainRAM();
			#else
			printInDisplay("getRAM: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("hideTaskBar", function(hide:Bool)
		{
			#if (windows && SLUSHI_CPP_CODE)
			if (ClientPrefs.data.winTaskBar)
				CppAPI.hideTaskbar(hide);
			#else
			printInDisplay("hideTaskbar: Function disabled in this build!", FlxColor.RED);
			#end
		});

		funkLua.set("setWallpaper", function(image:String)
		{
			#if (windows && SLUSHI_CPP_CODE)
			var allPath:String = CustomFuncs.getAllPath() + 'mods/images/winAssets/' + image + '.png';

			if (ClientPrefs.data.changeWallPaper)
			{
				if (image == "default")
				{
					WindowsFuncs.setOldWindowsWallpaper();
				}
				else
				{
					CppAPI.setWallpaper(allPath);
					WindowsFuncs.changedWallpaper = true;
					Debug.logSLEInfo("Wallpaper changed to: " + allPath);
				}
			}
			#else
			printInDisplay("setWallpaper: Function disabled in this build!", FlxColor.RED);
			#end
		});

		funkLua.set("winScreenCapture", function(nameToSave:String)
		{
			#if (windows)
			var allPath:String = CustomFuncs.getAllPath() + 'mods/images/winAssets/' + nameToSave + '.png';
			if (ClientPrefs.data.winScreenShots)
			{
				CppAPI.screenCapture(allPath);
				Debug.logSLEInfo("Screenshot saved to: " + allPath);
			}
			#else
			printInDisplay("setWallpaper: Function disabled in this build!", FlxColor.RED);
			#end
		});

		funkLua.set("moveDesktopWindows", function(mode:String, value:Int)
		{
			#if (windows && SLUSHI_CPP_CODE)
			if (ClientPrefs.data.winDesktopIcons)
			{
				switch (mode)
				{
					case "X":
						CppAPI.moveDesktopWindowsInX(value);
					case "Y":
						CppAPI.moveDesktopWindowsInY(value);
					case "XY":
						CppAPI.moveDesktopWindowsInXY(value, value);
					default:
						printInDisplay("moveDesktopWindows: Invalid value!", FlxColor.RED);
				}
			}
			#else
			printInDisplay("moveDesktopWindows: Platform unsupported for this function!", FlxColor.RED);
			#end
		});

		funkLua.set("doTweenDesktopWindows", function(mode:String, toValue:Float, duration:Float, ease:String = "linear")
		{
			#if (windows && SLUSHI_CPP_CODE)
			if (ClientPrefs.data.winDesktopIcons)
				WindowsFuncs.doTweenDesktopWindows(mode, toValue, duration, ease);
			#else
			printInDisplay("doTweenDesktopWindows: Platform unsupported for this function!", FlxColor.RED);
			#end
		});

		funkLua.set("doTweenDesktopWindowsAlpha", function(fromValue:Float, toValue:Float, duration:Float, ease:String = "linear")
		{
			#if (windows && SLUSHI_CPP_CODE)
			if (ClientPrefs.data.winDesktopIcons)
				WindowsFuncs.doTweenDesktopWindowsAlpha(fromValue, toValue, duration, ease);
			#else
			printInDisplay("setDesktopWindowsAlpha: Platform unsupported for this function!", FlxColor.RED);
			#end
		});

		funkLua.set("doTweenTaskBarAlpha", function(fromValue:Float, toValue:Float, duration:Float, ease:String = "linear")
		{
			#if (windows && SLUSHI_CPP_CODE)
			if (ClientPrefs.data.winDesktopIcons)
				WindowsFuncs.doTweenTaskBarAlpha(fromValue, toValue, duration, ease);
			#else
			printInDisplay("setDesktopWindowsAlpha: Platform unsupported for this function!", FlxColor.RED);
			#end
		});

		funkLua.set("getDesktopWindowsPos", function(mode:String)
		{
			#if (windows && SLUSHI_CPP_CODE)
			if (!ClientPrefs.data.winDesktopIcons)
				return 0;

			switch (mode)
			{
				case "X":
					return CppAPI.getDesktopWindowsXPos();
				case "Y":
					return CppAPI.getDesktopWindowsYPos();
				default:
					printInDisplay("getDesktopWindowsPos: Invalid value!", FlxColor.RED);
					return 0;
			}
			#else
			printInDisplay("getDesktopWindowsPos: Platform unsupported for this function!", FlxColor.RED);
			#end
		});

		funkLua.set("getWindowsVersion", function()
		{
			#if windows
			return WindowsFuncs.getWindowsVersion();
			#else
			printInDisplay("getWindowsVersion: Platform unsupported for this function! Use getOSVersion!", FlxColor.RED);
			#end
		});

		funkLua.set("sendNoti", function(desc:String, title:String)
		{
			#if windows
			if (ClientPrefs.data.windowsNotifications)
				WindowsFuncs.sendWindowsNotification(desc, title);
			#else
			printInDisplay("sendNoti: Platform unsupported for this function!", FlxColor.RED);
			#end
		});

		funkLua.set("hideDesktopIcons", function(hide:Bool)
		{
			#if SLUSHI_CPP_CODE
			if (ClientPrefs.data.winDesktopIcons)
				CppAPI.hideDesktopIcons(hide);
			#else
			printInDisplay("hideDesktopIcons: Function disabled in this build!", FlxColor.RED);
			#end
		});

		funkLua.set("setDesktopWindowsAlpha", function(alpha:Float)
		{
			#if SLUSHI_CPP_CODE
			if (ClientPrefs.data.winDesktopIcons)
				CppAPI.setDesktopWindowsAlpha(alpha);
			#else
			printInDisplay("setDesktopWindowsAlpha: Function disabled in this build!", FlxColor.RED);
			#end
		});

		funkLua.set("setTaskBarAlpha", function(alpha:Float)
		{
			#if SLUSHI_CPP_CODE
			if (ClientPrefs.data.winTaskBar)
				CppAPI.setTaskBarAlpha(alpha);
			#else
			printInDisplay("setDesktopWindowsAlpha: Function disabled in this build!", FlxColor.RED);
			#end
		});

		funkLua.set("setOtherWindowLayeredMode", function(window:String)
		{
			#if SLUSHI_CPP_CODE
			switch (window)
			{
				case "desktop":
					if (ClientPrefs.data.winDesktopIcons)
					{
						CppAPI.setWindowLayeredMode(0);
						Debug.logSLEInfo("Window Layered seting: Desktop Window");
					}
				case "taskBar":
					if (ClientPrefs.data.winTaskBar)
					{
						CppAPI.setWindowLayeredMode(1);
						Debug.logSLEInfo("Window Layered seting: Task Bar Window");
					}
				default:
					printInDisplay("setWindowLayeredMode: Invalid window!", FlxColor.RED);
					Debug.logSLEWarn("Invalid window!");
			}
			#else
			printInDisplay("setOtherWindowLayeredMode: Function disabled in this build!", FlxColor.RED);
			#end
		});

		// funkLua.set("getDesktopIconsCount", function()
		// {
		// 	#if SLUSHI_CPP_CODE
		// 	if (!ClientPrefs.data.winDesktopIcons)
		// 		return 0;

		// 	return WindowsCPP._getTotalDesktopIcons();
		// 	#else
		// 	printInDisplay("getDesktopIconsCount: Function disabled in this build!", FlxColor.RED);
		// 	#end
		// });

		// funkLua.set("getDesktopIconPosition", function(mode:String, iconIndex:Int):Int
		// {
		// 	#if SLUSHI_CPP_CODE
		// 	if (!ClientPrefs.data.winDesktopIcons)
		// 		return 0;

		// 	if (iconIndex < 0 || iconIndex > WindowsCPP._getTotalDesktopIcons())
		// 	{
		// 		printInDisplay("Index out of range: " + iconIndex, FlxColor.RED);
		// 		return 0;
		// 	}

		// 	switch (mode)
		// 	{
		// 		case "X":
		// 			return WindowsCPP._getDesktopIconXPosition(iconIndex);
		// 		case "Y":
		// 			return WindowsCPP._getDesktopIconYPosition(iconIndex);
		// 		default:
		// 			return 0;
		// 			printInDisplay("getDesktopIconPosition: Invalid mode!", FlxColor.RED);
		// 	}

		// 	return 0;
		// 	#else
		// 	printInDisplay("getDesktopIconPosition: Function disabled in this build!", FlxColor.RED);
		// 	#end
		// });

		// funkLua.set("setDesktopIconPosition", function(mode:String, iconIndex:Int, value:Int)
		// {
		// 	#if SLUSHI_CPP_CODE
		// 	if (!ClientPrefs.data.winDesktopIcons)
		// 		return 0;

		// 	if (iconIndex < 0 || iconIndex > WindowsCPP._getTotalDesktopIcons())
		// 	{
		// 		printInDisplay("Index out of range: " + iconIndex, FlxColor.RED);
		// 		return 0;
		// 	}

		// 	switch (mode)
		// 	{
		// 		case "X":
		// 			WindowsCPP._setDesktopIconXPosition(iconIndex, value);
		// 		case "Y":
		// 			WindowsCPP._setDesktopIconYPosition(iconIndex, value);
		// 		default:
		// 			printInDisplay("setDesktopIconPosition: Invalid mode!", FlxColor.RED);
		// 			return 0;
		// 	}

		// 	return 0;
		// 	#else
		// 	printInDisplay("setDesktopIconPosition: Function disabled in this build!", FlxColor.RED);
		// 	#end
		// });

		// funkLua.set("tweenDesktopIconPosition", function(mode:String, iconIndex:Int, toValue:Float, duration:Float, ease:String)
		// {
		// 	#if SLUSHI_CPP_CODE
		// 	if (!ClientPrefs.data.winDesktopIcons)
		// 		return;

		// 	if (iconIndex < 0 || iconIndex > WindowsCPP._getTotalDesktopIcons())
		// 	{
		// 		printInDisplay("Index out of range: " + iconIndex, FlxColor.RED);
		// 		return;
		// 	}

		// 	WindowsFuncs.doTweenDesktopIcon(mode, iconIndex, toValue, duration, ease);

		// 	#else
		// 	printInDisplay("tweenDesktopIconPosition: Function disabled in this build!", FlxColor.RED);
		// 	#end
		// });
	}
}

class WindowsGDI
{
	public static function loadWindowsGDILua(funkLua:FunkinLua)
	{
		Debug.logSLEInfo("Loaded Slushi Windows GDI Lua functions!");

		funkLua.set("windowsEffectModifier", function(tag:String = "", gdiEffect:String, activeEffect:Bool)
		{
			#if windows
			if (ClientPrefs.data.gdiEffects)
				WindowsGDIEffects.checkEffect(tag, gdiEffect, activeEffect);
			#else
			printInDisplay("windowsEffectModifier: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("setWinEffectProperty", function(tag:String, prop:String, value:Dynamic)
		{
			#if windows
			if (ClientPrefs.data.gdiEffects)
				WindowsGDIEffects.setWinEffectProperty(tag, prop, value);
			#else
			printInDisplay("setWinEffectProperty: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("setTitleTextToWindows", function(titleText:String)
		{
			#if windows
			if (ClientPrefs.data.gdiEffects)
				WindowsGDIEffects._setCustomTitleTextToWindows(titleText);
			#else
			printInDisplay("setTitleTextToWindows: Platform unsupported for this function", FlxColor.RED);
			#end
		});
	}
}
