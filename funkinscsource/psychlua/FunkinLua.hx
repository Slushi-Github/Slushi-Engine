#if LUA_ALLOWED
package psychlua;

import flixel.FlxBasic;
import flixel.FlxObject;
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
import substates.PauseSubState;
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
  var STAGE = 'STAGE';
  var PLAYSTATE = 'PLAYSTATE';
  var MODCHARTEDITOR = 'MODCHARTEDITOR';
  var CUSTOM = 'CUSTOM';
}

class FunkinLua
{
  public static var Function_Stop:Dynamic = "##PSYCHLUA_FUNCTIONSTOP";
  public static var Function_Continue:Dynamic = "##PSYCHLUA_FUNCTIONCONTINUE";
  public static var Function_StopLua:Dynamic = "##PSYCHLUA_FUNCTIONSTOPLUA";

  public static var Function_StopHScript:Dynamic = "##PSYCHLUA_FUNCTIONSTOPHSCRIPT";
  public static var Function_StopAll:Dynamic = "##PSYCHLUA_FUNCTIONSTOPALL";

  public var lua:State = null;
  public var camTarget:FlxCamera;
  public var modFolder:String = null;

  public var scriptName:String = '';

  public var preloading:Bool = false;

  public var typeInstance:FileInstance = PLAYSTATE;

  public var isStageLua(get, never):Bool;

