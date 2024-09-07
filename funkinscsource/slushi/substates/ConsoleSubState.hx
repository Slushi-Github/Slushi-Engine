package slushi.substates;

import backend.ui.PsychUIInputText;
import slushi.winSL.WinSLConsoleUtils;

/**
 * This is the substate for the console substate, alvadible in the SlushiMainMenuState
 * 
 * CURRENTLY BROKEN (?)
 * 
 * Author: Slushi
 */

class ConsoleSubState extends MusicBeatSubState
{
	var camConsole:FlxCamera;
	var input:PsychUIInputText;
	var resultText:FlxText;
	var sign:FlxText;
	var sletext:FlxText;
	var consoleText:FlxText;
	var sine:Float = 0;
	////////////////////
	var canEnterInput:Bool = true;
	var canExit:Bool = true;

	//////////////////////////////////////////////////////////////////////////////
	// ehh.. thanks Edwhak for this i suppose XD
	var commandsList:Array<String> = [
		'help', // Basic commands
		'engine.exit', // System commands
		'brutus', 'clear', 'cls',
		'test' // testing commands
	];

	function checkCommand(command:String)
	{
		var resultCommand:String = "";
		var centeredSLEText:Bool = false;
		if(commandsList.contains(command) && command != '' && command != null)
		{
			resultCommand = commandsList[commandsList.indexOf(command)];
			// updatePromptText(commandsInfo[commandsList.indexOf(command)]);
			applyCommand(resultCommand);
		}
		else
		{
			switch(command)
			{
				case '':
					updatePromptText('Must enter some input');
				default:
					updatePromptText('Command $command Not Found');
			}
		}

		if(resultText.height > FlxG.height)
			{
				FlxTween.tween(resultText, {y: resultText.y - 50}, 0.4, {ease: FlxEase.expoIn});
				if(!centeredSLEText) FlxTween.tween(sletext, {x: (FlxG.width - sletext.width) / 2}, 0.7, {ease: FlxEase.expoIn});
			}

		if(command != '') Debug.logSLEInfo('Input command is: ' + resultCommand);
		return resultCommand;
	}

	function applyCommand(command:String)
		{
			switch(command)
			{
				case 'brutus':
					canExit = false;
					resetTexts(0.01);
					var brutus:FlxSprite = new FlxSprite(0, 0);
					brutus.loadGraphic(SlushiMain.getSLEPath('OthersAssets/brutus.png'));
					brutus.scrollFactor.set(0, 0);
					brutus.screenCenter();
					brutus.antialiasing = ClientPrefs.data.antialiasing;

					var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					bg.scrollFactor.set();
					add(bg);
					add(brutus);
					FlxG.sound.play(SlushiMain.getSLEPath("Sounds/vineBoom.ogg"));
					FlxTween.tween(brutus, {alpha: 0}, 1.5, {ease: FlxEase.expoIn});
					FlxTween.tween(bg, {alpha: 0}, 1.5, {ease: FlxEase.expoIn, onComplete: 
						function(tween:FlxTween){
							canExit = true;
							brutus.destroy();
							bg.destroy();
					}});
				case 'clear' | 'cls':
					resetTexts(0.01);
				case 'engine.exit':
					var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					bg.alpha = 0;
					bg.scrollFactor.set();
					add(bg);
					FlxTween.tween(bg, {alpha: 1}, 1.5, {ease: FlxEase.expoIn, onComplete: 
						function(tween:FlxTween){
							WinSLConsoleUtils.init();
					}});
			}
		}

	function updatePromptText(text:String)
	{
		resultText.text += text + '\n\n';
	}

	function resetTexts(seconds:Float)
	{
		new FlxTimer().start(seconds, function(tmr:FlxTimer)
		{
			FlxTween.tween(sletext, {x: 10}, 0.7, {ease: FlxEase.expoIn});
			FlxTween.tween(resultText, {y: sletext.y + 40}, 0.7, {ease: FlxEase.expoIn});
			resultText.text = "";
			input.text = "";
		});
	}

	//////////////////////////////////////////////////////////////////////////////

	override public function create()
	{
		super.create();

		camConsole = new FlxCamera();
		camConsole.bgColor.alpha = 0;
		FlxG.cameras.add(camConsole, false);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.8;
		bg.scrollFactor.set();
		add(bg);

		sletext = new FlxText(10, 29, 0, "Slushi Engine Terminal Mode");
		sletext.setFormat(Paths.font("Consolas-Bold.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		sletext.scrollFactor.set();
		sletext.borderSize = 1.25;
		add(sletext);

		consoleText = new FlxText(10, FlxG.height - 46, "Console");
		consoleText.scrollFactor.set();
		consoleText.setFormat(Paths.font("Consolas-Bold.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(consoleText);

		sign = new FlxText(10, consoleText.y + 20, 0, ">");
		sign.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		sign.scrollFactor.set();
		sign.borderSize = 1.25;
		add(sign);

		resultText = new FlxText(10, sletext.y + 40, 0, "");
		resultText.setFormat(Paths.font("Consolas-Bold.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resultText.scrollFactor.set();
		resultText.borderSize = 1.25;
		add(resultText);

		input = new PsychUIInputText(27, FlxG.height - 26, FlxG.width, "", 20);
		input.textObj.setFormat(Paths.font("Consolas-Bold.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		input.scrollFactor.set();
		input.maxLength = 50;
		add(input);

		input.onChange = function(text:String, event:String) { 
			if(FlxG.keys.justPressed.ENTER && canEnterInput) {
				checkCommand(text);
			}
		}

		cameras = [camConsole];
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// input.callback = function(text:String, event:String) { 
		// 	if(FlxG.keys.justPressed.ENTER && canEnterInput) {
		// 		checkCommand(text);
		// 	}
		// }

		sine += 180 * elapsed;
		if (sign != null)
			sign.alpha = 1 - Math.sin((Math.PI * sine) / 180);

		if (FlxG.keys.justPressed.ESCAPE && canExit)
		{
			slushi.states.SlushiMainMenuState.inConsole = false;
			resetTexts(0.001);
			input.destroy();
			resultText.destroy();
			canEnterInput = false;
			close();
		}
	}
}