package slushi.windows;

import sys.io.Process;
import sys.io.File;
import lime.system.System;
import psychlua.LuaUtils;
import slushi.windows.ProgramRespondingUtil;

/*
 * This file is one that facilitates the use of Windows functions that come from WindowsCPP.hx within SLE. 
 * 
 * Author: Slushi
 */
class WindowsFuncs
{
	@:noPrivateAccess // Yeah, it's private, you can't use @:privateAccess like in HScript for get this :3
	private static var _windowsWallpaperPath:String = null;

	public static var changedWallpaper:Bool = false;
	private static final savedWallpaperPath:String = "assets/slushiEngineAssets/SLEAssets/OthersAssets/Cache/savedWindowswallpaper.png";

	public static function changeWindowsWallpaper(path:String)
	{
		#if windows
		var allPath:String = CustomFuncs.getAllPath() + 'assets/' + path;
		allPath = allPath.split("\\").join("/");
		CppAPI.setWallpaper(allPath);
		changedWallpaper = true;
		Debug.logSLEInfo("Wallpaper changed to: " + allPath);
		#end
	}

	public static function screenCapture(path:String)
	{
		#if windows
		var allPath:String = CustomFuncs.getAllPath() + 'assets/images/SLEAssets/Cache/' + path;
		allPath = allPath.split("\\").join("/");
		CppAPI.screenCapture(allPath);
		Debug.logSLEInfo("Screenshot saved to: " + allPath);
		#end
	}

	public static function saveCurrentWindowsWallpaper()
	{
		#if windows
		var path = '${Sys.getEnv("AppData")}\\Microsoft\\Windows\\Themes\\TranscodedWallpaper';

		if (path != null)
		{
			Debug.logSLEInfo("Wallpaper Path: " + path);
			Debug.logSLEInfo("Saving the path in a private variable...");
			_windowsWallpaperPath = path;
		}
		else
		{
			Debug.logSLEError("Error! Could not save the wallpaper path!");
		}
		#end
	}

	public static function saveCopyOfSavedWindowsWallpaper()
	{
		#if windows
		var finalPath = savedWallpaperPath;
		try
		{
			if (!FileSystem.exists('assets/slushiEngineAssets/SLEAssets/OthersAssets/Cache'))
				FileSystem.createDirectory('assets/slushiEngineAssets/SLEAssets/OthersAssets/Cache');

			File.copy(_windowsWallpaperPath, finalPath);
		}
		catch (e)
		{
			Debug.logSLEError("Could not save the wallpaper path: " + e);
		}
		#end
	}

	public static function setOldWindowsWallpaper()
	{
		#if windows
		if (changedWallpaper == false)
			return;

		changedWallpaper = false;

		if (ClientPrefs.data.useSavedWallpaper)
		{
			var finalPath = savedWallpaperPath;
			CppAPI.setWallpaper(finalPath);
			Debug.logSLEInfo("Wallpaper changed to: " + finalPath);
			return;
		}

		CppAPI.setWallpaper(_windowsWallpaperPath);
		Debug.logSLEInfo("Wallpaper changed to: " + _windowsWallpaperPath);
		#end
	}

	public static function sendWindowsNotification(desc:String, title:String)
	{
		#if windows
		var powershellCommand = "powershell -Command \"& {$ErrorActionPreference = 'Stop';"
			+ "$title = '"
			+ desc
			+ "';"
			+ "[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null;"
			+ "$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText01);"
			+ "$toastXml = [xml] $template.GetXml();"
			+ "$toastXml.GetElementsByTagName('text').AppendChild($toastXml.CreateTextNode($title)) > $null;"
			+ "$xml = New-Object Windows.Data.Xml.Dom.XmlDocument;"
			+ "$xml.LoadXml($toastXml.OuterXml);"
			+ "$toast = [Windows.UI.Notifications.ToastNotification]::new($xml);"
			+ "$toast.Tag = 'Test1';"
			+ "$toast.Group = 'Test2';"
			+ "$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('"
			+ "Slushi Engine: "
			+ title
			+ "');"
			+ "$notifier.Show($toast);}\"";

		if (title != null && title != "" && desc != null && desc != "" && getWindowsVersion() != 7)
			new Process(powershellCommand);
		#end
	}

	public static function resetAllCPPFunctions()
	{
		#if windows
		CppAPI.hideTaskbar(false);
		CppAPI.hideDesktopIcons(false);
		CppAPI.moveDesktopWindowsInXY(0, 0);
		CppAPI.setTaskBarAlpha(1);
		CppAPI.setDesktopWindowsAlpha(1);

		if (ClientPrefs.data.changeWallPaper)
		{
			if (changedWallpaper)
			{
				setOldWindowsWallpaper();
			}
		}
		#end
	}

