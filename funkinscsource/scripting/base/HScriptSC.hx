package scripting.base;

import hscript.*;
import haxe.io.Path;

typedef SCCall =
{
  var funcName:String;
  var funcValue:Dynamic;
  var funcReturn:Dynamic;
}

/**
 * Class serves as base for SCScript.
 */
class HScriptSC
{
  public var interp:Interp;
  public var parser:Parser;
  public var block:Expr;

  public var path:String;
  public var fileName:String;
  public var scriptStr:String;

  public var extension:String;

  public var modFolder:String;

  public var logErrors:Bool = true;

  public function new(path:String)
  {
    this.extension = Path.extension(path);
    this.path = path;
    this.scriptStr = #if MODS_ALLOWED File.getContent(path) #else Assets.getText(path) #end;
    this.fileName = Path.withoutDirectory(fileName);

    #if MODS_ALLOWED
    var myFolder:Array<String> = path.split('/');
    if (myFolder[0] + '/' == Paths.mods()
      && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) // is inside mods folder
      this.modFolder = myFolder[1];
    #end

    parser = new Parser();
    parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;

    interp = new Interp();
    try
    {
      block = parser.parseString(scriptStr);
      interp.execute(block);
    }
    catch (e:haxe.Exception)
    {
      Debug.displayAlert(e.message, 'Error on loading script $fileName');
      return;
    }
  }

  public function call(func:String, ?args:Array<Dynamic> = null):SCCall
  {
    if (interp == null) return null;
    if (args == null) args = [];

    try
    {
      var fnc:Dynamic = variables().get(func);
      if (fnc != null && Reflect.isFunction(func))
      {
        final call = Reflect.callMethod(null, fnc, args);
        return {funcName: func, funcValue: fnc, funcReturn: call};
      }
    }
    catch (e:haxe.Exception)
    {
      if (logErrors) Debug.logError(e.message);
    }

    return null;
  }

  public function executeFunction(func:String = null, args:Array<Dynamic> = null):Dynamic
  {
    if (func == null || !exists(func)) return null;
    return call(func, args);
  }

  public function set(key:String, value:Dynamic, overrideVar:Bool = true):Void
  {
    if (interp == null) return;
    try
    {
      if (overrideVar || !variables().exists(key)) variables().set(key, value);
    }
    catch (e:haxe.Exception)
    {
      if (logErrors) Debug.logError(e.message);
    }
  }

  public function get(key:String):Dynamic
  {
    if (interp == null) return false;

    try
    {
      if (variables().exists(key)) return variables().get(key);
    }
    catch (e:haxe.Exception)
    {
      if (logErrors) Debug.logError(e.message);
      return false;
    }
    return false;
  }

  public function variables():#if haxe3 Map<String, Dynamic> #else Hash<Dynamic> #end
  {
    if (interp == null) return new
      #if haxe3
      Map<String, Dynamic>
      #else
      Hash<Dynamic>
      #end();
    try
      return interp.variables
    catch (e:haxe.Exception)
    {
      if (logErrors) Debug.logError(e.message);
      return new
        #if haxe3
        Map<String, Dynamic>
        #else
        Hash<Dynamic>
        #end();
    }
    return new
      #if haxe3
      Map<String, Dynamic>
      #else
      Hash<Dynamic>
      #end();
  }

  public function exists(key:String):Bool
  {
    if (interp == null) return false;
    return variables().exists(key);
  }

  public function destroy()
  {
    interp = null;
    parser = null;
  }
}
