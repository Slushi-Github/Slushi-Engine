package shaders;

class BloomEffectNew extends ShaderBase
{
  public var range(default, set):Float = 0.1;
  public var steps(default, set):Float = 0.005;
  public var threshHold(default, set):Float = 0.8;
  public var brightness(default, set):Float = 7.0;

  public function new()
  {
    super('BloomNew');
  }

  function set_range(value:Float):Float
  {
    range = value;
    shader.setFloat('funrange', range);
    return range;
  }

  function set_steps(value:Float):Float
  {
    steps = value;
    shader.setFloat('funsteps', steps);
    return steps;
  }

  function set_threshHold(value:Float):Float
  {
    threshHold = value;
    shader.setFloat('funthreshhold', threshHold);
    return threshHold;
  }

  function set_brightness(value:Float):Float
  {
    brightness = value;
    shader.setFloat('funbrightness', brightness);
    return brightness;
  }
}
