package scripting;

import scripting.base.HScriptSC;

class SCScript extends flixel.FlxBasic
{
  public static function presetVariables():#if haxe3 Map<String, Dynamic> #else Hash<Dynamic> #end
  {
    return [
      // Haxe related stuff
      "Std" => Std,
      "Math" => Math,
      "Reflect" => Reflect,
      "StringTools" => StringTools,
      "Json" => haxe.Json,

      // OpenFL & Lime related stuff
      "Assets" => openfl.utils.Assets,
      "Application" => lime.app.Application,
      "GraphicsShader" => openfl.display.GraphicsShader,
      "Main" => Main,
      "ShaderFilter" => openfl.filters.ShaderFilter,
      "window" => lime.app.Application.current.window,

      // Flixel related stuff
      "FlxG" => flixel.FlxG,
      "FlxSprite" => flixel.FlxSprite,
      "FlxBasic" => flixel.FlxBasic,
      "FlxCamera" => flixel.FlxCamera,
      "state" => flixel.FlxG.state,
      "FlxEase" => flixel.tweens.FlxEase,
      "FlxTween" => flixel.tweens.FlxTween,
      "FlxSound" => flixel.sound.FlxSound,
      "FlxAssets" => flixel.system.FlxAssets,
      "FlxMath" => flixel.math.FlxMath,
      "FlxGroup" => flixel.group.FlxGroup,
      "FlxTypedGroup" => flixel.group.FlxGroup.FlxTypedGroup,
      "FlxSpriteGroup" => flixel.group.FlxSpriteGroup,
      "FlxTypeText" => flixel.addons.text.FlxTypeText,
      "FlxText" => flixel.text.FlxText,
      "FlxTimer" => flixel.util.FlxTimer,
      "FlxPoint" => CoolUtil.getMacroAbstractClass("flixel.math.FlxPoint"),
      "FlxAxes" => CoolUtil.getMacroAbstractClass("flixel.util.FlxAxes"),
      "FlxColor" => CoolUtil.getMacroAbstractClass("flixel.util.FlxColor"),

      // Flixel-addons related stuff
      #if (sys && !flash)
      "FlxRuntimeShader" => flixel.addons.display.FlxRuntimeShader,
      #end

      // Engine related suff + Folder they are located in.
      // Backend
      #if ACHIEVEMENTS_ALLOWED
      "Achievements" => backend.Achievements,
      #end
      "Conductor" => backend.Conductor,
      "ClientPrefs" => backend.ClientPrefs,
      "CoolUtil" => backend.CoolUtil,
      #if DISCORD_ALLOWED
      "Discord" => backend.Discord.DiscordClient,
      #end
      "Language" => backend.Language,
      "Mods" => backend.Mods,
      "Paths" => backend.Paths,
      "PsychCamera" => backend.PsychCamera,
      // CodenameEngine
      // -->Shaders
      "FunkinShader" => codenameengine.shaders.FunkinShader,
      "CustomShader" => codenameengine.shaders.CustomShader,
      // Cutscenes
      "CutsceneHandler" => cutscenes.CutsceneHandler,
      "DialogueBox" => cutscenes.DialogueBox,
      "DialogueBoxPsych" => cutscenes.DialogueBoxPsych,
      // Input
      "Controls" => input.Controls,
      // Objects
      "Alphabet" => objects.Alphabet,
      "AttachedSprite" => objects.AttachedSprite,
      "AttachedText" => objects.AttachedText,
      "Boyfriend" => objects.Character, // for compatibility
      "BGSprite" => objects.BGSprite,
      "Character" => objects.Character,
      #if flxanimate "FlxAnimate" => FlxAnimate, #end
      "FunkinSCSprite" => FunkinSCSprite,
      "HealthIcon" => objects.HealthIcon,
      "Note" => objects.note.Note,
      "StrumArrow" => objects.note.StrumArrow,
      // --> stagecontent
      "Stage" => backend.stage.Stage,
      // Options
      "Options" => options.OptionsState,
      "ModSettingsSubState" => options.ModSettingsSubState,
      // PsychLua
      "CustomFlxColor" => psychlua.CustomFlxColor,
      #if LUA_ALLOWED
      "FunkinLua" => psychlua.FunkinLua,
      #end
      // Shaders
      "ColorSwap" => shaders.ColorSwap,
      // States
      "FreeplayState" => states.freeplay.FreeplayState,
      "MainMenuState" => states.MainMenuState,
      "PlayState" => states.PlayState,
      "StoryMenuState" => states.StoryMenuState,
      "TitleState" => states.TitleState,
      // SubStates
      "GameOverSubstate" => substates.GameOverSubstate,
      "PauseSubState" => slushi.substates.SlushiPauseSubState,

      // External Usages For Engine
      "Countdown" => backend.Countdown,
      "HenchmenKillState" => backend.stage.HenchmenKillState
    ];
  }

