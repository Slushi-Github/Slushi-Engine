package backend;

import flixel.util.FlxSort;

/**
 * Class to help the members in a "group" -Created by me (-glow)
 */
class CustomArrayGroup<T>
{
  /**
   * members of this class/"group".
   */
  public var members:Array<T> = null;

  /**
   * Length os members of this class/"group". 0 is members are null.
   */
  public var length(get, never):Int;

  public function new()
    clear();

  /**
   * Resort members by any variable
   * @param variable The variable they sort in.
   */
  public dynamic function resort(variable:String)
  {
    if (members != null && members.length > 0)
    {
      members.sort(function(a:T, b:T):Int {
        return FlxSort.byValues(FlxSort.ASCENDING, Reflect.getProperty(a, variable), Reflect.getProperty(b, variable));
      });
    }
  }

  /**
    * If first member is valid.
    * @return Bool
     return (members[0] != null)
   */
  public dynamic function isFirstValid():Bool
    return (members[0] != null);

  /**
    * If there is a valid time.
    * @param rate
    * @param ignore
    * @return Bool
     return false
   */
  public dynamic function validTime(rate, ?ignore):Bool
    return false;

  /**
   * Setting the class/"group" members.
   * @param value
   * @return members = value ?? []
   */
  public dynamic function setMembers(value:Array<T> = null)
    members = value ?? [];

  /**
   * Clears the class/"group" members.
   * @return members = []
   */
  public dynamic function clear()
    members = [];

  public dynamic function byIndex(index:Int):T
    return members[index];

  public dynamic function indexOf(index:T):Int
    return members.indexOf(index);

  public dynamic function splice(index:Int, pos:Int)
    members.splice(index, pos);

  public dynamic function spliceIndexOf(member:T, index:Int = 0)
    splice(indexOf(member), index);

  public dynamic function push(member:T)
    members.push(member);

  public dynamic function insert(pos:Int, member:T)
    members.insert(pos, member);

  public dynamic function remove(member:T)
    members.remove(member);

  function get_length():Int
    return members?.length ?? 0;
}
