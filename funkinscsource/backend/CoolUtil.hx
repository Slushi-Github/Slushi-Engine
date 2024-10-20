package backend;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import backend.DataType;
import objects.VideoSprite;
import flixel.util.FlxSave;
import flixel.text.FlxText.FlxTextBorderStyle;

// Start placing more stuff for around the engine here!
class CoolUtil
{
  public static final haxeExtensions:Array<String> = ["hx", "hscript", "hsc", "hxs"];

  public static var opponentModeActive:Bool = false;

  inline public static function quantize(f:Float, snap:Float)
  {
    // changed so this actually works lol
    var m:Float = Math.fround(f * snap);
    Debug.logTrace(snap);
    return (m / snap);
  }

  inline public static function curveNumber(input:Float = 1, ?curve:Float = 10):Float
    return Math.sqrt(input) * curve;

  inline public static function clamp(value:Float, min:Float, max:Float):Float
    return Math.max(min, Math.min(max, value));

  inline public static function coolLerp(base:Float, target:Float, ratio:Float):Float
    return base + cameraLerp(ratio) * (target - base);

  inline public static function cameraLerp(lerp:Float):Float
    return lerp * (FlxG.elapsed / (1 / 60));

  inline public static function capitalize(text:String)
    return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

  public static function resetSprite(spr:FlxSprite, x:Float, y:Float)
  {
    spr.reset(x, y);
    spr.alpha = 1;
    spr.visible = true;
    spr.active = true;
    // spr.antialiasing = FlxSprite.defaultAntialiasing;
    // spr.rotOffset.set();
  }

  public static function resetSpriteAttributes(spr:FlxSprite)
  {
    spr.scale.x = 1;
    spr.scale.y = 1;
    spr.offset.x = 0;
    spr.offset.y = 0;
    spr.shader = null;
    spr.alpha = 1;
    spr.visible = true;
    spr.flipX = false;
    spr.flipY = false;

    spr.centerOrigin();
  }

  /**
   * Add several zeros at the beginning of a string, so that `2` becomes `02`.
   * @param str String to add zeros
   * @param num The length required
   */
  public static inline function addZeros(str:String, num:Int)
  {
    while (str.length < num)
      str = '0${str}';
    return str;
  }

  /**
   * Add several zeros at the end of a string, so that `2` becomes `20`, useful for ms.
   * @param str String to add zeros
   * @param num The length required
   */
  public static inline function addEndZeros(str:String, num:Int)
  {
    while (str.length < num)
      str = '${str}0';
    return str;
  }

  inline public static function boundTo(value:Float, min:Float, max:Float):Float
  {
    return Math.max(min, Math.min(max, value));
  }

  public static function coolTextFile2(path:String):Array<String>
  {
    var daList:Array<String> = File.getContent(path).trim().split('\n');

    for (i in 0...daList.length)
    {
      daList[i] = daList[i].trim();
    }

    return daList;
  }

  inline public static function coolTextFile(path:String):Array<String>
  {
    var daList:String = null;
    #if (sys && MODS_ALLOWED)
    if (FileSystem.exists(path)) daList = File.getContent(path);
    #else
    if (Assets.exists(path)) daList = Assets.getText(path);
    #end
    return daList != null ? listFromString(daList) : [];
  }

  inline public static function colorFromString(color:String):FlxColor
  {
    var hideChars = ~/[\t\n\r]/;
    var color:String = hideChars.split(color).join('').trim();
    var alpha:Float = 1;

    if (color.startsWith('0x'))
    {
      // alpha stuff
      if (color.length == 10)
      {
        var alphaHex:String = color.substr(2, 2);
        alpha = Std.parseInt("0x" + alphaHex) / 255.0;
      }

      color = color.substring(color.length - 6);
    }

    var colorNum:Null<FlxColor> = FlxColor.fromString(color);
    if (colorNum == null) colorNum = FlxColor.fromString('#$color');
    colorNum.alphaFloat = alpha;

    return colorNum != null ? colorNum : FlxColor.WHITE;
  }

  inline public static function listFromString(string:String):Array<String>
  {
    var daList:Array<String> = [];
    daList = string.trim().split('\n');

    for (i in 0...daList.length)
      daList[i] = daList[i].trim();

    return daList;
  }

  public static function floorDecimal(value:Float, decimals:Int):Float
  {
    if (decimals < 1) return Math.floor(value);

    var tempMult:Float = 1;
    for (i in 0...decimals)
      tempMult *= 10;

    var newValue:Float = Math.floor(value * tempMult);
    return newValue / tempMult;
  }

