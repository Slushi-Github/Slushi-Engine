#if LUA_ALLOWED
package psychlua;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.util.FlxAxes;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import backend.WeekData;
import backend.Highscore;
import openfl.utils.Assets;
import openfl.filters.BitmapFilter;
import cutscenes.DialogueBoxPsych;
import objects.note.StrumArrow;
import objects.note.Note;
import objects.note.NoteSplash;
import objects.Character;
import objects.HealthIcon;
import states.MainMenuState;
import states.StoryMenuState;
import slushi.substates.SlushiPauseSubState;
import substates.GameOverSubstate;
import psychlua.LuaUtils;
import psychlua.LuaUtils.LuaTweenOptions;
#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end
import psychlua.ModchartSprite;
import haxe.PosInfos;
import tjson.TJSON as Json;
import lime.app.Application;

typedef LuaCamera =
{
  var cam:FlxCamera;
  var shaders:Array<BitmapFilter>;
  var shaderNames:Array<String>;
}

/**
 * Where the files are looked from (As in place). Used for Lua.
 */
enum abstract FileInstance(String) to String from String
{
  var PLAYSTATE = 'PLAYSTATE';
  var STAGE = 'STAGE';
  var MODCHARTEDITOR = 'MODCHARTEDITOR';
  var CUSTOM = 'CUSTOM';
  var CHARACTER = 'CHARACTER';
}

class FunkinLua
{
  public var lua:State = null;
  public var camTarget:FlxCamera;
  public var modFolder:String = null;

  public var scriptName:String = '';

  public var preloading:Bool = false;

  public var typeInstance:FileInstance = PLAYSTATE;

  public var isStageLua(get, never):Bool;

  public function get_isStageLua():Bool
  {
    if (typeInstance == STAGE) return true;
    return false;
  }

  public var notScriptName:String = '';

  public var closed:Bool = false;

  public static var instance:FunkinLua = null;

  #if HSCRIPT_ALLOWED
  public var hscript:HScript = null;
  #end

  public var callbacks:Map<String, Dynamic> = new Map<String, Dynamic>();

  public static var customFunctions:Map<String, Dynamic> = new Map<String, Dynamic>();

  public static var lua_Cameras:Map<String, LuaCamera> = [];
  public static var lua_Shaders:Map<String, shaders.ShaderBase> = [];
  public static var lua_Custom_Shaders:Map<String, codenameengine.shaders.CustomShader> = [];

  public function new(scriptName:String, instance:FileInstance, preloading:Bool = false, notScriptName:String = null)
  {
    final times:Float = Date.now().getTime();
    final game:PlayState = PlayState.instance;

    if (game != null)
    {
      lua_Cameras.set("game", {cam: game.camGame, shaders: [], shaderNames: []});
      lua_Cameras.set("hud2", {cam: game.camHUD2, shaders: [], shaderNames: []});
      lua_Cameras.set("hud", {cam: game.camHUD, shaders: [], shaderNames: []});
      lua_Cameras.set("other", {cam: game.camOther, shaders: [], shaderNames: []});
      lua_Cameras.set("notestuff", {cam: game.camNoteStuff, shaders: [], shaderNames: []});
      lua_Cameras.set("stuff", {cam: game.camStuff, shaders: [], shaderNames: []});
      lua_Cameras.set("main", {cam: game.mainCam, shaders: [], shaderNames: []});
    }

    lua = LuaL.newstate();
    LuaL.openlibs(lua);

    // LuaL.dostring(lua, CLENSE);

    this.typeInstance = instance;
    this.preloading = preloading;
    this.scriptName = scriptName.trim();
    this.notScriptName = notScriptName.trim();

    if (instance != CHARACTER)
    {
      if (game != null)
      {
        if (!isStageLua) game.luaArray.push(this);
        else
          game.stage.luaArray.push(this);
      }
    }

    #if MODS_ALLOWED
    var myFolder:Array<String> = this.scriptName.split('/');
    if (myFolder[0] + '/' == Paths.mods()
      && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) // is inside mods folder
      this.modFolder = myFolder[1];
    #end

    // Lua shit
    set('Function_StopLua', LuaUtils.Function_StopLua);
    set('Function_StopHScript', LuaUtils.Function_StopHScript);
    set('Function_StopAll', LuaUtils.Function_StopAll);
    set('Function_Stop', LuaUtils.Function_Stop);
    set('Function_Continue', LuaUtils.Function_Continue);
    set('luaDebugMode', false);
    set('luaDeprecatedWarnings', true);
    set('version', MainMenuState.psychEngineVersion.trim());
    set('SCEversion', MainMenuState.SCEVersion.trim());
    set('modFolder', this.modFolder);

    // Song/Week shit
    set('curBpm', Conductor.bpm);
    if (PlayState.SONG != null)
    {
      set('bpm', PlayState.SONG.bpm);
      set('scrollSpeed', PlayState.SONG.speed);
    }
    set('crochet', Conductor.crochet);
    set('stepCrochet', Conductor.stepCrochet);
    set('songLength', 0);
    if (PlayState.SONG != null)
    {
      set('songName', PlayState.SONG.songId);
      set('songPath', Paths.formatToSongPath(PlayState.SONG.songId));
    }
    set('loadedSongName', Song.loadedSongName);
    set('loadedSongPath', Paths.formatToSongPath(Song.loadedSongName));
    set('chartPath', Song.chartPath);
    set('startedCountdown', false);
    if (PlayState.SONG != null) set('curStage', PlayState.SONG.stage);

    set('isStoryMode', PlayState.isStoryMode);
    set('difficulty', PlayState.storyDifficulty);
    set('difficultyName', Difficulty.getString(false));
    set('difficultyPath', Difficulty.getFilePath());
    set('difficultyNameTranslation', Difficulty.getString(true));
    set('weekRaw', PlayState.storyWeek);
    set('week', WeekData.weeksList[PlayState.storyWeek]);
    set('seenCutscene', PlayState.seenCutscene);
    set('hasVocals', PlayState.SONG.needsVoices);

    // Screen stuff
    set('screenWidth', FlxG.width);
    set('screenHeight', FlxG.height);

    if (game != null) @:privateAccess
    {
      var curSection:SwagSection = PlayState.SONG.notes[game.curSection];
      // PlayState variables
      set('curSection', game.curSection);
      set('curBeat', game.curBeat);
      set('curStep', game.curStep);
      set('curDecBeat', game.curDecBeat);
      set('curDecStep', game.curDecStep);

      set('score', game.songScore);
      set('misses', game.songMisses);
      set('hits', game.songHits);
      set('combo', game.combo);
      set('comboOp', game.comboOp);
      set('deaths', PlayState.deathCounter);

      set('rating', game.ratingPercent);
      set('ratingName', game.ratingName);
      set('ratingFC', game.ratingFC);
      set('totalPlayed', game.totalPlayed);
      set('totalNotesHit', game.totalNotesHit);

      set('inGameOver', GameOverSubstate.instance != null);
      set('mustHitSection', curSection != null ? (curSection.mustHitSection == true) : false);
      set('altAnim', curSection != null ? (curSection.altAnim == true) : false);
      set('playerAltAnim', curSection != null ? (curSection.playerAltAnim == true) : false);
      set('CPUAltAnim', curSection != null ? (curSection.CPUAltAnim == true) : false);
      set('gfSection', curSection != null ? (curSection.gfSection == true) : false);
      set('playDadSing', true);
      set('playBFSing', true);

      // Gameplay settings
      set('healthGainMult', game.healthGain);
      set('healthLossMult', game.healthLoss);

      #if FLX_PITCH
      set('playbackRate', game.playbackRate);
      #else
      set('playbackRate', 1);
      #end

      set('guitarHeroSustains', game.guitarHeroSustains);
      set('instakillOnMiss', game.instakillOnMiss);
      set('botPlay', game.cpuControlled);
      set('practice', game.practiceMode);
      set('modchart', game.notITGMod);
      set('opponent', game.opponentMode);
      set('showCaseMode', game.showCaseMode);
      set('holdsActive', game.holdsActive);

      for (i in 0...4)
      {
        set('defaultPlayerStrumX' + i, 0);
        set('defaultPlayerStrumY' + i, 0);
        set('defaultOpponentStrumX' + i, 0);
        set('defaultOpponentStrumY' + i, 0);
      }

      // Default character
      set('defaultBoyfriendX', game.BF_X);
      set('defaultBoyfriendY', game.BF_Y);
      set('defaultOpponentX', game.DAD_X);
      set('defaultOpponentY', game.DAD_Y);
      set('defaultGirlfriendX', game.GF_X);
      set('defaultGirlfriendY', game.GF_Y);
      set('defaultMomX', game.MOM_X);
      set('defaultMomY', game.MOM_Y);

      set('boyfriendName', game.boyfriend != null ? game.boyfriend.curCharacter : PlayState.SONG != null ? PlayState.SONG.characters.player : 'bf');
      set('dadName', game.dad != null ? game.dad.curCharacter : PlayState.SONG != null ? PlayState.SONG.characters.opponent : 'dad');
      set('gfName', game.gf != null ? game.gf.curCharacter : PlayState.SONG != null ? PlayState.SONG.characters.girlfriend : 'bf');
      set('momName', game.mom != null ? game.mom.curCharacter : PlayState.SONG != null ? PlayState.SONG.characters.secondOpponent : 'mom');
    }

    // Other settings
    set('downscroll', ClientPrefs.data.downScroll);
    set('middlescroll', ClientPrefs.data.middleScroll);
    set('framerate', ClientPrefs.data.framerate);
    set('ghostTapping', ClientPrefs.data.ghostTapping);
    set('hideHud', ClientPrefs.data.hideHud);
    set('timeBarType', ClientPrefs.data.timeBarType);
    set('scoreZoom', ClientPrefs.data.scoreZoom);
    set('cameraZoomOnBeat', ClientPrefs.data.camZooms);
    set('flashingLights', ClientPrefs.data.flashing);
    set('noteOffset', ClientPrefs.data.noteOffset);
    set('healthBarAlpha', ClientPrefs.data.healthBarAlpha);
    set('noResetButton', ClientPrefs.data.noReset);
    set('lowQuality', ClientPrefs.data.lowQuality);
    set('shadersEnabled', ClientPrefs.data.shaders);
    set('scriptName', scriptName);
    set('currentModDirectory', Mods.currentModDirectory);

    // Noteskin/Splash
    set('noteSkin', ClientPrefs.data.noteSkin);
    set('noteSkinPostfix', Note.getNoteSkinPostfix());
    set('splashSkin', ClientPrefs.data.splashSkin);
    set('splashSkinPostfix', NoteSplash.getSplashSkinPostfix());
    set('splashAlpha', ClientPrefs.data.splashAlpha);

    // Some more song stuff
    set('songPos', Conductor.songPosition);
    if (game != null) set('hudZoom', game.camHUD.zoom);
    set('cameraZoom', FlxG.camera.zoom);

    // build target (windows, mac, linux, etc.)
    set('buildTarget', LuaUtils.getBuildTarget());

    if (preloading) // only the necessary functions for preloading are included
    {
      set("debugPrint", function(text1:Dynamic = '', text2:Dynamic = '', text3:Dynamic = '', text4:Dynamic = '', text5:Dynamic = '') {
        if (text1 == null) text1 = '';
        if (text2 == null) text2 = '';
        if (text3 == null) text3 = '';
        if (text4 == null) text4 = '';
        if (text5 == null) text5 = '';

        luaTrace('' + text1 + text2 + text3 + text4 + text5, true, false);
      });

      set("makeLuaSprite", function(tag:String, image:String, x:Float, y:Float, ?antialiasing:Bool = true) {
        tag = tag.replace('.', '');
        var leSprite:ModchartSprite = new ModchartSprite(x, y);
        if (image != null && image.length > 0)
        {
          var rawPic:Dynamic;

          if (!Paths.currentTrackedAssets.exists(image)) Paths.image(image);

          rawPic = Paths.currentTrackedAssets.get(image);

          leSprite.loadGraphic(rawPic);
        }
        leSprite.antialiasing = antialiasing;

        if (!preloading) Stage.instance.swagBacks.set(tag, leSprite);
      });

      set("makeAnimatedLuaSprite", function(tag:String, image:String, x:Float, y:Float, spriteType:String = "auto") {
        tag = tag.replace('.', '');
        var leSprite:ModchartSprite = new ModchartSprite(x, y);

        LuaUtils.loadFrames(leSprite, image, spriteType);
        leSprite.antialiasing = true;

        if (!preloading) Stage.instance.swagBacks.set(tag, leSprite);
      });

      set("makeLuaBackdrop", function(tag:String, image:String, x:Float, y:Float, ?axes:String = "XY") {
        tag = tag.replace('.', '');

        var leSprite:FlxBackdrop = null;

        if (image != null && image.length > 0)
        {
          var rawPic:Dynamic;

          if (!Paths.currentTrackedAssets.exists(image)) Paths.image(image);

          rawPic = Paths.currentTrackedAssets.get(image);

          leSprite = new FlxBackdrop(rawPic, FlxAxes.fromString(axes), Std.int(x), Std.int(y));
        }

        if (leSprite == null) return;

        leSprite.antialiasing = true;
        leSprite.active = true;

        if (!preloading) Stage.instance.swagBacks.set(tag, leSprite);
      });

      set("makeHealthIcon", function(tag:String, character:String, player:Bool = false) {
        Paths.image('icons/icon-' + character);
      });

      set("loadGraphic", function(variable:String, image:String, ?gridX:Int, ?gridY:Int) {
        Paths.image(image);
      });

      set("makeLuaText", function(tag:String, text:String, width:Int, x:Float, y:Float) {
        tag = tag.replace('.', '');
        LuaUtils.findToDestroy(tag);
        var leText:FlxText = new FlxText(x, y, width, text, 16);
        leText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      });

      set("precacheSound", function(name:String, ?path:String = "sounds") {
        Paths.returnSound(path, name);
      });

      set("precacheImage", function(name:String) {
        Paths.image(name);
      });

      set("getProperty", function(variable:String) {
        return 0;
      });

      set("getPropertyFromClass", function(variable:String) {
        return true;
      });

      set("getColorFromHex", function(color:String) {
        return FlxColor.fromString('#$color');
      });

      // because sink
      set("getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
        var excludeArray:Array<String> = exclude.split(',');
        var toExclude:Array<Int> = [];
        for (i in 0...excludeArray.length)
        {
          if (exclude == '') break;
          toExclude.push(Std.parseInt(excludeArray[i].trim()));
        }
        return FlxG.random.int(min, max, toExclude);
      });
      set("getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
        var excludeArray:Array<String> = exclude.split(',');
        var toExclude:Array<Float> = [];
        for (i in 0...excludeArray.length)
        {
          if (exclude == '') break;
          toExclude.push(Std.parseFloat(excludeArray[i].trim()));
        }
        return FlxG.random.float(min, max, toExclude);
      });
      set("getRandomBool", function(chance:Float = 50) {
        return FlxG.random.bool(chance);
      });

