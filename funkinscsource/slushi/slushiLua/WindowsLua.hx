package slushi.slushiLua;

import psychlua.FunkinLua;
import slushi.windows.winGDIThings.SlushiWinGDI;
import slushi.windows.winGDIThings.WinGDIThread;

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
			var allPath:String = CustomFuncs.getProgramPath() + 'mods/images/windowsAssets/' + image + '.png';

			if (ClientPrefs.data.changeWallPaper)
			{
				if (image == "default")
				{
					WindowsFuncs.setOldWindowsWallpaper();
					return;
				}

				WindowsFuncs.changedWallpaper = true;
				CppAPI.setWallpaper(allPath);
				Debug.logSLEInfo("Wallpaper changed to: " + allPath);
			}
			#else
			printInDisplay("setWallpaper: Function disabled in this build!", FlxColor.RED);
			#end
		});

		funkLua.set("winScreenCapture", function(nameToSave:String)
		{
			#if (windows)
			var allPath:String = CustomFuncs.getProgramPath() + 'mods/images/windowsAssets/' + nameToSave + '.png';
			if (ClientPrefs.data.winScreenShots)
			{
				CppAPI.screenCapture(allPath);
				Debug.logSLEInfo("Screenshot saved to: " + allPath);
			}
			#else
			printInDisplay("winScreenCapture: Function disabled in this build!", FlxColor.RED);
			#end
		});

		funkLua.set("setDesktopWindowsPos", function(mode:String, value:Int)
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
						printInDisplay("setDesktopWindowsPos: Invalid value!", FlxColor.RED);
				}
			}
			#else
			printInDisplay("setDesktopWindowsPos: Platform unsupported for this function!", FlxColor.RED);
			#end
		});

		funkLua.set("doTweenDesktopWindowsPos", function(mode:String, toValue:Float, duration:Float, ease:String = "linear")
		{
			#if (windows && SLUSHI_CPP_CODE)
			if (ClientPrefs.data.winDesktopIcons)
				WindowsFuncs.doTweenDesktopWindows(mode, toValue, duration, ease);
			#else
			printInDisplay("doTweenDesktopWindowsPos: Platform unsupported for this function!", FlxColor.RED);
			#end
		});

		funkLua.set("doTweenDesktopWindowsAlpha", function(fromValue:Float, toValue:Float, duration:Float, ease:String = "linear")
		{
			#if (windows && SLUSHI_CPP_CODE)
			if (ClientPrefs.data.winDesktopIcons)
				WindowsFuncs.doTweenDesktopWindowsAlpha(fromValue, toValue, duration, ease);
			#else
			printInDisplay("doTweenDesktopWindowsAlpha: Platform unsupported for this function!", FlxColor.RED);
			#end
		});

		funkLua.set("doTweenTaskBarAlpha", function(fromValue:Float, toValue:Float, duration:Float, ease:String = "linear")
		{
			#if (windows && SLUSHI_CPP_CODE)
			if (ClientPrefs.data.winDesktopIcons)
				WindowsFuncs.doTweenTaskBarAlpha(fromValue, toValue, duration, ease);
			#else
			printInDisplay("doTweenTaskBarAlpha: Platform unsupported for this function!", FlxColor.RED);
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

		funkLua.set("sendNotification", function(desc:String, title:String)
		{
			#if windows
			if (ClientPrefs.data.windowsNotifications)
				WindowsFuncs.sendWindowsNotification(desc, title);
			#else
			printInDisplay("sendNotification: Platform unsupported for this function!", FlxColor.RED);
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
	}
}

class WindowsGDI
{
	public static function loadWindowsGDILua(funkLua:FunkinLua)
	{
		Debug.logSLEInfo("Loaded Slushi Windows GDI Lua functions!");

		funkLua.set("startGDIThread", function()
		{
			#if windows
			if (ClientPrefs.data.gdiEffects)
			{
				WinGDIThread.initThread();
			}
			#else
			printInDisplay("startThread: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("prepareGDIEffect", function(effect:String, wait:Float = 0)
		{
			#if windows
			if (ClientPrefs.data.gdiEffects)
				SlushiWinGDI.prepareGDIEffect(effect, wait);
			#else
			printInDisplay("prepareGDIEffect: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("setGDIEffectWaitTime", function(effect:String, wait:Float = 0)
		{
			#if windows
			if (ClientPrefs.data.gdiEffects)
				SlushiWinGDI.setGDIEffectWaitTime(effect, wait);
			#else
			printInDisplay("setGDIEffectWaitTime: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("enableGDIEffect", function(effect:String, enabled:Bool)
		{
			#if windows
			if (ClientPrefs.data.gdiEffects)
				SlushiWinGDI.enableGDIEffect(effect, enabled);
			#else
			printInDisplay("enableGDIEffect: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("removeGDIEffect", function(effect:String)
		{
			#if windows
			if (ClientPrefs.data.gdiEffects)
				SlushiWinGDI.removeGDIEffect(effect);
			#else
			printInDisplay("removeGDIEffect: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("setTitleTextToWindows", function(titleText:String)
		{
			#if windows
			if (ClientPrefs.data.gdiEffects)
				SlushiWinGDI._setCustomTitleTextToWindows(titleText);
			#else
			printInDisplay("setTitleTextToWindows: Platform unsupported for this function", FlxColor.RED);
			#end
		});
	}
}