	// Thanks Trock for giving me an idea to make this code cleaner.
	public static function getWindowsVersion():Int
	{
		#if windows
		var windowsVersions:Map<String, Int> = [
			"Windows 11" => 11, // Same as Windows 10, and maybe some more optimization.
			"Windows 10" => 10, // It's not bad, it's pretty good if you remove the bloatware that usually comes with the OS.
			"Windows 8.1" => 8, // Same as Windows 8.
			"Windows 8" => 8, // Hey, it could be made more for touch screens but, it is well optimized.
			"Windows 7" => 7, // Windows 7, beautiful OS, I love Windows Aero.
		];

		var platformLabel = System.platformLabel;
		var words = platformLabel.split(" ");
		var windowsIndex = words.indexOf("Windows");
		var result = "";
		if (windowsIndex != -1 && windowsIndex < words.length - 1)
		{
			result = words[windowsIndex] + " " + words[windowsIndex + 1];
		}

		if (windowsVersions.exists(result))
		{
			return windowsVersions.get(result);
		}

		return 0;
		#end

		return 0;
	}

	public static function setSlushiColorToWindow()
	{
		#if windows
		if (getWindowsVersion() == 11)
			CppAPI.setSlushiColorToWindow();
		#end
	}

	public static function setWindowBorderColor(rgb:Array<Int>)
	{
		#if windows
		if (getWindowsVersion() == 11)
			CppAPI.setWindowBorderColor(rgb[0], rgb[1], rgb[2]);
		#end
	}

	public static function getCursorPos():{x:Int, y:Int}
	{
		var mousePos = {x: 0, y: 0};
		#if windows
		mousePos = {x: WindowsCPP.getCursorPositionX(), y: WindowsCPP.getCursorPositionY()};
		#end
		return mousePos;
	}

	public static function initThreadForWindowRespondingHandler()
	{
		#if windows
		Sys.println("[slushi.windows.WindowsFuncs.initThreadForWindowRespondingHandler] - Starting thread for window responding handler...");
		ProgramRespondingUtil.initThread();
		#end
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	#if windows
	public static function doTweenDesktopWindows(mode:String, toValue:Float, duration:Float, ease:String)
	{
		var startvalueX = CppAPI.getDesktopWindowsXPos();
		var startvalueY = CppAPI.getDesktopWindowsYPos();
		switch (mode)
		{
			case "X":
				var numTween:NumTween = FlxTween.num(startvalueX, toValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
				numTween.onUpdate = function(twn:FlxTween)
				{
					CppAPI.moveDesktopWindowsInX(Std.int(numTween.value));
				}
			case "Y":
				var numTween:NumTween = FlxTween.num(startvalueY, toValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
				numTween.onUpdate = function(twn:FlxTween)
				{
					CppAPI.moveDesktopWindowsInY(Std.int(numTween.value));
				}
		}
	}

	public static function doTweenDesktopWindowsAlpha(fromValue:Float, toValue:Float, duration:Float, ease:String)
	{
		var numTween:NumTween = FlxTween.num(fromValue, toValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
		numTween.onUpdate = function(twn:FlxTween)
		{
			CppAPI.setDesktopWindowsAlpha(numTween.value);
		}
	}

	public static function doTweenTaskBarAlpha(fromValue:Float, toValue:Float, duration:Float, ease:String)
	{
		var numTween:NumTween = FlxTween.num(fromValue, toValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
		numTween.onUpdate = function(twn:FlxTween)
		{
			CppAPI.setTaskBarAlpha(numTween.value);
		}
	}
	#end
}

class DeprecatedFuncs
{
	#if windows
	public static function doTweenDesktopWindowsInX(fromValue:Float, toValue:Float, duration:Float, ease:String = "linear")
	{
		var numTween:NumTween = FlxTween.num(fromValue, toValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
		numTween.onUpdate = function(twn:FlxTween)
		{
			CppAPI.moveDesktopWindowsInX(Std.int(numTween.value));
		}
	}

	public static function doTweenDesktopWindowsInY(fromValue:Float, toValue:Float, duration:Float, ease:String = "linear")
	{
		var numTween:NumTween = FlxTween.num(fromValue, toValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
		numTween.onUpdate = function(twn:FlxTween)
		{
			CppAPI.moveDesktopWindowsInY(Std.int(numTween.value));
		}
	}
	#end
}
