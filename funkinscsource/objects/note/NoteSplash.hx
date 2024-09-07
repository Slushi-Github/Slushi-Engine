package objects.note;

import flixel.system.FlxAssets.FlxShader;
import openfl.Assets;
import shaders.RGBPalette;
import shaders.RGBPixelShader.RGBPixelShaderReference;
import states.editors.NoteSplashEditorState;

private typedef RGB =
{
  r:Null<Int>,
  g:Null<Int>,
  b:Null<Int>
}

private typedef NoteSplashAnim =
{
  name:String,
  prefix:String,
  noteData:Int,
  indices:Array<Int>,
  offsets:Array<Float>,
  fps:Array<Int>
}

typedef NoteSplashConfig =
{
  animations:Map<String, NoteSplashAnim>,
  scale:Float,
  allowRGB:Bool,
  allowPixel:Bool,
  rgb:Array<Null<RGB>>
}

class NoteSplash extends FunkinSCSprite
{
  private var _textureLoaded:String = null;

  public var skin:String;
  public var config(default, set):NoteSplashConfig;

  public static var DEFAULT_SKIN:String = "noteSplashes/noteSplashes";
  public static var configs:Map<String, NoteSplashConfig> = new Map();

  private var string1NoteSkin:String = null;
  private var string2NoteSkin:String = null;

  public var containedPixelTexture(get, never):Bool;

  function get_containedPixelTexture():Bool
  {
    return (skin.contains('pixel') || babyArrow.texture.contains('pixel') || styleChoice.contains('pixel'));
  }

  public var opponentSplashes:Bool = false;
  public var styleChoice:String = '';

  public var noteDataMap:Map<Int, String> = new Map();
  public var rgbShader:RGBPixelShaderReference;

  public var babyArrow:StrumArrow;

  public var neededOffsetCorrection:Bool = false;

  public function new(?splash:String, ?opponentSplashes:Bool = false)
  {
    super();

    this.opponentSplashes = opponentSplashes;

    if (splash == null) skin = getTexture(opponentSplashes);

    rgbShader = new RGBPixelShaderReference();
    shader = rgbShader.shader;
    loadSplash(splash, opponentSplashes);
  }

  function loadSplash(?splash:String, ?opponentSplashes:Bool = false)
  {
    config = null; // Reset config to the default so when reloaded it can be set properly
    skin = null;

    var skin:String = splash;

    if (skin == null || skin.length < 1) skin = try getTexture(opponentSplashes)
    catch (e) null;

    this.skin = skin;

    try
      frames = Paths.getSparrowAtlas(skin)
    catch (e)
    {
      active = visible = false;
    }

    var path:String = chooseSplashPath(skin);
    if (configs.exists(path)) this.config = configs.get(path);
    else if (Paths.exists(path))
    {
      var config:Dynamic = haxe.Json.parse(Paths.getTextFromFile(path));

      if (config != null)
      {
        var tempConfig:NoteSplashConfig =
          {
            animations: new Map(),
            scale: config.scale,
            allowRGB: config.allowRGB,
            allowPixel: config.allowPixel,
            rgb: config.rgb
          }
        for (i in Reflect.fields(config.animations))
        {
          tempConfig.animations.set(i, Reflect.field(config.animations, i));
        }

        this.config = tempConfig;
      }
    }
  }

  function chooseSplashPath(skin:String):String
  {
    var path:String = 'images/noteSplashes/$skin.json';
    if (Paths.exists(path)) return path;
    path = 'images/$skin.json';
    if (Paths.exists(path)) return path;
    path = '$skin.json';
    if (Paths.exists(path)) return path;
    return null;
  }

