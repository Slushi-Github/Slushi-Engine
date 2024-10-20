package backend.stage;

import flixel.FlxBasic;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Assets;
import openfl.display.BlendMode;
import backend.stage.*;
import backend.stage.base.*;
import backend.StageData;
import objects.Character;
import objects.note.Note.EventNote;
import objects.note.Note;
import cutscenes.CutsceneHandler;
import cutscenes.DialogueBox;
import substates.GameOverSubstate;
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
#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
#end

class Stage extends backend.stage.base.BaseStage
{
  public static var instance:Stage = null;

  // Stage stuff
  public var curStage:String = '';

  public var hideLastBG:Bool = false; // True = hide last BGs and show ones from slowBacks on certain step, False = Toggle visibility of BGs from SlowBacks on certain step
  // Use visible property to manage if BG would be visible or not at the start of the game
  public var tweenDuration:Float = 2; // How long will it tween hiding/showing BGs, variable above must be set to True for tween to activate
  public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
  // Layering algorithm for noobs: Everything loads by the method of "On Top", example: You load wall first(Every other added BG layers on it), then you load road(comes on top of wall and doesn't clip through it), then loading street lights(comes on top of wall and road)
  public var swagBacks:Map<String, Dynamic> = new Map<String,
    Dynamic>(); // Store BGs here to use them later (for example with slowBacks, using your custom stage event or to adjust position in stage debug menu(press 8 while in PlayState with debug build of the game))
  public var swagGroups:Map<String, FlxTypedGroup<Dynamic>> = new Map<String, FlxTypedGroup<Dynamic>>(); // Store Groups
  public var animatedBacks:Array<FlxSprite> = []; // Store animated backgrounds and make them play animation(Animation must be named Idle!! Else use swagGroup/swagBacks and script it in stepHit/beatHit function of this file!!)
  public var animatedBacks2:Array<FlxSprite> = []; // doesn't interrupt if animation is playing, unlike animatedBacks
  public var layInFront:Array<Array<Dynamic>> = [[], [], [], [], []]; // BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and technically also opponent since Haxe layering moment), fourth [3] in front of arrows and stuff
  public var slowBacks:Map<Int,
    Array<FlxSprite>> = []; // Change/add/remove backgrounds mid song! Format: "slowBacks[StepToBeActivated] = [Sprites,To,Be,Changed,Or,Added];"

  public var stopBGDancing:Bool = false;

  public var songLowercase:String = '';

  public var isCustomStage:Bool = false;
  public var isLuaStage:Bool = false;
  public var isHxStage:Bool = false;

  #if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

  #if HSCRIPT_ALLOWED
  public var hscriptArray:Array<psychlua.HScript> = [];
  public var scHSArray:Array<scripting.SCScript> = [];
  #end

  #if (HSCRIPT_ALLOWED && HScriptImproved)
  public var codeNameScripts:codenameengine.scripting.ScriptPack;
  #end

  public var preloading:Bool = false;

  public var stageName:String = "";
  public var stageId:String = "";

  public function new(daStage:String, ?preloading:Bool = false)
  {
    super();
    if (daStage == null) daStage = 'mainStage';

    this.curStage = daStage;
    this.preloading = preloading;

    instance = this;

    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (codeNameScripts == null) (codeNameScripts = new codenameengine.scripting.ScriptPack('Stage')).setParent(this);
    #end
  }

  public var defaultStage:backend.stage.base.BaseStage = null;

