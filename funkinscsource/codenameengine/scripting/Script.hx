package codenameengine.scripting;

import lime.app.Application;
import haxe.io.Path;
import _hscript.IHScriptCustomConstructor;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.FlxBasic;

/**
 * Class used for scripting.
 */
@:allow(codenameengine.scripting.ScriptPack)
class Script extends FlxBasic implements IFlxDestroyable
{
  /**
   * Use "static var thing = true;" in hscript to use those!!
   * are reset every mod switch so once you're done with them make sure to make them null!!
   */
  public static var staticVariables:Map<String, Dynamic> = [];

  public static function getDefaultVariables(?script:Script):Map<String, Dynamic>
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
      "FreeplayState" => slushi.states.freeplay.SlushiFreeplayState,
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

  /**
   * Currently executing script.
   */
  public static var curScript:Script = null;

  /**
   * Script name (with extension)
   */
  public var fileName:String;

  /**
   * Script Extension
   */
  public var extension:String;

  /**
   * Path to the script.
   */
  public var path:String = null;

  private var rawPath:String = null;

  private var didLoad:Bool = false;

  public var remappedNames:Map<String, String> = [];

  /**
   * Creates a script from the specified asset path. The language is automatically determined.
   * @param path Path in assets
   */
  public static function create(path:String):Script
  {
    if (FileSystem.exists(path))
    {
      return switch (Path.extension(path).toLowerCase())
      {
        case "hx" | "hscript" | "hsc" | "hxs":
          new HScript(path);
        default:
          new DummyScript(path);
      }
    }
    return new DummyScript(path);
  }

  /**
   * Creates a script from the string. The language is determined based on the path.
   * @param code code
   * @param path filename
   */
  public static function fromString(code:String, path:String):Script
  {
    return switch (Path.extension(path).toLowerCase())
    {
      case "hx" | "hscript" | "hsc" | "hxs":
        new HScript(path).loadFromString(code);
      default:
        new DummyScript(path).loadFromString(code);
    }
  }

  public var modFolder:String;

