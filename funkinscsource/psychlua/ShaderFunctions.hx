package psychlua;

#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end
import openfl.filters.ShaderFilter;
import codenameengine.shaders.CustomShader;

class ShaderFunctions
{
  public static function implement(funk:FunkinLua)
  {
    // shader shit
    if (!ClientPrefs.data.shaders) return;
    funk.addLocalCallback("initLuaShader", function(name:String) {
      #if (!flash && sys)
      return funk.initLuaShader(name);
      #else
      FunkinLua.luaTrace("initLuaShader: Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
      #end
      return false;
    });

    funk.addLocalCallback("setSpriteShader", function(obj:String, shader:String, ?findOther:Bool = false) {
      #if (!flash && sys)
      if (!funk.runtimeShaders.exists(shader) && !funk.initLuaShader(shader))
      {
        FunkinLua.luaTrace('setSpriteShader: Shader $shader is missing!', false, false, FlxColor.RED);
        return false;
      }

      final split:Array<String> = obj.split('.');
      final leObj:Dynamic = split.length > 1 ? LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1]) : LuaUtils.getObjectDirectly(split[0]);

      if (leObj != null)
      {
        final arr:Array<String> = findOther ? [FunkinLua.lua_Shaders.get(shader)
          .getShader()
          .glFragmentSource, FunkinLua.lua_Shaders.get(shader).getShader().glVertexSource] : funk.runtimeShaders.get(shader);
        final daShader:FlxRuntimeShader = new FlxRuntimeShader(arr[0], arr[1]);

        if (Std.isOfType(leObj, FlxCamera))
        {
          final daFilters = (leObj.filters != null) ? leObj.filters : [];
          daFilters.push(new ShaderFilter(daShader));

          leObj.setFilters(daFilters);
        }
        else
          leObj.shader = daShader;
        return true;
      }
      #else
      FunkinLua.luaTrace("setSpriteShader: Platform unsupported for Runtime Shaders!", false, false, FlxColor.RED);
      #end
      return false;
    });
    funk.set("removeSpriteShader", function(obj:String, ?shader:String = "", ?findOther:Bool = false) {
      final split:Array<String> = obj.split('.');
      final leObj:Dynamic = split.length > 1 ? LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1]) : LuaUtils.getObjectDirectly(split[0]);