  public function setupStageProperties(songName:String, ?stageChanged:Bool = false)
  {
    if (!ClientPrefs.data.background) return;
    if (songName != null) songLowercase = songName.toLowerCase();
    loadStageJson(curStage, stageChanged);

    var jsonPath:String = Paths.getPath('data/stages/$curStage.json', TEXT);
    Debug.logInfo('STAGE INFO JSON ? $jsonPath');

    isCustomStage = true;
    var missingJson:Bool = #if MODS_ALLOWED !FileSystem.exists(jsonPath) && #end!Assets.exists(jsonPath);
    if (missingJson)
    {
      Debug.logWarn('$curStage.json not found, using the default stage');
      curStage = 'mainStage'; // defaults to stage if we can't find the path
    }

    #if BASE_GAME_FILES
    switch (curStage)
    {
      case 'mainStage':
        defaultStage = new MainStage();
      case 'spookyMansion':
        defaultStage = new SpookyMansion();
      case 'phillyTrain':
        defaultStage = new PhillyTrain();
      case 'phillyBlazin':
        defaultStage = new PhillyBlazin();
      case 'phillyStreets':
        defaultStage = new PhillyStreets();
      case 'limoRide':
        defaultStage = new LimoRide();
      case 'mallXMas':
        defaultStage = new MallXMas();
      case 'mallEvil':
        defaultStage = new MallEvil();
      case 'school':
        defaultStage = new School();
      case 'schoolEvil':
        defaultStage = new SchoolEvil();
      case 'tankmanBattlefield':
        defaultStage = new TankmanBattlefield();
    }
    #end

    if (defaultStage != null)
    {
      defaultStage.buildStage(this);
      return;
    }

    isLuaStage = true;
    isHxStage = true;

    // Looks for two types of stages or more
    startStageScriptsNamed(curStage, preloading);
    setOnScripts('stageSpriteHandler', stageSpriteHandler);
  }

  public var camZoom:Float = 1.05;

  // moving the offset shit here too
  public var gfXOffset:Float = 0;
  public var dadXOffset:Float = 0;
  public var bfXOffset:Float = 0;
  public var momXOffset:Float = 0;
  public var gfYOffset:Float = 0;
  public var dadYOffset:Float = 0;
  public var bfYOffset:Float = 0;
  public var momYOffset:Float = 0;

  public var bfScrollFactor:Array<Float> = [1, 1]; // ye damn scroll factors!
  public var dadScrollFactor:Array<Float> = [1, 1];
  public var gfScrollFactor:Array<Float> = [0.95, 0.95];

  // stage stuff for easy stuff now softcoded into the stage.json
  // Rating Stuff
  public var stageUISuffixShit:String = '';
  public var stageUIPrefixShit:String = '';

  // CountDown Stuff
  public var stageHas3rdIntroAsset:Bool = false;
  public var stageIntroAssets:Array<String> = null;
  public var stageIntroSoundsSuffix:String = '';
  public var stageIntroSoundsPrefix:String = '';

  public var boyfriendCameraOffset:Array<Float> = [0, 0];
  public var opponentCameraOffset:Array<Float> = [0, 0];
  public var opponent2CameraOffset:Array<Float> = [0, 0];
  public var girlfriendCameraOffset:Array<Float> = [0, 0];

  public var hideGirlfriend:Bool = false;

  public var stageCameraSpeed:Float = 1;

  public var stageRatingOffsetXPlayer:Float = 0;
  public var stageRatingOffsetYPlayer:Float = 0;

  public var stageRatingOffsetXOpponent:Float = 0;
  public var stageRatingOffsetYOpponent:Float = 0;

  public var stageIntroSpriteScales:Array<Array<Float>> = null;

  public var stageRatingScales:Array<Float> = null;

  public var disabledIntroSounds:Bool = false;

  public var cameraCharacters:Map<String, Array<Float>> = new Map<String, Array<Float>>();

  public function setupWeekDir(stage:String, stageDir:String)
  {
    var directory:String = 'shared';
    var weekDir:String = stageDir;
    stageDir = null;

    if (weekDir != null && weekDir.length > 0) directory = weekDir;

    Debug.logInfo('directory: $directory');
    Paths.setCurrentLevel(directory);
  }

