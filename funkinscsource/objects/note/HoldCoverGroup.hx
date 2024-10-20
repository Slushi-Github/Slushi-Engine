package objects.note;

class HoldCoverGroup extends FlxTypedSpriteGroup<HoldCoverSprite>
{
  public var enabled:Bool = true;
  public var isPlayer:Bool = false;
  public var canSplash:Bool = false;
  public var isReady(get, never):Bool;

  function get_isReady():Bool
  {
    if (PlayState.instance != null)
    {
      return (PlayState.instance.strumLineNotes != null
        && PlayState.instance.strumLineNotes.members.length > 0
        && !PlayState.instance.startingSong
        && !PlayState.instance.inCutscene
        && !PlayState.instance.inCinematic
        && PlayState.instance.generatedMusic);
    }
    return false;
  }

  public function new(enabled:Bool, isPlayer:Bool, canSplash:Bool = false)
  {
    this.enabled = enabled;
    this.isPlayer = isPlayer;
    this.canSplash = canSplash;
    super(0, 0, 4);
    for (i in 0...maxSize)
      addHolds(i);
  }

  public dynamic function addHolds(i:Int)
  {
    var colors:Array<String> = ["Purple", "Blue", "Green", "Red"];
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
    this.add(hold);
  }

  public dynamic function spawnOnNoteHit(note:Note):Void
  {
    var noteData:Int = note.noteData;
    var isSus:Bool = note.isSustainNote;
    var isHoldEnd:Bool = note.isHoldEnd;
    if (enabled && isReady)
    {
      if (isSus)
      {
        this.members[noteData].affectSplash(HOLDING, noteData, note);
        if (isHoldEnd)
        {
          if (canSplash) this.members[noteData].affectSplash(SPLASHING, noteData);
          else
            this.members[noteData].affectSplash(DONE, noteData);
        }
      }
    }
  }

  public dynamic function despawnOnMiss(direction:Int, ?note:Note = null):Void
  {
    var noteData:Int = (note != null ? note.noteData : direction);
    if (enabled && isReady) this.members[noteData].affectSplash(STOP, noteData, note);
  }

  public dynamic function updateHold(elapsed:Float):Void
  {
    if (enabled && isReady)
    {
      for (i in 0...this.members.length)
      {
        if (this.members[i].x != pos(i, "x") - 110)
        {
          this.members[i].x = pos(i, "x") - 110;
        }
        if (this.members[i].y != pos(i, "y") - 100)
        {
          this.members[i].y = pos(i, "y") - 100;
        }

        if (this.members[i].boom)
        {
          if (this.members[i].isAnimationFinished())
          {
            this.members[i].visible = this.members[i].boom = false;
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
