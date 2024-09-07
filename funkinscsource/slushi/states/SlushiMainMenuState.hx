package slushi.states;

import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxFilterFrames;
import flash.filters.GlowFilter;
import slushi.substates.ConsoleSubState;

import states.CreditsState;
import states.MainMenuState;
import states.editors.MasterEditorMenu;
import states.freeplay.FreeplayState;
import states.StoryMenuState;
import options.OptionsState;
import states.ModsMenuState;

/**
 * The main menu state for Slushi Engine
 * 
 * Author: Slushi
 */

class SlushiMainMenuState extends MusicBeatState
{
	public static final psychEngineVersion:String = MainMenuState.psychEngineVersion;
	public static var SCEVersion:String = MainMenuState.SCEVersion;
	public static var slushiEngineVersion:String = SlushiMain.slushiEngineVersion;

	public static var SLELogo:FlxSprite;

	public static var inConsole:Bool = false;
	public static var slebg:FlxSprite;

	// OPTIONS ///////////////////////////////
	public var freeplaySprite:FlxSprite; // 0
	public var storyModeSprite:FlxSprite; // 1
	public var modsSprite:FlxSprite; // 2
	public var creditsSprite:FlxSprite; // 3
	public var optionsSprite:FlxSprite; // 4

	var sleLogoCamShader:ThreeDEffect;

	var finishedIntro:Bool = false;
	var clickedOption:Bool = false;
	var danceIntro:Bool = false;
	var shaderSpeed:Int = 4;
	var sineElap:Float = 0;
	var numTween:NumTween;

	var camOther:FlxCamera;
	var camSLELogo:FlxCamera;
	var camOptions:FlxCamera;

	var sprFilter0:FlxFilterFrames;
	var sprFilter1:FlxFilterFrames;
	var sprFilter2:FlxFilterFrames;
	var sprFilter3:FlxFilterFrames;
	var sprFilter4:FlxFilterFrames;

	var glowFilter0:GlowFilter;
	var glowFilter1:GlowFilter;
	var glowFilter2:GlowFilter;
	var glowFilter3:GlowFilter;
	var glowFilter4:GlowFilter;

	//////////////////////////////////////////

