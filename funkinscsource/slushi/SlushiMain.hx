package slushi;

import slushi.others.CustomFuncs;
import slushi.others.systemUtils.SystemInfo;
import slushi.others.BuildDemoText;
import slushi.slushiUtils.crashHandler.CrashHandler;
import tjson.TJSON as Json;
import slushi.states.SlushiTitleState;

/*
 * This is the main class for the Slushi Engine initialization, this loads all initial functions of Windows C++ API
 * and have variables like buildNumber (number of the build of the engine) or slushiEngineVersion (the version of the engine).
 *
 * Author: Slushi
 */
class SlushiMain
{
	// Versions of the things in the engine and base engine (SCE)
	public static var buildNumber:String = "19102024";
	public static var sceGitCommit:String = "4eaf8c4";
	public static var slushiEngineVersion:String = '0.3.8';
	public static var winSLVersion:String = '1.3.0';
	public static var slCrashHandlerVersion:String = '1.4.0';

	public static var slushiColor = FlxColor.fromRGB(143, 217, 209); // 0xff8FD9D1 0xffd6f3de
	private static var pathsToCreate:Array<String> = ['./engineUtils', './engineUtils/SMToConvert'];

	public static function loadSlushiEngineFunctions()
	{
		#if windows
		preventAdminExecution();
		CppAPI._setWindowLayered();
		CppAPI.centerWindow();
		WindowsFuncs.resetAllCPPFunctions();
		WindowsFuncs.saveCurrentWindowsWallpaper();
		if (ClientPrefs.data.useSavedWallpaper)
		{
			WindowsFuncs.saveCopyOfSavedWindowsWallpaper();
		}
		WindowsFuncs.setSlushiColorToWindow();
		#end
		SystemInfo.init();
		createEngineUtilsFolder();
		Application.current.window.onClose.add(SlushiMain.onCloseWindow);

		CrashHandler.initCrashHandler();

		#if THIS_IS_A_BUILD_TEST
		var textWarn:BuildDemoText = new BuildDemoText();
		Lib.current.stage.addChild(textWarn);
		#end
	}

	inline public static function getSLEPath(file:String = ''):String
	{
		final finalFile = 'assets/slushiEngineAssets/SLEAssets/$file';
		if (FileSystem.exists(finalFile)) {
			return finalFile;
		}
		else if (finalFile.endsWith('.png'))
		{
			Debug.logSLEWarn('[Image] SLE Path does not exist: $file');
			return finalFile + 'OthersAssets/ImageNotFound.png';
		}
		else if (finalFile.endsWith('.ogg'))
		{
			Debug.logSLEWarn('[Sound or Music] SLE Path does not exist: $file');
			return '';
		}
		else
		{
			Debug.logSLEWarn('SLE Path does not exist: $file');
			return '';
		}
	}

	public static function createEngineUtilsFolder()
	{
		var paths:Array<String> = pathsToCreate;

		for (path in paths)
			if (!FileSystem.exists(path))
				FileSystem.createDirectory(path);
	}

	public static function onCloseWindow()
	{
		Sys.println("\033[0m");
		#if windows
		Debug.logSLEInfo("Reseting all C++ functions...\n\n");
		WindowsFuncs.resetAllCPPFunctions();

		// Delete the saved wallpaper if it exists
		@:privateAccess
		if (FileSystem.exists(WindowsFuncs.savedWallpaperPath))
		{
			FileSystem.deleteFile(WindowsFuncs.savedWallpaperPath);
		}

		// Close the game without animations if it is in a crash, preventing a posible loop
		if (CrashHandler.inCrash)
		{
			Sys.exit(1);
			return;
		}

		Application.current.window.onClose.cancel();

		var numTween:NumTween = FlxTween.num(CppAPI.getWindowOppacity(), 0, 0.7, {
			onComplete: function(twn:FlxTween)
			{
				Sys.exit(0);
			}
		});
		numTween.onUpdate = function(twn:FlxTween)
		{
			CppAPI.setWindowOppacity(numTween.value);
		}
		#else
		Application.current.window.close();
		#end
	}

	public static function getBuildVer()
	{
		if (ClientPrefs.data.checkForUpdates)
		{
			Debug.logSLEInfo('Checking for new version...');
			var http = new haxe.Http("https://raw.githubusercontent.com/Slushi-Github/Slushi-Engine/main/gitVersion.json");
			var jsonData:Dynamic = null;

			http.onData = function(data:String)
			{
				try
				{
					jsonData = Json.parse(data);
				}
				catch (e)
				{
					Debug.logSLEError('Error parsing JSON: $e');
				}

				var currentVersion = slushiEngineVersion;
				var gitVersion = jsonData.engineVersion;
				Debug.logInfo('version online: [' + gitVersion + '], this version: [' + currentVersion + ']');
				if (gitVersion != currentVersion)
				{
					Debug.logSLEWarn('Versions arent matching!');
					SlushiTitleState.gitVersion.needUpdate = true;
					SlushiTitleState.gitVersion.newVersion = gitVersion;
				}
				else
				{
					Debug.logSLEInfo('Versions are matching!');
				}
			}

			http.onError = function(error)
			{
				Debug.logError('Error requesting JSON: $error');
			}

			http.request();
		}

		return "";
	}

	/**
	 * Even though SLE does not require administrator permissions for absolutely nothing, I do NOT want the engine 
	 * to be able to run with those permissions, it DOES NOT NEED THEM.
	 */
	private static function preventAdminExecution()
	{
		#if windows
		if (WindowsCPP.isRunningAsAdmin())
		{
			CppAPI.showMessageBox("SLE is running as an administrator, please don't do that.", "Slushi Engine: HEY!!", MSG_WARNING);
			Sys.exit(1);
		}
		#end
	}
}
