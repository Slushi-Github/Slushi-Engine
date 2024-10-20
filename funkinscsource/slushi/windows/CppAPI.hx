package slushi.windows;

/**
 * This file only contains the functions that come from WindowsCPP.hx, it should be 
 * the file to use when you require a Windows C++ function.
 * 
 * Author: Slushi
 */

class CppAPI
{
	#if (windows && cpp)
	public static function screenCapture(path:String)
	{
		WindowsCPP.windowsScreenShot(path);
	}

	public static function showMessageBox(message:String, caption:String, icon:MessageBoxIcon = MSG_WARNING)
	{
		WindowsCPP.showMessageBox(caption, message, icon);
	}

	public static function getWindowsTransparent()
	{
		WindowsCPP.getWindowsTransparent();
	}

	public static function disableWindowTransparent()
	{
		WindowsCPP.disableWindowTransparent();
	}

	public static function setWindowVisible(mode:Bool)
	{
		WindowsCPP.setWindowVisible(mode);
	}

	public static function setWindowOppacity(a:Float)
	{
		WindowsCPP.setWindowAlpha(a);
	}

	public static function getWindowOppacity():Float
	{
		return WindowsCPP.getWindowAlpha();
	}

	public static function _setWindowLayered()
	{
		WindowsCPP._setWindowLayered();
	}

	public static function centerWindow()
	{
		WindowsCPP.centerWindow();
	}

	public static function setSlushiColorToWindow()
	{
		return WindowsCPP.setSlushiWindowColor();
	}

	public static function setWindowBorderColor(r:Int, g:Int, b:Int)
	{
		return WindowsCPP.setWindowBorderColor(r, g, b);
	}

	#if SLUSHI_CPP_CODE
	public static function hideTaskbar(hide:Bool)
	{
		WindowsCPP.hideTaskbar(hide);
	}

	public static function setWallpaper(path:String)
	{
		WindowsCPP.setWallpaper(path);
	}

	public static function hideDesktopIcons(hide:Bool)
	{
		WindowsCPP.hideDesktopIcons(hide);
	}

	public static function moveDesktopWindowsInX(x:Int)
	{
		WindowsCPP.moveDesktopWindowsInX(x);
	}

	public static function moveDesktopWindowsInY(y:Int)
	{
		WindowsCPP.moveDesktopWindowsInY(y);
	}

	public static function moveDesktopWindowsInXY(x:Int, y:Int)
	{
		WindowsCPP.moveDesktopWindowsInXY(x, y);
	}

	public static function getDesktopWindowsXPos():Int
	{
		return WindowsCPP.returnDesktopWindowsX();
	}

	public static function getDesktopWindowsYPos():Int
	{
		return WindowsCPP.returnDesktopWindowsY();
	}

	public static function setDesktopWindowsAlpha(alpha:Float)
	{
		WindowsCPP._setDesktopWindowsAlpha(alpha);
	}

	public static function setTaskBarAlpha(alpha:Float)
	{
		WindowsCPP._setTaskBarAlpha(alpha);
	}

	public static function setWindowLayeredMode(window:Int)
	{
		WindowsCPP._setWindowLayeredMode(window);
	}
	#end
	#end
}
