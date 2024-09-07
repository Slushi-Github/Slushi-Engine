package;

import haxe.Json;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

typedef Library =
{
  var name:String;
  var type:String;
  var ?version:String;
  var ?dir:String;
  var ?ref:String;
  var ?url:String;
}

class Main
{
  public static function main():Void
  {
    // Create a folder to prevent messing with hmm libraries
    if (!FileSystem.exists(".haxelib")) FileSystem.createDirectory(".haxelib");

    // brief explanation: first we parse a json containing the library names, data, and such
    final libs:Array<Library> = Json.parse(File.getContent('./hmm.json')).dependencies;

    // now we loop through the data we currently have
    for (data in libs)
    {
      // and install the libraries, based on their type
      switch (data.type)
      {
        case "install", "haxelib": // for libraries only available in the haxe package manager
          var version:String = data.version == null ? "" : data.version;
          Sys.command('haxelib install ${data.name} ${version} --always');
        case "git": // for libraries that contain git repositories
          var ref:String = data.ref == null ? "" : data.ref;
          Sys.command('haxelib git ${data.name} ${data.url} ${ref} --always');
        default: // and finally, throw an error if the library has no type
          Sys.println('[SLUSHI ENGINE SETUP]: Unable to resolve library of type "${data.type}" for library "${data.name}"');
      }
    }
  }
}
