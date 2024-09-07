package backend.stage.base;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import objects.note.Note;
import objects.Character;

/**
 * Made for objects added on to Stage.
 */
class BaseStage extends FlxBasic
{
  private var game(get, never):Dynamic;

  public var onPlayState(get, never):Bool;

  // some variables for convenience
  public var paused(get, never):Bool;
  public var songName(get, never):String;
  public var isStoryMode(get, never):Bool;
  public var seenCutscene(get, never):Bool;
  public var inCutscene(get, set):Bool;
  public var canPause(get, set):Bool;
  public var members(get, never):Array<FlxBasic>;

  public var boyfriend(get, never):Character;
  public var dad(get, never):Character;
  public var gf(get, never):Character;
  public var mom(get, never):Character;

  public var unspawnNotes(get, never):Array<Note>;

  public var camGame(get, never):FlxCamera;
  public var camHUD(get, never):FlxCamera;
  public var camOther(get, never):FlxCamera;

  public var defaultCamZoom(get, set):Float;
  public var camFollow(get, never):FlxObject;

  public var stage:Stage = null;

  // main callbacks
  public function buildStage(baseStage:Stage) {}

  public function createPost() {}

  // public function update(elapsed:Float) {}
  public function countdownTick(count:Countdown, num:Int) {}

  public function startSong() {}

  // FNF steps, beats and sections
  public var curBeat:Int = 0;
  public var curDecBeat:Float = 0;
  public var curStep:Int = 0;
  public var curDecStep:Float = 0;
  public var curSection:Int = 0;

  public function beatHit() {}

  public function stepHit() {}

  public function sectionHit() {}

  // Substate close/open, for pausing Tweens/Timers
  public function closeSubState() {}

  public function openSubState(SubState:FlxSubState) {}

  // Events
  public function onEvent(eventName:String, eventParams:Array<String>, flValues:Array<Null<Float>>, time:Float) {}

  public function onEventPushed(event:EventNote) {}

  public function onEventPushedUnique(event:EventNote) {}

  // Note Hit/Miss
  public function goodNoteHit(note:Note) {}

  public function opponentNoteHit(note:Note) {}

  public function noteMiss(note:Note) {}

  public function noteMissPress(direction:Int) {}

  // Things to replace FlxGroup stuff and inject sprites directly into the state
  function add(object:FlxBasic)
    return FlxG.state.add(object);

  function remove(object:FlxBasic, splice:Bool = false)
    return FlxG.state.remove(object, splice);

  function insert(position:Int, object:FlxBasic)
    return FlxG.state.insert(position, object);

  public function addBehindGF(obj:FlxBasic)
    return insert(members.indexOf(game.gf), obj);

  public function addBehindBF(obj:FlxBasic)
    return insert(members.indexOf(game.boyfriend), obj);

  public function addBehindDad(obj:FlxBasic)
    return insert(members.indexOf(game.dad), obj);

  public function addBehindMom(obj:FlxBasic)
    return insert(members.indexOf(game.dad), obj);

  public function addFromPosGF(obj:FlxBasic, pos:Int = 0)
    return insert(members.indexOf(game.gf) + pos, obj);

  public function addFromPosBF(obj:FlxBasic, pos:Int = 0)
    return insert(members.indexOf(game.boyfriend) + pos, obj);

  public function addFromPosDad(obj:FlxBasic, pos:Int = 0)
    return insert(members.indexOf(game.dad) + pos, obj);

  public function addFromPosMom(obj:FlxBasic, pos:Int = 0)
    return insert(members.indexOf(game.mom) + pos, obj);

  public function setDefaultGF(name:String) // Fix for the Chart Editor on Base Game stages
  {
    var gfVersion:String = PlayState.SONG.characters.girlfriend;
    if (gfVersion == null || gfVersion.length < 1)
    {
      gfVersion = name;
      PlayState.SONG.characters.girlfriend = gfVersion;
    }
  }

  public function getStageObject(name:String) // Objects can only be accessed *after* create(), use createPost() if you want to mess with them on init
    return game.variables.get(name);

  // start/end callback functions
  public function setStartCallback(myfn:Void->Void)
  {
    if (!onPlayState) return;
    PlayState.instance.startCallback = myfn;
  }

  public function setEndCallback(myfn:Void->Void)
  {
    if (!onPlayState) return;
    PlayState.instance.endCallback = myfn;
  }

  // overrides
  function startCountdown()
    if (onPlayState) return PlayState.instance.startCountdown();
    else
      return false;

  function endSong()
    if (onPlayState) return PlayState.instance.endSong();
    else
      return false;

  inline private function get_paused()
    return game.paused;

  inline private function get_songName()
    return Song.formattedSongName;

  inline private function get_isStoryMode()
    return PlayState.isStoryMode;

  inline private function get_seenCutscene()
    return PlayState.seenCutscene;

  inline private function get_inCutscene()
    return game.inCutscene;

  inline private function set_inCutscene(value:Bool)
  {
    game.inCutscene = value;
    return value;
  }

  inline private function get_canPause()
    return game.canPause;

  inline private function set_canPause(value:Bool)
  {
    game.canPause = value;
    return value;
  }

  inline private function get_members()
    return game.members;

  inline private function get_game()
    return cast FlxG.state;

  inline private function get_onPlayState()
    return (Std.isOfType(FlxG.state, states.PlayState));

  inline private function get_boyfriend():Character
    return game.boyfriend;

  inline private function get_dad():Character
    return game.dad;

  inline private function get_gf():Character
    return game.gf;

  inline private function get_mom():Character
    return game.mom;

  inline private function get_unspawnNotes():Array<Note>
  {
    return cast game.unspawnNotes;
  }

  inline private function get_camGame():FlxCamera
    return game.camGame;

  inline private function get_camHUD():FlxCamera
    return game.camHUD;

  inline private function get_camOther():FlxCamera
    return game.camOther;

  inline private function get_defaultCamZoom():Float
    return game.defaultCamZoom;

  inline private function set_defaultCamZoom(value:Float):Float
  {
    game.defaultCamZoom = value;
    return game.defaultCamZoom;
  }

  inline private function get_camFollow():FlxObject
    return game.camFollow;
}
