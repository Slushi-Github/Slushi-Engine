package psychlua;

import flixel.FlxBasic;
import flixel.util.FlxAxes;
import psychlua.LuaUtils;
#if LUA_ALLOWED
import psychlua.FunkinLua;
#end
#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;

class HScript extends Iris
{
  public var isHxStage:Bool = false;
  public var filePath:String;
  public var modFolder:String;
  public var returnValue:Dynamic = null;
  #if LUA_ALLOWED
  public var parentLua:FunkinLua;

  public static function initHaxeModule(parent:FunkinLua)
  {
    if (parent.hscript == null)
    {
      var times:Float = Date.now().getTime();
      Debug.logInfo('initialized Hscript interp successfully: ${parent.scriptName} (${Std.int(Date.now().getTime() - times)}ms)');
      parent.hscript = new HScript(parent);
    }
  }

  public function errorCaught(e:IrisError, ?funcName:String)
  {
    var header:String = (funcName != null ? '$origin: $funcName' : origin);
    #if LUA_ALLOWED
    FunkinLua.luaTrace('ERROR ($header) - ${e.toString()}', false, false, FlxColor.RED);
    #else
    hscriptTrace('ERROR ($header) - ${e.toString()}', FlxColor.RED);
    #end
  }

  public static function hscriptTrace(text:String, color:FlxColor = FlxColor.WHITE)
  {
    if (states.PlayState.instance != null) states.PlayState.instance.addTextToDebug(text, color);
    Debug.logInfo(text);
  }