  public function loadStageJson(stage:String, ?stageChanged:Bool = false)
  {
    var stageData:StageFile = StageData.getStageFile(stage);
    var stageDir:String = '';
    if (stageData == null)
    {
      // Stage couldn't be found, create a dummy stage for preventing a crash
      Debug.logInfo('stage failed to have .json or .json didn\'t load properly, loading stage.json....');
    }
    stageDir = stageData.directory;

    if (stageChanged) setupWeekDir(stage, stageDir);

    camZoom = stageData.defaultZoom;

    if (stageData.ratingSkin != null)
    {
      stageUIPrefixShit = stageData.ratingSkin[0];
      stageUISuffixShit = stageData.ratingSkin[1];
    }

    if (stageData.countDownAssets != null) stageIntroAssets = stageData.countDownAssets;

    if (stageData.introSoundsSuffix != null)
    {
      stageIntroSoundsSuffix = stageData.introSoundsSuffix;
    }
    else
      stageIntroSoundsSuffix = stageData.isPixelStage ? '-pixel' : '';

    if (stageData.introSoundsPrefix != null)
    {
      stageIntroSoundsPrefix = stageData.introSoundsPrefix;
    }
    else
      stageIntroSoundsPrefix = '';

    if (stageData.introSpriteScales != null)
    {
      stageIntroSpriteScales = stageData.introSpriteScales;
    }
    else
      stageIntroSpriteScales = stageData.isPixelStage ? [[6, 6], [6, 6], [6, 6], [6, 6]] : [[1, 1], [1, 1], [1, 1], [1, 1]];

    disabledIntroSounds = stageData.disableIntroSounds == true ? true : false;

    if (stageData.ratingOffsets != null)
    {
      stageRatingOffsetXPlayer = stageData.ratingOffsets[0][0];
      stageRatingOffsetYPlayer = stageData.ratingOffsets[0][1];

      stageRatingOffsetXOpponent = stageData.ratingOffsets[1][0];
      stageRatingOffsetYOpponent = stageData.ratingOffsets[1][1];
    }

    if (stageData.ratingScales != null) stageRatingScales = stageData.ratingScales;

    PlayState.stageUI = "normal";
    if (stageData.stageUI != null && stageData.stageUI.trim().length > 0) PlayState.stageUI = stageData.stageUI;
    else if (stageData.isPixelStage == true) // Backward compatibility
      PlayState.stageUI = "pixel";

    hideGirlfriend = stageData.hide_girlfriend;

    if (stageData.boyfriend != null)
    {
      bfXOffset = stageData.boyfriend[0] - 770;
      bfYOffset = stageData.boyfriend[1] - 100;
    }
    if (stageData.girlfriend != null)
    {
      gfXOffset = stageData.girlfriend[0] - 400;
      gfYOffset = stageData.girlfriend[1] - 130;
    }
    if (stageData.opponent != null)
    {
      dadXOffset = stageData.opponent[0] - 100;
      dadYOffset = stageData.opponent[1] - 100;
    }
    if (stageData.opponent2 != null)
    {
      momXOffset = stageData.opponent2[0] - 100;
      momYOffset = stageData.opponent2[1] - 100;
    }

    if (stageData.camera_speed != null) stageCameraSpeed = stageData.camera_speed;

    boyfriendCameraOffset = stageData.camera_boyfriend;
    if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start
      boyfriendCameraOffset = [0, 0];

    opponentCameraOffset = stageData.camera_opponent;
    if (opponentCameraOffset == null) opponentCameraOffset = [0, 0];

    girlfriendCameraOffset = stageData.camera_girlfriend;
    if (girlfriendCameraOffset == null) girlfriendCameraOffset = [0, 0];

    opponent2CameraOffset = stageData.camera_opponent2;
    if (opponent2CameraOffset == null) opponent2CameraOffset = [0, 0];

    stageId = stageData.id;
    if (stageData.id == null) stageId = curStage + '-Stage';

    stageName = stageData.name;
    if (stageData.name == null) stageName = curStage;

    if (stageData.objects != null && stageData.objects.length > 0)
    {
      var list:Map<String, FlxSprite> = StageData.addObjectsToState(stageData.objects, null, null, null, null, this);
      for (key => spr in list)
        if (!StageData.reservedNames.contains(key)) swagBacks.set(key, spr);
    }

    var extraData:Dynamic = stageData._extraData;
    if (extraData != null)
    {
      if (extraData._cameraMovement != null)
      {
        cameraCharacters.set('player', extraData._cameraMovement.player != null ? extraData._cameraMovement.player : [50, 60]);
        cameraCharacters.set('opponent', extraData._cameraMovement.opponent != null ? extraData._cameraMovement.opponent : [50, 60]);
        cameraCharacters.set('girlfriend', extraData._cameraMovement.girlfriend != null ? extraData._cameraMovement.girlfriend : [50, 60]);
      }
    }

    if (cameraCharacters.get('player') == null && cameraCharacters.get('opponent') == null && cameraCharacters.get('girlfriend') == null)
    {
      cameraCharacters.set('player', [50, 60]);
      cameraCharacters.set('opponent', [50, 60]);
      cameraCharacters.set('girlfriend', [50, 60]);
    }
  }

