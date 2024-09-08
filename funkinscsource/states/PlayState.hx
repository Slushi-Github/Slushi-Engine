package states;

// If you want to add your stage to the game, copy states/stages/Template.hx,
// and put your stage code there, then, on PlayState, search for
// "switch (curStage)", and add your stage to that list.
// If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
// "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
// "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
// "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
// "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Rating;
import backend.Countdown;
import backend.HelperFunctions;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.ui.FlxBar;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.addons.effects.FlxTrail;
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.display.FlxBackdrop;
import lime.app.Application;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import tjson.TJSON as Json;
import cutscenes.CutsceneHandler;
import cutscenes.DialogueBoxPsych;
import states.StoryMenuState;
import states.MusicBeatState.subStates;
import states.freeplay.FreeplayState;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;
import substates.PauseSubState;
import substates.GameOverSubstate;
import substates.ResultsScreenKadeSubstate;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import objects.VideoSprite;
import objects.*;
import objects.note.Note.EventNote;
#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end
#if HSCRIPT_ALLOWED
import scripting.*;
#end
#if (HSCRIPT_ALLOWED && HScriptImproved)
import codenameengine.scripting.Script as HScriptCode;
#end
import shaders.FNFShader;
import utils.SoundUtil;
#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
#end

class PlayState extends MusicBeatState
{
  public static var STRUM_X = 49;
  public static var STRUM_X_MIDDLESCROLL = -272;

  public var GJUser:String = ClientPrefs.data.gjUser;

  public var bfStrumStyle:String = "";
  public var dadStrumStyle:String = "";

  public static var inResults:Bool = false;

  public static var tweenManager:FlxTweenManager = null;
  public static var timerManager:FlxTimerManager = null;

  public static var ratingStuff:Array<Dynamic> = [
    ['You Suck!', 0.2], // From 0% to 19%
    ['Shit', 0.4], // From 20% to 39%
    ['Bad', 0.5], // From 40% to 49%
    ['Bruh', 0.6], // From 50% to 59%
    ['Meh', 0.69], // From 60% to 68%
    ['Nice', 0.7], // 69%
    ['Good', 0.8], // From 70% to 79%
    ['Great', 0.9], // From 80% to 89%
    ['Sick!', 1], // From 90% to 99%
    ['Perfect!!', 1] // The value on this one isn't used actually, since Perfect is always "1"
  ];

  // event variables
  public var isCameraOnForcedPos:Bool = false;

  public var BF_X:Float = 770;
  public var BF_Y:Float = 450;
  public var DAD_X:Float = 100;
  public var DAD_Y:Float = 100;
  public var GF_X:Float = 400;
  public var GF_Y:Float = 130;
  public var MOM_X:Float = 100;
  public var MOM_Y:Float = 100;

  public var songSpeedTween:FlxTween;
  public var songSpeed(default, set):Float = 1;
  public var songSpeedType:String = "multiplicative";
  public var noteKillOffset:Float = 350;

  public var playbackRate(default, set):Float = 1;

  public static var curStage:String = '';
  public static var stageUI:String = "normal";
  public static var isPixelStage(get, never):Bool;

  @:noCompletion
  static function get_isPixelStage():Bool
    return stageUI == "pixel" || stageUI.endsWith("-pixel");

  public static var SONG:SwagSong = null;
  public static var isStoryMode:Bool = false;
  public static var storyWeek:Int = 0;
  public static var storyPlaylist:Array<String> = [];
  public static var storyDifficulty:Int = 1;

  public var inst:FlxSound;
  public var vocals:FlxSound;
  public var opponentVocals:FlxSound;
  public var splitVocals:Bool = false;

  public var dad:Character = null;
  public var gf:Character = null;
  public var mom:Character = null;
  public var boyfriend:Character = null;

  public var preloadChar:Character = null;

  public var notes:FlxTypedGroup<Note>;
  public var unspawnNotes:Array<Note> = [];
  public var eventNotes:Array<EventNote> = [];

  public var camFollow:FlxObject;
  public var prevCamFollow:FlxObject;

  #if SCEModchartingTools
  public var arrowPaths:FlxTypedGroup<ArrowPathSegment> = new FlxTypedGroup<ArrowPathSegment>();
  #end
  public var arrowLanes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
  public var strumLineNotes:Strumline = new Strumline(8);
  public var opponentStrums:Strumline = new Strumline(4);
  public var playerStrums:Strumline = new Strumline(4);
  public var grpNoteSplashes:FlxTypedGroup<NoteSplash> = new FlxTypedGroup<NoteSplash>();
  public var grpNoteSplashesCPU:FlxTypedGroup<NoteSplash> = new FlxTypedGroup<NoteSplash>();

  public var continueBeatBop:Bool = true;
  public var camZooming:Bool = false;
  public var camZoomingMult:Int = 4;
  public var camZoomingBop:Float = 1;
  public var camZoomingDecay:Float = 1;
  public var maxCamZoom:Float = 1.35;
  public var curSong:String = "";

  public var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

  public var scoreTxtSprite:FlxSprite;

  public var judgementCounter:FlxText;

  public var healthSet:Bool = false;
  public var health:Float = 1;
  public var maxHealth:Float = 2;
  public var combo:Int = 0;

  public var healthBarOverlay:AttachedSprite;
  public var healthBarHitBG:AttachedSprite;
  public var healthBarBG:AttachedSprite;
  public var timeBarBG:AttachedSprite;

  public var healthBar:FlxBar;
  public var healthBarHit:FlxBar;
  public var healthBarNew:Bar;
  public var healthBarHitNew:BarHit;
  public var timeBar:FlxBar;
  public var timeBarNew:Bar;

  public var songPercent:Float = 0;

  public var generatedMusic:Bool = false;
  public var endingSong:Bool = false;
  public var startingSong:Bool = false;
  public var updateTime:Bool = true;

  public static var changedDifficulty:Bool = false;
  public static var chartingMode:Bool = false;
  public static var modchartMode:Bool = false;

  // Gameplay settings
  public var healthGain:Float = 1;
  public var healthLoss:Float = 1;
  public var showCaseMode:Bool = false;
  public var guitarHeroSustains:Bool = false;
  public var instakillOnMiss:Bool = false;
  public var cpuControlled:Bool = false;
  public var practiceMode:Bool = false;
  public var opponentMode:Bool = false;
  public var holdsActive:Bool = true;
  public var notITGMod:Bool = true;
  public var OMANDNOTMS:Bool = false;
  public var OMANDNOTMSANDNOTITG:Bool = false;

  public var pressMissDamage:Float = 0.05;

  public var botplaySine:Float = 0;
  public var botplayTxt:FlxText;

  public var iconP1:HealthIcon;
  public var iconP2:HealthIcon;

  public var camGame:FlxCamera;
  public var camVideo:FlxCamera;
  public var camHUD2:FlxCamera;
  public var camHUD:FlxCamera;
  public var camOther:FlxCamera;
  public var camNoteStuff:FlxCamera;
  public var camStuff:FlxCamera;
  public var mainCam:FlxCamera;
  public var camPause:FlxCamera;

  // Slushi Engine cameras
  public var camSLEHUD:FlxCamera;
	public var camFor3D:FlxCamera;
	public var camFor3D2:FlxCamera;
	public var camFor3D3:FlxCamera;
	public var camFor3D4:FlxCamera;
	public var camFor3D5:FlxCamera;
	public var camWaterMark:FlxCamera;

  public var cameraSpeed:Float = 1;

  public var songScore:Int = 0;
  public var songHits:Int = 0;
  public var songMisses:Int = 0;
  public var scoreTxt:FlxText;
  public var timeTxt:FlxText;
  public var scoreTxtTween:FlxTween;

  // Rating Things
  public static var averageShits:Int = 0;
  public static var averageBads:Int = 0;
  public static var averageGoods:Int = 0;
  public static var averageSicks:Int = 0;
  public static var averageSwags:Int = 0;

  public var shitHits:Int = 0;
  public var badHits:Int = 0;
  public var goodHits:Int = 0;
  public var sickHits:Int = 0;
  public var swagHits:Int = 0;

  public static var averageWeekAccuracy:Float = 0;
  public static var averageWeekScore:Int = 0;
  public static var averageWeekMisses:Int = 0;
  public static var averageWeekShits:Int = 0;
  public static var averageWeekBads:Int = 0;
  public static var averageWeekGoods:Int = 0;
  public static var averageWeekSicks:Int = 0;
  public static var averageWeekSwags:Int = 0;

  public var weekAccuracy:Float = 0;
  public var weekScore:Int = 0;
  public var weekMisses:Int = 0;
  public var weekShits:Int = 0;
  public var weekBads:Int = 0;
  public var weekGoods:Int = 0;
  public var weekSicks:Int = 0;
  public var weekSwags:Int = 0;

  public static var seenCutscene:Bool = false;
  public static var deathCounter:Int = 0;

  public var defaultCamZoom:Float = 1.05;

  // how big to stretch the pixel art assets
  public static var daPixelZoom:Float = 6;

  public var inCutscene:Bool = false;
  public var inCinematic:Bool = false;

  public var arrowsGenerated:Bool = false;

  public var arrowsAppeared:Bool = false;

  public var skipCountdown:Bool = false;
  public var songLength:Float = 0;

  #if DISCORD_ALLOWED
  // Discord RPC variables
  public var storyDifficultyText:String = "";
  public var detailsText:String = "";
  public var detailsPausedText:String = "";
  #end

  // From kade but from bolo's kade (thanks!)
  #if (VIDEOS_ALLOWED && hxvlc)
  var reserveVids:Array<VideoSprite> = [];

  public var daVideoGroup:FlxTypedGroup<VideoSprite> = null;
  #end

  // Achievement shit
  var keysPressed:Array<Int> = [];
  var boyfriendIdleTime:Float = 0.0;
  var boyfriendIdled:Bool = false;

  // Lua shit
  public static var instance:PlayState;

  #if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

  #if HSCRIPT_ALLOWED
  public var hscriptArray:Array<psychlua.HScript> = [];
  public var scHSArray:Array<scripting.SCScript> = [];
  #end

  #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
  private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
  #end

  // Less laggy controls
  private var keysArray:Array<String>;

  // Song
  public var songName:String;

  // Callbacks for stages
  public var startCallback:Void->Void = null;
  public var endCallback:Void->Void = null;

  public var notAllowedOpponentMode:Bool = false;

  public static var timeToStart:Float = 0;

  // glow's kade stuff
  public var kadeEngineWatermark:FlxText;

  public var whichHud:String = ClientPrefs.data.hudStyle;

  public var usesHUD:Bool = false;

  // Slushi Engine song option
  public var useSLEHUD:Bool = false;

  public var forcedToIdle:Bool = false; // change if bf and dad are forced to idle to every (idleBeat) beats of the song
  public var allowedToHeadbang:Bool = true; // Will decide if gf is allowed to headbang depending on the song
  public var allowedToCheer:Bool = false; // Will decide if gf is allowed to cheer depending on the song

  public var allowedToHitBounce:Bool = false;

  public var allowTxtColorChanges:Bool = false;

  public var has3rdIntroAsset:Bool = false;

  public static var startCharScripts:Array<String> = [];

  public static var containsAPixelTextureForNotes:Bool = false;

  public var healthLerp:Float = 1;

  public var healthLerps(default, set):Bool = false;

  private function set_healthLerps(value:Bool):Bool
  {
    if (healthBar != null)
    {
      if (SONG != null && SONG.options.oldBarSystem)
      {
        healthBar.parentVariable = value ? "healthLerp" : "health";
      }
    }
    else if (healthBarNew != null)
    {
      if (SONG != null && !SONG.options.oldBarSystem)
      {
        healthBarNew.valueFunction = value ? (function() return healthLerp) : (function() return health);
      }
    }

    if (healthBarHit != null)
    {
      if (SONG != null && SONG.options.oldBarSystem)
      {
        healthBarHit.parentVariable = value ? "healthLerp" : "health";
      }
    }
    else if (healthBarHitNew != null)
    {
      if (SONG != null && !SONG.options.oldBarSystem)
      {
        healthBarHitNew.valueFunction = value ? (function() return healthLerp) : (function() return health);
      }
    }
    return healthLerps = value;
  }

  public function createTween(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):FlxTween
  {
    var tween:FlxTween = tweenManager.tween(Object, Values, Duration, Options);
    tween.manager = tweenManager;
    return tween;
  }

  public function createTweenNum(FromValue:Float, ToValue:Float, Duration:Float = 1, ?Options:TweenOptions, ?TweenFunction:Float->Void):FlxTween
  {
    var tween:FlxTween = tweenManager.num(FromValue, ToValue, Duration, Options, TweenFunction);
    tween.manager = tweenManager;
    return tween;
  }

  public function createTimer(Time:Float = 1, ?OnComplete:FlxTimer->Void, Loops:Int = 1):FlxTimer
  {
    var timer:FlxTimer = new FlxTimer();
    timer.manager = timerManager;
    return timer.start(Time, OnComplete, Loops);
  }

  public function addObject(object:FlxBasic)
  {
    add(object);
  }

  public function insertObject(pos:Int, object:FlxBasic)
  {
    insert(pos, object);
  }

  public function removeObject(object:FlxBasic)
  {
    remove(object);
  }

  public function destroyObject(object:FlxBasic)
  {
    object.destroy();
  }

  private var triggeredAlready:Bool = false;

  // Edwhak muchas gracias!
  public static var forceMiddleScroll:Bool = false; // yeah
  public static var forceRightScroll:Bool = false; // so modcharts that NEED rightscroll will be forced (mainly for player vs enemy classic stuff like bf vs someone)
  public static var prefixMiddleScroll:Bool = false;
  public static var prefixRightScroll:Bool = false; // so if someone force the scroll in chart and clientPrefs are the other option it will be autoLoaded again
  public static var savePrefixScrollM:Bool = false;
  public static var savePrefixScrollR:Bool = false;

  public var playerNotes = 0;
  public var opponentNotes = 0;
  public var songNotesCount = 0;

  public static var highestCombo:Int = 0;

  var col:FlxColor = 0xFFFFD700;
  var col2:FlxColor = 0xFFFFD700;

  var beat:Float = 0;
  var dataStuff:Float = 0;

  public var stage:Stage = null;

  #if (HSCRIPT_ALLOWED && HScriptImproved)
  public var codeNameScripts:codenameengine.scripting.ScriptPack;
  #end

  // for testing
  #if debug
  public var delayBar:FlxSprite;
  public var delayBarBg:FlxSprite;
  public var delayBarTxt:FlxText;
  #end

  public static var isPixelNotes:Bool = false;

  public var picoSpeakerAllowed:Bool = false;

  public var opponentHoldCovers:HoldCoverGroup;
  public var playerHoldCovers:HoldCoverGroup;

  override public function create()
  {
    Paths.clearStoredMemory();

    if (SONG == null)
    {
      Debug.displayAlert("PlayState Was Not Able To Load Any Songs!", "PlayState Error");
      MusicBeatState.switchState(new FreeplayState());
      return;
    }

    gfSpeed = 1;

    songName = Paths.formatToSongPath(SONG.songId);
    Debug.logInfo(songName);

    // Set up stage stuff before any scripts, else no functioning playstate.
    if (SONG.stage == null || SONG.stage.length < 1) SONG.stage = StageData.vanillaSongStage(Paths.formatToSongPath(Song.loadedSongName));
    curStage = SONG.stage;
    stage = new Stage(curStage);

    if (SONG.options.disableCaching)
    {
      try
      {
        #if MODS_ALLOWED
        if (FileSystem.exists(Paths.modFolders('data/songs/' + Paths.formatToSongPath(SONG.songId).toLowerCase() + '/preload.txt'))
          || FileSystem.exists(Paths.txt('songs/' + Paths.formatToSongPath(SONG.songId).toLowerCase() + '/preload')))
        #else
        if (Assets.exists(Paths.txt('songs/' + Paths.formatToSongPath(SONG.songId).toLowerCase() + "/preload")))
        #end
        {
          Debug.logInfo('Preloading Characters!');
          var characters:Array<String> = CoolUtil.coolTextFile(Paths.getPath('data/songs/' + Paths.formatToSongPath(SONG.songId)
            .toLowerCase() + '/preload.txt'));
          if (characters.length < 1) return;
          for (i in 0...characters.length)
          {
            var data:Array<String> = characters[i].split(' ');
            cacheCharacter(data[0]);

            var luaFile:String = 'data/characters/' + data[0];

            #if MODS_ALLOWED
            if (FileSystem.exists(Paths.getPath('data/characters/' + data[0] + '.lua')))
            #else
            if (Assets.exists(Paths.getPath(luaFile + '.lua')))
            #end
            startCharScripts.push(data[0]);
          }
        }
      }
      catch (e:Dynamic) {}
    }

    tweenManager = new FlxTweenManager();
    timerManager = new FlxTimerManager();

    startCallback = startCountdown;
    endCallback = endSong;

    if (alreadyEndedSong)
    {
      alreadyEndedSong = false;
      endSong();
    }

    alreadyEndedSong = false;
    paused = false;
    stoppedAllInstAndVocals = false;
    finishedSong = false;

    usesHUD = SONG.options.usesHUD;

    useSLEHUD = if (SONG.options.sleHUD != null) SONG.options.sleHUD else SONG.sleHUD;

    #if debug
    allowedEnter = (GJUser != null && (GJUser == 'glowsoony' || GJUser == 'Slushi_Game'));
    #else
    allowedEnter = true;
    #end

    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (codeNameScripts == null) (codeNameScripts = new codenameengine.scripting.ScriptPack("PlayState")).setParent(this);
    #end

    // for lua
    instance = this;
    PauseSubState.songName = null; // Reset to default
    playbackRate = ClientPrefs.getGameplaySetting('songspeed');

    swagHits = 0;
    sickHits = 0;
    badHits = 0;
    shitHits = 0;
    goodHits = 0;

    songMisses = 0;

    highestCombo = 0;
    inResults = false;

    keysArray = ['note_left', 'note_down', 'note_up', 'note_right'];

    if (FlxG.sound.music != null) FlxG.sound.music.stop();

    // Force A Scroll
    if (SONG.options.middleScroll && !ClientPrefs.data.middleScroll)
    {
      forceMiddleScroll = true;
      forceRightScroll = false;
      ClientPrefs.data.middleScroll = true;
    }
    else if (SONG.options.rightScroll && ClientPrefs.data.middleScroll)
    {
      forceMiddleScroll = false;
      forceRightScroll = true;
      ClientPrefs.data.middleScroll = false;
    }

    if (forceMiddleScroll && !ClientPrefs.data.middleScroll)
    {
      savePrefixScrollR = true;
    }
    else if (forceRightScroll && ClientPrefs.data.middleScroll)
    {
      savePrefixScrollM = true;
    }

    if (ClientPrefs.data.middleScroll)
    {
      prefixMiddleScroll = true;
      prefixRightScroll = false;
    }
    else if (!ClientPrefs.data.middleScroll)
    {
      prefixRightScroll = true;
      prefixMiddleScroll = false;
    }

    // Gameplay settings
    healthGain = ClientPrefs.getGameplaySetting('healthgain');
    healthLoss = ClientPrefs.getGameplaySetting('healthloss');
    instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
    opponentMode = (ClientPrefs.getGameplaySetting('opponent') && !SONG.options.blockOpponentMode);
    practiceMode = ClientPrefs.getGameplaySetting('practice');
    cpuControlled = ClientPrefs.getGameplaySetting('botplay');
    showCaseMode = ClientPrefs.getGameplaySetting('showcasemode');
    holdsActive = ClientPrefs.getGameplaySetting('sustainnotesactive');
    notITGMod = ClientPrefs.getGameplaySetting('modchart');
    guitarHeroSustains = ClientPrefs.data.newSustainBehavior;
    allowTxtColorChanges = ClientPrefs.data.coloredText;

    // Extra Stuff Needed FOR SCE
    OMANDNOTMS = (opponentMode && !ClientPrefs.data.middleScroll);
    OMANDNOTMSANDNOTITG = (opponentMode && SONG.options.notITG && ClientPrefs.data.middleScroll);
    CoolUtil.opponentModeActive = opponentMode;

    Note.notITGNotes = (notITGMod && SONG.options.notITG);
    StrumArrow.notITGStrums = (notITGMod && SONG.options.notITG);

    // var gameCam:FlxCamera = FlxG.camera;
    camGame = initPsychCamera();
    camVideo = new FlxCamera();
    camVideo.bgColor.alpha = 0;
    camHUD2 = new FlxCamera();
    camHUD2.bgColor.alpha = 0;
    camHUD = new FlxCamera();
    camHUD.bgColor.alpha = 0;
    camOther = new FlxCamera();
    camOther.bgColor.alpha = 0;
    camNoteStuff = new FlxCamera();
    camNoteStuff.bgColor.alpha = 0;
    camStuff = new FlxCamera();
    camStuff.bgColor.alpha = 0;
    mainCam = new FlxCamera();
    mainCam.bgColor.alpha = 0;
    camPause = new FlxCamera();
    camPause.bgColor.alpha = 0;

    camSLEHUD = new FlxCamera();
		camFor3D = new FlxCamera();
		camFor3D2 = new FlxCamera();
		camFor3D3 = new FlxCamera();
		camFor3D4 = new FlxCamera();
		camFor3D5 = new FlxCamera();
		camWaterMark = new FlxCamera();
		camSLEHUD.bgColor.alpha = 0;
		camFor3D.bgColor.alpha = 0;
		camFor3D2.bgColor.alpha = 0;
		camFor3D3.bgColor.alpha = 0;
		camFor3D4.bgColor.alpha = 0;
		camFor3D5.bgColor.alpha = 0;
		camWaterMark.bgColor.alpha = 0;

    // Game Camera (where stage and characters are)

    // Video Camera if you put funni videos or smth
    FlxG.cameras.add(camVideo, false);

    // for other stuff then the (Health Bar, scoreTxt, etc)
    FlxG.cameras.add(camHUD2, false);

    // HUD Camera (Health Bar, scoreTxt, etc)
    FlxG.cameras.add(camHUD, false);

    FlxG.cameras.add(camSLEHUD, false);
		FlxG.cameras.add(camFor3D, false);
		FlxG.cameras.add(camFor3D2, false);
		FlxG.cameras.add(camFor3D3, false);
		FlxG.cameras.add(camFor3D4, false);
		FlxG.cameras.add(camFor3D5, false);

    // for jumescares and shit
    FlxG.cameras.add(camOther, false);

    // All Note Stuff Above HUD
    FlxG.cameras.add(camNoteStuff, false);

    FlxG.cameras.add(camWaterMark, false);

    // Stuff camera (stuff that are on top of everything but lower then the main camera)
    FlxG.cameras.add(camStuff, false);

    // Main Camera
    FlxG.cameras.add(mainCam, false);

    // The final one should be more but for this one rn it's the pauseCam
    FlxG.cameras.add(camPause, false);

    camNoteStuff.zoom = !usesHUD ? camHUD.zoom : 1;

    persistentUpdate = true;
    persistentDraw = true;

    Conductor.mapBPMChanges(SONG);
    Conductor.bpm = SONG.bpm;

    #if DISCORD_ALLOWED
    // String that contains the mode defined here so it isn't necessary to call changePresence for each mode
    storyDifficultyText = Difficulty.getString();

    if (isStoryMode) detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
    else
      detailsText = "Freeplay";

    // String for when the game is paused
    detailsPausedText = "Paused - " + detailsText;
    #end

    var sleHUD:SlushiEngineHUD = new SlushiEngineHUD();
		add(sleHUD);

		var lyrics:LyricsUtils = new LyricsUtils();
		add(lyrics);

    GameOverSubstate.resetVariables();

    #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
    luaDebugGroup.cameras = [camOther];
    add(luaDebugGroup);
    #end

    if (SONG.characters.girlfriend == null || SONG.characters.girlfriend.length < 1) SONG.characters.girlfriend = 'gf'; // Fix for the Chart Editor

    gf = new Character(GF_X, GF_Y, SONG.characters.girlfriend, 'GF');
    var gfOffset = new backend.CharacterOffsets(SONG.characters.girlfriend, false, true);
    var daGFX:Float = gfOffset.daOffsetArray[0];
    var daGFY:Float = gfOffset.daOffsetArray[1];
    startCharacterPos(gf);
    gf.x += daGFX;
    gf.y += daGFY;
    gf.scrollFactor.set(0.95, 0.95);
    gf.useGFSpeed = true;

    dad = new Character(DAD_X, DAD_Y, SONG.characters.opponent, 'DAD');
    startCharacterPos(dad, true);
    dad.noteSkinStyleOfCharacter = SONG.options.opponentNoteStyle;
    dad.strumSkinStyleOfCharacter = SONG.options.opponentStrumStyle;
    if (dad.curCharacter.startsWith('gf')) dad.useGFSpeed = true;

    mom = new Character(MOM_X, MOM_X, SONG.characters.secondOpponent, 'DAD');
    startCharacterPos(mom, true);

    if (SONG.characters.secondOpponent == ''
      || SONG.characters.secondOpponent == ""
      || SONG.characters.secondOpponent == null
      || SONG.characters.secondOpponent.length < 1)
    {
      mom.alpha = 0.0001;
    }

    boyfriend = new Character(BF_X, BF_Y, SONG.characters.player, true, 'BF');
    startCharacterPos(boyfriend, false, true);
    boyfriend.noteSkinStyleOfCharacter = SONG.options.playerNoteStyle;
    boyfriend.strumSkinStyleOfCharacter = SONG.options.playerStrumStyle;

    Debug.logInfo('current stage, $curStage');

    stage.setupStageProperties(SONG.songId, true);
    curStage = stage.curStage;
    defaultCamZoom = stage.camZoom;
    cameraSpeed = stage.stageCameraSpeed;

    boyfriend.x += stage.bfXOffset;
    boyfriend.y += stage.bfYOffset;
    mom.x += stage.momXOffset;
    mom.y += stage.momYOffset;
    dad.x += stage.dadXOffset;
    dad.y += stage.dadYOffset;
    gf.x += stage.gfXOffset;
    gf.y += stage.gfYOffset;

    picoSpeakerAllowed = ((SONG.characters.girlfriend == 'pico-speaker' || gf.curCharacter == 'pico-speaker') && !stage.hideGirlfriend);
    if (stage.hideGirlfriend) gf.alpha = 0.0001;
    if (picoSpeakerAllowed)
    {
      gf.useGFSpeed = null;
      gf.idleToBeat = gf.isDancing = false;
    }

    #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    // "GLOBAL" SCRIPTS
    for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/global/'))
      for (file in FileSystem.readDirectory(folder))
      {
        #if LUA_ALLOWED
        if (file.toLowerCase().endsWith('.lua')) new FunkinLua(folder + file, 'PLAYSTATE');
        #end

        #if HSCRIPT_ALLOWED
        for (extn in CoolUtil.haxeExtensions)
          if (file.toLowerCase().endsWith('.$extn')) initHScript(folder + file);
        #end
      }

    for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/global/sc/'))
      for (file in FileSystem.readDirectory(folder))
        #if HSCRIPT_ALLOWED
        for (extn in CoolUtil.haxeExtensions)
          if (file.toLowerCase().endsWith('.$extn')) initSCHS(folder + file);
        #end

    #if (HSCRIPT_ALLOWED && HScriptImproved)
    for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/global/advanced/'))
      for (file in FileSystem.readDirectory(folder))
        for (extn in CoolUtil.haxeExtensions)
          if (file.toLowerCase().endsWith('.$extn')) initHSIScript(folder + file);
    #end

    for (i in 0...startCharScripts.length)
    {
      startCharacterScripts(startCharScripts[i]);
      startCharScripts.remove(startCharScripts[i]);
    }

    startCharacterScripts(gf.curCharacter);
    startCharacterScripts(dad.curCharacter);
    startCharacterScripts(mom.curCharacter);
    startCharacterScripts(boyfriend.curCharacter);
    #end

    if (ClientPrefs.data.characters)
    {
      boyfriend.scrollFactor.set(stage.bfScrollFactor[0], stage.bfScrollFactor[1]);
      dad.scrollFactor.set(stage.dadScrollFactor[0], stage.dadScrollFactor[1]);
      gf.scrollFactor.set(stage.gfScrollFactor[0], stage.gfScrollFactor[1]);
    }

    if (boyfriend.deadChar != null) GameOverSubstate.characterName = boyfriend.deadChar;

    var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
    if (gf != null)
    {
      camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
      camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
    }

    if (dad.curCharacter.startsWith('gf') || dad.replacesGF)
    {
      dad.setPosition(GF_X, GF_Y);
      if (gf != null) gf.visible = false;
    }

    setCameraOffsets();

    switch (curStage)
    {
      case 'school' | 'schoolEvil':
        var _song = SONG.gameOverData;
        if (_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
        if (_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-pixel';
        if (_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
        if (_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'bf-pixel-dead';
    }

    if (ClientPrefs.data.background)
    {
      for (i in stage.toAdd)
        add(i);

      for (index => array in stage.layInFront)
      {
        switch (index)
        {
          case 0:
            if (ClientPrefs.data.characters) if (gf != null) add(gf);
            for (bg in array)
              add(bg);
          case 1:
            if (ClientPrefs.data.characters) add(dad);
            for (bg in array)
              add(bg);
          case 2:
            if (ClientPrefs.data.characters) if (mom != null) add(mom);
            for (bg in array)
              add(bg);
          case 3:
            if (ClientPrefs.data.characters) add(boyfriend);
            for (bg in array)
              add(bg);
          case 4:
            if (ClientPrefs.data.characters)
            {
              if (gf != null) add(gf);
              add(dad);
              if (mom != null) add(mom);
              add(boyfriend);
            }
            for (bg in array)
              add(bg);
        }
      }
    }
    else
    {
      if (ClientPrefs.data.characters)
      {
        if (gf != null)
        {
          gf.scrollFactor.set(0.95, 0.95);
          add(gf);
        }
        add(dad);
        if (mom != null) add(mom);
        add(boyfriend);
      }
    }

    // if (songName == 'roses')
    // {
    //   for (i in [dad, gf, mom, boyfriend])
    //   {
    //     if (i != null)
    //     {
    //       i.color = 0x8E8E8E;
    //       i.curColor = 0x8E8E8E;
    //     }
    //   }
    // }

    if (stage.curStage == 'schoolEvil')
    {
      if (!ClientPrefs.data.lowQuality)
      {
        if (ClientPrefs.data.characters)
        {
          var trail:FlxTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
          addBehindDad(trail);
        }
      }
    }

    // INITIALIZE UI GROUPS
    comboGroup = new FlxSpriteGroup();
    comboGroupOP = new FlxSpriteGroup();

    arrowLanes.cameras = #if SCEModchartingTools arrowPaths.cameras = #end [usesHUD ? camHUD : camNoteStuff];

    var enabledHolds:Bool = ((!SONG.options.disableHoldCovers && !SONG.options.notITG) && ClientPrefs.data.holdCoverPlay);
    opponentHoldCovers = new HoldCoverGroup(enabledHolds, false);
    opponentHoldCovers.isReady = (strumLineNotes != null && strumLineNotes.members.length > 0 && !startingSong && !inCutscene && !inCinematic && generatedMusic);
    playerHoldCovers = new HoldCoverGroup(enabledHolds, true);
    playerHoldCovers.isReady = (strumLineNotes != null && strumLineNotes.members.length > 0 && !startingSong && !inCutscene && !inCinematic && generatedMusic);

    if (isStoryMode)
    {
      switch (storyWeek)
      {
        case 5:
          if (songName == 'winter-horrorland') inCinematic = true;
        case 7:
          inCinematic = true;
      }
    }

    Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;

    var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
    timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, ClientPrefs.data.downScroll ? FlxG.height - 44 : 20, 400, "", 32);
    timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    timeTxt.scrollFactor.set();
    timeTxt.alpha = 0;
    timeTxt.borderSize = 2;
    if (!showCaseMode) timeTxt.visible = updateTime = showTime;
    else
      timeTxt.visible = false;
    if (ClientPrefs.data.timeBarType == 'Song Name') timeTxt.text = songName;

    timeBarBG = new AttachedSprite('timeBarOld');
    timeBarBG.x = timeTxt.x;
    timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
    timeBarBG.scrollFactor.set();
    timeBarBG.alpha = 0;
    if (!showCaseMode) timeBarBG.visible = showTime;
    else
      timeBarBG.visible = false;
    timeBarBG.color = FlxColor.BLACK;
    timeBarBG.xAdd = -4;
    timeBarBG.yAdd = -4;

    timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercent', 0,
      1);
    timeBar.scrollFactor.set();
    if (showTime)
    {
      if (ClientPrefs.data.colorBarType == 'No Colors') timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
      else if (ClientPrefs.data.colorBarType == 'Main Colors') timeBar.createGradientBar([FlxColor.BLACK], [
        FlxColor.fromString(boyfriend.iconColorFormatted),
        FlxColor.fromString(dad.iconColorFormatted)
      ]);
      else if (ClientPrefs.data.colorBarType == 'Reversed Colors') timeBar.createGradientBar([FlxColor.BLACK], [
        FlxColor.fromString(dad.iconColorFormatted),
        FlxColor.fromString(boyfriend.iconColorFormatted)
      ]);
    }
    timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
    timeBar.alpha = 0;
    if (!showCaseMode) timeBar.visible = showTime;
    else
      timeBar.visible = false;
    timeBarBG.sprTracker = timeBar;

    timeBarNew = new Bar(0, timeTxt.y + (timeTxt.height / 4), 'timeBar', function() return songPercent, 0, 1, "");
    timeBarNew.scrollFactor.set();
    timeBarNew.screenCenter(X);
    timeBarNew.alpha = 0;
    if (!showCaseMode) timeBarNew.visible = showTime;
    else
      timeBarNew.visible = false;

    if (SONG.options.oldBarSystem)
    {
      add(timeBarBG);
      add(timeBar);
    }
    else
      add(timeBarNew);
    add(timeTxt);

    #if debug
    delayBarBg = new FlxSprite().makeGraphic(300, 30, FlxColor.BLACK);
    delayBarBg.screenCenter();
    delayBarBg.camera = mainCam;

    delayBar = new FlxSprite(640).makeGraphic(1, 22, FlxColor.WHITE);
    delayBar.scale.x = 0;
    delayBar.updateHitbox();
    delayBar.screenCenter(Y);
    delayBar.camera = mainCam;

    delayBarTxt = new FlxText(0, 312, 100, '0 ms', 32);
    delayBarTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    delayBarTxt.scrollFactor.set();
    delayBarTxt.borderSize = 2;
    delayBarTxt.screenCenter(X);
    delayBarTxt.camera = mainCam;

    add(delayBarBg);
    add(delayBar);
    add(delayBarTxt);
    #end

    add(comboGroup);
    add(comboGroupOP);
    add(arrowLanes);
    #if SCEModchartingTools
    add(arrowPaths);
    #end
    add(strumLineNotes);

    if (ClientPrefs.data.timeBarType == 'Song Name')
    {
      timeTxt.size = 24;
      timeTxt.y += 3;
    }

    // like old psych stuff
    if (SONG.notes[0] != null) cameraTargeted = SONG.notes[0].mustHitSection != true ? 'dad' : 'bf';
    camZooming = true;

    healthBarBG = new AttachedSprite('healthBarOld');
    healthBarBG.y = ClientPrefs.data.downScroll ? FlxG.height * 0.11 : FlxG.height * 0.89;
    healthBarBG.screenCenter(X);
    healthBarBG.scrollFactor.set();
    healthBarBG.visible = !ClientPrefs.data.hideHud;
    healthBarBG.xAdd = -4;
    healthBarBG.yAdd = -4;

    healthBarHitBG = new AttachedSprite('healthBarHit');
    healthBarHitBG.y = ClientPrefs.data.downScroll ? 0 : FlxG.height * 0.9;
    healthBarHitBG.screenCenter(X);
    healthBarHitBG.visible = !ClientPrefs.data.hideHud;
    healthBarHitBG.alpha = ClientPrefs.data.healthBarAlpha;
    healthBarHitBG.flipY = !ClientPrefs.data.downScroll;

    // healthBar
    healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, opponentMode ? LEFT_TO_RIGHT : RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8),
      Std.int(healthBarBG.height - 8), this, 'health', 0, maxHealth);
    healthBar.scrollFactor.set();

    healthBar.visible = !ClientPrefs.data.hideHud;
    healthBar.alpha = ClientPrefs.data.healthBarAlpha;
    healthBarBG.sprTracker = healthBar;

    healthBarOverlay = new AttachedSprite('healthBarOverlay');
    healthBarOverlay.y = healthBarBG.y;
    healthBarOverlay.screenCenter(X);
    healthBarOverlay.scrollFactor.set();
    healthBarOverlay.visible = !ClientPrefs.data.hideHud;
    healthBarOverlay.blend = MULTIPLY;
    healthBarOverlay.color = FlxColor.BLACK;
    healthBarOverlay.xAdd = -4;
    healthBarOverlay.yAdd = -4;

    // healthBarHit
    healthBarHit = new FlxBar(350, healthBarHitBG.y + 15, opponentMode ? LEFT_TO_RIGHT : RIGHT_TO_LEFT, Std.int(healthBarHitBG.width - 120),
      Std.int(healthBarHitBG.height - 30), this, 'health', 0, maxHealth);
    healthBarHit.visible = !ClientPrefs.data.hideHud;
    healthBarHit.alpha = ClientPrefs.data.healthBarAlpha;

    healthBarNew = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return health, 0, maxHealth,
      "healthBarOverlay");
    healthBarNew.screenCenter(X);
    healthBarNew.leftToRight = opponentMode;
    healthBarNew.scrollFactor.set();
    healthBarNew.visible = !ClientPrefs.data.hideHud;
    healthBarNew.alpha = ClientPrefs.data.healthBarAlpha;

