package slushi.slushiOptions;

import backend.StageData;
import flixel.FlxObject;
import flixel.FlxObject;

class SlushiOptionsState extends MusicBeatState
{
	var options:Array<String> = [

        'Slushi Engine Options',
		#if SLUSHI_CPP_CODE 
		'Special Windows Options'
		#end 
		];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	function openSelectedSubstate(label:String) {
		switch(label) {

			#if SLUSHI_CPP_CODE
			case 'Special Windows Options':
				openSubState(new slushi.slushiOptions.WindowsOptions());
			#end
			case 'Slushi Engine Options':
				openSubState(new slushi.slushiOptions.SlushiEngineOptions());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	var bg:FlxSprite;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var camMain:FlxCamera;
	var camSub:FlxCamera;


	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		bg = new FlxSprite().loadGraphic(SlushiMain.getSLEPath('optionsAssets/OptionsBG.png'));
		bg.scrollFactor.set();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);


		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (110 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}
		
		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	function errorAccess() {
		
		var text:FlxText = new FlxText(0, 0, 0, "You not have permission to access this!");
        text.setFormat(Paths.font("vcr.ttf"), 45, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.scrollFactor.set();
        text.borderSize = 1.25;
        text.color = slushi.SlushiMain.slushiColor;
        text.screenCenter();
        add(text);

		new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxTween.tween(text, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
			});
	}



	override function update(elapsed:Float) {

		if (FlxG.keys.pressed.F3)
			{
				slushi.substates.DebugSubState.onPlayState = false;
				openSubState(new slushi.substates.DebugSubState());
			}

		super.update(elapsed);


		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		var shiftMult:Int = 1;

		if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel);
			}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new options.OptionsState());
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function beatHit() {
		super.beatHit();

		bg.scale.set(1.11, 1.11);
		bg.updateHitbox();
		bg.offset.set();
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		ClientPrefs.keybindSaveLoad();
		super.destroy();
	}
}
