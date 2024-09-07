package objects.stage;

class BackgroundGirls extends FunkinSCSprite
{
  var isPissed:Bool = true;

  public function new(x:Float, y:Float, ?prefix:String)
  {
    super(x, y);

    // BG fangirls dissuaded
    frames = Paths.getSparrowAtlas('weeb/' + prefix + 'bgFreaks');
    antialiasing = false;
    swapDanceType();

    setGraphicSize(Std.int(width * PlayState.daPixelZoom));
    updateHitbox();
    animation.play('danceLeft');
  }

  var danceDir:Bool = false;

  public function swapDanceType():Void
  {
    isPissed = !isPissed;
    if (!isPissed)
    { // Gets unpissed
      animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, true);
      animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(29, 15), "", 24, true);
    }
    else
    { // Pisses
      animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, true);
      animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(29, 15), "", 24, true);
    }
    danceDir = !danceDir;

    if (danceDir) animation.play('danceRight', true);
    else
      animation.play('danceLeft', true);
  }

  override public function beatHit(curBeat:Int):Void
  {
    danceDir = !danceDir;

    if (danceDir) animation.play('danceRight', true);
    else
      animation.play('danceLeft', true);
  }
}
