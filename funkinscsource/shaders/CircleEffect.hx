package shaders;

class CircleEffect extends ShaderBase
{
  public var percent(default, set):Float = 0.0;

  public function new()
  {
    super('Circle');
    shader.setFloat('percent', percent);
  }

  function set_percent(value:Float):Float
  {
    percent = value;
    shader.setFloat('percent', percent);
    return percent;
  }
}
