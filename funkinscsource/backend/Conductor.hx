package backend;

import backend.song.SongData;

typedef BPMChangeEvent =
{
  var stepTime:Float;
  var songTime:Float;
  var bpm:Float;
  var ?stepCrochet:Float;
}

class Conductor
{
  public static var ROWS_PER_BEAT:Int = 48;
  // its 48 in ITG but idk because FNF doesnt work w/ note rows
  public static var ROWS_PER_MEASURE:Int = ROWS_PER_BEAT * 4;

  public static var bpm(default, set):Float = 100;
  public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
  public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
  public static var songPosition:Float = 0;
  public static var offset:Float = 0;

  // public static var safeFrames:Int = 10;
  public static var safeZoneOffset:Float = 0; // is calculated in create(), is safeFrames in milliseconds

  public static var bpmChangeMap:Array<BPMChangeEvent> = [];

  inline public static function beatToNoteRow(beat:Float):Int
  {
    return Math.round(beat * Conductor.ROWS_PER_BEAT);
  }

  inline public static function noteRowToBeat(row:Float):Float
  {
    return row / Conductor.ROWS_PER_BEAT;
  }

  public static function timeSinceLastBPMChange(time:Float):Float
  {
    var lastChange = getBPMFromSeconds(time);
    return time - lastChange.songTime;
  }

  public static function getBeatSinceChange(time:Float):Float
  {
    var lastBPMChange = getBPMFromSeconds(time);
    return (time - lastBPMChange.songTime) / (lastBPMChange.stepCrochet * 4);
  }

  public static function getCrotchetAtTime(time:Float)
  {
    var lastChange = getBPMFromSeconds(time);
    return lastChange.stepCrochet * 4;
  }

  public static function getBPMFromSeconds(time:Float)
  {
    var lastChange:BPMChangeEvent =
      {
        stepTime: 0,
        songTime: 0,
        bpm: bpm,
        stepCrochet: stepCrochet
      }
    for (i in 0...Conductor.bpmChangeMap.length)
    {
      if (time >= Conductor.bpmChangeMap[i].songTime) lastChange = Conductor.bpmChangeMap[i];
      else
        break;
    }
    return lastChange;
  }

  public static function getBPMFromStep(step:Float)
  {
    var lastChange:BPMChangeEvent =
      {
        stepTime: 0,
        songTime: 0,
        bpm: bpm,
        stepCrochet: stepCrochet
      }
    for (i in 0...Conductor.bpmChangeMap.length)
    {
      if (step >= Conductor.bpmChangeMap[i].stepTime) lastChange = Conductor.bpmChangeMap[i];
      else
        break;
    }

    return lastChange;
  }

  public static function beatToSeconds(beat:Float):Float
  {
    var step = beat * 4;
    var lastChange = getBPMFromStep(step);
    return lastChange.songTime + ((step - lastChange.stepTime) / (lastChange.bpm / 60) / 4) * 1000; // TODO: make less shit and take BPM into account PROPERLY
  }

  public static function getStep(time:Float)
  {
    var lastChange = getBPMFromSeconds(time);
    return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrochet;
  }

  public static function getStepRounded(time:Float)
  {
    var lastChange = getBPMFromSeconds(time);
    return lastChange.stepTime + Math.floor(time - lastChange.songTime) / lastChange.stepCrochet;
  }

  public static function getBeat(time:Float)
  {
    return getStep(time) / 4;
  }

  public static function getBeatRounded(time:Float):Int
  {
    return Math.floor(getStepRounded(time) / 4);
  }

  public static function mapBPMChanges(song:SwagSong)
  {
    bpmChangeMap = [];

    var curBPM:Float = song.bpm;
    var totalSteps:Int = 0;
    var totalPos:Float = 0;

    inline function pushChange(newBPM:Float)
    {
      var event:BPMChangeEvent =
        {
          stepTime: totalSteps,
          songTime: totalPos,
          bpm: newBPM,
          stepCrochet: calculateCrochet(newBPM) / 4
        };
      bpmChangeMap.push(event);
      curBPM = newBPM;
    }

    var firstSec = song.notes[0];
    if (firstSec == null || !firstSec.changeBPM) pushChange(song.bpm);

    for (section in song.notes)
    {
      if (section.changeBPM) pushChange(section.bpm);

      var deltaSteps:Int = Math.round(sectionBeats(section) * 4);
      totalSteps += deltaSteps;
      totalPos += (15000 * deltaSteps) / curBPM; // ((60 / curBPM) * 1000 / 4) * deltaSteps;
    }
    /*for (i in 0...song.notes.length)
      {
        if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
        {
          curBPM = song.notes[i].bpm;
          var event:BPMChangeEvent =
            {
              stepTime: totalSteps,
              songTime: totalPos,
              bpm: curBPM,
              stepCrochet: calculateCrochet(curBPM) / 4
            };
          bpmChangeMap.push(event);
        }

        var deltaSteps:Int = Math.round(getSectionBeats(song, i) * 4);
        totalSteps += deltaSteps;
        totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
    }*/
  }

  static function sectionBeats(section:SwagSection):Float
  {
    var beats:Null<Float> = (section == null) ? null : section.sectionBeats;
    return (beats == null) ? 4 : section.sectionBeats;
  }

  static function getSectionBeats(song:SwagSong, section:Int)
  {
    sectionBeats(song.notes[section]);
  }

  inline public static function calculateCrochet(bpm:Float)
  {
    return 60000 / bpm; // (60 / bpm) * 1000;
  }

  public static function set_bpm(newBPM:Float):Float
  {
    crochet = calculateCrochet(newBPM);
    stepCrochet = crochet / 4;
    return bpm = newBPM;
  }
}
