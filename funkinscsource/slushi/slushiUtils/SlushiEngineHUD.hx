package slushi.slushiUtils;

import psychlua.LuaUtils;

/**
 * The HUD for the engine, specifically for NotITG songs
 * 
 * Author: Slushi
 */
class SlushiEngineHUD extends FlxSprite
{
	public static var instance:SlushiEngineHUD;

	public var SLELogo = {
		posX: -20,
		posY: 0,
		blackAlpha: 0.7
	};

	public var bgSprite:FlxSprite;
	public var slushiSprite:FlxSprite;
	public var sceSprite:FlxSprite;
	public var notesSprite:FlxSprite;
	public var sleSprite:FlxSprite;
	public var blackGraphic:FlxSprite;

	static var data_judgements = {
		timeTimer: 0.2, // Timers time
		timeTween: 0.3, // Tweens time
		posX: 20,
		posY: 52,
		// Colors:
		swagColor: 0xff8FD9D1,
		sickColor: 0xFFFFFB00,
		goodColor: 0xFF00EB1F,
		badColor: 0xFFFF2600,
		shitColor: 0xFF555555
	};
	static var comboText:FlxText;
	static var swagText:FlxText;
	static var sickText:FlxText;
	static var goodText:FlxText;
	static var badText:FlxText;
	static var shitText:FlxText;

	public var sleVer:FlxText;
	public var scengine:FlxText;

	private static var camSLEHUD:FlxCamera;
	private static var camWaterMark:FlxCamera;
	private static var camHUD:FlxCamera;

	private static var leftNoteColor:Array<Int> = [194, 75, 153];
	private static var downNoteColor:Array<Int> = [0, 253, 253];
	private static var upNoteColor:Array<Int> = [18, 250, 5];
	private static var rightNoteColor:Array<Int> = [249, 58, 63];
	private static var slushiWindowColor:Array<Int> = [214, 243, 222];

	public var canChangeWindowColorWithNoteHit:Bool = true;

	private static var tweenDuration:Float = 0.3;
	private static var windowColorNumTween:NumTween;
	private static var forward:Bool = false;

	private static var comboTxtTween:FlxTween;
	private static var comboAlphaTween:FlxTween;

	public function new()
	{
		super();
		instance = this;

		camSLEHUD = PlayState.instance.camSLEHUD;
		camWaterMark = PlayState.instance.camWaterMark;
		camHUD = PlayState.instance.camHUD;

		if (PlayState.instance.useSLEHUD)
		{
			var blackGraphicForCamHUD = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackGraphicForCamHUD.scrollFactor.set();
			blackGraphicForCamHUD.cameras = [camHUD];
			addToCurrentState(blackGraphicForCamHUD);
			// camHUD.visible = false;

			bgSprite = new FlxSprite(0, 0);
			bgSprite.loadGraphic(SlushiMain.getSLEPath('SlushiEngineHUDAssets/BG.png'));
			bgSprite.scrollFactor.set(0, 0);
			bgSprite.antialiasing = ClientPrefs.data.antialiasing;
			bgSprite.cameras = [camSLEHUD];
			addToCurrentState(bgSprite);

			slushiSprite = new FlxSprite(SLELogo.posX, SLELogo.posY);
			slushiSprite.loadGraphic(SlushiMain.getSLEPath('SlushiEngineHUDAssets/Slushi.png'));
			slushiSprite.scrollFactor.set(0, 0);
			slushiSprite.scale.set(0.8, 0.8);
			slushiSprite.antialiasing = ClientPrefs.data.antialiasing;
			slushiSprite.cameras = [camSLEHUD];
			addToCurrentState(slushiSprite);

			sceSprite = new FlxSprite(SLELogo.posX, SLELogo.posY);
			sceSprite.loadGraphic(SlushiMain.getSLEPath('SlushiEngineHUDAssets/SCEngineText.png'));
			sceSprite.scrollFactor.set(0, 0);
			sceSprite.scale.set(0.8, 0.8);
			sceSprite.antialiasing = ClientPrefs.data.antialiasing;
			sceSprite.cameras = [camSLEHUD];
			addToCurrentState(sceSprite);

			notesSprite = new FlxSprite(SLELogo.posX, SLELogo.posY);
			notesSprite.loadGraphic(SlushiMain.getSLEPath('SlushiEngineHUDAssets/Notes.png'));
			notesSprite.scrollFactor.set(0, 0);
			notesSprite.scale.set(0.8, 0.8);
			notesSprite.antialiasing = ClientPrefs.data.antialiasing;
			notesSprite.cameras = [camSLEHUD];
			addToCurrentState(notesSprite);

			sleSprite = new FlxSprite(SLELogo.posX, SLELogo.posY);
			sleSprite.loadGraphic(SlushiMain.getSLEPath('SlushiEngineHUDAssets/SlushiEngineText.png'));
			sleSprite.scrollFactor.set(0, 0);
			sleSprite.scale.set(0.8, 0.8);
			sleSprite.antialiasing = ClientPrefs.data.antialiasing;
			sleSprite.cameras = [camSLEHUD];
			addToCurrentState(sleSprite);

			blackGraphic = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackGraphic.scrollFactor.set();
			blackGraphic.alpha = SLELogo.blackAlpha;
			blackGraphic.cameras = [camSLEHUD];
			addToCurrentState(blackGraphic);

			//////////////////////////////////////////////////////////////////////////////////

			comboText = new FlxText(0, 30, 0, "COMBO: ");
			comboText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			comboText.scrollFactor.set();
			comboText.borderSize = 1.25;
			comboText.screenCenter(X);
			comboText.x -= 10;
			comboText.color = SlushiMain.slushiColor;
			comboText.cameras = [camSLEHUD];
			addToCurrentState(comboText);

			// COMBO: //////////////////////////////////////////

			swagText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "SICK!!!");
			swagText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			swagText.scrollFactor.set();
			swagText.borderSize = 1.25;
			swagText.color = data_judgements.swagColor;
			swagText.cameras = [camSLEHUD];

			sickText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "SICK!!");
			sickText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			sickText.scrollFactor.set();
			sickText.borderSize = 1.25;
			sickText.color = data_judgements.sickColor;
			sickText.cameras = [camSLEHUD];

