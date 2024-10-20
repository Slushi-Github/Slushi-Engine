package shaders;

class ColorSwap extends ShaderBase
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
