package substates;

import flixel.FlxSubState;
import backend.Conductor;

class MusicBeatSubState extends FlxSubState
{
  public function new()
  {
    super();
  }

  public var curSection:Int = 0;
  public var stepsToDo:Int = 0;

  public var lastBeat:Float = 0;
  public var lastStep:Float = 0;

  public var curStep:Int = 0;
  public var curBeat:Int = 0;

  public var curDecStep:Float = 0;
  public var curDecBeat:Float = 0;

  public var controls(get, never):Controls;

  inline function get_controls():Controls
    return Controls.instance;

  override function create():Void
  {
    super.create();
  }

  public override function destroy():Void
  {
    super.destroy();
  }

  override function update(elapsed:Float)
  {
    if (!persistentUpdate) MusicBeatState.timePassedOnState += elapsed;
    var oldStep:Int = curStep;

    updateCurStep();
    updateBeat();

    if (oldStep != curStep)
    {
      if (curStep > 0) stepHit();

      if (PlayState.SONG != null)
      {
        if (oldStep < curStep) updateSection();
        else
          rollbackSection();
      }
    }

    super.update(elapsed);
  }

  private function updateSection():Void
  {
    if (stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
    while (curStep >= stepsToDo)
    {
      curSection++;
      var beats:Float = getBeatsOnSection();
      stepsToDo += Math.round(beats * 4);
      sectionHit();
    }
  }

  private function rollbackSection():Void
  {
    if (curStep < 0) return;

    var lastSection:Int = curSection;
    curSection = 0;
    stepsToDo = 0;
    for (i in 0...PlayState.SONG.notes.length)
    {
      if (PlayState.SONG.notes[i] != null)
      {
        stepsToDo += Math.round(getBeatsOnSection() * 4);
        if (stepsToDo > curStep) break;

        curSection++;
      }
    }

    if (curSection > lastSection) sectionHit();
  }

  private function updateBeat():Void
  {
    curBeat = Math.floor(curStep / 4);
    curDecBeat = curDecStep / 4;
  }

  private function updateCurStep():Void
  {
    var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

    var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
    curDecStep = lastChange.stepTime + shit;
    curStep = Math.floor(lastChange.stepTime) + Math.floor(shit);
  }

  public function stepHit():Void
  {
    if (curStep % 4 == 0) beatHit();
  }

  public function beatHit():Void
  {
    // do literally nothing dumbass
  }

  public function sectionHit():Void
  {
    // yep, you guessed it, nothing again, dumbass
  }

  public function getBeatsOnSection()
  {
    var val:Null<Float> = 4;
    if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
    return val == null ? 4 : val;
  }

  public function refresh()
  {
    sort(utils.SortUtil.byZIndex, flixel.util.FlxSort.ASCENDING);
  }
}
