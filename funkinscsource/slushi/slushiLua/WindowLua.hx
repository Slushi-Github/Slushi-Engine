package slushi.slushiLua;

import psychlua.FunkinLua;
import psychlua.LuaUtils;
import cpp.GetRAMSys;

class WindowLua
{
	public static function loadWindowLua(funkLua:FunkinLua)
	{
		Debug.logSLEInfo("Loaded Slushi Window Lua functions!");

		funkLua.set("windowTransparent", function(transparent:Bool, camToApply:String = 'game')
		{
			#if windows
			var blackSprite:FlxSprite = null;
			if (!SlushiLua.apliedWindowTransparent)
			{
				blackSprite = new FlxSprite().makeGraphic(FlxG.width + 20, FlxG.height + 20, FlxColor.fromRGB(25, 25, 25));
				blackSprite.camera = LuaUtils.cameraFromString(camToApply);
				if (PlayState.instance.defaultCamZoom < 1)
					blackSprite.scale.scale(1 / PlayState.instance.defaultCamZoom);
				blackSprite.scrollFactor.set();
				PlayState.instance.add(blackSprite);
			}

			if (transparent)
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
			#else
			printInDisplay("windowTransparent: Platform unsupported for Window transparent!", FlxColor.RED);
			#end
		});

		funkLua.set("setWindowAlpha", function(alpha:Float)
		{
			#if windows
			if (ClientPrefs.data.windowAlpha)
				WindowFuncs.windowAlpha(alpha);
			#else
			printInDisplay("setWindowAlpha: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("doTweenWinAlpha", function(value:Float, duration:Float, ease:String = "linear")
		{
			#if windows
			if (ClientPrefs.data.windowAlpha)
				WindowFuncs.doTweenWindowAlpha(value, duration, ease);
			#else
			printInDisplay("doTweenWinAlpha: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("centerWindow", function()
		{
			WindowFuncs.centerWindow();
		});

		funkLua.set("setMainWindowVisible", function(visible:Bool)
		{
			#if windows
			CppAPI.setWindowVisible(visible);
			#else
			printInDisplay("setMainWindowVisible: Platform unsupported for this function", FlxColor.RED);
			#end
		});

		funkLua.set("windowAlert", function(text:String, title:String)
		{
			WindowFuncs.windowAlert(text, title);
		});

		funkLua.set("resizableWindow", function(mode:Bool)
		{
			WindowFuncs.windowResizable(mode);
		});

		funkLua.set("windowMaximized", function(mode:Bool)
		{
			WindowFuncs.windowMaximized(mode);
		});

		funkLua.set("doTweenWinPos", function(mode:String, tag:String, value:Int, duration:Float, ease:String)
		{
			switch (mode)
			{
				case "X":
					var variables = MusicBeatState.getVariables("Tween");

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
					var variables = MusicBeatState.getVariables("Tween");

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

		// funkLua.set("doubleWindowTweenX", function(offset:Float, duration:Float, ease:String)
		// {
		// 	WindowFuncs.doubleWindowTweenX(offset, duration, ease);
		// });

		funkLua.set("centerWindowTween", function(tag:String, duration:Float, ease:String)
		{
			var variables = MusicBeatState.getVariables("Tween");
			var valueX = Std.int((WindowFuncs.getScreenSizeInWidth() - WindowFuncs.getWindowSizeInWidth()) / 2);
			var valueY = Std.int((WindowFuncs.getScreenSizeInHeight() - WindowFuncs.getWindowSizeInHeight()) / 2);
			tag = LuaUtils.formatVariable('tween_$tag');

			variables.set(tag, FlxTween.tween(Application.current.window, {x: valueX, y: valueY}, duration, {
				ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: function(twn:FlxTween)
				{
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					variables.remove(tag);
				}
			}));
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

		funkLua.set("setWindowTitle", function(text:String)
		{
			WindowFuncs.winTitle(text);
		});

		funkLua.set("getWindowTitle", function():String
		{
			return Application.current.window.title;
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

		funkLua.set("setWindowBorderColor", function(rgb:Array<Int>, mode:Bool = true)
		{
			#if windows
			if (SlushiEngineHUD.instance != null)
			{
				SlushiEngineHUD.instance.canChangeWindowColorWithNoteHit = mode;
			}
			WindowsFuncs.setWindowBorderColor(rgb);
			#end
		});

		funkLua.set("tweenWindowBorderColor", function(fromColor:Array<Int>, toColor:Array<Int>, duration:Float, ease:String = "linear", mode:Bool = true)
		{
			#if windows
			if (SlushiEngineHUD.instance != null)
			{
				SlushiEngineHUD.instance.canChangeWindowColorWithNoteHit = mode;
			}

			WindowsFuncs.tweenWindowBorderColor(fromColor, toColor, duration, ease);
			#end
			});
	}
}
