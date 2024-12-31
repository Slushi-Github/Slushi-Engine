package slushi;

import flixel.FlxGame;
import flixel.FlxState;
import slushi.slushiUtils.crashHandler.CrashHandler;
import slushi.substates.DebugSubState;
import slushi.windows.winGDIThings.WinGDIThread;

/*
 * This class is the base game, the FlxGame, modified to make the in-game crash handler that contains the Slushi Engine functional.
 * In addition to having functions to reset changes in the window or the Windows C++ API every time the game changes state and etc...
 *
 * This file is modified for specific use in Slushi Engine
 *
 * Authors: Edwhak_KillBot, Niz, and Slushi
 */
class MainGame extends FlxGame
{
	public static var oldState:FlxState;
	public static var crashHandlerAlredyOpen:Bool = false;

	override public function switchState():Void
	{
		#if windows
		WindowsFuncs.resetAllCPPFunctions();
		WindowFuncs.resetWindowParameters();
		WinGDIThread.stopThread();
		#end

		try
		{
			oldState = _state;
			super.switchState();

			FlxG.autoPause = false;
			crashHandlerAlredyOpen = false;
		}
		catch (error)
		{
			if (!crashHandlerAlredyOpen)
			{
				CrashHandler.symbolPrevent(error, 0);
				crashHandlerAlredyOpen = true;
			}
		}
	}

	override public function update()
	{
		if (FlxG.keys.justPressed.F3)
		{
			if (Type.getClass(FlxG.state) == PlayState)
			{
				DebugSubState.onPlayState = true;
			}
			else
			{
				DebugSubState.onPlayState = false;
			}
			FlxG.state.openSubState(new DebugSubState());
		}

		#if windows
		WindowsCPP.reDefineEngineWindowTitle(Application.current.window.title);
		#end

		try
		{
			super.update();
		}
		catch (error)
		{
			if (!crashHandlerAlredyOpen)
			{
				CrashHandler.symbolPrevent(error, 1);
				crashHandlerAlredyOpen = true;
			}
		}
	}

	override function draw():Void
	{
		try
		{
			super.draw();
			crashHandlerAlredyOpen = false;
		}
		catch (error)
		{
			if (!crashHandlerAlredyOpen)
			{
				CrashHandler.symbolPrevent(error, 2);
				crashHandlerAlredyOpen = true;
			}
		}
	}
}