      if (Std.isOfType(leObj, FlxCamera))
      {
        var newCamEffects = [];

        if (shader != "" && shader.length > 0)
        {
          var daFilters = [];
          var swagFilters = [];

          if (leObj.filters != null)
          {
            daFilters = leObj.filters;
            swagFilters = leObj.filters;
          }

          final arr:Array<String> = funk.runtimeShaders.get(shader);

          for (i in 0...daFilters.length)
          {
            final filter:ShaderFilter = daFilters[i];

            if ((filter.shader.glFragmentSource == FlxRuntimeShader.processDataSource(arr[0], 'fragment'))
              || (filter.shader.glFragmentSource == FunkinLua.lua_Shaders.get(shader).getShader().glFragmentSource))
            {
              swagFilters.remove(filter);
              break;
            }
          }

          newCamEffects = swagFilters;
        }

        leObj.setFilters(newCamEffects);
      }
      else
        leObj.shader = null;
      return false;
    });

    funk.set("getShaderBool", function(obj:String, prop:String, ?swagShader:String = "") {
      return checkFunction(funk, "getBool", obj, prop, Bool, swagShader);
    });
    funk.set("getShaderBoolArray", function(obj:String, prop:String, ?swagShader:String = "") {
      return checkFunction(funk, "getBoolArray", obj, prop, Array, swagShader);
    });
    funk.set("getShaderInt", function(obj:String, prop:String, ?swagShader:String = "") {
      return checkFunction(funk, "getInt", obj, prop, Int, swagShader);
    });
    funk.set("getShaderIntArray", function(obj:String, prop:String, ?swagShader:String = "") {
      return checkFunction(funk, "getIntArray", obj, prop, Array, swagShader);
    });
    funk.set("getShaderFloat", function(obj:String, prop:String, ?swagShader:String = "") {
      return checkFunction(funk, "getFloat", obj, prop, Float, swagShader);
    });
    funk.set("getShaderFloatArray", function(obj:String, prop:String, ?swagShader:String = "") {
      return checkFunction(funk, "getFloatArray", obj, prop, Array, swagShader);
    });

    funk.set("setShaderBool", function(obj:String, prop:String, value:Bool, ?swagShader:String = "") {
      return checkFunction(funk, "setBool", obj, prop, value, swagShader);
    });
    funk.set("setShaderBoolArray", function(obj:String, prop:String, values:Dynamic, ?swagShader:String = "") {
      final boolArray:Array<Null<Bool>> = values;
      return checkFunction(funk, "setBoolArray", obj, prop, boolArray, swagShader);
    });
    funk.set("setShaderInt", function(obj:String, prop:String, value:Int, ?swagShader:String = "") {
      return checkFunction(funk, "setInt", obj, prop, value, swagShader);
    });
    funk.set("setShaderIntArray", function(obj:String, prop:String, values:Dynamic, ?swagShader:String = "") {
      final intArray:Array<Null<Int>> = values;
      return checkFunction(funk, "setIntArray", obj, prop, intArray, swagShader);
    });
    funk.set("setShaderFloat", function(obj:String, prop:String, value:Float, ?swagShader:String = "") {
      return checkFunction(funk, "setFloat", obj, prop, value, swagShader);
    });
    funk.set("setShaderFloatArray", function(obj:String, prop:String, values:Dynamic, ?swagShader:String = "") {
      final floatArray:Array<Null<Float>> = values;
      return checkFunction(funk, "setFloatArray", obj, prop, floatArray, swagShader);
    });

    funk.set("setShaderSampler2D", function(obj:String, prop:String, bitmapdataPath:String, ?swagShader:String = "") {
      return checkFunction(funk, "setSampler2D", obj, prop, bitmapdataPath, swagShader);
    });

    funk.set("setShaderProperty", function(shader:String, prop:String, value:Dynamic, ?allowedTypes:Array<Dynamic> = null) {
      if (!FunkinLua.lua_Shaders.exists(shader)) return value;
      if (allowedTypes == null) allowedTypes = [Bool, Int, Array, Float, String];
      if (LuaUtils.isOfTypes(value, allowedTypes))
      {
        Reflect.setProperty(FunkinLua.lua_Shaders.get(shader), prop, value);
        return value;
      }
      return value;
    });

    funk.set("getShaderProperty", function(shader:String, prop:String, ?allowedTypes:Array<Dynamic> = null) {
      if (!FunkinLua.lua_Shaders.exists(shader)) return null;
      return Reflect.getProperty(FunkinLua.lua_Shaders.get(shader), prop);
    });

    // Shader stuff
    funk.set("setActorNoShader", function(id:String) {
      FunkinLua.lua_Shaders.remove(id);
      if (LuaUtils.getObjectDirectly(id) != null) LuaUtils.getObjectDirectly(id).shader = null;
      if (LuaUtils.getActorByName(id) != null) LuaUtils.getActorByName(id).shader = null;
    });

    funk.set("initShaderFromSource", function(name:String, classString:String) {
      var shaderClass = Type.resolveClass('shaders.' + classString);
      if (shaderClass != null)
      {
        var shad = Type.createInstance(shaderClass, []);
        FunkinLua.lua_Shaders.set(name, shad);
        Debug.logInfo('created shader: ' + name + ', shader from classString: shaders.' + classString);
      }
      else
        Debug.displayAlert("Unknown Shader: " + classString, "Shader Not Found!");
    });
    funk.set("setActorShader", function(actorStr:String, shaderName:String) {
      final shad = FunkinLua.lua_Shaders.get(shaderName).getShader();
      final split:Array<String> = actorStr.split('.');
      final spr:FlxSprite = split.length > 1 ? LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1]) : LuaUtils.getObjectDirectly(split[0]);

      if (shad != null)
      {
        Debug.logInfo("SHAD NOT NULL");

        if (spr != null) spr.shader = shad;
        else
          Debug.logError('Spr are both null!');
      }
    });

    funk.set("pushShaderToCamera", function(id:String, camera:String) {
      final funnyShader = FunkinLua.lua_Shaders.get(id).getShader();
      LuaUtils.cameraFromString(camera).filters.push(new ShaderFilter(funnyShader));
    });

    funk.set("tweenShaderFloat",
      function(tag:String, shaderName:String, prop:String, value:Dynamic, time:Float, easeStr:String = "linear", startVal:Null<Float> = null) {
        var shad = FunkinLua.lua_Shaders.get(shaderName).getShader();
        var ease = LuaUtils.getTweenEaseByString(easeStr);
        var startValue:Null<Float> = startVal;
        if (startValue == null) startValue = shad.getFloat(prop);

        if (shad != null)
        {
          if (tag != null)
          {
            MusicBeatState.getVariables("Tween").set(tag, FlxTween.num(startValue, value, time,
              {
                ease: ease,
                onComplete: function(twn:FlxTween) {
                  MusicBeatState.getVariables("Tween").remove(tag);
                  if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [tag, prop]);
                },
                onUpdate: function(tween:FlxTween) {
                  var ting = FlxMath.lerp(startValue, value, ease(tween.percent));
                  shad.setFloat(prop, ting);
                }
              }));
          }
          else
          {
            FlxTween.num(startValue, value, time,
              {
                ease: ease,
                onUpdate: function(tween:FlxTween) {
                  var ting = FlxMath.lerp(startValue, value, ease(tween.percent));
                  shad.setFloat(prop, ting);
                }
              });
          }
        }
      });

    funk.set("setCameraShader", function(camStr:String, shaderName:String) {
      var cam = LuaUtils.getCameraByName(camStr);
      var shad = FunkinLua.lua_Shaders.get(shaderName);

      if (cam != null && shad != null)
      {
        cam.shaders.push(new ShaderFilter(Reflect.getProperty(shad, 'shader'))); // use reflect to workaround compiler errors
        cam.shaderNames.push(shaderName);
        cam.cam.filters = cam.shaders;
      }
    });
    funk.set("removeCameraShader", function(camStr:String, shaderName:String) {
      var cam = LuaUtils.getCameraByName(camStr);
      if (cam != null)
      {
        if (cam.shaderNames.contains(shaderName))
        {
          var idx:Int = cam.shaderNames.indexOf(shaderName);
          if (idx != -1)
          {
            cam.shaderNames.remove(cam.shaderNames[idx]);
            cam.shaders.remove(cam.shaders[idx]);
            cam.cam.filters = cam.shaders; // refresh filters
          }
        }
      }
    });

    funk.set("createCustomShader", function(id:String, file:String, glslVersion:String = '120') {
      final funnyCustomShader:CustomShader = new CustomShader(file, glslVersion);
      FunkinLua.lua_Custom_Shaders.set(id, funnyCustomShader);
    });

    funk.set("setActorCustomShader", function(id:String, actor:String) {
      final funnyCustomShader:CustomShader = FunkinLua.lua_Custom_Shaders.get(id);
      if (LuaUtils.getActorByName(actor) != null) LuaUtils.getActorByName(actor).shader = funnyCustomShader;
      if (LuaUtils.getObjectDirectly(actor) != null) LuaUtils.getObjectDirectly(actor).shader = funnyCustomShader;
      return actor;
    });

    funk.set("setActorNoCustomShader", function(actor:String) {
      if (LuaUtils.getActorByName(actor) != null) LuaUtils.getActorByName(actor).shader = null;
      if (LuaUtils.getObjectDirectly(actor) != null) LuaUtils.getObjectDirectly(actor).shader = null;
      return actor;
    });

    funk.set("setCameraCustomShader", function(id:String, camera:String) {
      final funnyCustomShader:CustomShader = FunkinLua.lua_Custom_Shaders.get(id);
      LuaUtils.cameraFromString(camera).setFilters([new ShaderFilter(funnyCustomShader)]);
      return camera;
    });

    funk.set("pushCustomShaderToCamera", function(id:String, camera:String) {
      final funnyCustomShader:CustomShader = FunkinLua.lua_Custom_Shaders.get(id);
      LuaUtils.cameraFromString(camera).filters.push(new ShaderFilter(funnyCustomShader));
      return camera;
    });

    funk.set("setCameraNoCustomShader", function(camera:String) {
      LuaUtils.cameraFromString(camera).setFilters(null);
      return camera;
    });

    funk.set("getCustomShaderProperty", function(id:String, property:String) {
      final funnyCustomShader:CustomShader = FunkinLua.lua_Custom_Shaders.get(id);
      return funnyCustomShader.hget(property);
    });

    funk.set("setCustomShaderProperty", function(id:String, property:String, value:Dynamic) {
      final funnyCustomShader:CustomShader = FunkinLua.lua_Custom_Shaders.get(id);
      funnyCustomShader.hset(property, value);
      return value;
    });

    // Custom shader tween made by me (glowsoony)
    funk.set("doTweenCustomShaderFloat",
      function(tag:String, shaderName:String, prop:String, value:Dynamic, time:Float, easeStr:String = "linear", startVal:Null<Float> = null) {
        var shad:CustomShader = FunkinLua.lua_Custom_Shaders.get(shaderName);
        var ease = LuaUtils.getTweenEaseByString(easeStr);
        var startValue:Null<Float> = startVal;
        if (startValue == null) startValue = shad.hget(prop);

        if (shad != null)
        {
          if (tag != null)
          {
            MusicBeatState.getVariables("Tween").set(tag, FlxTween.num(startValue, value, time,
              {
                ease: ease,
                onComplete: function(twn:FlxTween) {
                  shad.hset(prop, value);
                  MusicBeatState.getVariables("Tween").remove(tag);
                  if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [tag, prop]);
                },
                onUpdate: function(tween:FlxTween) {
                  var ting = FlxMath.lerp(startValue, value, ease(tween.percent));
                  shad.hset(prop, ting);
                }
              }));
          }
          else
          {
            FlxTween.num(startValue, value, time,
              {
                ease: ease,
                onUpdate: function(tween:FlxTween) {
                  var ting = FlxMath.lerp(startValue, value, ease(tween.percent));
                  shad.hset(prop, ting);
                }
              });
          }
        }
      });

    funk.set("doTweenShaderFloat",
      function(tag:String, object:String, floatName:String, newFloat:Float, duration:Float, ease:String, ?swagShader:String = "") {
        #if (!flash && sys)
        var tag = tag;
        var leObj:FlxRuntimeShader = getShader(object, funk, swagShader);
        if (leObj == null)
        {
          leObj = FunkinLua.lua_Shaders.get(object).getShader();
          if (leObj == null) return;
        }

        if (tag != null)
        {
          MusicBeatState.getVariables("Tween").set(tag, FlxTween.num(leObj.getFloat(floatName), newFloat, duration,
            {
              ease: LuaUtils.getTweenEaseByString(ease),
              onComplete: function(twn:FlxTween) {
                MusicBeatState.getVariables("Tween").remove(tag);
                if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [tag, floatName]);
              }
            }, function(num) {
              leObj.setFloat(floatName, num);
            }));
        }
        else
        {
          FlxTween.num(leObj.getFloat(floatName), newFloat, duration, {ease: LuaUtils.getTweenEaseByString(ease)}, function(num) {
            leObj.setFloat(floatName, num);
          });
        }
        #end
      });
  }

  #if (!flash && sys)
  public static function getShader(obj:String, funk:FunkinLua, ?swagShader:String):FlxRuntimeShader
  {
    if (!ClientPrefs.data.shaders) return null;

    final split:Array<String> = obj.split('.');
    final target:Dynamic = split.length > 1 ? LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
      split[split.length - 1]) : LuaUtils.getObjectDirectly(split[0]);

    if (target == null)
    {
      FunkinLua.luaTrace('Error on getting shader: Object $obj not found', false, false, FlxColor.RED);
      return null;
    }

    var shader:Dynamic = null;

    if (Std.isOfType(target, FlxCamera))
    {
      var daFilters = null;
      daFilters = (target.filters != null) ? target.filters : [];

      if (swagShader != null && swagShader.length > 0)
      {
        final arr:Array<String> = funk.runtimeShaders.get(swagShader);

        for (i in 0...daFilters.length)
        {
          final filter:ShaderFilter = daFilters[i];

          if ((filter.shader.glFragmentSource == FlxRuntimeShader.processDataSource(arr[0], 'frgament'))
            || (filter.shader.glFragmentSource == FunkinLua.lua_Shaders.get(swagShader).getShader().glFragmentSource))
          {
            shader = filter.shader;
            break;
          }
        }
      }
      else
        shader = daFilters[0].shader;
    }
    else
      shader = target.shader;

    final returnedShader:FlxRuntimeShader = shader != null ? shader : null;
    return shader;
  }
  #end

  public static function checkFunction(funk:FunkinLua, func:String, obj:String, prop:String, value:Dynamic, ?swagShader:String = ""):Dynamic
  {
    final isArray:Bool = Std.isOfType(value, Array);
    final isFloat:Bool = isArray ? func.contains('Float') : Std.isOfType(value, Float);
    final isBool:Bool = isArray ? func.contains('Bool') : Std.isOfType(value, Bool);
    final isInt:Bool = isArray ? func.contains('Int') : Std.isOfType(value, Int);
    final isSampler2D:Bool = Std.isOfType(value, String);
    final warningNameParts:Array<String> = !func.contains('get') ? func.split("set") : func.split("get");
    final warningName:String = warningNameParts[0] + "Shader" + warningNameParts[1];
    final isSet:Bool = func.startsWith('set');

    #if (!flash && sys)
    final shader:FlxRuntimeShader = getShader(obj, funk, swagShader);
    final foundAObject:Bool = shader != null ? true : FunkinLua.lua_Shaders.exists(obj);
    final isLuaShader:Bool = shader != null ? false : FunkinLua.lua_Shaders.exists(obj);

    if (!foundAObject || (foundAObject && isLuaShader && !Std.isOfType(Reflect.getProperty(FunkinLua.lua_Shaders.get(obj), prop), value)))
    {
      FunkinLua.luaTrace('$warningName: Shader is not FlxRuntimeShader or is null!', false, false, FlxColor.RED);
      return null;
    }

    Debug.logInfo('$warningName, $isLuaShader, $foundAObject');

    if (!isLuaShader)
    {
      if (isArray)
      {
        if (isFloat)
        {
          if (isSet) shader.setFloatArray(prop, value);
          else
            return shader.getFloatArray(prop);
          return null;
        }
        if (isBool)
        {
          if (isSet) shader.setBoolArray(prop, value);
          else
            return shader.getBoolArray(prop);
          return null;
        }
        if (isInt)
        {
          if (isSet) shader.setIntArray(prop, value);
          else
            return shader.getIntArray(prop);
          return null;
        }
        if (isSampler2D)
        {
          var value = Paths.image(value);
          if (value != null && value.bitmap != null)
          {
            shader.setSampler2D(prop, value.bitmap);
            return null;
          }
        }
        return null;
      }
      else
      {
        if (isFloat)
        {
          if (isSet) shader.setFloat(prop, value);
          else
            return shader.getFloat(prop);
          return null;
        }
        if (isBool)
        {
          if (isSet) shader.setBool(prop, value);
          else
            return shader.getBool(prop);
          return null;
        }
        if (isInt)
        {
          if (isSet) shader.setInt(prop, value);
          else
            return shader.getInt(prop);
          return null;
        }
        return null;
      }
      return null;
    }
    else
    {
      if (isSet) Reflect.setProperty(FunkinLua.lua_Shaders.get(obj), prop, value);
      else
        return Reflect.getProperty(FunkinLua.lua_Shaders.get(obj), prop);
      return null;
    }
    return null;
    #else
    FunkinLua.luaTrace('$warningName: Platform unsupported for Runtime Shaders!', false, false, FlxColor.RED);
    return null;
    #end
  }
}
