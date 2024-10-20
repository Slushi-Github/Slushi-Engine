package psychlua;

class TextFunctions
{
  public static function implement(funk:FunkinLua)
  {
    funk.set("makeLuaText", function(tag:String, ?text:String = '', ?width:Int = 0, ?x:Float = 0, ?y:Float = 0) {
      tag = tag.replace('.', '');
      LuaUtils.findToDestroy(tag);
      final leText:FlxText = new FlxText(x, y, width, text, 16);
      leText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      leText.cameras = [PlayState.instance.camHUD];
      leText.scrollFactor.set();
      leText.borderSize = 2;
      MusicBeatState.getVariables("Text").set(tag, leText);
    });

    funk.set("setTextString", function(tag:String, text:String) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        obj.text = text;
        return true;
      }
      FunkinLua.luaTrace("setTextString: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });
    funk.set("setTextSize", function(tag:String, size:Int) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        obj.size = size;
        return true;
      }
      FunkinLua.luaTrace("setTextSize: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });
    funk.set("setTextWidth", function(tag:String, width:Float) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        obj.fieldWidth = width;
        return true;
      }
      FunkinLua.luaTrace("setTextWidth: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });
    #if (flixel >= "5.4.0")
    funk.set("setTextHeight", function(tag:String, height:Float) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        obj.fieldHeight = height;
        return true;
      }
      FunkinLua.luaTrace("setTextHeight: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });
    #end
    funk.set("setTextAutoSize", function(tag:String, value:Bool) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        obj.autoSize = value;
        return true;
      }
      FunkinLua.luaTrace("setTextAutoSize: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });
    funk.set("setTextBorder", function(tag:String, size:Float, color:String, ?style:String = 'outline') {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        CoolUtil.setTextBorderFromString(obj, (size > 0 ? style : 'none'));
        if (size > 0 && style.toLowerCase() != 'none') obj.borderSize = size;
        obj.borderColor = CoolUtil.colorFromString(color);
        return true;
      }
      FunkinLua.luaTrace("setTextBorder: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });
    funk.set("setTextColor", function(tag:String, color:String) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        obj.color = CoolUtil.colorFromString(color);
        return true;
      }
      FunkinLua.luaTrace("setTextColor: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });
    funk.set("setTextFont", function(tag:String, newFont:String) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        obj.font = Paths.font(newFont);
        return true;
      }
      FunkinLua.luaTrace("setTextFont: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });
    funk.set("setTextItalic", function(tag:String, italic:Bool) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        obj.italic = italic;
        return true;
      }
      FunkinLua.luaTrace("setTextItalic: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });
    funk.set("setTextAlignment", function(tag:String, alignment:String = 'left') {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        obj.alignment = LEFT;
        switch (alignment.trim().toLowerCase())
        {
          case 'right':
            obj.alignment = RIGHT;
          case 'center':
            obj.alignment = CENTER;
          case 'justify':
            obj.alignment = JUSTIFY;
        }
        return true;
      }
      FunkinLua.luaTrace("setTextAlignment: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return false;
    });

    funk.set("getTextString", function(tag:String) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null && obj.text != null)
      {
        return obj.text;
      }
      FunkinLua.luaTrace("getTextString: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return null;
    });
    funk.set("getTextSize", function(tag:String) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        return obj.size;
      }
      FunkinLua.luaTrace("getTextSize: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return -1;
    });
    funk.set("getTextFont", function(tag:String) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        return obj.font;
      }
      FunkinLua.luaTrace("getTextFont: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return null;
    });
    funk.set("getTextWidth", function(tag:String) {
      final split:Array<String> = tag.split('.');
      final obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1])) : LuaUtils.getObjectDirectly(split[0]);
      if (obj != null)
      {
        return obj.fieldWidth;
      }
      FunkinLua.luaTrace("getTextWidth: Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
      return 0;
    });

    funk.set("addLuaText", function(tag:String) {
      if (LuaUtils.getObjectDirectly(tag) != null)
      {
        final shit:FlxText = LuaUtils.getObjectDirectly(tag);
        LuaUtils.getTargetInstance().add(shit);
      }
    });
    funk.set("removeLuaText", function(tag:String, destroy:Bool = true) {
      final variables = MusicBeatState.variableMap(tag);
      if (variables == null) return;
      final text:FlxText = variables.get(tag);
      if (text == null) return;

      LuaUtils.getTargetInstance().remove(text, true);
      if (destroy)
      {
        text.destroy();
        variables.remove(tag);
      }
    });
  }
}