  public var hsCode:HScriptSC;

  public function new()
  {
    super();
  }

  public function loadScript(path:String)
  {
    hsCode = new HScriptSC(path);
    presetScript();
  }

  public function callFunc(func:String, ?args:Array<Dynamic>):SCCall
  {
    if (hsCode == null || !active || !exists) return null;
    if (args == null) args = [];
    return hsCode.call(func, args);
  }

  public function executeFunc(func:String = null, args:Array<Dynamic> = null):SCCall
  {
    if (hsCode == null || !active || !exists) return null;
    return hsCode.call(func, args);
  }

  public function setVar(key:String, value:Dynamic):Void
  {
    if (hsCode == null || !active || !exists) return;
    hsCode.set(key, value, false);
  }

  public function getVar(key:String):Dynamic
  {
    if (hsCode == null || !active || !exists) return false;
    return hsCode.get(key);
  }

  public function existsVar(key:String):Bool
  {
    if (hsCode == null || !active || !exists) return false;
    return hsCode.exists(key);
  }

  public function presetScript()
  {
    if (hsCode == null || !active || !exists) return;

    for (k => e in presetVariables())
      setVar(k, e);

    setVar("disableScript", () -> {
      active = false;
    });
    setVar("__script__", this);

    setVar("playDadSing", true);
    setVar("playBFSing", true);

    // Functions & Variables
    setVar('setVar', function(name:String, value:Dynamic, ?type:String = "Custom") {
      MusicBeatState.getVariables(type).set(name, psychlua.ReflectionFunctions.parseSingleInstance(value));
    });
    setVar('getVar', function(name:String, ?type:String = "Custom") {
      var result:Dynamic = null;
      if (MusicBeatState.getVariables(type).exists(name)) result = MusicBeatState.getVariables(type).get(name);
      return result;
    });
    setVar('removeVar', function(name:String, ?type:String = "Custom") {
      if (MusicBeatState.getVariables(type).exists(name))
      {
        MusicBeatState.getVariables(type).remove(name);
        return true;
      }
      return false;
    });
    setVar('debugPrint', function(text:String, ?color:FlxColor = null) {
      if (color == null) color = FlxColor.WHITE;
      if (states.PlayState.instance == FlxG.state) states.PlayState.instance.addTextToDebug(text, color);
      else
        Debug.logInfo(text);
    });
    setVar('getModSetting', function(saveTag:String, ?modName:String = null) {
      if (modName == null)
      {
        if (hsCode.modFolder == null)
        {
          PlayState.instance.addTextToDebug('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', FlxColor.RED);
          return null;
        }
        modName = hsCode.modFolder;
      }
      return psychlua.LuaUtils.getModSetting(saveTag, modName);
    });

    // Keyboard & Gamepads
    setVar('keyboardJustPressed', function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
    setVar('keyboardPressed', function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
    setVar('keyboardReleased', function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

    setVar('anyGamepadJustPressed', function(name:String) return FlxG.gamepads.anyJustPressed(name));
    setVar('anyGamepadPressed', function(name:String) FlxG.gamepads.anyPressed(name));
    setVar('anyGamepadReleased', function(name:String) return FlxG.gamepads.anyJustReleased(name));

    setVar('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return 0.0;

      return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
    });
    setVar('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return 0.0;

      return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
    });
    setVar('gamepadJustPressed', function(id:Int, name:String) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return false;

      return Reflect.getProperty(controller.justPressed, name) == true;
    });
    setVar('gamepadPressed', function(id:Int, name:String) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return false;

      return Reflect.getProperty(controller.pressed, name) == true;
    });
    setVar('gamepadReleased', function(id:Int, name:String) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null) return false;

