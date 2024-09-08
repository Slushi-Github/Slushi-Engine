package slushi.others;

/**
 * This class contains custom functions for the engine, but not usually used in the engine itself
 * 
 * Author: Slushi
 */

class CustomFuncs
{
	public static function getTime()
	{
		var timeNow = Date.now();
		var hour = timeNow.getHours();
		var minute = timeNow.getMinutes();
		var second = timeNow.getSeconds();
		var all = hour + ":" + (minute < 10 ? "0" : "") + minute + ":" + (second < 10 ? "0" : "") + second;

		return all;
	}

	public static function getDate()
	{
		var dateNow = Date.now();
		var year = dateNow.getFullYear();
		var mouth = dateNow.getMonth() + 1;
		var day = dateNow.getDate();
		var all = year + "-" + (mouth < 10 ? "0" : "") + mouth + "-" + (day < 10 ? "0" : "") + day;

		return all;
	}

	public static function getAllPath():String
	{
		var allPath:String = Sys.getCwd();
		allPath = allPath.split("\\").join("/");

		return allPath;
	}

	public static function realResetGame(?arg:String):Void
	{
		new Process("SLE.exe", [arg]);
		Sys.exit(0);
	}

	public static function setWinBorderColorFromInt(color:Int):Void {
		#if windows
		var red:Int = (color >> 16) & 0xFF;
		var green:Int = (color >> 8) & 0xFF;
		var blue:Int = color & 0xFF;
		var rgb:Array<Int> = [red, green, blue];
		WindowsFuncs.setWindowBorderColor(rgb);
		#end
	}
}
