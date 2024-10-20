package slushi.windowThings;

import flixel.tweens.misc.NumTween;

/*
 * This file contains the functions for the window, there are functions for changing the window position and size, simple class
 * 
 * Author: Slushi
 */
class WindowFuncs
{
	public static var windowX:Int = 0;
	public static var windowY:Int = 0;

	public static function setWinPositionInX(xValue:Int)
	{
		Application.current.window.x = xValue;
	}

	public static function setWinPositionInY(yValue:Int)
	{
		Application.current.window.y = yValue;
	}

	public static function setWinSizeInWidth(width:Int)
	{
		Application.current.window.width = width;
	}

	public static function setWinSizeInHeight(height:Int)
	{
		Application.current.window.height = height;
	}

	public static function windowBorderless(mode:Bool)
	{
		Application.current.window.borderless = mode;
	}

	public static function windowAlert(text:String, title:String)
	{
		Application.current.window.alert(text, title);
	}

	public static function getWindowPositionInX()
	{
		return Application.current.window.x;
	}

	public static function getWindowPositionInY()
	{
		return Application.current.window.y;
	}

	public static function getWindowSizeInWidth()
	{
		return Application.current.window.width;
	}

	public static function getWindowSizeInHeight()
	{
		return Application.current.window.height;
	}

	public static function getScreenSizeInWidth()
	{
		return Application.current.window.display.bounds.width;
	}

	public static function getScreenSizeInHeight()
	{
		return Application.current.window.display.bounds.height;
	}

	public static function windowResizable(mode:Bool)
	{
		Application.current.window.resizable = mode;
	}

	public static function windowMaximized(mode:Bool)
	{
		Application.current.window.maximized = mode;
	}

	public static function winTitle(text:String)
	{
		if (text == "default" || text == "" || text == null)
		{
			Application.current.window.title = Application.current.meta.get('name');
			return;
		}

		Application.current.window.title = text;
	}

	public static function windowDimWidth(width:Int)
	{
		Application.current.window.width = width;
	}

	public static function windowDimHeight(height:Int)
	{
		Application.current.window.height = height;
	}

	public static function reziseWindow(width:Int, height:Int)
	{
		Application.current.window.resize(width, height);
	}

	public static function windowAlpha(alpha:Float)
	{
		#if windows
		CppAPI.setWindowOppacity(alpha);
		#end
	}

	public static function doTweenWindowAlpha(toValue:Float, duration:Float, ease:String = "linear")
	{
		#if windows
		var startValue:Float = CppAPI.getWindowOppacity();
		var numTween:NumTween = FlxTween.num(startValue, toValue, duration, {ease: psychlua.LuaUtils.getTweenEaseByString(ease)});
		numTween.onUpdate = function(twn:FlxTween)
		{
			CppAPI.setWindowOppacity(numTween.value);
		}
		#end
	}

	public static function doTweenWindowWidth(toValue:Float, duration:Float, ease:String = "linear")
	{
		var numTween:NumTween = FlxTween.num(getWindowSizeInWidth(), toValue, duration, {ease: psychlua.LuaUtils.getTweenEaseByString(ease)});
		numTween.onUpdate = function(twn:FlxTween)
		{
			Application.current.window.width = Std.int(numTween.value);
		}
	}

	public static function doTweenWindowHeight(toValue:Float, duration:Float, ease:String = "linear")
	{
		var numTween:NumTween = FlxTween.num(getWindowSizeInHeight(), toValue, duration, {ease: psychlua.LuaUtils.getTweenEaseByString(ease)});
		numTween.onUpdate = function(twn:FlxTween)
		{
			Application.current.window.height = Std.int(numTween.value);
		}
	}

	public static function resetWindowParameters()
	{
		#if windows
		WindowsFuncs.setSlushiColorToWindow();
		#end

		if (!Application.current.window.maximized || !Application.current.window.fullscreen)
		{
			#if windows
			CppAPI.centerWindow();
			#else
			setWinPositionInX(Std.int((getScreenSizeInWidth() - getWindowSizeInWidth()) / 2));
			setWinPositionInY(Std.int((getScreenSizeInHeight() - getWindowSizeInHeight()) / 2));
			#end
		}

		if (!Application.current.window.resizable)
		{
			windowResizable(true);
		}
		if (!Application.current.window.borderless)
		{
			windowBorderless(false);
		}
		windowAlpha(1);
		winTitle("default");
	}
}
