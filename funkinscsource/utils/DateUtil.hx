package utils;

/**
 * Utilities for performing operations on dates.
 */
class DateUtil
{
  public static function generateTimestamp(?date:Date = null, ?formatted:Bool = false):String
  {
    if (date == null) date = Date.now();

    var timeNow:String = '${date.getFullYear()}-${Std.string(date.getMonth() + 1).lpad('0', 2)}-${Std.string(date.getDate()).lpad('0', 2)}-${Std.string(date.getHours()).lpad('0', 2)}-${Std.string(date.getMinutes()).lpad('0', 2)}-${Std.string(date.getSeconds()).lpad('0', 2)}';
    if (formatted)
    {
      timeNow = timeNow.replace(" ", "_");
      timeNow = timeNow.replace(":", "'");
    }
    return timeNow;
  }

  public static function generateCleanTimestamp(?date:Date = null):String
  {
    if (date == null) date = Date.now();

    return '${DateTools.format(date, '%B %d, %Y')} at ${DateTools.format(date, '%I:%M %p')}';
  }
}
