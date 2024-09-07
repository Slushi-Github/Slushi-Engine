package objects.note;

class Strumline extends FlxTypedGroup<StrumArrow>
{
  // Used in-game to control the scroll speed within a song
  public var scrollSpeed(default, set):Float = 1.0;
  public var allowScrollSpeedOverride:Bool = true;

  public var notes:FlxTypedGroup<Note> = null;

  private function set_scrollSpeed(value:Float):Float
  {
    var overrideSpeed:Float = PlayState.instance?.songSpeed ?? 1.0;
    scrollSpeed = allowScrollSpeedOverride ? overrideSpeed : value;
    return allowScrollSpeedOverride ? overrideSpeed : value;
  }

  public function new(limit:Int)
  {
    super(limit);
  }
}
