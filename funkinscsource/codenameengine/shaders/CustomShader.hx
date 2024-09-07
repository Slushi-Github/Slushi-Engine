package codenameengine.shaders;

import openfl.Assets;

/**
 * Class for custom shaders.
 *
 * To create one, create a `shaders` folder in your assets/mod folder, then add a file named `my-shader.frag` or/and `my-shader.vert`.
 *
 * Non-existent shaders will only load the default one, and throw a warning in the console.
 *
 * To access the shader's uniform variables, use `shader.variable`
 */
class CustomShader extends FunkinShader
{
  public var path:String = "";

  /**
   * Creates a new custom shader
   * @param name Name of the frag and vert files.
   * @param glslVersion GLSL version to use. Defaults to `120`.
   */
  public function new(name:String, glslVersion:String = "120")
  {
    var fragShaderPath:String = Paths.shaderFragment(name);
    var vertShaderPath:String = Paths.shaderVertex(name);
    var fragCode:String = getCode(fragShaderPath);
    var vertCode:String = getCode(vertShaderPath);

    path = fragShaderPath + vertShaderPath;

    var fragCodeFound:Bool = (fragCode != null);
    var vertCodeFound:Bool = (vertCode != null);

    if (fragCode == null && vertCode == null) Debug.logWarn('Shader "$name" couldn\'t be found.');
    else
      Debug.logInfo('frag code found $fragCodeFound, vert code found $vertCodeFound');

    super(fragCode, vertCode, glslVersion);
  }

  public function getCode(path:String):String
  {
    var code:String = #if MODS_ALLOWED FileSystem.exists(path) ? File.getContent(path) : null #else Assets.exists(path) ? Assets.getText(path) : null #end;
    return code;
  }
}
