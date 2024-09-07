package backend.data;

import haxe.ds.Either;
import hxjsonast.Json;
import hxjsonast.Json.JObjectField;
import hxjsonast.Tools;
import thx.semver.Version;
import thx.semver.VersionRule;

/**
 * `json2object` has an annotation `@:jcustomparse` which allows for mutation of parsed values.
 *
 * It also allows for validation, since throwing an error in this function will cause the issue to be properly caught.
 * Parsing will fail and `parser.errors` will contain the thrown exception.
 *
 * Functions must be of the signature `(hxjsonast.Json, String) -> T`, where the String is the property name and `T` is the type of the property.
 */
class DataParse
{
  /**
   * `@:jcustomparse(backend.data.DataParse.stringNotEmpty)`
   * @param json Contains the `pos` and `value` of the property.
   * @param name The name of the property.
   * @throws Error If the property is not a string or is empty.
   * @return The string value.
   */
  public static function stringNotEmpty(json:Json, name:String):String
  {
    switch (json.value)
    {
      case JString(s):
        if (s == "") throw 'Expected property $name to be non-empty.';
        return s;
      default:
        throw 'Expected property $name to be a string, but it was ${json.value}.';
    }
  }

  /**
   * `@:jcustomparse(backend.data.DataParse.semverVersion)`
   * @param json Contains the `pos` and `value` of the property.
   * @param name The name of the property.
   * @return The value of the property as a `thx.semver.Version`.
   */
  public static function semverVersion(json:Json, name:String):Version
  {
    switch (json.value)
    {
      case JString(s):
        if (s == "") throw 'Expected version property $name to be non-empty.';
        return s;
      default:
        throw 'Expected version property $name to be a string, but it was ${json.value}.';
    }
  }

  /**
   * `@:jcustomparse(backend.data.DataParse.semverVersionRule)`
   * @param json Contains the `pos` and `value` of the property.
   * @param name The name of the property.
   * @return The value of the property as a `thx.semver.VersionRule`.
   */
  public static function semverVersionRule(json:Json, name:String):VersionRule
  {
    switch (json.value)
    {
      case JString(s):
        if (s == "") throw 'Expected version rule property $name to be non-empty.';
        return s;
      default:
        throw 'Expected version rule property $name to be a string, but it was ${json.value}.';
    }
  }

  /**
   * Parser which outputs a Dynamic value, either a object or something else.
   * @param json
   * @param name
   * @return The value of the property.
   */
  public static function dynamicValue(json:Json, name:String):Dynamic
  {
    return Tools.getValue(json);
  }

  /**
   * Parser which outputs a `Either<Float, Array<Float>>`.
   */
  public static function eitherFloatOrFloats(json:Json, name:String):Null<Either<Float, Array<Float>>>
  {
    switch (json.value)
    {
      case JNumber(f):
        return Either.Left(Std.parseFloat(f));
      case JArray(fields):
        return Either.Right(fields.map((field) -> cast Tools.getValue(field)));
      default:
        throw 'Expected property $name to be one or multiple floats, but it was ${json.value}.';
    }
  }

  /**
   * Array of JSON fields `[{key, value}, {key, value}]` to a Dynamic object `{key:value, key:value}`.
   * @param fields
   * @return Dynamic
   */
  static function jsonFieldsToDynamicObject(fields:Array<JObjectField>):Dynamic
  {
    var result:Dynamic = {};
    for (field in fields)
    {
      Reflect.setField(result, field.name, Tools.getValue(field.value));
    }
    return result;
  }

  /**
   * Array of JSON elements `[Json, Json, Json]` to a Dynamic array `[String, Object, Int, Array]`
   * @param jsons
   * @return Array<Dynamic>
   */
  static function jsonArrayToDynamicArray(jsons:Array<Json>):Array<Null<Dynamic>>
  {
    return [for (json in jsons) Tools.getValue(json)];
  }
}
