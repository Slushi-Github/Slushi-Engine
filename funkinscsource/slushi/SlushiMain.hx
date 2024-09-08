package slushi;

import slushi.others.CustomFuncs;
import slushi.others.systemUtils.SystemInfo;
import slushi.others.BuildDemoText;
import slushi.slushiUtils.CrashHandler;
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
	public static var buildNumber:String = "07092024";
	public static var sceGitCommit:String = "99701c5";
	public static var slushiColor = FlxColor.fromRGB(143, 217, 209); // 0xff8FD9D1 0xffd6f3de
	public static var slushiEngineVersion:String = '0.3.4';
	public static var winSLVersion:String = '1.3';

	public static function loadSlushiEngineFunctions()
	{
		#if windows
		preventAdminExecution();
		CppAPI._setWindowLayered();
		CppAPI.centerWindow();
		WindowsFuncs.resetAllCPPFunctions();
		WindowsFuncs.saveCurrentWindowsWallpaper();
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
		if (FileSystem.exists(finalFile))
			return finalFile;
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
		var paths:Array<String> = ['./engineUtils', './engineUtils/SMToConvert'];

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

		// Close the game without animations
		if (CrashHandler.inCrash)
		{
			Sys.exit(0);
			return;
		}

		Application.current.window.onClose.cancel();

		var numTween:NumTween = FlxTween.num(1, 0, 0.7, {
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
			var http = new haxe.Http("https://github.com/Slushi-Github/Slushi-Engine/blob/main/gitVersion.json");
			var jsonData:Dynamic = null;

			http.onData = function(data:String)
			{
				try
				{
					jsonData = Json.parse(data);
				}
				catch (e)
				{
					Debug.logSLEError('Error parsing JSON or JSON does not exist: $e');
				}

				var currentVersion = slushiEngineVersion;
				var gitVersion = jsonData.engineVersion;
				Debug.logInfo('version online: [' + gitVersion + '], this version: [' + currentVersion + ']');
				if (gitVersion != currentVersion)
				{
					Debug.logSLEWarn('Versions arent matching!');
					slushi.states.SlushiTitleState.gitVersion.needUpdate = true;
					slushi.states.SlushiTitleState.gitVersion.newVersion = gitVersion;
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

	private static function preventAdminExecution()
	{
		#if windows
		if(WindowsCPP.isRunningAsAdmin()){
			CppAPI.showMessageBox("SLE is running as an administrator, please don't do that.", "Slushi Engine: HEY!", MSG_WARNING);
			Sys.exit(0);
		}
		#end
	}
}
