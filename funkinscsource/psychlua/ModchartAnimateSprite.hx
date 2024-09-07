package psychlua;

#if flxanimate
class ModchartAnimateSprite extends FlxAnimate
{
  public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();

  public function new(?x:Float = 0, ?y:Float = 0)
  {
    super(x, y);
    antialiasing = ClientPrefs.data.antialiasing;
  }

  public function playAnim(name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0)
  {
    anim.play(name, forced, reverse, startFrame);

    var daOffset = animOffsets.get(name);
    if (hasOffsetAnimation(name)) offset.set(daOffset[0], daOffset[1]);
  }

  public function hasOffsetAnimation(anim:String):Bool
  {
    return animOffsets.exists(anim);
  }

  public function hasAnimation(animation:String):Bool
  {
    @:privateAccess
    return (anim.animsMap.exists(animation) || anim.symbolDictionary.exists(animation));
  }

  public function addOffset(name:String, x:Float = 0, y:Float = 0)
  {
    animOffsets.set(name, [x, y]);
  }

  public function removeOffset(name:String)
  {
    animOffsets.remove(name);
  }
}
#end
