package slushi.slushiLua;

import psychlua.FunkinLua;
import psychlua.LuaUtils;

class WindowLua
{
	public static function loadWindowLua(funkLua:FunkinLua)
	{
		Debug.logSLEInfo("Loaded Slushi Window Lua functions!");

		funkLua.set("windowTrans", function(trans:Bool, camToApply:String = 'game')
		{
			#if windows
			var blackSprite:FlxSprite = null;
			if (CppAPI.obtainRAM() >= 4096)
			{ // por mis propias pruebas, usar esto con 4 GBs de ram, no es buena idea, asi que mejor lo desactivo si eso pasa
				if (!SlushiLua.apliedWindowTransparent)
				{
					blackSprite = new FlxSprite().makeGraphic(FlxG.width + 20, FlxG.height + 20, FlxColor.fromRGB(25, 25, 25));
					blackSprite.camera = LuaUtils.cameraFromString(camToApply);
					if (PlayState.instance.defaultCamZoom < 1)
						blackSprite.scale.scale(1 / PlayState.instance.defaultCamZoom);
					blackSprite.scrollFactor.set();
					PlayState.instance.add(blackSprite);
				}

				if (trans)
				{
					CppAPI.getWindowsTransparent();
					SlushiLua.apliedWindowTransparent = true;
				}
				else
				{
					PlayState.instance.remove(blackSprite);
					blackSprite.destroy();
					if (SlushiLua.apliedWindowTransparent)
					{
						CppAPI.disableWindowTransparent();
						SlushiLua.apliedWindowTransparent = false;
					}
				}
			}
			else
			{
				printInDisplay("windowTrans: Low RAM for Window transparent!", FlxColor.RED);
			}
			#else
			printInDisplay("windowTrans: Platform unsupported for Window transparent!", FlxColor.RED);
			#end
		});

		funkLua.set("windowAlpha", function(alpha:Float)
		{
			#if windows
			if (ClientPrefs.data.windowAlpha)
				WindowFuncs.windowAlpha(alpha);
			#else
			printInDisplay("WindowAlpha: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("doTweenWinAlpha", function(fromValue:Float, toValue:Float, duration:Float, ease:String = "linear")
		{
			#if windows
			if (ClientPrefs.data.windowAlpha)
				WindowFuncs.doTweenWindowAlpha(fromValue, toValue, duration, ease);
			#else
			printInDisplay("doTweenWinAlpha: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("centerWindow", function()
		{
			#if windows
			CppAPI.centerWindow();
			#else
			printInDisplay("centerWindow: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("setWindowVisible", function(visible:Bool)
		{
			#if windows
			CppAPI.setWindowVisible(visible);
			#else
			printInDisplay("setWindowVisible: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		#if desktop
		funkLua.set("winAlert", function(text:String, title:String)
		{
			WindowFuncs.windowAlert(text, title);
		});

		funkLua.set("canResizableWindow", function(mode:Bool)
		{
			WindowFuncs.windowResizable(mode);
		});

		funkLua.set("windowMaximized", function(mode:Bool)
		{
			WindowFuncs.windowMaximized(mode);
		});

		funkLua.set("DisableCloseButton", function(mode:Bool)
		{
			if (mode)
			{
				Application.current.window.onClose.cancel();
			}
		});

		funkLua.set("doTweenWinPos", function(mode:String, tag:String, value:Int, duration:Float, ease:String)
		{
			switch (mode)
			{
				case "X":
					var variables = MusicBeatState.getVariables();
					var originalTag:String = tag;
					tag = LuaUtils.formatVariable('tween_$tag');

					variables.set(tag, FlxTween.tween(Application.current.window, {x: value}, duration, {
						ease: LuaUtils.getTweenEaseByString(ease),
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
							variables.remove(tag);
						}
					}));
				case "Y":
					var variables = MusicBeatState.getVariables();
					var originalTag:String = tag;
					tag = LuaUtils.formatVariable('tween_$tag');

					variables.set(tag, FlxTween.tween(Application.current.window, {y: value}, duration, {
						ease: LuaUtils.getTweenEaseByString(ease),
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
							variables.remove(tag);
						}
					}));
				default:
					printInDisplay("doTweenWinPos: Invalid mode!", FlxColor.RED);
			}
		});

		funkLua.set("resetWindowParameters", function()
		{
			WindowFuncs.resetWindowParameters();
		});

		funkLua.set("doTweenWinSize", function(mode:String, toValue:Float, duration:Float, ease:String = "linear")
		{
			switch (mode)
			{
				case "WIDTH" | "W":
					WindowFuncs.doTweenWindowWidth(toValue, duration, ease);
				case "HEIGHT" | "H":
					WindowFuncs.doTweenWindowHeight(toValue, duration, ease);
				default:
					printInDisplay("doTweenWinSize: Invalid mode!", FlxColor.RED);
			}
		});

		funkLua.set("winTitle", function(text:String)
		{
			WindowFuncs.winTitle(text);
		});

		funkLua.set("setWindowPos", function(mode:String, value:Int)
		{
			switch (mode)
			{
				case "X":
					WindowFuncs.setWinPositionInX(value);
				case "Y":
					WindowFuncs.setWinPositionInY(value);
				default:
					printInDisplay("setWindowPos: Invalid mode!", FlxColor.RED);
			}
		});

		funkLua.set("getWindowPos", function(mode:String)
		{
			switch (mode)
			{
				case "X":
					return WindowFuncs.getWindowPositionInX();
				case "Y":
					return WindowFuncs.getWindowPositionInY();
				default:
					printInDisplay("getWindowPos: Invalid mode!", FlxColor.RED);
					return 0;
			}
		});

		funkLua.set("getScreenSize", function(mode:String)
		{
			switch (mode)
			{
				case "WIDTH" | "W":
					return WindowFuncs.getScreenSizeInWidth();
				case "HEIGHT" | "H":
					return WindowFuncs.getScreenSizeInHeight();
				default:
					printInDisplay("getScreenSize: Invalid mode!", FlxColor.RED);
					return 0;
			}
		});

		funkLua.set("getWindowSize", function(mode:String)
		{
			switch (mode)
			{
				case "WIDTH" | "W":
					return WindowFuncs.getWindowSizeInWidth();
				case "HEIGHT" | "H":
					return WindowFuncs.getWindowSizeInHeight();
				default:
					printInDisplay("getWindowSize: Invalid mode!", FlxColor.RED);
					return 0;
			}
		});

		funkLua.set("setWindowSize", function(mode:String, value:Int)
		{
			switch (mode)
			{
				case "WIDTH" | "W":
					WindowFuncs.setWinSizeInWidth(value);
				case "HEIGHT" | "H":
					WindowFuncs.setWinSizeInHeight(value);
				default:
					printInDisplay("setWindowSize: Invalid mode!", FlxColor.RED);
			}
		});
		#end

		funkLua.set("setWindowBorderColor", function(r:Int = 0, g:Int = 0, b:Int = 0, mode:Bool = true)
		{
			#if windows
			if (WindowsFuncs.getWindowsVersion() != 0
				&& WindowsFuncs.getWindowsVersion() == 11)
			{
				SlushiEngineHUD.instance.canChangeWindowColorWithNoteHit = mode;
				CppAPI.setWindowBorderColor(r, g, b);
			}
			else
			{
				printInDisplay("setWindowBorderColor: You no are in Windows 11, sorry", FlxColor.RED);
			}
			#end
		});
	}
}
