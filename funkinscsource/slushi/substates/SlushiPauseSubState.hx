package slushi.substates;

import backend.WeekData;
import backend.Highscore;
import states.StoryMenuState;
import options.OptionsState;
import flixel.util.FlxStringUtil;

class SlushiPauseSubState extends MusicBeatSubState
{
	public static var songName:String = null;

	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
	var difficultyChoices = [];
	var optionChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var optionsText:FlxText;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var music:FlxSound = FlxG.sound.music;

	var settings = {
		music: ClientPrefs.data.pauseMusic
	};

	var num:Int = 0;

	var bg:FlxSprite;
	var slBG:FlxSprite;

	override function create()
	{
		game.paused = true;

		if (Difficulty.list.length < 2)
			menuItemsOG.remove('Change Difficulty'); // No need to change difficulty if there is only one!

		if (PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
		}
		else if (PlayState.modchartMode)
		{
			menuItemsOG.insert(2, 'Leave ModChart Mode');
		}

		if (PlayState.chartingMode || PlayState.modchartMode)
		{
			if (!game.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...Difficulty.list.length)
		{
			var diff:String = Difficulty.getString(i);
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		for (i in OptionsState.options)
		{
			optionChoices.push(i);
		}
		optionChoices.push('BACK');

		if (pauseMusic != null)
			pauseMusic = null;

		pauseMusic = new FlxSound();
		try
		{
			var pauseSong:String = getPauseSong();
			if (pauseSong != null)
				pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		}
		catch (e:Dynamic)
		{
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		slBG = new FlxSprite().loadGraphic(SlushiMain.getSLEPath('BGs/SlushiBGPauseSubState.png'));
		slBG.antialiasing = ClientPrefs.data.antialiasing;
		slBG.updateHitbox();
		slBG.screenCenter();
		slBG.alpha = 0;
		slBG.color = SlushiMain.slushiColor;
		add(slBG);

		var levelInfo:FlxText = new FlxText(20, 15, 0, 'Song: ' + PlayState.SONG.songId, 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, 'Difficulty: ' + Difficulty.getString().toUpperCase(), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, Language.getPhrase("blueballed", "Blueballed: {1}", [PlayState.deathCounter]), 32);
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, Language.getPhrase("Practice Mode").toUpperCase(), 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = game.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "", 32);
		chartingText.scrollFactor.set();
		if (PlayState.chartingMode)
			chartingText.text = Language.getPhrase("Charting Mode").toUpperCase();
		else if (PlayState.modchartMode)
			chartingText.text = Language.getPhrase("Modchart Mode").toUpperCase();
		else
			chartingText.text = "";
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = (PlayState.chartingMode || PlayState.modchartMode);
		add(chartingText);

		var notITGText:FlxText = new FlxText(20, 15 + 101, 0, Language.getPhrase("Modchart Disabled").toUpperCase(), 32);
		notITGText.scrollFactor.set();
		notITGText.setFormat(Paths.font('vcr.ttf'), 32);
		notITGText.x = FlxG.width - (notITGText.width + 20);
		notITGText.y = FlxG.height - (notITGText.height + 60);
		notITGText.updateHitbox();
		notITGText.visible = !ClientPrefs.getGameplaySetting('modchart');
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		chartingText.alpha = 0;
		practiceText.alpha = 0;
		practiceText.y -= 5;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		// thank you crowplexus for the portuguese translation!! - subpurr
		optionsText = new FlxText(20, 15 + 101, 0,
			Language.getPhrase("options_in_pause_warning", "WARNING: Not all options are supported!\nSome options may not update until you restart."), 32);
		optionsText.scrollFactor.set();
		optionsText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		optionsText.borderSize = 4;
		optionsText.y = FlxG.height - (optionsText.height + 20);
		optionsText.updateHitbox();

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(slBG, {alpha: 0.8}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(chartingText, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(practiceText, {alpha: 1, y: practiceText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		missingTextBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		missingTextBG.scale.set(FlxG.width, FlxG.height);
		missingTextBG.updateHitbox();
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);

		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if (formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none'))
			return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;

	public var getReady:FlxSprite;
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public var inCountDown:Bool = false;
	public var unPauseTimer:FlxTimer;

	var stoppedUpdatingMusic:Bool = false;

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			close();
			game.canResync = true;
			return;
		}

		if (game != null)
			game.paused = true;
		cantUnpause -= elapsed;
		if (!stoppedUpdatingMusic)
		{ // Reason to no put != null outside is to not confuse the game to not "stop" when intended.
			if (pauseMusic != null && pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;
		}
		else
		{
			if (pauseMusic != null)
				pauseMusic.volume = 0;
		}

		super.update(elapsed);

		updateSkipTextStuff();

		if (controls.UI_UP_P && !inCountDown)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P && !inCountDown)
		{
			changeSelection(1);
		}
		if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if (controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if (holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if (curTime >= music.length)
						curTime -= music.length;
					else if (curTime < 0)
						curTime += music.length;
					updateSkipTimeText();
				}
		}

		if (FlxG.keys.justPressed.F5 && !inCountDown)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			PlayState.nextReloadAll = true;
			MusicBeatState.resetState();
		}

		if ((controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode)) && !inCountDown)
		{
			// Finally
			if (menuItems == difficultyChoices)
			{
				var songLowercase:String = Paths.formatToSongPath(PlayState.SONG.songId);
				var poop:String = Highscore.formatSong(songLowercase, curSelected);
				try
				{
					if (menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected))
					{
						Song.loadFromJson(poop, songLowercase);
						PlayState.storyDifficulty = curSelected;
						LoadingState.loadAndSwitchState(new PlayState());
						music.volume = 0;
						PlayState.changedDifficulty = true;
						PlayState.chartingMode = false;
						PlayState.modchartMode = false;
						return;
					}
				}
				catch (e:haxe.Exception)
				{
					Debug.logError('ERROR! ${e.message}');

					var errorStr:String = e.message;
					if (errorStr.startsWith('[lime.utils.Assets] ERROR:'))
						errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length - 1); // Missing chart
					else
						errorStr += '\n\n' + e.stack;
					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			if (menuItems == optionChoices)
			{
				switch (daSelected)
				{
					case 'Note Options':
						OptionsState.onPlayState = true;
						FlxTransitionableState.skipNextTransOut = true;
						FlxTransitionableState.skipNextTransIn = true;
						MusicBeatState.switchState(new options.NoteOptions());
						game.canResync = false;
					case 'Controls':
						openSubState(new options.ControlsSubState());
					case 'Graphics':
						openSubState(new options.GraphicsSettingsSubState());
					case 'Visuals':
						openSubState(new options.VisualsSettingsSubState());
					case 'Gameplay':
						openSubState(new options.GameplaySettingsSubState());
					case 'Misc':
						openSubState(new options.MiscSettingsSubState());
					case 'Adjust Delay and Combo':
						OptionsState.onPlayState = true;
						MusicBeatState.switchState(new options.NoteOffsetState());
						game.canResync = false;
					case 'Language':
						openSubState(new options.LanguageSubState());
					default:
						ClientPrefs.saveSettings();
						ClientPrefs.loadPrefs();
						ClientPrefs.keybindSaveLoad();
						menuItems = menuItemsOG;
						regenMenu();
						remove(optionsText); // no need for visible, just remove it
				}
				return;
			}

			if (!stoppedUpdatingMusic)
			{
				stoppedUpdatingMusic = true;
				destroyMusic();
			}
			menuOptions(daSelected);
		}
	}

	var isCountDown:Bool = false;

	function menuOptions(daSelected:String)
	{
		switch (daSelected)
		{
			case "Resume":
				if (ClientPrefs.data.pauseCountDown)
				{
					unPauseTimer = new FlxTimer().start(Conductor.crochet / 1000 / music.pitch, function(hmmm:FlxTimer)
					{
						switch (hmmm.loopsLeft)
						{
							case 4 | 3 | 2 | 1:
								pauseCountDown();
							case 0:
								if (hmmm.finished)
									pauseCountDown();
						}
					}, 5);
					isCountDown = true;
					for (item in grpMenuShit.members)
					{
						FlxTween.tween(item, {alpha: 0}, 0.56, {ease: FlxEase.quadOut});
					}
				}
				inCountDown = true;
				if (!isCountDown)
					close();
			case 'Change Difficulty':
				menuItems = difficultyChoices;
				deleteSkipTimeText();
				regenMenu();
			case 'Toggle Practice Mode':
				game.practiceMode = !game.practiceMode;
				PlayState.changedDifficulty = true;
				practiceText.visible = game.practiceMode;
			case "Restart Song", "Leave Charting Mode", "Leave ModChart Mode":
				LoadingState.loadAndSwitchState(new PlayState());

				switch (daSelected)
				{
					case "Leave Charting Mode":
						PlayState.chartingMode = false;
					case "Leave ModChart Mode":
						PlayState.modchartMode = false;
				}
			case 'Skip Time':
				if (curTime < Conductor.songPosition)
				{
					PlayState.startOnTime = curTime;
					restartSong(true);
				}
				else
				{
					if (curTime != Conductor.songPosition)
					{
						game.clearNotesBefore(curTime);
						game.setSongTime(curTime);
					}
					close();
				}
			case 'Toggle Botplay':
				game.cpuControlled = !game.cpuControlled;
				PlayState.changedDifficulty = true;
				game.botplayTxt.visible = game.cpuControlled;
				game.botplayTxt.alpha = 1;
				game.botplaySine = 0;
			case 'Options':
				menuItems = optionChoices;
				deleteSkipTimeText();
				regenMenu();
				add(optionsText); // ensure it's at front
			case 'End Song':
				close();
				game.notes.clear();
				game.unspawnNotes.clear();
				game.finishSong(true);
			case "Exit to menu":
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;

				Mods.loadTopMod();

				if (ClientPrefs.data.behaviourType != 'VSLICE')
				{
					if (PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else
						MusicBeatState.switchState(new slushi.states.freeplay.SlushiFreeplayState());
				}
				#if BASE_GAME_FILES
				else
				{
					if (PlayState.isStoryMode)
					{
						PlayState.storyPlaylist = [];
						openSubState(new vslice.transition.StickerSubState(null, (sticker) -> new StoryMenuState(sticker)));
					}
					else
						openSubState(new vslice.transition.StickerSubState(null, (sticker) -> new slushi.states.freeplay.SlushiFreeplayState(sticker)));
				}
				#end

				game.canResync = false;
				FlxG.sound.playMusic(SlushiMain.getSLEPath("Musics/SLE_HackNet_Resonance.ogg"));
				PlayState.changedDifficulty = false;
				PlayState.chartingMode = false;
				PlayState.modchartMode = false;
				game.alreadyEndedSong = false;
				FlxG.camera.followLerp = 0;
				if (PlayState.forceMiddleScroll)
				{
					if (PlayState.savePrefixScrollR && PlayState.prefixRightScroll)
					{
						ClientPrefs.data.middleScroll = false;
					}
				}
				else if (PlayState.forceRightScroll)
				{
					if (PlayState.savePrefixScrollM && PlayState.prefixMiddleScroll)
					{
						ClientPrefs.data.middleScroll = true;
					}
				}
		}
	}

	function destroyMusic()
	{
		pauseMusic.volume = 0;
		pauseMusic.destroy();
		pauseMusic = null;
	}

	var CDANumber:Int = 5;
	var game:PlayState = PlayState.instance;

	function pauseCountDown()
	{
		if (game == null)
			return;
		game.stageIntroSoundsSuffix = game.stage.stageIntroSoundsSuffix != null ? game.stage.stageIntroSoundsSuffix : '';
		game.stageIntroSoundsPrefix = game.stage.stageIntroSoundsPrefix != null ? game.stage.stageIntroSoundsPrefix : '';

		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch (PlayState.stageUI)
		{
			case "pixel": [
					'${PlayState.stageUI}UI/ready-pixel',
					'${PlayState.stageUI}UI/set-pixel',
					'${PlayState.stageUI}UI/date-pixel'
				];
			case "normal": ["ready", "set", "go"];
			default: [
					'${PlayState.stageUI}UI/ready',
					'${PlayState.stageUI}UI/set',
					'${PlayState.stageUI}UI/go'
				];
		}
		if (game.stage.stageIntroAssets != null)
			introAssets.set(PlayState.curStage, game.stage.stageIntroAssets);
		else
			introAssets.set(PlayState.stageUI, introImagesArray);

		var isPixelated:Bool = PlayState.isPixelStage;
		var introAlts:Array<String> = (game.stage.stageIntroAssets != null ? introAssets.get(PlayState.curStage) : introAssets.get(PlayState.stageUI));
		var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelated);
		for (value in introAssets.keys())
		{
			if (value == PlayState.curStage)
			{
				introAlts = introAssets.get(value);

				if (game.stageIntroSoundsSuffix != null && game.stageIntroSoundsSuffix.length > 0)
					game.introSoundsSuffix = game.stageIntroSoundsSuffix;
				else
					game.introSoundsSuffix = '';

				if (game.stageIntroSoundsPrefix != null && game.stageIntroSoundsPrefix.length > 0)
					game.introSoundsPrefix = game.stageIntroSoundsPrefix;
				else
					game.introSoundsPrefix = '';
			}
		}

		CDANumber -= 1;

		var introArrays0:Array<Float> = [];
		var introArrays1:Array<Float> = [];
		var introArrays2:Array<Float> = [];
		var introArrays3:Array<Float> = [];
		if (game.stage.stageIntroSpriteScales != null)
		{
			introArrays0 = game.stage.stageIntroSpriteScales[0];
			introArrays1 = game.stage.stageIntroSpriteScales[1];
			introArrays2 = game.stage.stageIntroSpriteScales[2];
			introArrays3 = game.stage.stageIntroSpriteScales[3];
		}

		switch (CDANumber)
		{
			case 4:
				var isNotNull = (introAlts.length > 3 ? introAlts[0] : "missingRating");
				getReady = createCountdownSprite(isNotNull, antialias, game.introSoundsPrefix + 'intro3' + game.introSoundsSuffix, introArrays0);
			case 3:
				countdownReady = createCountdownSprite(introAlts[introAlts.length - 3], antialias, game.introSoundsPrefix + 'intro2' + game.introSoundsSuffix,
					introArrays1);
			case 2:
				countdownSet = createCountdownSprite(introAlts[introAlts.length - 2], antialias, game.introSoundsPrefix + 'intro1' + game.introSoundsSuffix,
					introArrays2);
			case 1:
				countdownGo = createCountdownSprite(introAlts[introAlts.length - 1], antialias, game.introSoundsPrefix + 'introGo' + game.introSoundsSuffix,
					introArrays3);
			case 0:
				close();
		}
	}

	inline private function createCountdownSprite(image:String, antialias:Bool, soundName:String, scale:Array<Float> = null):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image(image));
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (image.contains("-pixel") && scale == null)
			spr.setGraphicSize(Std.int(spr.width * PlayState.daPixelZoom));

		if (scale != null)
			spr.scale.set(scale[0], scale[1]);

		spr.screenCenter();
		spr.antialiasing = antialias;
		add(spr);
		FlxTween.tween(spr, {y: spr.y + 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				remove(spr);
				spr.destroy();
			}
		});
		if (!game.stage.disabledIntroSounds)
			FlxG.sound.play(Paths.sound(soundName), 0.6);
		return spr;
	}

