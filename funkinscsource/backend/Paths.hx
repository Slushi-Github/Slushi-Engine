package backend;

import backend.DataType;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.system.FlxAssets;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import openfl.geom.Rectangle;
import openfl.media.Sound;
// import openfl.display3D.textures.Texture; // GPU STUFF
import lime.utils.Assets;
import tjson.TJSON as Json;
#if cpp
import cpp.NativeGc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
#if MODS_ALLOWED
import backend.Mods;
#end

enum abstract CacheRemovalType(String) to String from String
{
  var ALL = "All";
  var GRAPHIC = "Graphic";
  var SOUND = "Sound";
}

@:access(openfl.display.BitmapData)
class Paths
{
  inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
  inline public static var VIDEO_EXT = "mp4";

  public static var tempFramesCache:Map<String, FlxFramesCollection> = [];

  public static function init()
  {
    FlxG.signals.preStateSwitch.add(function() {
      tempFramesCache.clear();
    });
  }

  public static function excludeAsset(key:String)
  {
    if (!dumpExclusions.contains(key)) dumpExclusions.push(key);
  }

  public static var dumpExclusions:Array<String> = ['assets/shared/music/freakyMenu.$SOUND_EXT'];

  /// haya I love you for the base cache dump I took to the max
  public static function clearUnusedMemory(cache:Bool = true)
  {
    // clear non local assets in the tracked assets list
    if (!cache) return;
    for (key in currentTrackedAssets.keys())
    {
      if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
      {
        destroyGraphic(currentTrackedAssets.get(key)); // get rid of the graphic
        currentTrackedAssets.remove(key); // and remove the key from local cache map
      }
    }
    /*var counter:Int = 0;
      for (key in currentTrackedAssets.keys())
      {
        // if it is not currently contained within the used local assets
        if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
        {
          // get rid of it
          var obj = cast(currentTrackedAssets.get(key), FlxGraphic);
          @:privateAccess
          if (obj != null)
          {
            obj.persist = false;
            obj.destroyOnNoUse = true;
            OpenFlAssets.cache.removeBitmapData(key);

            FlxG.bitmap._cache.remove(key);
            FlxG.bitmap.removeByKey(key);

            if (obj.bitmap.__texture != null)
            {
              obj.bitmap.__texture.dispose();
              obj.bitmap.__texture = null;
            }

            FlxG.bitmap.remove(obj);

            obj.dump();
            obj.bitmap.disposeImage();
            FlxDestroyUtil.dispose(obj.bitmap);

            obj.bitmap = null;

            obj.destroy();

            obj = null;

            currentTrackedAssets.remove(key);
            counter++;
            Debug.logTrace('Cleared $key form RAM');
            Debug.logTrace('Cleared and removed $counter assets.');
          }
        }
    }*/

    // run the garbage collector for good measure lmfao
    runGC();
  }

  public static function runGC()
  {
    #if cpp
    cpp.vm.Gc.run(false);
    cpp.vm.Gc.compact();
    #else
    System.gc();
    #end
  }

  // define the locally tracked assets
  public static var localTrackedAssets:Array<String> = [];

  @:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
  public static function clearStoredMemory(typeToRemove:CacheRemovalType = ALL)
  {
    var counterAssets:Int = 0;

    // @:privateAccess
    for (key in FlxG.bitmap._cache.keys())
    {
      if (typeToRemove == ALL || typeToRemove == GRAPHIC)
      {
        if (!currentTrackedAssets.exists(key)) destroyGraphic(FlxG.bitmap.get(key));
      }
      /*var obj = cast(FlxG.bitmap._cache.get(key), FlxGraphic);
        if (obj != null && !currentTrackedAssets.exists(key))
        {
          obj.persist = false;
          obj.destroyOnNoUse = true;

          OpenFlAssets.cache.removeBitmapData(key);

          FlxG.bitmap._cache.remove(key);

          FlxG.bitmap.removeByKey(key);

          if (obj.bitmap.__texture != null)
          {
            obj.bitmap.__texture.dispose();
            obj.bitmap.__texture = null;
          }

          FlxG.bitmap.remove(obj);

          obj.dump();

          obj.bitmap.disposeImage();
          FlxDestroyUtil.dispose(obj.bitmap);
          obj.bitmap = null;

          obj.destroy();
          obj = null;
          counterAssets++;
          Debug.logTrace('Cleared $key from RAM');
          Debug.logTrace('Cleared and removed $counterAssets cached assets.');
      }*/
    }

    // clear all sounds that are cached
    var counterSound:Int = 0;
    for (key => asset in currentTrackedSounds)
    {
      if (typeToRemove == ALL || typeToRemove == SOUND)
      {
        if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null)
        {
          Assets.cache.clear(key);
          currentTrackedSounds.remove(key);
        }
      }
      /*if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
        {
          OpenFlAssets.cache.clear(key);
          OpenFlAssets.cache.removeSound(key);
          currentTrackedSounds.remove(key);
          counterSound++;
          Debug.logTrace('Cleared $key from RAM');
          Debug.logTrace('Cleared and removed $counterSound cached sounds.');
      }*/
    }

