package shaders;

class CubeEffect extends ShaderBase
{
  public var beat(default, set):Float = 0.0;

  function set_beat(value:Float):Float
  {
    beat = value;
    shader.setFloat('beat', beat);
    return beat;
  }

  public var time(default, set):Float = 0.0;

  function set_time(value:Float):Float
  {
    time = value;
    shader.setFloat('time', value);
    return time;
  }

  public var size(default, set):Float = 1.0;

  function set_size(value:Float):Float
  {
    size = value;
    shader.setFloat('size', size);
    return size;
  }

  public var kick(default, set):Float = 0.0;

  function set_kick(value:Float):Float
  {
    kick = value;
    shader.setFloat('kick', kick);
    return kick;
  }

  public var forward(default, set):Float = 0.0;

  function set_forward(value:Float):Float
  {
    forward = value;
    shader.setFloat('forward', forward);
    return forward;
  }

  public var nyooom(default, set):Float = 0.0;

  function set_nyooom(value:Float):Float
  {
    nyooom = value;
    shader.setFloat('nyooom', nyooom);
    return nyooom;
  }

  public var spin(default, set):Float = 1.0;

  function set_spin(value:Float):Float
  {
    spin = value;
    shader.setFloat('spin', spin);
    return spin;
  }

  public var twist(default, set):Float = 0.0;

  function set_twist(value:Float):Float
  {
    twist = value;
    shader.setFloat('twist', twist);
    return twist;
  }

  public var skew(default, set):Float = 0.0;

  function set_skew(value:Float):Float
  {
    skew = value;
    shader.setFloat('skew', skew);
    return skew;
  }

  public var slump(default, set):Float = 0.0;

  function set_slump(value:Float):Float
  {
    slump = value;
    shader.setFloat('slump', slump);
    return slump;
  }

  public var deformAmp(default, set):Float = 0.0;

  function set_deformAmp(value:Float):Float
  {
    deformAmp = value;
    shader.setFloat('deformAmp', deformAmp);
    return deformAmp;
  }

  public var deformFreq(default, set):Float = 0.0;

  function set_deformFreq(value:Float):Float
  {
    deformFreq = value;
    shader.setFloat('deformFreq', deformFreq);
    return deformFreq;
  }

  public var textureSizeX(default, set):Float = 0.0;

  function set_textureSizeX(value:Float):Float
  {
    textureSizeX = value;
    shader.setFloatArray('textureSize', [textureSizeX, textureSizeY]);
    return textureSizeX;
  }

  public var textureSizeY(default, set):Float = 0.0;

  function set_textureSizeY(value:Float):Float
  {
    textureSizeY = value;
    shader.setFloatArray('textureSize', [textureSizeX, textureSizeY]);
    return textureSizeY;
  }

  public var imageSizeX(default, set):Float = 0.0;

  function set_imageSizeX(value:Float):Float
  {
    imageSizeX = value;
    shader.setFloatArray('imageSize', [imageSizeX, imageSizeY]);
    return imageSizeX;
  }

  public var imageSizeY(default, set):Float = 0.0;

  function set_imageSizeY(value:Float):Float
  {
    imageSizeY = value;
    shader.setFloatArray('imageSize', [imageSizeX, imageSizeY]);
    return imageSizeY;
  }

  public function new()
  {
    super('Cube');
  }
}
