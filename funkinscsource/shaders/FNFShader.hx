package shaders;

#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end

class FNFShader #if (!flash && sys) extends FlxRuntimeShader #end
{
  public var name = null;

  public function new(name:String, frag:String, vertex:String)
  {
    super(frag, vertex);
    this.name = name;
  }
}
