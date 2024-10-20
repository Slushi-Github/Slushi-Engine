package slushi.others;

import haxe.io.Path;

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

	public static function getAllPath():String
	{
		var allPath:String = Path.directory(Sys.programPath()).replace("\\", "/");
		return allPath;
	}

	public static function realResetGame(?arg:String):Void
	{
		#if windows
		new Process("SLE.exe", [arg]);
		Sys.exit(0);
		#else
		Sys.exit(0);
		#end
	}

	public static function setWinBorderColorFromInt(color:Int):Void
	{
		#if windows
		var red:Int = (color >> 16) & 0xFF;
		var green:Int = (color >> 8) & 0xFF;
		var blue:Int = color & 0xFF;
		var rgb:Array<Int> = [red, green, blue];
		WindowsFuncs.setWindowBorderColor(rgb);
		#end
	}

	// Thanks Glowsoony for this code
	public static function getRGBFromFlxColor(red:FlxColor, green:FlxColor, blue:FlxColor):Array<Int>
	{
		// Función para convertir el valor entero a componentes RGB
		function getRGB(color:Int):Array<Int>
		{
			var red = (color >> 16) & 0xFF;
			var green = (color >> 8) & 0xFF;
			var blue = color & 0xFF;
			return [red, green, blue];
		}

		// Convertir cada FlxColor a su representación entera
		var flxColorRed = cast red; // No es necesario volver a convertir desde RGB si ya tienes un FlxColor
		var flxColorGreen = cast green;
		var flxColorBlue = cast blue;

		// Obtener los valores RGB de cada color
		var redRGB = getRGB(flxColorRed);
		var greenRGB = getRGB(flxColorGreen);
		var blueRGB = getRGB(flxColorBlue);

		// Devolver el arreglo con los componentes RGB
		return [redRGB[0], greenRGB[1], blueRGB[2]];
	}
}