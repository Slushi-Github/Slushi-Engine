package objects.note.constant;

// If you want to make a custom note type, you should search for:
// "function set_noteType"
import flixel.graphics.FlxGraphic;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import backend.NoteTypesConfigConstant3D;
import backend.Rating;
import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;
import openfl.Assets;
import utils.tools.ICloneable;
#if SCEModchartingTools
import modcharting.NotePositionData;
import modcharting.SustainStrip;
#end
import openfl.display.TriangleCulling;
import openfl.geom.Vector3D;
import openfl.geom.ColorTransform;
import lime.math.Vector2;
import objects.note.Note;
import objects.note.constant.Constant3DStrumArrow;

using StringTools;

/**
 * The Note object used as nothing, used freely for use as a Constant 3D Note to modify.
 *
 * If you want to make a custom note type, you should search for: "function set_noteType"
 */
class Constant3DNote extends ModchartArrow implements ICloneable<Constant3DNote>
{
  // Modcharting Stuff ---->
  // Galxay stuff
  private static var alphas:Map<String, Map<String, Map<Int, Array<Float>>>> = new Map();
  private static var indexes:Map<String, Map<String, Map<Int, Array<Int>>>> = new Map();
  private static var glist:Array<FlxGraphic> = [];

  public var gpix:FlxGraphic = null;
  public var oalp:Float = 1;
  public var oanim:String = "";

  // <----
  public static var globalRgbShaders:Array<RGBPalette> = [];
  public static var globalQuantRgbShaders:Array<RGBPalette> = [];
  public static var instance:Constant3DNote = null;

  // This is needed for the hardcoded note types to appear on the Chart Editor,
  // It's also used for backwards compatibility with 0.1 - 0.3.2 charts.
  public static final defaultNoteTypes:Array<String> = [
    '', // Always leave this one empty pls
    'Alt Animation',
    'Hey!',
    'Hurt Constant3DNote',
    'GF Sing',
    'Mom Sing',
    'No Animation'
  ];

  #if SCEModchartingTools
  public var mesh:SustainStrip;
  public var notePositionData:NotePositionData = NotePositionData.get();
  #end

  // We can now edit the time they spawn, useful for Modifiers (MT and non-MT)
  public var spawnTime:Float = 2000;

  public var holdNote:SustainTrail;
  public var eventNote:EventNote;

  public var eventLength:Int = 0;
  public var eventName:String = null;
  public var eventTime:Float = 0.0;
  public var params:Array<String> = [];

  public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();

  public var strumTime:Float = 0;
  public var noteData:Int = 0;
  public var strumLine:Int = 0;

  public var mustPress:Bool = false;
  public var canBeHit:Bool = false;
  public var tooLate:Bool = false;

  public var wasGoodHit:Bool = false;
  public var missed:Bool = false;

  public var ignoreNote:Bool = false;
  public var hitByOpponent:Bool = false;
  public var noteWasHit:Bool = false;
  public var prevNote:Constant3DNote;
  public var nextNote:Constant3DNote;

  public var noteSection:Int = 0;

  public var spawned:Bool = false;

  public var noteSkin:String = null;
  public var dType:Int = 0;

  public var tail:Array<Constant3DNote> = []; // for sustains
  public var parent:Constant3DNote;
  public var blockHit:Bool = false; // only works for player

  public var sustainLength:Float = 0;
  public var isSustainNote:Bool = false;
  public var noteType(default, set):String = null;

  public var rgbShader:RGBShaderReference;

  public var animSuffix:String = '';
  public var gfNote:Bool = false;
  public var momNote:Bool = false;
  public var earlyHitMult:Float = 1;
  public var lateHitMult:Float = 1;
  public var lowPriority:Bool = false;

  public static var SUSTAIN_SIZE:Int = 44;
  public static var swagWidth:Float = 160 * 0.7;
  public static var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
  public static var defaultNoteSkin(default, never):String = 'noteSkins/NOTE_assets';