  public function onCreatePost()
  {
    if (defaultStage != null) defaultStage.createPost();
  }

  public function onOpenSubState(SubState:flixel.FlxSubState)
  {
    if (defaultStage != null) defaultStage.openSubState(SubState);
  }

  public function onCloseSubState():Void
  {
    if (defaultStage != null) defaultStage.closeSubState();
  }

  public function onUpdate(elapsed:Float):Void
  {
    if (defaultStage != null) defaultStage.update(elapsed);

    callOnScripts('onStageUpdate', [elapsed]);
    callOnScripts('stageUpdate', [elapsed]);
  }

  public function onStepHit(curStep:Int):Void
  {
    final array = slowBacks[curStep];
    if (array != null && array.length > 0)
    {
      if (hideLastBG)
      {
        for (bg in swagBacks)
        {
          if (!array.contains(bg))
          {
            var tween = FlxTween.tween(bg, {alpha: 0}, tweenDuration,
              {
                onComplete: function(tween:FlxTween):Void {
                  bg.visible = false;
                }
              });
          }
        }
        for (bg in array)
        {
          bg.visible = true;
          FlxTween.tween(bg, {alpha: 1}, tweenDuration);
        }
      }
      else
      {
        for (bg in array)
          bg.visible = !bg.visible;
      }
    }

    if (defaultStage != null)
    {
      defaultStage.curStep = curStep;
      defaultStage.stepHit();
    }

    setOnScripts('curStageStep', curStep);
    callOnScripts('stageStepHit');
    callOnScripts('onStageStepHit');
  }

  public function onBeatHit(curBeat:Int):Void
  {
    if (!ClientPrefs.data.lowQuality && ClientPrefs.data.background && animatedBacks.length > 0)
    {
      for (bg in animatedBacks)
      {
        if (!stopBGDancing) bg.animation.play('idle', true);
      }
    }

    if (!ClientPrefs.data.lowQuality && ClientPrefs.data.background && animatedBacks2.length > 0)
    {
      for (bg in animatedBacks2)
      {
        if (!stopBGDancing) bg.animation.play('idle');
      }
    }

    if (defaultStage != null)
    {
      defaultStage.curBeat = curBeat;
      defaultStage.beatHit();
    }

    setOnScripts('curStageBeat', curBeat);
    callOnScripts('stageBeatHit');
    callOnScripts('onStageBeatHit');
  }

  public function onSectionHit(curSection:Int):Void
  {
    if (defaultStage != null)
    {
      defaultStage.curSection = curSection;
      defaultStage.sectionHit();
    }
    setOnScripts('curStageSection', curSection);
    callOnScripts('stageSectionHit');
    callOnScripts('onStageSectionHit');
  }

  public function eventCalledStage(eventName:String, eventParams:Array<String>, strumTime:Float):Void
  {
    var flValues:Array<Null<Float>> = [];
    for (i in 0...eventParams.length - 1)
    {
      if (!Math.isNaN(Std.parseFloat(eventParams[i]))) flValues.push(Std.parseFloat(eventParams[i]));
      else
        flValues.push(null);
    }

    if (defaultStage != null) defaultStage.onEvent(eventName, eventParams, flValues, strumTime);
  }

  public function countdownTickStage(count:Countdown, num:Int)
  {
    if (defaultStage != null) defaultStage.countdownTick(count, num);
  }

  public function startSongStage()
  {
    if (defaultStage != null) defaultStage.startSong();
  }

