package slushi.states;

import flixel.util.FlxGradient;
import flixel.effects.particles.FlxEmitter;
import openfl.Assets;
import backend.Highscore;
import slushi.windowThings.WindowSizeUtil;

/**
 * The first state of the game, the title state of SLE.
 * 
 * Author: Slushi
 */

class SlushiTitleState extends MusicBeatState
{
	var songBPM:Float = 88;
	var song:FlxSound = null;
	var camZoom:Float = 1.125;
	var skipedIntro:Bool = false;

	var grayGrad:FlxSprite = null;
	var whiteGrad:FlxSprite = null;

	var slushiEngineLogo:FlxSprite;
	var sleLogoPurpleNote:FlxSprite;
	var sleLogoRedNote:FlxSprite;
	var sleLogoGreenNote:FlxSprite;
	var sleLogoBlueNote:FlxSprite;
	var bg:FlxSprite;

	var slushi:FlxSprite;
	var sceText:FlxSprite;

	var continueSprite:FlxSprite;

	var particlesUP = new FlxTypedGroup<FlxEmitter>();
	var particlesDOWN = new FlxTypedGroup<FlxEmitter>();

	override public function create()
	{
		super.create();
		
		FlxG.sound.playMusic(SlushiMain.getSLEPath("Musics/SLE_HackNet_Resonance.ogg"), 0);
		FlxG.sound.music.fadeIn(4, 0, 0.7);
		states.MainMenuState.freakyPlaying = true;
		Conductor.bpm = songBPM;

		persistentUpdate = true;

		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		if (Main.checkGJKeysAndId())
		{
			GameJoltAPI.connect();
			GameJoltAPI.authDaUser(ClientPrefs.data.gjUser, ClientPrefs.data.gjToken);
		}

		Highscore.load();
		Assets.cache.enabled = true;
		WindowSizeUtil.setScreenResolutionOnStart();

		var newVersion:String = SlushiMain.getBuildVer();
		if(newVersion != "") {
			var finalText:FlxText = new FlxText(0, 0, 0, "Hey! You are using an old version of Slushi Engine\nVersion: " + newVersion + " > " + SlushiMain.slushiEngineVersion + "\nPlease download the latest version\nThanks for use SLE :3", 12);
			finalText.scrollFactor.set();
			finalText.setFormat("VCR OSD Mono", 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			finalText.screenCenter();
			finalText.y -= 20;
			add(finalText);
			finalText.alpha = 0;
			FlxTween.tween(finalText, {alpha: 1}, 0.3, {ease: FlxEase.quadOut});
			FlxTween.tween(finalText, {y: 320}, 0.3, {ease: FlxEase.quadOut});

			new FlxTimer().start(3, function(twn:FlxTimer)
			{
				FlxTween.tween(finalText, {alpha: 0}, 2, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween) {
					finalText.destroy();
				}});
			});
		}

		grayGrad = FlxGradient.createGradientFlxSprite(FlxG.width, 400, [0x0, SlushiMain.slushiColor]);
		grayGrad.x += 0;
		grayGrad.flipY = true;
		grayGrad.y -= 200;
		whiteGrad = FlxGradient.createGradientFlxSprite(FlxG.width, 400, [0x0, SlushiMain.slushiColor]);
		whiteGrad.x += 0;
		whiteGrad.y += 570;

		whiteGrad.alpha = 0;
		grayGrad.alpha = 0;

		// SLUSHI ENGINE LOGO
		slushiEngineLogo = new FlxSprite(0, 500);
		slushiEngineLogo.loadGraphic(SlushiMain.getSLEPath('SlushiEngineLogoSeparatedParts/SlushiEngineText.png'));
		slushiEngineLogo.antialiasing = ClientPrefs.data.antialiasing;
		slushiEngineLogo.setGraphicSize(Std.int(slushiEngineLogo.width * 0.85));

		sleLogoPurpleNote = new FlxSprite(0, 0);
		sleLogoPurpleNote.loadGraphic(SlushiMain.getSLEPath('SlushiEngineLogoSeparatedParts/purpleNote.png'));
		sleLogoPurpleNote.antialiasing = ClientPrefs.data.antialiasing;
		sleLogoPurpleNote.setGraphicSize(Std.int(sleLogoPurpleNote.width * 0.85));
		sleLogoPurpleNote.screenCenter();