  public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null, ?isHxStage:Bool = false)
  {
    var hs:HScript = try parent.hscript
    catch (e) null;
    if (hs == null)
    {
      trace('initializing haxe interp for: ${parent.scriptName}');
      parent.hscript = new HScript(parent, code, varsToBring, isHxStage);
      return parent.hscript.returnValue;
    }
    else
    {
      hs.varsToBring = varsToBring;
      var prevCode:String = hs.scriptCode;
      try
      {
        if (hs.scriptCode != code)
        {
          hs.scriptCode = code;
          hs.parse(true);
        }
        hs.returnValue = hs.execute();
        return hs.returnValue;
      }
      catch (e:IrisError)
      {
        hs.errorCaught(e);
        hs.returnValue = null;
        hs.scriptCode = prevCode;
        return e;
      }
    }
    return null;
  }
  #end

  public var origin:String;

  override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?isHxStage:Bool = false)
  {
    if (file == null) file = '';

    this.isHxStage = isHxStage;

    super(null, {name: "hscript-iris", autoRun: false, autoPreset: false});
    #if LUA_ALLOWED
    parentLua = parent;
    if (parent != null)
    {
      this.origin = parent.scriptName;
      this.modFolder = parent.modFolder;
    }
    #end
    filePath = file;
    if (filePath != null && filePath.length > 0 && parent == null)
    {
      this.origin = filePath;
      #if MODS_ALLOWED
      var myFolder:Array<String> = filePath.split('/');
      if (myFolder[0] + '/' == Paths.mods()
        && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) // is inside mods folder
        this.modFolder = myFolder[1];
      #end
    }
    var scriptThing:String = file;
    if (parent == null && file != null)
    {
      var f:String = file.replace('\\', '/');
      if (f.contains('/') && !f.contains('\n'))
      {
        scriptThing = File.getContent(f);
      }
    }
    preset();
    this.scriptCode = scriptThing;
    this.varsToBring = varsToBring;
    try
    {
      this.returnValue = execute();
    }
    catch (e:IrisError)
    {
      this.errorCaught(e);
      this.returnValue = null;
      this.returnValue = e;
    }
  }

  var varsToBring(default, set):Any = null;

  override function preset()
  {
    super.preset();

    set('Type', Type);
    set('Reflect', Reflect);
    #if sys
    set('File', sys.io.File);
    set('FileSystem', sys.FileSystem);
    #end

    // CLASSES (HAXE)
    set('Math', Math);
    set('Std', Std);
    set('Date', Date);

    // Some very commonly used classes
    set('FlxG', flixel.FlxG);
    set('FlxMath', flixel.math.FlxMath);
    set('FlxSprite', flixel.FlxSprite);
    set('FlxText', flixel.text.FlxText);
    set('FlxTextBorderStyle', FlxTextBorderStyle);
    #if (!flash && sys)
    set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
    #end
    set('FlxCamera', flixel.FlxCamera);
    set('FlxTimer', flixel.util.FlxTimer);
    set('FlxTween', flixel.tweens.FlxTween);
    set('FlxEase', flixel.tweens.FlxEase);
    set('FlxColor', psychlua.CustomFlxColor);
    set('FlxSound', flixel.sound.FlxSound);
    set('FlxState', flixel.FlxState);
    set('FlxSubState', flixel.FlxSubState);
    set('FlxTypedGroup', flixel.group.FlxGroup.FlxTypedGroup);
    set('FlxSpriteGroup', flixel.group.FlxSpriteGroup);
    set('FlxTypedSpriteGroup', flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup);
    set('FlxStringUtil', flixel.util.FlxStringUtil);
    set('FlxAtlasFrames', flixel.graphics.frames.FlxAtlasFrames);
    set('FlxSort', flixel.util.FlxSort);
    set('Application', lime.app.Application);
    set('FlxGraphic', flixel.graphics.FlxGraphic);
    set('File', sys.io.File);
    set('FlxTrail', flixel.addons.effects.FlxTrail);
    set('FlxShader', flixel.system.FlxAssets.FlxShader);
    set('FlxBar', flixel.ui.FlxBar);
    set('FlxBackdrop', flixel.addons.display.FlxBackdrop);
    set('StageSizeScaleMode', flixel.system.scaleModes.StageSizeScaleMode);
    set('GraphicsShader', openfl.display.GraphicsShader);
    set('ShaderFilter', openfl.filters.ShaderFilter);

    set('InputFormatter', backend.InputFormatter);

    set('PsychCamera', backend.PsychCamera);
    set('Countdown', backend.Countdown);
    set('PlayState', states.PlayState);
    set('Paths', backend.Paths);
    set('Conductor', backend.Conductor);
    set('ClientPrefs', backend.ClientPrefs);
    set('ColorSwap', shaders.ColorSwap);
    #if ACHIEVEMENTS_ALLOWED
    set('Achievements', backend.Achievements);
    #end
    #if DISCORD_ALLOWED
    set('Discord', backend.Discord.DiscordClient);
    #end
    set('Character', objects.Character);
    set('Alphabet', objects.Alphabet);
    set('Note', objects.note.Note);
    set('NoteSplash', objects.note.NoteSplash);
    set('StrumArrow', objects.note.StrumArrow);
    set('CustomSubstate', psychlua.CustomSubstate);
    set('ShaderFilter', openfl.filters.ShaderFilter);
    #if LUA_ALLOWED
    set('FunkinLua', psychlua.FunkinLua);
    #end
    set('Stage', backend.stage.Stage);
    #if flxanimate
    set('FlxAnimate', FlxAnimate);
    #end
    set('CustomFlxColor', psychlua.CustomFlxColor);

    set('BGSprite', objects.BGSprite);
    set('HealthIcon', objects.HealthIcon);
    set('MusicBeatState', states.MusicBeatState);
    set('MusicBeatSubState', substates.MusicBeatSubState);
    set('AttachedText', objects.AttachedText);

    // Functions & Variables
    set('setVar', function(name:String, value:Dynamic, ?type:String = "Custom") {
      MusicBeatState.getVariables(type).set(name, value);
    });
    set('getVar', function(name:String, ?type:String = "Custom") {
      var result:Dynamic = null;
      if (MusicBeatState.getVariables(type).exists(name)) result = MusicBeatState.getVariables(type).get(name);
      return result;
    });
    set('removeVar', function(name:String, ?type:String = "Custom") {
      if (MusicBeatState.getVariables(type).exists(name))
      {
        MusicBeatState.getVariables(type).remove(name);
        return true;
      }
      return false;
    });
    set('debugPrint', function(text:String, ?color:FlxColor = null) {
      if (color == null) color = FlxColor.WHITE;
      states.PlayState.instance.addTextToDebug(text, color);
    });

    set('getModSetting', function(saveTag:String, ?modName:String = null) {
      if (modName == null)
      {
        if (this.modFolder == null)
        {
          PlayState.instance.addTextToDebug('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', FlxColor.RED);
          return null;
        }
        modName = this.modFolder;
      }
      return psychlua.LuaUtils.getModSetting(saveTag, modName);
    });
    // Keyboard & Gamepads
    set('keyboardJustPressed', function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
    set('keyboardPressed', function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
    set('keyboardReleased', function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

    set('anyGamepadJustPressed', function(name:String) return FlxG.gamepads.anyJustPressed(name));
    set('anyGamepadPressed', function(name:String) FlxG.gamepads.anyPressed(name));
    set('anyGamepadReleased', function(name:String) return FlxG.gamepads.anyJustReleased(name));

    set('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return 0.0;

      return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
    });
    set('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return 0.0;

      return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
    });
    set('gamepadJustPressed', function(id:Int, name:String) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return false;

      return Reflect.getProperty(controller.justPressed, name) == true;
    });
    set('gamepadPressed', function(id:Int, name:String) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return false;

      return Reflect.getProperty(controller.pressed, name) == true;
    });
    set('gamepadReleased', function(id:Int, name:String) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return false;

      return Reflect.getProperty(controller.justReleased, name) == true;
    });

    set('keyJustPressed', function(name:String = '') {
      name = name.toLowerCase().trim();
      switch (name)
      {
        case 'left':
          return Controls.instance.NOTE_LEFT_P;
        case 'down':
          return Controls.instance.NOTE_DOWN_P;
        case 'up':
          return Controls.instance.NOTE_UP_P;
        case 'right':
          return Controls.instance.NOTE_RIGHT_P;
        default:
          return Controls.instance.justPressed(name);
      }
      return false;
    });
    set('keyPressed', function(name:String = '') {
      name = name.toLowerCase().trim();
      switch (name)
      {
        case 'left':
          return Controls.instance.NOTE_LEFT;
        case 'down':
          return Controls.instance.NOTE_DOWN;
        case 'up':
          return Controls.instance.NOTE_UP;
        case 'right':
          return Controls.instance.NOTE_RIGHT;
        default:
          return Controls.instance.pressed(name);
      }
      return false;
    });
    set('keyReleased', function(name:String = '') {
      name = name.toLowerCase().trim();
      switch (name)
      {
        case 'left':
          return Controls.instance.NOTE_LEFT_R;
        case 'down':
          return Controls.instance.NOTE_DOWN_R;
        case 'up':
          return Controls.instance.NOTE_UP_R;
        case 'right':
          return Controls.instance.NOTE_RIGHT_R;
        default:
          return Controls.instance.justReleased(name);
      }
      return false;
    });

    // For adding your own callbacks

    // not very tested but should work
    #if LUA_ALLOWED
    set('createGlobalCallback', function(name:String, func:Dynamic) {
      #if LUA_ALLOWED
      for (script in PlayState.instance.luaArray)
        if (script != null && script.lua != null && !script.closed) script.set(name, func);
      #end
      FunkinLua.customFunctions.set(name, func);
    });

    // tested
    set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null) {
      if (funk == null) funk = parentLua;

      if (funk != null) funk.addLocalCallback(name, func);
      else
        FunkinLua.luaTrace('createCallback ($name): 3rd argument is null', false, false, FlxColor.RED);
    });
    #end

    set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
      try
      {
        var str:String = '';
        if (libPackage.length > 0) str = libPackage + '.';

        set(libName, Type.resolveClass(str + libName));
      }
      catch (e:Dynamic)
      {
        var msg:String = e.message.substr(0, e.message.indexOf('\n'));
        #if LUA_ALLOWED
        if (parentLua != null)
        {
          FunkinLua.lastCalledScript = parentLua;
          FunkinLua.luaTrace('$origin: ${parentLua.lastCalledFunction} - $msg', false, false, FlxColor.RED);
          return;
        }
        #end
        if (PlayState.instance != null) states.PlayState.instance.addTextToDebug('$origin - $msg', FlxColor.RED);
        else
          Debug.logError('$origin - $msg');
      }
    });

    #if LUA_ALLOWED
    set('doLua', function(code:String = null, instance:String = 'PLAYSTATE', preloading:Bool = false, scriptName:String = 'unknown') {
      if (code != null) new FunkinLua(code, instance, preloading, scriptName);
    });
    #end
    set('CustomShader', codenameengine.shaders.CustomShader);
    set('StringTools', StringTools);
    #if LUA_ALLOWED
    set('parentLua', parentLua);
    #else
    set('parentLua', null);
    #end
    set('this', this);
    set('game', FlxG.state);
    set('controls', Controls.instance);
    set('stageManager', backend.stage.Stage.instance);
    set('buildTarget', psychlua.LuaUtils.getBuildTarget());
    set('customSubstate', psychlua.CustomSubstate.instance);
    set('customSubstateName', psychlua.CustomSubstate.name);
    set('StringTools', StringTools);
    set('Function_Stop', psychlua.LuaUtils.Function_Stop);
    set('Function_Continue', psychlua.LuaUtils.Function_Continue);
    set('Function_StopLua', psychlua.LuaUtils.Function_StopLua); // doesnt do much cuz HScript has a lower priority than Lua
    set('Function_StopHScript', psychlua.LuaUtils.Function_StopHScript);
    set('Function_StopAll', psychlua.LuaUtils.Function_StopAll);

    if (isHxStage)
    {
      Debug.logInfo('Limited usage of playstate properties inside the stage .lua\'s or .hx\'s!');
      set('hideLastBG', function(hid:Bool) {
        Stage.instance.hideLastBG = hid;
      });
      set('layerInFront', function(layer:Int = 0, id:Dynamic) Stage.instance.layInFront[layer].push(id));
      set('toAdd', function(id:Dynamic) Stage.instance.toAdd.push(id));
      set('setSwagBack', function(id:String, sprite:Dynamic) Stage.instance.swagBacks.set(id, sprite));
      set('getSwagBack', function(id:String) return Stage.instance.swagBacks.get(id));
      set('setSlowBacks', function(id:Dynamic, sprite:Array<FlxSprite>) Stage.instance.slowBacks.set(id, sprite));
      set('getSlowBacks', function(id:Dynamic) return Stage.instance.slowBacks.get(id));
      set('setSwagGroup', function(id:String, group:FlxTypedGroup<Dynamic>) Stage.instance.swagGroups.set(id, group));
      set('getSwagGroup', function(id:String) return Stage.instance.swagGroups.get(id));
      set('animatedBacks', function(id:FlxSprite) Stage.instance.animatedBacks.push(id));
      set('animatedBacks2', function(id:FlxSprite) Stage.instance.animatedBacks2.push(id));
      set('useSwagBack', function(id:String) return Stage.instance.swagBacks[id]);
    }

    set('add', FlxG.state.add);
    set('insert', FlxG.state.insert);
    set('remove', FlxG.state.remove);

    #if SCEModchartingTools
    set('ModchartEditorState', modcharting.ModchartEditorState);
    set('ModchartEvent', modcharting.ModchartEvent);
    set('ModchartEventManager', modcharting.ModchartEventManager);
    set('ModchartFile', modcharting.ModchartFile);
    set('ModchartFuncs', modcharting.ModchartFuncs);
    set('ModchartMusicBeatState', modcharting.ModchartMusicBeatState);
    set('ModchartUtil', modcharting.ModchartUtil);
    for (i in ['mod', 'Modifier'])
      set(i, modcharting.Modifier); // the game crashes without this???????? what??????????? -- fue glow
    set('ModifierSubValue', modcharting.Modifier.ModifierSubValue);
    set('ModTable', modcharting.ModTable);
    set('NoteMovement', modcharting.NoteMovement);
    set('NotePositionData', modcharting.NotePositionData);
    set('Playfield', modcharting.Playfield);
    set('PlayfieldRenderer', modcharting.PlayfieldRenderer);
    set('SimpleQuaternion', modcharting.SimpleQuaternion);
    set('SustainStrip', modcharting.SustainStrip);

    // Why?
    if (PlayState.instance != null
      && PlayState.SONG != null
      && !isHxStage
      && PlayState.SONG.options.notITG
      && ClientPrefs.getGameplaySetting('modchart')) modcharting.ModchartFuncs.loadHScriptFunctions(this);
    #end
    set('setAxes', function(axes:String) return FlxAxes.fromString(axes));

    if (states.PlayState.instance == FlxG.state)
    {
      #if (HSCRIPT_ALLOWED && HScriptImproved)
      set('doHSI', function(path:String) {
        states.PlayState.instance.addScript(path, CODENAME);
      });
      #end
      set('addBehindGF', states.PlayState.instance.addBehindGF);
      set('addBehindDad', states.PlayState.instance.addBehindDad);
      set('addBehindBF', states.PlayState.instance.addBehindBF);
    }

    set("playDadSing", true);
    set("playBFSing", true);

    set('setVarFromClass', function(instance:String, variable:String, value:Dynamic) {
      Reflect.setProperty(Type.resolveClass(instance), variable, value);
    });

    set('getVarFromClass', function(instance:String, variable:String) {
      Reflect.getProperty(Type.resolveClass(instance), variable);
    });

    FlxG.signals.focusGained.add(function() {
      executeFunction("focusGained", []);
    });
    FlxG.signals.focusLost.add(function() {
      executeFunction("focusLost", []);
    });
    FlxG.signals.gameResized.add(function(w:Int, h:Int) {
      executeFunction("gameResized", [w, h]);
    });
    FlxG.signals.postDraw.add(function() {
      executeFunction("postDraw", []);
    });
    FlxG.signals.postGameReset.add(function() {
      executeFunction("postGameReset", []);
    });
    FlxG.signals.postGameStart.add(function() {
      executeFunction("postGameStart", []);
    });
    FlxG.signals.postStateSwitch.add(function() {
      executeFunction("postStateSwitch", []);
    });

    set('parseJson', function(directory:String, ?ignoreMods:Bool = false):{} {
      var parseJson:{} = {};
      final funnyPath:String = directory + '.json';
      final jsonContents:String = Paths.getTextFromFile(funnyPath, ignoreMods);
      final realPath:String = (ignoreMods ? '' : Paths.modFolders(Mods.currentModDirectory)) + '/' + funnyPath;
      final jsonExists:Bool = Paths.fileExists(realPath, null, ignoreMods);
      if (jsonContents != null || jsonExists) parseJson = haxe.Json.parse(jsonContents);
      else if (!jsonExists && PlayState.chartingMode)
      {
        parseJson = {};
        if (states.PlayState.instance != null && states.PlayState.instance == FlxG.state)
        {
          states.PlayState.instance.addTextToDebug('parseJson: "' + realPath + '" doesn\'t exist!', 0xff0000, 6);
        }
      }
      return parseJson;
    });

    set('sys', #if sys true #else false #end);
  }

  // I hate the CALLS CANT THEY BE STATIC FOR ONCE!?
  public function executeCode(?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):IrisCall
  {
    if (funcToRun == null) return null;
    if (!exists(funcToRun))
    {
      #if LUA_ALLOWED
      FunkinLua.luaTrace(origin + ' - No function named: $funcToRun', false, false, FlxColor.RED);
      #else
      hscriptTrace(origin + ' - No function named: $funcToRun', FlxColor.RED);
      #end
      return null;
    }
    try
    {
      return call(funcToRun, funcArgs);
    }
    catch (e:IrisError)
    {
      errorCaught(e, funcToRun);
    }
    return null;
  }

  public function executeFunction(funcToRun:String = null, funcArgs:Array<Dynamic> = null):IrisCall
  {
    if (funcToRun == null || !exists(funcToRun)) return null;
    return call(funcToRun, funcArgs);
  }

  #if LUA_ALLOWED
  public static function implement(funk:FunkinLua)
  {
    funk.addLocalCallback("runHaxeCode",
      function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
        #if HSCRIPT_ALLOWED
        final retVal:Dynamic = initHaxeModuleCode(funk, codeToRun, varsToBring);
        if (Std.isOfType(retVal, IrisError)) return null;
        if (funcToRun == null)
        {
          return (LuaUtils.typeSupported(retVal)) ? retVal : null;
        }
        try
        {
          final retCall:IrisCall = funk.hscript.executeCode(funcToRun, funcArgs);
          if (retCall != null)
          {
            return (LuaUtils.typeSupported(retCall.returnValue)) ? retCall.returnValue : null;
          }
        }
        catch (e:Dynamic)
        {
          funk.hscript.errorCaught(e, funcToRun);
        }
        #else
        FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
        #end
        return null;
      });

    funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
      #if HSCRIPT_ALLOWED
      try
      {
        final retVal:IrisCall = funk.hscript.executeFunction(funcToRun, funcArgs);
        if (retVal != null) return (LuaUtils.typeSupported(retVal.returnValue)) ? retVal.returnValue : null;
      }
      catch (e:Dynamic)
      {
        funk.hscript.errorCaught(e, funcToRun);
      }
      return null;
      #else
      FunkinLua.luaTrace("runHaxeFunction: HScript isn't supported on this platform!", false, false, FlxColor.RED);
      return null;
      #end
    });
    // This function is unnecessary because import already exists in HScript as a native feature
    funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
      var str:String = '';
      if (libPackage.length > 0) str = libPackage + '.';
      else if (libName == null) libName = '';

      var c:Dynamic = Type.resolveClass(str + libName);
      if (c == null) c = Type.resolveEnum(str + libName);

      #if HSCRIPT_ALLOWED
      if (funk.hscript != null)
      {
        try
        {
          if (c != null) funk.hscript.set(libName, c);
        }
        catch (e:Dynamic)
        {
          FunkinLua.luaTrace(funk.hscript.origin + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
        }
      }
      FunkinLua.luaTrace("addHaxeLibrary is deprecated! Import classes through \"import\" in HScript!", false, true);
      #else
      FunkinLua.luaTrace(funk.hscript.origin + ": addHaxeLibrary: HScript isn't supported on this platform!", false, false, FlxColor.RED);
      #end
    });
  }
  #end

  override public function set(name:String, value:Dynamic, allowOverride:Bool = false):Void
  {
    // should always override by default
    super.set(name, value, true);
  }

  /*override function irisPrint(v):Void
    {
      FunkinLua.luaTrace('ERROR (${this.origin}:${interp.posInfos().lineNumber}): ${v}');
      Debug.logInfo('[${ruleSet.name}:${interp.posInfos().lineNumber}]: ${v}\n');
  }*/
  override public function destroy()
  {
    origin = null;
    #if LUA_ALLOWED parentLua = null; #end

    super.destroy();
  }

  #if SCEModchartingTools
  public inline function initMod(mod:modcharting.Modifier)
  {
    executeFunction("initMod", [mod]);
  }
  #end

  function set_varsToBring(values:Any)
  {
    if (varsToBring != null) for (key in Reflect.fields(varsToBring))
      if (exists(key.trim())) interp.variables.remove(key.trim());

    if (values != null)
    {
      for (key in Reflect.fields(values))
      {
        key = key.trim();
        set(key, Reflect.field(values, key));
      }
    }

    return varsToBring = values;
  }
}
#end
