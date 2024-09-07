package slushi;

import flixel.FlxGame;
import flixel.FlxState;
import slushi.slushiUtils.CrashHandler;
import slushi.winSL.WinSLCrashHandler;
import slushi.substates.DebugSubState;

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
	public static var alredyOpen:Bool = false;
	static var numberOfCrashes:Int = 0;

	override public function switchState():Void
	{
		#if windows
		WindowsFuncs.resetAllCPPFunctions();
		WindowFuncs.resetWindowParameters();
		#end

		try
		{
			try
			{
				oldState = _state;
				super.switchState();

				FlxG.autoPause = false;

				numberOfCrashes = 0;

				alredyOpen = false;
			}
			catch (error)
			{
				if (!alredyOpen)
				{
					CrashHandler.symbolPrevent(error);
					alredyOpen = true;
				}
			}
		}
		catch (error)
		{
			WinSLCrashHandler.onVMCrash(error);
		}
	}

	override public function update()
	{
		if (FlxG.keys.justPressed.F3)
		{
			if (Type.getClass(FlxG.state) == PlayState)
				DebugSubState.onPlayState = true;
			else
				DebugSubState.onPlayState = false;
			FlxG.state.openSubState(new DebugSubState());
		}

		WindowsCPP.reDefineEngineWindowTitle(Application.current.window.title);

		try
		{
			try
			{
				super.update();
			}
			catch (error)
			{
				if (!alredyOpen)
				{
					CrashHandler.symbolPrevent(error);
					alredyOpen = true;
				}
			}
		}
		catch (error)
		{
			WinSLCrashHandler.onVMCrash(error);
		}
	}
}