      set("setShaderSampler2D", function(obj:String, prop:String, bitmapDataPath:String) {
        #if (!flash && sys)
        Paths.image(bitmapDataPath);
        #end
      });

      set("getRunningScripts", function() {
        var runningScripts:Array<String> = [];
        return runningScripts;
      });

      // because we have to add em otherwise it'll only load the first sprite... for most luas. if you set it up where you make the sprites first and then all the formatting stuff ->
      // then it shouldn't be a problem

      var otherCallbacks:Array<String> = [
        'makeGraphic',
        'objectPlayAnimation',
        "makeLuaCharacter",
        "playAnim",
        "getMapKeys"
      ];
      var addCallbacks:Array<String> = [
        'addAnimationByPrefix',
        'addAnimationByIndices',
        'addAnimationByIndicesLoop',
        'addLuaSprite',
        'addLuaText',
        "addOffset",
        "addClipRect",
        "addAnimation"
      ];
      var setCallbacks:Array<String> = [
        'setScrollFactor', 'setObjectCamera', 'scaleObject', 'screenCenter', 'setTextSize', 'setTextBorder', 'setTextString', "setTextAlignment",
        "setTextColor", "setPropertyFromClass", "setBlendMode",
      ];
      var shaderCallbacks:Array<String> = [
        "initLuaShader",
        "setSpriteShader",
        "setShaderFloat",
        "setShaderFloatArray",
        "setShaderBool",
        "setShaderBoolArray"
      ];

      otherCallbacks = otherCallbacks.concat(addCallbacks);
      otherCallbacks = otherCallbacks.concat(setCallbacks);
      otherCallbacks = otherCallbacks.concat(shaderCallbacks);

      for (i in 0...otherCallbacks.length)
      {
        set(otherCallbacks[i], function(?val1:String) {
          // do almost nothing
          return true;
        });
      }

      var numberCallbacks:Array<String> = ["getObjectOrder", "setObjectOrder"];

