package slushi.others;

import haxe.io.Path;
import slushi.others.systemUtils.HiddenProcess;

/**
 * This class contains custom functions for the engine, but not usually used in the engine itself
 * 
 * Author: Slushi
 */
class CustomFuncs
{
	public static function getTime():String
	{
		var timeNow = Date.now();
		var hour = timeNow.getHours();
		var minute = timeNow.getMinutes();
		var second = timeNow.getSeconds();
		var all = hour + ":" + (minute < 10 ? "0" : "") + minute + ":" + (second < 10 ? "0" : "") + second;

		return all;
	}

	public static function getDate():String
	{
		var dateNow = Date.now();
		var year = dateNow.getFullYear();
		var mouth = dateNow.getMonth() + 1;
		var day = dateNow.getDate();
		var all = year + "-" + (mouth < 10 ? "0" : "") + mouth + "-" + (day < 10 ? "0" : "") + day;

		return all;
	}

	public static function getProgramPath():String
	{
		var allPath:String = Path.directory(Sys.programPath()).replace("\\", "/");
		return allPath;
	}

	public static function realResetGame(?args:Array<String> = null):Void
	{
		new HiddenProcess(Sys.programPath(), args);
		System.exit(0);
	}

	public static function parseVersion(version:String):Int
	{
		var parts = version.split(".");
		var major = Std.parseInt(parts[0]);
		var minor = parts.length > 1 ? Std.parseInt(parts[1]) : 0;
		var patch = parts.length > 2 ? Std.parseInt(parts[2]) : 0;
		return (major * 10000) + (minor * 100) + patch; // Ej: "1.2.3" -> 10203
	}

	public static function removeAllFilesFromCacheDirectory():Void
	{
		final path = "./assets/slushiEngineAssets/OthersAssets/SLCache";
		try
		{
			if (FileSystem.exists(path))
			{
				var directory = FileSystem.readDirectory(path);
				for (file in directory)
				{
					FileSystem.deleteFile(Path.join([path, file]));
				}
			}
		}
		catch (e:Dynamic)
		{
			Debug.logError('Error removing files from cache directory: $e');
		}
	}

	public static function colorIntToRGB(color:Int):Array<Int>
		{
			var red:Int = (color >> 16) & 0xFF;
			var green:Int = (color >> 8) & 0xFF;
			var blue:Int = color & 0xFF;
			var rgb:Array<Int> = [red, green, blue];
			return rgb;
		}
}
