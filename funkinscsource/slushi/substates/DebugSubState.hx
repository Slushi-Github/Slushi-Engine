package slushi.substates;

import slushi.winSL.WinSLConsoleUtils;

/**
 * A debug menu, copied from NotITG only in my style.
 * It also has a guide to the keystroke combinations
 * that can be used to do some things
 * last but not least, it also shows the engine compile number and the time. 
 * engine compilation number and time.
 * 
 * Author: Slushi
 */
class DebugSubState extends MusicBeatSubState
{
	var camDebugState:FlxCamera;

	var camText:FlxCamera;
	var alltexts:Array<String> = [
		'[In Gameplay] F3 + B: Active Botplay',
		'[In Gameplay] F3 + P: Active Practice mode',
		#if windows
		'F3 + C: Center the window',
		#end
		'F3 + F: Force crash',
	];

	public static var onPlayState:Bool = false;

	var mainText:FlxText;
	var actualTime:FlxText;

	override public function create()
	{
		super.create();

		camDebugState = new FlxCamera();
		camDebugState.bgColor.alpha = 0;
		FlxG.cameras.add(camDebugState, false);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		var titleText:FlxText = new FlxText(75, 45, "Debug Menu");
		titleText.scrollFactor.set();
		titleText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.alpha = 0.6;
		add(titleText);

		var buildNumber:FlxText = new FlxText(0, 660, "build:\n" + SlushiMain.buildNumber + " - (" + SlushiMain.slushiEngineVersion + ")");
		buildNumber.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		buildNumber.scrollFactor.set();
		buildNumber.screenCenter(X);
		// buildNumber.x -= 200;
		buildNumber.alpha = 0.6;
		add(buildNumber);

		actualTime = new FlxText(0, 10, "Time:\n");
		actualTime.scrollFactor.set();
		actualTime.screenCenter(X);
		actualTime.x -= 50;
		actualTime.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		actualTime.alpha = 0.6;
		add(actualTime);

		for (i in 0...alltexts.length)
		{
			mainText = new FlxText(0, 0, alltexts[i]);
			mainText.scrollFactor.set();
			mainText.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			mainText.screenCenter();
			mainText.y += (80 * (i - (alltexts.length / 2))) + 50;
			add(mainText);
		}

		for (obj in [buildNumber, actualTime, titleText, mainText])
		{
			obj.alpha = 0;
			FlxTween.tween(buildNumber, {alpha: 1}, 0.3, {ease: FlxEase.linear});
		}

		for (obj in [buildNumber, actualTime, titleText, mainText])
		{
			obj.y -= 10;
		}
		FlxTween.tween(buildNumber, {y: buildNumber.y + 10}, 0.3, {ease: FlxEase.linear});
		FlxTween.tween(actualTime, {y: actualTime.y + 10}, 0.3, {ease: FlxEase.linear});
		FlxTween.tween(titleText, {y: titleText.y + 10}, 0.3, {ease: FlxEase.linear});
		FlxTween.tween(mainText, {y: mainText.y + 10}, 0.3, {ease: FlxEase.linear});

		cameras = [camDebugState];
	}

	override function update(elapsed:Float)
	{
		actualTime.text = "Time:\n" + CustomFuncs.getTime();

		if (FlxG.keys.pressed.F3 && FlxG.keys.justPressed.F)
		{
			if (onPlayState)
				return SlushiDebugText.printInDisplay("Can't toggle while on PlayState", FlxColor.RED);

			var nullVar = null;
			nullVar.toString();
		}

		if (FlxG.keys.pressed.F3 && FlxG.keys.justPressed.B && onPlayState)
		{
			PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
			PlayState.changedDifficulty = true;
			PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
			PlayState.instance.botplayTxt.alpha = 1;
			PlayState.instance.botplaySine = 0;
			switch (PlayState.instance.cpuControlled)
			{
				case true:
					SlushiDebugText.printInDisplay("Botplay enabled", FlxColor.WHITE);
				case false:
					SlushiDebugText.printInDisplay("Botplay disabled", FlxColor.WHITE);
			}
		}

		if (FlxG.keys.pressed.F3 && FlxG.keys.justPressed.P && onPlayState)
		{
			PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
			PlayState.changedDifficulty = true;

			switch (PlayState.instance.practiceMode)
			{
				case true:
					SlushiDebugText.printInDisplay("Practice mode enabled", FlxColor.WHITE, 0.6);
				case false:
					SlushiDebugText.printInDisplay("Practice mode disabled", FlxColor.WHITE, 0.6);
			}
		}

		if (FlxG.keys.pressed.F3 && FlxG.keys.justPressed.W && !onPlayState)
		{
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			bg.camera = camDebugState;
			add(bg);
			FlxTween.tween(bg, {alpha: 1}, 1.5, {
				ease: FlxEase.expoIn,
				onComplete: function(tween:FlxTween)
				{
					WinSLConsoleUtils.init();
				}
			});
		}

		#if windows
		if (FlxG.keys.pressed.F3 && FlxG.keys.pressed.C && !Application.current.window.maximized)
		{
			CppAPI.centerWindow();
		}
		#end

		if (FlxG.keys.justReleased.F3)
		{
			close();
		}
		super.update(elapsed);
	}
}