      for (i in 0...numberCallbacks.length)
      {
        set(numberCallbacks[i], function(?val1:String) {
          // do almost nothing
          return 0;
        });
      }
    }
    else
    {
      for (name => func in customFunctions)
        if (func != null) set(name, func);

      //
      set("getRunningScripts", function() {
        var runningScripts:Array<String> = [];
        for (script in game.luaArray)
          runningScripts.push(script.scriptName);

        for (script in game.stage.luaArray)
          runningScripts.push(script.scriptName);

        for (script in game.hscriptArray)
          runningScripts.push(script.origin);

        for (script in game.stage.hscriptArray)
          runningScripts.push(script.origin);

        return runningScripts;
      });

      addLocalCallback("setOnScripts", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
        if (exclusions == null) exclusions = [];
        if (ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
        game.setOnScripts(varName, arg, exclusions);
      });
      addLocalCallback("setOnHScript", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
        if (exclusions == null) exclusions = [];
        if (ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
        game.setOnHScript(varName, arg, exclusions);
      });
      addLocalCallback("setOnHSIScript", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
        if (exclusions == null) exclusions = [];
        if (ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
        game.setOnHSI(varName, arg, exclusions);
      });
      addLocalCallback("setOnSCHS", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
        if (exclusions == null) exclusions = [];
        if (ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
        game.setOnSCHS(varName, arg, exclusions);
      });
      addLocalCallback("setOnLuas", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
        if (exclusions == null) exclusions = [];
        if (ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
        game.setOnLuas(varName, arg, exclusions);
      });

      addLocalCallback("callOnScripts",
        function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
            ?excludeValues:Array<Dynamic> = null) {
          if (excludeScripts == null) excludeScripts = [];
          if (ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
          return game.callOnScripts(funcName, args, ignoreStops, excludeScripts, excludeValues);
        });
      addLocalCallback("callOnLuas",
        function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
            ?excludeValues:Array<Dynamic> = null) {
          if (excludeScripts == null) excludeScripts = [];
          if (ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
          return game.callOnLuas(funcName, args, ignoreStops, excludeScripts, excludeValues);
        });
      addLocalCallback("callOnHScript",
        function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
            ?excludeValues:Array<Dynamic> = null) {
          if (excludeScripts == null) excludeScripts = [];
          if (ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
          return game.callOnHScript(funcName, args, ignoreStops, excludeScripts, excludeValues);
        });
      addLocalCallback("callOnHSI",
        function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
            ?excludeValues:Array<Dynamic> = null) {
          if (excludeScripts == null) excludeScripts = [];
          if (ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
          return game.callOnHSI(funcName, args, ignoreStops, excludeScripts, excludeValues);
        });
      addLocalCallback("callOnSCHS",
        function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
            ?excludeValues:Array<Dynamic> = null) {
          if (excludeScripts == null) excludeScripts = [];
          if (ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
          return game.callOnSCHS(funcName, args, ignoreStops, excludeScripts, excludeValues);
        });

      set("callScript", function(luaFile:String, funcName:String, ?args:Array<Dynamic> = null) {
        if (args == null)
        {
          args = [];
        }

        var luaPath:String = findScript(luaFile);
        if (luaPath != null) for (luaInstance in game.luaArray)
          if (luaInstance.scriptName == luaPath) return luaInstance.call(funcName, args);
        return null;
      });
      set("isRunningLuaFile", function(luaFile:String) {
        var luaPath:String = findScript(luaFile);
        if (luaPath != null)
        {
          for (luaInstance in game.luaArray)
            if (luaInstance.scriptName == luaPath) return true;
        }
        return false;
      });
      set("isRunningHxFile", function(hxFile:String) {
        for (extn in CoolUtil.haxeExtensions)
        {
          var hscriptPath:String = findScript(hxFile, '.$extn');
          if (hscriptPath != null)
          {
            for (hscriptInstance in game.hscriptArray)
              if (hscriptInstance.origin == hscriptPath) return true;
          }
        }
        return false;
      });

      set("setVar", function(varName:String, value:Dynamic, ?type:String = "Custom") {
        MusicBeatState.getVariables(type).set(varName, ReflectionFunctions.parseSingleInstance(value));
        return value;
      });
      set("getVar", function(varName:String, ?type:String = "Custom") {
        return MusicBeatState.getVariables(type).get(varName);
      });
      set("removeVar", function(varName:String, ?type:String = "Custom") {
        return MusicBeatState.getVariables(type).remove(varName);
      });

      set("addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { // would be dope asf.
        var luaPath:String = findScript(luaFile);
        if (luaPath != null)
        {
          if (!ignoreAlreadyRunning) for (luaInstance in game.luaArray)
            if (luaInstance.scriptName == luaPath)
            {
              luaTrace('addLuaScript: The script "' + luaPath + '" is already running!');
              return;
            }

          new FunkinLua(luaPath, typeInstance);
          return;
        }
        luaTrace("addLuaScript: Script doesn't exist!", false, false, FlxColor.RED);
      });
      set("addHScript", function(hxFile:String, ?ignoreAlreadyRunning:Bool = false) {
        #if HSCRIPT_ALLOWED
        for (extn in CoolUtil.haxeExtensions)
        {
          var scriptPath:String = findScript(hxFile, '.$extn');
          if (scriptPath != null)
          {
            if (!ignoreAlreadyRunning) for (script in game.hscriptArray)
              if (script.origin == scriptPath)
              {
                luaTrace('addHScript: The script "' + scriptPath + '" is already running!');
                return;
              }

            game.initHScript(scriptPath);
            return;
          }
        }
        luaTrace("addHScript: Script doesn't exist!", false, false, FlxColor.RED);
        #else
        luaTrace("addHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
        #end
      });
      set("removeLuaScript", function(luaFile:String) {
        var luaPath:String = findScript(luaFile);
        if (luaPath != null)
        {
          var foundAny:Bool = false;
          for (luaInstance in game.luaArray)
          {
            if (luaInstance.scriptName == luaPath)
            {
              Debug.logInfo('Closing lua script $luaPath');
              luaInstance.stop();
              foundAny = true;
            }
          }

          for (luaInstance in game.stage.luaArray)
            if (luaInstance.scriptName == luaPath)
            {
              Debug.logTrace('Closing script ' + luaInstance.scriptName);
              luaInstance.stop();
              foundAny = true;
            }

          if (foundAny) return true;
        }
        luaTrace('removeLuaScript: Script $luaFile isn\'t running!', false, false, FlxColor.RED);
        return false;
      });
      set("removeHScript", function(hxFile:String) {
        #if HSCRIPT_ALLOWED
        for (extn in CoolUtil.haxeExtensions)
        {
          var scriptPath:String = findScript(hxFile, '.$extn');
          if (scriptPath != null)
          {
            var foundAny:Bool = false;
            for (script in game.hscriptArray)
            {
              if (script.origin == scriptPath)
              {
                trace('Closing hscript $scriptPath');
                script.destroy();
                foundAny = true;
              }
            }

            for (script in game.stage.hscriptArray)
            {
              if (script.origin == scriptPath)
              {
                trace('Closing hscript $scriptPath');
                script.destroy();
                foundAny = true;
              }
            }
            if (foundAny) return true;
          }
        }
        luaTrace('removeHScript: Script $hxFile isn\'t running!', false, false, FlxColor.RED);
        return false;
        #else
        luaTrace("addHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
        #end
      });

      set("loadSong", function(?name:String = null, ?difficultyNum:Int = -1) {
        if (name == null || name.length < 1) name = Song.loadedSongName;
        if (difficultyNum == -1) difficultyNum = PlayState.storyDifficulty;

        var poop = Highscore.formatSong(name, difficultyNum);
        Song.loadFromJson(poop, name);
        PlayState.storyDifficulty = difficultyNum;
        MusicBeatState.switchState(new PlayState());

        if (FlxG.sound.music != null)
        {
          FlxG.sound.music.pause();
          FlxG.sound.music.volume = 0;
        }
        if (game != null && game.vocals != null)
        {
          game.vocals.pause();
          game.vocals.volume = 0;
        }
        if (game != null && game.opponentVocals != null && game.splitVocals)
        {
          game.opponentVocals.pause();
          game.opponentVocals.volume = 0;
        }
        FlxG.camera.followLerp = 0;
      });

      set("loadGraphic", function(variable:String, image:String, ?gridX:Int = 0, ?gridY:Int = 0) {
        var split:Array<String> = variable.split('.');
        var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        var gX = gridX == null ? 0 : gridX;
        var gY = gridY == null ? 0 : gridY;
        var animated = gridX != 0 || gridY != 0;

        if (split.length > 1)
        {
          spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (spr != null && image != null && image.length > 0)
        {
          spr.loadGraphic(Paths.image(image), animated, gridX, gridY);
        }
      });
      set("loadFrames", function(variable:String, image:String, spriteType:String = "sparrow") {
        var split:Array<String> = variable.split('.');
        var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (spr != null && image != null && image.length > 0)
        {
          LuaUtils.loadFrames(spr, image, spriteType);
        }
      });

      // shitass stuff for epic coders like me B)  *image of obama giving himself a medal*
      set("getObjectOrder", function(obj:String, ?group:String = null) {
        var leObj:FlxSprite = LuaUtils.getObjectDirectly(obj);
        if (leObj != null)
        {
          if (group != null)
          {
            var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
            if (groupOrArray != null)
            {
              switch (Type.typeof(groupOrArray))
              {
                case TClass(Array): // Is Array
                  return groupOrArray.indexOf(leObj);
                default: // Is Group
                  return Reflect.getProperty(groupOrArray, 'members').indexOf(leObj); // Has to use a Reflect here because of FlxTypedSpriteGroup
              }
            }
            else
            {
              luaTrace('getObjectOrder: Group $group doesn\'t exist!', false, false, FlxColor.RED);
              return -1;
            }
          }
          return LuaUtils.getTargetInstance().members.indexOf(leObj);
        }
        luaTrace('getObjectOrder: Object $obj doesn\'t exist!', false, false, FlxColor.RED);
        return -1;
      });
      set("setObjectOrder", function(obj:String, position:Int, ?group:String = null) {
        var leObj:FlxSprite = LuaUtils.getObjectDirectly(obj);
        if (leObj != null)
        {
          if (group != null)
          {
            var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
            if (groupOrArray != null)
            {
              switch (Type.typeof(groupOrArray))
              {
                case TClass(Array): // Is Array
                  groupOrArray.remove(leObj);
                  groupOrArray.insert(position, leObj);
                default: // Is Group
                  groupOrArray.remove(leObj, true);
                  groupOrArray.insert(position, leObj);
              }
            }
            else
              luaTrace('setObjectOrder: Group $group doesn\'t exist!', false, false, FlxColor.RED);
          }
          else
          {
            var groupOrArray:FlxState = LuaUtils.getTargetInstance();
            groupOrArray.remove(leObj, true);
            groupOrArray.insert(position, leObj);
          }
          return;
        }
        luaTrace('setObjectOrder: Object $obj doesn\'t exist!', false, false, FlxColor.RED);
      });

      // gay ass tweens
      set("startTween", function(tag:String, vars:String, values:Any = null, duration:Float, ?options:Any = null) {
        final itemExam:Dynamic = LuaUtils.tweenPrepare(tag, vars);
        if (itemExam != null)
        {
          if (values != null)
          {
            final myOptions:LuaTweenOptions = LuaUtils.getLuaTween(options);
            if (tag != null)
            {
              MusicBeatState.getVariables("Tween").set(tag, FlxTween.tween(itemExam, values, duration, myOptions != null ?
                {
                  type: myOptions.type,
                  ease: myOptions.ease,
                  startDelay: myOptions.startDelay,
                  loopDelay: myOptions.loopDelay,

                  onUpdate: function(twn:FlxTween) {
                    if (myOptions.onUpdate != null) game.callOnLuas(myOptions.onUpdate, [tag, vars]);
                  },
                  onStart: function(twn:FlxTween) {
                    if (myOptions.onStart != null) game.callOnLuas(myOptions.onStart, [tag, vars]);
                  },
                  onComplete: function(twn:FlxTween) {
                    if (twn.type == FlxTweenType.ONESHOT || twn.type == FlxTweenType.BACKWARD) MusicBeatState.getVariables("Tween").remove(tag);
                    if (myOptions.onComplete != null) game.callOnLuas(myOptions.onComplete, [tag, vars]);
                  }
                } : null));
              return tag;
            }
            else
              FlxTween.tween(itemExam, values, duration, myOptions != null ?
                {
                  type: myOptions.type,
                  ease: myOptions.ease,
                  startDelay: myOptions.startDelay,
                  loopDelay: myOptions.loopDelay,

                  onUpdate: function(twn:FlxTween) {
                    if (myOptions.onUpdate != null) game.callOnLuas(myOptions.onUpdate, [null, vars]);
                  },
                  onStart: function(twn:FlxTween) {
                    if (myOptions.onStart != null) game.callOnLuas(myOptions.onStart, [null, vars]);
                  },
                  onComplete: function(twn:FlxTween) {
                    if (myOptions.onComplete != null) game.callOnLuas(myOptions.onComplete, [null, vars]);
                  }
                } : null);
          }
        }
        else
          luaTrace('startTween: Couldnt find object: ' + vars, false, false, FlxColor.RED);
        return null;
      });

      set("doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return oldTweenFunction(tag, vars, {x: value}, duration, ease, 'doTweenX');
      });
      set("doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return oldTweenFunction(tag, vars, {y: value}, duration, ease, 'doTweenY');
      });
      set("doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return oldTweenFunction(tag, vars, {angle: value}, duration, ease, 'doTweenAngle');
      });
      set("doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return oldTweenFunction(tag, vars, {alpha: value}, duration, ease, 'doTweenAlpha');
      });
      set("doTweenZoom", function(tag:String, camera:String, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return oldTweenFunction(tag, LuaUtils.returnCameraName(camera), {zoom: value}, duration, ease, 'doTweenZoom');
      });

      set("doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ?ease:String = 'linear') {
        var itemExam:Dynamic = LuaUtils.tweenPrepare(tag, vars);
        if (itemExam != null)
        {
          var curColor:FlxColor = itemExam.color;
          curColor.alphaFloat = itemExam.alpha;
          if (tag != null)
          {
            MusicBeatState.getVariables("Tween").set(tag, FlxTween.color(itemExam, duration, curColor, CoolUtil.colorFromString(targetColor),
              {
                ease: LuaUtils.getTweenEaseByString(ease),
                onComplete: function(twn:FlxTween) {
                  MusicBeatState.getVariables("Tween").remove(tag);
                  if (game != null) game.callOnLuas('onTweenCompleted', [tag, vars]);
                }
              }));
            return tag;
          }
          else
            FlxTween.color(itemExam, duration, curColor, CoolUtil.colorFromString(targetColor), {ease: LuaUtils.getTweenEaseByString(ease)});
        }
        else
          luaTrace('doTweenColor: Couldnt find object: ' + vars, false, false, FlxColor.RED);
        return null;
      });

      // Tween shit, but for strums
      set("noteTweenX", function(tag:String, note:Int, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return noteTweenFunction(tag, note, {x: value}, duration, ease);
      });
      set("noteTweenY", function(tag:String, note:Int, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return noteTweenFunction(tag, note, {y: value}, duration, ease);
      });
      set("noteTweenAlpha", function(tag:String, note:Int, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return noteTweenFunction(tag, note, {alpha: value}, duration, ease);
      });
      set("noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return noteTweenFunction(tag, note, {angle: value}, duration, ease);
      });
      set("noteTweenDirection", function(tag:String, note:Int, value:Dynamic, duration:Float, ?ease:String = 'linear') {
        return noteTweenFunction(tag, note, {direction: value}, duration, ease);
      });

      set("cancelTween", function(tag:String) LuaUtils.cancelTween(tag));

      set("mouseClicked", function(?button:String = 'left') {
        var click:Bool = FlxG.mouse.justPressed;
        switch (button.trim().toLowerCase())
        {
          case 'middle':
            click = FlxG.mouse.justPressedMiddle;
          case 'right':
            click = FlxG.mouse.justPressedRight;
        }
        return click;
      });
      set("mousePressed", function(?button:String = 'left') {
        var press:Bool = FlxG.mouse.pressed;
        switch (button.trim().toLowerCase())
        {
          case 'middle':
            press = FlxG.mouse.pressedMiddle;
          case 'right':
            press = FlxG.mouse.pressedRight;
        }
        return press;
      });
      set("mouseReleased", function(?button:String = 'left') {
        var released:Bool = FlxG.mouse.justReleased;
        switch (button.trim().toLowerCase())
        {
          case 'middle':
            released = FlxG.mouse.justReleasedMiddle;
          case 'right':
            released = FlxG.mouse.justReleasedRight;
        }
        return released;
      });

      set("runTimer", function(tag:String, time:Float = 1, loops:Int = 1) {
        LuaUtils.cancelTimer(tag);
        MusicBeatState.getVariables("Timer").set(tag, new FlxTimer().start(time, function(tmr:FlxTimer) {
          if (tmr.finished) MusicBeatState.getVariables("Timer").remove(tag);
          game.callOnLuas('onTimerCompleted', [tag, tmr.loops, tmr.loopsLeft]);
        }, loops));
        return tag;
      });
      set("cancelTimer", function(tag:String) LuaUtils.cancelTimer(tag));

      // stupid bietch ass functions
      set("addScore", function(value:Int = 0) {
        game.songScore += value;
        game.RecalculateRating();
        return value;
      });
      set("addMisses", function(value:Int = 0) {
        game.songMisses += value;
        game.RecalculateRating();
        return value;
      });
      set("addHits", function(value:Int = 0) {
        game.songHits += value;
        game.RecalculateRating();
        return value;
      });
      set("setScore", function(value:Int = 0) {
        game.songScore = value;
        game.RecalculateRating();
        return value;
      });
      set("setMisses", function(value:Int = 0) {
        game.songMisses = value;
        game.RecalculateRating();
        return value;
      });
      set("setHits", function(value:Int = 0) {
        game.songHits = value;
        game.RecalculateRating();
        return value;
      });

      set("setHealth", function(value:Float = 1) return game.health = value);
      set("addHealth", function(value:Float = 0) game.health += value);
      set("getHealth", function() return game.health);

      // Identical functions
      set("FlxColor", function(color:String) return FlxColor.fromString(color));
      set("getColorFromName", function(color:String) return FlxColor.fromString(color));
      set("getColorFromString", function(color:String) return FlxColor.fromString(color));
      set("getColorFromHex", function(color:String) return FlxColor.fromString('#$color'));
      set("getColorFromParsedInt", function(color:String) {
        if (!color.startsWith('0x')) color = '0xFF' + color;
        return Std.parseInt(color);
      });

      // precaching
      set("addCharacterToList", function(name:String, ?superCache:Bool = false) {
        game.cacheCharacter(name, superCache);
      });
      set("precacheImage", function(name:String, ?allowGPU:Bool = true) {
        Paths.image(name, allowGPU);
      });
      set("precacheSound", function(name:String) {
        Paths.sound(name);
      });
      set("precacheMusic", function(name:String) {
        Paths.music(name);
      });
      set("precacheFont", function(name:String) {
        return name; // this doesn't actually preload the font.
      });

      // others
      set("triggerEventLegacy",
        function(name:String, ?arg1:String = '', ?arg2:String = '', ?arg3:String = '', ?arg4:String = '', ?arg5:String = '', ?arg6:String = '',
            ?arg7:String = '', ?arg8:String = '', ?arg9:String = '', ?arg10:String = '', ?arg11:String = '', ?arg12:String = '', ?arg13:String = '',
            ?arg14:String = '') {
          game.triggerEventLegacy(name, arg1, arg2, Conductor.songPosition, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
          return true;
        });

      set("triggerEvent", function(name:String, luaArgs:Array<String> = null) {
        if (luaArgs == null) luaArgs = [];
        var args:Array<String> = [];
        for (i in 0...luaArgs.length)
          args.push(Std.string(luaArgs[i]));
        game.triggerEvent(name, args, Conductor.songPosition);
        return true;
      });

      set("startCountdown", function() {
        game.startCountdown();
        return true;
      });
      set("endSong", function() {
        game.KillNotes();
        game.endSong();
        return true;
      });
      set("restartSong", function(?skipTransition:Bool = false) {
        game.persistentUpdate = false;
        FlxG.camera.followLerp = 0;
        SlushiPauseSubState.restartSong(skipTransition);
        return true;
      });
      set("exitSong", function(?skipTransition:Bool = false) {
        if (skipTransition)
        {
          FlxTransitionableState.skipNextTransIn = true;
          FlxTransitionableState.skipNextTransOut = true;
        }

        if (ClientPrefs.data.behaviourType != 'VSLICE')
        {
          if (PlayState.isStoryMode) MusicBeatState.switchState(new StoryMenuState());
          else
            MusicBeatState.switchState(new slushi.states.freeplay.SlushiFreeplayState());
        }
        #if BASE_GAME_FILES
        else
        {
          if (PlayState.isStoryMode)
          {
            PlayState.storyPlaylist = [];
            game.openSubState(new vslice.transition.StickerSubState(null, (sticker) -> new StoryMenuState(sticker)));
          }
          else
            game.openSubState(new vslice.transition.StickerSubState(null, (sticker) -> new slushi.states.freeplay.SlushiFreeplayState(sticker)));
        }
        #end

        FlxG.sound.playMusic(SlushiMain.getSLEPath("Musics/SLE_HackNet_Resonance.ogg"));
        PlayState.changedDifficulty = false;
        PlayState.chartingMode = false;
        PlayState.modchartMode = false;
        game.transitioning = true;
        FlxG.camera.followLerp = 0;
        if (PlayState.forceMiddleScroll)
        {
          if (PlayState.savePrefixScrollR && PlayState.prefixRightScroll)
          {
            ClientPrefs.data.middleScroll = false;
          }
        }
        else if (PlayState.forceRightScroll)
        {
          if (PlayState.savePrefixScrollM && PlayState.prefixMiddleScroll)
          {
            ClientPrefs.data.middleScroll = true;
          }
        }
        return true;
      });
      set("getSongPosition", function() {
        return Conductor.songPosition;
      });

      set("getCharacterX", function(type:String) {
        switch (type.toLowerCase())
        {
          case 'dad' | 'opponent':
            return game.dad.x;
          case 'gf' | 'girlfriend':
            return game.gf.x;
          case 'mom':
            return game.mom.x;
          default:
            return game.boyfriend.x;
        }
      });
      set("setCharacterX", function(type:String, value:Float) {
        switch (type.toLowerCase())
        {
          case 'dad' | 'opponent':
            return game.dad.x = value;
          case 'gf' | 'girlfriend':
            return game.gf.x = value;
          case 'mom':
            return game.mom.x = value;
          default:
            return game.boyfriend.x = value;
        }
      });
      set("getCharacterY", function(type:String) {
        switch (type.toLowerCase())
        {
          case 'dad' | 'opponent':
            return game.dad.y;
          case 'gf' | 'girlfriend':
            return game.gf.y;
          case 'mom':
            return game.mom.y;
          default:
            return game.boyfriend.y;
        }
      });
      set("setCharacterY", function(type:String, value:Float) {
        switch (type.toLowerCase())
        {
          case 'dad' | 'opponent':
            return game.dad.y = value;
          case 'gf' | 'girlfriend':
            return game.gf.y = value;
          case 'mom':
            return game.mom.y = value;
          default:
            return game.boyfriend.y = value;
        }
      });
      set("cameraSetTarget", function(target:String) {
        return game.cameraTargeted = target;
      });
      set('cameraGetTarget', function() {
        return game.cameraTargeted;
      });

      set("setCameraScroll", function(x:Float, y:Float) FlxG.camera.scroll.set(x - FlxG.width / 2, y - FlxG.height / 2));
      set("setCameraFollowPoint", function(x:Float, y:Float) game.camFollow.setPosition(x, y));
      set("addCameraScroll", function(?x:Float = 0, ?y:Float = 0) FlxG.camera.scroll.add(x, y));
      set("addCameraFollowPoint", function(?x:Float = 0, ?y:Float = 0) {
        game.camFollow.x += x;
        game.camFollow.y += y;
      });
      set("getCameraScrollX", () -> FlxG.camera.scroll.x + FlxG.width / 2);
      set("getCameraScrollY", () -> FlxG.camera.scroll.y + FlxG.height / 2);
      set("getCameraFollowX", () -> game.camFollow.x);
      set("getCameraFollowY", () -> game.camFollow.y);

      set("cameraShake", function(camera:String, intensity:Float, duration:Float) {
        LuaUtils.cameraFromString(camera).shake(intensity, duration);
      });
      set("cameraFlash", function(camera:String, color:String, duration:Float, forced:Bool) {
        LuaUtils.cameraFromString(camera).flash(CoolUtil.colorFromString(color), duration, null, forced);
      });
      set("cameraFade", function(camera:String, color:String, duration:Float, forced:Bool, ?fadeOut:Bool = false) {
        LuaUtils.cameraFromString(camera).fade(CoolUtil.colorFromString(color), duration, fadeOut, null, forced);
      });
      set("setRatingPercent", function(value:Float) {
        game.ratingPercent = value;
        game.setOnScripts('rating', game.ratingPercent);
        return value;
      });
      set("setRatingName", function(value:String) {
        game.ratingName = value;
        game.setOnScripts('ratingName', game.ratingName);
        return value;
      });
      set("setRatingFC", function(value:String) {
        game.ratingFC = value;
        game.setOnScripts('ratingFC', game.ratingFC);
        return value;
      });
      set("getMouseX", function(?camera:String = 'game') {
        var cam:FlxCamera = LuaUtils.cameraFromString(camera);
        return FlxG.mouse.getScreenPosition(cam).x;
      });
      set("getMouseY", function(?camera:String = 'game') {
        var cam:FlxCamera = LuaUtils.cameraFromString(camera);
        return FlxG.mouse.getScreenPosition(cam).y;
      });

      set("getMidpointX", function(variable:String) {
        var split:Array<String> = variable.split('.');
        var obj:FlxObject = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }
        if (obj != null) return obj.getMidpoint().x;

        return 0;
      });
      set("getMidpointY", function(variable:String) {
        var split:Array<String> = variable.split('.');
        var obj:FlxObject = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }
        if (obj != null) return obj.getMidpoint().y;

        return 0;
      });
      set("getGraphicMidpointX", function(variable:String) {
        var split:Array<String> = variable.split('.');
        var obj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }
        if (obj != null) return obj.getGraphicMidpoint().x;

        return 0;
      });
      set("getGraphicMidpointY", function(variable:String) {
        var split:Array<String> = variable.split('.');
        var obj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }
        if (obj != null) return obj.getGraphicMidpoint().y;

        return 0;
      });
      set("getScreenPositionX", function(variable:String, ?camera:String = 'game') {
        var split:Array<String> = variable.split('.');
        var obj:FlxObject = LuaUtils.getObjectDirectly(split[0]);
        var cam:FlxCamera = LuaUtils.cameraFromString(camera);
        if (split.length > 1)
        {
          obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }
        if (obj != null) return obj.getScreenPosition(cam).x;

        return 0;
      });
      set("getScreenPositionY", function(variable:String, ?camera:String = 'game') {
        var split:Array<String> = variable.split('.');
        var obj:FlxObject = LuaUtils.getObjectDirectly(split[0]);
        var cam:FlxCamera = LuaUtils.cameraFromString(camera);
        if (split.length > 1)
        {
          obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }
        if (obj != null) return obj.getScreenPosition(cam).y;

        return 0;
      });
      set("characterForceDance", function(character:String, ?forcedToIdle:Bool) {
        switch (character.toLowerCase())
        {
          case 'dad':
            game.dad.dance(forcedToIdle);
          case 'gf' | 'girlfriend':
            if (game.gf != null) game.gf.dance();
          case 'mom':
            if (game.mom != null) game.mom.dance(forcedToIdle);
          default:
            game.boyfriend.dance(forcedToIdle);
        }
      });

      set("makeLuaBackdrop", function(tag:String, image:String, spacingX:Float, spacingY:Float, ?axes:String = "XY") {
        tag = tag.replace('.', '');
        LuaUtils.findToDestroy(tag);
        var leSprite:FlxBackdrop = null;
        if (image != null && image.length > 0)
        {
          leSprite = new FlxBackdrop(Paths.image(image), FlxAxes.fromString(axes), Std.int(spacingX), Std.int(spacingY));
        }
        leSprite.antialiasing = ClientPrefs.data.antialiasing;
        if (isStageLua && !preloading) Stage.instance.swagBacks.set(tag, leSprite);
        else
          MusicBeatState.getVariables("Graphic").set(tag, leSprite);
        leSprite.active = true;
      });
      set("makeLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0) {
        tag = tag.replace('.', '');
        LuaUtils.findToDestroy(tag);
        var leSprite:ModchartSprite = new ModchartSprite(x, y);
        if (image != null && image.length > 0)
        {
          leSprite.loadGraphic(Paths.image(image));
        }
        if (isStageLua && !preloading) Stage.instance.swagBacks.set(tag, leSprite);
        else
          MusicBeatState.getVariables("Graphic").set(tag, leSprite);
        leSprite.active = true;
      });
      set("makeSkewedSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0) {
        tag = tag.replace('.', '');
        LuaUtils.findToDestroy(tag);
        var leSprite:FlxSkewed = new FlxSkewed(x, y);
        if (image != null && image.length > 0)
        {
          leSprite.loadGraphic(Paths.image(image));
        }
        if (isStageLua && !preloading) Stage.instance.swagBacks.set(tag, leSprite);
        else
          MusicBeatState.getVariables("Graphic").set(tag, leSprite);
        leSprite.active = true;
      });
      set("makeAnimatedLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0, ?spriteType:String = "auto") {
        tag = tag.replace('.', '');
        LuaUtils.findToDestroy(tag);
        var leSprite:ModchartSprite = new ModchartSprite(x, y);

        LuaUtils.loadFrames(leSprite, image, spriteType);
        if (isStageLua && !preloading) Stage.instance.swagBacks.set(tag, leSprite);
        else
          MusicBeatState.getVariables("Graphic").set(tag, leSprite);
      });

      set("makeGraphic", function(obj:String, width:Int = 256, height:Int = 256, color:String = 'FFFFFF') {
        final spr:FlxSprite = LuaUtils.getObjectDirectly(obj);
        if (spr != null) spr.makeGraphic(width, height, CoolUtil.colorFromString(color));
      });
      set("addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Float = 24, loop:Bool = true) {
        var obj:FlxSprite = cast LuaUtils.getObjectDirectly(obj);
        if (obj != null && obj.animation != null)
        {
          obj.animation.addByPrefix(name, prefix, framerate, loop);
          if (obj.animation.curAnim == null)
          {
            var dyn:Dynamic = cast obj;
            if (dyn.playAnim != null) dyn.playAnim(name, true);
            else
              dyn.animation.play(name, true);
          }
          return true;
        }
        return false;
      });

      set("addAnimation", function(obj:String, name:String, frames:Array<Int>, framerate:Float = 24, loop:Bool = true) {
        return LuaUtils.addAnimByIndices(obj, name, null, frames, framerate, loop);
      });

      set("addAnimationByIndices", function(obj:String, name:String, prefix:String, indices:Any, framerate:Float = 24, loop:Bool = false) {
        return LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, loop);
      });

      set("playActorAnimation", function(obj:String, anim:String, force:Bool = false, reverse:Bool = false, ?frame:Int = 0) {
        if (!ClientPrefs.data.characters) return;

        final char:Character = LuaUtils.getObjectDirectly(obj);
        if (char != null)
        { // what am I doing? of course it'll be a character
          char.playAnim(anim, force, reverse, frame);
        }
      });

      set("playAnim", function(obj:String, name:String, ?forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0) {
        var obj:Dynamic = LuaUtils.getObjectDirectly(obj);
        if (obj.playAnim != null)
        {
          obj.playAnim(name, forced, reverse, startFrame);
          return true;
        }
        else
        {
          if (obj.anim != null) obj.anim.play(name, forced, reverse, startFrame); // FlxAnimate
          else
            obj.animation.play(name, forced, reverse, startFrame);
          return true;
        }
        return false;
      });

      set("playAnimOld", function(obj:String, name:String, ?forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0) {
        if (LuaUtils.getObjectDirectly(obj) != null)
        {
          var luaObj:FlxSprite = LuaUtils.getObjectDirectly(obj);
          if (luaObj.animation.getByName(name) != null)
          {
            luaObj.animation.play(name, forced, reverse, startFrame);
            if (Std.isOfType(luaObj, ModchartSprite))
            {
              // convert luaObj to ModchartSprite
              var obj:Dynamic = luaObj;
              var luaObj:ModchartSprite = obj;

              var daOffset = luaObj.animOffsets.get(name);
              if (luaObj.hasOffsetAnimation(name))
              {
                luaObj.offset.set(daOffset[0], daOffset[1]);
              }
              else
                luaObj.offset.set(0, 0);
            }

            if (Std.isOfType(luaObj, Character) && ClientPrefs.data.characters)
            {
              // convert luaObj to Character
              var obj:Dynamic = luaObj;
              var luaObj:Character = obj;
              luaObj.playAnim(name, forced, reverse, startFrame);
            }
            else
              luaObj.animation.play(name, forced, reverse, startFrame);
          }
        }
      });

      set("addOffset", function(obj:String, anim:String, x:Float, y:Float) {
        var obj:Dynamic = LuaUtils.getObjectDirectly(obj);
        if (obj != null && obj.addOffset != null)
        {
          if (Std.isOfType(obj, Character) || Std.isOfType(obj, HealthIcon) || Std.isOfType(obj, ModchartSprite))
          {
            obj.addOffset(anim, x, y);
          }
          return true;
        }
        return false;
      });

      set("setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
        var object:FlxObject = LuaUtils.getObjectDirectly(obj);
        if (object != null)
        {
          object.scrollFactor.set(scrollX, scrollY);
          return;
        }

        var object:FlxObject = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
        if (object != null) object.scrollFactor.set(scrollX, scrollY);
      });
      set("addLuaSprite", function(tag:String, place:Dynamic = false) {
        if (isStageLua && !preloading)
        {
          if (Stage.instance.swagBacks.exists(tag))
          {
            var shit = Stage.instance.swagBacks.get(tag);

            if (place == -1 || place == false || place == "false") Stage.instance.toAdd.push(shit);
            else
            {
              if (place == true || place == "true")
              {
                place = 4;
              }
              Stage.instance.layInFront[place].push(shit);
            }
          }
          return;
        }
        else
        {
          final mySprite:FlxSprite = MusicBeatState.variableMap(tag).get(tag);
          if (mySprite == null) return;

          final instance = LuaUtils.getTargetInstance();
          if (place == 2 || place == true) instance.add(mySprite);
          else
          {
            if (game == null || !game.isDead) instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterPlacement()), mySprite);
            else
              GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), mySprite);
          }
          return;
        }
      });

      set("setGraphicSize", function(obj:String, x:Float, y:Float = 0, updateHitbox:Bool = true) {
        var split:Array<String> = obj.split('.');
        var poop:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (poop != null)
        {
          poop.setGraphicSize(x, y);
          if (updateHitbox) poop.updateHitbox();
          return;
        }
        luaTrace('setGraphicSize: Couldnt find object: ' + obj, false, false, FlxColor.RED);
      });
      set("scaleObject", function(obj:String, x:Float, y:Float, updateHitbox:Bool = true) {
        var split:Array<String> = obj.split('.');
        var poop:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (poop != null)
        {
          poop.scale.set(x, y);
          if (updateHitbox) poop.updateHitbox();
          return;
        }
        luaTrace('scaleObject: Couldnt find object: ' + obj, false, false, FlxColor.RED);
      });
      set("updateHitbox", function(obj:String) {
        var split:Array<String> = obj.split('.');
        var poop:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }
        if (poop != null)
        {
          poop.updateHitbox();
          return;
        }
        luaTrace('updateHitbox: Couldnt find object: ' + obj, false, false, FlxColor.RED);
      });

      set("removeLuaSprite", function(tag:String, destroy:Bool = true, ?group:String = null) {
        LuaUtils.findToDestroy(tag, destroy, group);
      });

      set("luaSpriteExists", function(tag:String) {
        final obj:FlxSprite = MusicBeatState.variableMap(tag).get(tag);
        return (obj != null && (Std.isOfType(obj, ModchartSprite) || Std.isOfType(obj, ModchartAnimateSprite)));
      });

      set("luaTextExists", function(tag:String) {
        final obj:FlxText = MusicBeatState.variableMap(tag).get(tag);
        return (obj != null && Std.isOfType(obj, FlxText));
      });
      set("luaSoundExists", function(tag:String) {
        final obj:FlxSound = MusicBeatState.variableMap(tag).get(tag);
        return (obj != null && Std.isOfType(obj, FlxSound));
      });

      set("setHealthBarColors", function(left:String, right:String) {
        if (!ClientPrefs.data.healthColor) return;
        final left_color:Null<FlxColor> = left != null && left.length > 0 ? CoolUtil.colorFromString(left) : null;
        final right_color:Null<FlxColor> = right != null && right.length > 0 ? CoolUtil.colorFromString(right) : null;
        if (PlayState.SONG.options.oldBarSystem)
        {
          if (!ClientPrefs.data.gradientSystemForOldBars)
          {
            game.healthBar.createFilledBar((game.opponentMode ? right_color : left_color), (game.opponentMode ? left_color : right_color));
          }
          else
            game.healthBar.createGradientBar([right_color, left_color], [right_color, left_color]);
          game.healthBar.updateBar();
        }
        else
        {
          game.healthBarNew.setColors(left_color, right_color);
          game.healthBarHitNew.setColors(left_color, right_color);
        }
      });
      set("setTimeBarColors", function(left:String, right:String) {
        final left_color:Null<FlxColor> = left != null && left.length > 0 ? CoolUtil.colorFromString(left) : null;
        final right_color:Null<FlxColor> = right != null && right.length > 0 ? CoolUtil.colorFromString(right) : null;
        if (PlayState.SONG.options.oldBarSystem)
        {
          if (ClientPrefs.data.colorBarType == 'No Colors') game.timeBar.createFilledBar(FlxColor.fromString(Std.string(right)),
            FlxColor.fromString(Std.string(left)));
          else if (ClientPrefs.data.colorBarType == 'Main Colors') game.timeBar.createGradientBar([FlxColor.BLACK],
            [FlxColor.fromString(Std.string(right)), FlxColor.fromString(Std.string(left))]);
          else if (ClientPrefs.data.colorBarType == 'Reversed Colors') game.timeBar.createGradientBar([FlxColor.BLACK],
            [FlxColor.fromString(Std.string(left)), FlxColor.fromString(Std.string(right))]);
          game.timeBar.updateBar();
        }
        else
          game.timeBarNew.setColors(left_color, right_color);
      });

      set("setPosition", function(obj:String, ?x:Float = null, ?y:Float = null) {
        final split:Array<String> = obj.split('.');
        var object:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1) object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);

        if (object != null)
        {
          if (x != null) object.x = x;
          if (y != null) object.y = y;
          return true;
        }
        luaTrace("setPosition: Couldnt find object " + obj, false, false, FlxColor.RED);
        return false;
      });

      set("setObjectCamera", function(obj:String, camera:String = 'game') {
        final split:Array<String> = obj.split('.');
        var object:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1) object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);

        if (object != null)
        {
          object.cameras = [LuaUtils.cameraFromString(camera)];
          return;
        }
        luaTrace("setObjectCamera: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
        return;
      });
      set("setBlendMode", function(obj:String, blend:String = '') {
        final split:Array<String> = obj.split('.');
        var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1) spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        if (spr != null)
        {
          spr.blend = LuaUtils.blendModeFromString(blend);
          return true;
        }
        luaTrace("setBlendMode: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
        return false;
      });
      set("screenCenter", function(obj:String, pos:String = 'xy') {
        final split:Array<String> = obj.split('.');
        var spr:FlxObject = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1) spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);

        if (spr != null)
        {
          switch (pos.trim().toLowerCase())
          {
            case 'x':
              spr.screenCenter(X);
              return;
            case 'y':
              spr.screenCenter(Y);
              return;
            default:
              spr.screenCenter(XY);
              return;
          }
        }
        luaTrace("screenCenter: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
      });
      set("objectsOverlap", function(obj1:String, obj2:String) {
        var namesArray:Array<String> = [obj1, obj2];
        var objectsArray:Array<FlxSprite> = [];
        for (i in 0...namesArray.length)
        {
          final real:FlxSprite = LuaUtils.getObjectDirectly(namesArray[i]);
          if (real != null) objectsArray.push(real);
        }

        if (!objectsArray.contains(null) && FlxG.overlap(objectsArray[0], objectsArray[1]))
        {
          return true;
        }
        return false;
      });
      set("getPixelColor", function(obj:String, x:Int, y:Int) {
        final split:Array<String> = obj.split('.');
        var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1) spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);

        if (spr != null) return spr.pixels.getPixel32(x, y);
        return FlxColor.BLACK;
      });
      set("startDialogue", function(dialogueFile:String, ?music:String = null) {
        var path:String;
        var songPath:String = Paths.formatToSongPath(Song.loadedSongName);
        #if TRANSLATIONS_ALLOWED
        path = Paths.getPath('data/songs/$songPath/${dialogueFile}_${ClientPrefs.data.language}.json', TEXT);
        #if MODS_ALLOWED
        if (!FileSystem.exists(path))
        #else
        if (!Assets.exists(path, TEXT))
        #end
        #end
        path = Paths.getPath('data/$songPath/$dialogueFile.json', TEXT);

        luaTrace('startDialogue: Trying to load dialogue: ' + path);

        #if MODS_ALLOWED
        if (FileSystem.exists(path))
        #else
        if (Assets.exists(path, TEXT))
        #end
        {
          var shit:DialogueFile = DialogueBoxPsych.parseDialogue(path);
          if (shit.dialogue.length > 0)
          {
            game.startDialogue(shit, music);
            luaTrace('startDialogue: Successfully loaded dialogue', false, false, FlxColor.GREEN);
            return true;
          }
          else
            luaTrace('startDialogue: Your dialogue file is badly formatted!', false, false, FlxColor.RED);
        }
      else
      {
        luaTrace('startDialogue: Dialogue file not found', false, false, FlxColor.RED);
        if (game.endingSong) game.endSong();
        else
          game.startCountdown();
      }
        return false;
      });
      set("startVideo", function(videoFile:String, type:String = 'mp4', ?midSong:Bool = false, ?canSkip:Bool = true) {
        #if (VIDEOS_ALLOWED && hxvlc)
        if (FileSystem.exists(Paths.video(videoFile, type)))
        {
          if (game.videoCutscene != null)
          {
            game.remove(game.videoCutscene);
            game.videoCutscene.destroy();
          }
          game.videoCutscene = game.startVideo(videoFile, type, midSong, canSkip);
          return true;
        }
        else
        {
          luaTrace('startVideo: Video file not found: ' + videoFile, false, false, FlxColor.RED);
        }
        return false;
        #else
        PlayState.instance.inCutscene = true;
        new FlxTimer().start(0.1, function(tmr:FlxTimer) {
          PlayState.instance.inCutscene = false;
          if (game.endingSong) game.endSong();
          else
            game.startCountdown();
        });
        return true;
        #end
      });

      set("playMusic", function(sound:String, ?volume:Float = 1, ?loop:Bool = false) {
        FlxG.sound.playMusic(Paths.music(sound), volume, loop);
      });
      set("playSound", function(sound:String, ?volume:Float = 1, ?tag:String = null, ?loop:Bool = false) {
        if (tag != null && tag.length > 0)
        {
          final variables = MusicBeatState.variableMap(tag);
          if (variables == null) return null;
          final oldSnd = variables.get(tag);
          if (oldSnd != null)
          {
            oldSnd.stop();
            oldSnd.destroy();
          }
          MusicBeatState.getVariables("Sound").set(tag, FlxG.sound.play(Paths.sound(sound), volume, loop, null, true, function() {
            if (!loop) MusicBeatState.getVariables("Sound").remove(tag);
            if (game != null) game.callOnLuas('onSoundFinished', [tag]);
          }));
          return tag;
        }
        FlxG.sound.play(Paths.sound(sound), volume);
        return null;
      });
      set("stopSound", function(tag:String) {
        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null) FlxG.sound.music.stop();
        }
        else
        {
          final variables = MusicBeatState.variableMap(tag);
          if (variables == null) return;
          final snd:FlxSound = variables.get(tag);
          if (snd != null)
          {
            snd.stop();
            variables.remove(tag);
          }
        }
      });
      set("pauseSound", function(tag:String) {
        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null) FlxG.sound.music.pause();
        }
        else
        {
          final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
          if (snd != null) snd.pause();
        }
      });
      set("resumeSound", function(tag:String) {
        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null) FlxG.sound.music.play();
        }
        else
        {
          final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
          if (snd != null) snd.play();
        }
      });
      set("soundFadeIn", function(tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1) {
        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null) FlxG.sound.music.fadeIn(duration, fromValue, toValue);
        }
        else
        {
          final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
          if (snd != null) snd.fadeIn(duration, fromValue, toValue);
        }
      });
      set("soundFadeOut", function(tag:String, duration:Float, toValue:Float = 0) {
        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(duration, toValue);
        }
        else
        {
          final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
          if (snd != null) snd.fadeOut(duration, toValue);
        }
      });
      set("soundFadeCancel", function(tag:String) {
        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null && FlxG.sound.music.fadeTween != null) FlxG.sound.music.fadeTween.cancel();
        }
        else
        {
          final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
          if (snd != null && snd.fadeTween != null) snd.fadeTween.cancel();
        }
      });
      set("getSoundVolume", function(tag:String) {
        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null) return FlxG.sound.music.volume;
        }
        else
        {
          final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
          if (snd != null) return snd.volume;
        }
        return 0;
      });
      set("setSoundVolume", function(tag:String, value:Float) {
        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null)
          {
            FlxG.sound.music.volume = value;
            return;
          }
        }
        else
        {
          final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
          if (snd != null) snd.volume = value;
        }
      });
      set("getSoundTime", function(tag:String) {
        if (tag == null || tag.length < 1)
        {
          return FlxG.sound.music != null ? FlxG.sound.music.time : 0;
        }
        final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
        return snd != null ? snd.time : 0;
      });
      set("setSoundTime", function(tag:String, value:Float) {
        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null)
          {
            FlxG.sound.music.time = value;
            return;
          }
        }
        else
        {
          final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
          if (snd != null) snd.time = value;
        }
      });
      set("getSoundPitch", function(tag:String) {
        #if FLX_PITCH
        final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
        return snd != null ? snd.pitch : 1;
        #else
        luaTrace("getSoundPitch: Sound Pitch is not supported on this platform!", false, false, FlxColor.RED);
        return 1;
        #end
      });
      set("setSoundPitch", function(tag:String, value:Float, ?doPause:Bool = false) {
        #if FLX_PITCH
        final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
        if (snd != null)
        {
          var wasResumed:Bool = snd.playing;
          if (doPause) snd.pause();
          snd.pitch = value;
          if (doPause && wasResumed) snd.play();
        }

        if (tag == null || tag.length < 1)
        {
          if (FlxG.sound.music != null)
          {
            final wasResumed:Bool = FlxG.sound.music.playing;
            if (doPause) FlxG.sound.music.pause();
            FlxG.sound.music.pitch = value;
            if (doPause && wasResumed) FlxG.sound.music.play();
            return;
          }
        }
        else
        {
          final snd:FlxSound = MusicBeatState.variableMap(tag).get(tag);
          if (snd != null)
          {
            final wasResumed:Bool = snd.playing;
            if (doPause) snd.pause();
            snd.pitch = value;
            if (doPause && wasResumed) snd.play();
          }
        }
        #else
        luaTrace("setSoundPitch: Sound Pitch is not supported on this platform!", false, false, FlxColor.RED);
        #end
      });

      // mod settings
      addLocalCallback("getModSetting", function(saveTag:String, ?modName:String = null) {
        #if MODS_ALLOWED
        if (modName == null)
        {
          if (this.modFolder == null)
          {
            luaTrace('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', false, false, FlxColor.RED);
            return null;
          }
          modName = this.modFolder;
        }
        return LuaUtils.getModSetting(saveTag, modName);
        #else
        luaTrace("getModSetting: Mods are disabled in this build!", false, false, FlxColor.RED);
        #end
      });
      //

      set("debugPrint", function(text:Dynamic = '', color:String = 'WHITE') game.addTextToDebug(text, CoolUtil.colorFromString(color)));

      set("Debug", function(type:String, input:Dynamic, ?pos:haxe.PosInfos) {
        switch (type)
        {
          case 'logError':
            Debug.logError(input, pos);
          case 'logWarn':
            Debug.logWarn(input, pos);
          case 'logInfo':
            Debug.logInfo(input, pos);
          case 'logTrace':
            Debug.logTrace(input, pos);
        }
      });

      set("initBackgroundOverlayVideo", function(vidPath:String, type:String, forMidSong:Bool, canSkip:Bool, loop:Bool, playOnLoad:Bool, layInFront:Bool) {
        #if (VIDEOS_ALLOWED && hxvlc)
        game.backgroundOverlayVideo(vidPath, type, forMidSong, canSkip, loop, playOnLoad, layInFront);
        #end
      });

      set("getPlayStateVariable", function(item:String, instance:Bool = true) {
        try
        {
          var result:Dynamic = null;
          if (instance) result = Reflect.getProperty(PlayState.instance, item);
          else
            result = Reflect.getProperty(PlayState, item);
          return result;
        }
        catch (e)
        {
          Debug.displayAlert("Unknown Item: " + item, "Item Not Found");
          return null;
        }
        return null;
      });

      set("setPlayStateVariable", function(item:String, value:Dynamic, instance:Bool = true) {
        try
        {
          if (instance) Reflect.setProperty(PlayState.instance, item, value);
          else
            Reflect.setProperty(PlayState, item, value);
          return true;
        }
        catch (e)
        {
          Debug.displayAlert("Unknown Item: " + item, "Item Not Found");
          return false;
        }
        return false;
      });

      addLocalCallback("close", function() {
        closed = true;
        Debug.logInfo('Closing script $scriptName');
        return closed;
      });

      #if DISCORD_ALLOWED DiscordClient.addLuaCallbacks(this); #end
      #if ACHIEVEMENTS_ALLOWED Achievements.addLuaCallbacks(this); #end
      #if TRANSLATIONS_ALLOWED Language.addLuaCallbacks(this); #end
      #if HSCRIPT_ALLOWED HScript.implement(this); #end
      #if VIDEOS_ALLOWED VideoFunctions.implement(this); #end
      #if flxanimate FlxAnimateFunctions.implement(this); #end
      #if SCEModchartingTools
      if (game != null
        && !isStageLua
        && PlayState.SONG != null
        && PlayState.SONG.options.notITG
        && ClientPrefs.getGameplaySetting('modchart')) modcharting.ModchartFuncs.loadLuaFunctions(this);
      #end
      psychlua.betadciu.SupportBETAFunctions.implement(this);
      ReflectionFunctions.implement(this);
      TextFunctions.implement(this);
      ExtraFunctions.implement(this);
      CustomSubstate.implement(this);
      ShaderFunctions.implement(this);
      GroupFunctions.implement(this);
      DeprecatedFunctions.implement(this);

      // Load ALL Lua Functions of the engine
			slushi.slushiLua.SlushiLua.loadSlushiLua(this);
    }

    try
    {
      var isString:Bool = !FileSystem.exists(scriptName);
      var result:Dynamic = null;
      if (!isString) result = LuaL.dofile(lua, scriptName);
      else
        result = LuaL.dostring(lua, scriptName);

      var resultStr:String = Lua.tostring(lua, result);
      if (resultStr != null && result != 0)
      {
        Debug.logInfo(resultStr);
        #if windows
				CppAPI.showMessageBox(resultStr, 'Error loading Lua script!', MSG_WARNING);
				#else
				luaTrace('Error in [$scriptName]: $resultStr', true, false, FlxColor.RED);
				#end
        stop();
        return;
      }
      if (isString && notScriptName != null) scriptName = notScriptName;
      else if (isString && notScriptName == null) scriptName = 'unknown';
    }
    catch (e:Dynamic)
    {
      #if windows
			CppAPI.showMessageBox('Failed to catch error on script and error on loading script!:\n$e', 'Error on loading...', MSG_WARNING);
			#else
			Debug.displayAlert('Failed to catch error on script and error on loading script!: $e', 'Error on loading...');
			#end
      Debug.logInfo('ERROR! $e');
      return;
    }
    call('onCreate', []);

    if (isStageLua) Debug.logInfo('Limited usage of playstate properties inside the stage .lua\'s or .hx\'s!');
    Debug.logInfo('lua file loaded succesfully: $scriptName (${Std.int(Date.now().getTime() - times)}ms)');
  }

  // main
  public var lastCalledFunction:String = '';

  public static var lastCalledScript:FunkinLua = null;

  public function call(func:String, args:Array<Dynamic>):Dynamic
  {
    #if LUA_ALLOWED
    if (closed) return LuaUtils.Function_Continue;

    lastCalledFunction = func;
    lastCalledScript = this;
    try
    {
      if (lua == null) return LuaUtils.Function_Continue;

      Lua.getglobal(lua, func);
      var type:Int = Lua.type(lua, -1);

      if (type != Lua.LUA_TFUNCTION)
      {
        if (type > Lua.LUA_TNIL) luaTrace("ERROR (" + func + "): attempt to call a " + LuaUtils.typeToString(type) + " value", false, false, FlxColor.RED);

        Lua.pop(lua, 1);
        return LuaUtils.Function_Continue;
      }

      for (arg in args)
        Convert.toLua(lua, arg);
      var status:Int = Lua.pcall(lua, args.length, 1, 0);

      // Checks if it's not successful, then show a error.
      if (status != Lua.LUA_OK)
      {
        var error:String = getErrorMessage(status);
        luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
        return LuaUtils.Function_Continue;
      }

      // If successful, pass and then return the result.
      var result:Dynamic = cast Convert.fromLua(lua, -1);
      if (result == null) result = LuaUtils.Function_Continue;

      Lua.pop(lua, 1);
      if (closed) stop();
      return result;
    }
    catch (e:Dynamic)
    {
      Debug.logTrace(e);
    }
    #end
    return LuaUtils.Function_Continue;
  }

  public function set(variable:String, data:Dynamic)
  {
    if (lua == null) return;

    if (Reflect.isFunction(data))
    {
      Lua_helper.add_callback(lua, variable, data);
      return;
    }

    Convert.toLua(lua, data);
    Lua.setglobal(lua, variable);
  }

  public function stop()
  {
    closed = true;

    lua_Cameras.clear();
    lua_Custom_Shaders.clear();

    if (lua == null)
    {
      return;
    }
    Lua.close(lua);
    lua = null;
    #if HSCRIPT_ALLOWED
    if (hscript != null)
    {
      hscript.destroy();
      hscript = null;
    }
    #end
  }

  public function get(var_name:String, type:Dynamic):Dynamic
  {
    var result:Any = null;

    Lua.getglobal(lua, var_name);
    result = Convert.fromLua(lua, -1);
    Lua.pop(lua, 1);

    if (result == null)
    {
      return null;
    }
    else
    {
      var result = LuaUtils.convert(result, type);
      return result;
    }
  }

  function oldTweenFunction(tag:String, vars:String, tweenValue:Any, duration:Float, ease:String, funcName:String)
  {
    var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
    if (target != null)
    {
      if (tag != null)
      {
        MusicBeatState.getVariables("Tween").set(tag, FlxTween.tween(target, tweenValue, duration,
          {
            ease: LuaUtils.getTweenEaseByString(ease),
            onComplete: function(twn:FlxTween) {
              MusicBeatState.getVariables("Tween").remove(tag);
              if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [tag, vars]);
            }
          }));
        return tag;
      }
      else
        FlxTween.tween(target, tweenValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
    }
    else
      luaTrace('$funcName: Couldnt find object: $vars', false, false, FlxColor.RED);
    return null;
  }

  public static function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE)
  {
    if (ignoreCheck || getBool('luaDebugMode'))
    {
      if (deprecated && !getBool('luaDeprecatedWarnings'))
      {
        return;
      }
      PlayState.instance.addTextToDebug(text, color);
      Debug.logTrace(text);
    }
  }

  function noteTweenFunction(tag:String, note:Int, data:Dynamic, duration:Float, ease:String)
  {
    if (PlayState.instance == null) return null;

    var strumNote:StrumArrow = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
    if (strumNote == null) return null;

    if (tag != null)
    {
      LuaUtils.cancelTween(tag);
      MusicBeatState.getVariables("Tween").set(tag, FlxTween.tween(strumNote, data, duration,
        {
          ease: LuaUtils.getTweenEaseByString(ease),
          onComplete: function(twn:FlxTween) {
            MusicBeatState.getVariables("Tween").remove(tag);
            if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
          }
        }));
      return tag;
    }
    else
      FlxTween.tween(strumNote, data, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
    return null;
  }

  public static function getBool(variable:String)
  {
    if (lastCalledScript == null) return false;

    var lua:State = lastCalledScript.lua;
    if (lua == null) return false;

    var result:String = null;
    Lua.getglobal(lua, variable);
    result = Convert.fromLua(lua, -1);
    Lua.pop(lua, 1);

    if (result == null)
    {
      return false;
    }
    return (result == 'true');
  }

  function findScript(scriptFile:String, ext:String = '.lua')
  {
    if (!scriptFile.endsWith(ext)) scriptFile += ext;
    var path:String = Paths.getPath(scriptFile, TEXT);
    #if MODS_ALLOWED
    if (FileSystem.exists(path))
    #else
    if (Assets.exists(path, TEXT))
    #end
    {
      return path;
    }
    #if MODS_ALLOWED
    else if (FileSystem.exists(scriptFile))
    #else
    else if (Assets.exists(scriptFile, TEXT))
    #end
    {
      return scriptFile;
    }
    return null;
  }

  public function getErrorMessage(status:Int):String
  {
    var v:String = Lua.tostring(lua, -1);
    Lua.pop(lua, 1);

    if (v != null) v = v.trim();
    if (v == null || v == "")
    {
      switch (status)
      {
        case Lua.LUA_ERRRUN:
          return "Runtime Error";
        case Lua.LUA_ERRMEM:
          return "Memory Allocation Error";
        case Lua.LUA_ERRERR:
          return "Critical Error";
      }
      return "Unknown Error";
    }

    return v;
    return null;
  }

  public function addLocalCallback(name:String, myFunction:Dynamic)
  {
    callbacks.set(name, myFunction);
    set(name, null); // just so that it gets called
  }

  #if (MODS_ALLOWED && !flash && sys)
  public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
  #end

  public function initLuaShader(name:String)
  {
    if (!ClientPrefs.data.shaders) return false;

    #if (MODS_ALLOWED && !flash && sys)
    if (runtimeShaders.exists(name))
    {
      var shaderData:Array<String> = runtimeShaders.get(name);
      if (shaderData != null && (shaderData[0] != null || shaderData[1] != null))
      {
        luaTrace('Shader $name was already initialized!');
        return true;
      }
    }

    var foldersToCheck:Array<String> = [Paths.mods('data/shaders/')];
    if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) foldersToCheck.insert(0,
      Paths.mods(Mods.currentModDirectory + '/data/shaders/'));

    for (mod in Mods.getGlobalMods())
      foldersToCheck.insert(0, Paths.mods(mod + '/data/shaders/'));

    for (folder in foldersToCheck)
    {
      if (FileSystem.exists(folder))
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
    }
    luaTrace('Missing shader $name .frag AND .vert files!', false, false, FlxColor.RED);
    #else
    luaTrace('This platform doesn\'t support Runtime Shaders!', false, false, FlxColor.RED);
    #end
    return false;
  }
}
#end