			goodText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "Good!");
			goodText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			goodText.scrollFactor.set();
			goodText.borderSize = 1.25;
			goodText.color = data_judgements.goodColor;
			goodText.cameras = [camSLEHUD];

			badText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "Bad");
			badText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			badText.scrollFactor.set();
			badText.borderSize = 1.25;
			badText.color = data_judgements.badColor;
			badText.cameras = [camSLEHUD];

			shitText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "Shit...");
			shitText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			shitText.scrollFactor.set();
			shitText.borderSize = 1.25;
			shitText.color = data_judgements.shitColor;
			shitText.cameras = [camSLEHUD];

			for (comboTextobj in [swagText, sickText, goodText, badText, shitText])
			{
				addToCurrentState(comboTextobj);
				comboTextobj.alpha = 0;
			}

			/////////////////////////////////////////////////////////////
		}
		sleVer = new FlxText(10, FlxG.height - 24, 0, "Slushi Engine v" + SlushiMain.slushiEngineVersion, 10);
		sleVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		sleVer.scrollFactor.set();
		sleVer.borderSize = 1.25;
		sleVer.color = SlushiMain.slushiColor;
		sleVer.visible = !ClientPrefs.data.hideHud;
		addToCurrentState(sleVer);

		scengine = new FlxText(10, FlxG.height - 42, 0, "SC Engine v" + states.MainMenuState.SCEVersion + ' (${SlushiMain.sceGitCommit})', 10);
		scengine.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scengine.scrollFactor.set();
		scengine.borderSize = 1.25;
		scengine.color = SlushiMain.slushiColor;
		scengine.visible = !ClientPrefs.data.hideHud;
		addToCurrentState(scengine);
		scengine.alpha = 0.7;

		sleVer.cameras = [camWaterMark];
		scengine.cameras = [camWaterMark];
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (PlayState.instance.useSLEHUD)
		{
			if (PlayState.instance != null)
			{
				comboText.text = "COMBO: " + PlayState.instance.combo;
			}
			comboText.screenCenter(X);
		}
	}

	// Thanks Edwhak for this code from Hitmans AD
	public static function setRatingText(rat:Float)
	{
		if (rat >= 0)
		{
			if (rat <= ClientPrefs.data.swagWindow)
			{
				visibleRating("swag");
			}
			else if (rat <= ClientPrefs.data.sickWindow)
			{
				visibleRating("sick");
			}
			else if (rat >= ClientPrefs.data.sickWindow && rat <= ClientPrefs.data.goodWindow)
			{
				visibleRating("good");
			}
			else if (rat >= ClientPrefs.data.goodWindow && rat <= ClientPrefs.data.badWindow)
			{
				visibleRating("bad");
			}
			else if (rat >= ClientPrefs.data.badWindow)
			{
				visibleRating("shit");
			}
		}
		else
		{
			if (rat >= ClientPrefs.data.sickWindow * -1)
			{
				visibleRating("swag");
			}
			else if (rat >= ClientPrefs.data.sickWindow * -1)
			{
				visibleRating("sick");
			}
			else if (rat <= ClientPrefs.data.sickWindow * -1 && rat >= ClientPrefs.data.goodWindow * -1)
			{
				visibleRating("good");
			}
			else if (rat <= ClientPrefs.data.goodWindow * -1 && rat >= ClientPrefs.data.badWindow * -1)
			{
				visibleRating("bad");
			}
			else if (rat <= ClientPrefs.data.badWindow * -1)
			{
				visibleRating("shit");
			}
		}

		/* Y gracias Trock por hacerme este codigo para en un principio Lua 
			(And thanks Trock for making me this code for Lua in the first place)
				function onTimerCompleted(tag)
				local nameAlpha = string.gsub(tag, "Timer", "Alpha")
				local textAlpha = string.gsub(tag, "Timer", "Text")
				doTweenAlpha(nameAlpha, textAlpha, 0, data_judgements.timeTween, "Linear")
				end
		 */
	}

	static function visibleRating(rating:String)
	{
		switch (rating)
		{
			case "swag":
				swagText.alpha = 1;
				doComboAlpha(0);
				sickText.alpha = 0;
				goodText.alpha = 0;
				badText.alpha = 0;
				shitText.alpha = 0;
			case "sick":
				sickText.alpha = 1;
				doComboAlpha(1);
				swagText.alpha = 0;
				goodText.alpha = 0;
				badText.alpha = 0;
				shitText.alpha = 0;
			case "good":
				goodText.alpha = 1;
				doComboAlpha(2);
				badText.alpha = 0;
				swagText.alpha = 0;
				badText.alpha = 0;
				shitText.alpha = 0;
			case "bad":
				badText.alpha = 1;
				doComboAlpha(3);
				goodText.alpha = 0;
				swagText.alpha = 0;
				sickText.alpha = 0;
				shitText.alpha = 0;
			case "shit":
				shitText.alpha = 1;
				doComboAlpha(4);
				badText.alpha = 0;
				swagText.alpha = 0;
				goodText.alpha = 0;
				sickText.alpha = 0;
		}
	}

	public static function doComboAngle():Void
	{
		if (!PlayState.instance.useSLEHUD)
			return;

		final newScale = 1.2;

		if (comboTxtTween != null)
			comboTxtTween.cancel();

		comboText.scale.x = newScale;
		comboText.scale.y = newScale;

		comboTxtTween = PlayState.instance.createTween(comboText.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween)
			{
				comboTxtTween = null;
			}
		});
	}

	static function doComboAlpha(comboToTween:Int):Void
	{
		if (comboAlphaTween != null)
			comboAlphaTween.cancel();

		switch (comboToTween)
		{
			case 0:
				swagText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(swagText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
			case 1:
				sickText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(sickText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
			case 2:
				goodText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(goodText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
			case 3:
				badText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(badText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
			case 4:
				shitText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(shitText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
		}
	}

	public static function setParamsFromPlayerNote(noteStrumTime:Float, isSustain:Bool, noteID:Int)
	{
		if (PlayState.instance.useSLEHUD)
		{
			setRatingText(noteStrumTime - Conductor.songPosition);
			if (!isSustain)
			{
				doComboAngle();
			}
		}
		#if windows
		if (ClientPrefs.data.changeWindowBorderColorWithNoteHit && instance.canChangeWindowColorWithNoteHit && !isSustain)
		{
			setWindowColorWithNoteHit(noteID);
		}
		#end
	}

	public static function setNotITGNotesInSteps(curStep:Int):Void
	{
		// AHHH GACIAS EDWHAK POR ESTO!!!!
		var animSkins:Array<String> = ['Default', 'Future', 'NotITG'];
		if ((PlayState.SONG.notITG || PlayState.SONG.options.notITG) && PlayState.instance.notITGMod)
		{
			for (i in 0...animSkins.length)
			{
				if (ClientPrefs.data.noteSkin.contains(animSkins[i]))
				{
					if (curStep % 4 == 0)
					{
						for (this2 in PlayState.instance.opponentStrums)
						{
							if (this2.animation.curAnim.name == 'static')
							{
								this2.rgbShader.r = 0xFF808080;
								this2.rgbShader.b = 0xFF474747;
								this2.rgbShader.enabled = true;
							}
						}
						for (this2 in PlayState.instance.playerStrums)
						{
							if (this2.animation.curAnim.name == 'static')
							{
								this2.rgbShader.r = 0xFF808080;
								this2.rgbShader.b = 0xFF474747;
								this2.rgbShader.enabled = true;
							}
						}
					}
					else if (curStep % 4 == 1)
					{
						for (this2 in PlayState.instance.opponentStrums)
						{
							if (this2.animation.curAnim.name == 'static')
							{
								this2.rgbShader.enabled = false;
							}
						}
						for (this2 in PlayState.instance.playerStrums)
						{
							if (this2.animation.curAnim.name == 'static')
							{
								this2.rgbShader.enabled = false;
							}
						}
					}
				}
			}
		}
	}

	public static function setOthersParamOfTheHUD()
	{
		if (PlayState.instance.useSLEHUD)
		{
			Debug.logSLEInfo('USING SLUSHI ENGINE HUD!');
			PlayState.instance.iconP1.visible = false;
			PlayState.instance.iconP2.visible = false;

			PlayState.instance.healthBar.angle = 90;
			PlayState.instance.healthBar.x = 950;
			PlayState.instance.healthBar.y = 350;
			PlayState.instance.healthBarNew.y = 350;
			PlayState.instance.healthBarNew.x = 950;
			PlayState.instance.healthBarNew.angle = 90;

			PlayState.instance.timeTxt.color = SlushiMain.slushiColor;
			PlayState.instance.scoreTxt.color = SlushiMain.slushiColor;
			PlayState.instance.botplayTxt.color = SlushiMain.slushiColor;

			PlayState.instance.timeBar.visible = false;
			PlayState.instance.timeBarNew.visible = false;

			PlayState.instance.botplayTxt.alpha = 0.4;

			PlayState.instance.timeTxt.y = FlxG.height - 44;
			PlayState.instance.botplayTxt.y = PlayState.instance.timeBar.y - 78;
			Debug.logSLEInfo('Trying to optimize and prepare the engine...');
			for (i in [PlayState.instance.boyfriend, PlayState.instance.dad, PlayState.instance.gf])
				if (i != null)
				{
					i.setFrames(null, false);
					i.loadGraphic(SlushiMain.getSLEPath('OthersAssets/player.png'));
					i.visible = false;
				}
			PlayState.instance.scoreTxtSprite.y = 0;
			PlayState.instance.scoreTxt.y = 0;
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////////
	#if windows
	public static function setWindowColorWithNoteHit(note:Int /*, currentNoteColor:Array<Int>*/):Void
	{
		switch (note)
		{
			// case 0:
			// 	startColorTween(0, forward, tweenDuration, currentNoteColor);
			// case 1:
			// 	startColorTween(1, forward, tweenDuration, currentNoteColor);
			// case 2:
			// 	startColorTween(2, forward, tweenDuration, currentNoteColor);
			// case 3:
			// 	startColorTween(3, forward, tweenDuration, currentNoteColor);

			case 0:
				startColorTween(0, forward, tweenDuration);
			case 1:
				startColorTween(1, forward, tweenDuration);
			case 2:
				startColorTween(2, forward, tweenDuration);
			case 3:
				startColorTween(3, forward, tweenDuration);
		}
	}

	static function startColorTween(index:Int, forward:Bool, duration:Float):Void
	{
		var tweenActived:Bool = false;

		if (tweenActived)
			return;

		var targetColor:Array<Int> = [];
		var startColor:Array<Int> = [];

		switch (index)
		{
			case 0:
				startColor = slushiWindowColor;
				targetColor = leftNoteColor;
			case 1:
				startColor = slushiWindowColor;
				targetColor = downNoteColor;
			case 2:
				startColor = slushiWindowColor;
				targetColor = upNoteColor;
			case 3:
				startColor = slushiWindowColor;
				targetColor = rightNoteColor;
		}

		if (!forward)
		{
			var temp:Array<Int> = startColor;
			startColor = targetColor;
			targetColor = temp;
		}

		tweenActived = true;
		if (windowColorNumTween != null)
		{
			windowColorNumTween.cancel();
			windowColorNumTween = null;
		}

		windowColorNumTween = FlxTween.num(0, 1, duration, {
			onComplete: function(tween:FlxTween)
			{
				if (forward)
				{
					startColorTween(index, false, duration);
				}
			}
		});

		windowColorNumTween.onUpdate = function(tween:FlxTween)
		{
			var interpolatedColor:Array<Int> = [];
			for (i in 0...3)
			{
				var newValue:Int = startColor[i] + Std.int((targetColor[i] - startColor[i]) * windowColorNumTween.value);
				newValue = Std.int(Math.max(0, Math.min(255, newValue)));
				interpolatedColor.push(newValue);
			}
			WindowsFuncs.setWindowBorderColor(interpolatedColor);
			tweenActived = false;
		};
	}

	// static function startColorTween(index:Int, forward:Bool, duration:Float, currentNoteColor:Array<Int>):Void
	// 	{
	// 		var tweenActived:Bool = false;
	// 		if (tweenActived)
	// 			return;
	// 		Debug.logSLEInfo("Note color RGB: " + currentNoteColor[0] + ", " + currentNoteColor[1] + ", " + currentNoteColor[2]);
	// 		var targetColor:Array<Int> = currentNoteColor;
	// 		var startColor:Array<Int> = slushiWindowColor;
	// 		if (!forward)
	// 		{
	// 			var temp:Array<Int> = startColor;
	// 			startColor = targetColor;
	// 			targetColor = temp;
	// 		}
	// 		tweenActived = true;
	// 		if (windowColorNumTween != null)
	// 		{
	// 			windowColorNumTween.cancel();
	// 			windowColorNumTween = null;
	// 		}
	// 		windowColorNumTween = FlxTween.num(0, 1, duration, {
	// 			onComplete: function(tween:FlxTween)
	// 			{
	// 				if (forward)
	// 				{
	// 					startColorTween(index, false, duration, currentNoteColor);
	// 				}
	// 			}
	// 		});
	// 		windowColorNumTween.onUpdate = function(tween:FlxTween)
	// 		{
	// 			var interpolatedColor:Array<Int> = [];
	// 			for (i in 0...3)
	// 			{
	// 				var newValue:Int = startColor[i] + Std.int((targetColor[i] - startColor[i]) * windowColorNumTween.value);
	// 				newValue = Std.int(Math.max(0, Math.min(255, newValue)));
	// 				interpolatedColor.push(newValue);
	// 			}
	// 			WindowsFuncs.setWindowBorderColor(interpolatedColor);
	// 			tweenActived = false;
	// 		};
	// 	}
	#end
	//////////////////////////////////////////////////////////////////////////////////////////////
	public function moveSLELogoX(xValue:Float, time:Float, ease:String)
	{
		for (sleHUDObj in [slushiSprite, sceSprite, notesSprite, sleSprite])
		{
			FlxTween.tween(sleHUDObj, {x: xValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		}

		if (xValue == -1)
		{
			for (sleHUDObj in [slushiSprite, sceSprite, notesSprite, sleSprite])
			{
				FlxTween.tween(sleHUDObj, {x: SLELogo.posX}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
			}
		}
	}

	public function moveSLELogoY(yValue:Float, time:Float, ease:String)
	{
		for (sleHUDObj in [slushiSprite, sceSprite, notesSprite, sleSprite])
		{
			FlxTween.tween(sleHUDObj, {y: yValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		}
		if (yValue == -1)
		{
			for (sleHUDObj in [slushiSprite, sceSprite, notesSprite, sleSprite])
			{
				FlxTween.tween(sleHUDObj, {y: SLELogo.posY}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
			}
		}
	}

	public function moveSLELogoAngle(angleValue:Float, time:Float, ease:String)
	{
		for (sleHUDObj in [slushiSprite, sceSprite, notesSprite, sleSprite])
		{
			FlxTween.tween(sleHUDObj, {angle: angleValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		}
	}

	public function setblackAlpha(alphaValue:Float, time:Float)
	{
		FlxTween.tween(blackGraphic, {alpha: alphaValue}, time, {ease: FlxEase.quadInOut});

		if (alphaValue == -1)
		{
			FlxTween.tween(blackGraphic, {alpha: SLELogo.blackAlpha}, time, {ease: FlxEase.quadInOut});
		}
	}
}
