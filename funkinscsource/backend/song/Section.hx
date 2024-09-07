package backend.song;

class Section
{
  public var sectionNotes:Array<Dynamic> = [];

  public var sectionBeats:Float = 4;
  public var gfSection:Bool = false;
  public var mustHitSection:Bool = true;
  public var player4Section:Bool = false;

  public function new(sectionBeats:Float = 4)
  {
    this.sectionBeats = sectionBeats;
    Debug.logTrace('test created section: ' + sectionBeats);
  }
}