  public function eventPushedStage(event:EventNote)
  {
    if (defaultStage != null) defaultStage.onEventPushed(event);
  }

  // Events
  public function eventPushedUniqueStage(event:EventNote)
  {
    if (defaultStage != null) defaultStage.onEventPushedUnique(event);
  }

  // Note Hit/Miss
  public function goodNoteHitStage(note:Note)
  {
    if (defaultStage != null) defaultStage.goodNoteHit(note);
  }

  public function opponentNoteHitStage(note:Note)
  {
    if (defaultStage != null) defaultStage.opponentNoteHit(note);
  }

  public function noteMissStage(note:Note)
  {
    if (defaultStage != null) defaultStage.noteMiss(note);
  }

  public function noteMissPressStage(direction:Int)
  {
    if (defaultStage != null) defaultStage.noteMissPress(direction);
  }

  // start/end callback functions
  public function setStartCallbackStage(myfn:Void->Void)
  {
    if (!onPlayState) return;
    PlayState.instance.startCallback = myfn;
  }

  public function setEndCallbackStage(myfn:Void->Void)
  {
    if (!onPlayState) return;
    PlayState.instance.endCallback = myfn;
  }

  // overrides
  public function startCountdownStage()
  {
    if (onPlayState) return PlayState.instance.startCountdown();
    else
      return false;
  }

  public function endSongStage()
  {
    if (onPlayState) return PlayState.instance.endSong();
    else
      return false;
  }

  #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
  public function startStageScriptsNamed(stage:String, preloading:Bool = false)
  {
    #if LUA_ALLOWED
    startLuasNamed('scripts/stages/' + stage, preloading);
    #end
    #if HSCRIPT_ALLOWED
    startHScriptsNamed('scripts/stages/' + stage);
    startSCHSNamed('scripts/stages/sc/' + stage);
    #if HScriptImproved startHSIScriptsNamed('scripts/stages/advanced/' + stage); #end
    #end
  }
  #end

  #if LUA_ALLOWED
  public function startLuasNamed(luaFile:String, ?preloading:Bool = false)
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