  function getTexture(?opponentSplashes:Bool = false, ?note:Note = null):String
  {
    var finalSplashSkin:String = null;
    if (PlayState.instance != null)
    {
      if (ClientPrefs.getGameplaySetting('opponent')
        && !ClientPrefs.data.middleScroll) styleChoice = opponentSplashes ? PlayState.instance.bfStrumStyle : PlayState.instance.dadStrumStyle;
      else
        styleChoice = opponentSplashes ? PlayState.instance.bfStrumStyle : PlayState.instance.dadStrumStyle;

      string1NoteSkin = "noteSplashes-" + styleChoice;
      string2NoteSkin = "notes/noteSplashes-" + styleChoice;
    }
    var firstPath:Bool = #if MODS_ALLOWED FileSystem.exists(Paths.getPath('images/$string1NoteSkin.png')) || #end Assets.exists(Paths.getPath('images/$string1NoteSkin.png'));
    var secondPath:Bool = #if MODS_ALLOWED FileSystem.exists(Paths.getPath('images/$string2NoteSkin.png')) || #end Assets.exists(Paths.getPath('images/$string2NoteSkin.png'));
    if (note != null && note.noteSplashData.texture != null) finalSplashSkin = note.noteSplashData.texture;
    else
    {
      if (firstPath) finalSplashSkin = "noteSplashes-" + styleChoice;
      else if (secondPath) finalSplashSkin = "notes/noteSplashes-" + styleChoice;
      else
      {
        if (PlayState.SONG != null)
        {
          if (PlayState.SONG.options.splashSkin != null
            && PlayState.SONG.options.splashSkin.length > 0) finalSplashSkin = PlayState.SONG.options.splashSkin;
          else
            finalSplashSkin = PlayState.SONG.options.disableSplashRGB ? 'noteSplashes' : DEFAULT_SKIN + getSplashSkinPostfix();
        }
      }
    }
    return finalSplashSkin;
  }

  public dynamic function spawnSplashNote(note:Note, ?noteData:Int, ?opponentSplashes:Bool = false, ?randomize:Bool = true)
  {
    if (getTexture(opponentSplashes, note) != null) loadSplash(getTexture(opponentSplashes, note));

    if (note != null && note.noteSplashData.disabled) return;
    if (babyArrow != null) setPosition(babyArrow.x, babyArrow.y); // To prevent it from being misplaced for one game tick

    var noteData:Null<Int> = noteData;
    if (noteData == null) noteData = note != null ? note.noteData : 0;

    if (randomize)
    {
      var anims:Int = 0;
      var datas:Int = 0;
      var animArray:Array<Int> = [];
      while (true)
      {
        var data:Int = noteData % 4 + (datas * 4);
        if (!noteDataMap.exists(data) || !animation.exists(noteDataMap[data])) break;
        datas++;
        anims++;
      }
      if (anims > 1)
      {
        for (i in 0...anims)
        {
          var data = noteData % 4 + (i * 4);
          if (!animArray.contains(data)) animArray.push(data);
        }
      }

      if (animArray.length > 1) noteData = animArray[FlxG.random.bool() ? 0 : 1];
    }

    var anim:String = null;
    function playDefaultAnim(playAnim:Bool = true)
    {
      var animation:String = noteDataMap.get(noteData);
      if (animation != null && this.animation.exists(animation))
      {
        if (playAnim) this.animation.play(animation);
        anim = animation;
      }
      else
        visible = false;
    }

    playDefaultAnim();

    var tempShader:RGBPalette = null;
    if (config.allowRGB)
    {
      if (note == null) note = new Note(0, noteData, false, "");
      Note.initializeGlobalRGBShader(noteData % 4);
      function useDefault()
      {
        tempShader = Note.globalRgbShaders[noteData % 4];
      }

      if (((cast FlxG.state) is NoteSplashEditorState)
        || ((note.noteSplashData.useRGBShader) && (PlayState.SONG == null || !PlayState.SONG.options.disableNoteRGB)))
      {
        // If Note RGB is enabled:
        if ((!note.noteSplashData.useGlobalShader || ((cast FlxG.state) is NoteSplashEditorState)))
        {
          var colors = config.rgb;
          if (colors != null)
          {
            tempShader = new RGBPalette();
            for (i in 0...colors.length)
            {
              if (i > 2) break;

              var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData % 4];
              if (PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[noteData % 4];
              var rgb = colors[i];
              if (rgb == null)
              {
                if (i == 0) tempShader.r = arr[0];
                else if (i == 1) tempShader.g = arr[1];
                else if (i == 2) tempShader.b = arr[2];
                continue;
              }

              var r:Null<Int> = rgb.r;
              var g:Null<Int> = rgb.g;
              var b:Null<Int> = rgb.b;

              if (r == null || Math.isNaN(r) || r < 0) r = arr[0];
              if (g == null || Math.isNaN(g) || g < 0) g = arr[1];
              if (b == null || Math.isNaN(b) || b < 0) b = arr[2];

              var color:FlxColor = FlxColor.fromRGB(r, g, b);
              if (i == 0) tempShader.r = color;
              else if (i == 1) tempShader.g = color;
              else if (i == 2) tempShader.b = color;
            }
          }
          else
            useDefault();
        }
        else
          useDefault();
      }
    }
    if (!config.allowPixel) rgbShader.containsPixel = false;
    rgbShader.copyValues(tempShader);
    if (!config.allowPixel) rgbShader.pixelSize = 1;

    var conf = config.animations.get(anim);
    var offsets:Array<Float> = [0, 0];
    if (conf != null) offsets = conf.offsets;

    if (offsets != null)
    {
      centerOffsets();
      offset.set(offsets[0], offsets[1]);
    }
    animation.finishCallback = function(name:String) {
      kill();
    };

    if (!ClientPrefs.data.splashAlphaAsStrumAlpha) alpha = ClientPrefs.data.splashAlpha;
    if (note != null) alpha = note.noteSplashData.a;

    antialiasing = (ClientPrefs.data.antialiasing && (!containedPixelTexture && !PlayState.isPixelStage));
    if (note != null && note.noteSplashData.antialiasing == false) antialiasing = false;

    if (animation.curAnim != null && conf != null)
    {
      var minFps = conf.fps[0];
      if (minFps < 0) minFps = 0;
      var maxFps = conf.fps[1];
      if (maxFps < 0) maxFps = 0;
      animation.curAnim.frameRate = FlxG.random.int(minFps, maxFps);
    }

    if (neededOffsetCorrection)
    {
      offset.x += -58;
      offset.y += -55;
    }
  }

