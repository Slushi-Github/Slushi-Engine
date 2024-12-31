package slushi.slushiUtils.crashHandler;

import flixel.system.scaleModes.*;
import flixel.group.FlxGroup;
import states.StoryMenuState;
import states.freeplay.FreeplayState;
import states.MainMenuState;
import slushi.states.freeplay.SlushiFreeplayState;

class GameplayCrashHandler
{
	static var camCrashHandler:FlxCamera;
	public static var assetGrp:FlxGroup;

	public static function crashHandlerTerminal(text:String = "")
	{
		if (!CrashHandler.createdCrashInGame)
		{
			CrashHandler.createdCrashInGame = true;
		}
		else
		{
			return;
		}

		// Stop the PlayState, to avoid a loop if the crash occurred in an update function
		if (Type.getClass(FlxG.state) == PlayState)
			{
				PlayState.instance.paused = true;
			}

		WindowFuncs.winTitle("Slushi Engine: Crash Handler Mode");
		WindowFuncs.resetWindowParameters();
		WindowsFuncs.setWindowBorderColor([0, 46, 114]);
		if (Main.fpsVar != null)
			Main.fpsVar.visible = false;
		FlxG.mouse.useSystemCursor = false;
		FlxG.mouse.visible = false;
		WindowFuncs.windowResizable(false);

		camCrashHandler = new FlxCamera();
		camCrashHandler.bgColor.alpha = 0;
		FlxG.cameras.add(camCrashHandler, false);

		assetGrp = new FlxGroup();
		FlxG.state.add(assetGrp);

		assetGrp.camera = camCrashHandler;

		var contents:String = text;

		var split:Array<String> = contents.split("\n");

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width + 100, FlxG.height + 100, FlxColor.BLACK);
		bg.scrollFactor.set();
		assetGrp.add(bg);
		bg.alpha = 0.7;

		var watermark = new FlxText(10, 0, 0, "Slushi Engine Crash Handler [v" + SlushiMain.sleThingsVersions.slCrashHandlerVersion + "] by Slushi");
		watermark.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		watermark.scrollFactor.set();
		watermark.borderSize = 1.25;
		watermark.antialiasing = true;
		assetGrp.add(watermark);

		var text0 = new FlxText(10, watermark.y + 20, 0, "Slushi Engine [" + SlushiMain.slushiEngineVersion + "]");
		text0.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text0.scrollFactor.set();
		text0.borderSize = 1.25;
		assetGrp.add(text0);
		text0.visible = false;

		var text1 = new FlxText(10, text0.y + 30, 0, "SYSTEM CRASH.\nCrash log:");
		text1.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text1.scrollFactor.set();
		text1.color = FlxColor.RED;
		text1.borderSize = 1.25;
		assetGrp.add(text1);
		text1.visible = false;

		var crashtext = new FlxText(10, text1.y + 37, 0, '');
		crashtext.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		crashtext.scrollFactor.set();
		crashtext.borderSize = 1.25;
		crashtext.antialiasing = true;
		crashtext.visible = false;
		for (i in 0...split.length - 0)
		{
			if (i == split.length - 18)
				crashtext.text += split[i];
			else
				crashtext.text += split[i] + "\n";
		}
		assetGrp.add(crashtext);

		var text2 = new FlxText(10, crashtext.height + 115, 0, "");
		text2.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text2.scrollFactor.set();
		text2.borderSize = 1.25;
		text2.text = "LOADING PREVIOUS STATE: [" + Type.getClassName(Type.getClass(MainGame.oldState)) + "]...";
		text2.color = SlushiMain.slushiColor;
		assetGrp.add(text2);
		text2.visible = false;

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			text0.visible = true;
			FlxG.sound.play(SlushiMain.getSLEPath("Sounds/beep.ogg"));
		});

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			text1.visible = true;
			FlxG.sound.play(SlushiMain.getSLEPath("Sounds/beep2.ogg"));
		});

		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			crashtext.visible = true;
			text2.visible = true;
			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				if (Main.fpsVar != null)
					Main.fpsVar.visible = ClientPrefs.data.showFPS;
				WindowFuncs.windowResizable(true);
				WindowFuncs.winTitle("default");

				if (Type.getClass(FlxG.state) == PlayState)
				{
					if (PlayState.isStoryMode)
					{
						MainGame.crashHandlerAlredyOpen = false;
						MusicBeatState.switchState(new StoryMenuState());
						CrashHandler.inCrash = false;
						CrashHandler.createdCrashInGame = false;
						CrashHandler.crashes = 0;
					}
					else
					{
						MainGame.crashHandlerAlredyOpen = false;
						MusicBeatState.switchState(new SlushiFreeplayState());
						CrashHandler.inCrash = false;
						CrashHandler.createdCrashInGame = false;
						CrashHandler.crashes = 0;
					}
				}
				else
				{
					MainGame.crashHandlerAlredyOpen = false;
					FlxG.switchState(Type.createInstance(Type.getClass(MainGame.oldState), []));
					CrashHandler.inCrash = false;
					CrashHandler.createdCrashInGame = false;
					CrashHandler.crashes = 0;
				}

				for (obj in assetGrp)
				{
					if (obj != null)
					{
						obj.destroy();
					}
				}

				if (camCrashHandler != null)
				{
					camCrashHandler.destroy();
				}

				Paths.clearUnusedMemory();
			});
		});
	}
}