package backend.data;

import json2object.Position;
import json2object.Position.Line;
import json2object.Error;

class DataError
{
  public static function printError(error:Error):Void
  {
    switch (error)
    {
      case IncorrectType(vari, expected, pos):
        Debug.logError('  Expected field "$vari" to be of type "$expected".');
        printPos(pos);
      case IncorrectEnumValue(value, expected, pos):
        Debug.logError('  Invalid enum value (expected "$expected", got "$value")');
        printPos(pos);
      case InvalidEnumConstructor(value, expected, pos):
        Debug.logError('  Invalid enum constructor (epxected "$expected", got "$value")');
        printPos(pos);
      case UninitializedVariable(vari, pos):
        Debug.logError('  Uninitialized variable "$vari"');
        printPos(pos);
      case UnknownVariable(vari, pos):
        Debug.logError('  Unknown variable "$vari"');
        printPos(pos);
      case ParserError(message, pos):
        Debug.logError('  Parsing error: ${message}');
        printPos(pos);
      case CustomFunctionException(e, pos):
        if (Std.isOfType(e, String))
        {
          Debug.logError('  ${e}');
        }
        else
        {
          printUnknownError(e);
        }
        printPos(pos);
      default:
        printUnknownError(error);
    }
  }

  public static function printUnknownError(e:Dynamic):Void
  {
    switch (Type.typeof(e))
    {
      case TClass(c):
        Debug.logError('  [${Type.getClassName(c)}] ${e.toString()}');
      case TEnum(c):
        Debug.logError('  [${Type.getEnumName(c)}] ${e.toString()}');
      default:
        Debug.logError('  [${Type.typeof(e)}] ${e.toString()}');
    }
  }

  /**
   * TODO: Figure out the nicest way to print this.
   * Maybe look up how other JSON parsers format their errors?
   * @see https://github.com/elnabo/json2object/blob/master/src/json2object/Position.hx
   */
  static function printPos(pos:Position):Void
  {
    if (pos.lines[0].number == pos.lines[pos.lines.length - 1].number)
    {
      Debug.logError('    at ${(pos.file == '') ? 'line ' : '${pos.file}:'}${pos.lines[0].number}');
    }
    else
    {
      Debug.logError('    at ${(pos.file == '') ? 'line ' : '${pos.file}:'}${pos.lines[0].number}-${pos.lines[pos.lines.length - 1].number}');
    }
  }
}
