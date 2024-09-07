package backend;

// Borrowed from schmovin by 4mbr0s3-2
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxPoint;

class CameraCopy extends FlxCamera
{
  var _target:FlxCamera;

  public var scrollOffset:FlxPoint = new FlxPoint();
  public var scrollOverrideTarget:FlxPoint = new FlxPoint();
  public var scrollOverride:Float = 0;
  public var zoomOffset:Float = 0;
  public var angleOffset:Float = 0;

  override public function new(target:FlxCamera)
  {
    super();
    _target = target;
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);
    this.copyFrom(_target);
    this.x = _target.x;
    this.y = _target.y;

    this.filters = _target.filters;

    this.scroll.copyFrom(_target.scroll);
    this.scroll.addPoint(scrollOffset);
    this.scroll.scale(1 - scrollOverride);
    this.scroll.addPoint(scrollOverrideTarget.scale(scrollOverride));

    this.angle = _target.angle + angleOffset;
    this.scaleX = _target.scaleX;
    this.scaleY = _target.scaleY;
    this.zoom = _target.zoom + zoomOffset;
    this.width = _target.width;
    this.height = _target.height;
  }

  public static function elapsedScrollFactor():Float
  {
    return 1 / (60 * FlxG.elapsed);
  }

  override function updateFollow()
  {
    super.updateFollow();
    scroll.x -= (_scrollTarget.x - scroll.x) * followLerp * FlxG.updateFramerate / 60;
    scroll.y -= (_scrollTarget.y - scroll.y) * followLerp * FlxG.updateFramerate / 60;

    scroll.x += (_scrollTarget.x - scroll.x) * followLerp * FlxG.updateFramerate / 60 / elapsedScrollFactor();
    scroll.y += (_scrollTarget.y - scroll.y) * followLerp * FlxG.updateFramerate / 60 / elapsedScrollFactor();
  }
}
