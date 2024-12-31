package psychlua;

import flixel.FlxBasic;
import flixel.addons.display.FlxBackdrop;
import backend.WeekData;
import backend.CharacterOffsets;
import objects.HealthIcon;
import objects.Character;
import Type.ValueType;
import openfl.display.BlendMode;
import substates.GameOverSubstate;
#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

typedef LuaTweenOptions =
{
  type:FlxTweenType,
  startDelay:Float,
  onUpdate:Null<String>,
  onStart:Null<String>,
  onComplete:Null<String>,
  loopDelay:Float,
  ease:EaseFunction
}

enum abstract AffixType(String) from String to String
{
  var NONE = 'None';
  var SUFFIXED = 'Suffixed';
  var PREFIXED = 'Prefixed';
  var CIRCUMFIXED = 'Circumfixed';
  var FORMATTED_SUFFIX = 'Formatted Suffix';
  var FORMATTED_PREFIX = 'Formatted Prefix';
  var FORMATTED_CIRCUMFIX = 'Formatted Circumfix';
}

class LuaUtils
{
  public static final Function_Stop:String = "##PSYCHLUA_FUNCTIONSTOP";
  public static final Function_Continue:String = "##PSYCHLUA_FUNCTIONCONTINUE";
  public static final Function_StopLua:String = "##PSYCHLUA_FUNCTIONSTOPLUA";
  public static final Function_StopHScript:String = "##PSYCHLUA_FUNCTIONSTOPHSCRIPT";
  public static final Function_StopAll:String = "##PSYCHLUA_FUNCTIONSTOPALL";

  public static function getLuaTween(options:Dynamic)
  {
    return (options != null) ?
      {
        type: getTweenTypeByString(options.type),
        startDelay: options.startDelay,
        onUpdate: options.onUpdate,
        onStart: options.onStart,
        onComplete: options.onComplete,
        loopDelay: options.loopDelay,
        ease: getTweenEaseByString(options.ease)
      } : null;
  }