		sleLogoBlueNote = new FlxSprite(0, 0);
		sleLogoBlueNote.loadGraphic(SlushiMain.getSLEPath('SlushiEngineLogoSeparatedParts/blueNote.png'));
		sleLogoBlueNote.antialiasing = ClientPrefs.data.antialiasing;
		sleLogoBlueNote.setGraphicSize(Std.int(sleLogoBlueNote.width * 0.85));
		sleLogoBlueNote.screenCenter();

		sleLogoGreenNote = new FlxSprite(0, 0);
		sleLogoGreenNote.loadGraphic(SlushiMain.getSLEPath('SlushiEngineLogoSeparatedParts/greenNote.png'));
		sleLogoGreenNote.antialiasing = ClientPrefs.data.antialiasing;
		sleLogoGreenNote.setGraphicSize(Std.int(sleLogoGreenNote.width * 0.85));
		sleLogoGreenNote.screenCenter();

		sleLogoRedNote = new FlxSprite(0, 0);
		sleLogoRedNote.loadGraphic(SlushiMain.getSLEPath('SlushiEngineLogoSeparatedParts/redNote.png'));
		sleLogoRedNote.antialiasing = ClientPrefs.data.antialiasing;
		sleLogoRedNote.setGraphicSize(Std.int(sleLogoRedNote.width * 0.85));
		sleLogoRedNote.screenCenter();

		slushi = new FlxSprite(0, 0);
		slushi.loadGraphic(SlushiMain.getSLEPath('SlushiEngineLogoSeparatedParts/Slushi.png'));
		slushi.antialiasing = ClientPrefs.data.antialiasing;
		slushi.setGraphicSize(Std.int(slushi.width * 0.85));
		slushi.screenCenter();

		sceText = new FlxSprite(0, 0);
		sceText.loadGraphic(SlushiMain.getSLEPath('SlushiEngineLogoSeparatedParts/SCEngineText.png'));
		sceText.antialiasing = ClientPrefs.data.antialiasing;
		sceText.setGraphicSize(Std.int(sceText.width * 0.85));
		sceText.screenCenter();

		continueSprite = new FlxSprite(0, 0);
		continueSprite.loadGraphic(SlushiMain.getSLEPath('SlushiTitleStateAssets/continueSprite.png'));
		continueSprite.antialiasing = ClientPrefs.data.antialiasing;
		continueSprite.screenCenter();
		continueSprite.y += 270;
		continueSprite.setGraphicSize(Std.int(continueSprite.width * 0.70));
		add(continueSprite);
		continueSprite.alpha = 0;

		for (i in [
			slushi,
			sceText,
			sleLogoPurpleNote,
			sleLogoBlueNote,
			sleLogoGreenNote,
			sleLogoRedNote,
			slushiEngineLogo
		])
		{
			add(i);
			i.alpha = 0;
		}

		for (i in 0...6)
		{
			var emitter:FlxEmitter = new FlxEmitter(-1000, 1500);
			emitter.launchMode = FlxEmitterMode.SQUARE;
			emitter.velocity.set(-50, -150, 50, -750, -100, 0, 100, -100);
			emitter.scale.set(0.75, 0.75, 3, 3, 0.75, 0.75, 1.5, 1.5);
			emitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			emitter.width = 3500;
			emitter.alpha.set(1, 1, 0, 0);
			emitter.lifespan.set(3, 5);
			emitter.loadParticles(SlushiMain.getSLEPath("SlushiTitleStateAssets/Particle" + i + ".png"), 500, 16, true);
			particlesUP.add(emitter);

			var emitter:FlxEmitter = new FlxEmitter(-1000, -1500);
			emitter.launchMode = FlxEmitterMode.SQUARE;
			emitter.velocity.set(50, 150, 50, 750, 100, 0, -100, 100);
			emitter.scale.set(0.75, 0.75, 3, 3, 0.75, 0.75, 1.5, 1.5);
			emitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			emitter.width = 3500;
			emitter.alpha.set(1, 1, 0, 0);
			emitter.lifespan.set(3, 5);
			emitter.loadParticles(SlushiMain.getSLEPath("SlushiTitleStateAssets/Particle" + i + ".png"), 500, -16, true);
			particlesDOWN.add(emitter);
		}
		if (particlesUP != null)
		{
			particlesUP.forEach(function(emitter:FlxEmitter)
			{
				if (!emitter.emitting)
					emitter.start(false, FlxG.random.float(0.1, 0.2), 100000);
			});
		}
		if (particlesDOWN != null)
		{
			particlesDOWN.forEach(function(emitter:FlxEmitter)
			{
				if (!emitter.emitting)
					emitter.start(false, FlxG.random.float(0.1, 0.2), 100000);
			});
		}
		add(particlesUP);
		add(particlesDOWN);

