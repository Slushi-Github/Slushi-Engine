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
		SwagColor: 0xff8FD9D1,
		SickColor: 0xFFFFFB00,
		GoodColor: 0xFF00EB1F,
		BadColor: 0xFFFF2600,
		ShitColor: 0xFF555555
	};
	static var comboText:FlxText;
	static var SwagText:FlxText;
	static var SickText:FlxText;
	static var GoodText:FlxText;
	static var BadText:FlxText;
	static var ShitText:FlxText;

	public var sleVer:FlxText;
	public var scengine:FlxText;

	static var camSLEHUD:FlxCamera;
	static var camWaterMark:FlxCamera;
	static var camHUD:FlxCamera;

	static var leftNoteColor:Array<Int> = [194, 75, 153];
	static var downNoteColor:Array<Int> = [0, 253, 253];
	static var upNoteColor:Array<Int> = [18, 250, 5];
	static var rightNoteColor:Array<Int> = [249, 58, 63];
	static var slushiWindowColor:Array<Int> = [214, 243, 222];
	public var canChangeWindowColorWithNoteHit:Bool = true;
	static var tweenDuration:Float = 0.3;
	static var windowColorNumTween:NumTween;
	static var forward:Bool = false;

	static var comboTxtTween:FlxTween;
	static var comboAlphaTween:FlxTween;

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
			bgSprite.loadGraphic(SlushiMain.getSLEPath('SLEHUDImages/BG.png'));
			bgSprite.scrollFactor.set(0, 0);
			bgSprite.antialiasing = ClientPrefs.data.antialiasing;
			bgSprite.cameras = [camSLEHUD];
			addToCurrentState(bgSprite);

			slushiSprite = new FlxSprite(SLELogo.posX, SLELogo.posY);
			slushiSprite.loadGraphic(SlushiMain.getSLEPath('SLEHUDImages/Slushi.png'));
			slushiSprite.scrollFactor.set(0, 0);
			slushiSprite.scale.set(0.8, 0.8);
			slushiSprite.antialiasing = ClientPrefs.data.antialiasing;
			slushiSprite.cameras = [camSLEHUD];
			addToCurrentState(slushiSprite);

			sceSprite = new FlxSprite(SLELogo.posX, SLELogo.posY);
			sceSprite.loadGraphic(SlushiMain.getSLEPath('SLEHUDImages/SCEngineText.png'));
			sceSprite.scrollFactor.set(0, 0);
			sceSprite.scale.set(0.8, 0.8);
			sceSprite.antialiasing = ClientPrefs.data.antialiasing;
			sceSprite.cameras = [camSLEHUD];
			addToCurrentState(sceSprite);

			notesSprite = new FlxSprite(SLELogo.posX, SLELogo.posY);
			notesSprite.loadGraphic(SlushiMain.getSLEPath('SLEHUDImages/Notes.png'));
			notesSprite.scrollFactor.set(0, 0);
			notesSprite.scale.set(0.8, 0.8);
			notesSprite.antialiasing = ClientPrefs.data.antialiasing;
			notesSprite.cameras = [camSLEHUD];
			addToCurrentState(notesSprite);

			sleSprite = new FlxSprite(SLELogo.posX, SLELogo.posY);
			sleSprite.loadGraphic(SlushiMain.getSLEPath('SLEHUDImages/SlushiEngineText.png'));
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

			SwagText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "SICK!!!");
			SwagText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			SwagText.scrollFactor.set();
			SwagText.borderSize = 1.25;
			SwagText.color = data_judgements.SwagColor;
			SwagText.cameras = [camSLEHUD];

			SickText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "SICK!!");
			SickText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			SickText.scrollFactor.set();
			SickText.borderSize = 1.25;
			SickText.color = data_judgements.SickColor;
			SickText.cameras = [camSLEHUD];

			GoodText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "Good!");
			GoodText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			GoodText.scrollFactor.set();
			GoodText.borderSize = 1.25;
			GoodText.color = data_judgements.GoodColor;
			GoodText.cameras = [camSLEHUD];

			BadText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "Bad");
			BadText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			BadText.scrollFactor.set();
			BadText.borderSize = 1.25;
			BadText.color = data_judgements.BadColor;
			BadText.cameras = [camSLEHUD];

			ShitText = new FlxText(comboText.x + data_judgements.posX, data_judgements.posY, 0, "Shit...");
			ShitText.setFormat(Paths.font("wendy.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			ShitText.scrollFactor.set();
			ShitText.borderSize = 1.25;
			ShitText.color = data_judgements.ShitColor;
			ShitText.cameras = [camSLEHUD];

			addToCurrentState(SwagText);
			addToCurrentState(SickText);
			addToCurrentState(GoodText);
			addToCurrentState(BadText);
			addToCurrentState(ShitText);

			SickText.alpha = 0;
			SwagText.alpha = 0;
			GoodText.alpha = 0;
			BadText.alpha = 0;
			ShitText.alpha = 0;

			/////////////////////////////////////////////////////////////
		}
		sleVer = new FlxText(10, FlxG.height - 24, 0, "Slushi Engine v" + SlushiMain.slushiEngineVersion, 10);
		sleVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		sleVer.scrollFactor.set();
		sleVer.borderSize = 1.25;
		sleVer.color = SlushiMain.slushiColor;
		sleVer.visible = !ClientPrefs.data.hideHud;
		addToCurrentState(sleVer);

		scengine = new FlxText(10, FlxG.height - 42, 0, "SC Engine v" + states.MainMenuState.SCEVersion +' (${SlushiMain.sceGitCommit})', 10);
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
				comboText.text = "COMBO: " + PlayState.instance.combo;
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
				SwagText.alpha = 1;
				doComboAlpha(0);
				SickText.alpha = 0;
				GoodText.alpha = 0;
				BadText.alpha = 0;
				ShitText.alpha = 0;
			case "sick":
				SickText.alpha = 1;
				doComboAlpha(1);
				SwagText.alpha = 0;
				GoodText.alpha = 0;
				BadText.alpha = 0;
				ShitText.alpha = 0;
			case "good":
				GoodText.alpha = 1;
				doComboAlpha(2);
				BadText.alpha = 0;
				SwagText.alpha = 0;
				BadText.alpha = 0;
				ShitText.alpha = 0;
			case "bad":
				BadText.alpha = 1;
				doComboAlpha(3);
				GoodText.alpha = 0;
				SwagText.alpha = 0;
				SickText.alpha = 0;
				ShitText.alpha = 0;
			case "shit":
				ShitText.alpha = 1;
				doComboAlpha(4);
				BadText.alpha = 0;
				SwagText.alpha = 0;
				GoodText.alpha = 0;
				SickText.alpha = 0;
		}
	}

	public static function doComboAngle():Void
	{
		if (!PlayState.instance.useSLEHUD)
			return;

		var newScale = 1.2;

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
				SwagText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(SwagText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
			case 1:
				SickText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(SickText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
			case 2:
				GoodText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(GoodText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
			case 3:
				BadText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(BadText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
			case 4:
				ShitText.alpha = 1;
				comboAlphaTween = PlayState.instance.createTween(ShitText, {alpha: 0}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						comboAlphaTween = null;
					}
				});
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
			PlayState.instance.timeBarNew.camera = camSLEHUD;
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
	public static function setWindowColorWithNoteHit(note:Int/*, currentNoteColor:Array<Int>*/):Void
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
		FlxTween.tween(slushiSprite, {x: xValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		FlxTween.tween(sceSprite, {x: xValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		FlxTween.tween(notesSprite, {x: xValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		FlxTween.tween(sleSprite, {x: xValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});

		if (xValue == -1)
		{
			FlxTween.tween(slushiSprite, {x: SLELogo.posX}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
			FlxTween.tween(sceSprite, {x: SLELogo.posX}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
			FlxTween.tween(notesSprite, {x: SLELogo.posX}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
			FlxTween.tween(sleSprite, {x: SLELogo.posX}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		}
	}

	public function moveSLELogoY(yValue:Float, time:Float, ease:String)
	{
		FlxTween.tween(slushiSprite, {y: yValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		FlxTween.tween(sceSprite, {y: yValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		FlxTween.tween(notesSprite, {y: yValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		FlxTween.tween(sleSprite, {y: yValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});

		if (yValue == -1)
		{
			FlxTween.tween(slushiSprite, {y: SLELogo.posY}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
			FlxTween.tween(sceSprite, {y: SLELogo.posY}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
			FlxTween.tween(notesSprite, {y: SLELogo.posY}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
			FlxTween.tween(sleSprite, {y: SLELogo.posY}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		}
	}

	public function moveSLELogoAngle(angleValue:Float, time:Float, ease:String)
	{
		FlxTween.tween(slushiSprite, {angle: angleValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		FlxTween.tween(sceSprite, {angle: angleValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		FlxTween.tween(notesSprite, {angle: angleValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
		FlxTween.tween(sleSprite, {angle: angleValue}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
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