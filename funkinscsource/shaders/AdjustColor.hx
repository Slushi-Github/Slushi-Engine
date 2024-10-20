package shaders;

class AdjustColor extends ShaderBase
{
  public var hue(default, set):Float;
  public var saturation(default, set):Float;
  public var brightness(default, set):Float;
  public var contrast(default, set):Float;

  public function new()
  {
    super('AdjustColor');
    hue = 0;
    saturation = 0;
    brightness = 0;
    contrast = 0;
  }

  function set_hue(value:Float):Float
  {
    hue = value;
    shader.setFloat('hue', hue);
    return hue;
  }

  function set_saturation(value:Float):Float
  {
    saturation = value;
    shader.setFloat('saturation', saturation);
    return saturation;
  }

  function set_brightness(value:Float):Float
  {
    brightness = value;
    shader.setFloat('brightness', brightness);
    return brightness;
  }

  function set_contrast(value:Float):Float
  {
    contrast = value;
    shader.setFloat('contrast', contrast);
    return contrast;
  }
}
