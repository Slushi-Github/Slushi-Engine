package shaders;

import shaders.RGBPalette;
import flixel.system.FlxAssets.FlxShader;

class RGBPixelShaderReference extends ShaderBase
{
  public var containsPixel:Bool = false;
  public var pixelSize:Float = 1;
  public var enabled(default, set):Bool = true;

  public function copyValues(tempShader:RGBPalette)
  {
    if (tempShader != null)
    {
      shader.setFloatArray('r', [
        tempShader.shader.getFloatArray('r')[0],
        tempShader.shader.getFloatArray('r')[1],
        tempShader.shader.getFloatArray('r')[2]
      ]);
      shader.setFloatArray('g', [
        tempShader.shader.getFloatArray('g')[0],
        tempShader.shader.getFloatArray('g')[1],
        tempShader.shader.getFloatArray('g')[2]
      ]);
      shader.setFloatArray('b', [
        tempShader.shader.getFloatArray('b')[0],
        tempShader.shader.getFloatArray('b')[1],
        tempShader.shader.getFloatArray('b')[2]
      ]);
      shader.setFloat('mult', tempShader.shader.getFloat('mult'));
    }
    else
      enabled = false;

    if (containsPixel) pixelSize = 6;
    shader.setFloatArray('uBlocksize', [pixelSize, pixelSize]);
  }

  public function set_enabled(value:Bool)
  {
    enabled = value;
    shader.setFloat('mult', value ? 1 : 0);
    return value;
  }

  public function set_pixelAmount(value:Float)
  {
    pixelSize = value;
    shader.setFloatArray('uBlocksize', [value, value]);
    return value;
  }

  public function reset()
  {
    shader.setFloatArray('r', [0, 0, 0]);
    shader.setFloatArray('g', [0, 0, 0]);
    shader.setFloatArray('b', [0, 0, 0]);
  }

  public function new()
  {
    super('RGBPixel');
    reset();
    enabled = true;

    if (containsPixel) pixelSize = PlayState.daPixelZoom;
    else
      pixelSize = 1;
  }
}
