package shaders;

// STOLEN FROM HAXEFLIXEL DEMO LOL
// Am I even allowed to use this?
// Blantados code! Thanks!!
import flixel.math.FlxAngle;
import flixel.addons.display.FlxRuntimeShader;
import openfl.Lib;

// Effects A-Z WITH SHADERS -glow
class AngelEffect extends ShaderBase
{
  @:isVar
  public var strength(get, set):Float = 0;

  function get_strength()
  {
    return shader.getFloat('strength');
  }

  function set_strength(v:Float)
  {
    shader.setFloatArray('stronk', [v, v]);
    return v;
  }

  @:isVar
  public var pixelSize(get, set):Float = 1;

  function get_pixelSize()
  {
    return (shader.getFloatArray('pixel')[0] + shader.getFloatArray('pixel')[1]) / 2;
  }

  function set_pixelSize(v:Float)
  {
    shader.setFloatArray('pixel', [v, v]);
    return v;
  }

  public function new()
  {
    super('Angel');
    shader.setFloat('iTime', 0.0);
    strength = 0;
    pixelSize = 1;
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class BarrelBlurEffect extends ShaderBase
{
  public var barrel(default, set):Float = 2.0;
  public var zoom(default, set):Float = 5.0;
  public var doChroma(default, set):Bool = false;

  public var angle(default, set):Float = 0.0;
  public var x(default, set):Float = 0.0;
  public var y(default, set):Float = 0.0;

  public function new():Void
  {
    super('BarrelBlur');
    shader.setFloat('barrel', barrel);
    shader.setFloat('zoom', zoom);
    shader.setBool('doChroma', doChroma);
    shader.setFloat('angle', angle);
    shader.setFloat('iTime', 0.0);
    shader.setFloat('x', x);
    shader.setFloat('y', y);
  }

  function set_barrel(value:Float):Float
  {
    barrel = value;
    shader.setFloat('barrel', value);
    return value;
  }

  function set_zoom(value:Float):Float
  {
    zoom = value;
    shader.setFloat('zoom', zoom);
    return value;
  }

  function set_doChroma(value:Bool):Bool
  {
    doChroma = value;
    shader.setBool('doChroma', value);
    return value;
  }

  function set_angle(value:Float):Float
  {
    angle = value;
    shader.setFloat('angle', angle);
    return value;
  }

  function set_x(value:Float):Float
  {
    x = value;
    shader.setFloat('x', x);
    return value;
  }

  function set_y(value:Float):Float
  {
    y = value;
    shader.setFloat('y', y);
    return value;
  }

  override public function update(elapsed:Float):Void
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class BetterBlurEffect extends ShaderBase
{
  public var loops(default, set):Float = 16.0;
  public var quality(default, set):Float = 5.0;
  public var strength(default, set):Float = 0.0;

  public function new():Void
  {
    super('BetterBlur');
    shader.setFloat('loops', 0);
    shader.setFloat('quality', 0);
    shader.setFloat('strength', 0);
  }

  function set_loops(value:Float):Float
  {
    loops = value;
    shader.setFloat('loops', loops);
    return value;
  }

  function set_quality(value:Float):Float
  {
    quality = value;
    shader.setFloat('quality', quality);
    return value;
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return value;
  }
}

class BloomBetterEffect extends ShaderBase
{
  public var effect(default, set):Float = 5;
  public var strength(default, set):Float = 0.2;
  public var contrast(default, set):Float = 1.0;
  public var brightness(default, set):Float = 0.0;

  public function new()
  {
    super('BloomBetter');

    shader.setFloat('effect', effect);
    shader.setFloat('strength', strength);
    shader.setFloatArray('iResolution', [FlxG.width, FlxG.height]);
    shader.setFloat('contrast', contrast);
    shader.setFloat('brightness', brightness);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloatArray('iResolution', [FlxG.width, FlxG.height]);
  }

  function set_effect(value:Float):Float
  {
    effect = value;
    shader.setFloat('effect', effect);
    return value;
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return value;
  }

  function set_contrast(value:Float):Float
  {
    contrast = value;
    shader.setFloat('contrast', contrast);
    return value;
  }

  function set_brightness(value:Float):Float
  {
    brightness = value;
    shader.setFloat('brightness', brightness);
    return value;
  }
}

class BlurEffect extends ShaderBase
{
  public var strength(default, set):Float = 0.0;
  public var strengthY(default, set):Float = 0.0;
  public var vertical:Bool = false;

  public function new():Void
  {
    super('Blur');
    shader.setFloat('strength', 0);
    shader.setFloat('strengthY', 0);
    // shader.vertical.value[0] = vertical;
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return strength;
  }

  function set_strengthY(value:Float):Float
  {
    strengthY = value;
    shader.setFloat('strengthY', strengthY);
    return strengthY;
  }
}

class ChromAbEffect extends ShaderBase
{
  public var strength(default, set):Float = 0.0;

  public function new():Void
  {
    super('ChromAb');
    shader.setFloat('strength', 0);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', value);
    return value;
  }
}

class ChromAbBlueSwapEffect extends ShaderBase
{
  public var strength(default, set):Float = 0.0;

  public function new():Void
  {
    super('ChromAbBlueSwap');
    shader.setFloat('strength', 0);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return strength;
  }
}

class ChromaticAberrationEffect extends ShaderBase
{
  public var rOffset(default, set):Float = 0.00;
  public var gOffset(default, set):Float = 0.00;
  public var bOffset(default, set):Float = 0.00;

  public function new()
  {
    super('ChromaticAberration');
    shader.setFloat('rOffset', rOffset);
    shader.setFloat('gOffset', gOffset * -1);
    shader.setFloat('bOffset', bOffset);
  }

  public function set_rOffset(roff:Float):Float
  {
    rOffset = roff;
    shader.setFloat('rOffset', rOffset);
    return roff;
  }

  public function set_gOffset(goff:Float):Float // RECOMMAND TO NOT USE CHANGE VALUE!
  {
    gOffset = goff;
    shader.setFloat('gOffset', gOffset * -1);
    return goff;
  }

  public function set_bOffset(boff:Float):Float
  {
    bOffset = boff;
    shader.setFloat('bOffset', bOffset);
    return boff;
  }

  public function setChrome(chromeOffset:Float):Void
  {
    shader.setFloat('rOffset', chromeOffset);
    shader.setFloat('gOffset', 0);
    shader.setFloat('bOffset', chromeOffset * -1);
  }
}

// More changed shaders added!
class ChromaticPincushEffect extends ShaderBase // No Vars Used!
{
  public function new()
  {
    super('ChromaticPincuh');
  }
}

class ChromaticRadialBlurEffect extends ShaderBase
{
  public function new()
  {
    super('ChromaticRadialBlur');
  }
}

class ColorFillEffect extends ShaderBase
{
  public var red(default, set):Float = 0.0;
  public var green(default, set):Float = 0.0;
  public var blue(default, set):Float = 0.0;
  public var fade(default, set):Float = 1.0;

  public function new():Void
  {
    super('ColorFill');
    shader.setFloat('red', red);
    shader.setFloat('green', green);
    shader.setFloat('blue', blue);
    shader.setFloat('fade', fade);
  }

  function set_red(value:Float):Float
  {
    red = value;
    shader.setFloat('red', red);
    return red;
  }

  function set_green(value:Float):Float
  {
    green = value;
    shader.setFloat('green', green);
    return green;
  }

  function set_blue(value:Float):Float
  {
    blue = value;
    shader.setFloat('blue', blue);
    return blue;
  }

  function set_fade(value:Float):Float
  {
    fade = value;
    shader.setFloat('fade', fade);
    return fade;
  }
}

class ColorOverrideEffect extends ShaderBase
{
  public var red(default, set):Float = 0.0;
  public var green(default, set):Float = 0.0;
  public var blue(default, set):Float = 0.0;

  public function new():Void
  {
    super('ColorOverride');
    shader.setFloat('red', red);
    shader.setFloat('green', green);
    shader.setFloat('blue', blue);
  }

  function set_red(value:Float):Float
  {
    red = value;
    shader.setFloat('red', red);
    return red;
  }

  function set_green(value:Float):Float
  {
    green = value;
    shader.setFloat('green', green);
    return green;
  }

  function set_blue(value:Float):Float
  {
    blue = value;
    shader.setFloat('blue', blue);
    return blue;
  }
}

// same thingy just copied so i can use it in scripts

/**
 * Cool Shader by ShadowMario that changes RGB based on HSV.
 */
class ColorSwapEffect extends ShaderBase
{
  public var hue(default, set):Float = 0;
  public var saturation(default, set):Float = 0;
  public var brightness(default, set):Float = 0;
  public var awesomeOutline(default, set):Bool = false;

  private function set_hue(value:Float)
  {
    hue = value;
    shader.setFloatArray('uTime', [hue, saturation, value]);
    return hue;
  }

  private function set_saturation(value:Float)
  {
    saturation = value;
    shader.setFloatArray('uTime', [hue, saturation, value]);
    return saturation;
  }

  private function set_brightness(value:Float)
  {
    brightness = value;
    shader.setFloatArray('uTime', [hue, saturation, value]);
    return brightness;
  }

  private function set_awesomeOutline(value:Bool)
  {
    awesomeOutline = value;
    shader.setBool('awesomeOutline', awesomeOutline);
    return awesomeOutline;
  }

  public function new()
  {
    super('ColorSwap');
    shader.setFloatArray('uTime', [0, 0, 0]);
    shader.setBool('awesomeOutline', false);
  }
}

class ColorWhiteFrameEffect extends ShaderBase
{
  public var amount(default, set):Float = 0.0;

  public function new()
  {
    super('ColorWhiteFrame');
    shader.setFloat('amount', amount);
  }

  function set_amount(a:Float):Float
  {
    amount = a;
    shader.setFloat('amount', amount);
    return a;
  }
}

class ColorWaveEffect extends ShaderBase
{
  public function new()
  {
    super('ColorWave');
    shader.setFloat('iTime', 0);
  }

  override public function update(elapsed:Float):Void
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class DesaturateEffect extends ShaderBase
{
  public function new()
  {
    super('Desaturate');
    shader.setFloat('iTime', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class DesaturationRGBEffect extends ShaderBase
{
  public var desaturationAmount(default, set):Float = 0.0;
  public var distortionTime(default, set):Float = 0.0;
  public var amplitude(default, set):Float = -0.1;
  public var frequency(default, set):Float = 8.0;

  public function new()
  {
    super('DesaturationRGB');
    shader.setFloat('desaturationAmount', desaturationAmount);
    shader.setFloat('distortionTime', distortionTime);
    shader.setFloat('amplitude', amplitude);
    shader.setFloat('frequency', frequency);
  }

  public function set_desaturationAmount(da:Float):Float
  {
    desaturationAmount = da;
    shader.setFloat('desaturationAmount', desaturationAmount);
    return da;
  }

  public function set_distortionTime(dt:Float):Float
  {
    distortionTime = dt;
    shader.setFloat('distortionTime', distortionTime);
    return dt;
  }

  public function set_amplitude(a:Float):Float
  {
    amplitude = a;
    shader.setFloat('amplitude', amplitude);
    return a;
  }

  public function set_frequency(f:Float):Float
  {
    frequency = f;
    shader.setFloat('frequency', frequency);
    return f;
  }
}

class DropShadow extends ShaderBase
{
  public var alpha(default, set):Float = 0;
  public var disx(default, set):Float = 0;
  public var disy(default, set):Float = 0;

  public var inner(default, set):Bool = false;
  public var inverted(default, set):Bool = false;

  public function new()
  {
    super('DropShadow');
    shader.setFloat('_alpha', alpha);
    shader.setFloat('_disx', disx);
    shader.setFloat('_disy', disy);
    shader.setBool('inner', inner);
    shader.setBool('inverted', inverted);
  }

  function set_alpha(value:Float)
  {
    alpha = value;
    shader.setFloat('_alpha', alpha);
    return value;
  }

  function set_disx(value:Float)
  {
    disx = value;
    shader.setFloat('_disx', disx);
    return value;
  }

  function set_disy(value:Float)
  {
    disy = value;
    shader.setFloat('_disy', disy);
    return value;
  }

  function set_inner(value:Bool)
  {
    inner = value;
    shader.setBool('inner', inner);
    return value;
  }

  function set_inverted(value:Bool)
  {
    inverted = value;
    shader.setBool('inverted', inverted);
    return value;
  }
}

class FlipEffect extends ShaderBase
{
  public var flip(default, set):Float = 0.0;

  public function new()
  {
    super('Flip');
    shader.setFloat('flip', 0);
  }

  function set_flip(value:Float)
  {
    flip = value;
    shader.setFloat('flip', flip);
    return value;
  }
}

class GameBoyEffect extends ShaderBase
{
  public var intensity(default, set):Float = 0.0;

  public function new()
  {
    super('GameBoy');
    shader.setFloat('intensity', intensity);
  }

  function set_intensity(i:Float):Float
  {
    intensity = i;
    shader.setFloat('intensity', intensity);
    return i;
  }
}

class GlitchedEffect extends ShaderBase
{
  public var prob(default, set):Float = 0.0;
  public var intensityChromatic(default, set):Float = 0.0;

  public function new()
  {
    super('Glitched');
    shader.setFloat('time', 0);
    shader.setFloat('prob', 0);
    shader.setFloat('intensityChromatic', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('time', shader.getFloat('time') + elapsed);
  }

  public function set_prob(p:Float):Float
  {
    prob = p;
    shader.setFloat('prob', prob);
    return p;
  }

  public function set_intensityChromatic(ic:Float):Float
  {
    intensityChromatic = ic;
    shader.setFloat('intensityChromatic', intensityChromatic);
    return ic;
  }
}

// Linux crashes due to GL_NV_non_square_matrices
// and I haven' t found a way to set version to 130 // (importing Eric's PR (openfl/openfl#2577) to this repo caused more errors)
// So for now, Linux users will have to disable shaders specifically for Libitina.
class GlitchNewEffect extends ShaderBase // https://www.shadertoy.com/view/XtyXzW
{
  public var prob(default, set):Float = 0;
  public var intensityChromatic(default, set):Float = 0;

  public function new()
  {
    super('GlitchNew');
    shader.setFloat('time', 0);
    shader.setFloat('prob', 0);
    shader.setFloat('intensityChromatic', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('time', shader.getFloat('time') + elapsed);
  }

  function set_prob(value:Float):Float
  {
    prob = value;
    shader.setFloat('prob', prob);
    return value;
  }

  function set_intensityChromatic(value:Float):Float
  {
    intensityChromatic = value;
    shader.setFloat('intensityChromatic', intensityChromatic);
    return value;
  }
}

class GlitchyChromaticEffect extends ShaderBase
{
  public var glitch(default, set):Float = 0;

  public function new()
  {
    super('GlitchyChromatic');
    shader.setFloat('iTime', 0);
    shader.setFloat('GLITCH', glitch);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
    shader.setFloat('GLITCH', glitch);
  }

  function set_glitch(value:Float)
  {
    glitch = value;
    shader.setFloat('GLITCH', glitch);
    return value;
  }
}

class GocpEffect extends ShaderBase
{
  public var iTime:Float = 0;
  public var texAlpha(default, set):Float = 0;
  public var saturation(default, set):Float = 0;

  public var threshold(default, set):Float = 0;
  public var rVal(default, set):Float = 0;
  public var gVal(default, set):Float = 0;
  public var bVal(default, set):Float = 0;

  public function new()
  {
    super('Gocp');
    shader.setFloat('iTime', 0);
    shader.setFloat('texAlpha', texAlpha);
    shader.setFloat('saturation', saturation);

    shader.setFloat('threshold', threshold);
    shader.setFloat('rVal', rVal);
    shader.setFloat('gVal', gVal);
    shader.setFloat('bVal', bVal);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }

  function set_texAlpha(ta:Float):Float
  {
    texAlpha = ta;
    shader.setFloat('texAlpha', texAlpha);
    return ta;
  }

  function set_saturation(s:Float):Float
  {
    saturation = s;
    shader.setFloat('saturation', saturation);
    return s;
  }

  function set_threshold(th:Float):Float
  {
    threshold = th;
    shader.setFloat('threshold', threshold);
    return th;
  }

  function set_rVal(rv:Float):Float
  {
    rVal = rv;
    shader.setFloat('rVal', rVal);
    return rv;
  }

  function set_gVal(gv:Float):Float
  {
    gVal = gv;
    shader.setFloat('gVal', gVal);
    return gv;
  }

  function set_bVal(bv:Float):Float
  {
    bVal = bv;
    shader.setFloat('bVal', bVal);
    return bv;
  }
}

class GreyscaleEffect extends ShaderBase // Has No Values To Add, Change, Take
{
  public function new()
  {
    super('Greyscale');
  }
}

class GreyscaleEffectNew extends ShaderBase
{
  public var strength(default, set):Float = 0.0;

  public function new():Void
  {
    super('GreyscaleNew');
    shader.setFloat('strength', 0);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return strength;
  }
}

class HeatEffect extends ShaderBase
{
  public var strength(default, set):Float = 1.0;

  public function new():Void
  {
    super('Heat');
    shader.setFloat('strength', strength);
    shader.setFloat('iTime', 0.0);
  }

  override public function update(elapsed:Float):Void
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return strength;
  }
}

class HeatWaveEffect extends ShaderBase
{
  public var strength(default, set):Float = 0;
  public var speed(default, set):Float = 0;

  public function new()
  {
    super('HeatWave');
    shader.setFloat('time', 0);
    shader.setFloat('strength', 0);
    shader.setFloat('speed', 0);
  }

  override public function update(elapsed:Float):Void
  {
    shader.setFloat('time', shader.getFloat('time') + elapsed);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return strength;
  }

  function set_speed(value:Float):Float
  {
    speed = value;
    shader.setFloat('speed', speed);
    return speed;
  }
}

class IndividualGlitchesEffect extends ShaderBase
{
  public var binaryIntensity(default, set):Float = 0;

  public function new()
  {
    super('IndividualGlitches');
    shader.setFloat('binaryIntensity', binaryIntensity);
  }

  public function set_binaryIntensity(binary:Float):Float
  {
    binaryIntensity = binary;
    shader.setFloat('binaryIntensity', binaryIntensity);
    return binary;
  }
}

class InvertEffect extends ShaderBase
{
  public function new()
  {
    super('Invert');
  }
}

class MirrorRepeatEffect extends ShaderBase
{
  public var zoom(default, set):Float = 5.0;
  public var angle(default, set):Float = 0.0;

  public var x(default, set):Float = 0.0;
  public var y(default, set):Float = 0.0;

  public function new():Void
  {
    super('MirrorRepeat');
    shader.setFloat('zoom', zoom);
    shader.setFloat('angle', angle);
    shader.setFloat('iTime', 0.0);
    shader.setFloat('x', x);
    shader.setFloat('y', y);
  }

  override public function update(elapsed:Float):Void
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }

  function set_zoom(value:Float):Float
  {
    zoom = value;
    shader.setFloat('zoom', zoom);
    return zoom;
  }

  function set_angle(value:Float):Float
  {
    angle = value;
    shader.setFloat('angle', angle);
    return angle;
  }

  function set_x(value:Float):Float
  {
    x = value;
    shader.setFloat('x', x);
    return x;
  }

  function set_y(value:Float):Float
  {
    y = value;
    shader.setFloat('y', y);
    return y;
  }
}

class MonitorEffect extends ShaderBase
{
  public function new()
  {
    super('Monitor');
  }
}

class MosaicEffect extends ShaderBase
{
  public var strength(default, set):Float = 0.0;

  public function new():Void
  {
    super('Mosaic');
    shader.setFloat('strength', strength);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', value);
    return strength;
  }
}

class MultiSplitEffect extends ShaderBase
{
  public var mult(default, set):Float = 0;

  public function new()
  {
    super('MultiSplit');
    shader.setFloat('multi', mult);
  }

  public function set_mult(isplit:Float):Float
  {
    mult = isplit;
    shader.setFloat('multi', mult);
    return isplit;
  }
}

class PaletteEffect extends ShaderBase
{
  public var strength(default, set):Float = 0.0;
  public var paletteSize(default, set):Float = 8.0;

  public function new():Void
  {
    super('Palette');
    shader.setFloat('strength', strength);
    shader.setFloat('paletteSize', paletteSize);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return strength;
  }

  function set_paletteSize(value:Float):Float
  {
    paletteSize = value;
    shader.setFloat('paletteSize', paletteSize);
    return paletteSize;
  }
}

class PerlinSmokeEffect extends ShaderBase
{
  public var waveStrength(default, set):Float = 0; // for screen wave (only for ruckus)
  public var smokeStrength(default, set):Float = 1;
  public var speed:Float = 1;

  public function new():Void
  {
    super('PerlinSmoke');
    shader.setFloat('waveStrength', waveStrength);
    shader.setFloat('smokeStrength', smokeStrength);
    shader.setFloat('iTime', 0.0);
  }

  override public function update(elapsed:Float):Void
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed * speed);
  }

  function set_waveStrength(value:Float):Float
  {
    waveStrength = value;
    shader.setFloat('waveStrength', waveStrength);
    return waveStrength;
  }

  function set_smokeStrength(value:Float):Float
  {
    smokeStrength = value;
    shader.setFloat('smokeStrength', smokeStrength);
    return smokeStrength;
  }
}

// Quick plane raymarcher thingy by 4mbr0s3 2 (partially)
class PlaneRaymarcherEffect extends ShaderBase
{
  public var pitch(get, set):Float;
  public var yaw(get, set):Float;
  public var cameraOffX(get, set):Float;
  public var cameraOffY(get, set):Float;
  public var cameraOffZ(get, set):Float;
  public var cameraLookAtX(get, set):Float;
  public var cameraLookAtY(get, set):Float;
  public var cameraLookAtZ(get, set):Float;

  function get_pitch():Float
  {
    return shader.getFloat('pitch');
  }

  function get_cameraOffX():Float
  {
    return shader.getFloatArray('cameraOff')[0];
  }

  function get_cameraOffY():Float
  {
    return shader.getFloatArray('cameraOff')[1];
  }

  function get_cameraOffZ():Float
  {
    return shader.getFloatArray('cameraOff')[2];
  }

  function get_cameraLookAtX():Float
  {
    return shader.getFloatArray('cameraLookAt')[0];
  }

  function get_cameraLookAtY():Float
  {
    return shader.getFloatArray('cameraLookAt')[1];
  }

  function get_cameraLookAtZ():Float
  {
    return shader.getFloatArray('cameraLookAt')[2];
  }

  function set_pitch(value:Float):Float
  {
    shader.setFloat('pitch', value);
    return value;
  }

  function set_cameraOffX(value:Float):Float
  {
    shader.setFloatArray('cameraOff', [
      value,
      shader.getFloatArray('cameraOff')[1],
      shader.getFloatArray('cameraOff')[2]
    ]);
    return value;
  }

  function set_cameraOffY(value:Float):Float
  {
    shader.setFloatArray('cameraOff', [
      shader.getFloatArray('cameraOff')[0],
      value,
      shader.getFloatArray('cameraOff')[2]
    ]);
    return value;
  }

  function set_cameraOffZ(value:Float):Float
  {
    shader.setFloatArray('cameraOff', [
      shader.getFloatArray('cameraOff')[0],
      shader.getFloatArray('cameraOff')[1],
      value
    ]);
    return value;
  }

  function set_cameraLookAtX(value:Float):Float
  {
    shader.setFloatArray('cameraLookAt', [
      value,
      shader.getFloatArray('cameraLookAt')[1],
      shader.getFloatArray('cameraLookAt')[2]
    ]);
    return value;
  }

  function set_cameraLookAtY(value:Float):Float
  {
    shader.setFloatArray('cameraLookAt', [
      shader.getFloatArray('cameraLookAt')[0],
      value,
      shader.getFloatArray('cameraLookAt')[2]
    ]);
    return value;
  }

  function set_cameraLookAtZ(value:Float):Float
  {
    shader.setFloatArray('cameraLookAt', [
      shader.getFloatArray('cameraLookAt')[0],
      shader.getFloatArray('cameraLookAt')[1],
      value
    ]);
    return value;
  }

  function get_yaw():Float
  {
    return shader.getFloat('yaw');
  }

  function set_yaw(value:Float):Float
  {
    shader.setFloat('yaw', value);
    return value;
  }

  public function new():Void
  {
    super('PlaneRaymarcher');
    shader.setFloatArray('cameraOff', [0, 0, 0]);
    shader.setFloatArray('cameraLookAt', [0, 0, 0]);
    shader.setFloat('pitch', 0);
    shader.setFloat('yaw', 0);
    shader.setFloat('uTime', 0);
  }

  override public function update(elapsed:Float):Void
  {
    shader.setFloat('uTime', shader.getFloat('uTime') + elapsed);
  }
}

// https://www.shadertoy.com/view/MlfBWr
// le shader
class RainFallEffect extends ShaderBase
{
  public function new():Void
  {
    super('RainFall');
    shader.setFloat('iTime', 0);
  }

  override public function update(elapsed:Float):Void
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class RayMarchEffect extends ShaderBase
{
  public var x:Float = 0;
  public var y:Float = 0;
  public var z:Float = 0;
  public var zoom(default, set):Float = -2;

  // Now you can customize these things for the shader! (NOW CAN CHANGE HOW MANY "windows" OR DISTANCE IS VISIBLE WHICH MAKES IT A BETTER SHADER)!
  public var stepsLimit(default, set):Float = 0;
  public var distLimit(default, set):Float = 0;
  public var surfDistLimit(default, set):Float = 0;

  public function new()
  {
    super('RayMarch');
    shader.setFloatArray('iResolution', [FlxG.width, FlxG.height]);
    shader.setFloatArray('rotation', [0, 0, 0]);
    shader.setFloat('zoom', zoom);

    shader.setFloat('MAX_STEPS_LIMIT', stepsLimit);
    shader.setFloat('MAX_DIST_LIMIT', distLimit);
    shader.setFloat('SURF_DIST_LIMIT', surfDistLimit);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloatArray('iResolution', [FlxG.width, FlxG.height]);
    shader.setFloatArray('rotation', [x * FlxAngle.TO_RAD, y * FlxAngle.TO_RAD, z * FlxAngle.TO_RAD]);
  }

  function set_zoom(value:Float):Float
  {
    zoom = value;
    shader.setFloat('zoom', value);
    return value;
  }

  function set_stepsLimit(value:Float):Float
  {
    stepsLimit = value;
    shader.setFloat('MAX_STEPS_LIMIT', value);
    return value;
  }

  function set_distLimit(value:Float):Float
  {
    distLimit = value;
    shader.setFloat('MAX_DIST_LIMIT', value);
    return value;
  }

  function set_surfDistLimit(value:Float):Float
  {
    surfDistLimit = value;
    shader.setFloat('SURF_DIST_LIMIT', value);
    return value;
  }
}

class RedAberration extends ShaderBase
{
  public var time(default, set):Float = 0.0;
  public var intensity(default, set):Float = 0.0;
  public var initial(default, set):Float = 0.0;

  public function new()
  {
    super('RedAberration');
    shader.setFloat('time', time);
    shader.setFloat('intensity', intensity);
    shader.setFloat('initial', initial);
  }

  function set_time(t:Float):Float
  {
    time = t;
    shader.setFloat('time', time);
    return t;
  }

  function set_intensity(i:Float):Float
  {
    intensity = i;
    shader.setFloat('intensity', intensity);
    return i;
  }

  function set_initial(i:Float):Float
  {
    initial = i;
    shader.setFloat('initial', initial);
    return i;
  }
}

class RGBPinEffect extends ShaderBase
{
  public var amount(default, set):Float = 0;
  public var distortionFactor(default, set):Float = 0;

  public function new():Void
  {
    super('RGBPin');
    shader.setFloat('amount', amount);
    shader.setFloat('distortionFactor', distortionFactor);
  }

  function set_amount(v:Float):Float
  {
    amount = v;
    shader.setFloat('amount', amount);
    return v;
  }

  function set_distortionFactor(v:Float):Float
  {
    distortionFactor = v;
    shader.setFloat('distortionFactor', distortionFactor);
    return v;
  }
}

class RgbThreeEffect extends ShaderBase
{
  public function new()
  {
    super('RgbThree');
    shader.setFloat('iTime', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class ScanlineEffectNew extends ShaderBase
{
  public var strength(default, set):Float = 0.0;
  public var pixelsBetweenEachLine(default, set):Float = 15.0;
  public var smooth(default, set):Bool = false;

  public function new():Void
  {
    super('ScanlineNew');
    shader.setFloat('strength', 0.0);
    shader.setFloat('pixelsBetweenEachLine', pixelsBetweenEachLine);
    shader.setBool('smoothVar', smooth);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return strength;
  }

  function set_pixelsBetweenEachLine(value:Float):Float
  {
    pixelsBetweenEachLine = value;
    shader.setFloat('pixelsBetweenEachLine', pixelsBetweenEachLine);
    return pixelsBetweenEachLine;
  }

  function set_smooth(value:Bool):Bool
  {
    smooth = value;
    shader.setBool('smoothVar', smooth);
    return smooth;
  }
}

class SobelEffect extends ShaderBase
{
  public var strength(default, set):Float = 1.0;
  public var intensity(default, set):Float = 1.0;

  public function new():Void
  {
    super('Sobel');
    shader.setFloat('strength', 0);
    shader.setFloat('intensity', 0);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return strength;
  }

  function set_intensity(value:Float):Float
  {
    intensity = value;
    shader.setFloat('intensity', intensity);
    return intensity;
  }
}

class SquishyEffect extends ShaderBase
{
  public function new()
  {
    super('Squishy');
    shader.setFloat('iTime', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class ThreeDEffect extends ShaderBase
{
  public var xrot(default, set):Float = 0;
  public var yrot(default, set):Float = 0;
  public var zrot(default, set):Float = 0;
  public var depth(default, set):Float = 0;

  public function new()
  {
    super('ThreeD');
    shader.setFloat('xrot', xrot);
    shader.setFloat('yrot', yrot);
    shader.setFloat('zrot', zrot);
    shader.setFloat('depth', depth);
  }

  function set_xrot(x:Float):Float
  {
    xrot = x;
    shader.setFloat('xrot', xrot);
    return x;
  }

  function set_yrot(y:Float):Float
  {
    yrot = y;
    shader.setFloat('yrot', yrot);
    return y;
  }

  function set_zrot(z:Float):Float
  {
    zrot = z;
    shader.setFloat('zrot', zrot);
    return z;
  }

  function set_depth(d:Float):Float
  {
    depth = d;
    shader.setFloat('depth', depth);
    return d;
  }
}

class TypeVCREffect extends ShaderBase
{
  public function new():Void
  {
    super('TypeVCR');
    shader.setFloat('iTime', 0.0);
  }

  override public function update(elapsed:Float):Void
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class VCRBorderEffect extends ShaderBase
{
  public function new()
  {
    super('VCRBorder');
  }
}

class VCRDistortionEffect extends ShaderBase
{
  public var glitchFactor(default, set):Float = 0;
  public var distortion(default, set):Bool = true;
  public var perspectiveOn(default, set):Bool = true;
  public var vignetteMoving(default, set):Bool = true;
  public var scanlinesOn(default, set):Bool = true;

  public function new()
  {
    super('VCRDistortion');
    shader.setFloat('iTime', 0);
    shader.setFloat('glitchModifier', glitchFactor);
    shader.setBool('distortionOn', distortion);
    shader.setBool('perspectiveOn', perspectiveOn);
    shader.setBool('vignetteOn', vignetteMoving);
    shader.setBool('scanlinesOn', scanlinesOn);
    shader.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }

  public function set_glitchFactor(glitch:Float):Float
  {
    glitchFactor = glitch;
    shader.setFloat('glitchModifier', glitchFactor);
    return glitch;
  }

  public function set_distortion(distort:Bool):Bool
  {
    distortion = distort;
    shader.setBool('distortionOn', distortion);
    return distort;
  }

  public function set_perspectiveOn(persp:Bool):Bool
  {
    perspectiveOn = persp;
    shader.setBool('perspectiveOn', perspectiveOn);
    return persp;
  }

  public function set_vignetteMoving(moving:Bool):Bool
  {
    vignetteMoving = moving;
    shader.setBool('vignetteOn', vignetteMoving);
    return moving;
  }

  public function set_scanlinesOn(scan:Bool):Bool
  {
    scanlinesOn = scan;
    shader.setBool('scanlinesOn', scanlinesOn);
    return scan;
  }
}

class VCRDistortionEffect2 extends ShaderBase // the one used for tails doll /// No Things Used!
{
  public function new()
  {
    super('VCRDistortion2');
    shader.setBool('scanlinesOn', true);
  }
}

class VCRMario85Effect extends ShaderBase
{
  public function new()
  {
    super('VCRMario85');
    shader.setFloat('time', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class VcrEffect extends ShaderBase
{
  public function new()
  {
    super('Vcr');
    shader.setFloat('iTime', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class VcrNoGlitchEffect extends ShaderBase
{
  public function new()
  {
    super('VcrNoGlitch');
    shader.setFloat('iTime', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class VcrWithGlitch extends ShaderBase
{
  public function new()
  {
    super('VcrWithGlitch');
    shader.setFloat('iTime', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class VHSEffect extends ShaderBase
{
  public function new()
  {
    super('VHS');
    shader.setFloat('iTime', 0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}

class VignetteEffect extends ShaderBase
{
  public var strength(default, set):Float = 1.0;
  public var size(default, set):Float = 0.0;
  public var red(default, set):Float = 0.0;
  public var green(default, set):Float = 0.0;
  public var blue(default, set):Float = 0.0;

  public function new():Void
  {
    super('Vignette');
    shader.setFloat('strength', 0);
    shader.setFloat('size', 0);
    shader.setFloat('red', red);
    shader.setFloat('green', green);
    shader.setFloat('blue', blue);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', strength);
    return strength;
  }

  function set_size(value:Float):Float
  {
    size = value;
    shader.setFloat('size', size);
    return size;
  }

  function set_red(value:Float):Float
  {
    red = value;
    shader.setFloat('red', red);
    return red;
  }

  function set_green(value:Float):Float
  {
    green = value;
    shader.setFloat('green', green);
    return green;
  }

  function set_blue(value:Float):Float
  {
    blue = value;
    shader.setFloat('blue', blue);
    return blue;
  }
}

class VignetteGlitchEffect extends ShaderBase
{
  public var time(default, set):Float = 0.0;
  public var prob(default, set):Float = 0.0;
  public var vignetteIntensity(default, set):Float = 0.0;

  public function new()
  {
    super('VignetteGlitch');
    shader.setFloat('time', time);
    shader.setFloat('prob', prob);
    shader.setFloat('vignetteIntensity', vignetteIntensity);
  }

  function set_time(t:Float):Float
  {
    time = t;
    shader.setFloat('time', time);
    return time;
  }

  function set_prob(p:Float):Float
  {
    prob = p;
    shader.setFloat('prob', prob);
    return prob;
  }

  function set_vignetteIntensity(vi:Float):Float
  {
    vignetteIntensity = vi;
    shader.setFloat('vignetteIntensity', vignetteIntensity);
    return vignetteIntensity;
  }
}

class WaveBurstEffect extends ShaderBase
{
  public var strength(default, set):Float = 0.0;

  public function new():Void
  {
    super('WaveBurst');
    shader.setFloat('strength', strength);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', value);
    return strength;
  }
}

class WaterEffect extends ShaderBase
{
  public var strength(default, set):Float = 10.0;
  public var speed:Float = 1.0;

  public function new():Void
  {
    super('Water');
    shader.setFloat('iTime', 0.0);
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed * speed);
  }

  function set_strength(value:Float):Float
  {
    strength = value;
    shader.setFloat('strength', value);
    return strength;
  }
}

class WaveCircleEffect extends ShaderBase
{
  public var waveSpeed(default, set):Float = 0;
  public var waveFrequency(default, set):Float = 0;
  public var waveAmplitude(default, set):Float = 0;

  public function new():Void
  {
    super('WaveCircle');
    shader.setFloat('uTime', 0.0);
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
    shader.setFloat('uTime', shader.getFloat('uTime') + elapsed);
  }

  function set_waveSpeed(v:Float):Float
  {
    waveSpeed = v;
    shader.setFloat('uSpeed', waveSpeed);
    return v;
  }

  function set_waveFrequency(v:Float):Float
  {
    waveFrequency = v;
    shader.setFloat('uFrequency', waveFrequency);
    return v;
  }

  function set_waveAmplitude(v:Float):Float
  {
    waveAmplitude = v;
    shader.setFloat('uWaveAmplitude', waveAmplitude);
    return v;
  }
}

class YCBUEndingEffect extends ShaderBase
{
  var amount:Float = 0;

  public function new()
  {
    super('YCBUEnding');
    shader.setFloat('seed', haxe.Timer.stamp());
    shader.setFloat('intensity', 0.0);
  }

  override public function update(elapsed:Float)
  {
    amount += elapsed;
    amount /= 4;
    shader.setFloat('seed', shader.getFloat('seed') + elapsed);
    shader.setFloat('intensity', FlxMath.bound(shader.getFloat('intensity') + amount, 0, 1));
  }
}