  public function get_isStageLua():Bool
  {
    return typeInstance == STAGE;
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
  public static var lua_Shaders:Map<String, shaders.FunkinSourcedShaders.ShaderBase> = [];
  public static var lua_Custom_Shaders:Map<String, codenameengine.shaders.CustomShader> = [];

  public function new(scriptName:String, ?instance:FileInstance = PLAYSTATE, ?preloading:Bool = false, ?notScriptName:String = null)
  {
    var times:Float = Date.now().getTime();
    var game:PlayState = PlayState.instance;

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

    if (game != null)
    {
      if (!isStageLua) game.luaArray.push(this);
      else
        game.stage.luaArray.push(this);
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
    set('difficultyPath', Paths.formatToSongPath(Difficulty.getString(false)));
    set('difficultyNameTranslation', Difficulty.getString(true));
    set('weekRaw', PlayState.storyWeek);
    set('week', WeekData.weeksList[PlayState.storyWeek]);
    set('seenCutscene', PlayState.seenCutscene);
    set('hasVocals', PlayState.SONG.needsVoices);

    // Camera poo
    set('cameraX', 0);
    set('cameraY', 0);

    // Screen stuff
    set('screenWidth', FlxG.width);
    set('screenHeight', FlxG.height);

    if (game != null)
    {
      // PlayState variables
      set('curSection', 0);
      set('curBeat', 0);
      set('curStep', 0);

      set('score', 0);
      set('misses', 0);
      set('hits', 0);
      set('combo', 0);

      set('rating', 0);
      set('ratingName', '');
      set('ratingFC', '');
      set('version', MainMenuState.psychEngineVersion.trim());
      set('SCEversion', MainMenuState.SCEVersion.trim());

      set('inGameOver', false);
      set('mustHitSection', false);
      set('altAnim', false);
      set('playerAltAnim', false);
      set('CPUAltAnim', false);
      set('gfSection', false);
      set('player4Section', false);
      set("playDadSing", true);
      set("playBFSing", true);

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
    }

    if (PlayState.SONG != null)
    {
      // Character shit
      set('boyfriendName', PlayState.SONG.characters.player);
      set('dadName', PlayState.SONG.characters.opponent);
      set('gfName', PlayState.SONG.characters.girlfriend);
      set('momName', PlayState.SONG.characters.secondOpponent);
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

      set("makeAnimatedLuaSprite", function(tag:String, image:String, x:Float, y:Float, spriteType:String = "sparrow") {
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
        LuaUtils.destroyObject(tag);
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
        #if (!flash && MODS_ALLOWED && sys)
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
          game.callOnScripts(funcName, args, ignoreStops, excludeScripts, excludeValues);
          return true;
        });
      addLocalCallback("callOnLuas",
        function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
            ?excludeValues:Array<Dynamic> = null) {
          if (excludeScripts == null) excludeScripts = [];
          if (ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
          game.callOnLuas(funcName, args, ignoreStops, excludeScripts, excludeValues);
          return true;
        });
      addLocalCallback("callOnHScript",
        function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
            ?excludeValues:Array<Dynamic> = null) {
          if (excludeScripts == null) excludeScripts = [];
          if (ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
          game.callOnHScript(funcName, args, ignoreStops, excludeScripts, excludeValues);
          return true;
        });
      addLocalCallback("callOnHSI",
        function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
            ?excludeValues:Array<Dynamic> = null) {
          if (excludeScripts == null) excludeScripts = [];
          if (ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
          game.callOnHSI(funcName, args, ignoreStops, excludeScripts, excludeValues);
          return true;
        });
      addLocalCallback("callOnSCHS",
        function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
            ?excludeValues:Array<Dynamic> = null) {
          if (excludeScripts == null) excludeScripts = [];
          if (ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
          game.callOnSCHS(funcName, args, ignoreStops, excludeScripts, excludeValues);
          return true;
        });

      set("callScript", function(luaFile:String, funcName:String, ?args:Array<Dynamic> = null) {
        if (args == null)
        {
          args = [];
        }

        var foundScript:String = findScript(luaFile);
        if (foundScript != null) for (luaInstance in game.luaArray)
          if (luaInstance.scriptName == foundScript)
          {
            luaInstance.call(funcName, args);
            return;
          }
      });

      set("getGlobalFromScript", function(luaFile:String, global:String) { // returns the global from a script
        var foundScript:String = findScript(luaFile);
        if (foundScript != null) for (luaInstance in game.luaArray)
          if (luaInstance.scriptName == foundScript)
          {
            Lua.getglobal(luaInstance.lua, global);
            if (Lua.isnumber(luaInstance.lua, -1)) Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
            else if (Lua.isstring(luaInstance.lua, -1)) Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
            else if (Lua.isboolean(luaInstance.lua, -1)) Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
            else
              Lua.pushnil(lua);

            // TODO: table

            Lua.pop(luaInstance.lua, 1); // remove the global

            return;
          }
        Lua.pushnil(lua);
      });
      set("setGlobalFromScript", function(luaFile:String, global:String, val:Dynamic) { // returns the global from a script
        var foundScript:String = findScript(luaFile);
        if (foundScript != null) for (luaInstance in game.luaArray)
          if (luaInstance.scriptName == foundScript) luaInstance.set(global, val);
      });
      /*set("getGlobals", function(luaFile:String) { // returns a copy of the specified file's globals
        var foundScript:String = findScript(luaFile);
        if(foundScript != null)
        {
          for (luaInstance in game.luaArray)
          {
            if(luaInstance.scriptName == foundScript)
            {
              Lua.newtable(lua);
              var tableIdx = Lua.gettop(lua);

              Lua.pushvalue(luaInstance.lua, Lua.LUA_GLOBALSINDEX);
              while(Lua.next(luaInstance.lua, -2) != 0) {
                // key = -2
                // value = -1

                var pop:Int = 0;

                // Manual conversion
                // first we convert the key
                if(Lua.isnumber(luaInstance.lua,-2)){
                  Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -2));
                  pop++;
                }else if(Lua.isstring(luaInstance.lua,-2)){
                  Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -2));
                  pop++;
                }else if(Lua.isboolean(luaInstance.lua,-2)){
                  Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -2));
                  pop++;
                }
                // TODO: table


                // then the value
                if(Lua.isnumber(luaInstance.lua,-1)){
                  Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
                  pop++;
                }else if(Lua.isstring(luaInstance.lua,-1)){
                  Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
                  pop++;
                }else if(Lua.isboolean(luaInstance.lua,-1)){
                  Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
                  pop++;
                }
                // TODO: table

                if(pop==2)Lua.rawset(lua, tableIdx); // then set it
                Lua.pop(luaInstance.lua, 1); // for the loop
              }
              Lua.pop(luaInstance.lua,1); // end the loop entirely
              Lua.pushvalue(lua, tableIdx); // push the table onto the stack so it gets returned

              return;
            }

          }
        }
      });*/

      set("isRunningLuaFile", function(luaFile:String) {
        var foundScript:String = findScript(luaFile);
        if (foundScript != null) for (luaInstance in game.luaArray)
          if (luaInstance.scriptName == foundScript) return true;
        return false;
      });
      set("isRunningHxFile", function(hxFile:String) {
        for (extn in CoolUtil.haxeExtensions)
        {
          var foundScript:String = findScript(hxFile, '.$extn');
          if (foundScript != null) for (luaInstance in game.hscriptArray)
            if (luaInstance.origin == foundScript) return true;
        }
        return false;
      });

      set("setVar", function(varName:String, value:Dynamic) {
        MusicBeatState.getVariables().set(varName, value);
        return value;
      });
      set("getVar", function(varName:String) {
        return MusicBeatState.getVariables().get(varName);
      });
      set("removeVar", function(varName:String) {
        return MusicBeatState.getVariables().remove(varName);
      });

      set("addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { // would be dope asf.
        var foundScript:String = findScript(luaFile);
        if (foundScript != null)
        {
          if (!ignoreAlreadyRunning) for (luaInstance in game.luaArray)
            if (luaInstance.scriptName == foundScript)
            {
              luaTrace('addLuaScript: The script "' + foundScript + '" is already running!');
              return;
            }

          new FunkinLua(foundScript, typeInstance);
          return;
        }
        luaTrace("addLuaScript: Script doesn't exist!", false, false, FlxColor.RED);
      });
      set("addHScript", function(hxFile:String, ?ignoreAlreadyRunning:Bool = false) {
        #if HSCRIPT_ALLOWED
        for (extn in CoolUtil.haxeExtensions)
        {
          var foundScript:String = findScript(hxFile, '.$extn');
          if (foundScript != null)
          {
            if (!ignoreAlreadyRunning) for (script in game.hscriptArray)
              if (script.origin == foundScript)
              {
                luaTrace('addHScript: The script "' + foundScript + '" is already running!');
                return;
              }

            game.initHScript(foundScript);
            return;
          }
        }
        luaTrace("addHScript: Script doesn't exist!", false, false, FlxColor.RED);
        #else
        luaTrace("addHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
        #end
      });
      set("removeLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) {
        var foundScript:String = findScript(luaFile);
        if (foundScript != null)
        {
          if (!ignoreAlreadyRunning) for (luaInstance in game.luaArray)
            if (luaInstance.scriptName == foundScript)
            {
              luaInstance.stop();
              Debug.logTrace('Closing script ' + luaInstance.scriptName);
              return true;
            }

          for (luaInstance in game.stage.luaArray)
            if (luaInstance.scriptName == foundScript)
            {
              luaInstance.stop();
              Debug.logTrace('Closing script ' + luaInstance.scriptName);
              return true;
            }
        }
        luaTrace('removeLuaScript: Script $luaFile isn\'t running!', false, false, FlxColor.RED);
        return false;
      });
      set("removeHScript", function(hxFile:String, ?ignoreAlreadyRunning:Bool = false) {
        #if HSCRIPT_ALLOWED
        for (extn in CoolUtil.haxeExtensions)
        {
          var foundScript:String = findScript(hxFile, '.$extn');
          if (foundScript != null)
          {
            if (!ignoreAlreadyRunning) for (script in game.hscriptArray)
              if (script.origin == foundScript)
              {
                Debug.logInfo('Closing script ' + script.origin);
                game.hscriptArray.remove(script);
                script.destroy();
                return true;
              }
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
        var split:Array<String> = obj.split('.');
        var leObj:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          leObj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (leObj != null)
        {
          var groupObj:Dynamic = LuaUtils.getObjectDirectly(group);
          if (groupObj == null) groupObj = LuaUtils.getTargetInstance();

          return groupObj.members.indexOf(leObj);
        }
        luaTrace("getObjectOrder: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
        return -1;
      });
      set("setObjectOrder", function(obj:String, position:Int, ?group:String = null) {
        var split:Array<String> = obj.split('.');
        var leObj:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          leObj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (position <= 0) position = 0;

        if (leObj != null)
        {
          var groupObj:Dynamic = LuaUtils.getObjectDirectly(group);
          if (groupObj == null) groupObj = LuaUtils.getTargetInstance();

          groupObj.remove(leObj, true);
          groupObj.insert(position, leObj);
          return;
        }
        luaTrace("setObjectOrder: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
      });

      // gay ass tweens
      set("startTween", function(tag:String, vars:String, values:Any = null, duration:Float, options:Any = null) {
        var itemExam:Dynamic = LuaUtils.tweenPrepare(tag, vars);
        if (itemExam != null)
        {
          if (values != null)
          {
            var myOptions:LuaTweenOptions = LuaUtils.getLuaTween(options);
            if (tag != null)
            {
              var variables = MusicBeatState.getVariables();
              var originalTag:String = tag;
              tag = LuaUtils.checkVariable(tag, 'tween_');
              variables.set(tag, FlxTween.tween(itemExam, values, duration,
                {
                  type: myOptions.type,
                  ease: myOptions.ease,
                  startDelay: myOptions.startDelay,
                  loopDelay: myOptions.loopDelay,

                  onUpdate: function(twn:FlxTween) {
                    if (myOptions.onUpdate != null) game.callOnLuas(myOptions.onUpdate, [originalTag, vars]);
                  },
                  onStart: function(twn:FlxTween) {
                    if (myOptions.onStart != null) game.callOnLuas(myOptions.onStart, [originalTag, vars]);
                  },
                  onComplete: function(twn:FlxTween) {
                    if (twn.type == FlxTweenType.ONESHOT || twn.type == FlxTweenType.BACKWARD) variables.remove(tag);
                    if (myOptions.onComplete != null) game.callOnLuas(myOptions.onComplete, [originalTag, vars]);
                  }
                }));
            }
            else
              FlxTween.tween(itemExam, values, duration,
                {
                  type: myOptions.type,
                  ease: myOptions.ease,
                  startDelay: myOptions.startDelay,
                  loopDelay: myOptions.loopDelay
                });
          }
        }
        else
          luaTrace('startTween: Couldnt find object: ' + vars, false, false, FlxColor.RED);
      });

      set("doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
        oldTweenFunction(tag, vars, {x: value}, duration, ease, 'doTweenX');
      });
      set("doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
        oldTweenFunction(tag, vars, {y: value}, duration, ease, 'doTweenY');
      });
      set("doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
        oldTweenFunction(tag, vars, {angle: value}, duration, ease, 'doTweenAngle');
      });
      set("doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
        oldTweenFunction(tag, vars, {alpha: value}, duration, ease, 'doTweenAlpha');
      });
      set("doTweenZoom", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
        oldTweenFunction(tag, vars, {zoom: value}, duration, ease, 'doTweenZoom');
      });

      set("doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String) {
        var itemExam:Dynamic = LuaUtils.tweenPrepare(tag, vars);
        if (itemExam != null)
        {
          var curColor:FlxColor = itemExam.color;
          curColor.alphaFloat = itemExam.alpha;
          if (tag != null)
          {
            var originalTag:String = tag;
            tag = LuaUtils.checkVariable(tag, 'tween_');
            var variables = MusicBeatState.getVariables();
            variables.set(tag, FlxTween.color(itemExam, duration, curColor, CoolUtil.colorFromString(targetColor),
              {
                ease: LuaUtils.getTweenEaseByString(ease),
                onComplete: function(twn:FlxTween) {
                  variables.remove(tag);
                  if (game != null) game.callOnLuas('onTweenCompleted', [originalTag, vars]);
                }
              }));
          }
          else
            FlxTween.color(itemExam, duration, curColor, CoolUtil.colorFromString(targetColor), {ease: LuaUtils.getTweenEaseByString(ease)});
        }
        else
          luaTrace('doTweenColor: Couldnt find object: ' + vars, false, false, FlxColor.RED);
      });

      // Tween shit, but for strums
      set("noteTweenX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
        noteTweenFunction(tag, note, {x: value}, duration, ease);
      });
      set("noteTweenY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
        noteTweenFunction(tag, note, {y: value}, duration, ease);
      });
      set("noteTweenAlpha", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
        noteTweenFunction(tag, note, {alpha: value}, duration, ease);
      });
      set("noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
        noteTweenFunction(tag, note, {angle: value}, duration, ease);
      });
      set("noteTweenDirection", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
        noteTweenFunction(tag, note, {direction: value}, duration, ease);
      });
      set("mouseClicked", function(button:String) {
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
      set("mousePressed", function(button:String) {
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
      set("mouseReleased", function(button:String) {
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

      set("cancelTween", function(tag:String) LuaUtils.cancelTween(tag));

      set("runTimer", function(tag:String, time:Float = 1, loops:Int = 1) {
        LuaUtils.cancelTimer(tag);
        var variables = MusicBeatState.getVariables();

        var originalTag:String = tag;
        tag = LuaUtils.checkVariable(tag, 'timer_');
        variables.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer) {
          if (tmr.finished) variables.remove(tag);
          game.callOnLuas('onTimerCompleted', [originalTag, tmr.loops, tmr.loopsLeft]);
        }, loops));
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
      set("getScore", function() return game.songScore);
      set("getMisses", function() return game.songMisses);
      set("getHits", function() return game.songHits);

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
        function(name:String, arg1:Dynamic, arg2:Dynamic, ?arg3:Dynamic, arg4:Dynamic, ?arg5:Dynamic, ?arg6:Dynamic, ?arg7:Dynamic, ?arg8:Dynamic,
            ?arg9:Dynamic, ?arg10:Dynamic, ?arg11:Dynamic, ?arg12:Dynamic, ?arg13:Dynamic, ?arg14:Dynamic) {
          var value1:String = arg1;
          var value2:String = arg2;
          var value3:String = arg3;
          var value4:String = arg4;
          var value5:String = arg5;
          var value6:String = arg6;
          var value7:String = arg7;
          var value8:String = arg8;
          var value9:String = arg9;
          var value10:String = arg10;
          var value11:String = arg11;
          var value12:String = arg12;
          var value13:String = arg13;
          var value14:String = arg14;
          game.triggerEventLegacy(name, value1, value2, Conductor.songPosition, value3, value4, value5, value6, value7, value8, value9, value10, value11,
            value12, value13, value14);
          return true;
        });

      set("triggerEvent", function(name:String, luaArgs:Array<Dynamic>) {
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
        PauseSubState.restartSong(skipTransition);
        return true;
      });
      set("exitSong", function(?skipTransition:Bool = false) {
        if (skipTransition)
        {
          FlxTransitionableState.skipNextTransIn = true;
          FlxTransitionableState.skipNextTransOut = true;
        }

        if (PlayState.isStoryMode) MusicBeatState.switchState(new StoryMenuState());
        else
          MusicBeatState.switchState(new states.freeplay.FreeplayState());

        #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

        FlxG.sound.playMusic(SlushiMain.getSLEPath("Musics/SLE_HackNet_Resonance.ogg"));
        PlayState.changedDifficulty = false;
        PlayState.chartingMode = false;
        PlayState.modchartMode = false;
        game.transitioning = true;
        FlxG.camera.followLerp = 0;
        Mods.loadTopMod();
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
      set("cameraShake", function(camera:String, intensity:Float, duration:Float) {
        LuaUtils.cameraFromString(camera).shake(intensity, duration);
      });

      set("cameraFlash", function(camera:String, color:String, duration:Float, forced:Bool) {
        LuaUtils.cameraFromString(camera).flash(CoolUtil.colorFromString(color), duration, null, forced);
      });
      set("cameraFade", function(camera:String, color:String, duration:Float, forced:Bool) {
        LuaUtils.cameraFromString(camera).fade(CoolUtil.colorFromString(color), duration, false, null, forced);
      });
      set("setRatingPercent", function(value:Float) {
        return game.ratingPercent = value;
      });
      set("setRatingName", function(value:String) {
        return game.ratingName = value;
      });
      set("setRatingFC", function(value:String) {
        return game.ratingFC = value;
      });
      set("getMouseX", function(camera:String = 'game') {
        var cam:FlxCamera = LuaUtils.cameraFromString(camera);
        return FlxG.mouse.getScreenPosition(cam).x;
      });
      set("getMouseY", function(camera:String = 'game') {
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
        LuaUtils.destroyObject(tag);
        var leSprite:FlxBackdrop = null;
        if (image != null && image.length > 0)
        {
          leSprite = new FlxBackdrop(Paths.image(image), FlxAxes.fromString(axes), Std.int(spacingX), Std.int(spacingY));
        }
        leSprite.antialiasing = ClientPrefs.data.antialiasing;
        MusicBeatState.getVariables().set(tag, leSprite);
        leSprite.active = true;
      });
      set("makeLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0) {
        tag = tag.replace('.', '');
        LuaUtils.destroyObject(tag);
        var leSprite:ModchartSprite = new ModchartSprite(x, y);
        if (image != null && image.length > 0)
        {
          leSprite.loadGraphic(Paths.image(image));
        }
        if (isStageLua && !preloading) Stage.instance.swagBacks.set(tag, leSprite);
        else
          MusicBeatState.getVariables().set(tag, leSprite);
        leSprite.active = true;
      });
      set("makeSkewedSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0) {
        tag = tag.replace('.', '');
        LuaUtils.destroyObject(tag);
        var leSprite:FlxSkewed = new FlxSkewed(x, y);
        if (image != null && image.length > 0)
        {
          leSprite.loadGraphic(Paths.image(image));
        }
        if (isStageLua && !preloading) Stage.instance.swagBacks.set(tag, leSprite);
        else
          MusicBeatState.getVariables().set(tag, leSprite);
        leSprite.active = true;
      });
      set("makeAnimatedLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0, ?spriteType:String = "sparrow") {
        tag = tag.replace('.', '');
        LuaUtils.destroyObject(tag);
        var leSprite:ModchartSprite = new ModchartSprite(x, y);

        LuaUtils.loadFrames(leSprite, image, spriteType);
        if (isStageLua && !preloading) Stage.instance.swagBacks.set(tag, leSprite);
        else
          MusicBeatState.getVariables().set(tag, leSprite);
      });

      set("makeGraphic", function(obj:String, width:Int = 256, height:Int = 256, color:String = 'FFFFFF') {
        var spr:FlxSprite = LuaUtils.getObjectDirectly(obj, false);
        if (Stage.instance.swagBacks.exists(obj))
        {
          spr = Stage.instance.swagBacks.get(obj);
          spr.makeGraphic(width, height, CoolUtil.colorFromString(color));
          return;
        }
        if (MusicBeatState.getVariables().exists(obj))
        {
          spr = MusicBeatState.getVariables().get(obj);
          spr.makeGraphic(width, height, CoolUtil.colorFromString(color));
          return;
        }
        if (spr != null) spr.makeGraphic(width, height, CoolUtil.colorFromString(color));
      });
      set("addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
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

      set("addAnimation", function(obj:String, name:String, frames:Array<Int>, framerate:Int = 24, loop:Bool = true) {
        var obj:FlxSprite = cast LuaUtils.getObjectDirectly(obj);
        if (obj != null && obj.animation != null)
        {
          obj.animation.add(name, frames, framerate, loop);
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

      set("addAnimationByIndices", function(obj:String, name:String, prefix:String, indices:Any, framerate:Int = 24, loop:Bool = false) {
        return LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, loop);
      });

      set("playActorAnimation", function(obj:String, anim:String, force:Bool = false, reverse:Bool = false, ?frame:Int = 0) {
        var char:Character = LuaUtils.getObjectDirectly(obj);

        if (char != null && Std.isOfType(char, Character) && ClientPrefs.data.characters)
        { // what am I doing? of course it'll be a character
          char.playAnim(anim, force, reverse, frame);
          return;
        }
      });

      set("playAnim", function(obj:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0) {
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

      set("playAnimOld", function(obj:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0) {
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
          }

          var spr:FlxSprite = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
          if (spr != null)
          {
            if (spr.animation.getByName(name) != null)
            {
              if (Std.isOfType(spr, Character) && ClientPrefs.data.characters)
              {
                // convert spr to Character
                var obj:Dynamic = spr;
                var spr:Character = obj;
                spr.playAnim(name, forced, reverse, startFrame);
              }
              else
                spr.animation.play(name, forced, reverse, startFrame);
            }
            return true;
          }
          return false;
        }

        var spr:FlxSprite = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
        if (spr != null)
        {
          if (spr.animation.getByName(name) != null)
          {
            if (Std.isOfType(spr, Character) && ClientPrefs.data.characters)
            {
              // convert spr to Character
              var obj:Dynamic = spr;
              var spr:Character = obj;
              spr.playAnim(name, forced, reverse, startFrame);
            }
            else
              spr.animation.play(name, forced, reverse, startFrame);
          }
          return true;
        }
        return false;
      });

      set("addOffset", function(obj:String, anim:String, x:Float, y:Float) {
        var obj:Dynamic = LuaUtils.getObjectDirectly(obj);
        if (obj != null && obj.addOffset != null)
        {
          if (Std.isOfType(obj, ModchartSprite))
          {
            obj.animOffsets.set(anim, x, y);
          }

          if (Std.isOfType(obj, Character) || Std.isOfType(obj, HealthIcon))
          {
            obj.addOffset(anim, x, y);
          }
          return true;
        }
        return false;
      });

      set("setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
        if (LuaUtils.getObjectDirectly(obj) != null)
        {
          LuaUtils.getObjectDirectly(obj).scrollFactor.set(scrollX, scrollY);
          return;
        }

        var object:FlxObject = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
        if (object != null)
        {
          object.scrollFactor.set(scrollX, scrollY);
        }
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
          return true;
        }
        else
        {
          var mySprite:FlxSprite = MusicBeatState.getVariables().get(tag);

          if (mySprite == null) return false;

          var instance = LuaUtils.getTargetInstance();
          if (place == 2 || place == true) instance.add(mySprite);
          else
          {
            if (game == null || !game.isDead) instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterPlacement()), mySprite);
            else
              GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), mySprite);
          }
          return true;
        }
      });

      set("setGraphicSize", function(obj:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
        if (game.getLuaObject(obj) != null)
        {
          var shit:FlxSprite = game.getLuaObject(obj);
          shit.setGraphicSize(x, y);
          if (updateHitbox) shit.updateHitbox();
          return;
        }

        if (Stage.instance.swagBacks.exists(obj))
        {
          Stage.instance.setSwagGraphicSize(obj, x, updateHitbox);
          return;
        }

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
        if (LuaUtils.getObjectDirectly(obj) != null)
        {
          var shit:FlxSprite = LuaUtils.getObjectDirectly(obj);
          shit.scale.set(x, y);
          if (updateHitbox) shit.updateHitbox();
          return;
        }

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
        if (game.getLuaObject(obj) != null)
        {
          var shit:FlxSprite = game.getLuaObject(obj);
          shit.updateHitbox();
          return;
        }

        var poop:FlxSprite = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
        if (poop != null)
        {
          poop.updateHitbox();
          return;
        }
        luaTrace('updateHitbox: Couldnt find object: ' + obj, false, false, FlxColor.RED);
      });
      set("updateHitboxFromGroup", function(group:String, index:Int) {
        if (Std.isOfType(Reflect.getProperty(LuaUtils.getTargetInstance(), group), FlxTypedGroup))
        {
          Reflect.getProperty(LuaUtils.getTargetInstance(), group).members[index].updateHitbox();
          return;
        }
        Reflect.getProperty(LuaUtils.getTargetInstance(), group)[index].updateHitbox();
      });

      set("removeLuaSprite", function(tag:String, destroy:Bool = true, ?group:String = null) {
        var obj:FlxSprite = LuaUtils.getObjectDirectly(tag);
        var isStage:Bool = false;
        if (obj == null || obj.destroy == null)
        {
          if (Stage.instance.swagBacks.exists(tag))
          {
            obj = Stage.instance.swagBacks.get(tag);
            isStage = true;
            if (obj == null || obj.destroy == null)
            {
              isStage = false;
              return;
            }
          }
          else
            return;
        }

        var groupObj:Dynamic = null;
        if (group == null) groupObj = LuaUtils.getTargetInstance();
        else
          groupObj = LuaUtils.getObjectDirectly(group);

        groupObj.remove(obj, true);
        if (destroy)
        {
          isStage ? Stage.instance.swagBacks.remove(tag) : MusicBeatState.getVariables().remove(tag);
          obj.destroy();
        }
      });

      set("luaSpriteExists", function(tag:String) {
        var obj:FlxSprite = MusicBeatState.getVariables().get(tag);
        return (obj != null && Std.isOfType(obj, FlxSprite));
      });

      set("luaTextExists", function(tag:String) {
        var obj:FlxText = MusicBeatState.getVariables().get(tag);
        return (obj != null && Std.isOfType(obj, FlxText));
      });
      set("luaSoundExists", function(tag:String) {
        tag = LuaUtils.checkVariable(tag, 'sound_');
        var obj:FlxSound = MusicBeatState.getVariables().get(tag);
        return (obj != null && Std.isOfType(obj, FlxSound));
      });

      set("setHealthBarColors", function(left:String, right:String) {
        if (!ClientPrefs.data.healthColor) return;
        var left_color:Null<FlxColor> = null;
        var right_color:Null<FlxColor> = null;
        if (left != null && left != '') left_color = CoolUtil.colorFromString(left);
        if (right != null && right != '') right_color = CoolUtil.colorFromString(right);

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
        var left_color:Null<FlxColor> = null;
        var right_color:Null<FlxColor> = null;
        if (left != null && left != '') left_color = CoolUtil.colorFromString(left);
        if (right != null && right != '') right_color = CoolUtil.colorFromString(right);
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
        {
          game.timeBarNew.setColors(left_color, right_color);
        }
      });

      set("setPosition", function(obj:String, ?x:Float = null, ?y:Float = null) {
        var real = game.getLuaObject(obj);
        if (real != null)
        {
          if (x != null) real.x = x;
          if (y != null) real.y = y;
          return true;
        }

        var split:Array<String> = obj.split('.');
        var object:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (object != null)
        {
          if (x != null) object.x = x;
          if (y != null) object.y = y;
          return true;
        }
        luaTrace("setPosition: Couldnt find object " + obj, false, false, FlxColor.RED);
        return false;
      });

      // New Camera Code for finding custom Cameras, by LarryFrosty
      set("setObjectCamera", function(obj:String, camera:String = 'game') {
        var real = game.getLuaObject(obj);
        var realCamera:Dynamic = LuaUtils.getObjectDirectly(camera);
        if (realCamera == null || !Std.isOfType(realCamera, FlxCamera)) realCamera = LuaUtils.cameraFromString(camera);

        if (real != null)
        {
          real.cameras = [realCamera];
          return true;
        }

        if (Stage.instance.swagBacks.exists(obj)) // LET'S GOOOOO IT WORKSS!!!!!!
        {
          var real:FlxSprite = LuaUtils.changeSpriteClass(Stage.instance.swagBacks.get(obj));

          if (real != null)
          {
            real.cameras = [realCamera];
            return true;
          }
        }

        var split:Array<String> = obj.split('.');
        var object:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (object != null)
        {
          object.cameras = [realCamera];
          return true;
        }
        luaTrace("setObjectCamera: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
        return false;
      });
      set("setBlendMode", function(obj:String, blend:String = '') {
        var real = LuaUtils.getObjectDirectly(obj);
        if (real != null)
        {
          real.blend = LuaUtils.blendModeFromString(blend);
          return true;
        }

        var split:Array<String> = obj.split('.');
        var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (spr != null)
        {
          spr.blend = LuaUtils.blendModeFromString(blend);
          return true;
        }
        luaTrace("setBlendMode: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
        return false;
      });
      set("screenCenter", function(obj:String, pos:String = 'xy') {
        var spr:FlxObject = LuaUtils.getObjectDirectly(obj);

        if (spr == null)
        {
          var split:Array<String> = obj.split('.');
          spr = LuaUtils.getObjectDirectly(split[0]);
          if (split.length > 1)
          {
            spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
          }
        }

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
          var real = LuaUtils.getObjectDirectly(namesArray[i]);
          if (real != null)
          {
            objectsArray.push(real);
          }
          else
          {
            objectsArray.push(Reflect.getProperty(LuaUtils.getTargetInstance(), namesArray[i]));
          }
        }

        if (!objectsArray.contains(null) && FlxG.overlap(objectsArray[0], objectsArray[1]))
        {
          return true;
        }
        return false;
      });
      set("getPixelColor", function(obj:String, x:Int, y:Int) {
        var split:Array<String> = obj.split('.');
        var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (spr != null) return spr.pixels.getPixel32(x, y);
        return FlxColor.BLACK;
      });
      set("startDialogue", function(dialogueFile:String, music:String = null) {
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

      set("playMusic", function(sound:String, volume:Float = 1, loop:Bool = false) {
        FlxG.sound.playMusic(Paths.music(sound), volume, loop);
      });
      set("playSound", function(sound:String, volume:Float = 1, ?tag:String = null, ?loop:Bool = false) {
        if (tag != null && tag.length > 0)
        {
          var originalTag:String = tag;
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var variables = MusicBeatState.getVariables();
          var oldSnd = variables.get(tag);
          if (oldSnd != null)
          {
            oldSnd.stop();
            oldSnd.destroy();
          }
          variables.set(tag, FlxG.sound.play(Paths.sound(sound), volume, loop, null, true, function() {
            if (!loop) variables.remove(tag);
            if (game != null) game.callOnLuas('onSoundFinished', [originalTag]);
          }));
          return;
        }
        FlxG.sound.play(Paths.sound(sound), volume);
      });
      set("stopSound", function(tag:String) {
        if (tag == null || tag.length < 1) if (FlxG.sound.music != null) FlxG.sound.music.stop();
        else
        {
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var variables = MusicBeatState.getVariables();
          var snd:FlxSound = variables.get(tag);
          if (snd != null)
          {
            snd.stop();
            variables.remove(tag);
          }
        }
      });
      set("pauseSound", function(tag:String) {
        if (tag == null || tag.length < 1) if (FlxG.sound.music != null) FlxG.sound.music.pause();
        else
        {
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var snd:FlxSound = MusicBeatState.getVariables().get(tag);
          if (snd != null) snd.pause();
        }
      });
      set("resumeSound", function(tag:String) {
        if (tag == null || tag.length < 1) if (FlxG.sound.music != null) FlxG.sound.music.play();
        else
        {
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var snd:FlxSound = MusicBeatState.getVariables().get(tag);
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
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var snd:FlxSound = MusicBeatState.getVariables().get(tag);
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
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var snd:FlxSound = MusicBeatState.getVariables().get(tag);
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
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var snd:FlxSound = MusicBeatState.getVariables().get(tag);
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
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var snd:FlxSound = MusicBeatState.getVariables().get(tag);
          if (snd != null) return snd.volume;
        }
        return 0;
      });
      set("setSoundVolume", function(tag:String, value:Float) {
        if (tag == null || tag.length < 1)
        {
          tag = LuaUtils.checkVariable(tag, 'sound_');
          if (FlxG.sound.music != null)
          {
            FlxG.sound.music.volume = value;
            return;
          }
        }
        else
        {
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var snd:FlxSound = MusicBeatState.getVariables().get(tag);
          if (snd != null) snd.volume = value;
        }
      });
      set("getSoundTime", function(tag:String) {
        if (tag == null || tag.length < 1)
        {
          return FlxG.sound.music != null ? FlxG.sound.music.time : 0;
        }
        tag = LuaUtils.checkVariable(tag, 'sound_');
        var snd:FlxSound = MusicBeatState.getVariables().get(tag);
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
          tag = LuaUtils.checkVariable(tag, 'sound_');
          var snd:FlxSound = MusicBeatState.getVariables().get(tag);
          if (snd != null) snd.time = value;
        }
      });
      #if FLX_PITCH
      set("getSoundPitch", function(tag:String) {
        tag = LuaUtils.checkVariable(tag, 'sound_');
        var snd:FlxSound = MusicBeatState.getVariables().get(tag);
        return snd != null ? snd.pitch : 0;
      });
      set("setSoundPitch", function(tag:String, value:Float, doPause:Bool = false) {
        tag = LuaUtils.checkVariable(tag, 'sound_');
        var snd:FlxSound = MusicBeatState.getVariables().get(tag);
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
            var wasResumed:Bool = FlxG.sound.music.playing;
            if (doPause) FlxG.sound.music.pause();
            FlxG.sound.music.pitch = value;
            if (doPause && wasResumed) FlxG.sound.music.play();
            return;
          }
        }
        else
        {
          var snd:FlxSound = MusicBeatState.getVariables().get(tag);
          if (snd != null)
          {
            var wasResumed:Bool = snd.playing;
            if (doPause) snd.pause();
            snd.pitch = value;
            if (doPause && wasResumed) snd.play();
          }
        }
      });
      #end

      // mod settings
      #if MODS_ALLOWED
      addLocalCallback("getModSetting", function(saveTag:String, ?modName:String = null) {
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
      });
      #end
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

      set("startCharScripts", function(name:String) {
        game.startCharacterScripts(name);
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

    if (Type.typeof(data) == TFunction)
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
    var variables = MusicBeatState.getVariables();
    if (target != null)
    {
      if (tag != null)
      {
        var originalTag:String = tag;
        tag = LuaUtils.checkVariable(tag, 'tween_');
        variables.set(tag, FlxTween.tween(target, tweenValue, duration,
          {
            ease: LuaUtils.getTweenEaseByString(ease),
            onComplete: function(twn:FlxTween) {
              variables.remove(tag);
              if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag, vars]);
            }
          }));
      }
      else
        FlxTween.tween(target, tweenValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
    }
    else
      luaTrace('$funcName: Couldnt find object: $vars', false, false, FlxColor.RED);
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
    if (PlayState.instance == null) return;

    var strumNote:StrumArrow = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
    if (strumNote == null) return;

    if (tag != null)
    {
      var originalTag:String = tag;
      tag = LuaUtils.checkVariable(tag, 'tween_');
      LuaUtils.cancelTween(tag);

      var variables = MusicBeatState.getVariables();
      variables.set(tag, FlxTween.tween(strumNote, data, duration,
        {
          ease: LuaUtils.getTweenEaseByString(ease),
          onComplete: function(twn:FlxTween) {
            variables.remove(tag);
            if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag]);
          }
        }));
    }
    else
      FlxTween.tween(strumNote, data, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
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
    var cervix = scriptFile + ext;
    var doPush = false;
    #if MODS_ALLOWED
    if (FileSystem.exists(Paths.modFolders(cervix)))
    {
      cervix = Paths.modFolders(cervix);
      doPush = true;
    }
    else if (FileSystem.exists(cervix))
    {
      doPush = true;
    }
    else
    {
      cervix = Paths.getSharedPath(cervix);
      if (FileSystem.exists(cervix)) doPush = true;
    }
    #else
    cervix = Paths.getSharedPath(cervix);
    if (Assets.exists(cervix)) doPush = true;
    #end
    if (doPush) return cervix;
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

  public function initLuaShader(name:String, ?glslVersion:Int = 120)
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
