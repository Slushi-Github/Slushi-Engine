package states;

import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import lime.app.Application;

class WarnFreeplay extends states.MusicBeatState
{
  public static var leftState:Bool = false;

  var warnText:FlxText;
  var txtSine:Float = 0;

  override function create()
  {
    super.create();

    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stageBackForStates'));
    bg.setGraphicSize(FlxG.width, FlxG.height);
    bg.color = FlxG.random.color();
    add(bg);

    warnText = new FlxText(0, 0, FlxG.width, "Hey!\n
			This Engine has some settings you may need to change before playing!\n
			\nWhich may be due to how some songs are!", 32);
    warnText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
    warnText.screenCenter(Y);
    add(warnText);
  }

  override function update(elapsed:Float)
  {
    txtSine += 180 * elapsed;
    warnText.alpha = 1 - Math.sin((Math.PI * txtSine) / 180);

    var back:Bool = controls.BACK;
    if (controls.ACCEPT || back)
    {
      leftState = true;
      FlxTransitionableState.skipNextTransIn = true;
      FlxTransitionableState.skipNextTransOut = true;
      if (!back)
      {
        ClientPrefs.data.freeplayWarn = false;
        ClientPrefs.saveSettings();
        FlxG.sound.play(Paths.sound('confirmMenu'));
        FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
          new FlxTimer().start(0.5, function(tmr:FlxTimer) {
            MusicBeatState.switchState(new states.freeplay.FreeplayState());
          });
        });
      }
      else
      {
        ClientPrefs.data.freeplayWarn = true;
        ClientPrefs.saveSettings();
        FlxG.sound.play(Paths.sound('cancelMenu'));
        FlxTween.tween(warnText, {alpha: 0}, 1,
          {
            onComplete: function(twn:FlxTween) {
              MusicBeatState.switchState(new states.MainMenuState());
            }
          });
      }
    }
    super.update(elapsed);
  }
}