  public var noteSplashData:NoteSplashData =
    {
      disabled: false,
      texture: null,
      antialiasing: !PlayState.isPixelStage,
      useGlobalShader: false,
      useRGBShader: (PlayState.SONG != null) ? !(PlayState.SONG.options.disableSplashRGB == true) : true,
      a: ClientPrefs.data.splashAlpha
    };
  public var offsetX:Float = 0;
  public var offsetY:Float = 0;
  public var offsetAngle:Float = 0;
  public var multAlpha:Float = 1;
  public var multSpeed(default, set):Float = 1;

  public var copyX:Bool = true;
  public var copyY:Bool = true;
  public var copyAngle:Bool = true;
  public var copyAlpha:Bool = true;
  public var copyVisible:Bool = false;

  public var hitHealth:Float = 0.02;
  public var missHealth:Float = 0.01;
  public var rating:RatingWindow;
  public var ratingToString:String = '';

  public var texture(default, set):String = null;

  public var noAnimation:Bool = false;
  public var noMissAnimation:Bool = false;
  public var hitCausesMiss:Bool = false;
  public var distance:Float = 2000; // plan on doing scroll directions soon -bb

  public var hitsoundDisabled:Bool = false;
  public var hitsoundChartEditor:Bool = true;

  public var canBeMissed:Bool = false;

  /**
   * Forces the hitsound to be played even if the user's hitsound volume is set to 0
  **/
  public var hitsoundForce:Bool = false;

  public var hitsoundVolume(get, default):Float = 1.0;

  function get_hitsoundVolume():Float
  {
    if (ClientPrefs.data.hitsoundVolume > 0) return ClientPrefs.data.hitsoundVolume;
    return hitsoundForce ? hitsoundVolume : 0.0;
  }

  public var hitsound(default, set):String = 'hitsound';

  function set_hitsound(value:String):String
  {
    if (ClientPrefs.data.hitsoundType == 'Notes')
    {
      if (value == null || value == '')
      {
        if (ClientPrefs.data.hitsoundType == 'Notes' && ClientPrefs.data.hitSounds != "None") value = ClientPrefs.data.hitSounds;
      }

      if (value == null || value == '') value = 'hitsound';

      hitsound = value;
    }
    else
      hitsound = null;
    return value;
  }

  public var isHoldEnd(get, never):Bool;

  function get_isHoldEnd():Bool
  {
    return (!isAnimationNull() && getAnimationName().endsWith('end'));
  }

  // Quant Stuff
  public var quantColorsOnNotes:Bool = true;
  public var quantizedNotes:Bool = false;

  // Extra support for textures
  public var containsPixelTexture:Bool = false;
  public var pathNotFound:Bool = false;
  public var isPixel:Bool = false;
  public var changedSkin:Bool = false;

  // For comfert.
  public var notePathLib:String = null;

  public static var notITGNotes:Bool = false;

  public var canSplash:Bool = true;

  public var replacentAnimation:String = '';
  public var skipAnimation:Bool = false;

  private function set_multSpeed(value:Float):Float
  {
    resizeByRatio(value / multSpeed);
    multSpeed = value;
    return value;
  }

  public dynamic function resizeByRatio(ratio:Float) // haha funny twitter shit
  {
    if (isSustainNote && animation.curAnim != null && !isHoldEnd)
    {
      scale.y *= ratio;
      updateHitbox();
    }
  }

  private function set_texture(value:String):String
  {
    changedSkin = true;
    reloadNote(value);
    return value;
  }

  public dynamic function defaultRGB()
  {
    var noteData:Int = noteData;
    if (noteData > 3) noteData = noteData % 4;

    var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];
    if (texture.contains('pixel') || noteSkin.contains('pixel') || containsPixelTexture) arr = ClientPrefs.data.arrowRGBPixel[noteData];

