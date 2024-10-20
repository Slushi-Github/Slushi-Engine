package shaders;

import openfl.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

class ShaderBase
{
  public var shader:FlxRuntimeShader;
  public var id:String = null;
  public var tweens:Array<FlxTween> = [];

  public function new(file:String)
  {
    final fragShaderPath:String = Paths.shaderFragment(file);
    final vertShaderPath:String = Paths.shaderVertex(file);
    final fragCode:String = getCode(fragShaderPath);
    final vertCode:String = getCode(vertShaderPath);

    shader = new FlxRuntimeShader(fragCode, vertCode);
  }

  public function canUpdate():Bool
    return true;

  public function update(elapsed:Float) {}

  public function getShader():FlxRuntimeShader
    return shader;

  public function destroy()
    shader = null;

  public function getCode(path:String):String
    return #if MODS_ALLOWED FileSystem.exists(path) ? File.getContent(path) : null #else Assets.exists(path) ? Assets.getText(path) : null #end;
}