      return Reflect.getProperty(controller.justReleased, name) == true;
    });

    setVar('keyJustPressed', function(name:String = '') {
      name = name.toLowerCase();
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
    setVar('keyPressed', function(name:String = '') {
      name = name.toLowerCase();
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
    setVar('keyReleased', function(name:String = '') {
      name = name.toLowerCase();
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

    #if LUA_ALLOWED
    setVar('doLua', function(code:String = null, instance:String = "PLAYSTATE", preloading:Bool = false, scriptName:String = 'unknown') {
      if (code != null) new psychlua.FunkinLua(code, instance, preloading, scriptName);
    });
    #end

    setVar('buildTarget', psychlua.LuaUtils.getBuildTarget());
    setVar('customSubstate', psychlua.CustomSubstate.instance);
    setVar('customSubstateName', psychlua.CustomSubstate.name);
    setVar('Function_Stop', psychlua.LuaUtils.Function_Stop);
    setVar('Function_Continue', psychlua.LuaUtils.Function_Continue);
    setVar('Function_StopLua', psychlua.LuaUtils.Function_StopLua); // doesnt do much cuz HScript has a lower priority than Lua
    setVar('Function_StopHScript', psychlua.LuaUtils.Function_StopHScript);
    setVar('Function_StopAll', psychlua.LuaUtils.Function_StopAll);

    setVar('add', FlxG.state.add);
    setVar('insert', FlxG.state.insert);
    setVar('remove', FlxG.state.remove);

    #if SCEModchartingTools
    setVar('ModchartEditorState', modcharting.ModchartEditorState);
    setVar('ModchartEvent', modcharting.ModchartEvent);
    setVar('ModchartEventManager', modcharting.ModchartEventManager);
    setVar('ModchartFile', modcharting.ModchartFile);
    setVar('ModchartFuncs', modcharting.ModchartFuncs);
    setVar('ModchartMusicBeatState', modcharting.ModchartMusicBeatState);
    setVar('ModchartUtil', modcharting.ModchartUtil);
    for (i in ['mod', 'Modifier'])
      setVar(i, modcharting.Modifier); // the game crashes without this???????? what??????????? -- fue glow
    setVar('ModifierSubValue', modcharting.Modifier.ModifierSubValue);
    setVar('ModTable', modcharting.ModTable);
    setVar('NoteMovement', modcharting.NoteMovement);
    setVar('NotePositionData', modcharting.NotePositionData);
    setVar('Playfield', modcharting.Playfield);
    setVar('PlayfieldRenderer', modcharting.PlayfieldRenderer);
    setVar('SimpleQuaternion', modcharting.SimpleQuaternion);
    setVar('SustainStrip', modcharting.SustainStrip);

    // Why?
    if (states.PlayState.instance != null
      && states.PlayState.SONG.options != null
      && states.PlayState.SONG.options.notITG
      && ClientPrefs.getGameplaySetting('modchart')) modcharting.ModchartFuncs.loadHScriptFunctions(this);
    #end
    setVar('setAxes', function(axes:String) return flixel.util.FlxAxes.fromString(axes));

    if (states.PlayState.instance == FlxG.state)
    {
      setVar('addBehindGF', states.PlayState.instance.addBehindGF);
      setVar('addBehindDad', states.PlayState.instance.addBehindDad);
      setVar('addBehindBF', states.PlayState.instance.addBehindBF);
    }

    setVar('setVarFromClass', function(instance:String, variable:String, value:Dynamic) {
      Reflect.setProperty(Type.resolveClass(instance), variable, value);
    });

    setVar('getVarFromClass', function(instance:String, variable:String) {
      Reflect.getProperty(Type.resolveClass(instance), variable);
    });

    setVar('parseJson', function(directory:String, ?ignoreMods:Bool = false):{} {
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
  }

  override public function destroy()
  {
    hsCode.destroy();
    super.destroy();
  }
}