    if (arr != null && noteData > -1 && noteData <= arr.length)
    {
      rgbShader.r = arr[0];
      rgbShader.g = arr[1];
      rgbShader.b = arr[2];
    }
    else
    {
      rgbShader.r = 0xFFFF0000;
      rgbShader.g = 0xFF00FF00;
      rgbShader.b = 0xFF0000FF;
    }
  }

  public dynamic function defaultRGBQuant()
  {
    var noteData:Int = noteData;
    var arrQuantRGB:Array<FlxColor> = ClientPrefs.data.arrowRGBQuantize[noteData];

    if (arrQuantRGB != null && noteData > -1 && noteData <= arrQuantRGB.length)
    {
      rgbShader.r = arrQuantRGB[0];
      rgbShader.g = arrQuantRGB[1];
      rgbShader.b = arrQuantRGB[2];
    }
    else
    {
      rgbShader.r = 0xFFFF0000;
      rgbShader.g = 0xFF00FF00;
      rgbShader.b = 0xFF0000FF;
    }
  }

  private function set_noteType(value:String):String
  {
    // var skin:String = 'noteSplashes';
    // if (PlayState.SONG != null && PlayState.SONG.options.splashSkin != "") skin = PlayState.SONG.options.splashSkin;
    quantizedNotes ? defaultRGBQuant() : defaultRGB();

    if (noteData > -1 && noteType != value)
    {
      switch (value)
      {
        case 'Hurt Constant3DNote':
          ignoreNote = true; // NO ONE WANTS TO GET HURT NOT EVEN THE OPPONENT :sob:
          // reloadNote('HURTNOTE_assets');
          // this used to change the note texture to HURTNOTE_assets.png,
          // but i've changed it to something more optimized with the implementation of RGBPalette:

          // quant shit
          quantColorsOnNotes = false;

          // note colors
          rgbShader.r = 0xFF101010;
          rgbShader.g = 0xFFFF0000;
          rgbShader.b = 0xFF990022;

          // splash data and colors
          // noteSplashData.r = 0xFFFF0000;
          // noteSplashData.g = 0xFF101010;
          noteSplashData.texture = 'noteSplashes-electric';

          // gameplay data
          lowPriority = true;
          missHealth = isSustainNote ? 0.25 : 0.1;
          hitCausesMiss = true;
          hitsound = 'cancelMenu';
          hitsoundChartEditor = false;
        case 'Alt Animation':
          animSuffix = '-alt';

        case 'No Animation':
          noAnimation = true;
          noMissAnimation = true;
        case 'GF Sing':
          gfNote = true;
        case 'Mom Sing':
          momNote = true;
      }
      if (value != null && value.length > 1) NoteTypesConfigConstant3D.applyNoteTypeData(this, value);
      if (hitsound != 'hitsound' && ClientPrefs.data.hitsoundVolume > 0) Paths.sound(hitsound); // precache new sound for being idiot-proof
      noteType = value;
    }
    return value;
  }

  public var parentStrumline:Strumline;

  // Used in-game to control the scroll speed within a song
  public var noteScrollSpeed(default, set):Float = 1.0;
  public var allowScrollSpeedOverride:Bool = true;

  private function set_noteScrollSpeed(value:Float):Float
  {
    var overrideSpeed:Float = parentStrumline?.scrollSpeed ?? 1.0;
    noteScrollSpeed = allowScrollSpeedOverride ? overrideSpeed : value;
    return allowScrollSpeedOverride ? overrideSpeed : value;
  }

  public var inEditor:Bool = false;

  public function new(strumTime:Float, noteData:Int, sustainNote:Bool = false, noteSkin:String, ?prevNote:Constant3DNote, ?createdFrom:Dynamic = null,
      ?scrollSpeed:Float, ?parentStrumline:Strumline, ?inEditor:Bool = false)
  {
    super();

    antialiasing = ClientPrefs.data.antialiasing;
    if (createdFrom == null) createdFrom = PlayState.instance;

    if (prevNote == null) prevNote = this;

    this.prevNote = prevNote;
    this.isSustainNote = sustainNote;
    this.noteSkin = noteSkin;
    this.moves = false;
    this.inEditor = inEditor;

    x += (ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
    // MAKE SURE ITS DEFINITELY OFF SCREEN?
    y -= 2000;
    this.strumTime = strumTime;
    if (!inEditor) this.strumTime += ClientPrefs.data.noteOffset;

    this.noteData = noteData;
    this.parentStrumline = parentStrumline;
    this.noteScrollSpeed = scrollSpeed;

    if (noteData > -1)
    {
      rgbShader = new RGBShaderReference(this, quantizedNotes ? initializeGlobalQuantRGBShader(noteData) : initializeGlobalRGBShader(noteData));
      texture = noteSkin;
      if (PlayState.SONG != null && PlayState.SONG.options.disableNoteRGB) rgbShader.enabled = false;

      x += swagWidth * (noteData);
      if (!isSustainNote && noteData < colArray.length)
      { // Doing this 'if' check to fix the warnings on Senpai songs
        var animToPlay:String = '';
        animToPlay = colArray[noteData % colArray.length];
        animation.play(animToPlay + 'Scroll');
      }
    }

    if (texture.contains('pixel') || noteSkin.contains('pixel')) containsPixelTexture = true;

    if (prevNote != null) prevNote.nextNote = this;

    if (isSustainNote && prevNote != null)
    {
      alpha = 0.6;
      multAlpha = 0.6;
      hitsoundDisabled = true;
      if (ClientPrefs.data.downScroll) flipY = true;

      offsetX += width / 2;
      copyAngle = false;

      animation.play(colArray[noteData % colArray.length] + 'holdend');

      updateHitbox();

      offsetX -= width / 2;

      if (texture.contains('pixel') || noteSkin.contains('pixel') || containsPixelTexture) offsetX += 30;

      if (prevNote.isSustainNote)
      {
        prevNote.animation.play(colArray[prevNote.noteData % colArray.length] + 'hold');

        prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05; // Because of how SCE works with sustains the value is static to 1.05 unless they break.
        prevNote.scale.y *= noteScrollSpeed;

        // Let's see if I might un-null it!
        if (!changedSkin)
        {
          if (texture.contains('pixel') || noteSkin.contains('pixel') || containsPixelTexture || isPixel)
          {
            prevNote.scale.y *= 1.19;
            prevNote.scale.y *= (6 / height); // Auto adjust note size
          }
        }
        prevNote.updateHitbox();
      }

      if (!changedSkin)
      {
        if (PlayState.isPixelStage)
        {
          scale.y *= PlayState.daPixelZoom;
          updateHitbox();
        }
      }
      earlyHitMult = 0;
    }
    else if (!isSustainNote)
    {
      centerOffsets();
      centerOrigin();
    }
    x += offsetX;
  }

  public dynamic function setupNote(mustPress:Bool, strumLine:Int, daSection:Int, noteType:String)
  {
    this.mustPress = mustPress;
    this.strumLine = strumLine;
    this.noteSection = daSection;
    this.noteType = noteType;
  }

  public static function initializeGlobalRGBShader(noteData:Int)
  {
    if (globalRgbShaders[noteData] == null)
    {
      var newRGB:RGBPalette = new RGBPalette();
      var arr:Array<FlxColor> = !PlayState.isPixelStage ? ClientPrefs.data.arrowRGB[noteData] : ClientPrefs.data.arrowRGBPixel[noteData];

      if (arr != null && noteData > -1 && noteData <= arr.length)
      {
        newRGB.r = arr[0];
        newRGB.g = arr[1];
        newRGB.b = arr[2];
      }
      else
      {
        newRGB.r = 0xFFFF0000;
        newRGB.g = 0xFF00FF00;
        newRGB.b = 0xFF0000FF;
      }
      globalRgbShaders[noteData] = newRGB;
    }
    return globalRgbShaders[noteData];
  }

  public static function initializeGlobalQuantRGBShader(noteData:Int)
  {
    if (globalQuantRgbShaders[noteData] == null)
    {
      var newRGB:RGBPalette = new RGBPalette();
      var arr:Array<FlxColor> = ClientPrefs.data.arrowRGBQuantize[noteData];

      if (arr != null && noteData > -1 && noteData <= arr.length)
      {
        newRGB.r = arr[0];
        newRGB.g = arr[1];
        newRGB.b = arr[2];
      }
      else
      {
        newRGB.r = 0xFFFF0000;
        newRGB.g = 0xFF00FF00;
        newRGB.b = 0xFF0000FF;
      }
      globalQuantRgbShaders[noteData] = newRGB;
    }
    return globalQuantRgbShaders[noteData];
  }

  var _lastNoteOffX:Float = 0;

  static var _lastValidChecked:String; // optimization

  public var originalHeight:Float = 6;
  public var correctionOffset:Float = 0; // dont mess with this

  public dynamic function reloadNote(noteStyle:String = '', postfix:String = '')
  {
    if (noteStyle == null) noteStyle = '';
    if (postfix == null) postfix = '';

    var skin:String = noteStyle + postfix;
    var animName:String = null;
    if (animation.curAnim != null) animName = animation.curAnim.name;

    var skinPixel:String = skin;
    var lastScaleY:Float = scale.y;
    var wasPixelNote:Bool = isPixel;
    var skinPostfix:String = getNoteSkinPostfix();
    var customSkin:String = skin + skinPostfix;
    var path:String = noteStyle.contains('pixel') ? 'pixelUI/' : '';

    var noteStylePaths:Bool = (Paths.fileExists('images/' + path + noteStyle + '.png', IMAGE)
      || Paths.fileExists('images/notes/' + path + noteStyle + '.png', IMAGE));
    var noteSkinPaths:Bool = (Paths.fileExists('images/' + path + noteSkin + '.png', IMAGE)
      || Paths.fileExists('images/notes/' + path + noteSkin + '.png', IMAGE));
    if (customSkin == _lastValidChecked || Paths.fileExists('images/' + path + customSkin + '.png', IMAGE))
    {
      skin = customSkin;
      _lastValidChecked = customSkin;
    }
    else
      skinPostfix = '';

    if (noteStylePaths && noteSkinPaths)
    {
      if (noteSkin != noteStyle) noteSkin = noteStyle;
      if (skin != noteSkin) skin = noteSkin;
    }
    else
      skin = customSkin;

    if (!inEditor)
    {
      if (!skin.contains('noteSkins') && rgbShader.enabled) rgbShader.enabled = false;
      else if (skin.contains('noteSkins') && !rgbShader.enabled) rgbShader.enabled = true;
    }

    loadNoteTexture(skin, skinPostfix, skinPixel);

    if (!inEditor)
    {
      var becomePixelNote:Bool = isPixel;

      if (isSustainNote)
      {
        scale.y = lastScaleY;

        if (changedSkin)
        {
          if (wasPixelNote && !becomePixelNote) // fixes the scaling
          {
            if (PlayState.SONG != null && !PlayState.SONG.options.notITG)
            {
              scale.y /= PlayState.daPixelZoom;
              scale.y *= 0.7;
            }

            offsetX += 3;
          }

          if (becomePixelNote && !wasPixelNote) // fixes the scaling
          {
            if (PlayState.SONG != null && !PlayState.SONG.options.notITG)
            {
              if (getNoteSkinPostfix().contains('future')) scale.y /= 1.26;
              else
                scale.y /= 0.7;
              scale.y *= PlayState.daPixelZoom;
            }

            offsetX -= 3;
          }
        }
      }
      updateHitbox();
    }

    if (animName != null) animation.play(animName, true);
    if (noteSkin != skin && noteSkin != noteStyle) noteSkin = skin;
  }

  public dynamic function loadNoteTexture(noteStyleType:String, skinPostfix:String, skinPixel:String)
  {
    var firstPathFound:Bool = #if MODS_ALLOWED FileSystem.exists(Paths.getPath('images/notes/$noteStyleType.png')) || #end Assets.exists(Paths.getPath('images/notes/$noteStyleType.png'));
    var secondPathFound:Bool = #if MODS_ALLOWED FileSystem.exists(Paths.getPath('images/$noteStyleType.png')) || #end Assets.exists(Paths.getPath('images/$noteStyleType.png'));
    switch (noteType)
    {
      default:
        switch (noteStyleType)
        {
          default:
            if ((texture.contains('pixel') || noteStyleType.contains('pixel') || containsPixelTexture)
              && !FileSystem.exists('$noteStyleType.xml'))
            {
              if (firstPathFound)
              {
                if (isSustainNote)
                {
                  var graphic = Paths.image(noteStyleType != "" ? 'notes/' + noteStyleType + 'ENDS' : ('pixelUI/' + skinPixel + 'ENDS' + skinPostfix),
                    notePathLib, !notITGNotes);
                  loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 2));
                  originalHeight = graphic.height / 2;
                }
                else
                {
                  var graphic = Paths.image(noteStyleType != "" ? 'notes/' + noteStyleType : ('pixelUI/' + skinPixel + skinPostfix), notePathLib, !notITGNotes);
                  loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 5));
                }

                loadNoteAnims(true);
              }
              else if (secondPathFound)
              {
                if (isSustainNote)
                {
                  var graphic = Paths.image(noteStyleType != "" ? noteStyleType + 'ENDS' : ('pixelUI/' + skinPixel + 'ENDS' + skinPostfix), notePathLib,
                    !notITGNotes);
                  loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 2));
                  originalHeight = graphic.height / 2;
                }
                else
                {
                  var graphic = Paths.image(noteStyleType != "" ? noteStyleType : ('pixelUI/' + skinPixel + skinPostfix), notePathLib, !notITGNotes);
                  loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 5));
                }

                loadNoteAnims(true);
              }
              else
              {
                var noteSkinNonRGB:Bool = (PlayState.SONG != null && PlayState.SONG.options.disableNoteRGB);
                if (isSustainNote)
                {
                  var graphic = Paths.image(noteSkinNonRGB ? 'pixelUI/NOTE_assetsENDS' : 'pixelUI/noteSkins/NOTE_assetsENDS' + getNoteSkinPostfix(),
                    notePathLib, !notITGNotes);
                  loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 2));
                  originalHeight = graphic.height / 2;
                }
                else
                {
                  var graphic = Paths.image(noteSkinNonRGB ? 'pixelUI/NOTE_assets' : 'pixelUI/noteSkins/NOTE_assets' + getNoteSkinPostfix(), notePathLib,
                    !notITGNotes);
                  loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 5));
                }

                loadNoteAnims(true);
              }
            }
            else
            {
              if (firstPathFound)
              {
                frames = Paths.getSparrowAtlas('notes/' + noteStyleType, notePathLib, !notITGNotes);
                loadNoteAnims();
              }
              else if (secondPathFound)
              {
                frames = Paths.getSparrowAtlas(noteStyleType, notePathLib, !notITGNotes);
                loadNoteAnims();
              }
              else
              {
                var noteSkinNonRGB:Bool = (PlayState.SONG != null && PlayState.SONG.options.disableNoteRGB);
                frames = Paths.getSparrowAtlas(noteSkinNonRGB ? "NOTE_assets" : "noteSkins/NOTE_assets" + getNoteSkinPostfix(), notePathLib, !notITGNotes);
                loadNoteAnims();
              }
            }
        }
    }
  }

  public static function getNoteSkinPostfix()
  {
    var skin:String = '';
    if (ClientPrefs.data.noteSkin != ClientPrefs.defaultData.noteSkin) skin = '-' + ClientPrefs.data.noteSkin.trim().toLowerCase().replace(' ', '_');
    return skin;
  }

  public dynamic function loadNoteAnims(?pixel:Bool = false)
  {
    if (colArray[noteData] == null) return;
    if (pixel)
    {
      isPixel = true;
      if (!inEditor) setGraphicSize(Std.int(width * PlayState.daPixelZoom));
      if (isSustainNote)
      {
        animation.add(colArray[noteData] + 'holdend', [noteData + 4], 12, true);
        animation.add(colArray[noteData] + 'hold', [noteData], 12, true);
      }
      else
        animation.add(colArray[noteData] + 'Scroll', [noteData + 4], 12, true);
      antialiasing = false;

      if (!inEditor && isSustainNote)
      {
        offsetX += _lastNoteOffX;
        _lastNoteOffX = (width - 7) * (PlayState.daPixelZoom / 2);
        offsetX -= _lastNoteOffX;
      }
    }
    else
    {
      isPixel = false;
      if (isSustainNote)
      {
        attemptToAddAnimationByPrefix('purpleholdend', 'pruple end hold', 24, true); // this fixes some retarded typo from the original note .FLA
        animation.addByPrefix(colArray[noteData] + 'holdend', colArray[noteData] + ' hold end', 24, true);
        animation.addByPrefix(colArray[noteData] + 'hold', colArray[noteData] + ' hold piece', 24, true);
      }
      else
        animation.addByPrefix(colArray[noteData] + 'Scroll', colArray[noteData] + '0');

      if (!inEditor)
      {
        setGraphicSize(Std.int(width * 0.7));
        updateHitbox();

        if (!isSustainNote)
        {
          centerOffsets();
          centerOrigin();
        }
      }
    }
  }

  function attemptToAddAnimationByPrefix(name:String, prefix:String, framerate:Int = 24, doLoop:Bool = true)
  {
    var animFrames = [];
    @:privateAccess
    animation.findByPrefix(animFrames, prefix); // adds valid frames to animFrames
    if (animFrames.length < 1) return;

    animation.addByPrefix(name, prefix, framerate, doLoop);
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);
    daOffsetX = offsetX; // adjust modchart notes offset
    containsPixelTexture = ((texture.contains('pixel') || noteSkin.contains('pixel')) && !containsPixelTexture);

    if (mustPress)
    {
      canBeHit = (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
        && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult));

      if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit) tooLate = true;
    }
    else
    {
      canBeHit = false;

      if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
      {
        if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition) wasGoodHit = true;
      }
    }

    if (tooLate && !inEditor)
    {
      if (alpha > 0.3) alpha = 0.3;
    }
  }

  public dynamic function followStrumArrow(myStrum:Constant3DStrumArrow, fakeCrochet:Float, newFollowSpeed:Float = 1)
  {
    var strumX:Float = myStrum.x;
    var strumY:Float = myStrum.y;
    var strumAngle:Float = myStrum.angle;
    var strumAlpha:Float = myStrum.alpha;
    var strumDirection:Float = myStrum.direction;
    var strumVisible:Bool = myStrum.visible;

    distance = (0.45 * (Conductor.songPosition - strumTime) * newFollowSpeed * multSpeed);
    if (!myStrum.downScroll) distance *= -1;

    if (copyAngle) angle = strumDirection - 90 + strumAngle + offsetAngle;

    if (copyAlpha) alpha = strumAlpha * multAlpha;

    if (copyX)
    {
      @:privateAccess
      x = strumX + offsetX + myStrum._dirCos * distance;
    }

    if (copyY)
    {
      @:privateAccess
      y = strumY + offsetY + correctionOffset + myStrum._dirSin * distance;
      if (myStrum.downScroll && isSustainNote)
      {
        if (texture.contains('pixel') || noteSkin.contains('pixel') || containsPixelTexture)
        {
          y -= PlayState.daPixelZoom * 9.5;
        }
        y -= (frameHeight * scale.y) - (swagWidth / 2);
      }
    }

    if (copyVisible) visible = strumVisible;
  }

  public dynamic function clipToStrumArrow(myStrum:Constant3DStrumArrow)
  {
    var center:Float = myStrum.y + offsetY + swagWidth / 2;
    if (isSustainNote && (mustPress || !ignoreNote) && (!mustPress || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit))))
    {
      var swagRect:FlxRect = clipRect;
      if (swagRect == null) swagRect = new FlxRect(0, 0, frameWidth, frameHeight);

      if (myStrum.downScroll)
      {
        if (y - offset.y * scale.y + height >= center)
        {
          swagRect.width = frameWidth;
          swagRect.height = (center - y) / scale.y;
          swagRect.y = frameHeight - swagRect.height;
        }
      }
      else if (y + offset.y * scale.y <= center)
      {
        swagRect.y = (center - y) / scale.y;
        swagRect.width = width / scale.x;
        swagRect.height = (height / scale.y) - swagRect.y;
      }
      clipRect = swagRect;
    }
  }

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (alpha < 0 || vertices == null || indices == null || uvtData == null || _point == null || offset == null)
    {
      return;
    }

    for (camera in cameras)
    {
      if (!camera.visible || !camera.exists) continue;
      // if (!isOnScreen(camera)) continue; // TODO: Update this code to make it work properly.

      // memory leak with drawTriangles :c

      getScreenPosition(_point, camera) /*.subtractPoint(offset)*/;
      var newGraphic:FlxGraphic = cast mapData();

      /*var shader = this.shader != null ? this.shader : new FlxShader();
        if (this.shader != shader) this.shader = shader;

        shader.bitmap.input = graphic.bitmap;
        shader.bitmap.filter = antialiasing ? LINEAR : NEAREST;

        var transforms:Array<ColorTransform> = [];
        var transfarm:ColorTransform = new ColorTransform();
        transfarm.redMultiplier = colorTransform.redMultiplier;
        transfarm.greenMultiplier = colorTransform.greenMultiplier;
        transfarm.blueMultiplier = colorTransform.blueMultiplier;
        transfarm.redOffset = colorTransform.redOffset;
        transfarm.greenOffset = colorTransform.greenOffset;
        transfarm.blueOffset = colorTransform.blueOffset;
        transfarm.alphaOffset = colorTransform.alphaOffset;
        transfarm.alphaMultiplier = colorTransform.alphaMultiplier * camera.alpha;

        for (n in 0...vertices.length)
          transforms.push(transfarm);

        var drawItem = camera.startTrianglesBatch(newGraphic, antialiasing, true, blend, true, shader);

        @:privateAccess
        {
          drawItem.addTrianglesColorArray(vertices, indices, uvtData, null, _point, camera._bounds, transforms);
      }*/

      camera.drawTriangles(newGraphic, vertices, indices, uvtData, null, _point, blend, true, antialiasing, colorTransform, shader);
      // camera.drawTriangles(processedGraphic, vertices, indices, uvtData, null, _point, blend, true, antialiasing);
      // trace("we do be drawin... something?\n verts: \n" + vertices);
    }

    // trace("we do be drawin tho");

    #if FLX_DEBUG
    if (FlxG.debugger.drawDebug) drawDebug();
    #end
  }

  function mapData():FlxGraphic
  {
    if (gpix == null || alpha != oalp || !animation.curAnim.finished || oanim != animation.curAnim.name)
    {
      if (!alphas.exists(noteType))
      {
        alphas.set(noteType, new Map());
        indexes.set(noteType, new Map());
      }
      if (!alphas.get(noteType).exists(animation.curAnim.name))
      {
        alphas.get(noteType).set(animation.curAnim.name, new Map());
        indexes.get(noteType).set(animation.curAnim.name, new Map());
      }
      if (!alphas.get(noteType).get(animation.curAnim.name).exists(animation.curAnim.curFrame))
      {
        alphas.get(noteType).get(animation.curAnim.name).set(animation.curAnim.curFrame, []);
        indexes.get(noteType).get(animation.curAnim.name).set(animation.curAnim.curFrame, []);
      }
      if (!alphas.get(noteType)
        .get(animation.curAnim.name)
        .get(animation.curAnim.curFrame)
        .contains(alpha))
      {
        var pix:FlxGraphic = FlxGraphic.fromFrame(frame, true);
        var nalp:Array<Float> = alphas.get(noteType).get(animation.curAnim.name).get(animation.curAnim.curFrame);
        var nindex:Array<Int> = indexes.get(noteType).get(animation.curAnim.name).get(animation.curAnim.curFrame);
        pix.bitmap.colorTransform(pix.bitmap.rect, colorTransform);
        glist.push(pix);
        nalp.push(alpha);
        nindex.push(glist.length - 1);
        alphas.get(noteType).get(animation.curAnim.name).set(animation.curAnim.curFrame, nalp);
        indexes.get(noteType).get(animation.curAnim.name).set(animation.curAnim.curFrame, nindex);
      }
      var dex = alphas.get(noteType)
        .get(animation.curAnim.name)
        .get(animation.curAnim.curFrame)
        .indexOf(alpha);
      gpix = glist[indexes.get(noteType).get(animation.curAnim.name).get(animation.curAnim.curFrame)[dex]];
      oalp = alpha;
      oanim = animation.curAnim.name;
    }
    return gpix;
  }

  @:noCompletion
  override function set_clipRect(rect:FlxRect):FlxRect
  {
    clipRect = rect;

    if (frames != null) frame = frames.frames[animation.frameIndex];

    return rect;
  }

  override public function clone():Constant3DNote
  {
    return new Constant3DNote(this.strumTime, this.noteData, this.isSustainNote, this.noteSkin, this.prevNote);
  }

  override public function destroy()
  {
    clipRect = flixel.util.FlxDestroyUtil.put(clipRect);
    _lastValidChecked = '';
    vertices = null;
    indices = null;
    uvtData = null;
    for (i in glist)
      i.destroy();
    alphas = new Map();
    indexes = new Map();
    glist = [];
    hasSetupRender = false;
    drawManual = false;
    super.destroy();
  }
}