    healthBarHitNew = new BarHit(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.87 : 0.09), 'healthBarHit', function() return health, 0, maxHealth);
    healthBarHitNew.screenCenter(X);
    healthBarHitNew.leftToRight = opponentMode;
    healthBarHitNew.scrollFactor.set();
    healthBarHitNew.visible = !ClientPrefs.data.hideHud;
    healthBarHitNew.alpha = ClientPrefs.data.healthBarAlpha;

    RatingWindow.createRatings();

    // Add Kade Engine watermark
    kadeEngineWatermark = new FlxText(FlxG.width
      - 1276, !ClientPrefs.data.downScroll ? FlxG.height - 35 : FlxG.height - 720, 0,
      songName
      + (FlxMath.roundDecimal(playbackRate, 3) != 1.00 ? " (" + FlxMath.roundDecimal(playbackRate, 3) + "x)" : "")
      + ' - '
      + Difficulty.getString(),
      15);
    kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    kadeEngineWatermark.scrollFactor.set();
    kadeEngineWatermark.visible = !ClientPrefs.data.hideHud;

    judgementCounter = new FlxText(FlxG.width - 1260, 0, FlxG.width, "", 20);
    judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    judgementCounter.borderSize = 2;
    judgementCounter.borderQuality = 2;
    judgementCounter.scrollFactor.set();
    judgementCounter.screenCenter(Y);
    judgementCounter.visible = !ClientPrefs.data.hideHud;
    if (ClientPrefs.data.judgementCounter) add(judgementCounter);

    scoreTxtSprite = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
    scoreTxt = new FlxText(whichHud != 'CLASSIC' ? 0 : healthBar.x - healthBar.width - 190,
      (whichHud == "HITMANS" ? (ClientPrefs.data.downScroll ? healthBar.y + 60 : healthBar.y + 50) : whichHud != 'CLASSIC' ? healthBar.y + 40 : healthBar.y
        + 30),
      FlxG.width, "", 20);
    scoreTxt.setFormat(Paths.font("vcr.ttf"), whichHud != 'CLASSIC' ? 20 : 19, FlxColor.WHITE, whichHud != 'CLASSIC' ? CENTER : RIGHT,
      FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    scoreTxt.scrollFactor.set();
    scoreTxt.borderSize = whichHud == 'GLOW_KADE' ? 1.5 : whichHud != 'CLASSIC' ? 1.05 : 1.25;
    if (whichHud != 'CLASSIC') scoreTxt.y + 3;
    scoreTxt.visible = !ClientPrefs.data.hideHud;
    scoreTxtSprite.alpha = 0.5;
    scoreTxtSprite.x = scoreTxt.x;
    scoreTxtSprite.y = scoreTxt.y + 2.5;

    updateScore(false);

    if (whichHud == 'GLOW_KADE') add(kadeEngineWatermark);

    botplayTxt = new FlxText(400, ClientPrefs.data.downScroll ? healthBar.y + 70 : healthBar.y - 90, FlxG.width - 800,
      Language.getPhrase("Botplay").toUpperCase(), 32);
    botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    botplayTxt.scrollFactor.set();
    botplayTxt.borderSize = 1.25;
    botplayTxt.visible = (cpuControlled && !showCaseMode);
    add(botplayTxt);

    iconP1 = new HealthIcon(boyfriend.healthIcon, true);
    iconP1.y = healthBar.y - 75;
    iconP1.visible = !ClientPrefs.data.hideHud;
    iconP1.alpha = ClientPrefs.data.healthBarAlpha;

    iconP2 = new HealthIcon(dad.healthIcon, false);
    iconP2.y = healthBar.y - 75;
    iconP2.visible = !ClientPrefs.data.hideHud;
    iconP2.alpha = ClientPrefs.data.healthBarAlpha;

    reloadColors();

    if (whichHud == 'HITMANS')
    {
      if (SONG.options.oldBarSystem)
      {
        add(healthBarHit);
        add(healthBarHitBG);
      }
      else
      {
        add(healthBarHitNew);
      }
    }
    else
    {
      if (SONG.options.oldBarSystem)
      {
        add(healthBarBG);
        add(healthBar);
        if (whichHud == 'GLOW_KADE') add(healthBarOverlay);
      }
      else
      {
        add(healthBarNew);
      }
    }
    add(iconP1);
    add(iconP2);

    if (whichHud != 'CLASSIC') add(scoreTxtSprite);
    add(scoreTxt);

    var splash:NoteSplash = new NoteSplash(false);
    grpNoteSplashes.add(splash);
    splash.alpha = 0.000001; // cant make it invisible or it won't allow precaching

    var splashCPU:NoteSplash = new NoteSplash(true);
    grpNoteSplashesCPU.add(splashCPU);
    splashCPU.alpha = 0.000001; // cant make it invisible or it won't allow precaching

    playerStrums.visible = false;
    opponentStrums.visible = false;

    generateSong();

    #if (VIDEOS_ALLOWED && hxvlc)
    daVideoGroup = new FlxTypedGroup<VideoSprite>();
    add(daVideoGroup);
    #end

    #if SCEModchartingTools
    if (SONG.options.notITG && notITGMod)
    {
      playfieldRenderer = new modcharting.PlayfieldRenderer(this, strumLineNotes, notes, arrowPaths);
      if(useSLEHUD)
        playfieldRenderer.camera = camNoteStuff;
      else
        playfieldRenderer.cameras = [usesHUD ? camHUD : camNoteStuff];
      add(playfieldRenderer);
    }
    #end

    add(opponentHoldCovers);
    add(playerHoldCovers);

    add(grpNoteSplashes);
    add(grpNoteSplashesCPU);

    camFollow = new FlxObject();
    camFollow.setPosition(camPos.x, camPos.y);
    camPos.put();

    if (prevCamFollow != null)
    {
      camFollow = prevCamFollow;
      prevCamFollow = null;
    }
    add(camFollow);

    FlxG.camera.follow(camFollow, LOCKON, 0);
    FlxG.camera.zoom = defaultCamZoom;
    FlxG.camera.snapToTarget();

    // FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

    FlxG.fixedTimestep = false;

    if (ClientPrefs.data.breakTimer)
    {
      var noteTimer:backend.NoteTimer = new backend.NoteTimer(this);
      noteTimer.camera = useSLEHUD ? camSLEHUD : camStuff;
      add(noteTimer);
    }

    SlushiEngineHUD.setOthersParamOfTheHUD();

    if (useSLEHUD)
      playerHoldCovers.cameras = opponentHoldCovers.cameras = strumLineNotes.cameras = grpNoteSplashes.cameras = grpNoteSplashesCPU.cameras = notes.cameras = [camNoteStuff];
    else
      playerHoldCovers.cameras = opponentHoldCovers.cameras = strumLineNotes.cameras = grpNoteSplashes.cameras = grpNoteSplashesCPU.cameras = notes.cameras = [usesHUD ? camHUD : camNoteStuff];
    for (i in [
      timeBar, timeBarNew, timeTxt, healthBar, healthBarNew, healthBarHit, healthBarHitNew, kadeEngineWatermark, judgementCounter, scoreTxtSprite, scoreTxt,
      botplayTxt, iconP1, iconP2, timeBarBG, healthBarBG, healthBarHitBG, healthBarOverlay
    ])
      i.camera = useSLEHUD ? camSLEHUD : camHUD;
    comboGroupOP.cameras = comboGroup.cameras = [ClientPrefs.data.gameCombo ? camGame : camHUD];

    startingSong = true;

    switch (songName)
    {
      default:
        var sleSongConfig = if(WeekData.getCurrentWeek().sleSongConfig != null) WeekData.getCurrentWeek().sleSongConfig else null;
        if (sleSongConfig != null && (sleSongConfig[1] != null || sleSongConfig[1] != ""))
          songInfo = Main.appName + ': ' + sleSongConfig[1] + ' - Song Playing: ${songName.toUpperCase()} - ${Difficulty.getString()}';
        else
          songInfo = Main.appName + ' - Song Playing: ${songName.toUpperCase()} - ${Difficulty.getString()}';
    }

    if (ClientPrefs.data.characters)
    {
      if (dad != null) dad.dance();
      if (boyfriend != null) boyfriend.dance();
      if (gf != null) gf.dance();
      if (mom != null) mom.dance();
    }

    if (inCutscene) cancelAppearArrows();

    #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    for (notetype in noteTypes)
      startNoteTypesNamed(notetype);
    for (event in eventsPushed)
      startEventsNamed(event);
    #end
    noteTypes = null;
    eventsPushed = null;

    if (eventNotes.length > 1)
    {
      for (event in eventNotes)
        event.time -= eventEarlyTrigger(event);
      eventNotes.sort(function(a:EventNote, b:EventNote) return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
    }

    // SONG SPECIFIC SCRIPTS
    #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/songs/$songName/'))
      for (file in FileSystem.readDirectory(folder))
      {
        #if LUA_ALLOWED
        if (file.toLowerCase().endsWith('.lua')) new FunkinLua(folder + file, 'PLAYSTATE');
        #end

        #if HSCRIPT_ALLOWED
        for (extn in CoolUtil.haxeExtensions)
          if (file.toLowerCase().endsWith('.$extn')) initHScript(folder + file);
        #end
      }

    for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/songs/$songName/sc/'))
      for (file in FileSystem.readDirectory(folder))
        #if HSCRIPT_ALLOWED
        for (extn in CoolUtil.haxeExtensions)
          if (file.toLowerCase().endsWith('.$extn')) initSCHS(folder + file);
        #end

    #if (HSCRIPT_ALLOWED && HScriptImproved)
    for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/songs/$songName/advanced/'))
      for (file in FileSystem.readDirectory(folder))
        for (extn in CoolUtil.haxeExtensions)
          if (file.toLowerCase().endsWith('.$extn')) initHSIScript(folder + file);
    #end
    #end

    callOnScripts('start', []);

    if (isStoryMode)
    {
      switch (songName)
      {
        case 'winter-horrorland':
          cancelAppearArrows();

        case 'roses':
          appearStrumArrows(false);

        case 'ugh', 'guns', 'stress':
          cancelAppearArrows();
      }
    }

    if (startCallback != null) startCallback();
    RecalculateRating();

    FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
    FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

    // PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
    if (ClientPrefs.data.hitsoundVolume > 0) if (ClientPrefs.data.hitSounds != "None") Paths.sound('hitsounds/${ClientPrefs.data.hitSounds}');
    if (!ClientPrefs.data.ghostTapping)
    {
      for (i in 1...4)
        Paths.sound('missnote$i');
    }
    Paths.image('alphabet');

    if (PauseSubState.songName != null) Paths.music(PauseSubState.songName);
    else if (Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none') Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

    resetRPC();

    if (stage != null) stage.onCreatePost();
    callOnScripts('onCreatePost');

    if (ClientPrefs.data.quantNotes && !SONG.options.disableNoteRGB && !SONG.options.disableStrumRGB && !SONG.options.disableNoteQuantRGB) setUpNoteQuant();

    cacheCountdown();
    cachePopUpScore();

    super.create();

    #if desktop
    Application.current.window.title = songInfo;
    #end

    Paths.clearUnusedMemory();

    if (eventNotes.length < 1) checkEventNote();

    if (timeToStart > 0)
    {
      clearNotesBefore(false, timeToStart);
    }

    if (ClientPrefs.data.resultsScreenType == 'KADE')
    {
      subStates.push(new ResultsScreenKadeSubstate(camFollow));
    }

    // This step ensures z-indexes are applied properly,
    // and it's important to call it last so all elements get affected.
    refresh();
  }

  public var stopCountDown:Bool = false;

  private function round(num:Float, numDecimalPlaces:Int)
  {
    var mult:Float = Math.pow(10, numDecimalPlaces);
    return Math.floor(num * mult + 0.5) / mult;
  }

  public dynamic function setUpNoteQuant()
  {
    var bpmChanges = Conductor.bpmChangeMap;
    var strumTime:Float = 0;
    var currentBPM:Float = SONG.bpm;
    var newTime:Float = 0;
    for (note in unspawnNotes)
    {
      strumTime = note.strumTime;
      newTime = strumTime;
      for (i in 0...bpmChanges.length)
        if (strumTime > bpmChanges[i].songTime)
        {
          currentBPM = bpmChanges[i].bpm;
          newTime = strumTime - bpmChanges[i].songTime;
        }
      if (note.quantColorsOnNotes && note.rgbShader.enabled)
      {
        dataStuff = ((currentBPM * (newTime - ClientPrefs.data.noteOffset)) / 1000 / 60);
        beat = round(dataStuff * 48, 0);

        if (!note.isSustainNote)
        {
          if (beat % (192 / 4) == 0)
          {
            col = ClientPrefs.data.arrowRGBQuantize[0][0];
            col2 = ClientPrefs.data.arrowRGBQuantize[0][2];
          }
          else if (beat % (192 / 8) == 0)
          {
            col = ClientPrefs.data.arrowRGBQuantize[1][0];
            col2 = ClientPrefs.data.arrowRGBQuantize[1][2];
          }
          else if (beat % (192 / 12) == 0)
          {
            col = ClientPrefs.data.arrowRGBQuantize[2][0];
            col2 = ClientPrefs.data.arrowRGBQuantize[2][2];
          }
          else if (beat % (192 / 16) == 0)
          {
            col = ClientPrefs.data.arrowRGBQuantize[3][0];
            col2 = ClientPrefs.data.arrowRGBQuantize[3][2];
          }
          else if (beat % (192 / 20) == 0)
          {
            col = ClientPrefs.data.arrowRGBQuantize[4][0];
            col2 = ClientPrefs.data.arrowRGBQuantize[4][2];
          }
          else if (beat % (192 / 24) == 0)
          {
            col = ClientPrefs.data.arrowRGBQuantize[5][0];
            col2 = ClientPrefs.data.arrowRGBQuantize[5][2];
          }
          else if (beat % (192 / 28) == 0)
          {
            col = ClientPrefs.data.arrowRGBQuantize[6][0];
            col2 = ClientPrefs.data.arrowRGBQuantize[6][2];
          }
          else if (beat % (192 / 32) == 0)
          {
            col = ClientPrefs.data.arrowRGBQuantize[7][0];
            col2 = ClientPrefs.data.arrowRGBQuantize[7][2];
          }
          else
          {
            col = 0xFF7C7C7C;
            col2 = 0xFF3A3A3A;
          }
          note.rgbShader.r = col;
          note.rgbShader.g = ClientPrefs.data.arrowRGBQuantize[0][1];
          note.rgbShader.b = col2;
        }
        else
        {
          note.rgbShader.r = note.prevNote.rgbShader.r;
          note.rgbShader.g = note.prevNote.rgbShader.g;
          note.rgbShader.b = note.prevNote.rgbShader.b;
        }
      }

      for (this1 in opponentStrums)
      {
        this1.rgbShader.r = 0xFF808080;
        this1.rgbShader.b = 0xFF474747;
        this1.rgbShader.g = 0xFFFFFFFF;
        this1.rgbShader.enabled = false;
      }
      for (this2 in playerStrums)
      {
        this2.rgbShader.r = 0xFF808080;
        this2.rgbShader.b = 0xFF474747;
        this2.rgbShader.g = 0xFFFFFFFF;
        this2.rgbShader.enabled = false;
      }
    }
    quantSetup = true;
  }

  public var quantSetup:Bool = false;

  public var songInfo:String = '';

  public var notInterupted:Bool = true;

  function set_songSpeed(value:Float):Float
  {
    if (generatedMusic)
    {
      opponentStrums.scrollSpeed = value;
      playerStrums.scrollSpeed = value;
      var ratio:Float = value / songSpeed; // funny word huh
      if (ratio != 1)
      {
        for (note in notes.members)
        {
          note.noteScrollSpeed = value;
          note.resizeByRatio(ratio);
        }
        for (note in unspawnNotes)
        {
          note.noteScrollSpeed = value;
          note.resizeByRatio(ratio);
        }
      }
    }
    songSpeed = value;
    noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
    return value;
  }

  function set_playbackRate(value:Float):Float
  {
    #if FLX_PITCH
    if (generatedMusic)
    {
      vocals.pitch = value;
      opponentVocals.pitch = value;
      FlxG.sound.music.pitch = value;

      var ratio:Float = playbackRate / value; // funny word huh
      if (ratio != 1)
      {
        for (note in notes.members)
          note.resizeByRatio(ratio);
        for (note in unspawnNotes)
          note.resizeByRatio(ratio);
      }
    }
    playbackRate = value;
    FlxG.timeScale = value;
    Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
    setOnScripts('playbackRate', playbackRate);
    #else
    playbackRate = 1.0;
    #end
    return playbackRate;
  }

  function cancelAppearArrows()
  {
    strumLineNotes.forEach(function(babyArrow:StrumArrow) {
      tweenManager.cancelTweensOf(babyArrow);
      babyArrow.alpha = 0;
      babyArrow.y = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
    });
    arrowsAppeared = false;
  }

  function removeStaticArrows(?destroy:Bool = false)
  {
    if (arrowsGenerated)
    {
      arrowLanes.forEach(function(bgLane:FlxSprite) {
        arrowLanes.remove(bgLane, true);
      });
      #if SCEModchartingTools
      arrowPaths.forEach(function(line:ArrowPathSegment) {
        line.clearAFT();
        arrowPaths.remove(line, true);
      });
      #end
      playerStrums.forEach(function(babyArrow:StrumArrow) {
        playerStrums.remove(babyArrow);
        if (destroy) babyArrow.destroy();
      });
      opponentStrums.forEach(function(babyArrow:StrumArrow) {
        opponentStrums.remove(babyArrow);
        if (destroy) babyArrow.destroy();
      });
      strumLineNotes.forEach(function(babyArrow:StrumArrow) {
        strumLineNotes.remove(babyArrow);
        if (destroy) babyArrow.destroy();
      });
      arrowsGenerated = false;
    }
  }

  #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
  public function addTextToDebug(text:String, color:FlxColor, ?timeTaken:Float = 6)
  {
    var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
    newText.text = text;
    newText.color = color;
    newText.disableTime = timeTaken;
    newText.alpha = 1;
    newText.setPosition(10, 8 - newText.height);

    luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
      spr.y += newText.height + 2;
    });
    luaDebugGroup.add(newText);

    Sys.println(text);
  }
  #end

  public dynamic function updateHealthColors(colorsUsed:Bool, gradientSystem:Bool)
  {
    if (SONG.options.oldBarSystem)
    {
      if (!gradientSystem)
      {
        if (colorsUsed)
        {
          healthBar.createFilledBar((opponentMode ? FlxColor.fromString(boyfriend.iconColorFormatted) : FlxColor.fromString(dad.iconColorFormatted)),
            (opponentMode ? FlxColor.fromString(dad.iconColorFormatted) : FlxColor.fromString(boyfriend.iconColorFormatted)));
        }
        else
        {
          healthBar.createFilledBar((opponentMode ? FlxColor.fromString('#66FF33') : FlxColor.fromString('#FF0000')),
            (opponentMode ? FlxColor.fromString('#FF0000') : FlxColor.fromString('#66FF33')));
        }
      }
      else
      {
        if (colorsUsed) healthBar.createGradientBar([
          FlxColor.fromString(boyfriend.iconColorFormatted),
          FlxColor.fromString(dad.iconColorFormatted)
        ], [
          FlxColor.fromString(boyfriend.iconColorFormatted),
          FlxColor.fromString(dad.iconColorFormatted)
        ]);
        else
          healthBar.createGradientBar([FlxColor.fromString("#66FF33"), FlxColor.fromString("#FF0000")],
            [FlxColor.fromString("#66FF33"), FlxColor.fromString("#FF0000")]);
      }
      healthBar.updateBar();
    }
    else
    {
      if (colorsUsed)
      {
        healthBarHitNew.setColors(FlxColor.fromString(dad.iconColorFormatted), FlxColor.fromString(boyfriend.iconColorFormatted));
        healthBarNew.setColors(FlxColor.fromString(dad.iconColorFormatted), FlxColor.fromString(boyfriend.iconColorFormatted));
      }
      else
      {
        healthBarHitNew.setColors(FlxColor.fromString('#FF0000'), FlxColor.fromString('#66FF33'));
        healthBarNew.setColors(FlxColor.fromString('#FF0000'), FlxColor.fromString('#66FF33'));
      }
    }
  }

  public dynamic function reloadColors()
  {
    updateHealthColors(ClientPrefs.data.healthColor, ClientPrefs.data.gradientSystemForOldBars);

    if (SONG.options.oldBarSystem)
    {
      if (ClientPrefs.data.colorBarType == 'Main Colors') timeBar.createGradientBar([FlxColor.BLACK], [
        FlxColor.fromString(boyfriend.iconColorFormatted),
        FlxColor.fromString(dad.iconColorFormatted)
      ]);
      else if (ClientPrefs.data.colorBarType == 'Reversed Colors') timeBar.createGradientBar([FlxColor.BLACK], [
        FlxColor.fromString(dad.iconColorFormatted),
        FlxColor.fromString(boyfriend.iconColorFormatted)
      ]);
      timeBar.updateBar();
    }

    if (!allowTxtColorChanges) return;
    for (i in [timeTxt, kadeEngineWatermark, scoreTxt, judgementCounter, botplayTxt])
    {
      i.color = FlxColor.fromString(dad.iconColorFormatted);
      if (i.color == CoolUtil.colorFromString('0xFF000000')
        || i.color == CoolUtil.colorFromString('#000000')
        || i.color == FlxColor.BLACK) i.borderColor = FlxColor.WHITE;
      else
        i.borderColor = FlxColor.BLACK;
    }
  }

  public function startCharacterScripts(name:String)
  {
    // Lua
    #if LUA_ALLOWED
    var doPush:Bool = false;
    var luaFile:String = 'data/characters/' + name + '.lua';
    #if MODS_ALLOWED
    var replacePath:String = Paths.modFolders(luaFile);
    if (FileSystem.exists(replacePath))
    {
      luaFile = replacePath;
      doPush = true;
    }
    else
    {
      luaFile = Paths.getSharedPath(luaFile);
      if (FileSystem.exists(luaFile)) doPush = true;
    }
    #else
    luaFile = Paths.getSharedPath(luaFile);
    if (Assets.exists(luaFile)) doPush = true;
    #end

    if (doPush)
    {
      for (script in luaArray)
      {
        if (script.scriptName == luaFile)
        {
          doPush = false;
          break;
        }
      }
      if (doPush) new FunkinLua(luaFile, 'PLAYSTATE');
    }
    #end

    // HScript
    #if HSCRIPT_ALLOWED
    var doPush:Bool = false;
    var scriptFile:String = 'data/characters/' + name;
    for (extn in CoolUtil.haxeExtensions)
    {
      var scriptFileHx:String = scriptFile + '.$extn';
      #if MODS_ALLOWED
      var replacePath:String = Paths.modFolders(scriptFileHx);
      if (FileSystem.exists(replacePath))
      {
        scriptFileHx = replacePath;
        doPush = true;
      }
      else
      #end
      {
        scriptFileHx = Paths.getSharedPath(scriptFileHx);
        if (FileSystem.exists(scriptFileHx)) doPush = true;
      }

      if (doPush)
      {
        if (Iris.instances.exists(scriptFileHx)) doPush = false;
        if (doPush) initHScript(scriptFileHx);
      }
    }

    #if HScriptImproved
    var doPush:Bool = false;
    var scriptFile:String = 'data/characters/advancedCharScripts/' + name;
    for (extn in CoolUtil.haxeExtensions)
    {
      var scriptFileHx:String = scriptFile + '.$extn';
      #if MODS_ALLOWED
      var replacePath:String = Paths.modFolders(scriptFileHx);
      if (FileSystem.exists(replacePath))
      {
        scriptFileHx = replacePath;
        doPush = true;
      }
      else
      #end
      {
        scriptFileHx = Paths.getSharedPath(scriptFileHx);
        if (FileSystem.exists(scriptFileHx)) doPush = true;
      }

      if (doPush)
      {
        for (script in codeNameScripts.scripts)
        {
          if (script.fileName == scriptFileHx)
          {
            doPush = false;
            break;
          }
        }
        if (doPush) initHSIScript(scriptFileHx);
      }
    }
    #end
    #end
  }

  public function getLuaObject(tag:String):Dynamic
    return variables.get(tag);

  public function startCharacterPos(char:Character, ?gfCheck:Bool = false, ?isBf:Bool = false)
  {
    if (gfCheck && char.curCharacter.startsWith('gf'))
    { // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
      char.setPosition(GF_X, GF_Y);
      char.scrollFactor.set(0.95, 0.95);
      char.idleBeat = 2;
    }
    char.x += char.positionArray[0];
    char.y += char.positionArray[1] - (isBf ? 350 : 0);
  }

  public var videoCutscene:VideoSprite = null;

  public function startVideo(name:String, type:String = 'mp4', forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, adjustSize:Bool = true,
      playOnLoad:Bool = true)
  {
    #if (VIDEOS_ALLOWED && hxvlc)
    try
    {
      if (!forMidSong) inCinematic = true;
      canPause = false;

      var foundFile:Bool = false;
      var fileName:String = Paths.video(name, type);
      #if sys
      if (FileSystem.exists(fileName))
      #else
      if (OpenFlAssets.exists(fileName))
      #end
      foundFile = true;

      if (foundFile)
      {
        videoCutscene = new VideoSprite(fileName, forMidSong, canSkip, loop, adjustSize);

        // Finish callback
        if (!forMidSong)
        {
          function onVideoEnd()
          {
            callOnScripts('onVideoCompleted', [name]);
            if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
            {
              cameraTargeted = SONG.notes[Std.int(curStep / 16)].mustHitSection ? 'bf' : 'dad';
              FlxG.camera.snapToTarget();
            }
            videoCutscene = null;
            canPause = false;
            inCutscene = false;
            startAndEnd();
          }

          function onVideoSkipped()
          {
            callOnScripts('onVideoSkipped', [name]);
            if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
            {
              cameraTargeted = SONG.notes[Std.int(curStep / 16)].mustHitSection ? 'bf' : 'dad';
              FlxG.camera.snapToTarget();
            }
            videoCutscene = null;
            canPause = false;
            inCutscene = false;
            startAndEnd();
          }
          // End callback
          videoCutscene.finishCallback = onVideoEnd;
          // Skip callback
          videoCutscene.onSkip = onVideoSkipped;
        }
        add(videoCutscene);

        if (playOnLoad) videoCutscene.play();
        return videoCutscene;
      }
      #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
      else
        addTextToDebug("Video not found: " + fileName, FlxColor.RED);
      #else
      else
        FlxG.log.error("Video not found: " + fileName);
      #end
    }
    catch (e:Dynamic) {}
    #else
    FlxG.log.warn('Platform not supported!');
    startAndEnd();
    #end
    return null;
  }

  function startAndEnd()
  {
    if (endingSong) endSong();
    else
      startCountdown();
  }

  var dialogueCount:Int = 0;

  public var psychDialogue:DialogueBoxPsych;

  // You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
  public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
  {
    // TO DO: Make this more flexible, maybe?
    if (psychDialogue != null) return;

    if (dialogueFile.dialogue.length > 0)
    {
      inCutscene = true;
      psychDialogue = new DialogueBoxPsych(dialogueFile, song);
      psychDialogue.scrollFactor.set();
      if (endingSong)
      {
        psychDialogue.finishThing = function() {
          psychDialogue = null;
          endSong();
        }
      }
      else
      {
        psychDialogue.finishThing = function() {
          psychDialogue = null;
          startCountdown();
        }
      }
      psychDialogue.nextDialogueThing = startNextDialogue;
      psychDialogue.skipDialogueThing = skipDialogue;
      psychDialogue.cameras = [camHUD];
      add(psychDialogue);
    }
    else
    {
      FlxG.log.warn('Your dialogue file is badly formatted!');
      startAndEnd();
    }
  }

  var startTimer:FlxTimer;
  var finishTimer:FlxTimer = null;

  // For being able to mess with the sprites on Lua
  public var getReady:FlxSprite;
  public var countdownReady:FlxSprite;
  public var countdownSet:FlxSprite;
  public var countdownGo:FlxSprite;

  // Can't make it a instance because of how it functions!
  public static var startOnTime:Float = 0;

  // CountDown Stuff
  public var stageIntroSoundsSuffix:String = '';
  public var stageIntroSoundsPrefix:String = '';

  function cacheCountdown()
  {
    stageIntroSoundsSuffix = stage.stageIntroSoundsSuffix != null ? stage.stageIntroSoundsSuffix : '';
    stageIntroSoundsPrefix = stage.stageIntroSoundsPrefix != null ? stage.stageIntroSoundsPrefix : '';

    var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
    var introImagesArray:Array<String> = switch (stageUI)
    {
      case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
      case "normal": ["ready", "set", "go"];
      default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
    }
    if (stage.stageIntroAssets != null) introAssets.set(stage.curStage, stage.stageIntroAssets);
    else
      introAssets.set(stageUI, introImagesArray);
    var introAlts:Array<String> = introAssets.get(stageUI);

    for (value in introAssets.keys())
    {
      if (value == stage.curStage)
      {
        introAlts = introAssets.get(value);

        if (stageIntroSoundsSuffix != '' || stageIntroSoundsSuffix != null || stageIntroSoundsSuffix != "") introSoundsSuffix = stageIntroSoundsSuffix;
        else
          introSoundsSuffix = '';

        if (stageIntroSoundsPrefix != '' || stageIntroSoundsPrefix != null || stageIntroSoundsPrefix != "") introSoundsPrefix = stageIntroSoundsPrefix;
        else
          introSoundsPrefix = '';
      }
    }

    for (asset in introAlts)
      Paths.image(asset);

    Paths.sound(introSoundsPrefix + 'intro3' + introSoundsSuffix);
    Paths.sound(introSoundsPrefix + 'intro2' + introSoundsSuffix);
    Paths.sound(introSoundsPrefix + 'intro1' + introSoundsSuffix);
    Paths.sound(introSoundsPrefix + 'introGo' + introSoundsSuffix);
  }

  public function updateDefaultPos()
  {
    for (i in 0...playerStrums.length)
    {
      setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
      setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
    }
    for (i in 0...opponentStrums.length)
    {
      setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
      setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
    }
    for (i in 0...strumLineNotes.length)
    {
      var member = strumLineNotes.members[i];
      setOnScripts("defaultStrum" + i + "X", Math.floor(member.x));
      setOnScripts("defaultStrum" + i + "Y", Math.floor(member.y));
      setOnScripts("defaultStrum" + i + "Angle", Math.floor(member.angle));
      setOnScripts("defaultStrum" + i + "Alpha", Math.floor(member.alpha));
    }

    #if SCEModchartingTools
    if (SONG.options.notITG && notITGMod) modcharting.NoteMovement.getDefaultStrumPos(this);
    #end
  }

  public var introSoundsSuffix:String = '';
  public var introSoundsPrefix:String = '';

  public var skipStrumSpawn:Bool = false;

  public var tick:Countdown = PREPARE;

  public dynamic function startCountdown()
  {
    stageIntroSoundsSuffix = stage.stageIntroSoundsSuffix != null ? stage.stageIntroSoundsSuffix : '';
    stageIntroSoundsPrefix = stage.stageIntroSoundsPrefix != null ? stage.stageIntroSoundsPrefix : '';

    if (!stopCountDown)
    {
      if (startedCountdown)
      {
        callOnScripts('onStartCountdown');
        return false;
      }

      if (inCinematic || inCutscene)
      {
        if (!arrowsAppeared)
        {
          appearStrumArrows(true);
        }
      }

      var arrowSetupStuffDAD:String = dad.strumSkin;
      var arrowSetupStuffBF:String = boyfriend.strumSkin;
      var songArrowSkins:Bool = !(SONG.options.strumSkin == null || SONG.options.strumSkin == '' || SONG.options.strumSkin == "");

      if (arrowSetupStuffBF == null || arrowSetupStuffBF == '' || arrowSetupStuffBF == "")
        arrowSetupStuffBF = (!songArrowSkins ? (isPixelStage ? 'pixel' : 'normal') : SONG.options.strumSkin);
      else
        arrowSetupStuffBF = boyfriend.noteSkin;
      if (arrowSetupStuffDAD == null || arrowSetupStuffDAD == '' || arrowSetupStuffDAD == "")
        arrowSetupStuffDAD = (!songArrowSkins ? (isPixelStage ? 'pixel' : 'normal') : SONG.options.strumSkin);
      else
        arrowSetupStuffDAD = dad.noteSkin;

      seenCutscene = true;
      inCutscene = false;
      inCinematic = false;

      if (SONG.notes[curSection] != null) cameraTargeted = SONG.notes[curSection].mustHitSection != true ? 'dad' : 'bf';
      isCameraFocusedOnCharacters = true;

      var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
      if (ret != LuaUtils.Function_Stop)
      {
        var skippedAhead:Bool = (skipCountdown || startOnTime > 0);
        if (!skipStrumSpawn)
        {
          setupArrowStuff(0, arrowSetupStuffDAD); // opponent
          setupArrowStuff(1, arrowSetupStuffBF); // player
          updateDefaultPos();
          if (!arrowsAppeared)
          {
            appearStrumArrows(skippedAhead ? false : ((!isStoryMode || storyPlaylist.length >= 3 || songName == 'tutorial')
              && !skipArrowStartTween
              && !disabledIntro));
          }
        }

        startedCountdown = true;
        Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
        setOnScripts('startedCountdown', true);
        callOnScripts('onCountdownStarted');

        var swagCounter:Int = 0;
        if (startOnTime > 0)
        {
          clearNotesBefore(false, startOnTime);
          setSongTime(startOnTime - 350);
          return true;
        }
        else if (skipCountdown)
        {
          setSongTime(0);
          return true;
        }

        startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
          if (ClientPrefs.data.characters) characterBopper(swagCounter);

          var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
          var introImagesArray:Array<String> = switch (stageUI)
          {
            case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
            case "normal": ["ready", "set", "go"];
            default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
          }
          if (stage.stageIntroAssets != null) introAssets.set(stage.curStage, stage.stageIntroAssets);
          else
            introAssets.set(stageUI, introImagesArray);

          var isPixelated:Bool = isPixelStage;
          var introAlts:Array<String> = (stage.stageIntroAssets != null ? introAssets.get(stage.curStage) : introAssets.get(stageUI));
          var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelated);

          for (value in introAssets.keys())
          {
            if (value == stage.curStage)
            {
              introAlts = introAssets.get(value);

              if (stageIntroSoundsSuffix != '' || stageIntroSoundsSuffix != null || stageIntroSoundsSuffix != "") introSoundsSuffix = stageIntroSoundsSuffix;
              else
                introSoundsSuffix = '';

              if (stageIntroSoundsPrefix != '' || stageIntroSoundsPrefix != null || stageIntroSoundsPrefix != "") introSoundsPrefix = stageIntroSoundsPrefix;
              else
                introSoundsPrefix = '';
            }
          }

          if (generatedMusic) notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

          var introArrays0:Array<Float> = null;
          var introArrays1:Array<Float> = null;
          var introArrays2:Array<Float> = null;
          var introArrays3:Array<Float> = null;
          if (stage.stageIntroSpriteScales != null)
          {
            introArrays0 = stage.stageIntroSpriteScales[0];
            introArrays1 = stage.stageIntroSpriteScales[1];
            introArrays2 = stage.stageIntroSpriteScales[2];
            introArrays3 = stage.stageIntroSpriteScales[3];
          }

          tick = decrementTick(tick);

          switch (tick)
          {
            case THREE:
              var isNotNull = (introAlts.length > 3 ? introAlts[0] : "missingRating");
              getReady = createCountdownSprite(isNotNull, antialias, introSoundsPrefix + 'intro3' + introSoundsSuffix, introArrays0);
            case TWO:
              countdownReady = createCountdownSprite(introAlts[introAlts.length - 3], antialias, introSoundsPrefix + 'intro2' + introSoundsSuffix,
                introArrays1);
            case ONE:
              countdownSet = createCountdownSprite(introAlts[introAlts.length - 2], antialias, introSoundsPrefix + 'intro1' + introSoundsSuffix, introArrays2);
            case GO:
              countdownGo = createCountdownSprite(introAlts[introAlts.length - 1], antialias, introSoundsPrefix + 'introGo' + introSoundsSuffix, introArrays3);
              if (ClientPrefs.data.heyIntro)
              {
                for (char in [dad, boyfriend, gf, mom])
                {
                  if (char != null && (char.hasOffsetAnimation('hey') || char.hasOffsetAnimation('cheer')))
                  {
                    char.playAnim(char.hasOffsetAnimation('hey') ? 'hey' : 'cheer', true);
                    if (!char.skipHeyTimer)
                    {
                      char.specialAnim = true;
                      char.heyTimer = 0.6;
                    }
                  }
                }
              }
            case START:
            default:
          }

          if (!skipStrumSpawn && arrowsAppeared)
          {
            notes.forEachAlive(function(note:Note) {
              note.copyAlpha = false;
              note.alpha = note.multAlpha;
              if ((ClientPrefs.data.middleScroll && !note.mustPress && !opponentMode)
                || (ClientPrefs.data.middleScroll && !note.mustPress && opponentMode))
              {
                note.alpha *= 0.35;
              }
            });
          }

          if (stage != null) stage.countdownTickStage(tick, swagCounter);
          callOnLuas('onCountdownTick', [swagCounter]);
          callOnAllHS('onCountdownTick', [tick, swagCounter]);

          swagCounter += 1;
        }, 5);
      }
      return true;
    }
    return false;
  }

  inline public function decrementTick(tick:Countdown):Countdown
  {
    switch (tick)
    {
      case PREPARE:
        return THREE;
      case THREE:
        return TWO;
      case TWO:
        return ONE;
      case ONE:
        return GO;
      case GO:
        return START;

      default:
        return START;
    }
  }

  inline public function createCountdownSprite(image:String, antialias:Bool, soundName:String, scale:Array<Float> = null):FlxSprite
  {
    var spr:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image(image));
    spr.cameras = [camHUD];
    spr.scrollFactor.set();
    spr.updateHitbox();

    if (image.contains("-pixel") && scale == null) spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

    if (scale != null && scale.length > 1) spr.scale.set(scale[0], scale[1]);

    spr.screenCenter();
    spr.antialiasing = antialias;
    insert(members.indexOf(notes), spr);
    createTween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000,
      {
        ease: FlxEase.cubeInOut,
        onComplete: function(twn:FlxTween) {
          remove(spr);
          spr.destroy();
        }
      });
    if (!stage.disabledIntroSounds) FlxG.sound.play(Paths.sound(soundName), 0.6);
    return spr;
  }

  public function addBehindGF(obj:FlxBasic)
    insert(members.indexOf(gf), obj);

  public function addBehindBF(obj:FlxBasic)
    insert(members.indexOf(boyfriend), obj);

  public function addBehindMom(obj:FlxBasic)
    insert(members.indexOf(mom), obj);

  public function addBehindDad(obj:FlxBasic)
    insert(members.indexOf(dad), obj);

  public function clearNotesBefore(completelyClearNotes:Bool = false, ?time:Float)
  {
    var i:Int = unspawnNotes.length - 1;
    while (i >= 0)
    {
      var daNote:Note = unspawnNotes[i];
      if (!completelyClearNotes) if (daNote.strumTime - 350 < time) invalidateNote(daNote, true);
      else
        invalidateNote(daNote, true);
      --i;
    }

    i = notes.length - 1;
    while (i >= 0)
    {
      var daNote:Note = notes.members[i];
      if (!completelyClearNotes) if (daNote.strumTime - 350 < time) invalidateNote(daNote, false);
      else
        invalidateNote(daNote, false);
      --i;
    }
  }

  public var updateAcc:Float;

  // fun fact: Dynamic Functions can be overriden by just doing this
  // `updateScore = function(miss:Bool = false) { ... }
  // its like if it was a variable but its just a function!
  // cool right? -Crow
  public dynamic function updateScore(miss:Bool = false)
  {
    var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
    if (ret == LuaUtils.Function_Stop) return;

    updateAcc = CoolUtil.floorDecimal(ratingPercent * 100, 2);

    var str:String = Language.getPhrase('rating_$ratingName', ratingName);
    if (totalPlayed != 0)
    {
      str += ' (${updateAcc}%) - ' + Language.getPhrase(ratingFC);

      // Song Rating!
      comboLetterRank = Rating.generateComboLetter(updateAcc);
    }

    var tempScore:String;
    if (!instakillOnMiss)
    {
      switch (whichHud)
      {
        case 'GLOW_KADE':
          tempScore = Language.getPhrase('score_text_glowkade', 'Score: {1} • Combo Breaks: {2} • Rating: {3} • Rank: {4}',
            [songScore, songMisses, str, comboLetterRank]);
        case 'HITMANS':
          tempScore = Language.getPhrase('score_text_glowkade', 'Score: {1} | Misses: {2} | Rating: {3} | Rank: {4}',
            [songScore, songMisses, str, comboLetterRank]);
        default:
          tempScore = Language.getPhrase('score_text', 'Score: {1} | Misses: {2} | Rating: {3}', [songScore, songMisses, str]);
      }
    }
    else
    {
      switch (whichHud)
      {
        case 'GLOW_KADE':
          tempScore = Language.getPhrase('score_text_instakill_glowkade', 'Score: {1} • Rating: {2} • Rank: {3}', [songScore, str, comboLetterRank]);
        case 'HITMANS':
          tempScore = Language.getPhrase('score_text_glowkade', 'Score: {1} | Combo Breaks: {2} | Rating: {3}', [songScore, str, comboLetterRank]);
        default:
          tempScore = Language.getPhrase('score_text_instakill', 'Score: {1} | Rating: {2}', [songScore, str]);
      }
    }

    if (whichHud == 'CLASSIC') tempScore = Language.getPhrase('score_text_classic', 'Score: {1}', [songScore]);
    scoreTxt.text = tempScore;

    if (!miss) doScoreBop();

    if (ClientPrefs.data.judgementCounter)
    {
      judgementCounter.text = '';

      var timingWins = Rating.timingWindows.copy();
      timingWins.reverse();

      for (rating in timingWins)
        judgementCounter.text += '${rating.name}s: ${rating.count}\n';

      judgementCounter.text += 'Misses: ${songMisses}\n';
      judgementCounter.updateHitbox();
    }
    callOnScripts('onUpdateScore', [miss]);
  }

  public function doScoreBop():Void
  {
    if (!ClientPrefs.data.scoreZoom || useSLEHUD) return;

    if (scoreTxtTween != null) scoreTxtTween.cancel();

    scoreTxt.scale.x = 1.075;
    scoreTxt.scale.y = 1.075;
    scoreTxtTween = createTween(scoreTxt.scale, {x: 1, y: 1}, 0.2,
      {
        onComplete: function(twn:FlxTween) {
          scoreTxtTween = null;
        }
      });
  }

  public function setSongTime(time:Float)
  {
    FlxG.sound.music.pause();
    vocals.pause();
    opponentVocals.pause();
    FlxG.sound.music.time = time - Conductor.offset;
    #if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
    FlxG.sound.music.play();

    if (Conductor.songPosition < vocals.length)
    {
      vocals.time = time - Conductor.offset;
      #if FLX_PITCH vocals.pitch = playbackRate; #end
      vocals.play();
    }
    else
      vocals.pause();

    if (Conductor.songPosition < opponentVocals.length)
    {
      opponentVocals.time = time - Conductor.offset;
      #if FLX_PITCH opponentVocals.pitch = playbackRate; #end
      opponentVocals.play();
    }
    else
      opponentVocals.pause();

    Conductor.songPosition = time;
  }

  public function startNextDialogue()
  {
    dialogueCount++;
    callOnScripts('onNextDialogue', [dialogueCount]);
  }

  public function skipDialogue()
  {
    callOnScripts('onSkipDialogue', [dialogueCount]);
  }

  public var songStarted = false;
  public var acceptFinishedSongBind = true;

  public dynamic function startSong():Void
  {
    canPause = true;
    startingSong = false;
    songStarted = true;

    #if (VIDEOS_ALLOWED && hxvlc)
    if (daVideoGroup != null)
    {
      for (vid in daVideoGroup)
      {
        vid.videoSprite.bitmap.resume();
      }
    }
    #end

    @:privateAccess
    FlxG.sound.playMusic(inst._sound, 1, false);
    #if FLX_PITCH
    FlxG.sound.music.pitch = playbackRate;
    #end
    if (acceptFinishedSongBind) FlxG.sound.music.onComplete = finishSong.bind();
    // Prevent the volume from being wrong.
    FlxG.sound.music.volume = 1.0;
    vocals.play();
    opponentVocals.play();

    setSongTime(Math.max(0, timeToStart) + Conductor.offset);
    timeToStart = 0;

    setSongTime(Math.max(0, startOnTime - 500) + Conductor.offset);
    startOnTime = 0;

    if (ClientPrefs.data.characters)
    {
      switch (songName)
      {
        case 'bopeebo' | 'philly-nice' | 'blammed' | 'cocoa' | 'eggnog':
          allowedToCheer = true;
        default:
          allowedToCheer = false;
      }
    }

    Debug.logInfo('started loading!');

    if (paused)
    {
      FlxG.sound.music.pause();
      vocals.pause();
    }

    if (stage != null) stage.startSongStage();

    // Song duration in a float, useful for the time left feature
    songLength = FlxG.sound.music.length;
    if (SONG.options.oldBarSystem)
    {
      createTween(timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
      createTween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    }
    else
      createTween(timeBarNew, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    createTween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

    #if DISCORD_ALLOWED
    // Updating Discord Rich Presence (with Time Left)
    if (autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.songId + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
    #end

    setOnScripts('songLength', songLength);
    callOnScripts('onSongStart');
  }

  public var noteTypes:Array<String> = [];
  public var eventsPushed:Array<String> = [];

  public var opponentSectionNoteStyle:String = "";
  public var playerSectionNoteStyle:String = "";

  public var opponentSectionStrumStyle:String = "";
  public var playerSectionStrumStyle:String = "";

  // note shit
  public var noteSkinDad:String;
  public var noteSkinBF:String;

  public var strumSkinDad:String;
  public var strumSkinBF:String;

  public var daSection:Int = 0;
  public var totalColumns:Int = 4;

  public dynamic function generateSong():Void
  {
    opponentSectionNoteStyle = "";
    playerSectionNoteStyle = "";

    opponentSectionStrumStyle = "";
    playerSectionStrumStyle = "";

    var songData = SONG;

    songSpeed = songData.speed;
    songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
    switch (songSpeedType)
    {
      case "multiplicative":
        songSpeed = songData.speed * ClientPrefs.getGameplaySetting('scrollspeed');
      case "constant":
        songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
    }

    Conductor.bpm = songData.bpm;

    curSong = songData.songId;

    if (instakillOnMiss)
    {
      var redVignette:FlxSprite = new FlxSprite().loadGraphic(Paths.image('nomisses_vignette', 'shared'));
      redVignette.screenCenter();
      redVignette.cameras = [mainCam];
      add(redVignette);
    }

    vocals = new FlxSound();
    opponentVocals = new FlxSound();
    try
    {
      if (songData.needsVoices)
      {
        final currentPrefix:String = (songData.options.vocalsPrefix != null ? songData.options.vocalsPrefix : '');
        final currentSuffix:String = (songData.options.vocalsSuffix != null ? songData.options.vocalsSuffix : '');
        final vocalPl:String = (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile;
        final normalVocals = Paths.voices(currentPrefix, songData.songId, currentSuffix);
        var playerVocals = SoundUtil.findVocal(
          {
            song: songData.songId,
            prefix: currentPrefix,
            suffix: currentSuffix,
            externVocal: vocalPl,
            character: boyfriend.curCharacter,
            difficulty: Difficulty.getString()
          });
        vocals.loadEmbedded(playerVocals != null ? playerVocals : normalVocals);

        final vocalOp:String = (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile;
        var oppVocals = SoundUtil.findVocal(
          {
            song: songData.songId,
            prefix: currentPrefix,
            suffix: currentSuffix,
            externVocal: vocalOp,
            character: dad.curCharacter,
            difficulty: Difficulty.getString()
          });
        if (oppVocals != null)
        {
          opponentVocals.loadEmbedded(oppVocals);
          splitVocals = true;
        }
      }
    }
    catch (e:Dynamic) {}

    #if FLX_PITCH
    vocals.pitch = playbackRate;
    opponentVocals.pitch = playbackRate;
    #end

    FlxG.sound.list.add(vocals);
    FlxG.sound.list.add(opponentVocals);

    inst = new FlxSound();
    try
    {
      inst.loadEmbedded(Paths.inst((songData.options.instrumentalPrefix != null ? songData.options.instrumentalPrefix : ''), songData.songId,
        (songData.options.instrumentalSuffix != null ? songData.options.instrumentalSuffix : '')));
    }
    catch (e:Dynamic) {}
    #if FLX_PITCH inst.pitch = playbackRate; #end
    FlxG.sound.list.add(inst);

    notes = new FlxTypedGroup<Note>();
    add(notes);

    var difficultyEventsFound:Bool = false;
    var file:String = Paths.getPath('data/songs/$songName/events-${Difficulty.getString().toLowerCase()}.json', TEXT);
    if (#if MODS_ALLOWED FileSystem.exists(file) || #end OpenFlAssets.exists(file))
    {
      var eventsData:Array<Dynamic> = Song.getChart('events-' + Difficulty.getString().toLowerCase(), songName).events;
      if (eventsData != null)
      {
        for (event in eventsData) // Event Notes
          for (i in 0...event[1].length)
            makeEvent(event, i);
        difficultyEventsFound = true;
      }
    }

    file = Paths.getPath('data/songs/$songName/events.json', TEXT);
    if (#if MODS_ALLOWED FileSystem.exists(file) || #end OpenFlAssets.exists(file))
    {
      var eventsData:Array<Dynamic> = Song.getChart('events', songName).events;
      if (eventsData != null && !difficultyEventsFound)
      {
        for (event in eventsData) // Event Notes
          for (i in 0...event[1].length)
            makeEvent(event, i);
      }
    }

    var stuff:Array<String> = [];

    if (FileSystem.exists(Paths.txt('songs/' + SONG.songId.toLowerCase() + "/arrowSwitches")))
    {
      stuff = CoolUtil.coolTextFile(Paths.txt('songs/' + SONG.songId.toLowerCase() + "/arrowSwitches"));
    }

    playerStrums.scrollSpeed = songSpeed;
    opponentStrums.scrollSpeed = songSpeed;

    var oldNote:Note = null;
    var sectionsData:Array<SwagSection> = SONG.notes;
    var ghostNotesCaught:Int = 0;
    for (section in sectionsData)
    {
      if (stuff != [])
      {
        for (i in 0...stuff.length)
        {
          var data:Array<String> = stuff[i].split(' ');

          if (daSection == Std.parseInt(data[0]))
          {
            (data[2] == 'dad' ? opponentSectionNoteStyle = data[1] : playerSectionNoteStyle = data[1]);
            (data[3] == 'dad' ? opponentSectionStrumStyle = data[4] : playerSectionStrumStyle = data[4]);
          }
        }
      }
      for (i in 0...section.sectionNotes.length)
      {
        noteSkinDad = dad.noteSkin;
        noteSkinBF = boyfriend.noteSkin;

        strumSkinDad = dad.strumSkin;
        strumSkinBF = boyfriend.strumSkin;

        final songNotes:Array<Dynamic> = section.sectionNotes[i];
        var spawnTime:Float = songNotes[0];
        var noteColumn:Int = Std.int(songNotes[1] % totalColumns);
        var holdLength:Float = songNotes[2];
        var noteType:String = songNotes[3];
        if (Math.isNaN(holdLength)) holdLength = 0.0;

        var gottaHitNote:Bool = true;

        if (songNotes[1] > 3 && !opponentMode) gottaHitNote = false;
        else if (songNotes[1] <= 3 && opponentMode) gottaHitNote = false;

        var noteSkinUsed:String = (gottaHitNote ? (OMANDNOTMS ? (opponentSectionNoteStyle != "" ? opponentSectionNoteStyle : noteSkinDad) : (playerSectionNoteStyle != "" ? playerSectionNoteStyle : noteSkinBF)) : (!OMANDNOTMS ? (opponentSectionNoteStyle != "" ? opponentSectionNoteStyle : noteSkinDad) : (playerSectionNoteStyle != "" ? playerSectionNoteStyle : noteSkinBF)));
        var songArrowSkins:Bool = true;

        if (SONG.options.arrowSkin == null || SONG.options.arrowSkin == '' || SONG.options.arrowSkin == "") songArrowSkins = false;
        if (noteSkinUsed == null || noteSkinUsed == '' || noteSkinUsed == "")
          noteSkinUsed = (!songArrowSkins ? (isPixelStage ? 'pixel' : 'normal') : SONG.options.arrowSkin);
        else
          noteSkinUsed = (gottaHitNote ? (OMANDNOTMS ? (opponentSectionNoteStyle != "" ? opponentSectionNoteStyle : noteSkinDad) : (playerSectionNoteStyle != "" ? playerSectionNoteStyle : noteSkinBF)) : (!OMANDNOTMS ? (opponentSectionNoteStyle != "" ? opponentSectionNoteStyle : noteSkinDad) : (playerSectionNoteStyle != "" ? playerSectionNoteStyle : noteSkinBF)));

        if (i != 0)
        {
          // CLEAR ANY POSSIBLE GHOST NOTES
          for (evilNote in unspawnNotes)
          {
            var matches:Bool = (noteColumn == evilNote.noteData && gottaHitNote == evilNote.mustPress && evilNote.noteType == noteType);
            if (matches && Math.abs(spawnTime - evilNote.strumTime) == 0.0)
            {
              evilNote.destroy();
              unspawnNotes.remove(evilNote);
              ghostNotesCaught++;
              // continue;
            }
          }
        }

        var swagNote:Note = new Note(spawnTime, noteColumn, false, noteSkinUsed, oldNote, this, songSpeed, gottaHitNote ? playerStrums : opponentStrums, false);
        var altName:String = gottaHitNote ? ((section.altAnim
          || (!opponentMode ? section.CPUAltAnim : section.playerAltAnim)) ? '-alt' : '') : ((section.altAnim
            || (opponentMode ? section.CPUAltAnim : section.playerAltAnim)) ? '-alt' : '');
        var isPixelNote:Bool = (swagNote.texture.contains('pixel') || swagNote.noteSkin.contains('pixel') || noteSkinDad.contains('pixel')
          || noteSkinBF.contains('pixel'));
        swagNote.setupNote(gottaHitNote, gottaHitNote ? 1 : 0, daSection, noteType);
        if (swagNote.noteType != 'GF Sing') swagNote.gfNote = (section.gfSection && !gottaHitNote);
        if (altName == '' && swagNote.noteType == 'Alt Animation') altName = '-alt';
        swagNote.animSuffix = altName;
        swagNote.containsPixelTexture = isPixelNote;
        swagNote.sustainLength = holdsActive ? holdLength : 0.0;
        swagNote.dType = section.dType;
        swagNote.scrollFactor.set();
        unspawnNotes.push(swagNote);

        final roundSus:Int = Math.round(swagNote.sustainLength / Conductor.stepCrochet);
        if (roundSus != 0)
        {
          for (susNote in 0...roundSus + 1)
          {
            oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

            var sustainNote:Note = new Note(spawnTime + (Conductor.stepCrochet * susNote), noteColumn, true, noteSkinUsed, oldNote, this, songSpeed,
              gottaHitNote ? playerStrums : opponentStrums, false);
            var isPixelNoteSus:Bool = (sustainNote.texture.contains('pixel')
              || sustainNote.noteSkin.contains('pixel')
              || oldNote.texture.contains('pixel')
              || oldNote.noteSkin.contains('pixel')
              || noteSkinDad.contains('pixel')
              || noteSkinBF.contains('pixel'));
            sustainNote.setupNote(swagNote.mustPress, swagNote.strumLine, swagNote.noteSection, swagNote.noteType);
            sustainNote.animSuffix = swagNote.animSuffix;
            if (sustainNote.noteType != 'GF Sing') sustainNote.gfNote = swagNote.gfNote;
            sustainNote.dType = swagNote.dType;
            sustainNote.containsPixelTexture = isPixelNoteSus;
            sustainNote.parent = swagNote;
            sustainNote.scrollFactor.set();
            unspawnNotes.push(sustainNote);
            swagNote.tail.push(sustainNote);

            // After everything loads
            var isNotePixel:Bool = isPixelNoteSus;
            oldNote.containsPixelTexture = isNotePixel;
            sustainNote.correctionOffset = swagNote.height / 2;
            if (!isNotePixel)
            {
              if (oldNote.isSustainNote)
              {
                oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
                oldNote.scale.y /= playbackRate;
                oldNote.updateHitbox();
              }

              if (ClientPrefs.data.downScroll) sustainNote.correctionOffset = 0;
            }
            else if (oldNote.isSustainNote)
            {
              oldNote.scale.y /= playbackRate;
              oldNote.updateHitbox();
            }

            if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
            else if (ClientPrefs.data.middleScroll)
            {
              sustainNote.x += 310;
              if (noteColumn > 1) // Up and Right
                sustainNote.x += FlxG.width / 2 + 25;
            }
          }
        }

        if (swagNote.mustPress)
        {
          swagNote.x += FlxG.width / 2; // general offset
        }
        else if (ClientPrefs.data.middleScroll)
        {
          swagNote.x += 310;
          if (noteColumn > 1) // Up and Right
            swagNote.x += FlxG.width / 2 + 25;
        }

        if (swagNote.mustPress && !swagNote.isSustainNote) playerNotes++;
        else if (!swagNote.mustPress) opponentNotes++;
        songNotesCount++;

        if (!noteTypes.contains(swagNote.noteType)) noteTypes.push(swagNote.noteType);

        oldNote = swagNote;
      }
    }
    // Event Notes
    for (event in songData.events)
      for (i in 0...event[1].length)
        makeEvent(event, i);

    unspawnNotes.sort(function(a:Note, b:Note):Int {
      return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
    });
    generatedMusic = true;

    opponentSectionNoteStyle = "";
    playerSectionNoteStyle = "";

    opponentSectionStrumStyle = "";
    playerSectionStrumStyle = "";

    callOnScripts('onSongGenerated', []);
  }

  // called only once per different event (Used for precaching)
  public function eventPushed(event:EventNote)
  {
    eventPushedUnique(event);
    if (eventsPushed.contains(event.name))
    {
      return;
    }

    if (stage != null && !finishedSong) stage.eventPushedStage(event);
    eventsPushed.push(event.name);
  }

  // called by every event with the same name
  public function eventPushedUnique(event:EventNote)
  {
    switch (event.name)
    {
      case "Change Character":
        cacheCharacter(event.params[1]);

      case 'Play Sound':
        Paths.sound(event.params[0]);
    }
    if (stage != null && !finishedSong) stage.eventPushedUniqueStage(event);
  }

  public function eventEarlyTrigger(event:EventNote):Float
  {
    var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.name, event.params, event.time], true, [], [0]);
    if (returnedValue == null)
    {
      returnedValue = callOnScripts('eventEarlyTriggerLegacy', [
        event.name,
        event.params[0] != null ? event.params[0] : "",
        event.params[1] != null ? event.params[1] : "",
        event.params[2] != null ? event.params[2] : "",
        event.params[3] != null ? event.params[3] : "",
        event.params[4] != null ? event.params[4] : "",
        event.params[5] != null ? event.params[5] : "",
        event.params[6] != null ? event.params[6] : "",
        event.params[7] != null ? event.params[7] : "",
        event.params[8] != null ? event.params[8] : "",
        event.params[9] != null ? event.params[9] : "",
        event.params[10] != null ? event.params[10] : "",
        event.params[11] != null ? event.params[11] : "",
        event.params[12] != null ? event.params[12] : "",
        event.params[13] != null ? event.params[13] : "",
        event.time
      ], true, [], [0]);
    }
    if (returnedValue != null && returnedValue != 0 && returnedValue != LuaUtils.Function_Continue)
    {
      return returnedValue;
    }

    switch (event.name)
    {
      case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
        return 280; // Plays 280ms before the actual position
    }
    return 0;
  }

  public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
    return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);

  public static function sortNotes(order:Int = FlxSort.ASCENDING, Obj1:Dynamic, Obj2:Dynamic):Int
    return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

  public function makeEvent(event:Array<Dynamic>, i:Int)
  {
    var subEvent:EventNote =
      {
        time: event[0] + ClientPrefs.data.noteOffset,
        name: event[1][i][0],
        params: event[1][i][1],
      };
    eventNotes.push(subEvent);
    eventPushed(subEvent);
    callOnScripts('onEventPushed', [subEvent.name, subEvent.params, subEvent.time]);
    callOnScripts('onEventPushedLegacy', [
      subEvent.name,
      subEvent.params[0] != null ? subEvent.params[0] : "",
      subEvent.params[1] != null ? subEvent.params[1] : "",
      subEvent.params[2] != null ? subEvent.params[2] : "",
      subEvent.params[3] != null ? subEvent.params[3] : "",
      subEvent.params[4] != null ? subEvent.params[4] : "",
      subEvent.params[5] != null ? subEvent.params[5] : "",
      subEvent.params[6] != null ? subEvent.params[6] : "",
      subEvent.params[7] != null ? subEvent.params[7] : "",
      subEvent.params[8] != null ? subEvent.params[8] : "",
      subEvent.params[9] != null ? subEvent.params[9] : "",
      subEvent.params[10] != null ? subEvent.params[10] : "",
      subEvent.params[11] != null ? subEvent.params[11] : "",
      subEvent.params[12] != null ? subEvent.params[12] : "",
      subEvent.params[13] != null ? subEvent.params[13] : "",
      subEvent.time
    ]);
  }

  public var boyfriendCameraOffset:Array<Float> = [0, 0];
  public var opponentCameraOffset:Array<Float> = [0, 0];
  public var opponent2CameraOffset:Array<Float> = [0, 0];
  public var girlfriendCameraOffset:Array<Float> = [0, 0];

  public function setCameraOffsets()
  {
    opponentCameraOffset = [stage?.opponentCameraOffset[0] ?? 0, stage?.opponentCameraOffset[1] ?? 0];
    girlfriendCameraOffset = [stage?.girlfriendCameraOffset[0] ?? 0, stage?.girlfriendCameraOffset[1] ?? 0];
    boyfriendCameraOffset = [stage?.boyfriendCameraOffset[0] ?? 0, stage?.boyfriendCameraOffset[1] ?? 0];
    opponent2CameraOffset = [stage?.opponent2CameraOffset[0] ?? 0, stage?.opponent2CameraOffset[1] ?? 0];
  }

  public var skipArrowStartTween:Bool = false; // for lua and hx
  public var disabledIntro:Bool = false; // for lua and hx

  public dynamic function setupArrowStuff(player:Int, style:String, amount:Int = 4):Void
  {
    switch (player)
    {
      case 0:
        if (opponentMode) bfStrumStyle = style;
        else
          dadStrumStyle = style;
      case 1:
        if (opponentMode) dadStrumStyle = style;
        else
          bfStrumStyle = style;
    }

    for (i in 0...amount)
      generateStaticStrumArrows(player, style, i);
  }

  public dynamic function generateStaticStrumArrows(player:Int, style:String, i:Int):Void
  {
    var strumLineX:Float = ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X;
    var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;

    var TRUE_STRUM_X:Float = strumLineX;

    if (style.contains('pixel')) TRUE_STRUM_X += (ClientPrefs.data.middleScroll ? 3 : 2);

    var babyArrow:StrumArrow = new StrumArrow(TRUE_STRUM_X, strumLineY, i, player, style);
    babyArrow.downScroll = ClientPrefs.data.downScroll;
    babyArrow.texture = style;
    babyArrow.reloadNote(style);
    reloadPixel(babyArrow, style);

    if (!SONG.options.notITG)
    {
      babyArrow.loadLane();
      babyArrow.bgLane.updateHitbox();
      babyArrow.bgLane.scrollFactor.set();
    }
    #if SCEModchartingTools
    else
      babyArrow.loadLineSegment();
    #end

    if (player == 1)
    {
      if (OMANDNOTMS) opponentStrums.add(babyArrow);
      else
        playerStrums.add(babyArrow);
    }
    else
    {
      if (ClientPrefs.data.middleScroll)
      {
        babyArrow.x += 310;

        // Up and Right
        if (i > 1) babyArrow.x += FlxG.width / 2 + 20;
      }

      if (OMANDNOTMS) playerStrums.add(babyArrow);
      else
        opponentStrums.add(babyArrow);
    }

    strumLineNotes.add(babyArrow);
    babyArrow.postAddedToGroup();

    callOnScripts('onSpawnStrum', [strumLineNotes.members.indexOf(babyArrow), babyArrow.player, babyArrow.ID]);
    if (i == 4 && player == 1) arrowsGenerated = true;
  }

  public function reloadPixel(babyArrow:StrumArrow, style:String)
  {
    var isPixel:Bool = (style.contains('pixel') || babyArrow.daStyle.contains('pixel') || babyArrow.texture.contains('pixel'));
    if (isPixel) babyArrow.containsPixelTexture = true;
  }

  public function appearStrumArrows(?tween:Bool = true):Void
  {
    strumLineNotes.forEach(function(babyArrow:StrumArrow) {
      var targetAlpha:Float = 1;

      if (babyArrow.player < 1 && ClientPrefs.data.middleScroll)
      {
        targetAlpha = 0.35;
      }

      if (tween)
      {
        babyArrow.alpha = 0;
        createTween(babyArrow, {alpha: targetAlpha}, 0.85, {ease: FlxEase.circOut, startDelay: 0.02 + (0.2 * babyArrow.ID)});
      }
      else
        babyArrow.alpha = disabledIntro ? 0 : targetAlpha;

      if (!SONG.options.notITG && babyArrow.bgLane != null) arrowLanes.add(babyArrow.bgLane);
      #if SCEModchartingTools
      else if (babyArrow.lineSegment != null) arrowPaths.add(babyArrow.lineSegment);
      #end
    });
    arrowsAppeared = true;
  }

  override function openSubState(SubState:FlxSubState)
  {
    if (stage != null) stage.onOpenSubState(SubState);
    if (paused)
    {
      #if (VIDEOS_ALLOWED && hxvlc)
      if (daVideoGroup != null)
      {
        for (vid in daVideoGroup.members)
        {
          if (vid.videoSprite.alive) vid.videoSprite.bitmap.pause();
        }
      }
      #end

      if (FlxG.sound.music != null && !alreadyEndedSong)
      {
        FlxG.sound.music.pause();
        if (vocals != null) vocals.pause();
        if (opponentVocals != null && splitVocals) opponentVocals.pause();
      }

      FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished) tmr.active = false);
      FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished) twn.active = false);

      #if VIDEOS_ALLOWED
      for (vid in VideoSprite._videos)
      {
        if (vid.isPlaying) vid.pause();
      }
      #end
    }

    super.openSubState(SubState);
  }

  public var canResync:Bool = true;

  override function closeSubState()
  {
    super.closeSubState();

    if (stage != null) stage.onCloseSubState();

    if (paused)
    {
      canResync = true;
      FlxG.timeScale = playbackRate;
      #if (VIDEOS_ALLOWED && hxvlc)
      if (daVideoGroup != null)
      {
        for (vid in daVideoGroup)
        {
          if (vid.videoSprite.alive) vid.videoSprite.bitmap.resume();
        }
      }
      #end

      if (FlxG.sound.music != null && !startingSong && canResync) resyncVocals(splitVocals);

      FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished) tmr.active = true);
      FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished) twn.active = true);

      #if VIDEOS_ALLOWED
      for (vid in VideoSprite._videos)
      {
        if (vid.isPlaying) vid.resume();
      }
      #end

      paused = false;
      callOnScripts('onResume');
      resetRPC(startTimer != null && startTimer.finished);
    }
  }

  override public function onFocus():Void
  {
    callOnScripts('onFocus');
    if (health > 0 && !paused) resetRPC(Conductor.songPosition > 0.0);
    super.onFocus();
    callOnScripts('onFocusPost');
  }

  override public function onFocusLost():Void
  {
    callOnScripts('onFocusLost');
    #if DISCORD_ALLOWED
    if (health > 0 && !paused && autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.songId + " (" + storyDifficultyText + ")",
      iconP2.getCharacter());
    #end
    super.onFocusLost();
    callOnScripts('onFocusLostPost');
  }

  // Updating Discord Rich Presence.
  public var autoUpdateRPC:Bool = true; // performance setting for custom RPC things

  function resetRPC(?showTime:Bool = false)
  {
    #if DISCORD_ALLOWED
    if (!autoUpdateRPC) return;

    if (showTime) DiscordClient.changePresence(detailsText, SONG.songId
      + " ("
      + storyDifficultyText
      + ")", iconP2.getCharacter(), true,
      songLength
      - Conductor.songPosition
      - ClientPrefs.data.noteOffset);
    else
      DiscordClient.changePresence(detailsText, SONG.songId + " (" + storyDifficultyText + ")", iconP2.getCharacter());
    #end
  }

  public function resyncVocals(split:Bool = false):Void
  {
    if (finishTimer != null || alreadyEndedSong) return;

    FlxG.sound.music.play();
    #if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
    Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

    var checkVocals = split ? [vocals, opponentVocals] : [vocals];
    for (voc in checkVocals)
    {
      if (voc != null)
      {
        if (FlxG.sound.music.time < voc.length)
        {
          voc.time = FlxG.sound.music.time;
          #if FLX_PITCH voc.pitch = playbackRate; #end
          voc.play();
        }
        else
          voc.pause();
      }
    }
  }

  var vidIndex:Int = 0;

  public function backgroundOverlayVideo(vidSource:String, type:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false,
      playOnLoad:Bool = true, layInFront:Bool = false)
  {
    #if (VIDEOS_ALLOWED && hxvlc)
    switch (type)
    {
      default:
        var foundFile:Bool = false;
        var fileName:String = Paths.video(vidSource, type);
        #if sys
        if (FileSystem.exists(fileName))
        #else
        if (OpenFlAssets.exists(fileName))
        #end
        foundFile = true;

        if (foundFile)
        {
          var cutscene:VideoSprite = new VideoSprite(fileName, forMidSong, canSkip, loop);

          if (!layInFront)
          {
            cutscene.videoSprite.scrollFactor.set(0, 0);
            cutscene.videoSprite.camera = camGame;
            cutscene.videoSprite.scale.set((6 / 5) + (defaultCamZoom / 8), (6 / 5) + (defaultCamZoom / 8));
          }
          else
          {
            cutscene.videoSprite.camera = camVideo;
            cutscene.videoSprite.scrollFactor.set();
            cutscene.videoSprite.scale.set((6 / 5), (6 / 5));
          }

          cutscene.videoSprite.updateHitbox();
          cutscene.videoSprite.visible = false;

          reserveVids.push(cutscene);
          if (!layInFront)
          {
            remove(daVideoGroup);
            if (ClientPrefs.data.characters)
            {
              if (gf != null) remove(gf);
              remove(dad);
              if (mom != null) remove(mom);
              remove(boyfriend);
            }
            for (cutscene in reserveVids)
              daVideoGroup.add(cutscene);
            add(daVideoGroup);
            if (ClientPrefs.data.characters)
            {
              if (gf != null) add(gf);
              add(boyfriend);
              add(dad);
              if (mom != null) add(mom);
            }
          }
          else
          {
            for (cutscene in reserveVids)
            {
              cutscene.videoSprite.camera = camVideo;
              daVideoGroup.add(cutscene);
            }
          }

          reserveVids = [];

          cutscene.videoSprite.bitmap.rate = playbackRate;
          daVideoGroup.members[vidIndex].videoSprite.visible = true;
          vidIndex++;
        }
    }
    #end
  }

  public var paused:Bool = false;
  public var canReset:Bool = true;
  public var startedCountdown:Bool = false;
  public var canPause:Bool = false;
  public var freezeCamera:Bool = false;
  public var allowDebugKeys:Bool = true;

  public var cameraTargeted:String;
  public var camMustHit:Bool;

  public var charCam:Character = null;
  public var isDadCam:Bool = false;
  public var isGfCam:Bool = false;
  public var isMomCam:Bool = false;

  public var isCameraFocusedOnCharacters:Bool = false;

  public var forceChangeOnTarget:Bool = false;

  public var isMustHitSection:Bool = false;
  public var iconOffset:Int = 26;

  public function changeHealth(by:Float):Float
  {
    health += by;
    return health;
  }

  private var allowedEnter:Bool = false;

  public var totalElapsed:Float = 0;

  override public function update(elapsed:Float)
  {
    if (alreadyEndedSong)
    {
      if (endCallback != null) endCallback();
      else
        MusicBeatState.switchState(new FreeplayState());
      super.update(elapsed);
      return;
    }

    if (paused)
    {
      callOnScripts('onUpdate', [elapsed]);
      callOnScripts('update', [elapsed]);

      super.update(elapsed);

      callOnScripts('onUpdatePost', [elapsed]);
      callOnScripts('updatePost', [elapsed]);
      return;
    }

    for (holdCovers in [opponentHoldCovers, playerHoldCovers])
    {
      if (holdCovers != null)
      {
        if (!holdCovers.isReady) if (strumLineNotes != null && strumLineNotes.members.length > 0 && !startingSong && !inCutscene && !inCinematic
          && generatedMusic) holdCovers.isReady = true;
        else if (holdCovers.isReady) if (((strumLineNotes == null && strumLineNotes.members.length <= 0)
          || startingSong
          || inCutscene
          || inCinematic)
          && !generatedMusic) holdCovers.isReady = false;
      }
    }

    totalElapsed += elapsed;

    #if SCEModchartingTools
    // LMAO IT LOOKS SOO GOOFY AS FUCK
    if (playfieldRenderer != null && notITGMod && SONG.options.notITG)
    {
      playfieldRenderer.speed = playbackRate;
      playfieldRenderer.updateToCurrentElapsed(totalElapsed);
    }
    #end

    for (value in MusicBeatState.getVariables().keys())
    {
      if (MusicBeatState.getVariables().get(value) != null && MusicBeatState.getVariables().exists(value))
      {
        if (value.startsWith('extraCharacter_'))
        {
          var daChar:Character = cast(MusicBeatState.getVariables().get(value), Character);
          if (daChar != null)
          {
            if ((daChar.isPlayer && !daChar.flipMode || !daChar.isPlayer && daChar.flipMode))
            {
              if (daChar.getLastAnimationPlayed().startsWith('sing')) daChar.holdTimer += elapsed;
              else
                daChar.holdTimer = 0;
            }
          }
        }
      }
    }

    // Some Extra VERS to help
    setOnScripts('songPos', Conductor.songPosition);
    setOnScripts('hudZoom', camHUD.zoom);
    setOnScripts('cameraZoom', FlxG.camera.zoom);

    callOnScripts('onUpdate', [elapsed]);
    callOnScripts('update', [elapsed]);

    if (stage != null) stage.onUpdate(elapsed);

    for (shaderKeys in FunkinLua.lua_Shaders.keys())
    {
      if (FunkinLua.lua_Shaders.exists(shaderKeys))
      {
        if (FunkinLua.lua_Shaders.get(shaderKeys).canUpdate()) FunkinLua.lua_Shaders.get(shaderKeys).update(elapsed);
      }
    }

    if (showCaseMode)
    {
      for (i in [
        iconP1, iconP2, healthBar, healthBarNew, healthBarBG, timeBar, timeBarBG, timeTxt, timeBarNew, scoreTxt, scoreTxtSprite, kadeEngineWatermark,
        healthBarHit, healthBarHitBG, healthBarHitNew, healthBarOverlay, judgementCounter
      ])
      {
        i.visible = false;
        i.alpha = 0;
      }

      for (value in MusicBeatState.getVariables().keys())
      {
        if (MusicBeatState.getVariables().get(value) != null && MusicBeatState.getVariables().exists(value))
        {
          if (value.startsWith('extraIcon_'))
          {
            cast(MusicBeatState.getVariables().get(value), HealthIcon).visible = false;
            cast(MusicBeatState.getVariables().get(value), HealthIcon).alpha = 0;
          }
        }
      }
    }
    else
    {
      if (botplayTxt != null && botplayTxt.visible && !useSLEHUD)
      {
        botplaySine += 180 * elapsed;
        botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
      }
    }

    if (!inCutscene && !paused && !freezeCamera)
    {
      FlxG.camera.followLerp = 0.04 * cameraSpeed * playbackRate;
      if (!startingSong && !endingSong && !boyfriend.isAnimationNull() && boyfriend.getLastAnimationPlayed().startsWith('idle'))
      {
        boyfriendIdleTime += elapsed;
        if (boyfriendIdleTime >= 0.15)
        { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
          boyfriendIdled = true;
        }
      }
      else
        boyfriendIdleTime = 0;
    }
    else
      FlxG.camera.followLerp = 0;

    if (!paused)
    {
      tweenManager.update(elapsed);
      timerManager.update(elapsed);
    }

    setOnScripts('curDecStep', curDecStep);
    setOnScripts('curDecBeat', curDecBeat);

    if ((controls.PAUSE || ClientPrefs.data.autoPause && !Main.focused) && startedCountdown && canPause)
    {
      var ret:Dynamic = callOnScripts('onPause', null, true);
      if (ret != LuaUtils.Function_Stop) openPauseMenu();
    }

    if (SONG.options.oldBarSystem) health = (healthSet ? 1 : (health > maxHealth ? maxHealth : health));
    else
      health = (healthSet ? 1 : (healthBarNew.bounds.max != null ? (health > healthBarNew.bounds.max ? healthBarNew.bounds.max : health) : (health > maxHealth ? maxHealth : health)));

    healthLerp = FlxMath.lerp(healthLerp, health, 0.15 / (ClientPrefs.data.framerate / 60));

    if (whichHud == 'HITMANS')
    {
      if (!iconP1.overrideIconPlacement) iconP1.x = FlxG.width - 160;
      if (!iconP2.overrideIconPlacement) iconP2.x = 0;
    }
    else
    {
      var healthPercent = SONG.options.oldBarSystem ? FlxMath.remapToRange(opponentMode ? 100 - healthBar.percent : healthBar.percent, 0, 100, 100,
        0) : FlxMath.remapToRange(opponentMode ? 100 - healthBarNew.percent : healthBarNew.percent, 0, 100, 100, 0);
      var addedIconX = SONG.options.oldBarSystem ? healthBar.x + (healthBar.width * (healthPercent * 0.01)) : healthBarNew.x
        + (healthBarNew.width * (healthPercent * 0.01));

      if (!iconP1.overrideIconPlacement) iconP1.x = addedIconX + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
      if (!iconP2.overrideIconPlacement) iconP2.x = addedIconX - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
    }

    if (health <= 0) health = 0;
    else if (health >= 2) health = 2;

    updateIcons();

    if (!endingSong && !inCutscene && allowedEnter && allowDebugKeys && songStarted)
    {
      if (controls.justPressed('debug_1')) openChartEditor(true);
      if (controls.justPressed('debug_2')) openCharacterEditor(true);
      #if SCEModchartingTools
      if (controls.justPressed('debug_3')) openModchartEditor(true);
      #end
    }

    // Update the conductor.
    if (startedCountdown && !paused)
    {
      Conductor.songPosition += elapsed * 1000;
      if (Conductor.songPosition >= Conductor.offset)
      {
        Conductor.songPosition = FlxMath.lerp(FlxG.sound.music.time + Conductor.offset, Conductor.songPosition, Math.exp(-elapsed * 5));
        var timeDiff:Float = Math.abs((FlxG.sound.music.time + Conductor.offset) - Conductor.songPosition);
        if (timeDiff > 1000 * playbackRate) Conductor.songPosition = Conductor.songPosition + 1000 * FlxMath.signOf(timeDiff);

        if (timeDiff > 25 * playbackRate) Debug.logWarn('Warning! Delay is too fucking high!!');

        #if debug
        if (FlxG.keys.justPressed.K)
        {
          Debug.logInfo('Times: ' + FlxG.sound.music.time + '' + vocals.time + '' + opponentVocals.time);
          Debug.logInfo('Difference: ' + (FlxG.sound.music.time - Conductor.songPosition));
        }

        var daScale = Math.max(-144, Math.min(144, FlxG.sound.music.time - Conductor.songPosition) * (144 / 25));
        delayBar.scale.x = Math.abs(daScale);
        delayBar.updateHitbox();
        if (daScale < 0) delayBar.x = 640 - delayBar.scale.x;
        else
          delayBar.x = 640;

        var timeDiff:Int = Math.round(FlxG.sound.music.time - Conductor.songPosition);
        delayBarTxt.text = '$timeDiff ms';
        if (Math.abs(timeDiff) > 15) delayBar.color = FlxColor.RED;
        else
          delayBar.color = FlxColor.WHITE;
        #end
      }
    }

    if (startingSong)
    {
      if (startedCountdown && Conductor.songPosition >= Conductor.offset) startSong();
      else if (!startedCountdown) Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
    }
    else if (!paused)
    {
      if (updateTime)
      {
        var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
        songPercent = (curTime / songLength);

        var songCalc:Float = (songLength - curTime) / playbackRate; // time fix

        if (ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime; // amount of time passed is ok

        var secondsTotal:Int = Math.floor(songCalc / 1000);
        if (secondsTotal < 0) secondsTotal = 0;

        if (ClientPrefs.data.timeBarType != 'Song Name') timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
        else
        { // this is what was fucked up, hopefully this fixes it.
          var secondsTotal:Int = Math.floor(songCalc / 1000);
          if (secondsTotal < 0) secondsTotal = 0;
          timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
        }
      }
    }

    try
    {
      moveCameraToTarget(cameraTargeted);
    }
    catch (e)
    {
      moveCameraToTarget(null);
      cameraTargeted = null;
    }

    if (generatedMusic && storyDifficulty < 3)
    {
      // Make sure Girlfriend cheers only for certain songs
      if (allowedToCheer)
      {
        // Don't animate GF if something else is already animating her (eg. train passing)
        if (gf != null) if (gf.getLastAnimationPlayed() == 'danceLeft'
          || gf.getLastAnimationPlayed() == 'danceRight'
          || gf.getLastAnimationPlayed() == 'idle')
        {
          // Per song treatment since some songs will only have the 'Hey' at certain times
          switch (songName)
          {
            case 'philly-nice':
              {
                // General duration of the song
                if (curStep < 1000)
                {
                  // Beats to skip or to stop GF from cheering
                  if (curStep != 736 && curStep != 864)
                  {
                    if (curStep % 64 == 32)
                    {
                      // Just a garantee that it'll trigger just once
                      if (!triggeredAlready)
                      {
                        gf.playAnim('cheer');
                        if (!gf.skipHeyTimer)
                        {
                          gf.specialAnim = true;
                          gf.heyTimer = 0.6;
                        }
                        triggeredAlready = true;
                      }
                    }
                    else
                      triggeredAlready = false;
                  }
                }
              }
            case 'bopeebo':
              {
                // Where it starts || where it ends
                if (curStep > 20 && curStep < 520)
                {
                  if (curStep % 32 == 28)
                  {
                    if (!triggeredAlready)
                    {
                      gf.playAnim('cheer');
                      if (!gf.skipHeyTimer)
                      {
                        gf.specialAnim = true;
                        gf.heyTimer = 0.6;
                      }
                      triggeredAlready = true;
                    }
                  }
                  else
                    triggeredAlready = false;
                }
              }
            case 'blammed':
              {
                if (curStep > 120 && curStep < 760)
                {
                  if (curStep < 360 || curStep > 512)
                  {
                    if (curStep % 16 == 8)
                    {
                      if (!triggeredAlready)
                      {
                        gf.playAnim('cheer');
                        if (!gf.skipHeyTimer)
                        {
                          gf.specialAnim = true;
                          gf.heyTimer = 0.6;
                        }
                        triggeredAlready = true;
                      }
                    }
                    else
                      triggeredAlready = false;
                  }
                }
              }
            case 'cocoa':
              {
                if (curStep < 680)
                {
                  if (curStep < 260 || curStep > 520 && curStep < 580)
                  {
                    if (curStep % 64 == 60)
                    {
                      if (!triggeredAlready)
                      {
                        gf.playAnim('cheer');
                        if (!gf.skipHeyTimer)
                        {
                          gf.specialAnim = true;
                          gf.heyTimer = 0.6;
                        }
                        triggeredAlready = true;
                      }
                    }
                    else
                      triggeredAlready = false;
                  }
                }
              }
            case 'eggnog':
              {
                if (curStep > 40 && curStep != 444 && curStep < 880)
                {
                  if (curStep % 32 == 28)
                  {
                    if (!triggeredAlready)
                    {
                      gf.playAnim('cheer');
                      if (!gf.skipHeyTimer)
                      {
                        gf.specialAnim = true;
                        gf.heyTimer = 0.6;
                      }
                      triggeredAlready = true;
                    }
                  }
                  else
                    triggeredAlready = false;
                }
              }
          }
        }
      }
    }

    if (camZooming && songStarted)
    {
      FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * 1));
      camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * 1));
      camNoteStuff.zoom = !usesHUD ? camHUD.zoom : 1;

      camSLEHUD.zoom = camHUD.zoom;
      camWaterMark.zoom = camHUD.zoom;
    }

    FlxG.watch.addQuick("secShit", curSection);
    FlxG.watch.addQuick("beatShit", curBeat);
    FlxG.watch.addQuick("stepShit", curStep);

    if (inCutscene || inCinematic) canPause = false;

    // RESET = Quick Game Over Screen
    if (!ClientPrefs.data.noReset
      && controls.RESET
      && canReset
      && !inCutscene
      && !inCinematic
      && startedCountdown
      && !endingSong)
    {
      health = 0;
      Debug.logTrace("RESET = True");
    }
    doDeathCheck();

    if (unspawnNotes[0] != null)
    {
      var time:Float = unspawnNotes[0].spawnTime * playbackRate;
      if (unspawnNotes[0].noteScrollSpeed < 1) time /= unspawnNotes[0].noteScrollSpeed;
      if (unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

      while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
      {
        var dunceNote:Note = unspawnNotes[0];
        notes.insert(0, dunceNote);
        dunceNote.spawned = true;

        callOnLuas('onSpawnNote', [
          notes.members.indexOf(dunceNote),
          dunceNote.noteData,
          dunceNote.noteType,
          dunceNote.isSustainNote,
          dunceNote.strumTime
        ]);
        callOnAllHS('onSpawnNote', [dunceNote]);

        var index:Int = unspawnNotes.indexOf(dunceNote);
        unspawnNotes.splice(index, 1);

        callOnLuas('onSpawnNotePost', [
          notes.members.indexOf(dunceNote),
          dunceNote.noteData,
          dunceNote.noteType,
          dunceNote.isSustainNote,
          dunceNote.strumTime
        ]);
        callOnAllHS('onSpawnNotePost', [dunceNote]);
      }
    }

    if (generatedMusic)
    {
      if (!inCutscene && !inCinematic)
      {
        notes.update(elapsed);

        if (!cpuControlled) keysCheck();
        else
          charactersDance();

        if (opponentMode) charactersDance(true);

        if (notes.length != 0)
        {
          if (startedCountdown)
          {
            var fakeCrochet:Float = (60 / SONG.bpm) * 1000;

            notes.forEachAlive(function(daNote:Note) {
              var strumGroup:Strumline = playerStrums;
              if (!daNote.mustPress) strumGroup = opponentStrums;

              var strum:StrumArrow = strumGroup.members[daNote.noteData];
              if (daNote.allowStrumFollow) daNote.followStrumArrow(strum, fakeCrochet, daNote.noteScrollSpeed / playbackRate);

              if (!isPixelNotes && daNote.noteSkin.contains('pixel')) isPixelNotes = true;
              else if (isPixelNotes && !daNote.noteSkin.contains('pixel')) isPixelNotes = false;

              if (daNote.allowNotesToHit)
              {
                if (daNote.mustPress)
                {
                  if (cpuControlled
                    && !daNote.blockHit
                    && daNote.canBeHit
                    && ((daNote.isSustainNote && daNote.prevNote.wasGoodHit)
                      || daNote.strumTime <= Conductor.songPosition)) goodNoteHit(daNote);
                }
                else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote) opponentNoteHit(daNote);

                if (daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumArrow(strum);
              }

              // Kill extremely late notes and cause misses

              if (Conductor.songPosition - daNote.strumTime > noteKillOffset)
              {
                if (ClientPrefs.data.vanillaStrumAnimations)
                {
                  if (!daNote.mustPress)
                  {
                    if ((daNote.isSustainNote && daNote.isHoldEnd) || !daNote.isSustainNote) strum.playAnim('static', true);
                  }
                  else
                  {
                    if (daNote.isSustainNote && daNote.isHoldEnd) strum.playAnim('static', true);
                  }
                }

                if (daNote.allowDeleteAndMiss)
                {
                  if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) noteMiss(daNote);
                  invalidateNote(daNote, false);
                }
              }
            });
          }
          else
          {
            notes.forEachAlive(function(daNote:Note) {
              daNote.canBeHit = false;
              daNote.wasGoodHit = false;
            });
          }
        }
      }
      checkEventNote();
    }

    if (playerHoldCovers != null) playerHoldCovers.updateHold(elapsed);
    if (opponentHoldCovers != null) opponentHoldCovers.updateHold(elapsed);

    #if debug
    if (!endingSong && !startingSong)
    {
      if (FlxG.keys.justPressed.ONE)
      {
        KillNotes();
        FlxG.sound.music.onComplete();
      }
      if (FlxG.keys.justPressed.TWO)
      { // Go 10 seconds into the future :O
        setSongTime(Conductor.songPosition + 10000);
        clearNotesBefore(Conductor.songPosition);
      }
    }
    #end

    setOnScripts('cameraX', camFollow.x);
    setOnScripts('cameraY', camFollow.y);
    setOnScripts('botPlay', cpuControlled);
    callOnScripts('onUpdatePost', [elapsed]);
    callOnScripts('updatePost', [elapsed]);

    if (quantSetup)
    {
      if (ClientPrefs.data.quantNotes && !SONG.options.disableStrumRGB)
      {
        var group:Strumline = OMANDNOTMSANDNOTITG ? opponentStrums : playerStrums;
        for (this2 in group)
        {
          if (this2.animation.curAnim.name == 'static')
          {
            this2.rgbShader.r = 0xFFFFFFFF;
            this2.rgbShader.b = 0xFF808080;
          }
        }
      }
    }

    super.update(elapsed);
  }

  public dynamic function moveCameraToTarget(setTarget:String)
  {
    cameraTargeted = setTarget;
    if (SONG.notes[curSection] != null)
    {
      if (SONG.notes[curSection].mustHitSection) isMustHitSection = true;
      else
        isMustHitSection = false;
    }
    if (generatedMusic && !endingSong && !isCameraOnForcedPos && isCameraFocusedOnCharacters)
    {
      if (!forceChangeOnTarget)
      {
        if (SONG.notes[curSection] != null)
        {
          if (!SONG.notes[curSection].mustHitSection) cameraTargeted = 'dad';
          if (SONG.notes[curSection].mustHitSection) cameraTargeted = 'bf';
          if (SONG.notes[curSection].gfSection) cameraTargeted = 'gf';
          if (SONG.notes[curSection].player4Section) cameraTargeted = 'mom';
        }
      }

      switch (cameraTargeted)
      {
        case 'dad':
          if (dad != null)
          {
            camMustHit = false;
            charCam = dad;
            isDadCam = true;

            var offsetX = 0;
            var offsetY = 0;

            camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);

            camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
            camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];

            camFollow.x += dadcamX;
            camFollow.y += dadcamY;

            if (dad.getLastAnimationPlayed().toLowerCase().startsWith('idle')
              || dad.getLastAnimationPlayed().toLowerCase().endsWith('right')
              || dad.getLastAnimationPlayed().toLowerCase().endsWith('left'))
            {
              dadcamY = 0;
              dadcamX = 0;
            }

            callOnScripts('playerTwoTurn', []);
          }
        case 'gf' | 'girlfriend':
          if (gf != null)
          {
            charCam = gf;
            isGfCam = true;

            var offsetX = 0;
            var offsetY = 0;

            camFollow.setPosition(gf.getMidpoint().x + offsetX, gf.getMidpoint().y + offsetY);

            camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
            camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];

            camFollow.x += gfcamX;
            camFollow.y += gfcamY;

            if (gf.getLastAnimationPlayed().toLowerCase().startsWith('idle')
              || gf.getLastAnimationPlayed().toLowerCase().endsWith('right')
              || gf.getLastAnimationPlayed().toLowerCase().endsWith('left'))
            {
              gfcamY = 0;
              gfcamX = 0;
            }

            callOnScripts('playerThreeTurn', []);
          }
        case 'boyfriend' | 'bf':
          if (boyfriend != null)
          {
            camMustHit = true;
            charCam = boyfriend;
            isDadCam = false;

            var offsetX = 0;
            var offsetY = 0;

            camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

            camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
            camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

            camFollow.x += bfcamX;
            camFollow.y += bfcamY;

            if (boyfriend.getLastAnimationPlayed().toLowerCase().startsWith('idle')
              || boyfriend.getLastAnimationPlayed().toLowerCase().endsWith('right')
              || boyfriend.getLastAnimationPlayed().toLowerCase().endsWith('left'))
            {
              bfcamY = 0;
              bfcamX = 0;
            }

            callOnScripts('playerOneTurn', []);
          }
        case 'mom':
          if (mom != null)
          {
            camMustHit = false;
            charCam = mom;
            isMomCam = true;

            var offsetX = 0;
            var offsetY = 0;

            camFollow.setPosition(mom.getMidpoint().x + 150 + offsetX, mom.getMidpoint().y - 100 + offsetY);

            camFollow.x += mom.cameraPosition[0] + opponent2CameraOffset[0];
            camFollow.y += mom.cameraPosition[1] + opponent2CameraOffset[1];

            camFollow.x += momcamX;
            camFollow.y += momcamY;

            if (mom.getLastAnimationPlayed().toLowerCase().startsWith('idle')
              || mom.getLastAnimationPlayed().toLowerCase().endsWith('right')
              || mom.getLastAnimationPlayed().toLowerCase().endsWith('left'))
            {
              momcamY = 0;
              momcamX = 0;
            }

            callOnScripts('playerFourTurn', []);
          }
      }

      if (charCam != null)
      {
        var characterCam:String = '';
        if (charCam == boyfriend) characterCam = 'player';
        else if (charCam == dad) characterCam = 'opponent';
        else if (charCam == gf) characterCam = 'girlfriend';
        var camArray:Array<Float> = stage.cameraCharacters.get(characterCam);

        if (ClientPrefs.data.cameraMovement && !charCam.charNotPlaying && ClientPrefs.data.characters) moveCameraXY(charCam, -1, camArray[0], camArray[1]);

        callOnScripts('onMoveCamera', [cameraTargeted]);
      }
    }
  }

  public dynamic function updateIcons()
  {
    var icons:Array<HealthIcon> = [iconP1, iconP2];

    var percent20or80:Bool = false;
    var percent80or20:Bool = false;

    if (SONG.options.oldBarSystem)
    {
      percent20or80 = !opponentMode ? (whichHud == "HITMANS" ? healthBarHit.percent < 20 : healthBar.percent < 20) : (whichHud == "HITMANS" ? healthBarHit.percent > 80 : healthBar.percent > 80);
      percent80or20 = !opponentMode ? (whichHud == "HITMANS" ? healthBarHit.percent > 80 : healthBar.percent > 80) : (whichHud == "HITMANS" ? healthBarHit.percent < 20 : healthBar.percent < 20);
    }
    else
    {
      percent20or80 = !opponentMode ? (whichHud == "HITMANS" ? healthBarHitNew.percent < 20 : healthBarNew.percent < 20) : (whichHud == "HITMANS" ? healthBarHitNew.percent > 80 : healthBarNew.percent > 80);
      percent80or20 = !opponentMode ? (whichHud == "HITMANS" ? healthBarHitNew.percent > 80 : healthBarNew.percent > 80) : (whichHud == "HITMANS" ? healthBarHitNew.percent < 20 : healthBarNew.percent < 20);
    }

    for (i in 0...icons.length)
    {
      icons[i].percent20or80 = percent20or80;
      icons[i].percent80or20 = percent80or20;
      icons[i].healthIndication = health;
      icons[i].speedBopLerp = playbackRate;
    }

    icons[0].setIconScale = playerIconScale;
    icons[1].setIconScale = opponentIconScale;

    for (value in MusicBeatState.getVariables().keys())
    {
      if (MusicBeatState.getVariables().get(value) != null && MusicBeatState.getVariables().exists(value))
      {
        if (value.startsWith('extraIcon_'))
        {
          cast(MusicBeatState.getVariables().get(value), HealthIcon).percent20or80 = percent20or80;
          cast(MusicBeatState.getVariables().get(value), HealthIcon).percent80or20 = percent80or20;

          cast(MusicBeatState.getVariables().get(value), HealthIcon).healthIndication = health;
          cast(MusicBeatState.getVariables().get(value), HealthIcon).speedBopLerp = playbackRate;
        }
      }
    }
  }

  public dynamic function changeOpponentVocalTrack(?prefix:String = null, ?suffix:String = null, ?song:String = null)
  {
    var songData = SONG;
    var newSong:String = song;

    try
    {
      if (songData.needsVoices)
      {
        if (newSong != null)
        {
          final vocalOpp:String = (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile;
          final currentPrefix:String = prefix != null ? prefix : '';
          final currentSuffix:String = suffix != null ? suffix : '';
          final oppVocals = SoundUtil.findVocal(
            {
              song: songData.song,
              prefix: currentPrefix,
              suffix: currentSuffix,
              externVocal: vocalOpp,
              character: dad.curCharacter,
              difficulty: Difficulty.getString()
            });
          if (oppVocals != null)
          {
            opponentVocals.loadEmbedded(oppVocals);
            splitVocals = true;
          }
        }
        else
        {
          final vocalOpp:String = (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile;
          final currentPrefix:String = songData.options.vocalsPrefix != null ? songData.options.vocalsPrefix : '';
          final currentSuffix:String = songData.options.vocalsSuffix != null ? songData.options.vocalsSuffix : '';
          final oppVocals = SoundUtil.findVocal(
            {
              song: songData.song,
              prefix: currentPrefix,
              suffix: currentSuffix,
              externVocal: vocalOpp,
              character: dad.curCharacter,
              difficulty: Difficulty.getString()
            });

          if (oppVocals != null)
          {
            opponentVocals.loadEmbedded(oppVocals);
            splitVocals = true;
          }
        }
      }
    }
    catch (e:Dynamic) {}

    if (splitVocals) opponentVocals.play();
  }

  public dynamic function changeVocalTrack(?prefix:String = null, ?suffix:String = null, ?song:String = null)
  {
    var songData = SONG;
    var newSong:String = song;

    try
    {
      if (songData.needsVoices)
      {
        if (newSong != null)
        {
          final vocalPl:String = (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile;
          final currentPrefix:String = prefix != null ? prefix : '';
          final currentSuffix:String = suffix != null ? suffix : '';
          final normalVocals = Paths.voices(currentPrefix, newSong, currentSuffix);
          var playerVocals = SoundUtil.findVocal(
            {
              song: songData.song,
              prefix: currentPrefix,
              suffix: currentSuffix,
              externVocal: vocalPl,
              character: boyfriend.curCharacter,
              difficulty: Difficulty.getString()
            });
          vocals.loadEmbedded(playerVocals != null ? playerVocals : normalVocals);
        }
        else
        {
          final vocalPl:String = (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile;
          final currentPrefix:String = songData.options.vocalsPrefix != null ? songData.options.vocalsPrefix : '';
          final currentSuffix:String = songData.options.vocalsSuffix != null ? songData.options.vocalsSuffix : '';
          final normalVocals = Paths.voices(currentPrefix, songData.song, currentSuffix);
          var playerVocals = SoundUtil.findVocal(
            {
              song: songData.song,
              prefix: currentPrefix,
              suffix: currentSuffix,
              externVocal: vocalPl,
              character: boyfriend.curCharacter,
              difficulty: Difficulty.getString()
            });
          vocals.loadEmbedded(playerVocals != null ? playerVocals : normalVocals);
        }
      }
    }
    catch (e:Dynamic) {}

    vocals.play();
  }

  public dynamic function changeMusicTrack(?prefix:String = null, ?suffix:String = null, ?song:String = null)
  {
    var songData = SONG;
    var addedOnPrefix:String = (prefix != null ? prefix : "");
    var addedOnSuffix:String = (suffix != null ? suffix : "");
    var newSong:String = song;

    try
    {
      if (newSong != null) inst.loadEmbedded(Paths.inst(addedOnPrefix, SONG.songId, addedOnSuffix));
      else
      {
        inst.loadEmbedded(Paths.inst((songData.options.instrumentalPrefix != null ? songData.options.instrumentalPrefix : ""), songData.songId,
          (songData.options.instrumentalSuffix != null ? songData.options.instrumentalSuffix : "")));
      }
    }
    catch (e:Dynamic) {}

    @:privateAccess
    FlxG.sound.playMusic(inst._sound, 1, false);
  }

  function openPauseMenu()
  {
    FlxG.camera.followLerp = 0;
    persistentUpdate = false;
    persistentDraw = true;
    paused = true;

    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.pause();
      if (vocals != null) vocals.pause();
      if (opponentVocals != null && splitVocals) opponentVocals.pause();
    }

    if (!cpuControlled)
    {
      var group:Strumline = OMANDNOTMSANDNOTITG ? opponentStrums : playerStrums;
      for (note in group)
        if (note.animation.curAnim != null && note.animation.curAnim.name != 'static')
        {
          note.playAnim('static');
          note.resetAnim = 0;
        }
    }

    var pauseSubState = new PauseSubState();
    openSubState(pauseSubState);
    pauseSubState.camera = camPause;

    #if DISCORD_ALLOWED
    if (autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.songId + " (" + storyDifficultyText + ")", iconP2.getCharacter());
    #end
  }

  public function openChartEditor(openedOnce:Bool = false)
  {
    if (modchartMode) return false;
    else
    {
      canResync = false;
      FlxG.timeScale = 1;
      FlxG.camera.followLerp = 0;
      chartingMode = true;
      modchartMode = false;
      if (persistentUpdate != false) persistentUpdate = false;
      if (FlxG.sound.music != null)
      {
        FlxG.sound.music.volume = 0;
        FlxG.sound.music.stop();
        if (vocals != null)
        {
          vocals.volume = 0;
          vocals.stop();
        }
        if (opponentVocals != null)
        {
          opponentVocals.volume = 0;
          opponentVocals.stop();
        }
      }

      #if DISCORD_ALLOWED
      DiscordClient.changePresence("Chart Editor", null, null, true);
      DiscordClient.resetClientID();
      #end

      if (notITGMod && SONG.options.notITG)
      {
        Note.notITGNotes = false;
        StrumArrow.notITGStrums = false;
      }

      MusicBeatState.switchState(new ChartingState());
      return true;
    }
  }

  public function openCharacterEditor(openedOnce:Bool = false)
  {
    canResync = false;
    FlxG.timeScale = 1;
    FlxG.camera.followLerp = 0;
    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.volume = 0;
      FlxG.sound.music.stop();
      if (vocals != null)
      {
        vocals.volume = 0;
        vocals.stop();
      }
      if (opponentVocals != null && splitVocals)
      {
        opponentVocals.volume = 0;
        opponentVocals.stop();
      }
    }
    #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
    MusicBeatState.switchState(new CharacterEditorState(SONG.characters.opponent));
    return true;
  }

  #if SCEModchartingTools
  public function openModchartEditor(openedOnce:Bool = false)
  {
    if (chartingMode || !SONG.options.notITG && !notITGMod) return false;
    else
    {
      canResync = false;
      FlxG.timeScale = 1;
      FlxG.camera.followLerp = 0;
      modchartMode = true;
      chartingMode = false;
      if (persistentUpdate != false) persistentUpdate = false;
      if (FlxG.sound.music != null)
      {
        FlxG.sound.music.volume = 0;
        FlxG.sound.music.stop();
        vocals.volume = 0;
        vocals.stop();
        opponentVocals.volume = 0;
        opponentVocals.stop();
      }
      #if DISCORD_ALLOWED
      DiscordClient.changePresence("Modchart Editor", null, null, true);
      DiscordClient.resetClientID();
      #end
      MusicBeatState.switchState(new modcharting.ModchartEditorState());
      if (notITGMod && !SONG.options.notITG)
      {
        Note.notITGNotes = true;
        StrumArrow.notITGStrums = true;
      }
      return true;
    }
  }
  #end

  function doDeathCheck(?skipHealthCheck:Bool = false)
  {
    if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead && gameOverTimer == null)
    {
      var ret:Dynamic = callOnScripts('onGameOver', null, true);
      if (ret != LuaUtils.Function_Stop)
      {
        death();
        return true;
      }
    }
    return false;
  }

  public var isDead:Bool = false; // Don't mess with this on Lua!!!
  public var gameOverTimer:FlxTimer;

  public dynamic function death()
  {
    FlxG.animationTimeScale = 1.0;
    boyfriend.stunned = true;
    deathCounter++;

    paused = true;

    canResync = false;
    canPause = false;

    persistentUpdate = false;
    persistentDraw = false;
    FlxTimer.globalManager.clear();
    FlxTween.globalManager.clear();
    FlxG.camera.setFilters([]);

    #if VIDEOS_ALLOWED
    for (vid in VideoSprite._videos)
    {
      vid.destroy();
    }
    VideoSprite._videos = [];
    #end
    if (ClientPrefs.data.instantRespawn && !ClientPrefs.data.characters || boyfriend.deadChar == "" && GameOverSubstate.characterName == "")
    {
      FlxG.sound.music.volume = 0;
      FlxG.sound.music.stop();
      if (vocals != null)
      {
        vocals.volume = 0;
        vocals.stop();
      }
      if (opponentVocals != null && splitVocals)
      {
        opponentVocals.volume = 0;
        opponentVocals.stop();
      }
      LoadingState.loadAndSwitchState(new PlayState());
    }
    else
    {
      if (GameOverSubstate.deathDelay > 0)
      {
        gameOverTimer = new FlxTimer().start(GameOverSubstate.deathDelay, function(_) {
          FlxG.sound.music.volume = 0;
          FlxG.sound.music.stop();
          if (vocals != null)
          {
            vocals.volume = 0;
            vocals.stop();
          }
          if (opponentVocals != null && splitVocals)
          {
            opponentVocals.volume = 0;
            opponentVocals.stop();
          }
          openSubState(new GameOverSubstate(boyfriend));
          gameOverTimer = null;
        });
      }
      else
      {
        FlxG.sound.music.volume = 0;
        FlxG.sound.music.stop();
        if (vocals != null)
        {
          vocals.volume = 0;
          vocals.stop();
        }
        if (opponentVocals != null && splitVocals)
        {
          opponentVocals.volume = 0;
          opponentVocals.stop();
        }
        openSubState(new GameOverSubstate(boyfriend));
      }
    }

    #if DISCORD_ALLOWED
    // Game Over doesn't get his own variable because it's only used here
    if (autoUpdateRPC) DiscordClient.changePresence("Game Over - " + detailsText, SONG.songId + " (" + storyDifficultyText + ")", iconP2.getCharacter());
    #end
    isDead = true;
  }

  public dynamic function checkEventNote()
  {
    while (eventNotes.length > 0)
    {
      var leEventTime:Float = eventNotes[0].time;
      if (Conductor.songPosition < leEventTime)
      {
        return;
      }
      triggerEvent(eventNotes[0].name, eventNotes[0].params, leEventTime);
      eventNotes.shift();
    }
  }

  public var letCharactersSwapNoteSkin:Bool = false; // False because of the stupid work around's with this.

  // For .hx files since they don't have a trigger for it but instead use playstate for the trigger
  public dynamic function triggerEventLegacy(eventName:String, value1:String, value2:String, ?eventTime:Float, ?value3:String, ?value4:String, ?value5:String,
      ?value6:String, ?value7:String, ?value8:String, ?value9:String, ?value10:String, ?value11:String, ?value12:String, ?value13:String, ?value14:String)
  {
    triggerEvent(eventName, [
      value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11, value12, value13, value14
    ], eventTime);
  }

  public var zoomLimitForAdding:Float = 1.35;

  public dynamic function triggerEvent(eventName:String, eventParams:Array<String>, ?eventTime:Float)
  {
    var flValues:Array<Null<Float>> = [];
    for (i in 0...eventParams.length - 1)
    {
      flValues.push(Std.parseFloat(eventParams[i]));
      if (Math.isNaN(flValues[i])) flValues[i] = null;
    }

    switch (eventName)
    {
      case 'Hey!':
        var value:Int = 2;
        switch (eventParams[0].toLowerCase().trim())
        {
          case 'bf' | 'boyfriend' | '0':
            value = 0;
          case 'gf' | 'girlfriend' | '1':
            value = 1;
          case 'dad' | '2':
            value = 2;
          case 'mom' | '3':
            value = 3;
          default:
            value = 4;
        }

        if (flValues[1] == null || flValues[1] <= 0) flValues[1] = 0.6;

        if ((value == 3 || value == 4) && mom != null)
        {
          mom.playAnim('hey', true);
          if (!mom.skipHeyTimer)
          {
            mom.specialAnim = true;
            mom.heyTimer = flValues[1];
          }
        }
        if ((value == 2 || value == 4))
        {
          dad.playAnim('hey', true);
          if (!dad.skipHeyTimer)
          {
            dad.specialAnim = true;
            dad.heyTimer = flValues[1];
          }
        }
        if ((value == 1 || value == 4))
        {
          if (dad.curCharacter.startsWith('gf'))
          { // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
            dad.playAnim('cheer', true);
            if (!dad.skipHeyTimer)
            {
              dad.specialAnim = true;
              dad.heyTimer = flValues[1];
            }
          }
          else if (gf != null)
          {
            gf.playAnim('cheer', true);
            if (!gf.skipHeyTimer)
            {
              gf.specialAnim = true;
              gf.heyTimer = flValues[1];
            }
          }
        }
        if ((value == 0 || value == 4))
        {
          boyfriend.playAnim('hey', true);
          if (!boyfriend.skipHeyTimer)
          {
            boyfriend.specialAnim = true;
            boyfriend.heyTimer = flValues[1];
          }
        }

      case 'Set GF Speed':
        if (flValues[0] == null || flValues[0] < 1) flValues[0] = 1;
        if (gf != null) gfSpeed = Math.round(flValues[0]);

      case 'Add Camera Zoom':
        if (ClientPrefs.data.camZooms && FlxG.camera.zoom < zoomLimitForAdding)
        {
          if (flValues[0] == null) flValues[0] = 0.015;
          if (flValues[1] == null) flValues[1] = 0.03;

          FlxG.camera.zoom += flValues[0];
          camHUD.zoom += flValues[1];
        }

      case 'Default Set Cam Zoom': // Add setCamZom as default Event
        var val1:Float = flValues[0];
        var val2:Float = flValues[1];

        if (eventParams[1] == '')
        {
          defaultCamZoom = val1;
        }
        else
        {
          defaultCamZoom = val1;
          FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, val2, {ease: FlxEase.sineInOut});
        }

      case 'Default Camera Flash': // Add flash as default Event
        var val:String = "0xFF" + eventParams[0];
        var color:FlxColor = Std.parseInt(val);
        var time:Float = Std.parseFloat(eventParams[1]);
        var alpha:Float = eventParams[3] != null ? Std.parseFloat(eventParams[3]) : 0.5;
        if (!ClientPrefs.data.flashing) color.alphaFloat = alpha;

        LuaUtils.cameraFromString(eventParams[2].toLowerCase()).flash(color, time, null, true);

      case 'Play Animation':
        var char:Character = dad;
        switch (eventParams[1].toLowerCase().trim())
        {
          case 'dad' | '0':
            char = dad;
          case 'bf' | 'boyfriend' | '1':
            char = boyfriend;
          case 'gf' | 'girlfriend' | '2':
            char = gf;
          case 'mom' | '3':
            char = mom;
          default:
            var tag = eventParams[1];
            tag = LuaUtils.checkVariable(tag, 'extraCharacter_');
            char = cast(MusicBeatState.getVariables().get(tag), Character);
        }

        characterAnimToPlay(eventParams[0], char);

      case 'Camera Follow Pos':
        if (camFollow != null)
        {
          isCameraOnForcedPos = false;
          if (flValues[0] != null || flValues[1] != null)
          {
            isCameraOnForcedPos = true;
            if (flValues[0] == null) flValues[0] = 0;
            if (flValues[1] == null) flValues[1] = 0;
            camFollow.x = flValues[0];
            camFollow.y = flValues[1];
            if (flValues[2] != null) defaultCamZoom = flValues[2];
          }
        }

      case 'Alt Idle Animation':
        var char:Character = dad;
        switch (eventParams[0].toLowerCase().trim())
        {
          case 'dad':
            char = dad;
          case 'gf' | 'girlfriend':
            char = gf;
          case 'boyfriend' | 'bf':
            char = boyfriend;
          case 'mom':
            char = mom;
          default:
            var tag = LuaUtils.checkVariable(eventParams[0], 'extraCharacter_');
            char = MusicBeatState.getVariables().get(tag);
        }

        if (char != null) char.idleSuffix = eventParams[1];

      case 'Screen Shake':
        var valuesArray:Array<String> = [eventParams[0], eventParams[1]];
        var targetsArray:Array<FlxCamera> = [camGame, camHUD];
        for (i in 0...targetsArray.length)
        {
          var split:Array<String> = valuesArray[i].split(',');
          var duration:Float = 0;
          var intensity:Float = 0;
          if (split[0] != null) duration = Std.parseFloat(split[0].trim());
          if (split[1] != null) intensity = Std.parseFloat(split[1].trim());
          if (Math.isNaN(duration)) duration = 0;
          if (Math.isNaN(intensity)) intensity = 0;

          if (duration > 0 && intensity != 0)
          {
            targetsArray[i].shake(intensity, duration);
          }
        }

      case 'Change Character':
        var charType:Int = 0;
        switch (eventParams[0].toLowerCase().trim())
        {
          case 'bf' | 'boyfriend' | '0':
            charType = 0;
            LuaUtils.changeBFAuto(eventParams[1]);

          case 'dad' | '1':
            charType = 1;
            LuaUtils.changeDadAuto(eventParams[1]);

          case 'gf' | 'girlfriend' | '2':
            charType = 2;
            if (gf != null) LuaUtils.changeGFAuto(eventParams[1]);

          case 'mom' | '3':
            charType = 3;
            if (mom != null) LuaUtils.changeMomAuto(eventParams[1]);

          default:
            var char:Character = MusicBeatState.getVariables().get('extraCharacter_' + eventParams[0]);

            if (char != null)
            {
              LuaUtils.makeLuaCharacter(eventParams[0], eventParams[1], char.isPlayer, char.flipMode);
            }
        }

        if (!SONG.options.notITG && !notITGMod && letCharactersSwapNoteSkin)
        {
          if (boyfriend.noteSkin != null && dad.noteSkin != null)
          {
            for (n in notes.members)
            {
              n.texture = (n.mustPress ? boyfriend.noteSkin : dad.noteSkin);
              n.noteSkin = (n.mustPress ? boyfriend.noteSkin : dad.noteSkin);
              n.reloadNote(n.noteSkin);
            }
            for (i in strumLineNotes.members)
            {
              i.texture = (i.player == 1 ? boyfriend.noteSkin : dad.noteSkin);
              i.daStyle = (i.player == 1 ? boyfriend.noteSkin : dad.noteSkin);
              i.reloadNote(i.daStyle);
            }
          }
        }

      case 'Change Scroll Speed':
        if (songSpeedType != "constant")
        {
          var speedEase = LuaUtils.getTweenEaseByString(eventParams[2] != null ? eventParams[2] : 'linear');
          if (flValues[0] == null) flValues[0] = 1;
          if (flValues[1] == null) flValues[1] = 0;

          var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValues[0];
          if (flValues[1] <= 0) songSpeed = newValue;
          else
          {
            songSpeedTween = createTween(this, {songSpeed: newValue}, flValues[1],
              {
                ease: speedEase,
                onComplete: function(twn:FlxTween) {
                  songSpeedTween = null;
                }
              });
          }
        }

      case 'Set Property':
        try
        {
          var split:Array<String> = eventParams[0].split('.');

          if (split.length > 1)
          {
            LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1], eventParams[1]);
          }
          else
          {
            LuaUtils.setVarInArray(this, eventParams[0], eventParams[1]);
          }
        }
        catch (e:Dynamic)
        {
          var len:Int = e.message.indexOf('\n') + 1;
          if (len <= 0) len = e.message.length;
          #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
          addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
          #else
          Debug.logError('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
          #end
        }

      case 'Play Sound':
        if (flValues[1] == null) flValues[1] = 1;
        FlxG.sound.play(Paths.sound(eventParams[0]), flValues[1]);

      case 'Reset Extra Arguments':
        var char:Character = dad;
        switch (eventParams[0].toLowerCase().trim())
        {
          case 'dad' | '0':
            char = dad;
          case 'bf' | 'boyfriend' | '1':
            char = boyfriend;
          case 'gf' | 'girlfriend' | '2':
            char = gf;
          case 'mom' | '3':
            char = mom;
          default:
            var tag = LuaUtils.checkVariable(eventParams[0], 'extraCharacter_');
            char = MusicBeatState.getVariables().get(tag);
        }

        if (char != null) char.resetAnimationVars();

      case 'Change Stage':
        changeStage(eventParams[0]);

      case 'Add Cinematic Bars':
        var valueForFloat1:Float = Std.parseFloat(eventParams[0]);
        if (Math.isNaN(valueForFloat1)) valueForFloat1 = 0;

        var valueForFloat2:Float = Std.parseFloat(eventParams[1]);
        if (Math.isNaN(valueForFloat2)) valueForFloat2 = 0;

        addCinematicBars(valueForFloat1, valueForFloat2);
      case 'Remove Cinematic Bars':
        var valueForFloat1:Float = Std.parseFloat(eventParams[0]);
        if (Math.isNaN(valueForFloat1)) valueForFloat1 = 0;

        removeCinematicBars(valueForFloat1);
      case 'Set Camera Target':
        forceChangeOnTarget = (eventParams[1] == 'false') ? false : true;
        cameraTargeted = eventParams[0];

      case 'Change Camera Props':
        if (eventParams[0] == '' && eventParams[1] == '') isCameraFocusedOnCharacters = true;
        else
          isCameraFocusedOnCharacters = false;
        FlxTween.cancelTweensOf(camFollow);
        FlxTween.cancelTweensOf(defaultCamZoom);

        // Props split up from one value.
        var camProps:Array<String> = eventParams[0].split(',');
        var followX:Float = (camProps[0] != "" ? Std.parseFloat(camProps[0]) : 0);
        var followY:Float = (camProps[1] != "" ? Std.parseFloat(camProps[1]) : 0);
        var zoomForCam:Float = (camProps[2] != "" ? Std.parseFloat(camProps[2]) : 0);

        // If camera uses Tweens to make values exact.
        var tweenCamera:Bool = (eventParams[1] != "" ? (eventParams[1] == "false" ? false : true) : false);

        // Eases
        var easesPoses:Array<String> = eventParams[2].split(',');
        var easeForX:String = (easesPoses[0] != "" ? easesPoses[0] : 'linear');
        var easeForY:String = (easesPoses[1] != "" ? easesPoses[1] : 'linear');
        var easeForZoom:String = (easesPoses[2] != "" ? easesPoses[2] : 'linear');

        // Time
        var timeForTweens:Array<String> = eventParams[3].split(',');
        var xTime:Float = (timeForTweens[0] != "" ? Std.parseFloat(timeForTweens[0]) : 0);
        var yTime:Float = (timeForTweens[1] != "" ? Std.parseFloat(timeForTweens[1]) : 0);
        var zoomTime:Float = (timeForTweens[2] != "" ? Std.parseFloat(timeForTweens[2]) : 0);

        if (tweenCamera)
        {
          if (camProps[0] != "") FlxTween.tween(camFollow, {x: followX}, xTime, {ease: LuaUtils.getTweenEaseByString(easeForX)});
          if (camProps[1] != "") FlxTween.tween(camFollow, {y: followY}, yTime, {ease: LuaUtils.getTweenEaseByString(easeForY)});
          if (camProps[2] != "") FlxTween.tween(this, {defaultCamZoom: zoomForCam}, zoomTime, {ease: LuaUtils.getTweenEaseByString(easeForZoom)});
        }
        else
        {
          if (camProps[0] != "") camFollow.x = followX;
          if (camProps[1] != "") camFollow.y = followY;
          if (camProps[2] != "") defaultCamZoom = zoomForCam;
        }
    }

    if (stage != null && !finishedSong) stage.eventCalledStage(eventName, eventParams, eventTime);
    callOnScripts('onEvent', [eventName, eventParams, eventTime]);
    callOnScripts('onEventLegacy', [
           eventName, eventParams[0], eventParams[1],      eventTime,  eventParams[2],  eventParams[3],  eventParams[4], eventParams[5],
      eventParams[6], eventParams[7], eventParams[8], eventParams[9], eventParams[10], eventParams[11], eventParams[12], eventParams[14]
    ]);
  }

  public dynamic function characterAnimToPlay(animation:String, char:Character)
  {
    if (!ClientPrefs.data.characters) return;
    if (char != null)
    {
      char.playAnim(animation, true);
      char.specialAnim = true;
    }
  }

  public var cinematicBars:Map<String, FlxSprite> = ["top" => null, "bottom" => null];

  public dynamic function addCinematicBars(speed:Float, ?thickness:Float = 7)
  {
    if (cinematicBars["top"] == null)
    {
      cinematicBars["top"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, Std.int(FlxG.height / thickness), FlxColor.BLACK);
      cinematicBars["top"].screenCenter(X);
      cinematicBars["top"].cameras = [camHUD2];
      cinematicBars["top"].y = 0 - cinematicBars["top"].height; // offscreen
      add(cinematicBars["top"]);
    }

    if (cinematicBars["bottom"] == null)
    {
      cinematicBars["bottom"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, Std.int(FlxG.height / thickness), FlxColor.BLACK);
      cinematicBars["bottom"].screenCenter(X);
      cinematicBars["bottom"].cameras = [camHUD2];
      cinematicBars["bottom"].y = FlxG.height; // offscreen
      add(cinematicBars["bottom"]);
    }

    createTween(cinematicBars["top"], {y: 0}, speed, {ease: FlxEase.circInOut});
    createTween(cinematicBars["bottom"], {y: FlxG.height - cinematicBars["bottom"].height}, speed, {ease: FlxEase.circInOut});
  }

  public dynamic function removeCinematicBars(speed:Float)
  {
    if (cinematicBars["top"] != null)
    {
      createTween(cinematicBars["top"], {y: 0 - cinematicBars["top"].height}, speed, {ease: FlxEase.circInOut});
    }

    if (cinematicBars["bottom"] != null)
    {
      createTween(cinematicBars["bottom"], {y: FlxG.height}, speed, {ease: FlxEase.circInOut});
    }
  }

  public var dadcamX:Float = 0;
  public var dadcamY:Float = 0;
  public var gfcamX:Float = 0;
  public var gfcamY:Float = 0;
  public var bfcamX:Float = 0;
  public var bfcamY:Float = 0;
  public var momcamX:Float = 0;
  public var momcamY:Float = 0;

  /**
   * The function is used to move the camera using either the animations of the characters or notehit.
   * @param char The character used to identify the camera Character.
   * @param note If this data is not -1 it will follow the numbers 0-3 for each direction.
   * @param intensity1 The first intensity.
   * @param intensity2 The second intensity.
   */
  public dynamic function moveCameraXY(char:Character = null, note:Int = -1, intensity1:Float = 0, intensity2:Float = 0):Void
  {
    var isDad:Bool = false;
    var isGf:Bool = false;
    var isMom:Bool = false;
    var camName:String = "";
    var camValueY:Float = 0;
    var camValueX:Float = 0;
    var stringChosen:String = (note > -1 ? Std.string(Std.int(Math.abs(note))) : (!char.isAnimationNull() ? char.getLastAnimationPlayed() : Std.string(Std.int(Math.abs(note)))));

    if (char == gf) isGf = true;
    else if (char == dad) isDad = true;
    else if (char == mom) isMom = true;
    else
    {
      // Only BF then!
      isGf = false;
      isMom = false;
      isDad = false;
    }

    switch (stringChosen)
    {
      case 'singLEFT' | 'singLEFT-alt' | '0':
        camValueY = 0;
        camValueX = -intensity1;
      case 'singDOWN' | 'singDOWN-alt' | '1':
        camValueY = intensity2;
        camValueX = 0;
      case 'singUP' | 'singUP-alt' | '2':
        camValueY = -intensity2;
        camValueX = 0;
      case 'singRIGHT' | 'singRIGHT-alt' | '3':
        camValueY = 0;
        camValueX = intensity1;
    }

    if (isDad) camName = "dad";
    else if (isGf) camName = "gf";
    else if (isMomCam) camName = "mom";
    else
      camName = "bf";

    Reflect.setProperty(PlayState.instance, camName + 'camX', camValueX);
    Reflect.setProperty(PlayState.instance, camName + 'camY', camValueY);
  }

  public dynamic function finishSong(?ignoreNoteOffset:Bool = false):Void
  {
    finishedSong = true;

    FlxG.sound.music.volume = 0;
    if (vocals != null)
    {
      vocals.volume = 0;
      vocals.pause();
    }
    if (opponentVocals != null && splitVocals)
    {
      opponentVocals.volume = 0;
      opponentVocals.pause();
    }
    if (ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset)
    {
      if (endCallback != null) endCallback();
    }
    else
    {
      finishTimer = createTimer(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
        if (endCallback != null) endCallback();
      });
    }
  }

  public var transitioning = false;
  public var comboLetterRank:String = '';
  public var alreadyEndedSong:Bool = false;
  public var stoppedAllInstAndVocals:Bool = false;

  public static var finishedSong:Bool = false;

  public dynamic function endSong()
  {
    // Should kill you if you tried to cheat
    if (!startingSong)
    {
      notes.forEach(function(daNote:Note) {
        if (daNote != null && daNote.strumTime < songLength - Conductor.safeZoneOffset) health -= 0.05 * healthLoss;
      });
      for (daNote in unspawnNotes)
      {
        if (daNote != null && daNote.strumTime < songLength - Conductor.safeZoneOffset)
        {
          health -= 0.05 * healthLoss;
        }
      }

      if (doDeathCheck())
      {
        return false;
      }
    }

    timeBarNew.visible = false;
    timeBar.visible = false;
    timeTxt.visible = false;
    canPause = false;
    endingSong = true;
    camZooming = false;
    inCutscene = false;
    inCinematic = false;
    updateTime = false;

    deathCounter = 0;
    seenCutscene = false;

    chartingMode = false;
    modchartMode = false;

    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.active = false;
      FlxG.sound.music.volume = 0;
      FlxG.sound.music.stop();
      if (vocals != null)
      {
        vocals.active = false;
        vocals.volume = 0;
        vocals.stop();
      }
      if (opponentVocals != null && splitVocals)
      {
        opponentVocals.active = false;
        opponentVocals.volume = 0;
        opponentVocals.stop();
      }
    }

    if (notITGMod && SONG.options.notITG)
    {
      Note.notITGNotes = false;
      StrumArrow.notITGStrums = false;
    }

    if (FlxG.sound.music.active != true) stoppedAllInstAndVocals = true;

    alreadyEndedSong = true;

    #if ACHIEVEMENTS_ALLOWED
    var weekNoMiss:String = WeekData.getWeekFileName() + '_nomiss';
    checkForAchievement([weekNoMiss, 'ur_bad', 'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);
    #end

    var legitTimings:Bool = true;
    for (rating in Rating.timingWindows)
    {
      if (rating.timingWindow != rating.defaultTimingWindow)
      {
        legitTimings = false;
        break;
      }
    }

    var superMegaConditionShit:Bool = legitTimings
      && notITGMod
      && holdsActive
      && !cpuControlled
      && !practiceMode
      && !chartingMode
      && !modchartMode
      && HelperFunctions.truncateFloat(healthGain, 2) <= 1
      && HelperFunctions.truncateFloat(healthLoss, 2) >= 1;
    var ret:Dynamic = callOnScripts('onEndSong', null, true);
    if (ret != LuaUtils.Function_Stop && !transitioning)
    {
      #if ! switch
      if (superMegaConditionShit && ClientPrefs.data.resultsScreenType == 'NONE')
      {
        var percent:Float = ratingPercent; // Accuracy HighScore
        if (Math.isNaN(percent)) percent = 0;
        Highscore.saveScore(songName, songScore, storyDifficulty, percent);
        Highscore.saveCombo(songName, ratingFC, storyDifficulty);
        Highscore.saveLetter(songName, comboLetterRank, storyDifficulty);
      }
      #end
      playbackRate = 1;

      if (isStoryMode)
      {
        var percent:Float = updateAcc;
        if (Math.isNaN(percent)) percent = 0;
        weekAccuracy += HelperFunctions.truncateFloat(percent / storyPlaylist.length, 2);
        weekScore += Math.round(songScore);
        weekMisses += songMisses;
        weekSicks += sickHits;
        weekSwags += swagHits;
        weekGoods += goodHits;
        weekBads += badHits;
        weekShits += shitHits;

        setWeekAverage(weekAccuracy, [weekScore, weekMisses, weekSwags, weekSicks, weekGoods, weekBads, weekShits]);
        setRatingAverage([swagHits, sickHits, goodHits, badHits, shitHits]);

        storyPlaylist.remove(storyPlaylist[0]);

        if (storyPlaylist.length <= 0)
        {
          if (!stoppedAllInstAndVocals)
          {
            if (FlxG.sound.music != null)
            {
              FlxG.sound.music.active = false;
              FlxG.sound.music.volume = 0;
              FlxG.sound.music.stop();
              if (vocals != null)
              {
                vocals.active = false;
                vocals.volume = 0;
                vocals.stop();
              }
              if (opponentVocals != null && splitVocals)
              {
                opponentVocals.active = false;
                opponentVocals.volume = 0;
                opponentVocals.stop();
              }
            }
          }

          if (ClientPrefs.data.resultsScreenType == 'KADE')
          {
            if (persistentUpdate != false) persistentUpdate = false;
            openSubState(subStates[0]);
            inResults = true;
          }
          else if (ClientPrefs.data.resultsScreenType == 'V-SLICE') {
            persistentUpdate = false;

            var modManifest = Mods.getPack();
            var modName = "unknown mod";

            if(modManifest != null)
              if(modManifest.name != "" || modManifest.name != null || modManifest.name != "Name" || modManifest.name != "name") {
                modName = modManifest.name;
              }
        
            vocals.stop();
            camHUD.alpha = 1;

            var accPts = ratingPercent * totalPlayed;

            var scoreData =
            {
              score: songScore,
              accPoints: accPts,
      
              sick: sickHits,
              good: goodHits,
              bad: badHits,
              shit: shitHits,
              missed: songMisses,
              combo: combo,
              maxCombo: highestCombo,
              totalNotesHit: totalPlayed,
              totalNotes: 69,
            };
          
            var res:states.results.ResultState = new states.results.ResultState(
            {
              storyMode: isStoryMode,
              songId: curSong,
              difficultyId: Difficulty.getString(),
              title: isStoryMode ? ('') : ('${curSong} from ${modName}'),
              scoreData:scoreData,
              prevScoreRank: null,
              isNewHighscore: songScore>Highscore.getScore(songName, storyDifficulty)
            });
            this.persistentDraw = false;
            openSubState(res);
          }
          else
          {
            Mods.loadTopMod();
            FlxG.sound.playMusic(SlushiMain.getSLEPath("Musics/SLE_HackNet_Resonance.ogg"));
            #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
            MusicBeatState.switchState(new StoryMenuState());
          }

          if (!practiceMode && !cpuControlled)
          {
            StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
            Highscore.saveWeekScore(WeekData.getWeekFileName(), averageWeekScore, storyDifficulty);

            FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
            FlxG.save.flush();
          }
          changedDifficulty = false;
        }
        else
        {
          var difficulty:String = Difficulty.getFilePath();

          Debug.logTrace('LOADING NEXT SONG');
          Debug.logTrace(Paths.formatToSongPath(storyPlaylist[0]) + difficulty);

          FlxTransitionableState.skipNextTransIn = true;
          FlxTransitionableState.skipNextTransOut = true;
          prevCamFollow = camFollow;

          Song.loadFromJson(storyPlaylist[0] + difficulty, storyPlaylist[0]);

          if (!stoppedAllInstAndVocals)
          {
            if (FlxG.sound.music != null)
            {
              FlxG.sound.music.active = false;
              FlxG.sound.music.volume = 0;
              FlxG.sound.music.stop();
              if (vocals != null)
              {
                vocals.active = false;
                vocals.volume = 0;
                vocals.stop();
              }
              if (opponentVocals != null && splitVocals)
              {
                opponentVocals.active = false;
                opponentVocals.volume = 0;
                opponentVocals.stop();
              }
            }
          }

          LoadingState.prepareToSong(SONG);
          LoadingState.loadAndSwitchState(new PlayState(), false, false);
        }
      }
      else
      {
        setRatingAverage([swagHits, sickHits, goodHits, badHits, shitHits]);

        if (!stoppedAllInstAndVocals)
        {
          if (FlxG.sound.music != null)
          {
            FlxG.sound.music.active = false;
            FlxG.sound.music.volume = 0;
            FlxG.sound.music.stop();
            if (vocals != null)
            {
              vocals.active = false;
              vocals.volume = 0;
              vocals.stop();
            }
            if (opponentVocals != null && splitVocals)
            {
              opponentVocals.active = false;
              opponentVocals.volume = 0;
              opponentVocals.stop();
            }
          }
        }

        if (ClientPrefs.data.resultsScreenType == 'KADE')
        {
          if (persistentUpdate != false) persistentUpdate = false;
          openSubState(subStates[0]);
          inResults = true;
        }
        else if (ClientPrefs.data.resultsScreenType == 'V-SLICE') {
          persistentUpdate = false;

          var modManifest = Mods.getPack();
          var modName = "unknown mod";

          if(modManifest != null)
            if(modManifest.name != "" || modManifest.name != null || modManifest.name != "Name" || modManifest.name != "name") {
              modName = modManifest.name;
            }
      
          vocals.stop();
          camHUD.alpha = 1;

          var accPts = ratingPercent * totalPlayed;

          var scoreData =
          {
            score: songScore,
            accPoints: accPts,
    
            sick: sickHits,
            good: goodHits,
            bad: badHits,
            shit: shitHits,
            missed: songMisses,
            combo: combo,
            maxCombo: highestCombo,
            totalNotesHit: totalPlayed,
            totalNotes: 69,
          };
        
          var res:states.results.ResultState = new states.results.ResultState(
          {
            storyMode: isStoryMode,
            songId: curSong,
            difficultyId: Difficulty.getString(),
            title: isStoryMode ? ('') : ('${curSong} from ${modName}'),
            scoreData:scoreData,
            prevScoreRank: null,
            isNewHighscore: songScore>Highscore.getScore(songName, storyDifficulty)
          });
          this.persistentDraw = false;
          openSubState(res);
        }
        else
        {
          Debug.logTrace('WENT BACK TO FREEPLAY??');
          Mods.loadTopMod();
          #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
          MusicBeatState.switchState(new FreeplayState());
          FlxG.sound.playMusic(SlushiMain.getSLEPath("Musics/SLE_HackNet_Resonance.ogg"));
          changedDifficulty = false;
        }
      }
      transitioning = true;

      if (forceMiddleScroll)
      {
        if (savePrefixScrollR && prefixRightScroll)
        {
          ClientPrefs.data.middleScroll = false;
        }
      }
      else if (forceRightScroll)
      {
        if (savePrefixScrollM && prefixMiddleScroll)
        {
          ClientPrefs.data.middleScroll = true;
        }
      }
    }
    return true;
  }

  public function setWeekAverage(acc:Float, weekArgs:Array<Int>)
  {
    averageWeekAccuracy = acc;
    averageWeekScore = weekArgs[0];
    averageWeekMisses = weekArgs[1];
    averageWeekSwags = weekArgs[2];
    averageWeekSicks = weekArgs[3];
    averageWeekGoods = weekArgs[4];
    averageWeekBads = weekArgs[5];
    averageWeekShits = weekArgs[6];
  }

  public function setRatingAverage(ratingArgs:Array<Int>)
  {
    averageSwags = ratingArgs[0];
    averageSicks = ratingArgs[1];
    averageBads = ratingArgs[3];
    averageGoods = ratingArgs[2];
    averageShits = ratingArgs[4];
  }

  public function KillNotes()
  {
    while (notes.length > 0)
    {
      var daNote:Note = notes.members[0];
      invalidateNote(daNote, false);
    }
    unspawnNotes = [];
    eventNotes = [];
  }

  public var totalPlayed:Int = 0;
  public var totalNotesHit:Float = 0.0;

  public var showCombo:Bool = ClientPrefs.data.showCombo;
  public var showComboNum:Bool = ClientPrefs.data.showComboNum;
  public var showRating:Bool = ClientPrefs.data.showRating;

  // Stores Ratings and Combo Sprites in a group for OP
  public var comboGroupOP:FlxSpriteGroup;
  // Stores Ratings and Combo Sprites in a group
  public var comboGroup:FlxSpriteGroup;
  // Stores HUD Elements in a Group
  public var uiGroup:FlxSpriteGroup;

  public var ratingsAlpha:Float = 1;

  public function cachePopUpScore()
  {
    var uiPrefix:String = '';
    var uiSuffix:String = '';

    var stageUIPrefixNotNull:Bool = false;
    var stageUISuffixNotNull:Bool = false;

    if (stage.stageUIPrefixShit != null)
    {
      uiPrefix = stage.stageUIPrefixShit;
      stageUIPrefixNotNull = true;
    }
    if (stage.stageUISuffixShit != null)
    {
      uiSuffix = stage.stageUISuffixShit;
      stageUISuffixNotNull = true;
    }

    if (!stageUIPrefixNotNull && !stageUISuffixNotNull)
    {
      if (stageUI != "normal")
      {
        uiPrefix = '${stageUI}UI/';
        if (isPixelStage) uiSuffix = '-pixel';
      }
    }
    else
    {
      switch (stage.curStage)
      {
        default:
          uiPrefix = stage.stageUIPrefixShit;
          uiSuffix = stage.stageUISuffixShit;
      }
    }

    for (rating in Rating.timingWindows)
      Paths.cacheBitmap(uiPrefix + rating.name.toLowerCase() + uiSuffix);
    for (i in 0...10)
      Paths.cacheBitmap(uiPrefix + 'num' + i + uiSuffix);
  }

  public function getRatesScore(rate:Float, score:Float):Float
  {
    var rateX:Float = 1;
    var lastScore:Float = score;
    var pr = rate - 0.05;
    if (pr < 1.00) pr = 1;

    while (rateX <= pr)
    {
      if (rateX > pr) break;
      lastScore = score + ((lastScore * rateX) * 0.022);
      rateX += 0.05;
    }

    var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

    return actualScore;
  }

  public dynamic function popUpScore(note:Note):Void
  {
    var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
    if (vocals != null) vocals.volume = 1;
    if (!ClientPrefs.data.comboStacking && comboGroup.members.length > 0)
    {
      for (spr in comboGroup)
      {
        if (spr == null) continue;

        comboGroup.remove(spr);
        spr.destroy();
      }
    }

    if (cpuControlled) noteDiff = 0;

    var placement:Float = ClientPrefs.data.gameCombo ? FlxG.width * 0.55 : FlxG.width * 0.48;
    var rating:FlxSprite = new FlxSprite();
    var score:Float = 0;

    // tryna do MS based judgment due to popular demand
    var daRating:RatingWindow = Rating.judgeNote(noteDiff / playbackRate, cpuControlled);

    totalNotesHit += daRating.accuracyBonus;
    totalPlayed += 1;

    note.rating = daRating;

    if (ClientPrefs.data.resultsScreenType == 'KADE')
    {
      ResultsScreenKadeSubstate.instance.registerHit(note, false, cpuControlled, Rating.timingWindows[0].timingWindow);
    }

    score = daRating.scoreBonus;
    daRating.count++;

    note.canSplash = ((!note.noteSplashData.disabled && ClientPrefs.splashOption('Player') && daRating.doNoteSplash)
      && !SONG.options.notITG);
    if (note.canSplash) spawnNoteSplashOnNote(note);

    if (playbackRate >= 1.05) score = getRatesScore(playbackRate, score);

    if (!practiceMode)
    {
      songScore += Math.round(score);
      songHits++;
      RecalculateRating(false);
    }

    if (!showRating && !showComboNum && !showComboNum) return;

    var uiPrefix:String = '';
    var uiSuffix:String = '';
    var antialias:Bool = ClientPrefs.data.antialiasing;
    var stageUIPrefixNotNull:Bool = false;
    var stageUISuffixNotNull:Bool = false;

    if (stage.stageUIPrefixShit != null)
    {
      uiPrefix = stage.stageUIPrefixShit;
      stageUIPrefixNotNull = true;
    }
    if (stage.stageUISuffixShit != null)
    {
      uiSuffix = stage.stageUISuffixShit;
      stageUISuffixNotNull = true;
    }

    var offsetX:Float = 0;
    var offsetY:Float = 0;

    if (!stageUIPrefixNotNull && !stageUISuffixNotNull)
    {
      if (stageUI != "normal")
      {
        uiPrefix = '${stageUI}UI/';
        if (isPixelStage) uiSuffix = '-pixel';
        antialias = !isPixelStage;
      }
    }
    else
    {
      switch (stage.curStage)
      {
        default:
          if (ClientPrefs.data.gameCombo)
          {
            offsetX = stage.stageRatingOffsetXPlayer != 0 ? stage.gfXOffset + stage.stageRatingOffsetXPlayer : stage.gfXOffset;
            offsetY = stage.stageRatingOffsetYPlayer != 0 ? stage.gfYOffset + stage.stageRatingOffsetYPlayer : stage.gfYOffset;
          }
          uiPrefix = stage.stageUIPrefixShit;
          uiSuffix = stage.stageUISuffixShit;

          antialias = !(uiPrefix.contains('pixel') || uiSuffix.contains('pixel'));
      }
    }

    note.ratingToString = daRating.name.toLowerCase();

    switch (daRating.name.toLowerCase())
    {
      case 'shit':
        shitHits++;
      case 'bad':
        badHits++;
      case 'good':
        goodHits++;
      case 'sick':
        sickHits++;
      case 'swag':
        swagHits++;
    }

    rating.loadGraphic(Paths.image(uiPrefix + daRating.name.toLowerCase() + uiSuffix));
    if (rating.graphic == null) rating.loadGraphic(Paths.image('missingRating'));
    rating.screenCenter();
    rating.x = placement - 40 + offsetX;
    rating.y -= 60 + offsetY;
    rating.acceleration.y = 550 * playbackRate * playbackRate;
    rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
    rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
    rating.visible = (!ClientPrefs.data.hideHud && showRating);
    rating.alpha = ratingsAlpha;
    rating.x += ClientPrefs.data.comboOffset[0];
    rating.y -= ClientPrefs.data.comboOffset[1];
    rating.antialiasing = antialias;

    var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'combo' + uiSuffix));
    if (comboSpr.graphic == null) comboSpr.loadGraphic(Paths.image('missingRating'));
    comboSpr.screenCenter();
    comboSpr.x = placement + offsetX;
    comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
    comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
    comboSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
    comboSpr.x += ClientPrefs.data.comboOffset[0];
    comboSpr.y -= ClientPrefs.data.comboOffset[1];
    comboSpr.antialiasing = antialias;
    comboSpr.y += 60 + offsetY;
    comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
    comboSpr.alpha = ratingsAlpha;

    if (showRating) comboGroup.add(rating);

    if (!uiPrefix.contains('pixel') || !uiSuffix.contains('pixel'))
    {
      rating.setGraphicSize(Std.int(rating.width * (stage.stageRatingScales != null ? stage.stageRatingScales[0] : 0.7)));
      comboSpr.setGraphicSize(Std.int(comboSpr.width * (stage.stageRatingScales != null ? stage.stageRatingScales[1] : 0.7)));
    }
    else
    {
      rating.setGraphicSize(Std.int(rating.width * (stage.stageRatingScales != null ? stage.stageRatingScales[2] : 5.1)));
      comboSpr.setGraphicSize(Std.int(comboSpr.width * (stage.stageRatingScales != null ? stage.stageRatingScales[3] : 5.1)));
    }

    comboSpr.updateHitbox();
    rating.updateHitbox();

    if (combo > highestCombo) highestCombo = combo - 1;

    var daLoop:Int = 0;
    var xThing:Float = 0;
    if (showCombo && (whichHud != 'GLOW_KADE' || (whichHud == 'GLOW_KADE' && combo > 5))) comboGroup.add(comboSpr);

    var separatedScore:String = Std.string(combo).lpad('0', 3);
    for (i in 0...separatedScore.length)
    {
      var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'num' + Std.parseInt(separatedScore.charAt(i)) + uiSuffix));
      if (numScore.graphic == null) numScore.loadGraphic(Paths.image('missingRating'));
      numScore.screenCenter();
      numScore.x = placement + (43 * daLoop) - 90 + offsetX + ClientPrefs.data.comboOffset[2];
      numScore.y += 80 - offsetY - ClientPrefs.data.comboOffset[3];

      if (!uiPrefix.contains('pixel') || !uiSuffix.contains('pixel'))
        numScore.setGraphicSize(Std.int(numScore.width * (stage.stageRatingScales != null ? stage.stageRatingScales[4] : 0.5)));
      else
        numScore.setGraphicSize(Std.int(numScore.width * (stage.stageRatingScales != null ? stage.stageRatingScales[5] : daPixelZoom)));
      numScore.updateHitbox();

      numScore.acceleration.y = FlxG.random.int(200, 300);
      numScore.velocity.y -= FlxG.random.int(140, 160);
      numScore.velocity.x = FlxG.random.float(-5, 5);
      numScore.visible = !ClientPrefs.data.hideHud;
      numScore.antialiasing = antialias;
      numScore.alpha = ratingsAlpha;

      if (showComboNum && (whichHud != 'GLOW_KADE' || (whichHud == 'GLOW_KADE' && (combo >= 10 || combo == 0)))) comboGroup.add(numScore);

      createTween(numScore, {alpha: 0}, 0.2,
        {
          onComplete: function(tween:FlxTween) {
            numScore.destroy();
            comboGroup.remove(numScore);
          },
          startDelay: Conductor.crochet * 0.002
        });

      daLoop++;
      if (numScore.x > xThing) xThing = numScore.x;
    }
    comboSpr.x = xThing + 50 + offsetX;
    createTween(rating, {alpha: 0}, 0.2,
      {
        startDelay: Conductor.crochet * 0.001
      });

    createTween(comboSpr, {alpha: 0}, 0.2,
      {
        onComplete: function(tween:FlxTween) {
          comboSpr.destroy();
          rating.destroy();
          comboGroup.remove(comboSpr);
          comboGroup.remove(rating);
        },
        startDelay: Conductor.crochet * 0.002
      });
  }

  public dynamic function popUpScoreOp(note:Note):Void
  {
    if (splitVocals)
    {
      if (opponentVocals != null) opponentVocals.volume = 1;
    }
    else
    {
      if (vocals != null) vocals.volume = 1;
    }
    if (!ClientPrefs.data.comboStacking && comboGroupOP.members.length > 0)
    {
      for (spr in comboGroupOP)
      {
        if (spr == null) continue;

        comboGroupOP.remove(spr);
        spr.destroy();
      }
    }

    var placement:Float = FlxG.width * 0.38;
    var rating:FlxSprite = new FlxSprite();

    note.canSplash = ((!note.noteSplashData.disabled && ClientPrefs.splashOption('Opponent')) && !SONG.options.notITG);
    if (note.canSplash) spawnNoteSplashOnNote(note);

    if (!showRating && !showComboNum && !showComboNum) return;

    var uiPrefix:String = "";
    var uiSuffix:String = '';
    var antialias:Bool = ClientPrefs.data.antialiasing;
    var stageUIPrefixNotNull:Bool = false;
    var stageUISuffixNotNull:Bool = false;

    if (stage.stageUIPrefixShit != null)
    {
      uiPrefix = stage.stageUIPrefixShit;
      stageUIPrefixNotNull = true;
    }
    if (stage.stageUISuffixShit != null)
    {
      uiSuffix = stage.stageUISuffixShit;
      stageUISuffixNotNull = true;
    }

    var offsetX:Float = 0;
    var offsetY:Float = 0;

    if (!stageUIPrefixNotNull && !stageUISuffixNotNull)
    {
      if (stageUI != "normal")
      {
        uiPrefix = '${stageUI}UI/';
        if (isPixelStage) uiSuffix = '-pixel';
        antialias = !isPixelStage;
      }
    }
    else
    {
      switch (stage.curStage)
      {
        default:
          if (ClientPrefs.data.gameCombo)
          {
            offsetX = stage.stageRatingOffsetXOpponent != 0 ? stage.gfXOffset + stage.stageRatingOffsetXOpponent : stage.gfXOffset;
            offsetY = stage.stageRatingOffsetYOpponent != 0 ? stage.gfYOffset + stage.stageRatingOffsetYOpponent : stage.gfYOffset;
          }
          uiPrefix = stage.stageUIPrefixShit;
          uiSuffix = stage.stageUISuffixShit;

          antialias = !(uiPrefix.contains('pixel') || uiSuffix.contains('pixel'));
      }
    }

    rating.loadGraphic(Paths.image(uiPrefix + 'swag' + uiSuffix));
    if (rating.graphic == null) rating.loadGraphic(Paths.image('missingRating'));
    rating.screenCenter();
    rating.x = placement - 40 + offsetX;
    rating.y -= 60 + offsetY;
    rating.acceleration.y = 550 * playbackRate * playbackRate;
    rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
    rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
    rating.visible = (!ClientPrefs.data.hideHud && showRating);
    rating.x += ClientPrefs.data.comboOffset[0];
    rating.y -= ClientPrefs.data.comboOffset[1];
    rating.antialiasing = antialias;
    rating.alpha = ratingsAlpha;

    var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'combo' + uiSuffix));
    if (comboSpr.graphic == null) comboSpr.loadGraphic(Paths.image('missingRating'));
    comboSpr.screenCenter();
    comboSpr.x = placement + offsetX;
    comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
    comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
    comboSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
    comboSpr.x += ClientPrefs.data.comboOffset[0];
    comboSpr.y -= ClientPrefs.data.comboOffset[1];
    comboSpr.antialiasing = antialias;
    comboSpr.y += 60 + offsetY;
    comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
    comboSpr.alpha = ratingsAlpha;

    if (showRating) comboGroupOP.add(rating);

    if (!uiPrefix.contains('pixel') || !uiSuffix.contains('pixel'))
    {
      rating.setGraphicSize(Std.int(rating.width * (stage.stageRatingScales != null ? stage.stageRatingScales[0] : 0.7)));
      comboSpr.setGraphicSize(Std.int(comboSpr.width * (stage.stageRatingScales != null ? stage.stageRatingScales[1] : 0.7)));
    }
    else
    {
      rating.setGraphicSize(Std.int(rating.width * (stage.stageRatingScales != null ? stage.stageRatingScales[2] : 5.1)));
      comboSpr.setGraphicSize(Std.int(comboSpr.width * (stage.stageRatingScales != null ? stage.stageRatingScales[3] : 5.1)));
    }

    comboSpr.updateHitbox();
    rating.updateHitbox();

    var daLoop:Int = 0;
    var xThing:Float = 0;
    if (showCombo && (whichHud != 'GLOW_KADE' || (whichHud == 'GLOW_KADE' && comboOp > 5))) comboGroupOP.add(comboSpr);

    var separatedScore:String = Std.string(comboOp).lpad('0', 3);
    for (i in 0...separatedScore.length)
    {
      var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'num' + Std.parseInt(separatedScore.charAt(i)) + uiSuffix));
      if (numScore.graphic == null) numScore.loadGraphic(Paths.image('missingRating'));
      numScore.screenCenter();
      numScore.x = placement + (43 * daLoop) - 90 + offsetX + ClientPrefs.data.comboOffset[2];
      numScore.y += 80 - offsetY - ClientPrefs.data.comboOffset[3];

      if (!uiPrefix.contains('pixel') || !uiSuffix.contains('pixel'))
        numScore.setGraphicSize(Std.int(numScore.width * (stage.stageRatingScales != null ? stage.stageRatingScales[4] : 0.5)));
      else
        numScore.setGraphicSize(Std.int(numScore.width * (stage.stageRatingScales != null ? stage.stageRatingScales[5] : daPixelZoom)));
      numScore.updateHitbox();

      numScore.acceleration.y = FlxG.random.int(200, 300);
      numScore.velocity.y -= FlxG.random.int(140, 160);
      numScore.velocity.x = FlxG.random.float(-5, 5);
      numScore.visible = !ClientPrefs.data.hideHud;
      numScore.antialiasing = antialias;
      numScore.alpha = ratingsAlpha;

      if (showComboNum
        && (whichHud != 'GLOW_KADE' || (whichHud == 'GLOW_KADE' && (combo >= 10 || combo == 0)))) comboGroupOP.add(numScore);

      createTween(numScore, {alpha: 0}, 0.2,
        {
          onComplete: function(tween:FlxTween) {
            numScore.destroy();
            comboGroupOP.remove(numScore);
          },
          startDelay: Conductor.crochet * 0.002
        });

      daLoop++;
      if (numScore.x > xThing) xThing = numScore.x;
    }
    comboSpr.x = xThing + 50 + offsetX;
    createTween(rating, {alpha: 0}, 0.2,
      {
        startDelay: Conductor.crochet * 0.001
      });

    createTween(comboSpr, {alpha: 0}, 0.2,
      {
        onComplete: function(tween:FlxTween) {
          comboSpr.destroy();
          rating.destroy();
          comboGroupOP.remove(comboSpr);
          comboGroupOP.remove(rating);
        },
        startDelay: Conductor.crochet * 0.002
      });
  }

  public var strumsBlocked:Array<Bool> = [];

  private function onKeyPress(event:KeyboardEvent):Void
  {
    var eventKey:FlxKey = event.keyCode;
    var key:Int = getKeyFromEvent(keysArray, eventKey);
    if (!controls.controllerMode)
    {
      #if debug
      // Prevents crash specifically on debug without needing to try catch shit
      @:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
      #end

      if (FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
    }
  }

  private function keyPressed(key:Int)
  {
    var keyBool:Bool = (key > playerStrums.length);
    if (OMANDNOTMSANDNOTITG) keyBool = (key > opponentStrums.length);
    if (cpuControlled || paused || inCutscene || key < 0 || keyBool || !generatedMusic || endingSong || boyfriend.stunned) return;

    // had to name it like this else it'd break older scripts lol
    var ret:Dynamic = callOnScripts('onKeyPressPre', [key]);
    if (ret == LuaUtils.Function_Stop) return;

    if (ClientPrefs.data.hitsoundType == 'Keys'
      && ClientPrefs.data.hitsoundVolume != 0
      && ClientPrefs.data.hitSounds != "None") FlxG.sound.play(Paths.sound('hitsounds/${ClientPrefs.data.hitSounds}'), ClientPrefs.data.hitsoundVolume)
      .pitch = playbackRate;

    // more accurate hit time for the ratings?
    var lastTime:Float = Conductor.songPosition;
    if (Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

    // obtain notes that the player can hit
    var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
      var canHit:Bool = n != null && !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit;
      return canHit && !n.isSustainNote && n.noteData == key;
    });
    plrInputNotes.sort(sortHitNotes);

    if (plrInputNotes.length != 0)
    { // slightly faster than doing `> 0` lol
      var funnyNote:Note = plrInputNotes[0]; // front note

      if (plrInputNotes.length > 1)
      {
        var doubleNote:Note = plrInputNotes[1];

        if (doubleNote.noteData == funnyNote.noteData)
        {
          // if the note has a 0ms distance (is on top of the current note), kill it
          if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0) invalidateNote(doubleNote, false);
          else if (doubleNote.strumTime < funnyNote.strumTime)
          {
            // replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
            funnyNote = doubleNote;
          }
        }
      }
      goodNoteHit(funnyNote);
    }
    else
    {
      callOnScripts('onGhostTap', [key]);
      if (!ClientPrefs.data.ghostTapping) noteMissPress(key);
    }

    // Needed for the  "Just the Two of Us" achievement.
    //									- Shadow Mario
    if (!keysPressed.contains(key)) keysPressed.push(key);

    // more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
    Conductor.songPosition = lastTime;

    var spr:StrumArrow = playerStrums.members[key];
    if (OMANDNOTMSANDNOTITG) spr = opponentStrums.members[key];
    if (strumsBlocked[key] != true
      && spr != null
      && spr.animation.curAnim.name != 'confirm'
      && spr.animation.curAnim.name != 'confirm-hold'
      && spr.animation.getByName('pressed') != null)
    {
      spr.playAnim('pressed', true);
      spr.resetAnim = 0;
    }
    callOnScripts('onKeyPress', [key]);
  }

  public static function sortHitNotes(a:Note, b:Note):Int
  {
    if (a.lowPriority && !b.lowPriority) return 1;
    else if (!a.lowPriority && b.lowPriority) return -1;
    return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
  }

  private function onKeyRelease(event:KeyboardEvent):Void
  {
    var eventKey:FlxKey = event.keyCode;
    var key:Int = getKeyFromEvent(keysArray, eventKey);
    if (!controls.controllerMode && key > -1) keyReleased(key);
  }

  private function keyReleased(key:Int)
  {
    var keyBool:Bool = (key > playerStrums.length);
    if (OMANDNOTMSANDNOTITG) keyBool = (key > opponentStrums.length);
    if (cpuControlled || !startedCountdown || paused || key < 0 || keyBool) return;

    var ret:Dynamic = callOnScripts('onKeyReleasePre', [key]);
    if (ret == LuaUtils.Function_Stop) return;

    var spr:StrumArrow = OMANDNOTMSANDNOTITG ? opponentStrums.members[key] : playerStrums.members[key];
    if (spr != null && spr.animation.getByName('static') != null)
    {
      spr.playAnim('static', true);
      spr.resetAnim = 0;
    }
    callOnScripts('onKeyRelease', [key]);

    if (!opponentMode)
    {
      // Thanks drkfon376
      if (playerHoldCovers != null
        && !playerHoldCovers.members[key].isAnimationNull()
        && !playerHoldCovers.members[key].getLastAnimationPlayed().endsWith('p')) playerHoldCovers.despawnOnMiss(key);
    }
    else
    {
      if (opponentHoldCovers != null
        && !opponentHoldCovers.members[key].isAnimationNull()
        && !opponentHoldCovers.members[key].getLastAnimationPlayed().endsWith('p')) opponentHoldCovers.despawnOnMiss(key);
    }
  }

  public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
  {
    if (key != NONE)
    {
      for (i in 0...arr.length)
      {
        var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
        for (noteKey in note)
          if (key == noteKey) return i;
      }
    }
    return -1;
  }

  // Hold notes
  private function keysCheck():Void
  {
    // HOLDING
    var holdArray:Array<Bool> = [];
    var pressArray:Array<Bool> = [];
    var releaseArray:Array<Bool> = [];
    for (key in keysArray)
    {
      holdArray.push(controls.pressed(key));
      if (controls.controllerMode)
      {
        pressArray.push(controls.justPressed(key));
        releaseArray.push(controls.justReleased(key));
      }
    }

    // TO DO: Find a better way to handle controller inputs, this should work for now
    if (controls.controllerMode && pressArray.contains(true)) for (i in 0...pressArray.length)
      if (pressArray[i] && strumsBlocked[i] != true) keyPressed(i);

    if (startedCountdown && !inCutscene && !boyfriend.stunned && generatedMusic)
    {
      // rewritten inputs???
      if (notes.length > 0)
      {
        for (n in notes)
        { // I can't do a filter here, that's kinda awesome
          var canHit:Bool = (n != null && !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit);

          if (guitarHeroSustains) canHit = canHit && n.parent != null && n.parent.wasGoodHit;

          if (canHit && n.isSustainNote)
          {
            var released:Bool = !holdArray[n.noteData];

            if (!released) goodNoteHit(n);
          }
        }
      }

      if (!holdArray.contains(true) || endingSong)
      {
        charactersDance();
      }
      #if ACHIEVEMENTS_ALLOWED
      else
        checkForAchievement(['oversinging']);
      #end
    }

    // TO DO: Find a better way to handle controller inputs, this should work for now
    if ((controls.controllerMode || strumsBlocked.contains(true)) && releaseArray.contains(true)) for (i in 0...releaseArray.length)
      if (releaseArray[i] || strumsBlocked[i] == true) keyReleased(i);
  }

  public var allowedToPlayAnimationsBF:Bool = true;
  public var allowedToPlayAnimationsDAD:Bool = true;
  public var allowedToPlayAnimationsMOM:Bool = true;

  public dynamic function charactersDance(onlyBFOpponentDances:Bool = false)
  {
    if (!ClientPrefs.data.characters) return;
    var bfConditions:Bool = boyfriend.allowHoldTimer() && allowedToPlayAnimationsBF;
    var dadConditions:Bool = dad.allowHoldTimer() && allowedToPlayAnimationsDAD;
    var gfConditions:Bool = gf.allowHoldTimer();
    if (onlyBFOpponentDances)
    {
      boyfriend.danceConditions(bfConditions, forcedToIdle);
    }
    else
    {
      // The game now thinks it's needed completely!
      if (opponentMode)
      {
        dad.danceConditions(dadConditions, forcedToIdle);
        gf.danceConditions(gfConditions && !gf.isPlayer, forcedToIdle);
      }
      else
      {
        boyfriend.danceConditions(bfConditions, forcedToIdle);
      }

      for (value in MusicBeatState.getVariables().keys())
      {
        if (MusicBeatState.getVariables().get(value) != null && MusicBeatState.getVariables().exists(value))
        {
          if (value.startsWith('extraCharacter_'))
          {
            var daChar:Character = cast(MusicBeatState.getVariables().get(value), Character);
            if (daChar != null)
            {
              var daCharConditions:Bool = daChar.allowHoldTimer();

              if ((daChar.isPlayer && !daChar.flipMode || !daChar.isPlayer && daChar.flipMode)) daChar.danceConditions(daCharConditions);
            }
          }
        }
      }
    }
  }

  public var playDad:Bool = true;
  public var playBF:Bool = true;

  public dynamic function noteMiss(daNote:Note):Void
  {
    // You didn't hit the key and let it go offscreen, also used by Hurt Notes
    notes.forEachAlive(function(note:Note) {
      if (daNote != note
        && daNote.mustPress
        && daNote.noteData == note.noteData
        && daNote.isSustainNote == note.isSustainNote
        && Math.abs(daNote.strumTime - note.strumTime) < 1) invalidateNote(note, false);
    });
    var dType:Int = 0;

    if (daNote != null)
    {
      dType = daNote.dType;
      if (ClientPrefs.data.resultsScreenType == 'KADE')
      {
        daNote.rating = Rating.timingWindows[0];
        ResultsScreenKadeSubstate.instance.registerHit(daNote, true, cpuControlled, Rating.timingWindows[0].timingWindow);
      }
    }
    else if (songStarted && SONG.notes[curSection] != null) dType = SONG.notes[curSection].dType;

    var result:Dynamic = callOnLuas('noteMissPre', [
      notes.members.indexOf(daNote),
      daNote.noteData,
      daNote.noteType,
      daNote.isSustainNote
    ]);
    var result2:Dynamic = callOnAllHS('noteMissPre', [daNote]);
    if (result == LuaUtils.Function_Stop || result2 == LuaUtils.Function_Stop) return;
    if (stage != null) stage.noteMissStage(daNote);
    noteMissCommon(daNote.noteData, daNote);
    FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.5, 0.6));
    callOnLuas('noteMiss', [
      notes.members.indexOf(daNote),
      daNote.noteData,
      daNote.noteType,
      daNote.isSustainNote,
      dType
    ]);
    callOnAllHS('noteMiss', [daNote]);
  }

  public dynamic function noteMissPress(direction:Int = 1):Void // You pressed a key when there was no notes to press for this key
  {
    if (ClientPrefs.data.ghostTapping) return; // fuck it

    noteMissCommon(direction);
    if (ClientPrefs.data.missSounds && !finishedSong) FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
    if (stage != null) stage.noteMissPressStage(direction);
    callOnScripts('playerOneMissPress', [direction, Conductor.songPosition]);
    callOnScripts('noteMissPress', [direction]);
  }

  public dynamic function noteMissCommon(direction:Int, note:Note = null)
  {
    if (!opponentMode)
    {
      if (playerHoldCovers != null)
      {
        if (note != null) playerHoldCovers.despawnOnMiss(direction, note);
        else
          playerHoldCovers.despawnOnMiss(direction);
      }
    }
    else
    {
      if (opponentHoldCovers != null)
      {
        if (note != null) opponentHoldCovers.despawnOnMiss(direction, note);
        else
          opponentHoldCovers.despawnOnMiss(direction);
      }
    }
    // score and data
    var char:Character = opponentMode ? dad : boyfriend;
    var dType:Int = 0;
    var subtract:Float = pressMissDamage;
    if (note != null) subtract = note.missHealth;

    // GUITAR HERO SUSTAIN CHECK LOL!!!!
    if (note != null && guitarHeroSustains && note.parent == null)
    {
      if (note.tail.length != 0)
      {
        note.alpha = 0.3;
        for (childNote in note.tail)
        {
          childNote.alpha = 0.3;
          childNote.missed = true;
          childNote.canBeHit = false;
          childNote.ignoreNote = true;
          childNote.tooLate = true;
        }
        note.missed = true;
        note.canBeHit = false;

        // subtract += 0.385; // you take more damage if playing with this gameplay changer enabled.
        // i mean its fair :p -crow
        subtract *= note.tail.length + 1;
        // i think it would be fair if damage multiplied based on how long the sustain is -Tahir
      }

      if (note.missed) return;
    }

    if (note != null && guitarHeroSustains && note.parent != null && note.isSustainNote)
    {
      if (note.missed) return;

      var parentNote:Note = note.parent;
      if (parentNote.wasGoodHit && parentNote.tail.length != 0)
      {
        for (child in parentNote.tail)
          if (child != note)
          {
            child.missed = true;
            child.canBeHit = false;
            child.ignoreNote = true;
            child.tooLate = true;
          }
      }
    }

    vocals.volume = 0;
    if (instakillOnMiss) doDeathCheck(true);

    var lastCombo:Int = combo;
    combo = 0;

    health -= subtract * healthLoss;
    if (!practiceMode) songScore -= 10;
    if (!endingSong) songMisses++;
    totalPlayed++;
    RecalculateRating(true);

    if (((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) && gf != null) char = gf;
    if (((note != null && note.momNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].player4Section))
      && mom != null) char = mom;

    if (note != null) dType = note.dType;
    else if (songStarted && SONG.notes[curSection] != null) dType = SONG.notes[curSection].dType;

    playBF = searchLuaVar('playBFSing', 'bool', false);

    var animSuffix:String = (note != null ? note.animSuffix : '');

    var hasMissedAnimations:Bool = false;
    var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length - 1, direction)))] + 'miss' + animSuffix;

    if (char.hasOffsetAnimation(animToPlay)) hasMissedAnimations = true;

    if (char != null && char.hasMissAnimations && hasMissedAnimations && ClientPrefs.data.characters || (note != null && !note.noMissAnimation))
    {
      if (playBF)
      {
        if (char == boyfriend) if (allowedToPlayAnimationsBF) char.playAnim(animToPlay, true);
        else if (char == dad) if (allowedToPlayAnimationsDAD) char.playAnim(animToPlay, true);
        else if (char == gf) char.playAnim(animToPlay, true);
        else if (char == mom) if (allowedToPlayAnimationsMOM) char.playAnim(animToPlay, true);

        if (char != gf && lastCombo > 5 && gf != null && gf.hasOffsetAnimation('sad'))
        {
          gf.playAnim('sad', true);
          gf.specialAnim = true;
        }
      }
    }
  }

  public var comboOp:Int = 0;

  public var popupScoreForOp:Bool = ClientPrefs.data.popupScoreForOp;

  public dynamic function opponentNoteHit(note:Note):Void
  {
    var singData:Int = Std.int(Math.abs(note.noteData));
    var char:Character = null;

    if (!opponentMode)
    {
      var result:Dynamic = callOnLuas('dadPreNoteHit', [note.noteData, note.isSustainNote, note.noteType, note.dType]);
      var result2:Dynamic = callOnAllHS('dadPreNoteHit', [note]);
      var result3:Dynamic = callOnLuas('playerTwoPreSing', [note.noteData, Conductor.songPosition]);
      var result4:Dynamic = callOnAllHS('playerTwoPreSing', [note]);
      var result5:Dynamic = callOnLuas('opponentNoteHitPre', [
        notes.members.indexOf(note),
        Math.abs(note.noteData),
        note.noteType,
        note.isSustainNote,
        note.dType
      ]);
      var result6:Dynamic = callOnAllHS('opponentNoteHitPre', [note]);
      if (result == LuaUtils.Function_Stop || result2 == LuaUtils.Function_Stop || result3 == LuaUtils.Function_Stop || result4 == LuaUtils.Function_Stop
        || result5 == LuaUtils.Function_Stop || result6 == LuaUtils.Function_Stop) return;
    }
    else
    {
      var result:Dynamic = callOnLuas('bfPreNoteHit', [note.noteData, note.isSustainNote, note.noteType, note.dType]);
      var result2:Dynamic = callOnAllHS('bfPreNoteHit', [note]);
      var result3:Dynamic = callOnLuas('playerOnePreSing', [note.noteData, Conductor.songPosition]);
      var result4:Dynamic = callOnAllHS('playerOnePreSing', [note]);
      var result5:Dynamic = callOnLuas('goodNoteHitPre', [
        notes.members.indexOf(note),
        Math.abs(note.noteData),
        note.noteType,
        note.isSustainNote,
        note.dType
      ]);
      var result6:Dynamic = callOnAllHS('goodNoteHitPre', [note]);
      if (result == LuaUtils.Function_Stop || result2 == LuaUtils.Function_Stop || result3 == LuaUtils.Function_Stop || result4 == LuaUtils.Function_Stop
        || result5 == LuaUtils.Function_Stop || result6 == LuaUtils.Function_Stop) return;
    }

    if (note.gfNote && gf != null) char = gf;
    else if ((SONG.notes[curSection] != null && SONG.notes[curSection].player4Section || note.momNote) && mom != null) char = mom;
    else
      char = opponentMode ? boyfriend : dad;

    note.canSplash = ((!note.noteSplashData.disabled && !note.isSustainNote && ClientPrefs.splashOption('Opponent') && !popupScoreForOp)
      && !SONG.options.notITG);
    if (note.canSplash) spawnNoteSplashOnNote(note);

    playDad = opponentMode ? searchForVarsOnScripts('playBFSing', 'bool', false) : searchForVarsOnScripts('playDadSing', 'bool', false);

    var animCheck:String = 'hey';

    var replaceAnimation:String = note.replacentAnimation;
    if (replaceAnimation == '') replaceAnimation = note.replacentAnimation;

    var animToPlay:String = (replaceAnimation == '') ? singAnimations[Std.int(Math.abs(Math.min(singAnimations.length - 1, note.noteData)))]
      + note.animSuffix : replaceAnimation
      + note.animSuffix;
    var hasAnimations:Bool = false;

    var canPlay:Bool = true;
    if (note.isSustainNote)
    {
      var holdAnim:String = animToPlay + '-hold';
      if (char.hasOffsetAnimation(holdAnim)) animToPlay = holdAnim;
      if (char.getLastAnimationPlayed() == holdAnim) canPlay = false;
    }

    if (char.hasOffsetAnimation(animToPlay)) hasAnimations = true;

    var characterCam:String = '';
    if (char == boyfriend) characterCam = 'player';
    else if (char == dad) characterCam = 'opponent';
    else if (char == gf) characterCam = 'girlfriend';
    var camArray:Array<Float> = stage.cameraCharacters.get(characterCam);

    if (ClientPrefs.data.cameraMovement
      && (char.charNotPlaying || !ClientPrefs.data.characters)) moveCameraXY(char, note.noteData, camArray[0], camArray[1]);

    if (!note.skipAnimation && char != null && !note.noAnimation && !char.specialAnim && ClientPrefs.data.characters)
    {
      if (hasAnimations)
      {
        if (playDad)
        {
          if (char == boyfriend)
          {
            if (opponentMode && allowedToPlayAnimationsBF)
            {
              if (canPlay) char.playAnim(animToPlay, true);
              char.holdTimer = 0;
            }
          }
          else if (char == gf)
          {
            if (canPlay) char.playAnim(animToPlay, true);
            char.holdTimer = 0;
            animCheck = 'cheer';
          }
          else if (char == mom)
          {
            if (allowedToPlayAnimationsMOM)
            {
              if (canPlay) char.playAnim(animToPlay, true);
              char.holdTimer = 0;
            }
          }
          else if (char == dad)
          {
            if (!opponentMode && allowedToPlayAnimationsDAD)
            {
              if (canPlay) char.playAnim(animToPlay, true);
              char.holdTimer = 0;
            }
          }

          if (note.noteType == 'Hey!')
          {
            if (char.hasOffsetAnimation(animCheck))
            {
              char.playAnim(animCheck, true);
              if (!char.skipHeyTimer)
              {
                char.specialAnim = true;
                char.heyTimer = 0.6;
              }
            }
          }
        }
      }
    }
    var opponentBool:Bool = true;
    var noteGroup:Strumline = opponentStrums;
    if (OMANDNOTMSANDNOTITG)
    {
      opponentBool = false;
      noteGroup = playerStrums;
    }

    if (splitVocals)
    {
      if (opponentVocals != null) opponentVocals.volume = 1;
    }
    else
    {
      if (vocals != null) vocals.volume = 1;
    }
    if (ClientPrefs.data.LightUpStrumsOP) strumPlayAnim(opponentBool, singData, Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note.isSustainNote);
    note.hitByOpponent = true;
    if (quantSetup)
    {
      if (ClientPrefs.data.quantNotes && !SONG.options.disableStrumRGB)
      {
        noteGroup.members[note.noteData].rgbShader.r = note.rgbShader.r;
        noteGroup.members[note.noteData].rgbShader.g = note.rgbShader.g;
        noteGroup.members[note.noteData].rgbShader.b = note.rgbShader.b;
      }
    }

    if (!note.isSustainNote)
    {
      if (popupScoreForOp)
      {
        comboOp++;
        if (comboOp > 9999) comboOp = 9999;
        popUpScoreOp(note);
      }
    }

    if (!opponentMode)
    {
      if (opponentHoldCovers != null) opponentHoldCovers.spawnOnNoteHit(note);
    }
    else
    {
      if (playerHoldCovers != null) playerHoldCovers.spawnOnNoteHit(note);
    }

    if (stage != null) stage.opponentNoteHitStage(note);

    if (!opponentMode)
    {
      callOnLuas('playerTwoSing', [note.noteData, Conductor.songPosition]);
      callOnAllHS('playerTwoSing', [note]);
      callOnLuas('dadNoteHit', [note.noteData, note.isSustainNote, note.noteType, note.dType]);
      callOnAllHS('dadNoteHit', [note]);
      callOnLuas('opponentNoteHit', [
        notes.members.indexOf(note),
        Math.abs(note.noteData),
        note.noteType,
        note.isSustainNote,
        note.dType
      ]);
      callOnAllHS('opponentNoteHit', [note]);
    }
    else
    {
      callOnLuas('playerOneSing', [note.noteData, Conductor.songPosition]);
      callOnAllHS('playerOneSing', [note]);
      callOnLuas('bfNoteHit', [note.noteData, note.isSustainNote, note.noteType, note.dType]);
      callOnAllHS('bfNoteHit', [note]);
      callOnLuas('goodNoteHit', [
        notes.members.indexOf(note),
        Math.abs(note.noteData),
        note.noteType,
        note.isSustainNote,
        note.dType
      ]);
      callOnAllHS('goodNoteHit', [note]);
    }

    if (!note.isSustainNote) invalidateNote(note, false);
  }

  public dynamic function goodNoteHit(note:Note):Void
  {
    if (note.wasGoodHit) return;
    if (cpuControlled && note.ignoreNote) return;

    var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
    var leData:Int = Math.round(Math.abs(note.noteData));
    var leType:String = note.noteType;
    var leDType:Int = note.dType;
    var singData:Int = Std.int(Math.abs(note.noteData));
    var char:Character = null;

    if (!opponentMode)
    {
      var result:Dynamic = callOnLuas('bfPreNoteHit', [note.noteData, note.isSustainNote, note.noteType, note.dType]);
      var result2:Dynamic = callOnAllHS('bfPreNoteHit', [note]);
      var result3:Dynamic = callOnLuas('playerOnePreSing', [note.noteData, Conductor.songPosition]);
      var result4:Dynamic = callOnAllHS('playerOnePreSing', [note]);
      var result5:Dynamic = callOnLuas('goodNoteHitPre', [
        notes.members.indexOf(note),
        Math.abs(note.noteData),
        note.noteType,
        note.isSustainNote,
        note.dType
      ]);
      var result6:Dynamic = callOnAllHS('goodNoteHitPre', [note]);
      if (result == LuaUtils.Function_Stop || result2 == LuaUtils.Function_Stop || result3 == LuaUtils.Function_Stop || result4 == LuaUtils.Function_Stop
        || result5 == LuaUtils.Function_Stop || result6 == LuaUtils.Function_Stop) return;
    }
    else
    {
      var result:Dynamic = callOnLuas('dadPreNoteHit', [note.noteData, note.isSustainNote, note.noteType, note.dType]);
      var result2:Dynamic = callOnAllHS('dadPreNoteHit', [note]);
      var result3:Dynamic = callOnLuas('playerTwoPreSing', [note.noteData, Conductor.songPosition]);
      var result4:Dynamic = callOnAllHS('playerTwoPreSing', [note]);
      var result5:Dynamic = callOnLuas('opponentNoteHitPre', [
        notes.members.indexOf(note),
        Math.abs(note.noteData),
        note.noteType,
        note.isSustainNote,
        note.dType
      ]);
      var result6:Dynamic = callOnAllHS('opponentNoteHitPre', [note]);
      if (result == LuaUtils.Function_Stop || result2 == LuaUtils.Function_Stop || result3 == LuaUtils.Function_Stop || result4 == LuaUtils.Function_Stop
        || result5 == LuaUtils.Function_Stop || result6 == LuaUtils.Function_Stop) return;
    }

    if (note.gfNote && gf != null) char = gf;
    else if ((SONG.notes[curSection] != null && SONG.notes[curSection].player4Section || note.momNote) && mom != null) char = mom;
    else
      char = opponentMode ? dad : boyfriend;

    note.wasGoodHit = true;

    if (note.hitsound != null && note.hitsoundVolume > 0 && !note.hitsoundDisabled) FlxG.sound.play(Paths.sound(note.hitsound), note.hitsoundVolume);

    if (!note.hitCausesMiss) // Common notes
    {
      playBF = opponentMode ? searchForVarsOnScripts('playDadSing', 'bool', false) : searchForVarsOnScripts('playBFSing', 'bool', false);

      var animCheck:String = 'hey';

      var replaceAnimation:String = note.replacentAnimation;

      var animToPlay:String = (replaceAnimation == '') ? singAnimations[Std.int(Math.abs(Math.min(singAnimations.length - 1, note.noteData)))]
        + note.animSuffix : replaceAnimation
        + note.animSuffix;
      var hasAnimations:Bool = false;

      if (note.isSustainNote)
      {
        var holdAnim:String = animToPlay + '-hold';
        if (char.hasOffsetAnimation(holdAnim)) animToPlay = holdAnim;
      }

      if (char.hasOffsetAnimation(animToPlay)) hasAnimations = true;

      var characterCam:String = '';
      if (char == boyfriend) characterCam = 'player';
      else if (char == dad) characterCam = 'opponent';
      else if (char == gf) characterCam = 'girlfriend';

      var camArray:Array<Float> = stage.cameraCharacters.get(characterCam);

      if (useSLEHUD) {
        SlushiEngineHUD.setRatingText(note.strumTime - Conductor.songPosition);
        if(!isSus)
          SlushiEngineHUD.doComboAngle();
      }
      #if windows
      if(ClientPrefs.data.changeWindowBorderColorWithNoteHit && SlushiEngineHUD.instance.canChangeWindowColorWithNoteHit && !isSus)
        {
          SlushiEngineHUD.setWindowColorWithNoteHit(leData);
        }
      #end

      if (ClientPrefs.data.cameraMovement
        && (char.charNotPlaying || !ClientPrefs.data.characters)) moveCameraXY(char, note.noteData, camArray[0], camArray[1]);

      if (!note.skipAnimation && char != null && !note.noAnimation && !char.specialAnim && ClientPrefs.data.characters)
      {
        if (hasAnimations)
        {
          if (playBF)
          {
            if (char == boyfriend)
            {
              if (!opponentMode && allowedToPlayAnimationsBF)
              {
                char.playAnim(animToPlay, true);
                char.holdTimer = 0;
              }
            }
            else if (char == gf)
            {
              char.playAnim(animToPlay, true);
              char.holdTimer = 0;
              animCheck = 'cheer';
            }
            else if (char == mom)
            {
              if (allowedToPlayAnimationsMOM)
              {
                char.playAnim(animToPlay, true);
                char.holdTimer = 0;
              }
            }
            else if (char == dad)
            {
              if (opponentMode && allowedToPlayAnimationsDAD)
              {
                char.playAnim(animToPlay, true);
                char.holdTimer = 0;
              }
            }

            if (note.noteType == 'Hey!')
            {
              if (char.hasOffsetAnimation(animCheck))
              {
                char.playAnim(animCheck, true);
                if (!char.skipHeyTimer)
                {
                  char.specialAnim = true;
                  char.heyTimer = 0.6;
                }
              }
            }
          }
        }
      }
      var playerBool:Bool = false;
      var noteGroup:Strumline = playerStrums;
      if (OMANDNOTMSANDNOTITG)
      {
        playerBool = true;
        noteGroup = opponentStrums;
      }

      var songLightUp:Bool = (cpuControlled || chartingMode || modchartMode || showCaseMode);
      if (!songLightUp)
      {
        var spr:StrumArrow = noteGroup.members[note.noteData];
        if (spr != null)
        {
          if (ClientPrefs.data.vanillaStrumAnimations)
          {
            if (isSus) spr.holdConfirm();
            else
              spr.playAnim('confirm', true);
          }
          else
          {
            spr.playAnim('confirm', true);
          }
        }
      }
      else
        strumPlayAnim(playerBool, singData, Conductor.stepCrochet * 1.25 / 1000 / playbackRate, isSus);

      vocals.volume = 1;
      if (quantSetup)
      {
        if (ClientPrefs.data.quantNotes && !SONG.options.disableStrumRGB)
        {
          noteGroup.members[note.noteData].rgbShader.r = note.rgbShader.r;
          noteGroup.members[note.noteData].rgbShader.g = note.rgbShader.g;
          noteGroup.members[note.noteData].rgbShader.b = note.rgbShader.b;
        }
      }

      if (!note.isSustainNote)
      {
        combo++;
        if (combo > 9999) combo = 9999;
        popUpScore(note);
      }
      var gainHealth:Bool = true; // prevent health gain, as sustains are threated as a singular note
      if (guitarHeroSustains && note.isSustainNote) gainHealth = false;
      if (gainHealth) health += note.hitHealth * healthGain;

      if (!opponentMode)
      {
        if (playerHoldCovers != null) playerHoldCovers.spawnOnNoteHit(note);
      }
      else
      {
        if (opponentHoldCovers != null) opponentHoldCovers.spawnOnNoteHit(note);
      }

      if (stage != null) stage.goodNoteHitStage(note);
    }
    else // Notes that count as a miss if you hit them (Hurt notes for example)
    {
      if (!note.noMissAnimation)
      {
        switch (note.noteType)
        {
          case 'Hurt Note':
            if (char.hasOffsetAnimation('hurt'))
            {
              char.playAnim('hurt', true);
              char.specialAnim = true;
            }
        }
      }
      noteMiss(note);
      note.canSplash = ((!note.noteSplashData.disabled && !note.isSustainNote && ClientPrefs.splashOption('Player'))
        && !SONG.options.notITG);
      if (note.canSplash) spawnNoteSplashOnNote(note);
    }

    if (!opponentMode)
    {
      callOnLuas('playerOneSing', [note.noteData, Conductor.songPosition]);
      callOnAllHS('playerOneSing', [note]);
      callOnLuas('bfNoteHit', [note.noteData, note.isSustainNote, note.noteType, note.dType]);
      callOnAllHS('bfNoteHit', [note]);
      callOnLuas('goodNoteHit', [
        notes.members.indexOf(note),
        Math.abs(note.noteData),
        note.noteType,
        note.isSustainNote,
        note.dType
      ]);
      callOnAllHS('goodNoteHit', [note]);
    }
    else
    {
      callOnLuas('playerTwoSing', [note.noteData, Conductor.songPosition]);
      callOnAllHS('playerTwoSing', [note]);
      callOnLuas('dadNoteHit', [note.noteData, note.isSustainNote, note.noteType, note.dType]);
      callOnAllHS('dadNoteHit', [note]);
      callOnLuas('opponentNoteHit', [
        notes.members.indexOf(note),
        Math.abs(note.noteData),
        note.noteType,
        note.isSustainNote,
        note.dType
      ]);
      callOnAllHS('opponentNoteHit', [note]);
    }

    if (!note.isSustainNote) invalidateNote(note, false);
  }

  public function invalidateNote(note:Note, unspawnedNotes:Bool):Void
  {
    if (note == null) return;
    note.ignoreNote = true;
    note.active = false;
    note.visible = false;
    note.kill();
    if (!unspawnedNotes) notes.remove(note, true);
    else
      unspawnNotes.remove(note);
    note.destroy();
    note = null;
  }

  public function spawnNoteSplashOnNote(note:Note)
  {
    if (note != null)
    {
      var strum:StrumArrow = note.mustPress ? playerStrums.members[note.noteData] : opponentStrums.members[note.noteData];
      if (strum != null) spawnNoteSplash(note, note.noteData, strum);
    }
  }

  public function spawnNoteSplash(?note:Note = null, data:Int, strum:StrumArrow)
  {
    var splash:NoteSplash = new NoteSplash(!note.mustPress);
    splash.babyArrow = strum;
    splash.spawnSplashNote(note, !note.mustPress);
    if (ClientPrefs.data.splashAlphaAsStrumAlpha)
    {
      var strumsAsSplashAlpha:Null<Float> = null;
      var strums:Strumline = note.mustPress ? playerStrums : opponentStrums;
      strums.forEachAlive(function(spr:StrumArrow) {
        strumsAsSplashAlpha = spr.alpha;
      });
      splash.alpha = strumsAsSplashAlpha;
    }
    note.mustPress ? grpNoteSplashes.add(splash) : grpNoteSplashesCPU.add(splash);
  }

  private function cleanManagers()
  {
    tweenManager.clear();
    timerManager.clear();
  }

  public override function destroy()
  {
    #if LUA_ALLOWED
    for (lua in luaArray)
    {
      lua.call('onDestroy', []);
      lua.stop();
    }
    luaArray = null;
    FunkinLua.customFunctions.clear();
    LuaUtils.killShaders();
    #end

    unspawnNotes = [];
    eventNotes = [];
    noteTypes = [];

    #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    remove(luaDebugGroup);
    luaDebugGroup.destroy();
    #end

    #if HSCRIPT_ALLOWED
    for (script in hscriptArray)
      if (script != null)
      {
        script.call('onDestroy');
        script.destroy();
      }
    hscriptArray = null;

    for (script in scHSArray)
      if (script != null)
      {
        script.callFunc('onDestroy');
        script.destroy();
      }
    scHSArray = null;

    #if HScriptImproved
    for (script in codeNameScripts.scripts)
      if (script != null)
      {
        script.call('onDestroy');
        script.destroy();
      }
    codeNameScripts.scripts = null;
    #end
    #end

    FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
    FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
    #if desktop
    Application.current.window.title = Main.appName;
    #end

    FlxG.camera.setFilters([]);

    FlxG.timeScale = 1;
    #if FLX_PITCH FlxG.sound.music.pitch = 1; #end
    Note.globalRgbShaders = [];
    Note.globalQuantRgbShaders = [];
    backend.NoteTypesConfig.clearNoteTypesData();

    boyfriend.destroy();
    dad.destroy();
    gf.destroy();
    mom.destroy();

    cleanManagers();
    if (stage != null)
    {
      stage.onDestroy();
    }
    instance = null;

    if (FlxG.sound.music != null) FlxG.sound.music.pause();
    if (vocals != null)
    {
      vocals.destroy();
      remove(vocals);
    }
    super.destroy();
  }

  var lastStepHit:Int = -1;

  public var opponentIconScale:Float = 1.2;
  public var playerIconScale:Float = 1.2;
  public var iconBopSpeed:Int = 1;

  override function stepHit()
  {
    if (storyDifficulty < 3)
    {
      if (curStep % 64 == 60 && songName == 'tutorial' && dad.curCharacter == 'gf' && curStep > 64 && curStep < 192)
      {
        if (SONG.needsVoices)
        {
          boyfriend.playAnim('hey', true);
          if (!boyfriend.skipHeyTimer)
          {
            boyfriend.specialAnim = true;
            boyfriend.heyTimer = 0.6;
          }
          dad.playAnim('cheer', true);
          if (!dad.skipHeyTimer)
          {
            dad.specialAnim = true;
            dad.heyTimer = 0.6;
          }
        }
      }

      if (curStep % 32 == 28 #if cpp && curStep != 316 #end && songName == 'bopeebo')
      {
        boyfriend.playAnim('hey', true);
        if (!boyfriend.skipHeyTimer)
        {
          boyfriend.specialAnim = true;
          boyfriend.heyTimer = 0.6;
        }
      }
      if ((curStep == 190 || curStep == 446) && songName == 'bopeebo')
      {
        boyfriend.playAnim('hey', true);
      }
    }

    // AHHH GACIAS EDWHAK POR ESTO!!!!
		var animSkins:Array<String> = ['Default', 'Future', 'NotITG'];
		if (SONG.notITG && notITGMod)
		{
				for (i in 0... animSkins.length){
					if (ClientPrefs.data.noteSkin.contains(animSkins[i])){	
						if (curStep % 4 == 0){
							for (this2 in opponentStrums)
							{
								if (this2.animation.curAnim.name == 'static'){
									this2.rgbShader.r = 0xFF808080;
									this2.rgbShader.b = 0xFF474747;
									this2.rgbShader.enabled = true;
								}
							}
							for (this2 in playerStrums)
							{
								if (this2.animation.curAnim.name == 'static'){
									this2.rgbShader.r = 0xFF808080;
									this2.rgbShader.b = 0xFF474747;
									this2.rgbShader.enabled = true;
								}
							}
						}else if (curStep % 4 == 1){
							for (this2 in opponentStrums)
							{
								if (this2.animation.curAnim.name == 'static'){ 
									this2.rgbShader.enabled = false;
								}
							}
							for (this2 in playerStrums)
							{
								if (this2.animation.curAnim.name == 'static'){
									this2.rgbShader.enabled = false;
								}
							}
						}
					}
				}
		}

    #if !LUA_ALLOWED
    if (notITGMod)
    {
      if (songName == 'tutorial')
      {
        if (curStep < 413)
        {
          if ((curStep % 8 == 4) && (curStep < 254 || curStep > 323))
          {
            receptorTween();
            elasticCamZoom();
            speedBounce();
          }
          else
          {
            if (curStep % 16 == 8 && (curStep >= 254 && curStep < 323))
            {
              receptorTween();
              elasticCamZoom();
              speedBounce();
            }
          }
        }
      }
    }
    #end

    if (stage != null) stage.onStepHit(curStep);

    super.stepHit();

    if (curStep == lastStepHit)
    {
      return;
    }

    // stage.stepHit();

    lastStepHit = curStep;

    setOnScripts('curStep', curStep);
    callOnScripts('stepHit');
    callOnScripts('onStepHit');
  }

  var lastBeatHit:Int = -1;

  override function beatHit()
  {
    if (lastBeatHit >= curBeat) return;

    // move it here, uh, much more useful then just each section
    if (camZooming
      && FlxG.camera.zoom < maxCamZoom
      && ClientPrefs.data.camZooms
      && curBeat % camZoomingMult == 0
      && continueBeatBop)
    {
      FlxG.camera.zoom += 0.015 * camZoomingBop;
      camHUD.zoom += 0.03 * camZoomingBop;
    }

    if (!iconP2.overrideBeatBop)
    {
      iconP2.iconBopSpeed = iconBopSpeed;
      iconP2.beatHit(curBeat);
    }
    if (!iconP1.overrideBeatBop)
    {
      iconP1.iconBopSpeed = iconBopSpeed;
      iconP1.beatHit(curBeat);
    }

    characterBopper(curBeat);

    if (stage != null) stage.onBeatHit(curBeat);

    super.beatHit();
    lastBeatHit = curBeat;

    setOnScripts('curBeat', curBeat);
    callOnScripts('beatHit');
    callOnScripts('onBeatHit');
  }

  public var gfSpeed(default, set):Int = 1; // how frequently gf would play their beat animation

  public function set_gfSpeed(value:Int):Int
  {
    if (Math.isNaN(value)) value = 1;

    gfSpeed = value;
    for (char in [boyfriend, dad, mom, gf])
      if (char != null) char.gfSpeed = value;
    for (characterValue in MusicBeatState.getVariables().keys())
    {
      if (MusicBeatState.getVariables().get(characterValue) != null && MusicBeatState.getVariables().exists(characterValue))
      {
        if (characterValue.startsWith('extraCharacter_'))
        {
          var daChar:Character = cast(MusicBeatState.getVariables().get(characterValue), Character);
          if (daChar != null) daChar.gfSpeed = value;
        }
      }
    }
    return value;
  }

  public function characterBopper(beat:Int):Void
  {
    if (!ClientPrefs.data.characters) return;
    var cpuAlt:Bool = SONG.notes[curSection] != null ? SONG.notes[curSection].CPUAltAnim : false;
    var playerAlt:Bool = SONG.notes[curSection] != null ? SONG.notes[curSection].playerAltAnim : false;
    if (boyfriend != null && boyfriend.beatDance(beat)) boyfriend.danceChar('player', playerAlt, forcedToIdle, allowedToPlayAnimationsBF);
    if (dad != null && dad.beatDance(beat)) dad.danceChar('opponent', cpuAlt, forcedToIdle, allowedToPlayAnimationsDAD);
    if (mom != null && mom.beatDance(beat)) mom.danceChar('opponent', cpuAlt, forcedToIdle, allowedToPlayAnimationsMOM);
    if (gf != null && gf.beatDance(beat)) gf.danceChar('girlfriend');
    for (value in MusicBeatState.getVariables().keys())
    {
      if (MusicBeatState.getVariables().get(value) != null && MusicBeatState.getVariables().exists(value))
      {
        if (value.startsWith('extraCharacter_'))
        {
          var daChar:Character = cast(MusicBeatState.getVariables().get(value), Character);
          if (daChar != null && daChar.beatDance(beat)) daChar.danceChar('custom_char');
        }
      }
    }
  }

  override function sectionHit()
  {
    if (SONG.notes[curSection] != null)
    {
      #if !LUA_ALLOWED
      if (songName == 'tutorial') tweenCamZoom(!SONG.notes[curSection].mustHitSection ? true : false);
      #end
      if (SONG.notes[curSection].changeBPM)
      {
        if (Conductor.bpm != SONG.notes[curSection].bpm) Conductor.bpm = SONG.notes[curSection].bpm;
        setOnScripts('curBpm', Conductor.bpm);
        setOnScripts('crochet', Conductor.crochet);
        setOnScripts('stepCrochet', Conductor.stepCrochet);
      }
      setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
      setOnScripts('altAnim', SONG.notes[curSection].altAnim);
      setOnScripts('gfSection', SONG.notes[curSection].gfSection);
      setOnScripts('playerAltAnim', SONG.notes[curSection].playerAltAnim);
      setOnScripts('CPUAltAnim', SONG.notes[curSection].CPUAltAnim);
      setOnScripts('player4Section', SONG.notes[curSection].player4Section);

      if (!SONG.options.oldBarSystem)
      {
        changeObjectToTweeningColor(timeBarNew.leftBar, SONG.notes[curSection].gfSection, SONG.notes[curSection].mustHitSection,
          (Conductor.stepCrochet * 4) / 1000, 'sineInOut');
      }
    }

    if (stage != null) stage.onSectionHit(curSection);

    super.sectionHit();

    setOnScripts('curSection', curSection);
    callOnScripts('sectionHit');
    callOnScripts('onSectionHit');
  }

  public function changeObjectToTweeningColor(sprite:FlxSprite, isGF:Bool, isMustHit:Bool, ?time:Float = 1, ?easeStr:String = 'linear')
  {
    var curColor:FlxColor = sprite.color;
    curColor.alphaFloat = sprite.alpha;
    if (isGF) FlxTween.color(sprite, time, curColor, CoolUtil.colorFromString(gf.iconColorFormatted), {ease: LuaUtils.getTweenEaseByString(easeStr)});
    else
    {
      if (isMustHit) FlxTween.color(sprite, time, curColor, CoolUtil.colorFromString(boyfriend.iconColorFormatted),
        {ease: LuaUtils.getTweenEaseByString(easeStr)});
      else
        FlxTween.color(sprite, time, curColor, CoolUtil.colorFromString(dad.iconColorFormatted), {ease: LuaUtils.getTweenEaseByString(easeStr)});
    }
  }

  #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
  public function startNoteTypesNamed(type:String)
  {
    #if LUA_ALLOWED
    startLuasNamed('custom_notetypes/scripts/' + type);
    #end
    #if HSCRIPT_ALLOWED
    startHScriptsNamed('custom_notetypes/scripts/' + type);
    startSCHSNamed('custom_notetypes/script/sc/' + type);
    #if HScriptImproved startHSIScriptsNamed('custom_notetypes/scripts/advanced/' + type); #end
    #end
  }

  public function startEventsNamed(event:String)
  {
    #if LUA_ALLOWED
    startLuasNamed('custom_events/scripts/' + event);
    #end
    #if HSCRIPT_ALLOWED
    startHScriptsNamed('custom_events/scripts/' + event);
    startSCHSNamed('custom_events/scripts/sc/' + event);
    #if HScriptImproved startHSIScriptsNamed('custom_events/scripts/advanced/' + event); #end
    #end
  }
  #end

  #if LUA_ALLOWED
  public function startLuasNamed(luaFile:String)
  {
    var scriptFilelua:String = luaFile + '.lua';
    #if MODS_ALLOWED
    var luaToLoad:String = Paths.modFolders(scriptFilelua);
    if (!FileSystem.exists(luaToLoad)) luaToLoad = Paths.getSharedPath(scriptFilelua);

    if (FileSystem.exists(luaToLoad))
    #elseif sys
    var luaToLoad:String = Paths.getSharedPath(scriptFilelua);
    if (OpenFlAssets.exists(luaToLoad))
    #end
    {
      for (script in luaArray)
        if (script.scriptName == luaToLoad) return false;

      new FunkinLua(luaToLoad, 'PLAYSTATE', false);
      return true;
    }
    return false;
  }
  #end

  #if HSCRIPT_ALLOWED
  public function startHScriptsNamed(scriptFile:String)
  {
    for (extn in CoolUtil.haxeExtensions)
    {
      var scriptFileHx:String = scriptFile + '.$extn';
      #if MODS_ALLOWED
      var scriptToLoad:String = Paths.modFolders(scriptFileHx);
      if (!FileSystem.exists(scriptToLoad)) scriptToLoad = Paths.getSharedPath(scriptFileHx);
      #else
      var scriptToLoad:String = Paths.getSharedPath(scriptFileHx);
      #end

      if (FileSystem.exists(scriptToLoad))
      {
        if (Iris.instances.exists(scriptToLoad)) return false;

        initHScript(scriptToLoad);
        return true;
      }
    }
    return false;
  }

  public function initHScript(file:String)
  {
    var newScript:HScript = null;
    try
    {
      var times:Float = Date.now().getTime();
      newScript = new HScript(null, file);
      newScript.call('onCreate');
      hscriptArray.push(newScript);
      Debug.logInfo('initialized Hscript interp successfully: $file (${Std.int(Date.now().getTime() - times)}ms)');
    }
    catch (e:Dynamic)
    {
      var newScript:HScript = cast(Iris.instances.get(file), HScript);
      addTextToDebug('ERROR ON LOADING ($file) - $e', FlxColor.RED);

      if (newScript != null) newScript.destroy();
    }
  }

  public function startSCHSNamed(scriptFile:String)
  {
    for (extn in CoolUtil.haxeExtensions)
    {
      var scriptFileHx:String = scriptFile + '.$extn';
      #if MODS_ALLOWED
      var scriptToLoad:String = Paths.modFolders(scriptFileHx);
      if (!FileSystem.exists(scriptToLoad)) scriptToLoad = Paths.getSharedPath(scriptFileHx);
      #else
      var scriptToLoad:String = Paths.getSharedPath(scriptFileHx);
      #end

      if (FileSystem.exists(scriptToLoad))
      {
        for (script in scHSArray)
          if (script.hsCode.path == scriptToLoad) return false;

        initSCHS(scriptToLoad);
        return true;
      }
    }
    return false;
  }

  public function initSCHS(file:String)
  {
    var newScript:SCScript = null;
    try
    {
      var times:Float = Date.now().getTime();
      newScript = new SCScript();
      newScript.loadScript(file);
      newScript.callFunc('onCreate');
      scHSArray.push(newScript);
      Debug.logInfo('initialized SCHScript interp successfully: $file (${Std.int(Date.now().getTime() - times)}ms)');
    }
    catch (e:Dynamic)
    {
      var script:SCScript = null;
      for (scripts in scHSArray)
        if (scripts.hsCode.path == file) script = scripts;
      var newScript:SCScript = script;
      // addTextToDebug('ERROR ON LOADING ($file) - $e', FlxColor.RED);

      if (newScript != null) newScript.destroy();
    }
  }

  #if HScriptImproved
  public function startHSIScriptsNamed(scriptFile:String)
  {
    for (extn in CoolUtil.haxeExtensions)
    {
      var scriptFileHx:String = scriptFile + '.$extn';
      #if MODS_ALLOWED
      var scriptToLoad:String = Paths.modFolders(scriptFileHx);
      if (!FileSystem.exists(scriptToLoad)) scriptToLoad = Paths.getSharedPath(scriptFileHx);
      #else
      var scriptToLoad:String = Paths.getSharedPath(scriptFileHx);
      #end

      if (FileSystem.exists(scriptToLoad))
      {
        for (script in codeNameScripts.scripts)
          if (script.fileName == scriptToLoad) return false;
        initHSIScript(scriptToLoad);
        return true;
      }
    }
    return false;
  }

  public function initHSIScript(scriptFile:String)
  {
    try
    {
      var times:Float = Date.now().getTime();
      addScript(scriptFile);
      Debug.logInfo('initialized hscript-improved interp successfully: $scriptFile (${Std.int(Date.now().getTime() - times)}ms)');
    }
    catch (e)
    {
      Debug.logError('Error on loading Script!' + e);
    }
  }
  #end
  #end
  public function callOnAllHS(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var result:Dynamic = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
    if (result == null || excludeValues.contains(result)) result = callOnHSI(funcToCall, args, ignoreStops, exclusions, excludeValues);
    if (result == null || excludeValues.contains(result)) result = callOnSCHS(funcToCall, args, ignoreStops, exclusions, excludeValues);
    return result;
  }

  public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    if (stage != null && stage.isCustomStage) stage.callOnScripts(funcToCall, args, ignoreStops, exclusions, excludeValues);

    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
    if (result == null || excludeValues.contains(result))
    {
      result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
      if (result == null || excludeValues.contains(result)) result = callOnHSI(funcToCall, args, ignoreStops, exclusions, excludeValues);
      if (result == null || excludeValues.contains(result)) result = callOnSCHS(funcToCall, args, ignoreStops, exclusions, excludeValues);
    }
    return result;
  }

  public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;
    #if LUA_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isLuaStage) stage.callOnLuas(funcToCall, args);

    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var arr:Array<FunkinLua> = [];
    for (script in luaArray)
    {
      if (script.closed)
      {
        arr.push(script);
        continue;
      }

      if (exclusions.contains(script.scriptName)) continue;

      var myValue:Dynamic = script.call(funcToCall, args);
      if ((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll)
        && !excludeValues.contains(myValue)
        && !ignoreStops)
      {
        returnVal = myValue;
        break;
      }

      if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;

      if (script.closed) arr.push(script);
    }

    if (arr.length > 0) for (script in arr)
      luaArray.remove(script);
    #end
    return returnVal;
  }

  public function callOnHScript(funcToCall:String, ?args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;

    #if HSCRIPT_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.callOnHScript(funcToCall, args);

    if (exclusions == null) exclusions = new Array();
    if (excludeValues == null) excludeValues = new Array();
    excludeValues.push(LuaUtils.Function_Continue);

    var len:Int = hscriptArray.length;
    if (len < 1) return returnVal;
    for (script in hscriptArray)
    {
      @:privateAccess
      if (script == null || !script.exists(funcToCall) || exclusions.contains(script.origin)) continue;

      try
      {
        var callValue = script.call(funcToCall, args);
        var myValue:Dynamic = callValue.methodVal;

        // compiler fuckup fix
        final stopHscript = myValue == LuaUtils.Function_StopHScript;
        final stopAll = myValue == LuaUtils.Function_StopAll;
        if ((stopHscript || stopAll) && !excludeValues.contains(myValue) && !ignoreStops)
        {
          returnVal = myValue;
          break;
        }
        if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;
      }
      catch (e:Dynamic)
      {
        addTextToDebug('ERROR (${script.origin}: $funcToCall) - $e', FlxColor.RED);
      }
    }
    #end

    return returnVal;
  }

  public function callOnHSI(funcToCall:String, ?args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;

    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.callOnHSI(funcToCall, args);

    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var len:Int = codeNameScripts.scripts.length;
    if (len < 1) return returnVal;

    for (script in codeNameScripts.scripts)
    {
      var myValue:Dynamic = script.active ? script.call(funcToCall, args) : null;
      final stopHscript = myValue == LuaUtils.Function_StopHScript;
      final stopAll = myValue == LuaUtils.Function_StopAll;
      if ((stopHscript || stopAll) && !excludeValues.contains(myValue) && !ignoreStops)
      {
        returnVal = myValue;
        break;
      }
      if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;
    }
    #end

    return returnVal;
  }

  public function callOnSCHS(funcToCall:String, ?args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;

    #if HSCRIPT_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.callOnSCHS(funcToCall, args);

    if (exclusions == null) exclusions = new Array();
    if (excludeValues == null) excludeValues = new Array();
    excludeValues.push(LuaUtils.Function_Continue);

    var len:Int = scHSArray.length;
    if (len < 1) return returnVal;
    for (script in scHSArray)
    {
      if (script == null || !script.existsVar(funcToCall) || exclusions.contains(script.hsCode.path)) continue;

      try
      {
        var callValue = script.callFunc(funcToCall, args);
        var myValue:Dynamic = callValue.funcValue;

        // compiler fuckup fix
        final stopHscript = myValue == LuaUtils.Function_StopHScript;
        final stopAll = myValue == LuaUtils.Function_StopAll;
        if ((stopHscript || stopAll) && !excludeValues.contains(myValue) && !ignoreStops)
        {
          returnVal = myValue;
          break;
        }
        if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;
      }
      catch (e:Dynamic)
      {
        addTextToDebug('ERROR (${script.hsCode.path}: $funcToCall) - $e', FlxColor.RED);
      }
    }
    #end

    return returnVal;
  }

  public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    if (stage != null && stage.isCustomStage)
    {
      if (stage.isLuaStage) stage.setOnLuas(variable, arg, exclusions);
      if (stage.isHxStage)
      {
        stage.setOnHScript(variable, arg, exclusions);
        stage.setOnHSI(variable, arg, exclusions);
      }
    }

    if (exclusions == null) exclusions = [];
    setOnLuas(variable, arg, exclusions);
    setOnHScript(variable, arg, exclusions);
    setOnHSI(variable, arg, exclusions);
    setOnSCHS(variable, arg, exclusions);
  }

  public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    #if LUA_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isLuaStage) stage.setOnLuas(variable, arg);

    if (exclusions == null) exclusions = [];
    for (script in luaArray)
    {
      if (exclusions.contains(script.scriptName)) continue;

      script.set(variable, arg);
    }
    #end
  }

  public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    #if HSCRIPT_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.setOnHScript(variable, arg);

    if (exclusions == null) exclusions = [];
    for (script in hscriptArray)
    {
      if (exclusions.contains(script.origin)) continue;

      script.set(variable, arg);
    }
    #end
  }

  public function setOnHSI(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.setOnHSI(variable, arg);

    if (exclusions == null) exclusions = [];
    for (script in codeNameScripts.scripts)
    {
      if (exclusions.contains(script.fileName)) continue;

      script.set(variable, arg);
    }
    #end
  }

  public function setOnSCHS(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    #if HSCRIPT_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.setOnSCHS(variable, arg);

    if (exclusions == null) exclusions = [];
    for (script in scHSArray)
    {
      if (exclusions.contains(script.hsCode.path)) continue;

      script.setVar(variable, arg);
    }
    #end
  }

  public function getOnScripts(variable:String, arg:String, exclusions:Array<String> = null)
  {
    if (stage != null && stage.isCustomStage)
    {
      if (stage.isLuaStage) stage.getOnLuas(variable, arg, exclusions);
      if (stage.isHxStage)
      {
        stage.getOnHScript(variable, exclusions);
        stage.getOnHSI(variable, exclusions);
        stage.getOnSCHS(variable, exclusions);
      }
    }

    if (exclusions == null) exclusions = [];
    getOnLuas(variable, arg, exclusions);
    getOnHScript(variable, exclusions);
    getOnHSI(variable, exclusions);
    getOnSCHS(variable, exclusions);
  }

  public function getOnLuas(variable:String, arg:String, exclusions:Array<String> = null)
  {
    #if LUA_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isLuaStage) stage.getOnLuas(variable, arg, exclusions);

    if (exclusions == null) exclusions = [];
    for (script in luaArray)
    {
      if (exclusions.contains(script.scriptName)) continue;

      script.get(variable, arg);
    }
    #end
  }

  public function getOnHScript(variable:String, exclusions:Array<String> = null)
  {
    #if HSCRIPT_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.getOnHScript(variable, exclusions);

    if (exclusions == null) exclusions = [];
    for (script in hscriptArray)
    {
      if (exclusions.contains(script.origin)) continue;

      script.get(variable);
    }
    #end
  }

  public function getOnHSI(variable:String, exclusions:Array<String> = null)
  {
    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.getOnHSI(variable, exclusions);

    if (exclusions == null) exclusions = [];
    for (script in codeNameScripts.scripts)
    {
      if (exclusions.contains(script.fileName)) continue;

      script.get(variable);
    }
    #end
  }

  public function getOnSCHS(variable:String, exclusions:Array<String> = null)
  {
    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.getOnSCHS(variable, exclusions);

    if (exclusions == null) exclusions = [];
    for (script in scHSArray)
    {
      if (exclusions.contains(script.hsCode.path)) continue;

      script.getVar(variable);
    }
    #end
  }

  public function searchForVarsOnScripts(variable:String, arg:String, result:Bool)
  {
    var result:Dynamic = searchLuaVar(variable, arg, result);
    if (result == null)
    {
      result = searchHxVar(variable, arg, result);
      if (result == null) result = searchHSIVar(variable, arg, result);
    }
    return result;
  }

  public function searchLuaVar(variable:String, arg:String, result:Bool)
  {
    #if LUA_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isLuaStage) stage.searchLuaVar(variable, arg, result);

    for (script in luaArray)
    {
      if (script.get(variable, arg) == result)
      {
        return result;
      }
    }
    #end
    return !result;
  }

  public function searchHxVar(variable:String, arg:String, result:Bool)
  {
    #if HSCRIPT_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.searchHxVar(variable, arg, result);

    for (script in hscriptArray)
    {
      if (LuaUtils.convert(script.get(variable), arg) == result)
      {
        return result;
      }
    }
    #end
    return !result;
  }

  public function searchHSIVar(variable:String, arg:String, result:Bool)
  {
    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.searchHSIVar(variable, arg, result);

    for (script in codeNameScripts.scripts)
    {
      if (LuaUtils.convert(script.get(variable), arg) == result)
      {
        return result;
      }
    }
    #end
    return !result;
  }

  public function getHxNewVar(name:String, type:String):Dynamic
  {
    #if HSCRIPT_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isHxStage) stage.getHxNewVar(name, type);

    var hxVar:Dynamic = null;

    // we prioritize modchart cuz frick you

    for (script in hscriptArray)
    {
      var newHxVar = Std.isOfType(script.get(name), Type.resolveClass(type));
      hxVar = newHxVar;
    }
    if (hxVar != null) return hxVar;
    #end

    return null;
  }

  public function getLuaNewVar(name:String, type:String):Dynamic
  {
    #if LUA_ALLOWED
    if (stage != null && stage.isCustomStage && stage.isLuaStage) stage.getLuaNewVar(name, type);

    var luaVar:Dynamic = null;

    // we prioritize modchart cuz frick you

    for (script in luaArray)
    {
      var newLuaVar = script.get(name, type).getVar(name, type);
      if (newLuaVar != null) luaVar = newLuaVar;
    }
    if (luaVar != null) return luaVar;
    #end

    return null;
  }

  public function strumPlayAnim(isDad:Bool, id:Int, time:Float, isSus:Bool = false)
  {
    var spr:StrumArrow = null;
    if (isDad) spr = opponentStrums.members[id];
    else
      spr = playerStrums.members[id];

    if (spr != null)
    {
      if (ClientPrefs.data.vanillaStrumAnimations)
      {
        if (isSus)
        {
          if (spr.animation.getByName('confirm-hold') != null) spr.holdConfirm();
        }
        else
        {
          if (spr.animation.getByName('confirm') != null) spr.playAnim('confirm', true);
        }
      }
      else
      {
        if (spr.animation.getByName('confirm') != null)
        {
          spr.playAnim('confirm', true);
          spr.resetAnim = time;
        }
      }
    }
  }

  public var ratingName:String = '?';
  public var ratingPercent:Float;
  public var ratingFC:String = '?';

  public function RecalculateRating(badHit:Bool = false)
  {
    setOnScripts('score', songScore);
    setOnScripts('misses', songMisses);
    setOnScripts('hits', songHits);
    setOnScripts('combo', combo);

    var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
    if (ret != LuaUtils.Function_Stop)
    {
      // This ones up here for reasons!
      ratingFC = Rating.generateComboRank(songMisses);

      ratingName = '?';
      if (totalPlayed != 0) // Prevent divide by 0
      {
        // Rating Percent
        ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));

        // Rating Name
        ratingName = ratingStuff[ratingStuff.length - 1][0]; // Uses last string
        if (ratingPercent < 1)
        {
          for (i in 0...ratingStuff.length - 1)
          {
            if (ratingPercent < ratingStuff[i][1])
            {
              ratingName = ratingStuff[i][0];
              break;
            }
          }
        }
      }
    }
    updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce
    setOnScripts('rating', ratingPercent);
    setOnScripts('ratingName', ratingName);
    setOnScripts('ratingFC', ratingFC);
  }

  #if ACHIEVEMENTS_ALLOWED
  private function checkForAchievement(achievesToCheck:Array<String> = null)
  {
    if (chartingMode || modchartMode) return;

    var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice') || ClientPrefs.getGameplaySetting('botplay'));

    if (cpuControlled) return;

    for (name in achievesToCheck)
    {
      if (!Achievements.exists(name)) continue;

      var unlock:Bool = false;
      if (name != WeekData.getWeekFileName() + '_nomiss') // common achievements
      {
        switch (name)
        {
          case 'ur_bad':
            unlock = (ratingPercent < 0.2 && !practiceMode);

          case 'ur_good':
            unlock = (ratingPercent >= 1 && !usedPractice);

          case 'oversinging':
            unlock = (boyfriend.holdTimer >= 10 && !usedPractice);

          case 'hype':
            unlock = (!boyfriendIdled && !usedPractice);

          case 'two_keys':
            unlock = (!usedPractice && keysPressed.length <= 2);

          case 'toastie':
            unlock = (!ClientPrefs.data.cacheOnGPU && !ClientPrefs.data.shaders && ClientPrefs.data.lowQuality && !ClientPrefs.data.antialiasing);

          case 'debugger':
            unlock = (songName == 'test' && !usedPractice);
        }
      }
      else // any FC achievements, name should be "weekFileName_nomiss", e.g: "week3_nomiss";
      {
        if (isStoryMode
          && averageWeekMisses + songMisses < 1
          && (Difficulty.getString().toUpperCase() == 'HARD' || Difficulty.getString().toUpperCase() == 'NIGHTMARE')
          && storyPlaylist.length <= 1
          && !changedDifficulty
          && !usedPractice) unlock = true;
      }

      if (unlock) Achievements.unlock(name);
    }
  }
  #end

  public function cacheCharacter(character:String,
      ?superCache:Bool = false) // Make cacheCharacter function not repeat already preloaded characters! ///NEEDS CONSTANT PRELOADING LOL
  {
    try
    {
      var cacheChar:Character = new Character(0, 0, character);
      Debug.logInfo('found ' + character);
      cacheChar.alpha = 0.00001;
      startCharacterScripts(cacheChar.curCharacter);
      cacheChar.destroy();
      if (superCache)
      {
        add(cacheChar);
        remove(cacheChar);
      }
    }
    catch (e:Dynamic)
    {
      Debug.logWarn('Error on $e');
    }
  }

  #if (!flash && sys)
  public var currentShaders:Array<FlxRuntimeShader> = [];

  private function setShaders(obj:Dynamic, shaders:Array<FNFShader>)
  {
    #if (!flash && sys)
    var filters = [];

    for (shader in shaders)
    {
      filters.push(new ShaderFilter(shader));

      if (!Std.isOfType(obj, FlxCamera))
      {
        obj.shader = shader;

        return true;
      }

      currentShaders.push(shader);
    }
    if (Std.isOfType(obj, FlxCamera)) obj.setFilters(filters);

    return true;
    #end
  }

  private function removeShaders(obj:Dynamic)
  {
    #if (!flash && sys)
    var filters = [];

    for (shader in currentShaders)
    {
      currentShaders.remove(shader);
    }

    if (!Std.isOfType(obj, FlxCamera))
    {
      obj.shader = null;

      return true;
    }
    if (Std.isOfType(obj, FlxCamera)) obj.setFilters(filters);

    return true;
    #end
  }

  public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();

  public function createRuntimeShader(name:String):FlxRuntimeShader
  {
    if (!ClientPrefs.data.shaders) return new FlxRuntimeShader();

    #if (!flash && MODS_ALLOWED && sys)
    if (!runtimeShaders.exists(name) && !initLuaShader(name))
    {
      FlxG.log.warn('Shader $name is missing!');
      return new FlxRuntimeShader();
    }

    var arr:Array<String> = runtimeShaders.get(name);
    return new FlxRuntimeShader(arr[0], arr[1]);
    #else
    FlxG.log.warn("Platform unsupported for Runtime Shaders!");
    return null;
    #end
  }

  public function initLuaShader(name:String, ?glslVersion:Int = 120)
  {
    if (!ClientPrefs.data.shaders) return false;

    #if (MODS_ALLOWED && !flash && sys)
    if (runtimeShaders.exists(name))
    {
      FlxG.log.warn('Shader $name was already initialized!');
      return true;
    }

    for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/shaders/'))
    {
      var frag:String = folder + name + '.frag';
      var vert:String = folder + name + '.vert';
      var found:Bool = false;
      if (FileSystem.exists(frag))
      {
        frag = File.getContent(frag);
        found = true;
      }
      else
        frag = null;

      if (FileSystem.exists(vert))
      {
        vert = File.getContent(vert);
        found = true;
      }
      else
        vert = null;

      if (found)
      {
        runtimeShaders.set(name, [frag, vert]);
        return true;
      }
    }
    #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
    #else
    FlxG.log.warn('Missing shader $name .frag AND .vert files!');
    #end
    #else
    FlxG.log.warn('This platform doesn\'t support Runtime Shaders!', false, false, FlxColor.RED);
    #end
    return false;
  }
  #end

  // does this work. right? -- future me here. yes it does.
  public function changeStage(id:String)
  {
    if (!ClientPrefs.data.background) return;

    if (ClientPrefs.data.characters)
    {
      for (i in [gf, dad, mom, boyfriend])
      {
        remove(i);
      }
    }

    if (ClientPrefs.data.gameCombo)
    {
      remove(comboGroup);
      remove(comboGroupOP);
    }

    stage.onDestroy();

    stage = new Stage(id);
    stage.setupStageProperties(SONG.songId, true);
    stage.curStage = id;
    curStage = id;
    defaultCamZoom = stage.camZoom;
    cameraSpeed = stage.stageCameraSpeed;

    for (i in stage.toAdd)
      add(i);

    for (index => array in stage.layInFront)
    {
      switch (index)
      {
        case 0:
          if (ClientPrefs.data.characters) if (gf != null) add(gf);
          for (bg in array)
            add(bg);
        case 1:
          if (ClientPrefs.data.characters) add(dad);
          for (bg in array)
            add(bg);
        case 2:
          if (ClientPrefs.data.characters) if (mom != null) add(mom);
          for (bg in array)
            add(bg);
        case 3:
          if (ClientPrefs.data.characters) add(boyfriend);
          for (bg in array)
            add(bg);
        case 4:
          if (ClientPrefs.data.characters)
          {
            if (gf != null) add(gf);
            add(dad);
            if (mom != null) add(mom);
            add(boyfriend);
          }
          for (bg in array)
            add(bg);
      }
    }

    if (ClientPrefs.data.gameCombo)
    {
      add(comboGroup);
      add(comboGroupOP);
    }

    if (stage.isCustomStage)
    {
      stage.callOnScripts('onCreatePost'); // i swear if this starts crashing stuff i'mma cry
    }

    setCameraOffsets();
  }

  // LUA MODCHART TO SOURCE FOR HTML5 TUTORIAL MODCHART :) -BoloVEVO (From His Kade Fork Engine!)
  #if !cpp
  function elasticCamZoom()
  {
    var camGroup:Array<FlxCamera> = !usesHUD ? [camHUD, camNoteStuff] : [camHUD];
    for (camShit in camGroup)
    {
      camShit.zoom += 0.06;
      createTween(camShit, {zoom: camShit.zoom - 0.06}, 0.5,
        {
          ease: FlxEase.elasticOut
        });
    }

    FlxG.camera.zoom += 0.06;

    createTweenNum(FlxG.camera.zoom, FlxG.camera.zoom - 0.06, 0.5, {ease: FlxEase.elasticOut}, updateCamZoom.bind(FlxG.camera));
  }

  function receptorTween()
  {
    for (i in 0...strumLineNotes.length)
    {
      createTween(strumLineNotes.members[i], {angle: strumLineNotes.members[i].angle + 360}, 0.5, {ease: FlxEase.smootherStepInOut});
    }
  }

  function updateCamZoom(camGame:FlxCamera, upZoom:Float)
  {
    camGame.zoom = upZoom;
  }

  function speedBounce()
  {
    var secondValue:Float = 0.35;
    var firstValue:Float = songSpeed;

    triggerEvent('Change Scroll Speed', Std.string(firstValue), Std.string(secondValue), 'sineout');
  }

  var isTweeningThisShit:Bool = false;

  function tweenCamZoom(isDad:Bool)
  {
    if (isDad) createTweenNum(FlxG.camera.zoom, FlxG.camera.zoom + 0.3, (Conductor.stepCrochet * 4 / 1000), {
      ease: FlxEase.smootherStepInOut,
    }, updateCamZoom.bind(FlxG.camera));
    else
      createTweenNum(FlxG.camera.zoom, FlxG.camera.zoom - 0.3, (Conductor.stepCrochet * 4 / 1000), {
        ease: FlxEase.smootherStepInOut,
      }, updateCamZoom.bind(FlxG.camera));
  }
  #end

  public function addScript(file:String)
  {
    #if (HSCRIPT_ALLOWED && HScriptImproved)
    for (ext in CoolUtil.haxeExtensions)
    {
      if (haxe.io.Path.extension(file).toLowerCase().contains(ext))
      {
        Debug.logInfo('INITIALIZED SCRIPT: ' + file);
        var script = HScriptCode.create(file);
        if (!(script is codenameengine.scripting.DummyScript))
        {
          codeNameScripts.add(script);

          // Set the things first
          script.set("SONG", SONG);
          script.set("stageManager", backend.stage.Stage.instance);

          // Difference between "Stage" and "gameStageAccess" is that "Stage" is the main class while "gameStageAccess" is the current "Stage" of this class.
          script.set("gameStageAccess", stage);

          // Then CALL SCRIPT
          script.load();
          script.call('onCreate');
        }
      }
    }
    #end
  }

  public function getPropertyInstance(variable:String)
  {
    var split:Array<String> = variable.split('.');
    if (split.length > 1)
    {
      var refelectedItem:Dynamic = null;

      refelectedItem = split[0];

      for (i in 1...split.length - 1)
      {
        refelectedItem = Reflect.getProperty(refelectedItem, split[i]);
      }
      return Reflect.getProperty(refelectedItem, split[split.length - 1]);
    }
    return Reflect.getProperty(PlayState.instance, variable);
  }

  public function setPropertyInstance(variable:String, value:Dynamic)
  {
    var split:Array<String> = variable.split('.');
    if (split.length > 1)
    {
      var refelectedItem:Dynamic = null;

      refelectedItem = split[0];

      for (i in 1...split.length - 1)
      {
        refelectedItem = Reflect.getProperty(refelectedItem, split[i]);
      }
      return Reflect.setProperty(refelectedItem, split[split.length - 1], value);
    }
    return Reflect.setProperty(PlayState.instance, variable, value);
  }

  public function getPropertyNoInstance(variable:String)
  {
    var split:Array<String> = variable.split('.');
    if (split.length > 1)
    {
      var refelectedItem:Dynamic = null;

      refelectedItem = split[0];

      for (i in 1...split.length - 1)
      {
        refelectedItem = Reflect.getProperty(refelectedItem, split[i]);
      }
      return Reflect.getProperty(refelectedItem, split[split.length - 1]);
    }
    return Reflect.getProperty(PlayState, variable);
  }

  public function setPropertyNoInstance(variable:String, value:Dynamic)
  {
    var split:Array<String> = variable.split('.');
    if (split.length > 1)
    {
      var refelectedItem:Dynamic = null;

      refelectedItem = split[0];

      for (i in 1...split.length - 1)
      {
        refelectedItem = Reflect.getProperty(refelectedItem, split[i]);
      }
      return Reflect.setProperty(refelectedItem, split[split.length - 1], value);
    }
    return Reflect.setProperty(PlayState, variable, value);
  }
}
