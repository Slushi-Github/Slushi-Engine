package shaders;

class RGBPalette extends ShaderBase
{
  public var r(default, set):FlxColor;
  public var g(default, set):FlxColor;
  public var b(default, set):FlxColor;
  public var mult(default, set):Float;

  public var stealthGlow(default, set):Float;
  public var stealthGlowRed(default, set):Float;
  public var stealthGlowGreen(default, set):Float;
  public var stealthGlowBlue(default, set):Float;

  private function set_r(color:FlxColor)
  {
    r = color;
    shader.setFloatArray('r', [color.redFloat, color.greenFloat, color.blueFloat]);
    return color;
  }

  private function set_g(color:FlxColor)
  {
    g = color;
    shader.setFloatArray('g', [color.redFloat, color.greenFloat, color.blueFloat]);
    return color;
  }

  private function set_b(color:FlxColor)
  {
    b = color;
    shader.setFloatArray('b', [color.redFloat, color.greenFloat, color.blueFloat]);
    return color;
  }

  private function set_mult(value:Float)
  {
    mult = FlxMath.bound(value, 0, 1);
    shader.setFloat('mult', mult);
    return mult;
  }

  private function set_stealthGlow(value:Float)
  {
    stealthGlow = value;
    shader.setFloat('_stealthGlow', stealthGlow);
    return value;
  }

  private function set_stealthGlowRed(value:Float)
  {
    stealthGlowRed = value;
    shader.setFloat('_stealthR', stealthGlowRed);
    return value;
  }

  private function set_stealthGlowGreen(value:Float)
  {
    stealthGlowGreen = value;
    shader.setFloat('_stealthG', stealthGlowGreen);
    return value;
  }

  private function set_stealthGlowBlue(value:Float)
  {
    stealthGlowBlue = value;
    shader.setFloat('_stealthB', stealthGlowBlue);
    return value;
  }

  public function new()
  {
    super('RGBPalette');
    r = 0xFFFF0000;
    g = 0xFF00FF00;
    b = 0xFF0000FF;
    mult = 1.0;

    stealthGlow = 0.0;
    stealthGlowRed = 1.0;
    stealthGlowGreen = 1.0;
    stealthGlowBlue = 1.0;
  }
}

// automatic handler for easy usability
class RGBShaderReference
{
  public var r(default, set):FlxColor;
  public var g(default, set):FlxColor;
  public var b(default, set):FlxColor;
  public var mult(default, set):Float;
  public var enabled(default, set):Bool = true;

  public var stealthGlow(default, set):Float;
  public var stealthGlowRed(default, set):Float;
  public var stealthGlowGreen(default, set):Float;
  public var stealthGlowBlue(default, set):Float;

  public var parent:RGBPalette;

  private var _owner:FlxSprite;
  private var _original:RGBPalette;

  public function new(owner:FlxSprite, ref:RGBPalette)
  {
    parent = ref;
    _owner = owner;
    _original = ref;
    owner.shader = ref.shader;

    @:bypassAccessor
    {
      r = parent.r;
      g = parent.g;
      b = parent.b;
      mult = parent.mult;

      stealthGlow = parent.stealthGlow;
      stealthGlowRed = parent.stealthGlowRed;
      stealthGlowGreen = parent.stealthGlowGreen;
      stealthGlowBlue = parent.stealthGlowBlue;
    }
  }

  private function set_r(value:FlxColor)
  {
    if (allowNew && value != _original.r) cloneOriginal();
    return (r = parent.r = value);
  }

  private function set_g(value:FlxColor)
  {
    if (allowNew && value != _original.g) cloneOriginal();
    return (g = parent.g = value);
  }

  private function set_b(value:FlxColor)
  {
    if (allowNew && value != _original.b) cloneOriginal();
    return (b = parent.b = value);
  }

  private function set_mult(value:Float)
  {
    if (allowNew && value != _original.mult) cloneOriginal();
    return (mult = parent.mult = value);
  }

  private function set_enabled(value:Bool)
  {
    _owner.shader = value ? parent.shader : null;
    return (enabled = value);
  }

  private function set_stealthGlow(value:Float)
  {
    if (allowNew && value != _original.stealthGlow) cloneOriginal();
    return (stealthGlow = parent.stealthGlow = value);
  }

  private function set_stealthGlowRed(value:Float)
  {
    if (allowNew && value != _original.stealthGlowRed) cloneOriginal();
    return (stealthGlowRed = parent.stealthGlowRed = value);
  }

  private function set_stealthGlowGreen(value:Float)
  {
    if (allowNew && value != _original.stealthGlowGreen) cloneOriginal();
    return (stealthGlowGreen = parent.stealthGlowGreen = value);
  }

  private function set_stealthGlowBlue(value:Float)
  {
    if (allowNew && value != _original.stealthGlowBlue) cloneOriginal();
    return (stealthGlowBlue = parent.stealthGlowBlue = value);
  }

  public var allowNew = true;

  private function cloneOriginal()
  {
    if (allowNew)
    {
      allowNew = false;
      if (_original != parent) return;

      parent = new RGBPalette();
      parent.r = _original.r;
      parent.g = _original.g;
      parent.b = _original.b;
      parent.mult = _original.mult;

      parent.stealthGlow = _original.stealthGlow;
      parent.stealthGlowRed = _original.stealthGlowRed;
      parent.stealthGlowGreen = _original.stealthGlowGreen;
      parent.stealthGlowBlue = _original.stealthGlowBlue;

      _owner.shader = parent.shader;
    }
  }
}
