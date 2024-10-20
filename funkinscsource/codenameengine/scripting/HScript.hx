package codenameengine.scripting;

import haxe.io.Path;
import _hscript.Expr.ClassDecl;
import _hscript.Expr.ModuleDecl;
import _hscript.Expr.Error;
import _hscript.Parser;
import openfl.Assets;
import lime.utils.AssetType;
import _hscript.*;
import haxe.io.Path;

class HScript extends Script
{
  public var interp:Interp;
  public var parser:Parser;
  public var expr:Expr;
  public var decls:Array<ModuleDecl> = null;
  public var code:String;
  public var folderlessPath:String;

  var __importedPaths:Array<String>;

  public static function initParser()
  {
    var parser = new Parser();
    parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
    return parser;
  }

  public override function onCreate(path:String)
  {
    super.onCreate(path);

    interp = new Interp();

    try
    {
      if (FileSystem.exists(rawPath)) code = sys.io.File.getContent(rawPath);
    }
    catch (e)
      Debug.logError('Error while reading $path: ${Std.string(e)}');
    parser = initParser();
    folderlessPath = Path.directory(path);
    __importedPaths = [path];

    interp.errorHandler = _errorHandler;
    interp.importFailedCallback = importFailedCallback;
    interp.staticVariables = Script.staticVariables;
    interp.allowStaticVariables = interp.allowPublicVariables = true;

    interp.variables.set("trace", Reflect.makeVarArgs((args) -> {
      var v:String = Std.string(args.shift());
      for (a in args)
        v += ", " + Std.string(a);
      this.trace(v);
    }));

    codenameengine.scripting.GlobalScript.call("onScriptCreated", [this, "hscript"]);
    loadFromString(code);
  }

  public override function loadFromString(code:String)
  {
    try
    {
      if (code != null && code.trim() != "") expr = parser.parseString(code, Path.withoutDirectory(fileName));
    }
    catch (e:Error)
    {
      Debug.logError('failed once');
      _errorHandler(e);
    }
    catch (e)
    {
      Debug.logError('failed twice');
      _errorHandler(new Error(ECustom(e.toString()), 0, 0, fileName, 0));
    }

    return this;
  }

  private function importFailedCallback(cl:Array<String>):Bool
  {
    var assetsPath = Paths.getPath('source/${cl.join("/")}', TEXT);
    for (hxExt in CoolUtil.haxeExtensions)
    {
      var p = '$assetsPath.$hxExt';
      Debug.logInfo('What is the Archive name: ' + p);
      if (__importedPaths.contains(p)) return true; // no need to reimport again
      if (sys.FileSystem.exists(p))
      {
        var code = sys.io.File.getContent(p);
        var expr:Expr = null;
        try
        {
          if (code != null && code.trim() != "") expr = parser.parseString(code, Path.withoutDirectory(cl.join("/") + "." + hxExt));
        }
        catch (e:Error)
        {
          _errorHandler(e);
        }
        catch (e)
        {
          _errorHandler(new Error(ECustom(e.toString()), 0, 0, fileName, 0));
        }
        if (expr != null)
        {
          @:privateAccess
          interp.exprReturn(expr);
          __importedPaths.push(p);
        }
        return true;
      }
    }
    return false;
  }

  private function _errorHandler(error:Error)
  {
    var fileName = error.origin;
    if (remappedNames.exists(fileName)) fileName = remappedNames.get(fileName);
    var fn = '$fileName:${error.line}: ';
    var err = error.toString();
    if (err.startsWith(fn)) err = err.substr(fn.length);

    Debug.logError(fn);
    Debug.logError(err);

    // Reminder that this is so amazing to see error in-game
    #if HSCRIPT_ALLOWED
    if (states.PlayState.instance == FlxG.state) states.PlayState.instance.addTextToDebug('$fn, $err', FlxColor.RED, 16);
    #end
  }

  public override function setParent(parent:Dynamic)
  {
    interp.scriptObject = parent;
  }

  public override function onLoad()
  {
    @:privateAccess
    interp.execute(parser.mk(EBlock([]), 0, 0));
    if (expr != null)
    {
      interp.execute(expr);
      call("new", []);
    }
  }

  public override function reload()
  {
    // save variables

    interp.allowStaticVariables = interp.allowPublicVariables = false;
    var savedVariables:Map<String, Dynamic> = [];
    for (k => e in interp.variables)
    {
      if (!Reflect.isFunction(e))
      {
        savedVariables[k] = e;
      }
    }
    var oldParent = interp.scriptObject;
    onCreate(path);

    for (k => e in Script.getDefaultVariables(this))
      set(k, e);

    load();
    setParent(oldParent);

    for (k => e in savedVariables)
      interp.variables.set(k, e);

    interp.allowStaticVariables = interp.allowPublicVariables = true;
  }

  private override function onCall(funcName:String = null, parameters:Array<Dynamic> = null):Dynamic
  {
    if (interp == null) return null;
    if (!interp.variables.exists(funcName)) return null;

    var func = interp.variables.get(funcName);
    if (func != null && Reflect.isFunction(func)) return Reflect.callMethod(null, func, parameters);

    return null;
  }

  public override function get(val:String):Dynamic
  {
    return interp.variables.get(val);
  }

  public override function set(val:String, value:Dynamic)
  {
    interp.variables.set(val, value);
  }

  public override function trace(v:Dynamic)
  {
    var posInfo = interp.posInfos();
    Debug.logInfo('${fileName}:${posInfo.lineNumber}: ' + (Std.isOfType(v, String) ? v : Std.string(v)), posInfo);
  }

  public override function setPublicMap(map:Map<String, Dynamic>)
  {
    this.interp.publicVariables = map;
  }
}