  public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic, allowMaps:Bool = false):Any
  {
    var splitProps:Array<String> = variable.split('[');
    if (splitProps.length > 1)
    {
      var target:Dynamic = null;
      if (MusicBeatState.findVariableObj(splitProps[0]))
      {
        var retVal:Dynamic = MusicBeatState.variableMap(splitProps[0]).get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else if (PlayState.instance.stage.swagBacks.exists(splitProps[0]))
      {
        var retVal:Dynamic = PlayState.instance.stage.swagBacks.get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else if (PlayState.instance.stage.swagGroups.exists(splitProps[0]))
      {
        var retVal:Dynamic = PlayState.instance.stage.swagGroups.get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else if (Stage.instance.swagBacks.exists(splitProps[0]))
      {
        var retVal:Dynamic = Stage.instance.swagBacks.get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else if (Stage.instance.swagGroups.exists(splitProps[0]))
      {
        var retVal:Dynamic = Stage.instance.swagGroups.get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else
        target = Reflect.getProperty(instance, splitProps[0]);

      for (i in 1...splitProps.length)
      {
        var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
        if (i >= splitProps.length - 1) // Last array
          target[j] = value;
        else // Anything else
          target = target[j];
      }
      return target;
    }

    if (allowMaps && isMap(instance))
    {
      instance.set(variable, value);
      return value;
    }

    if (MusicBeatState.findVariableObj(variable))
    {
      MusicBeatState.variableMap(variable).set(variable, value);
      return value;
    }
    else if (PlayState.instance.stage.swagBacks.exists(variable))
    {
      PlayState.instance.stage.setPropertyObject(variable, value);
      return value;
    }
    else if (PlayState.instance.stage.swagGroups.exists(variable))
    {
      PlayState.instance.stage.swagGroups.set(variable, value);
      return value;
    }
    else if (Stage.instance.swagBacks.exists(variable))
    {
      Stage.instance.setPropertyObject(variable, value);
      return value;
    }
    else if (Stage.instance.swagGroups.exists(variable))
    {
      Stage.instance.swagGroups.set(variable, value);
      return value;
    }

    Reflect.setProperty(instance, variable, value);
    return value;
  }

  public static function getVarInArray(instance:Dynamic, variable:String, allowMaps:Bool = false):Any
  {
    var splitProps:Array<String> = variable.split('[');
    if (splitProps.length > 1)
    {
      var target:Dynamic = null;
      if (MusicBeatState.findVariableObj(splitProps[0]))
      {
        var retVal:Dynamic = MusicBeatState.variableMap(variable).get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else if (PlayState.instance.stage.swagBacks.exists(splitProps[0]))
      {
        var retVal:Dynamic = PlayState.instance.stage.swagBacks.get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else if (PlayState.instance.stage.swagGroups.exists(splitProps[0]))
      {
        var retVal:Dynamic = PlayState.instance.stage.swagGroups.get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else if (Stage.instance.swagBacks.exists(splitProps[0]))
      {
        var retVal:Dynamic = Stage.instance.swagBacks.get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else if (Stage.instance.swagGroups.exists(splitProps[0]))
      {
        var retVal:Dynamic = Stage.instance.swagGroups.get(splitProps[0]);
        if (retVal != null) target = retVal;
      }
      else
        target = Reflect.getProperty(instance, splitProps[0]);

      for (i in 1...splitProps.length)
      {
        var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
        target = target[j];
      }
      return target;
    }

    if (allowMaps && isMap(instance))
    {
      return instance.get(variable);
    }

    if (MusicBeatState.findVariableObj(variable))
    {
      var retVal:Dynamic = MusicBeatState.variableMap(variable).get(variable);
      if (retVal != null) return retVal;
    }
    if (PlayState.instance.stage.swagBacks.exists(variable))
    {
      var retVal:Dynamic = PlayState.instance.stage.swagBacks.get(variable);
      if (retVal != null) return retVal;
    }
    if (PlayState.instance.stage.swagGroups.exists(variable))
    {
      var retVal:Dynamic = PlayState.instance.stage.swagGroups.get(variable);
      if (retVal != null) return retVal;
    }
    if (Stage.instance.swagBacks.exists(variable))
    {
      var retVal:Dynamic = Stage.instance.swagBacks.get(variable);
      if (retVal != null) return retVal;
    }
    if (Stage.instance.swagGroups.exists(variable))
    {
      var retVal:Dynamic = Stage.instance.swagGroups.get(variable);
      if (retVal != null) return retVal;
    }
    return Reflect.getProperty(instance, variable);
  }

  public static function getModSetting(saveTag:String, ?modName:String = null)
  {
    #if MODS_ALLOWED
    if (FlxG.save.data.modSettings == null) FlxG.save.data.modSettings = new Map<String, Dynamic>();

    var settings:Map<String, Dynamic> = FlxG.save.data.modSettings.get(modName);
    var path:String = Paths.mods('$modName/data/settings.json');
    if (FileSystem.exists(path))
    {
      if (settings == null || !settings.exists(saveTag))
      {
        if (settings == null) settings = new Map<String, Dynamic>();
        var data:String = File.getContent(path);
        try
        {
          // FunkinLua.luaTrace('getModSetting: Trying to find default value for "$saveTag" in Mod: "$modName"');
          var parsedJson:Dynamic = tjson.TJSON.parse(data);
          for (i in 0...parsedJson.length)
          {
            var sub:Dynamic = parsedJson[i];
            if (sub != null && sub.save != null && !settings.exists(sub.save))
            {
              if (sub.type != 'keybind' && sub.type != 'key')
              {
                if (sub.value != null)
                {
                  // FunkinLua.luaTrace('getModSetting: Found unsaved value "${sub.save}" in Mod: "$modName"');
                  settings.set(sub.save, sub.value);
                }
              }
              else
              {
                // FunkinLua.luaTrace('getModSetting: Found unsaved keybind "${sub.save}" in Mod: "$modName"');
                settings.set(sub.save, {keyboard: (sub.keyboard != null ? sub.keyboard : 'NONE'), gamepad: (sub.gamepad != null ? sub.gamepad : 'NONE')});
              }
            }
          }
          FlxG.save.data.modSettings.set(modName, settings);
        }
        catch (e:Dynamic)
        {
          var errorTitle = 'Mod name: ' + Mods.currentModDirectory;
          var errorMsg = 'An error occurred: $e';
          #if windows
          Debug.displayAlert(errorMsg, errorTitle);
          #end
          Debug.logError('$errorTitle - $errorMsg');
        }
      }
    }
    else
    {
      FlxG.save.data.modSettings.remove(modName);
      #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
      PlayState.instance.addTextToDebug('getModSetting: $path could not be found!', FlxColor.RED);
      #else
      FlxG.log.warn('getModSetting: $path could not be found!');
      #end
      return null;
    }

    if (settings.exists(saveTag)) return settings.get(saveTag);
    #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    PlayState.instance.addTextToDebug('getModSetting: "$saveTag" could not be found inside $modName\'s settings!', FlxColor.RED);
    #else
    FlxG.log.warn('getModSetting: "$saveTag" could not be found inside $modName\'s settings!');
    #end
    #end
    return null;
  }

  public static function isMap(variable:Dynamic)
  {
    /*switch(Type.typeof(variable)){
      case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
        return true;
      default:
        return false;
    }*/

    if (variable.exists != null && variable.keyValueIterator != null) return true;
    return false;
  }

  public static function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic, ?allowMaps:Bool = false)
  {
    var split:Array<String> = variable.split('.');
    if (split.length > 1)
    {
      var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
      for (i in 1...split.length - 1)
        obj = Reflect.getProperty(obj, split[i]);

      leArray = obj;
      variable = split[split.length - 1];
    }
    if (allowMaps && isMap(leArray)) leArray.set(variable, value);
    else
      Reflect.setProperty(leArray, variable, value);
    return value;
  }

  public static function getGroupStuff(leArray:Dynamic, variable:String, ?allowMaps:Bool = false)
  {
    var split:Array<String> = variable.split('.');
    if (split.length > 1)
    {
      var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
      for (i in 1...split.length - 1)
        obj = Reflect.getProperty(obj, split[i]);

      leArray = obj;
      variable = split[split.length - 1];
    }

    if (allowMaps && isMap(leArray)) return leArray.get(variable);
    return Reflect.getProperty(leArray, variable);
  }

  public static function getPropertyLoop(split:Array<String>, ?getProperty:Bool = true, ?allowMaps:Bool = false):Dynamic
  {
    var obj:Dynamic = getObjectDirectly(split[0]);
    var end = split.length;
    if (getProperty) end = split.length - 1;

    for (i in 1...end)
      obj = getVarInArray(obj, split[i], allowMaps);
    return obj;
  }

  public static function getObjectDirectly(objectName:String, ?allowMaps:Bool = false):Dynamic
  {
    if (objectName == 'dadGroup' || objectName == 'boyfriendGroup' || objectName == 'gfGroup' || objectName == 'momGroup')
    {
      objectName = objectName.substring(0, objectName.length - 5); // because we don't use character groups
    }

    switch (objectName)
    {
      case 'this' | 'instance' | 'game':
        return PlayState.instance;

      default:
        var obj:Dynamic = null;

        if (MusicBeatState.findVariableObj(objectName)) obj = MusicBeatState.variableObj(objectName);
        else if (Stage.instance.swagBacks.exists(objectName)) obj = Stage.instance.swagBacks.get(objectName);
        else if (Stage.instance.swagGroups.exists(objectName)) obj = Stage.instance.swagGroups.get(objectName);
        else if (PlayState.instance.stage.swagBacks.exists(objectName)) obj = PlayState.instance.stage.swagBacks.get(objectName);
        else if (PlayState.instance.stage.swagGroups.exists(objectName)) obj = PlayState.instance.stage.swagGroups.get(objectName);

        if (obj == null) obj = getVarInArray(MusicBeatState.getState(), objectName, allowMaps);
        if (obj == null) obj = getActorByName(objectName);
        return obj;
    }
  }

  public static function typeSupported(value:Dynamic)
    return (value == null || isOfTypes(value, [Bool, Int, Float, String, Array]) || Type.typeof(value) == Type.ValueType.TObject);

  public static function isOfTypes(value:Any, types:Array<Dynamic>)
  {
    for (type in types)
    {
      if (Std.isOfType(value, type)) return true;
    }
    return false;
  }

  public static function getTargetInstance()
  {
    var instance:Dynamic = Stage.instance;
    if (PlayState.instance != null)
    {
      instance = PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
    }
    if (instance != null) return instance;
    return MusicBeatState.getState();
  }

  public static inline function getLowestCharacterPlacement():Character
  {
    var char:Character = PlayState.instance.gf;
    var pos:Int = PlayState.instance.members.indexOf(char);

    var newPos:Int = PlayState.instance.members.indexOf(PlayState.instance.boyfriend);
    if (newPos < pos)
    {
      char = PlayState.instance.boyfriend;
      pos = newPos;
    }

    newPos = PlayState.instance.members.indexOf(PlayState.instance.dad);
    if (newPos < pos)
    {
      char = PlayState.instance.dad;
      pos = newPos;
    }
    return char;
  }

  public static function addAnimByIndices(obj:String, name:String, prefix:String, indices:Any = null, framerate:Float = 24, loop:Bool = false)
  {
    var obj:FlxSprite = cast getObjectDirectly(obj);
    if (obj != null && obj.animation != null)
    {
      if (indices == null) indices = [0];
      else if (Std.isOfType(indices, String))
      {
        var strIndices:Array<String> = cast(indices, String).trim().split(',');
        var myIndices:Array<Int> = [];
        for (i in 0...strIndices.length)
        {
          myIndices.push(Std.parseInt(strIndices[i]));
        }
        indices = myIndices;
      }

      if (prefix != null) obj.animation.addByIndices(name, prefix, indices, '', framerate, loop);
      else
        obj.animation.add(name, indices, framerate, loop);

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
  }

  public static function loadFrames(spr:FlxSprite, image:String, spriteType:String)
  {
    switch (spriteType.toLowerCase().replace(' ', ''))
    {
      case "json", "ase", "aseprite", "jsoni8":
        spr.frames = Paths.getJsonAtlas(image);
      case "packer", "packeratlas", "pac":
        spr.frames = Paths.getPackerAtlas(image);
      case "xml":
        spr.frames = Paths.getXmlAtlas(image);
      case 'sparrow':
        spr.frames = Paths.getSparrowAtlas(image);
      default:
        spr.frames = Paths.getAtlas(image);
    }
  }

  public static function findToDestroy(tag:String, destroy:Bool = true, ?group:String = null)
  {
    destroyObject(tag, destroy, group);
    destroyStageObject(tag, destroy, group);
  }

  public static function destroyObject(tag:String, destroy:Bool = true, ?group:String = null)
  {
    final variables = MusicBeatState.variableMap(tag);
    final groupObj:Dynamic = group != null ? getObjectDirectly(group) : getTargetInstance();
    if (variables == null) return;
    final obj:FlxBasic = variables.get(tag);
    if (obj == null || obj.destroy == null) return;

    groupObj.remove(obj, true);
    if (destroy)
    {
      obj.destroy();
      variables.remove(tag);
    }
  }

  public static function destroyStageObject(tag:String, destroy:Bool = true, ?group:String = null)
  {
    final variables = Stage.instance.swagBacks;
    final groupObj:Dynamic = group != null ? getObjectDirectly(group) : getTargetInstance();
    if (variables == null) return;
    final obj:FlxBasic = variables.get(tag);
    if (obj == null || obj.destroy == null) return;

    groupObj.remove(obj, true);
    if (destroy)
    {
      obj.destroy();
      Stage.instance.swagBacks.remove(tag);
    }
  }

  public static function cancelTween(tag:String)
  {
    final variables = MusicBeatState.variableMap(tag);
    if (variables == null) return;
    final twn:FlxTween = variables.get(tag);
    if (twn != null)
    {
      twn.cancel();
      twn.destroy();
      variables.remove(tag);
    }
  }

  public static function cancelTimer(tag:String)
  {
    final variables = MusicBeatState.variableMap(tag);
    if (variables == null) return;
    final tmr:FlxTimer = variables.get(tag);
    if (tmr != null)
    {
      tmr.cancel();
      tmr.destroy();
      variables.remove(tag);
    }
  }

  public static function formatVariableOption(tag:String, option:AffixType = NONE, ?suffix:String = null, ?prefix:String = null):String
  {
    final originalTag:String = tag;
    var externalSuffix:String = suffix == null ? '' : suffix;
    var externalPrefix:String = prefix == null ? '' : prefix;
    switch (option)
    {
      case NONE:
        final finalTag:String = originalTag;
        return finalTag;
      case SUFFIXED, FORMATTED_SUFFIX:
        final finalTag:String = option == FORMATTED_SUFFIX ? formatVariable(suffix + originalTag) : suffix + originalTag;
        return finalTag;
      case PREFIXED, FORMATTED_PREFIX:
        final finalTag:String = option == FORMATTED_PREFIX ? formatVariable(originalTag + prefix) : originalTag + prefix;
        return finalTag;
      case CIRCUMFIXED, FORMATTED_CIRCUMFIX:
        final finalTag:String = option == FORMATTED_CIRCUMFIX ? formatVariable(suffix + originalTag + prefix) : suffix + originalTag + prefix;
        return finalTag;
      default:
        return "";
    }
    return null;
  }

  public static function formatVariable(tag:String)
    return tag.trim().replace(' ', '_').replace('.', '');

  public static function checkVariable(start:String, end:String, formatType:String = "both")
  {
    formatType = formatType.toLowerCase();
    if (!start.startsWith(end))
    {
      switch (formatType)
      {
        case "both", "both-reverse":
          switch (formatType)
          {
            case "both":
              start = formatVariable(end + start);
            case "both-reverse":
              start = formatVariable(start + end);
          }
        case "endformat-start":
          start = formatVariable(end) + start;
        case "end-startformat":
          start = end + formatVariable(start);
        case "startformat-end":
          start = formatVariable(start) + end;
        case "start-formatend":
          start = start + formatVariable(end);
      }
      return start;
    }
    return formatVariable(start);
  }

  public static function tweenPrepare(tag:String, vars:String)
  {
    if (tag != null) cancelTween(tag);
    var variables:Array<String> = vars.split('.');
    var sexyProp:Dynamic = getObjectDirectly(variables[0]);
    if (variables.length > 1) sexyProp = getVarInArray(getPropertyLoop(variables), variables[variables.length - 1]);
    return sexyProp;
  }

  public static function getBuildTarget():String
  {
    #if windows
    #if x86_BUILD
    return 'windows_x86';
    #else
    return 'windows';
    #end
    #elseif linux
    return 'linux';
    #elseif mac
    return 'mac';
    #elseif hl
    return 'hashlink';
    #elseif (html5 || emscripten || nodejs || winjs || electron)
    return 'browser';
    #elseif android
    return 'android';
    #elseif webos
    return 'webos';
    #elseif tvos
    return 'tvos';
    #elseif watchos
    return 'watchos';
    #elseif air
    return 'air';
    #elseif flash
    return 'flash';
    #elseif (ios || iphonesim)
    return 'ios';
    #elseif neko
    return 'neko';
    #elseif switch
    return 'switch';
    #else
    return 'unknown';
    #end
  }

  // buncho string stuffs
  public static function getTweenTypeByString(?type:String = '')
  {
    switch (type.toLowerCase().trim())
    {
      case 'backward':
        return FlxTweenType.BACKWARD;
      case 'looping', 'loop':
        return FlxTweenType.LOOPING;
      case 'persist':
        return FlxTweenType.PERSIST;
      case 'pingpong':
        return FlxTweenType.PINGPONG;
    }
    return FlxTweenType.ONESHOT;
  }

  public static function getTweenEaseByString(?ease:String = '')
  {
    switch (ease.toLowerCase().trim())
    {
      case 'backin':
        return utils.EaseUtil.backIn;
      case 'backinout':
        return utils.EaseUtil.backInOut;
      case 'backout':
        return utils.EaseUtil.backOut;
      case 'backoutin':
        return utils.EaseUtil.backOutIn;
      case 'bounce':
        return utils.EaseUtil.bounce;
      case 'bouncein':
        return utils.EaseUtil.bounceIn;
      case 'bounceinout':
        return utils.EaseUtil.bounceInOut;
      case 'bounceout':
        return utils.EaseUtil.bounceOut;
      case 'bounceoutin':
        return utils.EaseUtil.bounceOutIn;
      case 'bell':
        return utils.EaseUtil.bell;
      case 'circin':
        return utils.EaseUtil.circIn;
      case 'circinout':
        return utils.EaseUtil.circInOut;
      case 'circout':
        return utils.EaseUtil.circOut;
      case 'circoutin':
        return utils.EaseUtil.circOutIn;
      case 'cubein':
        return utils.EaseUtil.cubeIn;
      case 'cubeinout':
        return utils.EaseUtil.cubeInOut;
      case 'cubeout':
        return utils.EaseUtil.cubeOut;
      case 'cubeoutin':
        return utils.EaseUtil.cubeOutIn;
      case 'elasticin':
        return utils.EaseUtil.elasticIn;
      case 'elasticinout':
        return utils.EaseUtil.elasticInOut;
      case 'elasticout':
        return utils.EaseUtil.elasticOut;
      case 'elasticoutin':
        return utils.EaseUtil.elasticOutIn;
      case 'expoin':
        return utils.EaseUtil.expoIn;
      case 'expoinout':
        return utils.EaseUtil.expoInOut;
      case 'expoout':
        return utils.EaseUtil.expoOut;
      case 'expooutin':
        return utils.EaseUtil.expoOutIn;
      case 'inverse':
        return utils.EaseUtil.inverse;
      case 'instant':
        return utils.EaseUtil.instant;
      case 'pop':
        return utils.EaseUtil.pop;
      case 'popelastic':
        return utils.EaseUtil.popElastic;
      case 'pulse':
        return utils.EaseUtil.pulse;
      case 'pulseelastic':
        return utils.EaseUtil.pulseElastic;
      case 'quadin':
        return utils.EaseUtil.quadIn;
      case 'quadinout':
        return utils.EaseUtil.quadInOut;
      case 'quadout':
        return utils.EaseUtil.quadOut;
      case 'quadoutin':
        return utils.EaseUtil.quadOutIn;
      case 'quartin':
        return utils.EaseUtil.quartIn;
      case 'quartinout':
        return utils.EaseUtil.quartInOut;
      case 'quartout':
        return utils.EaseUtil.quartOut;
      case 'quartoutin':
        return utils.EaseUtil.quartOutIn;
      case 'quintin':
        return utils.EaseUtil.quintIn;
      case 'quintinout':
        return utils.EaseUtil.quintInOut;
      case 'quintout':
        return utils.EaseUtil.quintOut;
      case 'quintoutin':
        return utils.EaseUtil.quintOutIn;
      case 'sinein':
        return utils.EaseUtil.sineIn;
      case 'sineinout':
        return utils.EaseUtil.sineInOut;
      case 'sineout':
        return utils.EaseUtil.sineOut;
      case 'sineoutin':
        return utils.EaseUtil.sineOutIn;
      case 'spike':
        return utils.EaseUtil.spike;
      case 'smoothstepin':
        return utils.EaseUtil.smoothStepIn;
      case 'smoothstepinout':
        return utils.EaseUtil.smoothStepInOut;
      case 'smoothstepout':
        return utils.EaseUtil.smoothStepOut;
      case 'smootherstepin':
        return utils.EaseUtil.smootherStepIn;
      case 'smootherstepinout':
        return utils.EaseUtil.smootherStepInOut;
      case 'smootherstepout':
        return utils.EaseUtil.smootherStepOut;
      case 'tap':
        return utils.EaseUtil.tap;
      case 'tapelastic':
        return utils.EaseUtil.tapElastic;
      case 'tri':
        return utils.EaseUtil.tri;
    }
    return utils.EaseUtil.linear;
  }

  public static function blendModeFromString(blend:String):BlendMode
  {
    switch (blend.toLowerCase().trim())
    {
      case 'add':
        return ADD;
      case 'alpha':
        return ALPHA;
      case 'darken':
        return DARKEN;
      case 'difference':
        return DIFFERENCE;
      case 'erase':
        return ERASE;
      case 'hardlight':
        return HARDLIGHT;
      case 'invert':
        return INVERT;
      case 'layer':
        return LAYER;
      case 'lighten':
        return LIGHTEN;
      case 'multiply':
        return MULTIPLY;
      case 'overlay':
        return OVERLAY;
      case 'screen':
        return SCREEN;
      case 'shader':
        return SHADER;
      case 'subtract':
        return SUBTRACT;
    }
    return NORMAL;
  }

  public static function typeToString(type:Int):String
  {
    #if LUA_ALLOWED
    switch (type)
    {
      case Lua.LUA_TBOOLEAN:
        return "boolean";
      case Lua.LUA_TNUMBER:
        return "number";
      case Lua.LUA_TSTRING:
        return "string";
      case Lua.LUA_TTABLE:
        return "table";
      case Lua.LUA_TFUNCTION:
        return "function";
    }
    if (type <= Lua.LUA_TNIL) return "nil";
    #end
    return "unknown";
  }

  public static function cameraFromString(cam:String):FlxCamera
  {
    var camera:LuaCamera = getCameraByName(cam);
    if (camera == null)
    {
      if (PlayState.instance != null)
      {
        switch (cam.toLowerCase())
        {
          case 'camgame' | 'game':
            return PlayState.instance.camGame;
          case 'camhud2' | 'hud2':
            return PlayState.instance.camHUD2;
          case 'camhud' | 'hud':
            return PlayState.instance.camHUD;
          case 'camother' | 'other':
            return PlayState.instance.camOther;
          case 'camnotestuff' | 'notestuff':
            return PlayState.instance.camNoteStuff;
          case 'camstuff' | 'stuff':
            return PlayState.instance.camStuff;
          case 'maincam' | 'main':
            return PlayState.instance.mainCam;

          case 'camslehud' | 'slehud':
            return PlayState.instance.camSLEHUD;
          case 'camthings':
            return PlayState.instance.camThings;
          case 'camthings2':
            return PlayState.instance.camThings2;
          case 'camthings3':
            return PlayState.instance.camThings3;
          case 'camthings4':
            return PlayState.instance.camThings4;
          case 'camthings5':
            return PlayState.instance.camThings5;
          case 'camwatermark' | 'watermark':
            return PlayState.instance.camWaterMark;
        }
      }

      // modded cameras
      var camera:Dynamic = MusicBeatState.variableMap(cam).get(cam);
      if (camera == null || !Std.isOfType(camera, FlxCamera)) camera = PlayState.instance.camGame;
      return camera;
    }
    return camera.cam;
  }

  public static function returnCameraName(camera:String):String
  {
    switch (camera.toLowerCase())
    {
      case 'camgame' | 'game':
        camera = 'camGame';
      case 'camhud2' | 'hud2':
        camera = 'camHUD2';
      case 'camhud' | 'hud':
        camera = 'camHUD';
      case 'camother' | 'other':
        camera = 'camOther';
      case 'camnotestuff' | 'notestuff':
        camera = 'camNoteStuff';
      case 'camstuff' | 'stuff':
        camera = 'stuff';
      case 'maincam', 'main':
        camera = 'mainCam';
      case 'camslehud' | 'slehud':
        camera = 'camSLEHUD';
      case 'camthings':
        camera = 'camThings';
      case 'camthings2':
        camera = 'camThings2';
      case 'camthings3':
        camera = 'camThings3';
      case 'camthings4':
        camera = 'camThings4';
      case 'camthings5':
        camera = 'camThings5';
      case 'camwatermark' | 'watermark':
        camera = 'camWaterMark';
      default:
        var cam:Dynamic = MusicBeatState.variableMap(camera).get(camera);
        if (cam == null || !Std.isOfType(cam, FlxCamera)) camera = 'camGame';
    }
    return camera;
  }

  public static function makeLuaCharacter(tag:String, character:String, isPlayer:Bool = false, flipped:Bool = false, characterType:String = 'OTHER')
  {
    tag = tag.replace('.', '');
    if (!ClientPrefs.data.characters) return;
    var animationName:String = "no way anyone have an anim name this big";
    var animationFrame:Int = 0;
    var position:Int = -1;

    if (MusicBeatState.getVariables("Character").get(tag) != null)
    {
      var daChar:Character = MusicBeatState.getVariables("Character").get(tag);
      if (daChar.playAnimationBeforeSwitch)
      {
        animationName = daChar.animation.curAnim.name;
        animationFrame = daChar.animation.curAnim.curFrame;
      }
      position = LuaUtils.getTargetInstance().members.indexOf(daChar);
    }

    LuaUtils.findToDestroy(tag);
    var leSprite:Character = new Character(0, 0, character, isPlayer, characterType);
    leSprite.flipMode = flipped;
    leSprite.isCustomCharacter = true;
    MusicBeatState.getVariables("Character").set(tag, leSprite); // yes
    var shit:Character = MusicBeatState.getVariables("Character").get(tag);

    LuaUtils.getTargetInstance().add(shit);

    if (position >= 0) // this should keep them in the same spot if they switch
    {
      LuaUtils.getTargetInstance().remove(shit, true);
      LuaUtils.getTargetInstance().insert(position, shit);
    }

    var charOffset = new CharacterOffsets(character, flipped);
    var charX:Float = charOffset.daOffsetArray[0];
    var charY:Float = charOffset.daOffsetArray[1] + (flipped ? 350 : 0);

    if (!isPlayer)
    {
      if (flipped) shit.flipMode = true;

      if (shit.hardCodedCharacter)
      {
        if (flipped)
        {
          if (charX == 0 && charOffset.daOffsetArray[1] == 0 && !charOffset.hasOffsets)
          {
            var charOffset2 = new CharacterOffsets(character, false);
            charX = charOffset2.daOffsetArray[0];
            charY = charOffset2.daOffsetArray[1];
          }
        }
        else
        {
          if (charX == 0 && charY == 0 && !charOffset.hasOffsets)
          {
            var charOffset2 = new CharacterOffsets(character, true);
            charX = charOffset2.daOffsetArray[0];
            charY = charOffset2.daOffsetArray[1] + 350;
          }
        }
      }

      if (!shit.hardCodedCharacter)
      {
        charX = shit.positionArray[0];
        charY = shit.positionArray[1];
      }

      shit.x = PlayState.instance.stage.dadXOffset + charX + PlayState.instance.DAD_X;
      shit.y = PlayState.instance.stage.dadYOffset + charY + PlayState.instance.DAD_Y;
    }
    else
    {
      if (flipped) shit.flipMode = true;

      var charOffset = new CharacterOffsets(character, !flipped);
      var charX:Float = charOffset.daOffsetArray[0];
      var charY:Float = charOffset.daOffsetArray[1] - (!flipped ? 0 : 350);

      if (shit.hardCodedCharacter)
      {
        if (flipped)
        {
          if (charX == 0 && charOffset.daOffsetArray[1] == 0)
          {
            var charOffset2 = new CharacterOffsets(character, true);
            charX = charOffset2.daOffsetArray[0];
            charY = charOffset2.daOffsetArray[1];
          }
        }
        else
        {
          if (charX == 0 && charY == 0 && !shit.curCharacter.startsWith('bf'))
          {
            var charOffset2 = new CharacterOffsets(character, false);
            charX = charOffset2.daOffsetArray[0];
            charY = charOffset2.daOffsetArray[1] - 350;
          }
        }
      }

      if (!shit.hardCodedCharacter)
      {
        charX = shit.positionArray[0];
        charY = shit.positionArray[1] - 350;
      }

      shit.x = PlayState.instance.stage.bfXOffset + charX + PlayState.instance.BF_X;
      shit.y = PlayState.instance.stage.bfYOffset + charY + PlayState.instance.BF_Y;
    }

    if (shit.playAnimationBeforeSwitch)
    {
      if (shit.hasOffsetAnimation(animationName)) shit.playAnim(animationName, true, false, animationFrame);
    }

    shit.loadCharacterScript(shit.curCharacter);
  }

  // Kade why tf is it not like in PlayState???
  // Blantados Code!

  public static function changeGFCharacter(id:String, x:Float, y:Float)
  {
    changeGFAuto(id, false);
    PlayState.instance.gf.x = x;
    PlayState.instance.gf.y = y;
  }

  public static function changeDadCharacter(id:String, x:Float, y:Float)
  {
    changeDadAuto(id, false);
    PlayState.instance.dad.x = x;
    PlayState.instance.dad.y = y;
  }

  public static function changeBoyfriendCharacter(id:String, x:Float, y:Float)
  {
    changeBFAuto(id, false);
    PlayState.instance.boyfriend.x = x;
    PlayState.instance.boyfriend.y = y;
  }

  public static function changeMomCharacter(id:String, x:Float, y:Float)
  {
    changeMomAuto(id, false);
    PlayState.instance.mom.x = x;
    PlayState.instance.mom.y = y;
  }

  // this is better. easier to port shit from playstate.
  public static function changeGFCharacterBetter(x:Float, y:Float, id:String)
  {
    changeGFCharacter(id, x, y);
  }

  public static function changeDadCharacterBetter(x:Float, y:Float, id:String)
  {
    changeDadCharacter(id, x, y);
  }

  public static function changeBoyfriendCharacterBetter(x:Float, y:Float, id:String)
  {
    changeBoyfriendCharacter(id, x, y);
  }

  public static function changeMomCharacterBetter(x:Float, y:Float, id:String)
  {
    changeMomCharacter(id, x, y);
  }

  // trying to do some auto stuff so i don't have to set manual x and y values
  public static function changeBFAuto(id:String, ?flipped:Bool = false)
  {
    if (!ClientPrefs.data.characters) return;
    if (PlayState.instance.boyfriend == null) return;
    var animationName:String = "no way anyone have an anim name this big";
    var animationFrame:Int = 0;
    if (PlayState.instance.boyfriend.playAnimationBeforeSwitch)
    {
      animationName = PlayState.instance.boyfriend.animation.curAnim.name;
      animationFrame = PlayState.instance.boyfriend.animation.curAnim.curFrame;
    }

    PlayState.instance.boyfriend.resetAnimationVars();

    PlayState.instance.removeObject(PlayState.instance.boyfriend);
    PlayState.instance.boyfriend.destroy();
    PlayState.instance.boyfriend = new Character(0, 0, id, !flipped, 'BF');
    PlayState.instance.boyfriend.flipMode = flipped;

    var charOffset = new CharacterOffsets(id, !flipped);
    var charX:Float = charOffset.daOffsetArray[0];
    var charY:Float = charOffset.daOffsetArray[1] - (!flipped ? 0 : 350);

    if (PlayState.instance.boyfriend.hardCodedCharacter)
    {
      if (flipped)
      {
        if (charX == 0 && charOffset.daOffsetArray[1] == 0)
        {
          var charOffset2 = new CharacterOffsets(id, true);
          charX = charOffset2.daOffsetArray[0];
          charY = charOffset2.daOffsetArray[1];
        }
      }
      else
      {
        if (charX == 0 && charY == 0 && !PlayState.instance.boyfriend.curCharacter.startsWith('bf'))
        {
          var charOffset2 = new CharacterOffsets(id, false);
          charX = charOffset2.daOffsetArray[0];
          charY = charOffset2.daOffsetArray[1] - 350;
        }
      }
    }

    if (!PlayState.instance.boyfriend.hardCodedCharacter)
    {
      charX = PlayState.instance.boyfriend.positionArray[0];
      charY = PlayState.instance.boyfriend.positionArray[1] - 350;
    }

    PlayState.instance.boyfriend.setPosition(PlayState.instance.stage.bfXOffset
      + charX
      + PlayState.instance.BF_X,
      PlayState.instance.stage.bfYOffset
      + charY
      + PlayState.instance.BF_Y);

    PlayState.instance.addObject(PlayState.instance.boyfriend);

    PlayState.instance.iconP1.changeIcon(PlayState.instance.boyfriend.healthIcon);

    PlayState.instance.reloadColors();

    if (PlayState.instance.boyfriend.playAnimationBeforeSwitch)
    {
      if (PlayState.instance.boyfriend.hasOffsetAnimation(animationName)) PlayState.instance.boyfriend.playAnim(animationName, true, false, animationFrame);
    }

    PlayState.instance.setOnScripts('boyfriendName', PlayState.instance.boyfriend.curCharacter);
    PlayState.instance.boyfriend.loadCharacterScript(PlayState.instance.boyfriend.curCharacter);
  }

  public static function changeDadAuto(id:String, ?flipped:Bool = false)
  {
    if (!ClientPrefs.data.characters) return;
    if (PlayState.instance.dad == null) return;
    var animationName:String = "no way anyone have an anim name this big";
    var animationFrame:Int = 0;
    if (PlayState.instance.dad.playAnimationBeforeSwitch)
    {
      animationName = PlayState.instance.dad.animation.curAnim.name;
      animationFrame = PlayState.instance.dad.animation.curAnim.curFrame;
    }

    PlayState.instance.remove(PlayState.instance.dad);
    PlayState.instance.dad.destroy();
    PlayState.instance.dad = new Character(0, 0, id, flipped, 'DAD');
    PlayState.instance.dad.flipMode = flipped;

    var charOffset = new CharacterOffsets(id, flipped);
    var charX:Float = charOffset.daOffsetArray[0];
    var charY:Float = charOffset.daOffsetArray[1] + (flipped ? 350 : 0);

    if (PlayState.instance.dad.hardCodedCharacter)
    {
      if (flipped)
      {
        if (charX == 0 && charOffset.daOffsetArray[1] == 0 && !charOffset.hasOffsets)
        {
          var charOffset2 = new CharacterOffsets(id, false);
          charX = charOffset2.daOffsetArray[0];
          charY = charOffset2.daOffsetArray[1];
        }
      }
      else
      {
        if (charX == 0 && charY == 0 && !charOffset.hasOffsets)
        {
          var charOffset2 = new CharacterOffsets(id, true);
          charX = charOffset2.daOffsetArray[0];
          charY = charOffset2.daOffsetArray[1] + 350;
        }
      }
    }

    if (!PlayState.instance.dad.hardCodedCharacter)
    {
      charX = PlayState.instance.dad.positionArray[0];
      charY = PlayState.instance.dad.positionArray[1];
    }

    PlayState.instance.dad.setPosition(PlayState.instance.stage.dadXOffset
      + charX
      + PlayState.instance.DAD_X,
      PlayState.instance.stage.dadYOffset
      + charY
      + PlayState.instance.DAD_Y);

    PlayState.instance.add(PlayState.instance.dad);

    PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);

    PlayState.instance.reloadColors();

    if (PlayState.instance.dad.playAnimationBeforeSwitch)
    {
      if (PlayState.instance.dad.hasOffsetAnimation(animationName)) PlayState.instance.dad.playAnim(animationName, true, false, animationFrame);
    }

    PlayState.instance.setOnScripts('dadName', PlayState.instance.dad.curCharacter);
    PlayState.instance.dad.loadCharacterScript(PlayState.instance.dad.curCharacter);
  }

  public static function changeGFAuto(id:String, ?flipped:Bool = false)
  {
    if (!ClientPrefs.data.characters) return;
    if (PlayState.instance.gf == null) return;
    var animationName:String = "no way anyone have an anim name this big";
    var animationFrame:Int = 0;
    if (PlayState.instance.gf.playAnimationBeforeSwitch)
    {
      animationName = PlayState.instance.gf.animation.curAnim.name;
      animationFrame = PlayState.instance.gf.animation.curAnim.curFrame;
    }

    PlayState.instance.remove(PlayState.instance.gf);
    PlayState.instance.gf.destroy();
    PlayState.instance.gf = new Character(0, 0, id, flipped, 'GF');
    PlayState.instance.gf.flipMode = flipped;

    var charX:Float = PlayState.instance.gf.positionArray[0];
    var charY:Float = PlayState.instance.gf.positionArray[1];

    PlayState.instance.gf.setPosition(PlayState.instance.stage.gfXOffset
      + charX
      + PlayState.instance.GF_X,
      PlayState.instance.stage.gfYOffset
      + charY
      + PlayState.instance.GF_Y);
    PlayState.instance.gf.scrollFactor.set(0.95, 0.95);
    PlayState.instance.addObject(PlayState.instance.gf);

    if (PlayState.instance.gf.playAnimationBeforeSwitch)
    {
      if (PlayState.instance.gf.hasOffsetAnimation(animationName)) PlayState.instance.gf.playAnim(animationName, true, false, animationFrame);
    }

    PlayState.instance.setOnScripts('gfName', PlayState.instance.gf.curCharacter);
    PlayState.instance.gf.loadCharacterScript(PlayState.instance.gf.curCharacter);
  }

  public static function changeMomAuto(id:String, ?flipped:Bool = false)
  {
    if (!ClientPrefs.data.characters) return;
    if (PlayState.instance.mom == null) return;
    var animationName:String = "no way anyone have an anim name this big";
    var animationFrame:Int = 0;
    if (PlayState.instance.mom.playAnimationBeforeSwitch)
    {
      animationName = PlayState.instance.mom.animation.curAnim.name;
      animationFrame = PlayState.instance.mom.animation.curAnim.curFrame;
    }

    PlayState.instance.remove(PlayState.instance.mom);
    PlayState.instance.mom.destroy();
    PlayState.instance.mom = new Character(0, 0, id, flipped, 'DAD');
    PlayState.instance.mom.flipMode = flipped;

    var charOffset = new CharacterOffsets(id, flipped);
    var charX:Float = charOffset.daOffsetArray[0];
    var charY:Float = charOffset.daOffsetArray[1] + (flipped ? 350 : 0);

    charX = PlayState.instance.mom.positionArray[0];
    charY = PlayState.instance.mom.positionArray[1];

    PlayState.instance.mom.setPosition(PlayState.instance.stage.momXOffset
      + charX
      + PlayState.instance.MOM_X,
      PlayState.instance.stage.momYOffset
      + charY
      + PlayState.instance.MOM_Y);

    PlayState.instance.add(PlayState.instance.mom);

    if (PlayState.instance.mom.playAnimationBeforeSwitch)
    {
      if (PlayState.instance.mom.hasOffsetAnimation(animationName)) PlayState.instance.mom.playAnim(animationName, true, false, animationFrame);
    }

    PlayState.instance.setOnScripts('momName', PlayState.instance.mom.curCharacter);
    PlayState.instance.mom.loadCharacterScript(PlayState.instance.mom.curCharacter);
  }

  #if LUA_ALLOWED
  public static function getCameraByName(id:String):FunkinLua.LuaCamera
  {
    if (FunkinLua.lua_Cameras.exists(id)) return FunkinLua.lua_Cameras.get(id);

    switch (id.toLowerCase())
    {
      case 'camhud2' | 'hud2':
        return FunkinLua.lua_Cameras.get("hud2");
      case 'camhud' | 'hud':
        return FunkinLua.lua_Cameras.get("hud");
      case 'camother' | 'other':
        return FunkinLua.lua_Cameras.get("other");
      case 'camnotestuff' | 'notestuff':
        return FunkinLua.lua_Cameras.get("notestuff");
      case 'camstuff' | 'stuff':
        return FunkinLua.lua_Cameras.get("stuff");
      case 'maincam' | 'main':
        return FunkinLua.lua_Cameras.get("main");

      case 'camslehud' | 'slehud':
        return FunkinLua.lua_Cameras.get("camSLEHUD");
      case 'camthings':
        return FunkinLua.lua_Cameras.get("camThings");
      case 'camthings2':
        return FunkinLua.lua_Cameras.get("camThings2");
      case 'camthings3':
        return FunkinLua.lua_Cameras.get("camThings3");
      case 'camthings4':
        return FunkinLua.lua_Cameras.get("camThings4");
      case 'camthings5':
        return FunkinLua.lua_Cameras.get("camThings5");
      case 'camwatermark' | 'watermark':
        return FunkinLua.lua_Cameras.get("camWaterWark");
    }

    return FunkinLua.lua_Cameras.get("game");
  }

  public static function killShaders() // dead
  {
    for (cam in FunkinLua.lua_Cameras)
    {
      cam.shaders = [];
      cam.shaderNames = [];
    }
    FunkinLua.lua_Cameras = [];

    for (shader in FunkinLua.lua_Shaders.keys())
    {
      FunkinLua.lua_Shaders.get(shader).destroy();
      FunkinLua.lua_Shaders.remove(shader);
    }
    FunkinLua.lua_Shaders = [];
  }

  public static function getActorByName(id:String):Dynamic // kade to psych
  {
    if (FunkinLua.lua_Cameras.exists(id)) return FunkinLua.lua_Cameras.get(id).cam;
    else if (FunkinLua.lua_Shaders.exists(id)) return FunkinLua.lua_Shaders.get(id);
    else if (FunkinLua.lua_Custom_Shaders.exists(id)) return FunkinLua.lua_Custom_Shaders.get(id);

    // pre defined names
    if (getTargetInstance() == PlayState.instance)
    {
      switch (id)
      {
        case 'boyfriend' | 'bf':
          return PlayState.instance.boyfriend;
        case 'dad':
          return PlayState.instance.dad;
        case 'mom':
          return PlayState.instance.mom;
        case 'gf' | 'girlfriend':
          return PlayState.instance.gf;
      }
    }

    if (id.contains('stage-') && getTargetInstance() == PlayState.instance)
    {
      var daID:String = id.split('-')[1];
      return PlayState.instance.stage.swagBacks[daID];
    }

    if (getTargetInstance() == PlayState.instance)
    {
      if (Reflect.getProperty(PlayState.instance, id) != null) return Reflect.getProperty(PlayState.instance, id);
      else if (Reflect.getProperty(PlayState, id) != null) return Reflect.getProperty(PlayState, id);
    }

    if (MusicBeatState.variableMap(id).exists(id)) return MusicBeatState.variableMap(id).get(id);

    if (Std.parseInt(id) == null) return Reflect.getProperty(getTargetInstance(), id);
    else if (getTargetInstance() == PlayState.instance)
    {
      return PlayState.instance.strumLineNotes.members[Std.parseInt(id)];
    }
    return "No such item!";
  }

  public static function convert(v:Any, type:String):Dynamic
  {
    if (Std.isOfType(v, String) && type != null)
    {
      var v:String = v;
      if (type.substr(0, 4) == 'array')
      {
        if (type.substr(4) == 'float')
        {
          var array:Array<String> = v.split(',');
          var array2:Array<Float> = new Array();

          for (vars in array)
          {
            array2.push(Std.parseFloat(vars));
          }

          return array2;
        }
        else if (type.substr(4) == 'int')
        {
          var array:Array<String> = v.split(',');
          var array2:Array<Int> = new Array();

          for (vars in array)
          {
            array2.push(Std.parseInt(vars));
          }

          return array2;
        }
        else
        {
          var array:Array<String> = v.split(',');
          return array;
        }
      }
      else if (type == 'float')
      {
        return Std.parseFloat(v);
      }
      else if (type == 'int')
      {
        return Std.parseInt(v);
      }
      else if (type == 'bool')
      {
        if (v == 'true')
        {
          return true;
        }
        else
        {
          return false;
        }
      }
      else
      {
        return v;
      }
    }
    else
    {
      return v;
    }
  }
  #end

  public static function changeStageOffsets(char:String, x:Float = -10000,
      ?y:Float = -10000) // in case you need to change or test the stage offsets for the auto commands
  {
    if (getTargetInstance() != PlayState.instance) return;
    switch (char)
    {
      case 'boyfriend' | 'bf':
        if (x != -10000) PlayState.instance.stage.bfXOffset = x;
        if (y != -10000) PlayState.instance.stage.bfYOffset = y;
      case 'gf':
        if (x != -10000) PlayState.instance.stage.gfXOffset = x;
        if (y != -10000) PlayState.instance.stage.gfYOffset = y;
      case 'mom':
        if (x != -10000) PlayState.instance.stage.momXOffset = x;
        if (y != -10000) PlayState.instance.stage.momYOffset = y;
      default:
        if (x != -10000) PlayState.instance.stage.dadXOffset = x;
        if (y != -10000) PlayState.instance.stage.dadYOffset = y;
    }
  }

  public static function doFunction(id:String, ?val1:Dynamic, ?val2:Dynamic, ?val3:Dynamic, ?val4:Dynamic)
  {
    // this is dumb but idk how else to do it and i don't wanna make multiple functions for different playstate functions so yeah.
    switch (id)
    {
      case 'startCountdown':
        PlayState.instance.startCountdown();
      case 'resyncVocals':
        PlayState.instance.resyncVocals();
      case 'cacheImage':
        Paths.cacheBitmap(val1, val2, val3, val4);
    }
  }
}