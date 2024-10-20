package shaders;

class OldTVEffect extends ShaderBase
{
  public function new()
  {
    super('OldTV');
    shader.setFloat('iTime', haxe.Timer.stamp());
  }

  override public function update(elapsed:Float)
  {
    shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);
  }
}
