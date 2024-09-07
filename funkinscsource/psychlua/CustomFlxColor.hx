package psychlua;

@:publicFields
class CustomFlxColor
{
  public static var instance:CustomFlxColor = new CustomFlxColor();

  public function new() {}

  public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
  public static var WHITE(default, null):Int = FlxColor.WHITE;
  public static var GRAY(default, null):Int = FlxColor.GRAY;
  public static var BLACK(default, null):Int = FlxColor.BLACK;

  public static var GREEN(default, null):Int = FlxColor.GREEN;
  public static var LIME(default, null):Int = FlxColor.LIME;
  public static var YELLOW(default, null):Int = FlxColor.YELLOW;
  public static var ORANGE(default, null):Int = FlxColor.ORANGE;
  public static var RED(default, null):Int = FlxColor.RED;
  public static var PURPLE(default, null):Int = FlxColor.PURPLE;
  public static var BLUE(default, null):Int = FlxColor.BLUE;
  public static var BROWN(default, null):Int = FlxColor.BROWN;
  public static var PINK(default, null):Int = FlxColor.PINK;
  public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
  public static var CYAN(default, null):Int = FlxColor.CYAN;

  public static function fromInt(Value:Int):Int
  {
    return cast FlxColor.fromInt(Value);
  }

  public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
  {
    return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
  }

  public static function getRGB(color:Int):Array<Int>
  {
    var flxcolor:FlxColor = FlxColor.fromInt(color);
    return [flxcolor.red, flxcolor.green, flxcolor.blue, flxcolor.alpha];
  }

  public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
  {
    return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
  }

  public static function getRGBFloat(color:Int):Array<Float>
  {
    var flxcolor:FlxColor = FlxColor.fromInt(color);
    return [flxcolor.redFloat, flxcolor.greenFloat, flxcolor.blueFloat, flxcolor.alphaFloat];
  }

  public static function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
  {
    return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
  }

  public static function getCMYK(color:Int):Array<Float>
  {
    var flxcolor:FlxColor = FlxColor.fromInt(color);
    return [
      flxcolor.cyan,
      flxcolor.magenta,
      flxcolor.yellow,
      flxcolor.black,
      flxcolor.alphaFloat
    ];
  }

  public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
  {
    return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
  }

  public static function getHSB(color:Int):Array<Float>
  {
    var flxcolor:FlxColor = FlxColor.fromInt(color);
    return [flxcolor.hue, flxcolor.saturation, flxcolor.brightness, flxcolor.alphaFloat];
  }

  public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
  {
    return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
  }

  public static function getHSL(color:Int):Array<Float>
  {
    var flxcolor:FlxColor = FlxColor.fromInt(color);
    return [flxcolor.hue, flxcolor.saturation, flxcolor.lightness, flxcolor.alphaFloat];
  }

  public static function fromString(str:String):Int
  {
    return cast FlxColor.fromString(str);
  }

  public static function getHSBColorWheel(Alpha:Int = 255):Array<Int>
  {
    return cast FlxColor.getHSBColorWheel(Alpha);
  }

  public static function interpolate(Color1:Int, Color2:Int, Factor:Float = 0.5):Int
  {
    return cast FlxColor.interpolate(Color1, Color2, Factor);
  }

  public static function gradient(Color1:Int, Color2:Int, Steps:Int, ?Ease:Float->Float):Array<Int>
  {
    return cast FlxColor.gradient(Color1, Color2, Steps, Ease);
  }

  public static function multiply(lhs:Int, rhs:Int):Int
  {
    return cast FlxColor.multiply(lhs, rhs);
  }

  public static function add(lhs:Int, rhs:Int):Int
  {
    return cast FlxColor.add(lhs, rhs);
  }

  public static function subtract(lhs:Int, rhs:Int):Int
  {
    return cast FlxColor.subtract(lhs, rhs);
  }

  public static function getComplementHarmony(color:Int):Int
  {
    return cast FlxColor.fromInt(color).getComplementHarmony();
  }

  public static function getAnalogousHarmony(color:Int, Threshold:Int = 30):CustomHarmony
  {
    return cast FlxColor.fromInt(color).getAnalogousHarmony(Threshold);
  }

  public static function getSplitComplementHarmony(color:Int, Threshold:Int = 30):CustomHarmony
  {
    return cast FlxColor.fromInt(color).getSplitComplementHarmony(Threshold);
  }

  public static function getTriadicHarmony(color:Int):CustomTriadicHarmony
  {
    return cast FlxColor.fromInt(color).getTriadicHarmony();
  }

  public static function to24Bit(color:Int):Int
  {
    return color & 0xffffff;
  }

  public static function toHexString(color:Int, Alpha:Bool = true, Prefix:Bool = true):String
  {
    return cast FlxColor.fromInt(color).toHexString(Alpha, Prefix);
  }

  public static function toWebString(color:Int):String
  {
    return cast FlxColor.fromInt(color).toWebString();
  }

  public static function getColorInfo(color:Int):String
  {
    return cast FlxColor.fromInt(color).getColorInfo();
  }

  public static function getDarkened(color:Int, Factor:Float = 0.2):Int
  {
    return cast FlxColor.fromInt(color).getDarkened(Factor);
  }

  public static function getLightened(color:Int, Factor:Float = 0.2):Int
  {
    return cast FlxColor.fromInt(color).getLightened(Factor);
  }

  public static function getInverted(color:Int):Int
  {
    return cast FlxColor.fromInt(color).getInverted();
  }
}

typedef CustomHarmony =
{
  original:Int,
  warmer:Int,
  colder:Int
}

typedef CustomTriadicHarmony =
{
  color1:Int,
  color2:Int,
  color3:Int
}