	override public function create()
	{
		super.create();

		persistentUpdate = true;
		
		camOther = new FlxCamera();
		camOptions = new FlxCamera();
		camSLELogo = new FlxCamera();
		camOther.bgColor.alpha = 0;
		camSLELogo.bgColor.alpha = 0;
		camOptions.bgColor.alpha = 0;
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(camSLELogo, false);
		FlxG.cameras.add(camOptions, false);

		sleLogoCamShader = new ThreeDEffect();

		camSLELogo.setFilters([new ShaderFilter(sleLogoCamShader.shader)]);

		slebg = new FlxSprite(0, 0).loadGraphic(SlushiMain.getSLEPath('BGs/SlushiBGMainMenu.png'));
		slebg.scrollFactor.set();
		slebg.antialiasing = ClientPrefs.data.antialiasing;
		slebg.camera = camOther;
		add(slebg);

		var SLELogo = new FlxSprite(0, 0).loadGraphic(SlushiMain.getSLEPath('SlushiEngineLogoSCE.png'));
		SLELogo.setGraphicSize(Std.int(SLELogo.width * 0.8));
		SLELogo.antialiasing = ClientPrefs.data.antialiasing;
		add(SLELogo);
		SLELogo.alpha = 0;
		SLELogo.y += 20;
		SLELogo.camera = camSLELogo;

		freeplaySprite = new FlxSprite(0, 0).loadGraphic(SlushiMain.getSLEPath('SlushiMainMenuAssets/FreeplayOption.png'));
		freeplaySprite.antialiasing = ClientPrefs.data.antialiasing;
		freeplaySprite.screenCenter();
		freeplaySprite.y -= 230;
		add(freeplaySprite);
		freeplaySprite.camera = camOptions;

		storyModeSprite = new FlxSprite(0, 0).loadGraphic(SlushiMain.getSLEPath('SlushiMainMenuAssets/StoryModeOption.png'));
		storyModeSprite.antialiasing = ClientPrefs.data.antialiasing;
		storyModeSprite.screenCenter();
		storyModeSprite.x -= 430;
		add(storyModeSprite);
		storyModeSprite.camera = camOptions;

		modsSprite = new FlxSprite(0, 0).loadGraphic(SlushiMain.getSLEPath('SlushiMainMenuAssets/ModsOption.png'));
		modsSprite.antialiasing = ClientPrefs.data.antialiasing;
		modsSprite.screenCenter();
		modsSprite.x = storyModeSprite.x + 850;
		add(modsSprite);
		modsSprite.camera = camOptions;

		creditsSprite = new FlxSprite(0, 0).loadGraphic(SlushiMain.getSLEPath('SlushiMainMenuAssets/CreditsOption.png'));
		creditsSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(creditsSprite);
		creditsSprite.screenCenter();
		creditsSprite.y += 240;
		creditsSprite.x -= 260;
		creditsSprite.camera = camOptions;

		optionsSprite = new FlxSprite(0, 0).loadGraphic(SlushiMain.getSLEPath('SlushiMainMenuAssets/OptionsOption.png'));
		optionsSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(optionsSprite);
		optionsSprite.screenCenter();
		optionsSprite.y = creditsSprite.y;
		optionsSprite.x += creditsSprite.x + 100;
		optionsSprite.camera = camOptions;

		for (i in [freeplaySprite, storyModeSprite, modsSprite, creditsSprite, optionsSprite])
		{
			i.alpha = 0.8;
			i.setGraphicSize(Std.int(i.width * 0.8));
		}

		glowFilter0 = new GlowFilter(SlushiMain.slushiColor, 1, 40, 40, 1.5, 1);
		glowFilter1 = new GlowFilter(SlushiMain.slushiColor, 1, 40, 40, 1.5, 1);
		glowFilter2 = new GlowFilter(SlushiMain.slushiColor, 1, 40, 40, 1.5, 1);
		glowFilter3 = new GlowFilter(SlushiMain.slushiColor, 1, 40, 40, 1.5, 1);
		glowFilter4 = new GlowFilter(SlushiMain.slushiColor, 1, 40, 40, 1.5, 1);
		sprFilter0 = createFilterFrames(freeplaySprite, glowFilter0);
		sprFilter1 = createFilterFrames(storyModeSprite, glowFilter1);
		sprFilter2 = createFilterFrames(modsSprite, glowFilter2);
		sprFilter3 = createFilterFrames(creditsSprite, glowFilter3);
		sprFilter4 = createFilterFrames(optionsSprite, glowFilter4);

		for (i in [glowFilter0, glowFilter1, glowFilter2, glowFilter3, glowFilter4])
		{
			i.blurX = 0;
			i.blurY = 0;
		}

		var sceVer:FlxText = new FlxText(10, FlxG.height - 22, 0, "SC Engine v" + SCEVersion + ' (${SlushiMain.sceGitCommit})', 12);
		sceVer.scrollFactor.set();
		sceVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(sceVer);
		var sleVer:FlxText = new FlxText(10, FlxG.height - 42, 0, "Slushi Engine v" + SlushiMain.slushiEngineVersion, 12);
		sleVer.scrollFactor.set();
		sleVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(sleVer);

		for (i in [sceVer, sleVer])
		{
			i.alpha = 0;
			i.x -= 20;
			i.camera = camOther;
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			FlxTween.tween(camSLELogo, {alpha: 1, y: SLELogo.y - 20}, 0.7, {
				ease: FlxEase.linear,
				onComplete: function(tween:FlxTween)
				{
					FlxTween.tween(SLELogo, {alpha: 0.4}, 0.5, {ease: FlxEase.linear});
					FlxTween.tween(camSLELogo, {zoom: 0.8}, 0.8, {ease: FlxEase.linear});
					for (i in [sceVer, sleVer])
					{
						FlxTween.tween(i, {alpha: 1, x: i.x + 20}, 0.5, {ease: FlxEase.linear});
					}
					finishedIntro = true;
				}
			});
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (finishedIntro)
		{
			if (!clickedOption)
			{
				sineElap = sineElap + (elapsed * shaderSpeed);
				sleLogoCamShader.shader.yrot.value = [Math.sin(sineElap) / 12];
				sleLogoCamShader.shader.xrot.value = [Math.sin(sineElap + 2) / 12];
			}

			onCursorClick();

			// if (FlxG.keys.justPressed.F2)
			// {
			// 	if (inConsole)
			// 		return;
			// 	inConsole = true;
			// 	openSubState(new ConsoleSubState());
			// }

			if (controls.justPressed('debug_1'))
			{
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}
	}

	function onCursorClick()
	{
		if (clickedOption || inConsole)
			return;

		var time:Float = 1.6;
		var shaderValue:Float = 6.5;

		if (FlxG.mouse.overlaps(freeplaySprite, camOptions) && FlxG.mouse.pressed)
		{
			for (i in [storyModeSprite, modsSprite, creditsSprite, optionsSprite])
			{
				FlxTween.tween(i, {angle: 10, y: 1000, alpha: 0}, time, {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new FreeplayState());
					}
				});
			}
			FlxTween.tween(camOther, {alpha: 1}, time, {ease: FlxEase.linear});
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxFlicker.flicker(freeplaySprite, 1.2, 0.06, false, false);
			FlxTween.tween(freeplaySprite, {x: (FlxG.width - freeplaySprite.width) / 2, y: (FlxG.height - freeplaySprite.height) / 2}, time,
				{ease: FlxEase.elasticInOut});
			clickedOption = true;
			numTween = FlxTween.num(0, shaderValue, 1.2);
			numTween.onUpdate = function(twn:FlxTween)
			{
				sleLogoCamShader.shader.yrot.value = [numTween.value];
			}
		}
		else if (FlxG.mouse.overlaps(storyModeSprite) && FlxG.mouse.pressed)
		{
			for (i in [freeplaySprite, modsSprite, creditsSprite, optionsSprite])
			{
				FlxTween.tween(i, {angle: 10, y: 1000, alpha: 0}, time, {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new StoryMenuState());
					}
				});
			}
			FlxTween.tween(camOther, {alpha: 1}, time, {ease: FlxEase.linear});
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(storyModeSprite, {x: (FlxG.width - storyModeSprite.width) / 2, y: (FlxG.height - storyModeSprite.height) / 2}, time,
				{ease: FlxEase.elasticInOut});
			FlxFlicker.flicker(storyModeSprite, 1.2, 0.06, false, false);
			clickedOption = true;
			numTween = FlxTween.num(0, shaderValue, 1.2);
			numTween.onUpdate = function(twn:FlxTween)
			{
				sleLogoCamShader.shader.yrot.value = [numTween.value];
			}
		}
		else if (FlxG.mouse.overlaps(modsSprite) && FlxG.mouse.pressed)
		{
			for (i in [freeplaySprite, storyModeSprite, creditsSprite, optionsSprite])
			{
				FlxTween.tween(i, {angle: 10, y: 1000, alpha: 0}, time, {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new ModsMenuState());
					}
				});
			}
			FlxTween.tween(camOther, {alpha: 1}, time, {ease: FlxEase.linear});
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(modsSprite, {x: (FlxG.width - modsSprite.width) / 2, y: (FlxG.height - modsSprite.height) / 2}, time, {ease: FlxEase.linear});
			FlxFlicker.flicker(modsSprite, 1.2, 0.06, false, false);
			clickedOption = true;
			numTween = FlxTween.num(0, shaderValue, 1.2);
			numTween.onUpdate = function(twn:FlxTween)
			{
				sleLogoCamShader.shader.yrot.value = [numTween.value];
			}
		}
		else if (FlxG.mouse.overlaps(creditsSprite) && FlxG.mouse.pressed)
		{
			for (i in [freeplaySprite, storyModeSprite, modsSprite, optionsSprite])
			{
				FlxTween.tween(i, {angle: 10, y: 1000, alpha: 0}, time, {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new states.CreditsState());
					}
				});
			}
			FlxTween.tween(camOther, {alpha: 1}, time, {ease: FlxEase.linear});
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(creditsSprite, {x: (FlxG.width - creditsSprite.width) / 2, y: (FlxG.height - creditsSprite.height) / 2}, time,
				{ease: FlxEase.elasticInOut});
			FlxFlicker.flicker(creditsSprite, 1.2, 0.06, false, false);
			clickedOption = true;
			numTween = FlxTween.num(0, shaderValue, 1.2);
			numTween.onUpdate = function(twn:FlxTween)
			{
				sleLogoCamShader.shader.yrot.value = [numTween.value];
			}
		}
		else if (FlxG.mouse.overlaps(optionsSprite) && FlxG.mouse.pressed)
		{
			for (i in [freeplaySprite, storyModeSprite, modsSprite, creditsSprite])
			{
				FlxTween.tween(i, {angle: 10, y: 1000, alpha: 0}, time, {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new OptionsState());
						OptionsState.onPlayState = false;
						if (PlayState.SONG != null)
						{
							PlayState.SONG.options.arrowSkin = null;
							PlayState.SONG.options.splashSkin = null;
							PlayState.stageUI = 'normal';
						}
					}
				});
			}
			FlxTween.tween(camOther, {alpha: 1}, time, {ease: FlxEase.linear});
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(optionsSprite, {x: (FlxG.width - optionsSprite.width) / 2, y: (FlxG.height - optionsSprite.height) / 2}, time,
				{ease: FlxEase.elasticInOut});
			FlxFlicker.flicker(optionsSprite, 1.2, 0.06, false, false);
			clickedOption = true;
			numTween = FlxTween.num(0, shaderValue, 1.2);
			numTween.onUpdate = function(twn:FlxTween)
			{
				sleLogoCamShader.shader.yrot.value = [numTween.value];
			}
		}
	}

	static inline var SIZE_INCREASE:Int = 50;

	function createFilterFrames(sprite:FlxSprite, filter:BitmapFilter)
	{
		var filterFrames = FlxFilterFrames.fromFrames(sprite.frames, SIZE_INCREASE, SIZE_INCREASE, [filter]);
		updateFilter(sprite, filterFrames);
		return filterFrames;
	}

	function updateFilter(spr:FlxSprite, sprFilter:FlxFilterFrames)
	{
		sprFilter.applyToSprite(spr, false, true);
	}
}
