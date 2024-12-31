package slushi.windows.winGDIThings;

import sys.thread.Thread;

/*
 * This class starts an external thread to the main one of the engine, it is used so that 
 * Windows GDI effects do not generate lag in the game due to the fact that they consume quite some
 * 
 * Author: Slushi
 */
class WinGDIThread
{
	public static var mainThread:Thread;
	public static var gdiEffects:Map<String, SlushiWinGDIEffectData> = [];
	public static var runningThread:Bool = true;
	public static var elapsedTime:Float = 0;
	public static var temporarilyPaused:Bool = false;

	public static function initThread()
	{
		if (mainThread != null)
			return;

		Debug.logSLEInfo('Starting Windows GDI Thread...');

		mainThread = Thread.create(() ->
		{
			Debug.logSLEInfo('Windows GDI Thread running...');
			while (runningThread)
			{
				/**
				 * Check if the game is focused or if the PlayState is paused or the player is dead
				 * This prevents GDI effects from continuing to be generated at times when they should not be
				 */
				if (!Main.focused)
				{
					return;
				}
				if (PlayState.instance != null)
				{
					if (PlayState.instance.paused)
					{
						return;
					}
					else if (PlayState.instance.isDead)
					{
						return;
					}
				}
				if (temporarilyPaused)
				{
					return;
				}

				elapsedTime++;
				SlushiWinGDI.setElapsedTime(elapsedTime);

				for (gdi in gdiEffects)
				{
					if (!gdi.enabled)
						continue;

					if (gdi.wait > 0)
					{
						// Wait if wait time is greater than 0, slows down the effect
						Sys.sleep(gdi.wait);
					}
					gdi.gdiEffect.update();
				}
			}
		});
	}

	public static function stopThread()
	{
		if (mainThread != null)
		{
			Debug.logSLEInfo('Stopping Windows GDI Thread...');
			runningThread = false;
			temporarilyPaused = false;
			mainThread = null;
		}
		gdiEffects.clear();
		elapsedTime = 0;
		SlushiWinGDI.setElapsedTime(elapsedTime);
	}
}