  inline public static function dominantColor(sprite:FlxSprite):Int
  {
    var countByColor:Map<Int, Int> = [];
    for (col in 0...sprite.frameWidth)
    {
      for (row in 0...sprite.frameHeight)
      {
        var colorOfThisPixel:FlxColor = sprite.pixels.getPixel32(col, row);
        if (colorOfThisPixel.alphaFloat > 0.05)
        {
          colorOfThisPixel = FlxColor.fromRGB(colorOfThisPixel.red, colorOfThisPixel.green, colorOfThisPixel.blue, 255);
          var count:Int = countByColor.exists(colorOfThisPixel) ? countByColor[colorOfThisPixel] : 0;
          countByColor[colorOfThisPixel] = count + 1;
        }
      }
    }

    var maxCount = 0;
    var maxKey:Int = 0; // after the loop this will store the max color
    countByColor[FlxColor.BLACK] = 0;
    for (key => count in countByColor)
    {
      if (count >= maxCount)
      {
        maxCount = count;
        maxKey = key;
      }
    }
    countByColor = [];
    return maxKey;
  }

  inline public static function numberArray(max:Int, ?min:Int = 0):Array<Int>
  {
    return [for (i in min...max + 1) i];
  }

  inline public static function browserLoad(site:String)
  {
    return utils.WindowUtil.openURL(site);
  }

  inline public static function openFolder(folder:String, absolute:Bool = false)
  {
    #if sys
    if (!absolute) folder = Sys.getCwd() + '$folder';

    folder = folder.replace('/', '\\');
    if (folder.endsWith('/')) folder.substr(0, folder.length - 1);

    #if linux
    var command:String = '/usr/bin/xdg-open';
    #else
    var command:String = 'explorer.exe';
    #end
    Sys.command(command, [folder]);
    Debug.logInfo('$command $folder');
    #else
    FlxG.error("Platform is not supported for CoolUtil.openFolder");
    #end
  }

  /**
    Helper Function to Fix Save Files for Flixel 5
    -- EDIT: [November 29, 2023] --
    this function is used to get the save path, period.
    since newer flixel versions are being enforced anyways.
    @crowplexus
  **/
  @:access(flixel.util.FlxSave.validate)
  inline public static function getSavePath():String
  {
    final company:String = FlxG.stage.application.meta.get('company');
    return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
  }

  public static function setTextBorderFromString(text:FlxText, border:String)
  {
    text.borderStyle = returnTextBorderFromString(border.toLowerCase().trim());
  }

  public static function returnTextBorderFromString(border:String):FlxTextBorderStyle
  {
    switch (border.toLowerCase().trim())
    {
      case 'shadow':
        return SHADOW;
      case 'outline':
        return OUTLINE;
      case 'outline_fast', 'outlinefast':
        return OUTLINE_FAST;
      default:
        return NONE;
    }
    return NONE;
  }

  public static function returnColor(?str:String = ''):FlxColor
  {
    switch (str.toLowerCase())
    {
      case "black":
        return FlxColor.BLACK;
      case "white":
        return FlxColor.WHITE;
      case "blue":
        return FlxColor.BLUE;
      case "brown":
        return FlxColor.BROWN;
      case "cyan":
        return FlxColor.CYAN;
      case "yellow":
        return FlxColor.YELLOW;
      case "gray":
        return FlxColor.GRAY;
      case "green":
        return FlxColor.GREEN;
      case "lime":
        return FlxColor.LIME;
      case "magenta":
        return FlxColor.MAGENTA;
      case "orange":
        return FlxColor.ORANGE;
      case "pink":
        return FlxColor.PINK;
      case "purple":
        return FlxColor.PURPLE;
      case "red":
        return FlxColor.RED;
      case "transparent" | 'trans':
        return FlxColor.TRANSPARENT;
    }
    return FlxColor.WHITE;
  }

  public static inline function exactSetGraphicSize(obj:Dynamic, width:Float, height:Float) // ACTULLY WORKS LMAO -lunar
  {
    obj.scale.set(Math.abs(((obj.width - width) / obj.width) - 1), Math.abs(((obj.height - height) / obj.height) - 1));
  }

  /**
   * Returns a string representation of a size, following this format: `1.02 GB`, `134.00 MB`
   * @param size Size to convert ot string
   * @return String Result string representation
   */
  public static function getSizeString(size:Float):String
  {
    var labels = [" B", " KB", " MB", " GB", " TB"];
    var rSize:Float = size;
    var label:Int = 0;
    while (rSize > 1024 && label < labels.length - 1)
    {
      label++;
      rSize /= 1024;
    }
    return '${Std.int(rSize) + "." + addZeros(Std.string(Std.int((rSize % 1) * 100)), 2)}${labels[label]}';
  }

