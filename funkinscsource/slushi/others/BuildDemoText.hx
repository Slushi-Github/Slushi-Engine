package slushi.others;

import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * A class that displays a warning that this is a test build, useful for when you want to show a build 
 * to others and you want to make sure that if it is leaked, it will be easy to recognize, am I clear xd?
 * 
 * Author: Slushi
 */

class BuildDemoText extends TextField
{
	public function new()
	{
		super();

		x = (FlxG.width - this.width) / 2;
		y = ((FlxG.height - this.height) / 2) + 350;

		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 20, 0xffffff);
		autoSize = CENTER;
		text = 'THIS IS A TEST BUILD (${SlushiMain.slushiEngineVersion} - ${SlushiMain.buildNumber}), NOT A RELEASE BUILD!';
		alpha = 0.5;
	}
}