		for (i in [particlesUP, particlesDOWN])
			i.visible = false;

		persistentUpdate = true;
		persistentDraw = true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (controls.ACCEPT)
		{
			if (!skipedIntro)
			{
				skipPartOneOfTheIntro();
				skipedIntro = true;
			}
			else
			{
				MusicBeatState.switchState(new slushi.states.SlushiMainMenuState());
			}
		}
	}

	function skipPartOneOfTheIntro()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.time = 44200;
	}

	function tweenAlphaOfSLELogoNotes(part:Int, alpha:Float, time:Float)
	{
		switch (part)
		{
			case 1:
				FlxTween.tween(sleLogoPurpleNote, {alpha: alpha}, time, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(sleLogoPurpleNote, {alpha: 0}, time, {ease: FlxEase.linear});
					}
				});
			case 2:
				FlxTween.tween(sleLogoBlueNote, {alpha: alpha}, time, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(sleLogoBlueNote, {alpha: 0}, time, {ease: FlxEase.linear});
					}
				});
			case 3:
				FlxTween.tween(sleLogoGreenNote, {alpha: alpha}, time, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(sleLogoGreenNote, {alpha: 0}, time, {ease: FlxEase.linear});
					}
				});
			case 4:
				FlxTween.tween(sleLogoRedNote, {alpha: alpha}, time, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(sleLogoRedNote, {alpha: 0}, time, {ease: FlxEase.linear});
					}
				});
			default:
				Debug.logInfo("null");
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (curStep == 15 && curStep != 266)
		{
			if (curStep % 16 == 0)
			{
				FlxTween.tween(whiteGrad, {"pixels.height": 550, alpha: 0.7}, Conductor.crochet / 1900, {
					onComplete: function(flx:FlxTween)
					{
						@:privateAccess {
							whiteGrad.pixels.height = 0;
						}
						whiteGrad.alpha = 0;
					}
				});

				FlxTween.tween(grayGrad, {"pixels.height": 550, alpha: 0.7}, Conductor.crochet / 1900, {
					onComplete: function(flx:FlxTween)
					{
						@:privateAccess {
							grayGrad.pixels.height = 0;
						}
						grayGrad.alpha = 0;
					}
				});
			}
		}

		if (curStep >= 132 && curStep <= 265)
		{
			tweenAlphaOfSLELogoNotes(FlxG.random.int(1, 4), 0.5, 0.1);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.camera.zoom = camZoom;
		FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1300, {
			ease: FlxEase.quadOut
		});

		FlxTween.tween(whiteGrad, {"pixels.height": 400, alpha: 0.7}, Conductor.crochet / 1900, {
			onComplete: function(flx:FlxTween)
			{
				@:privateAccess {
					whiteGrad.pixels.height = 0;
				}
				whiteGrad.alpha = 0;
			}
		});
		FlxTween.tween(grayGrad, {"pixels.height": 400, alpha: 0.7}, Conductor.crochet / 1900, {
			onComplete: function(flx:FlxTween)
			{
				@:privateAccess {
					grayGrad.pixels.height = 0;
				}
				grayGrad.alpha = 0;
			}
		});

		if (curBeat >= 165 && curBeat <= 293)
		{
			if (curBeat % 2 == 0)
			{
				for (i in [
					slushi,
					sceText,
					sleLogoPurpleNote,
					sleLogoBlueNote,
					sleLogoGreenNote,
					sleLogoRedNote,
					slushiEngineLogo
				])
				{
					FlxTween.tween(i, {angle: 10}, 0.2, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(i, {angle: 0}, 0.2, {ease: FlxEase.linear});
						}
					});
				}
				if (!Application.current.window.maximized)
				{
					FlxTween.tween(Application.current.window, {x: Application.current.window.x + 25}, 0.2, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(Application.current.window, {x: Application.current.window.x - 25}, 0.2, {ease: FlxEase.linear});
						}
					});
				}
			}
			else
			{
				for (i in [
					slushi,
					sceText,
					sleLogoPurpleNote,
					sleLogoBlueNote,
					sleLogoGreenNote,
					sleLogoRedNote,
					slushiEngineLogo
				])
				{
					FlxTween.tween(i, {angle: -10}, 0.2, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(i, {angle: 0}, 0.2, {ease: FlxEase.linear});
						}
					});
				}
				if (!Application.current.window.maximized)
				{
					FlxTween.tween(Application.current.window, {x: Application.current.window.x - 25}, 0.2, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(Application.current.window, {x: Application.current.window.x + 25}, 0.2, {ease: FlxEase.linear});
						}
					});
				}
			}
		}

		switch (curBeat)
		{
			case 66:
				skipedIntro = true;
				for (i in [particlesUP, particlesDOWN])
					i.visible = true;
				FlxG.camera.flash(FlxColor.WHITE, 2);
				sleLogoPurpleNote.y -= 100;
				sleLogoBlueNote.x += 100;
				sleLogoGreenNote.y += 100;
				sleLogoRedNote.x -= 100;
				slushi.y -= 100;
				FlxTween.tween(slushiEngineLogo, {y: 0, alpha: 1}, 2.7, {
					ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(sceText, {alpha: 1}, 1.2, {ease: FlxEase.expoOut});
						FlxTween.tween(slushi, {alpha: 1, y: 0}, 1.2, {ease: FlxEase.expoOut});
						FlxTween.tween(continueSprite, {alpha: 1}, 1.2, {
							ease: FlxEase.expoOut,
							onComplete: function(twn:FlxTween)
							{
								FlxTween.tween(continueSprite, {y: continueSprite.y + 20}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
							}
						});
						for (i in [sleLogoPurpleNote, sleLogoBlueNote, sleLogoGreenNote, sleLogoRedNote])
						{
							FlxTween.tween(i, {y: 0}, 2.7, {ease: FlxEase.expoOut});
							FlxTween.tween(i, {x: 0}, 2.7, {ease: FlxEase.expoOut});
							FlxTween.tween(i, {alpha: 1}, 2.7, {ease: FlxEase.expoOut});
						}
					}
				});
			case 149:
				camZoom = 1;
			case 164:
				camZoom = 1.4;
			case 294:
				for (i in [
					sleLogoPurpleNote,
					sleLogoBlueNote,
					sleLogoGreenNote,
					sleLogoRedNote,
					slushiEngineLogo,
					sceText
				])
				{
					FlxTween.tween(i, {angle: 20}, 8, {ease: FlxEase.quadOut});
					FlxTween.tween(i, {y: 1000}, FlxG.random.float(5, 8), {ease: FlxEase.quadOut});
					FlxTween.tween(i, {alpha: 0}, 8, {ease: FlxEase.quadOut});
				}
				camZoom = 1;
			case 297:
				FlxTween.tween(slushi, {alpha: 0.6}, 1.2, {ease: FlxEase.expoOut});
				final finalText:FlxText = new FlxText(0, 0, 0, "Entering the Main Menu State...", 12);
				finalText.scrollFactor.set();
				finalText.setFormat("VCR OSD Mono", 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				finalText.screenCenter();
				finalText.y -= 20;
				add(finalText);
				finalText.alpha = 0;
				FlxTween.tween(finalText, {alpha: 1}, 2, {ease: FlxEase.quadOut});
				FlxTween.tween(finalText, {y: 320}, 2, {ease: FlxEase.quadOut});
			case 303:
				MusicBeatState.switchState(new slushi.states.SlushiMainMenuState());
		}
	}
}