    /*FlxG.sound.list.forEachAlive(function(sound:flixel.sound.FlxSound):Void
      {
        FlxG.sound.list.remove(sound, true);
        sound.stop();
        sound.destroy();
      });
      FlxG.sound.list.clear();

      // this totally isn't copied from polymod/backends/LimeBackend.hx trust me

      var lime_cache:lime.utils.AssetCache = cast lime.utils.Assets.cache;

      for (key in lime_cache.image.keys())
        lime_cache.image.remove(key);
      for (key in lime_cache.font.keys())
        lime_cache.font.remove(key);
      for (key in lime_cache.audio.keys())
      {
        lime_cache.audio.get(key).dispose();
        lime_cache.audio.remove(key);
    }*/

    // flags everything to be cleared out next unused memory clear
    localTrackedAssets = [];
    #if !html5 openfl.Assets.cache.clear("songs"); #end
  }

  inline static function destroyGraphic(graphic:FlxGraphic)
  {
    // free some gpu memory
    if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null) graphic.bitmap.__texture.dispose();
    FlxG.bitmap.remove(graphic);
  }

  static public var currentLevel:String;

  static public function setCurrentLevel(name:String):Void
    currentLevel = name.toLowerCase();

  public static function stripLibrary(path:String):String
  {
    var parts:Array<String> = path.split(':');
    if (parts.length < 2) return path;
    return parts[1];
  }

  public static function getLibrary(path:String):String
  {
    var parts:Array<String> = path.split(':');
    if (parts.length < 2) return 'preload';
    return parts[0];
  }

  public static function getPath(file:String, ?type:AssetType = TEXT, ?parentfolder:String, ?modsAllowed:Bool = true):String
  {
    #if MODS_ALLOWED
    if (modsAllowed)
    {
      var customFile:String = file;
      if (parentfolder != null) customFile = '$parentfolder/$file';

      var modded:String = modFolders(customFile);
      if (FileSystem.exists(modded)) return modded;
    }
    #end

    if (parentfolder != null) return getFolderPath(file, parentfolder);

    if (currentLevel != null && currentLevel != 'shared')
    {
      var levelPath = getFolderPath(file, currentLevel);
      if (OpenFlAssets.exists(levelPath, type)) return levelPath;
    }
    return getSharedPath(file);
  }

  static public function loadJSON(key:String, ?library:String):Dynamic
  {
    var rawJson = '';
    try
    {
      #if MODS_ALLOWED
      rawJson = modsJson(key).trim(); // that's because modsJson is for data/ and not other things lmao.
      #else
      rawJson = OpenFlAssets.getText(Paths.json(key, library)).trim();
      #end
    }
    catch (e)
    {
      Debug.logError('ERROR! $e');
      Debug.logError('Error parsing JSON or JSON does not exist');
      rawJson = null;
    }

    // Perform cleanup on files that have bad data at the end.
    if (rawJson != null)
    {
      while (!rawJson.endsWith("}"))
      {
        rawJson = rawJson.substr(0, rawJson.length - 1);
      }
    }

    try
    {
      // Attempt to parse and return the JSON data.
      if (rawJson != null) return cast Json.parse(rawJson);
      return null;
    }
    catch (e)
    {
      Debug.logError("AN ERROR OCCURRED parsing a JSON file.");
      Debug.logError('ERROR! ${e.message}');

      // Return null.
      return null;
    }
  }

  inline static public function getFolderPath(file:String, folder = "shared")
    return 'assets/$folder/$file';

  inline public static function getSharedPath(file:String = ''):String
    return 'assets/shared/$file';

  inline public static function getPreloadPath(file:String = ''):String
    return 'assets/$file';

  inline public static function file(file:String, type:AssetType = TEXT, ?library:String):String
    return getPath(file, type, library);

  inline static public function bitmapFont(key:String, ?library:String):FlxBitmapFont
    return FlxBitmapFont.fromAngelCode(image(key, library), fontXML(key, library));

  inline static public function fontXML(key:String, ?library:String):Xml
    return Xml.parse(File.getContent(getPath('images/$key.fnt', TEXT, library)));

  inline static public function txt(key:String, ?library:String):String
    return getPath('data/$key.txt', TEXT, library);

  inline static public function xml(key:String, ?library:String):String
    return getPath('data/$key.xml', TEXT, library);

  inline static public function animJson(key:String, ?library:String):String
    return getPath('images/$key/Animation.json', TEXT, library);

  inline static public function spriteMapJson(key:String, ?library:String):String
    return getPath('images/$key/spritemap.json', TEXT, library);

  inline static public function json(key:String, ?library:String):String
    return getPath('data/$key.json', TEXT, library);

  inline static public function shaderFragment(key:String, ?library:String):String
    return getPath('data/shaders/$key.frag', TEXT, library);

  inline static public function shaderVertex(key:String, ?library:String):String
    return getPath('data/shaders/$key.vert', TEXT, library);

  inline static public function lua(key:String, ?library:String):String
    return getPath('$key.lua', TEXT, library);

  inline static public function hx(key:String, ?library:String):String
    return getPath('$key.hx', TEXT, library);

  inline static public function html(key:String, ?library:String):String
    return getPath('$key.html', TEXT, library);

  inline static public function css(key:String, ?library:String):String
    return getPath('$key.css', TEXT, library);

  static public function video(key:String, type:String = VIDEO_EXT):String
  {
    #if MODS_ALLOWED
    var file:String = modsVideo(key, type);
    if (FileSystem.exists(file)) return file;
    #end
    return 'assets/videos/$key.$type';
  }

  inline static public function sound(key:String, ?modsAllowed:Bool = true):Sound
    return returnSound('sounds/$key', modsAllowed);

  inline static public function music(key:String, ?modsAllowed:Bool = true):Sound
    return returnSound('music/$key', modsAllowed);

  inline static public function ui(key:String, ?library:String):String
    return xml('ui/$key', library);

  inline static public function voices(?prefix:String = '', song:String, ?suffix:String = '', ?postfix:String = null, ?modsAllowed:Bool = true):Sound
  {
    var songKey:String = '${formatToSongPath(song)}/${prefix}Voices${suffix}';
    if (postfix != null) songKey += postfix.startsWith('-') ? postfix : '-' + postfix;
    return returnSound(songKey, 'songs', modsAllowed, false, true);
  }

  inline static public function inst(?prefix:String = '', song:String, ?suffix:String = '', ?modsAllowed:Bool = true):Sound
    return returnSound('${formatToSongPath(song)}/${prefix}Inst${suffix}', 'songs', modsAllowed, false, true);

  /**
   * Gets the path to an `Inst.mp3/ogg` song instrumental from songs:assets/songs/`song`/
   * @param song name of the song to get instrumental for
   * @param arguments arugments carried for mutiple uses such as prefix, suffix, parentfolder.
   * @param withExtension if it should return with the audio file extension `.mp3` or `.ogg`.
   * @return String
   */
  inline static public function getInstPath(path:String = "", ?arguements:Array<Dynamic>, ?withExtension:Bool = true):String
  {
    var completePath:String = formatToSongPath(path);
    var prefix:String = arguements[0] != null ? arguements[0] : "";
    var suffix:String = arguements[1] != null ? arguements[1] : "";
    var modsAllowed:Bool = arguements[2] != null ? arguements[2] : true;
    var parentfolder:String = arguements[3] != null ? arguements[3] : "songs";
    var isDirectPath:Bool = arguements[4] != null ? arguements[4] : false;
    var directPath:String = arguements[5] != null ? arguements[5] : "";
    var ext:String = withExtension ? '.${SOUND_EXT}' : '';
    return isDirectPath ? getPath(completePath, SOUND, parentfolder,
      modsAllowed) : getPath('$completePath/${prefix}Inst$suffix$ext', SOUND, parentfolder, modsAllowed);
  }

  /**
   * Gets the path to an `Voices.mp3/ogg` song instrumental from songs:assets/songs/`song`/
   * @param song name of the song to get instrumental for
   * @param arguements arugments carried for mutiple uses such as prefix, suffix, parentfolder.
   * @param withExtension if it should return with the audio file extension `.mp3` or `.ogg`.
   * @return String
   */
  inline static public function getVocalsPath(path:String = "", ?arguements:Array<Dynamic>, ?withExtension:Bool = true):String
  {
    var completePath:String = formatToSongPath(path);
    var prefix:String = arguements[0] != null ? arguements[0] : "";
    var suffix:String = arguements[1] != null ? arguements[1] : "";
    var modsAllowed:Bool = arguements[2] != null ? arguements[2] : true;
    var parentfolder:String = arguements[3] != null ? arguements[3] : "songs";
    var isDirectPath:Bool = arguements[4] != null ? arguements[4] : false;
    var directPath:String = arguements[5] != null ? arguements[5] : "";
    var ext:String = withExtension ? '.${SOUND_EXT}' : '';
    return isDirectPath ? getPath(completePath, SOUND, parentfolder,
      modsAllowed) : getPath('$completePath/${prefix}Voices$suffix$ext', SOUND, parentfolder, modsAllowed);
  }

  inline static public function soundRandom(key:String, min:Int, max:Int, ?modsAllowed:Bool = true)
    return sound(key + FlxG.random.int(min, max), modsAllowed);

  inline static public function scriptsForHandler(key:String, defaultPlace:String = null):String
  {
    if (defaultPlace == null) defaultPlace = 'classes';

    if (FileSystem.exists(getPath('$defaultPlace/$key.hx'))) return getPath('$defaultPlace/$key.hx');
    Debug.logTrace('File for script $key.hx not found!');
    return null;
  }

  public static var currentTrackedAssets:Map<String, FlxGraphic> = [];

  static public function image(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true, ?extraArgs:Array<Dynamic> = null):FlxGraphic
  {
    if (extraArgs == null) extraArgs = [true, true, "png", true];

    var startsWithImages:Bool = extraArgs[0];
    var usesPNGExt:Bool = extraArgs[1];
    var usedExt:String = extraArgs[2];
    var usesPaths:Bool = extraArgs[3];

    if (startsWithImages) key = Language.getFileTranslation('images/$key') + (usesPNGExt ? '.png' : '.$usedExt');
    else
      key = Language.getFileTranslation(key) + (usesPNGExt ? '.png' : '.$usedExt');

    var bitmap:BitmapData = null;
    if (currentTrackedAssets.exists(key))
    {
      localTrackedAssets.push(key);
      return currentTrackedAssets.get(key);
    }
    return cacheBitmap(key, parentfolder, bitmap, allowGPU, usesPaths);
  }

  public static var currentTrackedTextures:Map<String, Texture> = [];

  public static function cacheBitmap(key:String, ?parentfolder:String = null, ?bitmap:BitmapData = null, ?allowGPU:Bool = true, ?usePath:Bool = true):FlxGraphic
  {
    if (bitmap == null)
    {
      var file:String = usePath ? getPath(key, IMAGE, parentfolder, true) : key;
      #if MODS_ALLOWED if (FileSystem.exists(file)) bitmap = BitmapData.fromFile(file);
      else #end if (OpenFlAssets.exists(file, IMAGE)) bitmap = OpenFlAssets.getBitmapData(file);

      if (bitmap == null)
      {
        Debug.logTrace('oh no its returning null NOOOO ($file)');
        return null;
      }
    }

    if (allowGPU && ClientPrefs.data.cacheOnGPU && bitmap.image != null)
    {
      bitmap.lock();
      if (bitmap.__texture == null)
      {
        bitmap.image.premultiplied = true;
        bitmap.getTexture(FlxG.stage.context3D);
      }
      bitmap.getSurface();
      bitmap.disposeImage();
      bitmap.image.data = null;
      bitmap.image = null;
      bitmap.readable = true;
    }
    var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
    graph.persist = true;
    graph.destroyOnNoUse = false;

    currentTrackedAssets.set(key, graph);
    localTrackedAssets.push(key);
    return graph;
  }

  inline static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
  {
    final path:String = getPath(key, TEXT, !ignoreMods);
    #if sys
    return (FileSystem.exists(path)) ? File.getContent(path) : null;
    #else
    return (OpenFlAssets.exists(path, TEXT)) ? Assets.getText(path) : null;
    #end
  }

  inline static public function font(key:String):String
  {
    #if MODS_ALLOWED
    final file:String = modsFont(key);
    if (FileSystem.exists(file)) return file;
    #end
    return 'assets/shared/data/fonts/$key';
  }

  public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?parentfolder:String = null)
  {
    #if MODS_ALLOWED
    if (!ignoreMods)
    {
      final modKey:String = parentfolder == 'songs' ? 'songs/$key' : key;
      for (mod in Mods.getGlobalMods())
        if (FileSystem.exists(mods('$mod/$modKey'))) return true;
      if (FileSystem.exists(mods(Mods.currentModDirectory + '/' + modKey)) || FileSystem.exists(mods(modKey))) return true;
    }
    #end
    return (OpenFlAssets.exists(getPath(key, type, parentfolder, false)));
  }

  // less optimized but automatic handling
  static public function getAtlas(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var useMod = false;
    final imageLoaded:FlxGraphic = image(key, parentfolder, allowGPU);
    final myXml:Dynamic = getPath('images/$key.xml', TEXT, parentfolder, true);
    if (OpenFlAssets.exists(myXml) #if MODS_ALLOWED || (FileSystem.exists(myXml) && (useMod = true)) #end)
    {
      #if MODS_ALLOWED
      return FlxAtlasFrames.fromSparrow(imageLoaded, (useMod ? File.getContent(myXml) : myXml));
      #else
      return FlxAtlasFrames.fromSparrow(imageLoaded, myXml);
      #end
    }
    else
    {
      final myJson:Dynamic = getPath('images/$key.json', TEXT, parentfolder, true);
      if (OpenFlAssets.exists(myJson) #if MODS_ALLOWED || (FileSystem.exists(myJson) && (useMod = true)) #end)
      {
        #if MODS_ALLOWED
        return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, (useMod ? File.getContent(myJson) : myJson));
        #else
        return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, myJson);
        #end
      }
    }
    return getPackerAtlas(key, parentfolder);
  }

  static public function checkForImage(key:String, ?parentfolder:String, checkForAtlas:Bool = false, ?ext:String = "png")
  {
    if (checkForAtlas)
    {
      var atlasPath = getPath('images/$key/spritemap.$ext');
      var multiplePath = getPath('images/$key/1.$ext');
      if (atlasPath != null && FileSystem.exists(atlasPath)) return atlasPath.substr(0, atlasPath.length - 14);
      if (multiplePath != null && FileSystem.exists(multiplePath)) return multiplePath.substr(0, multiplePath.length - 6);
    }
    if (FileSystem.exists(modFolders('images/$key.$ext'))) return modFolders('images/$key.$ext');
    else if (FileSystem.exists(modFolders('$parentfolder/images/$key.ext'))) return modFolders('$parentfolder/images/$key.$ext');
    else if (FileSystem.exists(getPath('images/$key.$ext'))) return getPath('images/$key.$ext');
    return 'images/$key.$ext';
  }

  static public function loadFrames(endPath:Array<String>, Unique:Bool = false, Key:String = null):FlxFramesCollection
  {
    // I found the problem at long last and fixed it!!!!
    var notExts:String = switch (haxe.io.Path.extension(endPath[0]).toLowerCase())
    {
      case "png": #if MODS_ALLOWED modFolders(endPath[0].substring(0,
          endPath[0].length - 4)) #else getPath(endPath[0].substring(0, endPath[0].length - 4)) #end;
      default: #if MODS_ALLOWED modFolders(endPath[0]) #else endPath[0] #end;
    }
    var noExt:String = haxe.io.Path.withoutExtension(getPath(endPath[0]));
    var hasNoEx:String = haxe.io.Path.withoutExtension(endPath[0]);
    var noSecond:String = endPath[1];

    if (FileSystem.exists('$notExts/1.png'))
    {
      Debug.logInfo('multiple sprite sheets on $notExts.');
      // MULTIPLE SPRITESHEETS!!

      var graphic = FlxG.bitmap.add("flixel/images/logo/default.png", false, '$notExts/mult');
      var frames = codenameengine.backend.assets.MultiFramesCollection.findFrame(graphic);
      if (frames != null) return frames;

      Debug.logInfo("no frames yet for multiple atlases!!");
      var cur = 1;
      var finalFrames = new codenameengine.backend.assets.MultiFramesCollection(graphic);
      while (FileSystem.exists('$notExts/$cur.png'))
      {
        var spr = loadFrames(['$notExts/$cur.png']);
        finalFrames.addFrames(spr);
        cur++;
      }
      return finalFrames;
    }
    else if (FileSystem.exists('$noExt/1.png'))
    {
      Debug.logInfo('multiple sprite sheets on $noExt.');
      // MULTIPLE SPRITESHEETS!!

      var graphic = FlxG.bitmap.add("flixel/images/logo/default.png", false, '$noExt/mult');
      var frames = codenameengine.backend.assets.MultiFramesCollection.findFrame(graphic);
      if (frames != null) return frames;

      Debug.logInfo("no frames yet for multiple atlases!!");
      var cur = 1;
      var finalFrames = new codenameengine.backend.assets.MultiFramesCollection(graphic);
      while (FileSystem.exists('$noExt/$cur.png'))
      {
        var spr = loadFrames(['$noExt/$cur.png']);
        finalFrames.addFrames(spr);
        cur++;
      }
      return finalFrames;
    }
    else if (FileSystem.exists('$hasNoEx/1.png'))
    {
      Debug.logInfo('multiple sprite sheets on $hasNoEx.');
      // MULTIPLE SPRITESHEETS!!

      var graphic = FlxG.bitmap.add("flixel/images/logo/default.png", false, '$hasNoEx/mult');
      var frames = codenameengine.backend.assets.MultiFramesCollection.findFrame(graphic);
      if (frames != null) return frames;

      Debug.logInfo("no frames yet for multiple atlases!!");
      var cur = 1;
      var finalFrames = new codenameengine.backend.assets.MultiFramesCollection(graphic);
      while (FileSystem.exists('$hasNoEx/$cur.png'))
      {
        var spr = loadFrames(['$hasNoEx/$cur.png']);
        finalFrames.addFrames(spr);
        cur++;
      }
      return finalFrames;
    }
    else if (FileSystem.exists('$noExt.xml'))
    {
      return Paths.getSparrowAtlas(noExt);
    }
    else if (FileSystem.exists('$noExt.txt'))
    {
      return Paths.getPackerAtlas(noExt);
    }
    else if (FileSystem.exists('$noExt.json'))
    {
      return Paths.getJsonAtlas(noExt);
    }
    else if (FileSystem.exists(getPath('images/$noSecond.xml')))
    {
      return Paths.getSparrowAtlas(noSecond);
    }
    else if (FileSystem.exists(getPath('images/$noSecond.txt')))
    {
      return Paths.getPackerAtlas(noSecond);
    }
    else if (FileSystem.exists(getPath('images/$noSecond.json')))
    {
      return Paths.getJsonAtlas(noSecond);
    }
    else if (FileSystem.exists('$hasNoEx.xml'))
    {
      return Paths.getSparrowAtlasAlt(hasNoEx);
    }
    else if (FileSystem.exists('$hasNoEx.txt'))
    {
      return Paths.getPackerAtlasAlt(hasNoEx);
    }
    else if (FileSystem.exists('$hasNoEx.json'))
    {
      return Paths.getJsonAtlasAlt(hasNoEx);
    }

    var graph:FlxGraphic = null;
    try
    {
      graph = FlxG.bitmap.add(hasNoEx, Unique, Key);
    }
    catch (e:haxe.Exception)
    {
      Debug.logInfo(e.message);
      return null;
    }
    return graph.imageFrame;
  }

  /**
   * Gets frames at specified path.
   * @param key Path to the frames
   * @param library (Additional) library to load the frames from.
   */
  public static function getFrames(key:String, justKey:Bool = false, ?parentfolder:String = null, ?firstPath:String = null)
  {
    if (tempFramesCache.exists(key))
    {
      var frames = tempFramesCache[key];
      if (frames.parent != null && frames.parent.bitmap != null && frames.parent.bitmap.readable) return frames;
      else
        tempFramesCache.remove(key);
    }
    return tempFramesCache[key] = loadFrames(justKey ? [key, firstPath] : [Paths.checkForImage(key, parentfolder, true), firstPath]);
  }

  static public function getMultiAtlas(keys:Array<String>, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var parentFrames:FlxAtlasFrames = Paths.getAtlas(keys[0].trim());
    if (keys.length > 1)
    {
      var original:FlxAtlasFrames = parentFrames;
      parentFrames = new FlxAtlasFrames(parentFrames.parent);
      parentFrames.addAtlas(original, true);
      for (i in 1...keys.length)
      {
        var extraFrames:FlxAtlasFrames = Paths.getAtlas(keys[i].trim(), parentFolder, allowGPU);
        if (extraFrames != null) parentFrames.addAtlas(extraFrames, true);
      }
    }
    return parentFrames;
  }

  inline static public function getSparrowAtlas(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var imageLoaded:FlxGraphic = image(key, parentfolder, allowGPU);
    #if MODS_ALLOWED
    var xmlExists:Bool = false;

    var xml:String = modsXml(key);
    if (FileSystem.exists(xml)) xmlExists = true;

    return FlxAtlasFrames.fromSparrow(imageLoaded,
      (xmlExists ? File.getContent(xml) : getPath(Language.getFileTranslation('images/$key') + '.xml', TEXT, parentfolder)));
    #else
    return FlxAtlasFrames.fromSparrow(imageLoaded, getPath(Language.getFileTranslation('images/$key') + '.xml', TEXT, parentfolder));
    #end
  }

  inline static public function getSparrowAtlasAlt(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var imageLoaded:FlxGraphic = image(key, parentfolder, allowGPU, [false, true, "png", false]);
    return FlxAtlasFrames.fromSparrow(imageLoaded, File.getContent(Language.getFileTranslation(key) + '.xml'));
  }

  inline static public function getPackerAtlas(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var imageLoaded:FlxGraphic = image(key, parentfolder, allowGPU);
    #if MODS_ALLOWED
    var txtExists:Bool = false;

    var txt:String = modsTxt(key);
    if (FileSystem.exists(txt)) txtExists = true;

    return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded,
      (txtExists ? File.getContent(txt) : getPath(Language.getFileTranslation('images/$key') + '.txt', TEXT, parentfolder)));
    #else
    return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, getPath(Language.getFileTranslation('images/$key') + '.txt', TEXT, parentfolder));
    #end
  }

  inline static public function getPackerAtlasAlt(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var imageLoaded:FlxGraphic = image(key, parentfolder, allowGPU, [false, true, "png", false]);
    return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, File.getContent(Language.getFileTranslation(key) + '.txt'));
  }

  inline static public function getXmlAtlas(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var imageLoaded:FlxGraphic = image(key, parentfolder, allowGPU);
    #if MODS_ALLOWED
    var xmlExists:Bool = false;

    var xml:String = modsXml(key);
    if (FileSystem.exists(xml)) xmlExists = true;

    return FlxAtlasFrames.fromTexturePackerXml(imageLoaded,
      (xmlExists ? File.getContent(xml) : getPath(Language.getFileTranslation('images/$key') + '.xml', TEXT, parentfolder)));
    #else
    return FlxAtlasFrames.fromTexturePackerXml(imageLoaded, getPath(Language.getFileTranslation('images/$key') + '.xml', TEXT, parentfolder));
    #end
  }

  inline static public function getXmlAtlasAlt(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var imageLoaded:FlxGraphic = image(key, parentfolder, allowGPU, [false, true, "png", false]);
    return FlxAtlasFrames.fromTexturePackerXml(imageLoaded, File.getContent(Language.getFileTranslation(key) + '.xml'));
  }

  inline static public function getJsonAtlas(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var imageLoaded:FlxGraphic = image(key, parentfolder, allowGPU);
    #if MODS_ALLOWED
    var jsonExists:Bool = false;

    var json:String = modsImagesJson(key);
    if (FileSystem.exists(json)) jsonExists = true;

    return FlxAtlasFrames.fromTexturePackerJson(imageLoaded,
      (jsonExists ? File.getContent(json) : getPath(Language.getFileTranslation('images/$key') + '.json', TEXT, parentfolder)));
    #else
    return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, getPath(Language.getFileTranslation('images/$key') + '.json', TEXT, parentfolder));
    #end
  }

  inline static public function getJsonAtlasAlt(key:String, ?parentfolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
  {
    var imageLoaded:FlxGraphic = image(key, parentfolder, allowGPU, [false, true, "png", false]);
    return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, File.getContent(Language.getFileTranslation(key) + '.json'));
  }

  inline static public function getAtlasAltFromData(key:String, data:DataType)
  {
    switch (data)
    {
      case GENERICXML:
        return getXmlAtlasAlt(key);
      case SPARROW:
        return getSparrowAtlasAlt(key);
      case PACKER:
        return getPackerAtlasAlt(key);
      case JSON:
        return getJsonAtlasAlt(key);
    }
  }

  inline static public function getAtlasFromData(key:String, data:DataType)
  {
    switch (data)
    {
      case GENERICXML:
        return getXmlAtlas(key);
      case SPARROW:
        return getSparrowAtlas(key);
      case PACKER:
        return getPackerAtlas(key);
      case JSON:
        return getJsonAtlas(key);
    }
  }

  inline static public function formatToSongPath(path:String, ?type:String = 'lowercased'):String
  {
    final invalidChars = ~/[~&;:<>#\s]/g;
    final hideChars = ~/[.,'"%?!]/g;

    var finalResult:String = hideChars.replace(invalidChars.replace(path, '-'), '').trim();
    if (type == null) type = 'lowercased';

    switch (type)
    {
      case 'lowercased':
        finalResult = finalResult.toLowerCase();
    }
    return finalResult;
  }

  public static var currentTrackedSounds:Map<String, Sound> = [];

  public static function returnSound(key:String, ?path:String, ?modsAllowed:Bool = true, ?beepOnNull:Bool = true, ?usePath:Bool = true)
  {
    var file:String = usePath ? getPath(Language.getFileTranslation(key) + '.$SOUND_EXT', SOUND, path, modsAllowed) : key;

    if (!currentTrackedSounds.exists(file))
    {
      #if sys
      if (FileSystem.exists(file)) currentTrackedSounds.set(file, Sound.fromFile(file));
      #else
      if (OpenFlAssets.exists(file, SOUND)) currentTrackedSounds.set(file, OpenFlAssets.getSound(file));
      #end
    else if (beepOnNull)
    {
      Debug.logError('SOUND NOT FOUND: $key, PATH: $path');
      return FlxAssets.getSound('flixel/sounds/beep');
    }
    }

    localTrackedAssets.push(file);
    return currentTrackedSounds.get(file);
  }

  #if MODS_ALLOWED
  inline static public function mods(key:String = ''):String
    return 'mods/' + key;

  inline static public function modsFont(key:String):String
    return modFolders('data/fonts/' + key);

  inline static public function modsJson(key:String):String
    return modFolders('data/' + key + '.json');

  inline static public function modsVideo(key:String, type:String = VIDEO_EXT):String
    return modFolders('videos/' + key + '.' + type);

  inline static public function modsSounds(path:String, key:String):String
    return modFolders(path + '/' + key + '.' + SOUND_EXT);

  inline static public function modsImages(key:String):String
    return modFolders('images/' + key + '.png');

  inline static public function modsXml(key:String):String
    return modFolders('images/' + key + '.xml');

  inline static public function modsTxt(key:String):String
    return modFolders('images/' + key + '.txt');

  inline static public function modsImagesJson(key:String)
    return modFolders('images/' + key + '.json');

  inline static public function modsShaderFragment(key:String)
    return modFolders('data/shaders/' + key + '.frag');

  inline static public function modsShaderVertex(key:String)
    return modFolders('data/shaders/' + key + '.vert');

  inline static public function modsAchievements(key:String)
    return modFolders('data/achievements/' + key + '.json');

  static public function modFolders(key:String):String
  {
    if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
    {
      var fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
      if (FileSystem.exists(fileToCheck))
      {
        return fileToCheck;
      }
    }

    for (mod in Mods.getGlobalMods())
    {
      var fileToCheck:String = mods(mod + '/' + key);
      if (FileSystem.exists(fileToCheck)) return fileToCheck;
    }
    return 'mods/' + key;
  }
  #end

  #if flxanimate
  public static function loadAnimateAtlas(spr:FlxAnimate, folderOrImg:Dynamic, spriteJson:Dynamic = null, animationJson:Dynamic = null)
  {
    var changedAnimJson = false;
    var changedAtlasJson = false;
    var changedImage = false;

    if (spriteJson != null)
    {
      changedAtlasJson = true;
      spriteJson = File.getContent(spriteJson);
    }

    if (animationJson != null)
    {
      changedAnimJson = true;
      animationJson = File.getContent(animationJson);
    }

    // is folder or image path
    if (Std.isOfType(folderOrImg, String))
    {
      var originalPath:String = folderOrImg;
      for (i in 0...10)
      {
        var st:String = '$i';
        if (i == 0) st = '';

        if (!changedAtlasJson)
        {
          spriteJson = getTextFromFile('images/$originalPath/spritemap$st.json');
          if (spriteJson != null)
          {
            changedImage = true;
            changedAtlasJson = true;
            folderOrImg = image('$originalPath/spritemap$st');
            break;
          }
        }
        else if (fileExists('images/$originalPath/spritemap$st.png', IMAGE))
        {
          changedImage = true;
          folderOrImg = image('$originalPath/spritemap$st');
          break;
        }
      }

      if (!changedImage)
      {
        changedImage = true;
        folderOrImg = image(originalPath);
      }

      if (!changedAnimJson)
      {
        changedAnimJson = true;
        animationJson = getTextFromFile('images/$originalPath/Animation.json');
      }
    }

    spr.loadAtlasEx(folderOrImg, spriteJson, animationJson);
  }
  #end
}
