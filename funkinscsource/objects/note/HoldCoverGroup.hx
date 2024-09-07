package objects.note;

class HoldCoverGroup extends FlxTypedSpriteGroup<HoldCoverSprite>
{
  public var enabled:Bool = true;
  public var isPlayer:Bool = false;
  public var isReady:Bool = false;

  public function new(enabled:Bool, isPlayer:Bool)
  {
    this.enabled = enabled;
    this.isPlayer = isPlayer;
    super(0, 0, 4);
    for (i in 0...maxSize)
      addHolds(i);
  }

  public dynamic function addHolds(i:Int)
  {
    var colors:Array<String> = ["Purple", "Blue", "Green", "Red", "Purple", "Blue", "Green", "Red"];
    var hcolor:String = colors[i];
    var hold:HoldCoverSprite = new HoldCoverSprite();
    hold.initFrames(i, hcolor);
    hold.initAnimations(i, hcolor);
    hold.boom = false;
    hold.isPlaying = false;
    hold.visible = false;
    hold.activatedSprite = enabled;
    hold.spriteId = '$hcolor-$i';
    hold.spriteIntID = i;
    add(hold);
  }

  public dynamic function spawnOnNoteHit(note:Note):Void
  {
    var noteData:Int = note.noteData % 4;
    var isSus:Bool = note.isSustainNote;
    var isHoldEnd:Bool = note.isHoldEnd;
    if (enabled && isReady)
    {
      if (isSus)
      {
        members[noteData].affectSplash('Holding', noteData, note);
        if (isHoldEnd)
        {
          if (isPlayer) members[noteData].affectSplash('Splashing', noteData);
          else
            members[noteData].affectSplash('Done', noteData);
        }
      }
    }
  }

  public dynamic function despawnOnMiss(direction:Int, ?note:Note = null):Void
  {
    var noteData:Int = (note != null ? note.noteData % 4 : direction % 4);
    if (enabled && isReady) members[noteData].affectSplash('Stop', noteData, note);
  }

  public dynamic function updateHold(elapsed:Float):Void
  {
    if (enabled && isReady)
    {
      for (i in 0...members.length)
      {
        if (members[i].x != pos(i, "x") - 110)
        {
          members[i].x = pos(i, "x") - 110;
        }
        if (members[i].y != pos(i, "y") - 100)
        {
          members[i].y = pos(i, "y") - 100;
        }

        if (members[i].boom)
        {
          if (members[i].isAnimationFinished())
          {
            members[i].visible = false;
            members[i].boom = false;
          }
        }
      }
    }
  }

  public dynamic function pos(note:Int, variable:String):Float
  {
    if (enabled && isReady)
    {
      if (PlayState.instance != null)
      {
        var game:PlayState = PlayState.instance;
        if (game.strumLineNotes != null)
        {
          if (variable == "x") return game.strumLineNotes.members[isPlayer ? note + 4 : note].x;
          else if (variable == "y") return game.strumLineNotes.members[isPlayer ? note + 4 : note].y;
        }
        return 0;
      }
      return 0;
    }
    return 0;
  }
}
