package shaders;

class ShaderFile
{
  public static function frag(shader:String):String
    return File.getContent(Paths.shaderFragment(shader, 'source'));

  public static function vert(shader:String):String
    return File.getContent(Paths.shaderVertex(shader, 'source'));
}
