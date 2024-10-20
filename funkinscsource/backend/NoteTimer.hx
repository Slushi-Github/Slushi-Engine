package backend;

import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import backend.Conductor;
import shaders.CircleEffect;

using flixel.util.FlxSpriteUtil;

class NoteTimer extends FlxTypedSpriteGroup<FlxSprite>
{
  private var instance:PlayState;
  private var timerText:FlxText;
  private var timerCircle:FlxSprite;
  private var circleShader:CircleEffect = new CircleEffect();

  public function new(instance:PlayState)
  {
    super();
    this.instance = instance;

    timerCircle = new FlxSprite().loadGraphic(Paths.image("circleThing"));
    timerCircle.antialiasing = true;
    timerCircle.shader = circleShader.shader;
    timerCircle.scale *= 0.75;
    timerCircle.updateHitbox();
    add(timerCircle);
    timerText = new FlxText(0, 0, 0, "");
    timerText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(timerText);

    timerCircle.screenCenter();
    timerText.screenCenter();

    circleShader.percent = 0.0;

    // alpha = 0;
  }

  private var lastStartTime:Float = FlxMath.MAX_VALUE_FLOAT;

  override public function update(elapsed:Float)
  {
    super.update(elapsed);
    var timeTillNextNote:Float = FlxMath.MAX_VALUE_FLOAT;

    if (instance != null)
    {
      var show:Bool = false;
      if (Conductor.songPosition > 0)
      {
        for (daNote in instance.notes)
          if (daNote.mustPress) // check notes for closest
          {
            final timeDiff = daNote.strumTime - Conductor.songPosition;
            if (timeDiff < timeTillNextNote) timeTillNextNote = timeDiff;
          }

        if (timeTillNextNote == FlxMath.MAX_VALUE_FLOAT) // now check unspawnNotes if not found anything
        {
          for (daNote in instance.unspawnNotes.members)
            if (daNote.mustPress)
            {
              final timeDiff = daNote.strumTime - Conductor.songPosition;
              if (timeDiff < timeTillNextNote)
              {
                timeTillNextNote = timeDiff;
                break;
              }
            }
        }
        show = timeTillNextNote != FlxMath.MAX_VALUE_FLOAT; // if found a note and time is larger than 2 secs
      }

      // visible = false;
      var targetAlpha:Float = 0.0;
      if (show)
      {
        if (lastStartTime == FlxMath.MAX_VALUE_FLOAT && timeTillNextNote > 3000) lastStartTime = timeTillNextNote;

        if (lastStartTime != FlxMath.MAX_VALUE_FLOAT)
        {
          var secsLeft:Float = Math.ceil(timeTillNextNote * 0.001);
          var percent:Float = timeTillNextNote / lastStartTime;
          // timerCircle.amount = percent;
          if (percent <= 0.0)
          {
            lastStartTime = FlxMath.MAX_VALUE_FLOAT; // reset
            timerText.text = "";
            circleShader.percent = 0.0;
          }
          else
          {
            circleShader.percent = percent;
            timerText.text = "" + secsLeft;
          }
          updatePosition();
        }
        if (timeTillNextNote > 1000)
        {
          // visible = true;
          targetAlpha = 1.0;
        }
      }

      timerText.alpha = FlxMath.lerp(timerText.alpha, targetAlpha, elapsed * 5);
      timerCircle.alpha = timerText.alpha;
    }
  }

  function updatePosition()
  {
    timerCircle.screenCenter();
    timerText.screenCenter();
    if (ClientPrefs.data.downScroll)
    {
      timerCircle.y += 260;
      timerText.y += 260;
    }
    else
    {
      timerCircle.y -= 260;
      timerText.y -= 260;
    }
  }
}