	function deleteSkipTimeText()
	{
		if (skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		if (PlayState.instance != null)
		{
			PlayState.instance.paused = true; // For lua
			if (PlayState.instance.vocals != null)
			{
				PlayState.instance.vocals.volume = 0;
			}

			if (PlayState.instance.splitVocals && PlayState.instance.opponentVocals != null)
			{
				PlayState.instance.opponentVocals.volume = 0;
			}
		}
		if (FlxG.sound.music != null)
			FlxG.sound.music.volume = 0;

		if (noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	override function destroy()
	{
		if (pauseMusic != null)
			pauseMusic.destroy();
		game.canResync = true;

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		for (num => item in grpMenuShit.members)
		{
			item.targetY = num - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;

			if (item.targetY == 0 && item == skipTimeTracker)
			{
				curTime = Math.max(0, Conductor.songPosition);
				updateSkipTimeText();
			}
		}

		missingText.visible = false;
		missingTextBG.visible = false;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
		{
			var obj:Alphabet = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}
		for (num => str in menuItems)
		{
			var item = new Alphabet(90, 320, Language.getPhrase('pause_$str', str), true);
			item.isMenuItem = true;
			item.targetY = num;
			grpMenuShit.add(item);
			if (!PlayState.chartingMode || !PlayState.modchartMode)
				item.screenCenter(X);

			if (str == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}

		curSelected = 0;
		changeSelection();
	}

	function updateSkipTextStuff()
	{
		if (skipTimeText == null || skipTimeTracker == null)
			return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false)
			+ ' / '
			+ FlxStringUtil.formatTime(Math.max(0, Math.floor(music.length / 1000)), false);
}
