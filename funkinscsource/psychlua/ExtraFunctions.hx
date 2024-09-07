package psychlua;

import openfl.utils.Assets;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import openfl.utils.Assets;

//
// Things to trivialize some dumb stuff like splitting strings on older Lua
//
class ExtraFunctions
{
  public static function implement(funk:FunkinLua)
  {
    // Keyboard & Gamepads
    funk.set("keyboardJustPressed", function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name.toUpperCase()));
    funk.set("keyboardPressed", function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name.toUpperCase()));
    funk.set("keyboardReleased", function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name.toUpperCase()));

    // Code by DetectiveBaldi
    funk.set("firstKeyJustPressed", function():String {
      var result:String = cast(FlxG.keys.firstJustPressed(), FlxKey).toString();

      if (result == null || result.length < 1)
        result = "NONE"; // "Why?" `FlxKey.toStringMap` does not contain `FlxKey.NONE`, so we need to have a check for it.

      return result;
    });

    funk.set("firstKeyPressed", function():String {
      var result:String = cast(FlxG.keys.firstPressed(), FlxKey).toString();

      if (result == null || result.length < 1) result = "NONE";

      return result;
    });

    funk.set("firstKeyJustReleased", function():String {
      var result:String = cast(FlxG.keys.firstJustReleased(), FlxKey).toString();

      if (result == null || result.length < 1) result = "NONE";

      return result;
    });

    funk.set("anyGamepadJustPressed", function(name:String) {
      return FlxG.gamepads.anyJustPressed(name.toUpperCase());
    });
    funk.set("anyGamepadPressed", function(name:String) {
      return FlxG.gamepads.anyPressed(name.toUpperCase());
    });
    funk.set("anyGamepadReleased", function(name:String) {
      return FlxG.gamepads.anyJustReleased(name.toUpperCase());
    });

    funk.set("gamepadAnalogX", function(id:Int, ?leftStick:Bool = true) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null)
      {
        return 0.0;
      }
      return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
    });
    funk.set("gamepadAnalogY", function(id:Int, ?leftStick:Bool = true) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null)
      {
        return 0.0;
      }
      return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
    });
    funk.set("gamepadJustPressed", function(id:Int, name:String) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null)
      {
        return false;
      }
      return Reflect.getProperty(controller.justPressed, name.toUpperCase()) == true;
    });
    funk.set("gamepadPressed", function(id:Int, name:String) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null)
      {
        return false;
      }
      return Reflect.getProperty(controller.pressed, name.toUpperCase()) == true;
    });
    funk.set("gamepadReleased", function(id:Int, name:String) {
      var controller = FlxG.gamepads.getByID(id);
      if (controller == null)
      {
        return false;
      }
      return Reflect.getProperty(controller.justReleased, name.toUpperCase()) == true;
    });

    funk.set("keyJustPressed", function(name:String = '') {
      name = name.toLowerCase().trim();
      switch (name)
      {
        case 'left':
          return PlayState.instance.controls.NOTE_LEFT_P;
        case 'down':
          return PlayState.instance.controls.NOTE_DOWN_P;
        case 'up':
          return PlayState.instance.controls.NOTE_UP_P;
        case 'right':
          return PlayState.instance.controls.NOTE_RIGHT_P;
        case 'space':
          return PlayState.instance.controls.justPressed('space');
        default:
          return PlayState.instance.controls.justPressed(name);
      }
      return false;
    });
    funk.set("keyPressed", function(name:String = '') {
      name = name.toLowerCase().trim();
      switch (name)
      {
        case 'left':
          return PlayState.instance.controls.NOTE_LEFT;
        case 'down':
          return PlayState.instance.controls.NOTE_DOWN;
        case 'up':
          return PlayState.instance.controls.NOTE_UP;
        case 'right':
          return PlayState.instance.controls.NOTE_RIGHT;
        case 'space':
          return PlayState.instance.controls.pressed('space');
        default:
          return PlayState.instance.controls.pressed(name);
      }
      return false;
    });
    funk.set("keyReleased", function(name:String = '') {
      name = name.toLowerCase().trim();
      switch (name)
      {
        case 'left':
          return PlayState.instance.controls.NOTE_LEFT_R;
        case 'down':
          return PlayState.instance.controls.NOTE_DOWN_R;
        case 'up':
          return PlayState.instance.controls.NOTE_UP_R;
        case 'right':
          return PlayState.instance.controls.NOTE_RIGHT_R;
        case 'space':
          return PlayState.instance.controls.justReleased('space');
        default:
          return PlayState.instance.controls.justReleased(name);
      }
      return false;
    });

    // Code by Rudyrue
    funk.set("isOfType", function(tag:String, cls:String):Bool {
      return Std.isOfType(LuaUtils.getObjectDirectly(tag), Type.resolveClass(cls));
    });

    // Save data management
    funk.set("initSaveData", function(name:String, ?folder:String = 'psychenginemods') {
      var variables = MusicBeatState.getVariables();
      if (!variables.exists(name))
      {
        var save:FlxSave = new FlxSave();
        // folder goes unused for flixel 5 users. @BeastlyGhost
        save.bind(name, CoolUtil.getSavePath() + '/' + folder);
        variables.set('save_$name', save);
        return;
      }
      FunkinLua.luaTrace('initSaveData: Save file already initialized: ' + name);
    });
    funk.set("flushSaveData", function(name:String) {
      var variables = MusicBeatState.getVariables();
      if (variables.exists('save_$name'))
      {
        variables.get('save_$name').flush();
        return;
      }
      FunkinLua.luaTrace('flushSaveData: Save file not initialized: ' + name, false, false, FlxColor.RED);
    });
    funk.set("getDataFromSave", function(name:String, field:String, ?defaultValue:Dynamic = null) {
      var variables = MusicBeatState.getVariables();
      if (variables.exists('save_$name'))
      {
        var saveData = variables.get('save_$name').data;
        if (Reflect.hasField(saveData, field)) return Reflect.field(saveData, field);
        else
          return defaultValue;
      }
      FunkinLua.luaTrace('getDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
      return defaultValue;
    });
    funk.set("setDataFromSave", function(name:String, field:String, value:Dynamic) {
      var variables = MusicBeatState.getVariables();
      if (variables.exists('save_$name'))
      {
        Reflect.setField(variables.get('save_$name').data, field, value);
        return;
      }
      FunkinLua.luaTrace('setDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
    });
    funk.set("eraseSaveData", function(name:String) {
      var variables = MusicBeatState.getVariables();
      if (variables.exists('save_$name'))
      {
        variables.get('save_$name').erase();
        return;
      }
      FunkinLua.luaTrace('eraseSaveData: Save file not initialized: ' + name, false, false, FlxColor.RED);
    });

    // File management
    // Code by DectectiveBaldi
    funk.set("parseJson", function(location:String):{} {
      var parsed:{} = {};
      if (FileSystem.exists(Paths.getPath(location, TEXT)))
      {
        parsed = tjson.TJSON.parse(File.getContent(Paths.getPath(location, TEXT)));
      }
      else
        parsed = tjson.TJSON.parse(location);
      return parsed;
    });
    funk.set("checkFileExists", function(filename:String, ?absolute:Bool = false) {
      #if MODS_ALLOWED
      if (absolute) return FileSystem.exists(filename);

      return FileSystem.exists(Paths.getPath(filename, TEXT));
      #else
      if (absolute) return Assets.exists(filename, TEXT);

      return Assets.exists(Paths.getPath(filename, TEXT));
      #end
    });
    funk.set("saveFile", function(path:String, content:String, ?absolute:Bool = false) {
      try
      {
        #if MODS_ALLOWED
        if (!absolute) File.saveContent(Paths.mods(path), content);
        else
        #end
        File.saveContent(path, content);

        return true;
      }
      catch (e:Dynamic)
      {
        FunkinLua.luaTrace("saveFile: Error trying to save " + path + ": " + e, false, false, FlxColor.RED);
      }
      return false;
    });
    funk.set("deleteFile", function(path:String, ?ignoreModFolders:Bool = false, ?absolute:Bool = false) {
      try
      {
        var lePath:String = path;
        if (!absolute) lePath = Paths.getPath(path, TEXT, !ignoreModFolders);
        if (FileSystem.exists(lePath))
        {
          FileSystem.deleteFile(lePath);
          return true;
        }
      }
      catch (e:Dynamic)
      {
        FunkinLua.luaTrace("deleteFile: Error trying to delete " + path + ": " + e, false, false, FlxColor.RED);
      }
      return false;
    });
    funk.set("getTextFromFile", function(path:String, ?ignoreModFolders:Bool = false) {
      return Paths.getTextFromFile(path, ignoreModFolders);
    });
    funk.set("directoryFileList", function(folder:String) {
      var list:Array<String> = [];
      #if sys
      if (FileSystem.exists(folder))
      {
        for (folder in FileSystem.readDirectory(folder))
        {
          if (!list.contains(folder))
          {
            list.push(folder);
          }
        }
      }
      #end
      return list;
    });

    // String tools
    funk.set("stringStartsWith", function(str:String, start:String) {
      return str.startsWith(start);
    });
    funk.set("stringEndsWith", function(str:String, end:String) {
      return str.endsWith(end);
    });
    funk.set("stringSplit", function(str:String, split:String) {
      return str.split(split);
    });
    funk.set("stringTrim", function(str:String) {
      return str.trim();
    });

    // Randomization
    funk.set("getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
      var excludeArray:Array<String> = exclude.split(',');
      var toExclude:Array<Int> = [];
      for (i in 0...excludeArray.length)
      {
        if (exclude == '') break;
        toExclude.push(Std.parseInt(excludeArray[i].trim()));
      }
      return FlxG.random.int(min, max, toExclude);
    });
    funk.set("getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
      var excludeArray:Array<String> = exclude.split(',');
      var toExclude:Array<Float> = [];
      for (i in 0...excludeArray.length)
      {
        if (exclude == '') break;
        toExclude.push(Std.parseFloat(excludeArray[i].trim()));
      }
      return FlxG.random.float(min, max, toExclude);
    });
    funk.set("getRandomBool", function(chance:Float = 50) {
      return FlxG.random.bool(chance);
    });

    // paths stuff
    funk.set("paths", function(tag:String, text:String) {
      switch (tag)
      {
        case 'font':
          return Paths.font(text);
        case 'xml':
          return Paths.xml(text);
        default:
          return '';
      }
    });

    funk.set("changeTrack", function(track:String, ?prefix:String = null, ?suffix:String = null, ?song:String = null){
      switch (track.toLowerCase())
      {
        case 'music', 'inst', 'instrumental':
          PlayState.instance.changeMusicTrack(prefix, suffix, song);
        case 'vocals', 'voices', 'voice':
          PlayState.instance.changeVocalTrack(prefix, suffix, song);
        case 'opponent-vocals', 'opponent-voices', 'opponent-voice':
          PlayState.instance.changeOpponentVocalTrack(prefix, suffix, song);
      }
    });
  }
}