      new FunkinLua(luaToLoad, 'STAGE', preloading);
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
      newScript = new HScript(null, file, true, true);
      newScript.executeFunction('onCreate');
      hscriptArray.push(newScript);
      Debug.logInfo('initialized Hscript interp successfully: $file (${Std.int(Date.now().getTime() - times)}ms)');
    }
    catch (e:Dynamic)
    {
      var newScript:HScript = cast(Iris.instances.get(file), HScript);
      HScript.hscriptTrace('ERROR ON LOADING ($file) - $e', FlxColor.RED);

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
      newScript.executeFunc('onCreate');
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
      Debug.logError('Error on loading Script! $e');
    }
  }
  #end
  #end
  public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;
    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
    if (result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
    if (result == null || excludeValues.contains(result)) result = callOnHSI(funcToCall, args, ignoreStops, exclusions, excludeValues);
    if (result == null || excludeValues.contains(result)) result = callOnSCHS(funcToCall, args, ignoreStops, exclusions, excludeValues);
    return result;
  }

  public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;
    #if LUA_ALLOWED
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

  public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ignoreStops:Bool = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;

    #if HSCRIPT_ALLOWED
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
        var myValue:Dynamic = callValue.signature;

        // compiler fuckup fix
        if ((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll)
          && !excludeValues.contains(myValue)
          && !ignoreStops)
        {
          returnVal = myValue;
          break;
        }
        if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;
      }
      catch (e:Dynamic)
      {
        HScript.hscriptTrace('ERROR (${script.origin}: $funcToCall) - $e', FlxColor.RED);
      }
    }
    #end

    return returnVal;
  }

  public function callOnHSI(funcToCall:String, args:Array<Dynamic> = null, ignoreStops:Bool = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;

    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var len:Int = codeNameScripts.scripts.length;
    if (len < 1) return returnVal;

    for (script in codeNameScripts.scripts)
    {
      var myValue:Dynamic = script.active ? script.call(funcToCall, args) : null;
      if ((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll)
        && !excludeValues.contains(myValue)
        && !ignoreStops)
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
        var myValue:Dynamic = callValue.funcReturn;

        // compiler fuckup fix
        if ((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll)
          && !excludeValues.contains(myValue)
          && !ignoreStops)
        {
          returnVal = myValue;
          break;
        }
        if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;
      }
      catch (e:Dynamic) {}
    }
    #end

    return returnVal;
  }

  public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    if (exclusions == null) exclusions = [];
    setOnLuas(variable, arg, exclusions);
    setOnHScript(variable, arg, exclusions);
    setOnHSI(variable, arg, exclusions);
    setOnSCHS(variable, arg, exclusions);
  }

  public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    #if LUA_ALLOWED
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
    if (exclusions == null) exclusions = [];
    getOnLuas(variable, arg, exclusions);
    getOnHScript(variable, exclusions);
    getOnHSI(variable, exclusions);
    getOnSCHS(variable, exclusions);
  }

  public function getOnLuas(variable:String, arg:String, exclusions:Array<String> = null)
  {
    #if LUA_ALLOWED
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
    #if HSCRIPT_ALLOWED
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

  public function setSwagGraphicSize(name:String, val:Float = 1, ?updateHitBox:Bool = true)
  {
    // because this is different apparently

    if (swagBacks.exists(name))
    {
      var shit = swagBacks.get(name);

      shit.setGraphicSize(Std.int(shit.width * val));
      if (updateHitBox) shit.updateHitbox();
    }
  }

  public function getPropertyObject(variable:String)
  {
    var split:Array<String> = variable.split('.');
    if (split.length > 1)
    {
      var refelectedItem:Dynamic = null;

      refelectedItem = swagBacks.get(split[0]);

      for (i in 1...split.length - 1)
      {
        refelectedItem = Reflect.getProperty(refelectedItem, split[i]);
      }
      return Reflect.getProperty(refelectedItem, split[split.length - 1]);
    }
    return Reflect.getProperty(Stage.instance, swagBacks.get(variable));
  }

  public function setPropertyObject(variable:String, value:Dynamic)
  {
    var split:Array<String> = variable.split('.');
    if (split.length > 1)
    {
      var refelectedItem:Dynamic = null;

      refelectedItem = swagBacks.get(split[0]);

      for (i in 1...split.length - 1)
      {
        refelectedItem = Reflect.getProperty(refelectedItem, split[i]);
      }
      return Reflect.setProperty(refelectedItem, split[split.length - 1], value);
    }
    return Reflect.setProperty(Stage.instance, swagBacks.get(variable), value);
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
    return Reflect.getProperty(Stage, variable);
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
    return Reflect.setProperty(Stage, variable, value);
  }

  public function getPropertyInstance(variable:String)
  {
    var split:Array<String> = variable.split('.');
    if (split.length > 1)
    {
      var refelectedItem:Dynamic = null;

      refelectedItem = swagBacks.get(split[0]);

      for (i in 1...split.length - 1)
      {
        refelectedItem = Reflect.getProperty(refelectedItem, split[i]);
      }
      return Reflect.getProperty(refelectedItem, split[split.length - 1]);
    }
    return Reflect.getProperty(Stage.instance, swagBacks.get(variable));
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
    return Reflect.setProperty(Stage, variable, value);
  }

  public function stageSpriteHandler(sprite:Dynamic = null, place:Int = -1, tag:String = '', ?addToGroup:Bool = false):Void
  {
    if (sprite == null) return;

    if (place > -1)
    {
      /*
        for those who don't know
        layInFront[0].push(sprite) what the 0 means is that the "sprite" is on top of gf but no other characters
        layInFront[1].push(sprite) what the 1 means is that the "sprite" is on top of mom but no other characters
        layInFront[2].push(sprite) what the 2 means is that the "sprite" is on top of dad ???
        layInFront[3].push(sprite) what the 3 means is that the "sprite" is on top of bf (but since haxeflixel is goofy it also means on top of dad) ??
        layInFront[4].push(sprite) what the 4 means is that the "sprite" is on top of all of the characters
        also .push(sprite) means it is adding the sprite like the rest from toAddPushed(sprite) but with layering
       */
      layInFront[place].push(sprite);
    }
    else
    {
      /*
        just adding the sprite.
       */
      toAdd.push(sprite);
    }

    var newTag:String = tag;

    if (newTag.endsWith('-UPPER')) newTag = newTag.substring(0, newTag.length - 6).toUpperCase();
    else if (newTag.endsWith('-lower')) newTag = newTag.substring(0, newTag.length - 6).toLowerCase();

    if (addToGroup) setSwagGroup(newTag, sprite, true);
    else
      swagBacks[newTag] = sprite;
  }

  public function setSwagGroup(tag:String, swagedSprite:FlxTypedGroup<Dynamic> = null, ?skipTagAdjust:Bool = false)
  {
    var newTag:String = tag;

    if (!skipTagAdjust)
    {
      if (newTag.endsWith('-UPPER')) newTag = newTag.substring(0, newTag.length - 6).toUpperCase();
      else if (newTag.endsWith('-lower')) newTag = newTag.substring(0, newTag.length - 6).toLowerCase();
    }

    if (swagedSprite != null) swagGroups[newTag] = swagedSprite;
  }

  public function addAnimatedBack(animatedBack:FlxSprite = null)
    if (animatedBack != null) animatedBacks.push(animatedBack);

  public function addAnimatedBack2(animatedBack2:FlxSprite = null)
    if (animatedBack2 != null) animatedBacks2.push(animatedBack2);

  public function addSlowBackAction(curStep:Int, slowedBacks:Array<FlxSprite> = null)
  {
    if (slowedBacks != null) slowBacks[curStep] = slowedBacks;
  }

  public function addScript(file:String)
  {
    #if (HSCRIPT_ALLOWED && HScriptImproved)
    for (ext in CoolUtil.haxeExtensions)
    {
      if (file.toLowerCase().contains('.$ext'))
      {
        Debug.logInfo('INITIALIZED');
        var script = HScriptCode.create(file);
        if (!(script is codenameengine.scripting.DummyScript))
        {
          codeNameScripts.add(script);

          // Set the things first
          script.set("game", PlayState?.instance);
          script.set("songLowercase", songLowercase);

          // Then CALL SCRIPT
          script.load();
          script.call('onCreate');
        }
      }
    }
    #end
  }

  public function onDestroy():Void
  {
    #if LUA_ALLOWED
    for (lua in luaArray)
    {
      lua.call('onDestroy', []);
      lua.stop();
    }
    luaArray = null;
    #end

    curStage = null;
    instance = null;

    if (defaultStage != null) defaultStage.destroy();

    for (sprite in swagBacks.keys())
    {
      if (swagBacks[sprite] != null) swagBacks[sprite].destroy();
    }

    swagBacks.clear();

    #if HSCRIPT_ALLOWED
    for (script in hscriptArray)
      if (script != null)
      {
        script.executeFunction('onDestroy');
        script.destroy();
      }
    hscriptArray = null;

    for (script in scHSArray)
      if (script != null)
      {
        script.executeFunc('onDestroy');
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
    codeNameScripts = null;
    #end
    #end

    while (toAdd.length > 0)
    {
      toAdd.remove(toAdd[0]);
      if (toAdd[0] != null) toAdd[0].destroy();
    }

    while (animatedBacks.length > 0)
    {
      animatedBacks.remove(animatedBacks[0]);
      if (animatedBacks[0] != null) animatedBacks[0].destroy();
    }

    for (array in layInFront)
    {
      for (sprite in array)
      {
        if (sprite != null) sprite.destroy();
        array.remove(sprite);
      }
    }

    for (swag in swagGroups.keys())
    {
      if (swagGroups[swag].members != null) for (member in swagGroups[swag].members)
      {
        swagGroups[swag].members.remove(member);
        member.destroy();
      }
    }

    swagGroups.clear();
  }

  public function checkNameMatch(stageName:String):Bool
  {
    if (this.stageId == stageName || this.stageName == stageName || this.curStage == stageName) return true;
    return false;
  }
}
