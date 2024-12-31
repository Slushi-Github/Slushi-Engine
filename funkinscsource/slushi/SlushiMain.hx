package slushi;

import slushi.others.CustomFuncs;
import slushi.others.systemUtils.SystemInfo;
import slushi.others.BuildDemoText;
import slushi.slushiUtils.crashHandler.CrashHandler;
import tjson.TJSON as Json;
import slushi.states.SlushiTitleState;
import slushi.windows.winGDIThings.WinGDIThread;
import haxe.Http;
import slushi.others.EngineMacros;

/*
 * This is the main class for the Slushi Engine initialization, this loads all initial functions of Windows C++ API
 * and have variables like buildNumber (number of the build of the engine) or slushiEngineVersion (the version of the engine).
 *
 * Author: Slushi
 */
class SlushiMain
{
	// Versions of the things in the engine and SCE
	public static var buildNumber:String = EngineMacros.prepareBuildNumber();
	public static var sceGitCommit:String = "4eaf8c4";
	public static var slushiEngineVersion:String = '0.4.0';
	public static var sleThingsVersions = {
		winSLVersion: '1.3.0',
		slCrashHandlerVersion: '1.4.0'
	};

	public static var slushiColor:FlxColor = FlxColor.fromRGB(143, 217, 209); // 0xff8FD9D1 0xffd6f3de
	private static var pathsToCreate:Array<String> = ['./slEngineUtils', './slEngineUtils/SMToConvert', './mods/images/windowsAssets/'];

	public static function loadSlushiEngineFunctions()
	{
		#if windows
		preventAdminExecution();
		CppAPI._setWindowLayered();
		WindowsFuncs.resetAllCPPFunctions();
		WindowsFuncs.saveCurrentWindowsWallpaper();
		if (ClientPrefs.data.useSavedWallpaper)
		{
			WindowsFuncs.saveCopyOfSavedWindowsWallpaper();
		}
		WindowsFuncs.setSlushiColorToWindow();
		#end
		WindowFuncs.centerWindow();
		CrashHandler.initCrashHandler();
		SystemInfo.init();
		createSLEngineFolders();
		Application.current.window.onClose.add(SlushiMain.onCloseWindow);

		#if THIS_IS_A_BUILD_TEST
		var textWarn:BuildDemoText = new BuildDemoText();
		Lib.current.stage.addChild(textWarn);
		#end
	}

	inline public static function getSLEPath(file:String = ''):String
	{
		final finalFile = 'assets/slushiEngineAssets/$file';
		if (FileSystem.exists(finalFile))
		{
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

	private static function createSLEngineFolders()
	{
		for (path in pathsToCreate)
		{
			try
			{
				if (!FileSystem.exists(path))
				{
					FileSystem.createDirectory(path);
				}
			}
			catch (e)
			{
				Debug.logSLEError('Error creating [$path]: $e');
			}
		}
	}

	public static function onCloseWindow()
	{
		Sys.println("\033[0m");
		CustomFuncs.removeAllFilesFromCacheDirectory();
		#if windows
		Debug.logSLEInfo("Reseting all C++ functions...\n");
		WinGDIThread.stopThread();
		WindowsFuncs.resetAllCPPFunctions();

		// Delete the saved wallpaper if it exists
		@:privateAccess
		try
		{
			if (FileSystem.exists(WindowsFuncs.savedWallpaperPath))
			{
				FileSystem.deleteFile(WindowsFuncs.savedWallpaperPath);
			}
		}
		catch (e)
		{
			Debug.logSLEError('Error deleting saved wallpaper: $e');
		}

		// Close the game without animations if it is in a crash, preventing a posible loop
		if (CrashHandler.inCrash)
		{
			System.exit(1);
			return;
		}

		Application.current.window.onClose.cancel();

		var numTween:NumTween = FlxTween.num(CppAPI.getWindowOppacity(), 0, 0.6, {
			onComplete: function(twn:FlxTween)
			{
				System.exit(0);
			}
		});
		numTween.onUpdate = function(twn:FlxTween)
		{
			CppAPI.setWindowOppacity(numTween.value);
		}
		#else
		System.exit(0);
		#end
	}

	public static function getBuildVer()
	{
		if (ClientPrefs.data.checkForUpdates)
		{
			Debug.logSLEInfo('Checking for new version...');
			var http = new Http("https://raw.githubusercontent.com/Slushi-Github/Slushi-Engine/main/gitVersion.json");
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
					return;
				}

				var currentVersion = slushiEngineVersion;
				var gitVersion = jsonData.engineVersion;

				Debug.logSLEInfo('Version online: [' + gitVersion + '], this version: [' + currentVersion + ']');

				var currentVersionNum = CustomFuncs.parseVersion(currentVersion);
				var gitVersionNum = CustomFuncs.parseVersion(gitVersion);

				if (currentVersionNum > gitVersionNum)
				{
					Debug.logSLEInfo('The version is higher than the one on Github so this is a development version, skipping update check.');
					SlushiTitleState.gitVersion.needUpdate = false;
					slushiEngineVersion += ' - [DEV]';
				}
				else if (currentVersionNum < gitVersionNum)
				{
					Debug.logSLEWarn('A new version is available!');
					SlushiTitleState.gitVersion.needUpdate = true;
					SlushiTitleState.gitVersion.newVersion = gitVersion;
				}
				else
				{
					Debug.logSLEInfo('Versions are matching!');
					SlushiTitleState.gitVersion.needUpdate = false;
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
	 * 
	 * Except when running SLE on Linux or MacOS through Wine, Wine will always run a 
	 * Windows program with administrator permissions apparently, making it 
	 * impossible to run SLE this way before.
	 */
	private static function preventAdminExecution()
	{
		#if windows
		if (WindowsCPP.detectWine())
		{
			Debug.logSLEWarn("Wine detected! Skipping admin check because Wine always runs as admin.");
			return;
		}

		if (WindowsCPP.isRunningAsAdmin())
		{
			CppAPI.showMessageBox("SLE is running as an administrator, please don't do that.", "Slushi Engine: HEY!!", MSG_WARNING);
			System.exit(1);
		}
		#end
	}
}
