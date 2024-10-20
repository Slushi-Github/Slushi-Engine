package psychlua;

import flixel.group.*; // Need all group items lol.
import flixel.FlxBasic;
import group.FlxSkewedSpriteGroup;

/**
 * Custom class made by me! -glow / editied and revised because of Ryiuu
 */
class GroupFunctions
{
  public static function implement(funk:FunkinLua)
  {
    funk.set("makeLuaSpriteGroup", function(tag:String, ?x:Float = 0, ?y:Float = 0, ?maxSize:Int = 0) {
      try
      {
        tag = tag.replace('.', '');
        LuaUtils.findToDestroy(tag);
        var group:FlxSpriteGroup = new FlxSpriteGroup(x, y, maxSize);
        if (funk.isStageLua && !funk.preloading) Stage.instance.swagBacks.set(tag, group);
        else
          MusicBeatState.getVariables("Group").set(tag, group);
      }
      catch (e:haxe.Exception)
      {
        Debug.displayAlert(e.message, 'makeLuaSpriteGroup ERROR!');
      }
    });

    funk.set("makeLuaSkewedSpriteGroup", function(tag:String, ?x:Float = 0, ?y:Float = 0, ?maxSize:Int = 0) {
      try
      {
        tag = tag.replace('.', '');
        LuaUtils.findToDestroy(tag);
        var group:FlxSkewedSpriteGroup = new FlxSkewedSpriteGroup(x, y, maxSize);
        if (funk.isStageLua && !funk.preloading) Stage.instance.swagBacks.set(tag, group);
        else
          MusicBeatState.getVariables("Group").set(tag, group);
      }
      catch (e:haxe.Exception)
      {
        Debug.displayAlert(e.message, 'makeLuaSkewedSpriteGroup ERROR!');
      }
    });

    funk.set('groupInsertSprite', function(tag:String, obj:String, pos:Int = 0, ?removeFromGroup:Bool = true) {
      try
      {
        var group:FlxSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        if (group == null)
        {
          FunkinLua.luaTrace("Group is null, can't dont any actions!, returning this trace!");
          return false;
        }

        var split:Array<String> = obj.split('.');
        var object:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (object != null)
        {
          var newObject:FlxSprite = cast(object, FlxSprite);
          if (newObject != null)
          {
            if (removeFromGroup) group.remove(newObject, true);
            group.insert(pos, newObject);
            return true;
          }
        }
        return false;
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('groupInsert Error ! ${e.message}');
        return false;
      }
    });

    funk.set('groupInsertSkewedSprite', function(tag:String, obj:String, pos:Int = 0, ?removeFromGroup:Bool = true) {
      try
      {
        var group:FlxSkewedSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        if (group == null)
        {
          FunkinLua.luaTrace("Group is null, can't dont any actions!, returning this trace!");
          return false;
        }

        var split:Array<String> = obj.split('.');
        var object:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (object != null)
        {
          var newObject:FlxSkewed = cast(object, FlxSkewed);
          if (newObject != null)
          {
            if (removeFromGroup) group.remove(newObject, true);
            group.insert(pos, newObject);
            return true;
          }
        }
        return false;
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('groupInsertSkewedSprite Error ! ${e.message}');
        return false;
      }
    });

    funk.set('groupRemoveSprite', function(tag:String, obj:String, splice:Bool = false) {
      try
      {
        var group:FlxSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        if (group == null)
        {
          FunkinLua.luaTrace("Group is null, can't dont any actions!, returning this trace!");
          return false;
        }

        var split:Array<String> = obj.split('.');
        var object:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (object != null)
        {
          var newObject:FlxSprite = cast(object, FlxSprite);
          if (newObject != null)
          {
            group.remove(newObject, splice);
            return true;
          }
        }
        return false;
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('groupRemoveSprite Error ! ${e.message}');
        return false;
      }
    });

    funk.set('groupRemoveSkewedSprite', function(tag:String, obj:String, splice:Bool = false) {
      try
      {
        var group:FlxSkewedSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        if (group == null)
        {
          FunkinLua.luaTrace("Group is null, can't dont any actions!, returning this trace!");
          return false;
        }

        var split:Array<String> = obj.split('.');
        var object:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (object != null)
        {
          var newObject:FlxSkewed = cast(object, FlxSkewed);
          if (newObject != null)
          {
            group.remove(newObject, splice);
            return true;
          }
        }
        return false;
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('groupRemoveSkewedSprite Error ! ${e.message}');
        return false;
      }
    });

    funk.set('groupAddSprite', function(tag:String, obj:String) {
      try
      {
        var group:FlxSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        if (group == null)
        {
          FunkinLua.luaTrace("Group is null, can't dont any actions!, returning this trace!");
          return false;
        }

        var split:Array<String> = obj.split('.');
        var object:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (object != null)
        {
          var newObject:FlxSprite = cast(object, FlxSprite);
          if (newObject != null)
          {
            group.add(newObject);
            return true;
          }
        }
        return false;
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('groupAddSprite Error ! ${e.message + e.stack}');
        return false;
      }
    });

    funk.set('groupAddSkewedSprite', function(tag:String, obj:String) {
      try
      {
        var group:FlxSkewedSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        if (group == null)
        {
          FunkinLua.luaTrace("Group is null, can't dont any actions!, returning this trace!");
          return false;
        }

        var split:Array<String> = obj.split('.');
        var object:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
        if (split.length > 1)
        {
          object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
        }

        if (object != null)
        {
          var newObject:FlxSkewed = cast(object, FlxSkewed);
          if (newObject != null)
          {
            group.add(newObject);
            return true;
          }
        }
        return false;
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('groupAddSkewedSprite Error ! ${e.message + e.stack}');
        return false;
      }
    });

    funk.set('setSpriteGroupCameras', function(tag:String, cams:Array<String> = null) {
      try
      {
        var group:FlxSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        var cameras:Array<FlxCamera> = [];
        for (i in 0...cams.length)
        {
          cameras.push(LuaUtils.cameraFromString(cams[i]));
        }
        if (group != null && cameras != null) group.cameras = cameras;
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('setGroupCams Error ! ${e.message + e.stack}');
      }
    });

    funk.set('setSkewedSpriteGroupCameras', function(tag:String, cams:Array<String> = null) {
      try
      {
        var group:FlxSkewedSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        var cameras:Array<FlxCamera> = [];
        for (i in 0...cams.length)
        {
          cameras.push(LuaUtils.cameraFromString(cams[i]));
        }
        if (group != null && cameras != null) group.cameras = cameras;
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('setSkewedGroupCams Error ! ${e.message + e.stack}');
      }
    });

    funk.set('setSpriteGroupCamera', function(tag:String, cam:String = null) {
      try
      {
        var group:FlxSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        if (group != null && cam != null) group.camera = LuaUtils.cameraFromString(cam);
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('setGroupCam Error ! ${e.message + e.stack}');
      }
    });

    funk.set('setSkewedSpriteGroupCamera', function(tag:String, cam:String = null) {
      try
      {
        var group:FlxSkewedSpriteGroup = MusicBeatState.variableMap(tag).get(tag);
        if (group != null && cam != null) group.camera = LuaUtils.cameraFromString(cam);
      }
      catch (e:haxe.Exception)
      {
        Debug.logError('setSkewedGroupCam Error ! ${e.message + e.stack}');
      }
    });
  }
}
