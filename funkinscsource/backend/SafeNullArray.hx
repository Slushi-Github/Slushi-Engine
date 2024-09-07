package backend;

/**
 * Some Items Detect The Array as Nullable, and it has nullSaftey(No Nullables Allowed! ? Off : On).
 */
@:nullSafety(Off)
class SafeNullArray
{
  public static function getModsList():Array<String>
  {
    var mods:Array<String> = Mods.parseList().all;
    return mods;
  }
}