  /**
   * Creates a new instance of the script class.
   * @param path
   */
  public function new(path:String)
  {
    super();

    rawPath = path;
    path = Paths.getPath(path);
    fileName = Path.withoutDirectory(path);
    extension = Path.extension(path);
    this.path = path;
    onCreate(path);
    #if MODS_ALLOWED
    var myFolder:Array<String> = path.split('/');
    if (myFolder[0] + '/' == Paths.mods()
      && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) // is inside mods folder
      this.modFolder = myFolder[1];
    #end
    for (k => e in getDefaultVariables(this))
    {
      set(k, e);
    }
    set("disableScript", () -> {
      active = false;
    });
    set("__script__", this);

    set("playDadSing", true);
    set("playBFSing", true);

    // Functions & Variables
    set('setVar', function(name:String, value:Dynamic, ?type:String = "Custom") {
      MusicBeatState.getVariables(type).set(name, psychlua.ReflectionFunctions.parseSingleInstance(value));
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
      if (states.PlayState.instance == FlxG.state) states.PlayState.instance.addTextToDebug(text, color);
      else
        Debug.logInfo(text);
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
    set('keyPressed', function(name:String = '') {
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
    set('keyReleased', function(name:String = '') {
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
    set('doLua', function(code:String = null, instance:String = "PLAYSTATE", preloading:Bool = false, scriptName:String = 'unknown') {
      if (code != null) new psychlua.FunkinLua(code, instance, preloading, scriptName);
    });
    #end

    set('buildTarget', psychlua.LuaUtils.getBuildTarget());
    set('customSubstate', psychlua.CustomSubstate.instance);
    set('customSubstateName', psychlua.CustomSubstate.name);
    set('Function_Stop', psychlua.LuaUtils.Function_Stop);
    set('Function_Continue', psychlua.LuaUtils.Function_Continue);
    set('Function_StopLua', psychlua.LuaUtils.Function_StopLua); // doesnt do much cuz HScript has a lower priority than Lua
    set('Function_StopHScript', psychlua.LuaUtils.Function_StopHScript);
    set('Function_StopAll', psychlua.LuaUtils.Function_StopAll);

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
    if (states.PlayState.instance != null
      && states.PlayState.SONG.options != null
      && states.PlayState.SONG.options.notITG
      && ClientPrefs.getGameplaySetting('modchart')) modcharting.ModchartFuncs.loadHScriptFunctions(this);
    #end
    set('setAxes', function(axes:String) return flixel.util.FlxAxes.fromString(axes));

    if (states.PlayState.instance == FlxG.state)
    {
      set('addBehindGF', states.PlayState.instance.addBehindGF);
      set('addBehindDad', states.PlayState.instance.addBehindDad);
      set('addBehindBF', states.PlayState.instance.addBehindBF);
    }

    set('setVarFromClass', function(instance:String, variable:String, value:Dynamic) {
      Reflect.setProperty(Type.resolveClass(instance), variable, value);
    });

    set('getVarFromClass', function(instance:String, variable:String) {
      Reflect.getProperty(Type.resolveClass(instance), variable);
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
  }

  #if SCEModchartingTools
  public inline function initMod(mod:modcharting.Modifier)
  {
    call("initMod", [mod]);
  }
  #end

  /**
   * Loads the script
   */
  public function load()
  {
    if (didLoad) return;

    var oldScript = curScript;
    curScript = this;
    onLoad();
    curScript = oldScript;

    didLoad = true;
  }

  /**
   * HSCRIPT ONLY FOR NOW
   * Sets the "public" variables map for ScriptPack
   */
  public function setPublicMap(map:Map<String, Dynamic>) {}

  /**
   * Hot-reloads the script, if possible
   */
  public function reload() {}

  /**
   * Traces something as this script.
   */
  public function trace(v:Dynamic)
  {
    Debug.logInfo('${fileName}: ' + Std.string(v));
  }

  /**
   * Calls the function `func` defined in the script.
   * @param func Name of the function
   * @param parameters (Optional) Parameters of the function.
   * @return Result (if void, then null)
   */
  public function call(func:String, ?parameters:Array<Dynamic>):Dynamic
  {
    var oldScript = curScript;
    curScript = this;

    var result = onCall(func, parameters == null ? [] : parameters);

    curScript = oldScript;
    return result;
  }

  /**
   * Loads the code from a string, doesnt really work after the script has been loaded
   * @param code The code.
   */
  public function loadFromString(code:String)
  {
    return this;
  }

  /**
   * Sets a script's parent object so that its properties can be accessed easily. Ex: Passing `PlayState.instance` will allow `boyfriend` to be typed instead of `PlayState.instance.boyfriend`.
   * @param variable Parent variable.
   */
  public function setParent(variable:Dynamic) {}

  /**
   * Gets the variable `variable` from the script's variables.
   * @param variable Name of the variable.
   * @return Variable (or null if it doesn't exists)
   */
  public function get(variable:String):Dynamic
  {
    return null;
  }

  /**
   * Gets the variable `variable` from the script's variables.
   * @param variable Name of the variable.
   * @return Variable (or null if it doesn't exists)
   */
  public function set(variable:String, value:Dynamic):Void {}

  /**
   * Shows an error from this script.
   * @param text Text of the error (ex: Null Object Reference).
   * @param additionalInfo Additional information you could provide.
   */
  public function error(text:String, ?additionalInfo:Dynamic):Void
  {
    Debug.logError(fileName);
    Debug.logError(text);
  }

  override public function toString():String
  {
    return FlxStringUtil.getDebugString(didLoad ? [LabelValuePair.weak("path", path), LabelValuePair.weak("active", active),] : [
      LabelValuePair.weak("path", path),
      LabelValuePair.weak("active", active),
      LabelValuePair.weak("loaded", didLoad),
    ]);
  }

  /**
   * PRIVATE HANDLERS - DO NOT TOUCH
   */
  private function onCall(func:String = null, parameters:Array<Dynamic> = null):Dynamic
    return null;

  public function onCreate(path:String) {}

  public function onLoad() {}
}