  public static function getSplashSkinPostfix()
  {
    var skin:String = '';
    if (ClientPrefs.data.splashSkin != ClientPrefs.defaultData.splashSkin) skin = '-' + ClientPrefs.data.splashSkin.trim().toLowerCase().replace(' ', '-');
    return skin;
  }

  function addAnimAndCheck(name:String, anim:String, ?framerate:Int = 24, ?loop:Bool = false)
  {
    var animFrames = [];
    @:privateAccess
    animation.findByPrefix(animFrames, anim); // adds valid frames to animFrames

    if (animFrames.length < 1) return false;

    animation.addByPrefix(name, anim, framerate, loop);
    return true;
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (babyArrow != null)
    {
      // cameras = babyArrow.cameras;
      setPosition(babyArrow.x, babyArrow.y);
    }
  }

  public static function createConfig():NoteSplashConfig
  {
    return {
      animations: new Map(),
      scale: 1,
      allowRGB: true,
      allowPixel: true,
      rgb: null
    }
  }

  public static function addAnimationToConfig(config:NoteSplashConfig, scale:Float, name:String, prefix:String, fps:Array<Int>, offsets:Array<Float>,
      indices:Array<Int>, noteData:Int):NoteSplashConfig
  {
    if (config == null) config = createConfig();
    config.animations.set(name,
      {
        name: name,
        noteData: noteData,
        prefix: prefix,
        indices: indices,
        offsets: offsets,
        fps: fps
      });
    config.scale = scale;
    return config;
  }

  function set_config(value:NoteSplashConfig):NoteSplashConfig
  {
    if (value == null) value = createConfig();

    noteDataMap.clear();

    for (i in value.animations)
    {
      var key:String = i.name;
      if (i.prefix.length > 0 && key != null && key.length > 0)
      {
        if (i.indices != null && i.indices.length > 0 && key != null && key.length > 0) animation.addByIndices(key, i.prefix, i.indices, "", i.fps[1], false);
        else
          animation.addByPrefix(key, i.prefix, i.fps[1], false);
        noteDataMap.set(i.noteData, key);
      }
    }
    scale.set(value.scale, value.scale);
    return config = value;
  }
}