  public static function getDataTypeStringArray():Array<String>
  {
    var enums:Array<DataType> = DataType.createAll();
    var strs:Array<String> = [];

    for (_enum in enums)
    {
      strs[enums.indexOf(_enum)] = Std.string(_enum);
    }
    return strs;
  }

  /**
   * Gets the macro class created by hscript-improved for an abstract / enum
   */
  @:noUsing public static inline function getMacroAbstractClass(className:String)
  {
    return Type.resolveClass('${className}_HSC');
  }

  /**
   * Sprite getting set to this instead of the original.
   */
  public static var videoSprite:VideoSprite = null;

  /**
   * Allows creating a video outside playstate.
   */
  public static function startVideo(name:String, type:String = 'mp4', forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true,
      callBack:Void->Void, onSkip:Void->Void)
  {
    #if (VIDEOS_ALLOWED && hxvlc)
    try
    {
      var foundFile:Bool = false;
      var fileName:String = Paths.video(name, type);
      #if sys
      if (FileSystem.exists(fileName))
      #else
      if (OpenFlAssets.exists(fileName))
      #end
      foundFile = true;

      if (foundFile)
      {
        var cutscene:VideoSprite = new VideoSprite(fileName, forMidSong, canSkip, loop);
        if (!forMidSong)
        {
          // Finish callback
          cutscene.finishCallback = callBack;

          // Skip callback
          cutscene.onSkip = onSkip;
        }

        if (playOnLoad) cutscene.videoSprite.play();
        return cutscene;
      }
      else
        FlxG.log.error("Video not found: " + fileName);
    }
    #else
    FlxG.log.warn('Platform not supported!');
    #end
    return null;
  }

  /**
   * Borrowed from CNE (CodenameEngine)
   * Tries to get a color from a `Dynamic` variable.
   * @param c `Dynamic` color.
   * @return The result color, or `null` if invalid.
   */
  public static function getColorFromDynamic(c:Dynamic):Null<FlxColor>
  {
    // -1
    if (c is Int) return c;

    // -1.0
    if (c is Float) return Std.int(c);

    // "#FFFFFF"
    if (c is String) return FlxColor.fromString(c);

    // [255, 255, 255]
    if (c is Array)
    {
      var r:Int = 0;
      var g:Int = 0;
      var b:Int = 0;
      var a:Int = 255;
      var array:Array<Dynamic> = cast c;
      for (k => e in array)
      {
        if (e is Int || e is Float)
        {
          switch (k)
          {
            case 0:
              r = Std.int(e);
            case 1:
              g = Std.int(e);
            case 2:
              b = Std.int(e);
            case 3:
              a = Std.int(e);
          }
        }
      }
      return FlxColor.fromRGB(r, g, b, a);
    }
    return null;
  }

  /**
   * A function to blend colors.
   * @param bgColor main color.
   * @param ovColor overlay color.
   * @return Int
   */
  public static function blendColors(bgColor:Int, ovColor:Int):Int
  {
    var a_bg = (bgColor >> 24) & 0xFF;
    var r_bg = (bgColor >> 16) & 0xFF;
    var g_bg = (bgColor >> 8) & 0xFF;
    var b_bg = bgColor & 0xFF;

    var a_ov = (ovColor >> 24) & 0xFF;
    var r_ov = (ovColor >> 16) & 0xFF;
    var g_ov = (ovColor >> 8) & 0xFF;
    var b_ov = ovColor & 0xFF;

    var alpha = a_ov + (a_bg * (255 - a_ov) / 255);
    var red = r_ov * (a_ov / 255) + r_bg * (1 - (a_ov / 255));
    var green = g_ov * (a_ov / 255) + g_bg * (1 - (a_ov / 255));
    var blue = b_ov * (a_ov / 255) + b_bg * (1 - (a_ov / 255));

    return (Std.int(alpha) << 24) | (Std.int(red) << 16) | (Std.int(green) << 8) | Std.int(blue);
  }

  public static function recursivelyReadFolders(path:String, ?erasePath:Bool = true)
  {
    var ret:Array<String> = [];
    for (i in FileSystem.readDirectory(path))
    {
      returnFileName(i, ret, path);
    }
    if (erasePath)
    {
      path += '/';
      for (i in 0...ret.length)
      {
        ret[i] = ret[i].replace(path, '');
      }
    }
    return ret;
  }

  static function returnFileName(path:String, toAdd:Array<String>, full:String)
  {
    if (FileSystem.isDirectory(full + '/' + path))
    {
      for (i in FileSystem.readDirectory(full + '/' + path))
        returnFileName(i, toAdd, full + '/' + path);
    }
    else
      toAdd.push((full + '/' + path).replace('.json', ''));
  }
}
