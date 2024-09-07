package psychlua;

import Type.ValueType;
import haxe.Constraints;
import substates.GameOverSubstate;
import objects.Character;
import lime.app.Application;

//
// Functions that use a high amount of Reflections, which are somewhat CPU intensive
// These functions are held together by duct tape
//
class ReflectionFunctions
{
  static final instanceStr:Dynamic = "##PSYCHLUA_STRINGTOOBJ";

  public static function implement(funk:FunkinLua)
  {
    funk.set("getProperty", function(variable:String, ?allowMaps:Bool = false) {
      try
      {
        var split:Array<String> = variable.split('.');
        if (Stage.instance.swagBacks.exists(split[0]))
        {
          return Stage.instance.getPropertyObject(variable);
        }
        if (split.length > 1) return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split, true, allowMaps), split[split.length - 1], allowMaps);
        return LuaUtils.getVarInArray(LuaUtils.getTargetInstance(), variable, allowMaps);
      }
      catch (e)
      {
        Debug.displayAlert("Unknown 'Get' Variable: " + variable, "Variable Not Found");
        return false;
      }
      return false;
    });
    funk.set("setProperty", function(variable:String, value:Dynamic, allowMaps:Bool = false) {
      try
      {
        var split:Array<String> = variable.split('.');
        if (Stage.instance.swagBacks.exists(split[0]))
        {
          Stage.instance.setPropertyObject(variable, value);
          return value;
        }
        if (split.length > 1)
        {
          LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split, true, allowMaps), split[split.length - 1], value, allowMaps);
          return value;
        }
        LuaUtils.setVarInArray(LuaUtils.getTargetInstance(), variable, value, allowMaps);
        return value;
      }
      catch (e)
      {
        Debug.displayAlert("Unknown 'Set' Variable: " + variable, "Variable Not Found");
      }
      return value;
    });
    funk.set("getPropertyFromClass", function(classVar:String, variable:String, ?allowMaps:Bool = false) {
      classVar = checkForOldClassVars(classVar);

      var myClass:Dynamic = Type.resolveClass(classVar);
      if (myClass == null)
      {
        FunkinLua.luaTrace('getPropertyFromClass: Class $classVar not found', false, false, FlxColor.RED);
        return null;
      }

      var split:Array<String> = variable.split('.');
      if (split.length > 1)
      {
        var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
        for (i in 1...split.length - 1)
          obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

        return LuaUtils.getVarInArray(obj, split[split.length - 1], allowMaps);
      }
      return LuaUtils.getVarInArray(myClass, variable, allowMaps);
    });
    funk.set("setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic, ?allowMaps:Bool = false) {
      classVar = checkForOldClassVars(classVar);

      var myClass:Dynamic = Type.resolveClass(classVar);
      if (myClass == null)
      {
        FunkinLua.luaTrace('setPropertyFromClass: Class $classVar not found', false, false, FlxColor.RED);
        return null;
      }

      var split:Array<String> = variable.split('.');
      if (split.length > 1)
      {
        var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
        for (i in 1...split.length - 1)
          obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

        LuaUtils.setVarInArray(obj, split[split.length - 1], value, allowMaps);
        return value;
      }
      LuaUtils.setVarInArray(myClass, variable, value, allowMaps);
      return value;
    });
    funk.set("getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, ?allowMaps:Bool = false) {
      var split:Array<String> = obj.split('.');
      var realObject:Dynamic = null;
      if (split.length > 1) realObject = LuaUtils.getPropertyLoop(split, true, allowMaps);
      else
        realObject = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);

      if (Std.isOfType(realObject, FlxTypedGroup))
      {
        var result:Dynamic = LuaUtils.getGroupStuff(realObject.members[index], variable, allowMaps);

        if (PlayState.instance.stage.swagGroup.exists(obj)) result = PlayState.instance.stage.swagGroup.get(obj);

        return result;
      }

      var leArray:Dynamic = realObject[index];
      if (leArray != null)
      {
        var result:Dynamic = null;
        if (Type.typeof(variable) == ValueType.TInt) result = leArray[variable];
        else
          result = LuaUtils.getGroupStuff(leArray, variable, allowMaps);
        return result;
      }
      FunkinLua.luaTrace("getPropertyFromGroup: Object #" + index + " from group: " + obj + " doesn't exist!", false, false, FlxColor.RED);
      return null;
    });
    funk.set("setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic, ?allowMaps:Bool = false) {
      var split:Array<String> = obj.split('.');
      var realObject:Dynamic = null;
      if (split.length > 1) realObject = LuaUtils.getPropertyLoop(split, true, allowMaps);
      else
        realObject = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);

      if (Std.isOfType(realObject, FlxTypedGroup))
      {
        if (PlayState.instance.stage.swagGroup.exists(obj)) realObject = PlayState.instance.stage.swagGroup.get(obj);
        LuaUtils.setGroupStuff(realObject.members[index], variable, value, allowMaps);
        return value;
      }

      var leArray:Dynamic = realObject[index];
      if (leArray != null)
      {
        if (Type.typeof(variable) == ValueType.TInt)
        {
          leArray[variable] = value;
          return value;
        }
        LuaUtils.setGroupStuff(leArray, variable, value, allowMaps);
      }
      return value;
    });
    funk.set("removeFromGroup", function(obj:String, index:Int, dontDestroy:Bool = false) {
      var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
      if (Std.isOfType(groupOrArray, FlxTypedGroup))
      {
        if (PlayState.instance.stage.swagGroup.exists(obj)) groupOrArray = PlayState.instance.stage.swagGroup.get(obj);
        var member = groupOrArray.members[index];
        if (!dontDestroy) member.kill();
        groupOrArray.remove(member, true);
        if (!dontDestroy) member.destroy();
        return;
      }
      groupOrArray.remove(groupOrArray[index]);
    });

    funk.set("callMethod", function(funcToRun:String, ?args:Array<Dynamic> = null) {
      return callMethodFromObject(PlayState.instance, funcToRun, parseInstances(args));
    });
    funk.set("callMethodFromClass", function(className:String, funcToRun:String, ?args:Array<Dynamic> = null) {
      return callMethodFromObject(Type.resolveClass(className), funcToRun, parseInstances(args));
    });

    funk.set("createInstance", function(variableToSave:String, className:String, ?args:Array<Dynamic> = null) {
      variableToSave = variableToSave.trim().replace('.', '');
      if (!MusicBeatState.getVariables().exists(variableToSave))
      {
        if (args == null) args = [];
        var myType:Dynamic = Type.resolveClass(className);

        if (myType == null)
        {
          FunkinLua.luaTrace('createInstance: Class $className not found.', false, false, FlxColor.RED);
          return false;
        }

        var obj:Dynamic = Type.createInstance(myType, args);
        if (obj != null) MusicBeatState.getVariables().set(variableToSave, obj);
        else
          FunkinLua.luaTrace('createInstance: Failed to create $variableToSave, arguments are possibly wrong.', false, false, FlxColor.RED);

        return (obj != null);
      }
      else
        FunkinLua.luaTrace('createInstance: Variable $variableToSave is already being used and cannot be replaced!', false, false, FlxColor.RED);
      return false;
    });
    funk.set("addInstance", function(objectName:String, ?inFront:Bool = false) {
      if (MusicBeatState.getVariables().exists(objectName))
      {
        var obj:Dynamic = MusicBeatState.getVariables().get(objectName);
        if (inFront) LuaUtils.getTargetInstance().add(obj);
        else
        {
          if (!PlayState.instance.isDead) PlayState.instance.insert(PlayState.instance.members.indexOf(LuaUtils.getLowestCharacterPlacement()), obj);
          else
            GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), obj);
        }
      }
      else
        FunkinLua.luaTrace('addInstance: Can\'t add what doesn\'t exist~ ($objectName)', false, false, FlxColor.RED);
    });
    // Code by LarryFrosty
    funk.set("removeInstance", function(objectName:String, destroy:Bool = true) {
      if (MusicBeatState.getVariables().exists(objectName))
      {
        var obj:Dynamic = MusicBeatState.getVariables().get(objectName);
        LuaUtils.getTargetInstance().remove(obj, true);
        if (destroy)
        {
          obj.kill();
          obj.destroy();
          MusicBeatState.getVariables().remove(objectName);
        }
      }
      else
        FunkinLua.luaTrace('removeInstance: Variable $objectName does not exist and cannot be removed!');
    });
    funk.set("instanceArg", function(instanceName:String, ?className:String = null) {
      var retStr:String = '$instanceStr::$instanceName';
      if (className != null) retStr += '::$className';
      return retStr;
    });
  }

  static function parseInstances(args:Array<Dynamic>)
  {
    if (args == null) return [];
    for (i in 0...args.length)
    {
      var myArg:String = cast args[i];
      if (myArg != null && myArg.length > instanceStr.length)
      {
        var index:Int = myArg.indexOf('::');
        if (index > -1)
        {
          myArg = myArg.substring(index + 2);
          var lastIndex:Int = myArg.lastIndexOf('::');

          var split:Array<String> = lastIndex > -1 ? myArg.substring(0, lastIndex).split('.') : myArg.split('.');
          args[i] = (lastIndex > -1) ? Type.resolveClass(myArg.substring(lastIndex + 2)) : PlayState.instance;
          for (j in 0...split.length)
          {
            args[i] = LuaUtils.getVarInArray(args[i], split[j].trim());
          }
        }
      }
    }
    return args;
  }

  static function callMethodFromObject(classObj:Dynamic, funcStr:String, args:Array<Dynamic> = null)
  {
    if (args == null) args = [];

    var split:Array<String> = funcStr.split('.');
    var funcToRun:Function = null;
    var obj:Dynamic = classObj;
    if (obj == null)
    {
      return null;
    }

    for (i in 0...split.length)
    {
      obj = LuaUtils.getVarInArray(obj, split[i].trim());
    }

    funcToRun = cast obj;
    return funcToRun != null ? Reflect.callMethod(obj, funcToRun, args) : null;
  }

  static function checkForOldClassVars(classVar:String)
  {
    switch (classVar)
    {
      case "StrumNote", "StrumArrow":
        classVar = "objects.note.StrumArrow";
      case "ClientPrefs":
        classVar = "backend.ClientPrefs";
      case "Conductor":
        classVar = "backend.Conductor";
      case "LoadingState":
        classVar = "states.LoadingState";
      #if LUA_ALLOWED
      case "FunkinLua":
        classVar = "psychlua.FunkinLua";
      #end
      case "PlayState":
        classVar = "states.PlayState";
    }
    return classVar;
  }
}
