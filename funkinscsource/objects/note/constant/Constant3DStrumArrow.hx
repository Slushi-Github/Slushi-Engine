package objects.note.constant;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;
import openfl.Assets;
import openfl.display.TriangleCulling;
import openfl.geom.Vector3D;
import openfl.geom.ColorTransform;
#if SCEModchartingTools
import modcharting.NotePositionData;
#end
import lime.math.Vector2;

/**
 * A Copy of StrumArrow but constantly drawn in 3D.
 */
class Constant3DStrumArrow extends ModchartArrow
{
  // Galxay stuff
  private static var alphas:Map<String, Map<Int, Map<String, Map<Int, Array<Float>>>>> = new Map();
  private static var indexes:Map<String, Map<Int, Map<String, Map<Int, Array<Int>>>>> = new Map();
  private static var glist:Array<FlxGraphic> = [];

  public var gpix:FlxGraphic = null;
  public var oalp:Float = 1;
  public var oanim:String = "";

  public var rgbShader:RGBShaderReference;
  public var noteData:Int = 0;
  public var direction(default, set):Float; // plan on doing scroll directions soon -bb
  public var downScroll:Bool = false; // plan on doing scroll directions soon -bb
  public var sustainReduce:Bool = true;
  public var daStyle = 'style';
  public var player:Int;
  public var containsPixelTexture:Bool = false;
  public var pathNotFound:Bool = false;
  public var changedSkin:Bool = false;

  public var laneFollowsReceptor:Bool = true;

  public var bgLane:FlxSkewed;

  private var _dirSin:Float;
  private var _dirCos:Float;

  private function set_direction(_fDir:Float):Float
  {
    // 0.01745329251 = Math.PI / 180
    _dirSin = Math.sin(_fDir * 0.01745329251);
    _dirCos = Math.cos(_fDir * 0.01745329251);

    return direction = _fDir;
  }

  public var texture(default, set):String = null;

  private function set_texture(value:String):String
  {
    changedSkin = true;
    reloadNote(value);
    return value;
  }

  public var useRGBShader:Bool = true;

  public var quantizedNotes:Bool = false;

  public var strumPathLib:String = null;

  public static var notITGStrums:Bool = false;

  public var resetAnim:Float = 0;

  #if SCEModchartingTools
  public var strumPositionData:NotePositionData = NotePositionData.get();
  public var lineSegment:ArrowPathSegmentConstant3D;
  #end

  public var strumType(default, set):String = null;

  private function set_strumType(value:String):String
  {
    // Add custom strumTypes here!
    if (noteData > 0 && strumType != value)
    {
      strumType = value;
    }
    return value;
  }

  public var inEditor:Bool = false;

  public function new(x:Float, y:Float, leData:Int, player:Int, ?style:String, ?quantizedNotes:Bool, ?inEditor:Bool)
  {
    direction = 90;
    rgbShader = new RGBShaderReference(this, !quantizedNotes ? Note.initializeGlobalRGBShader(leData) : Note.initializeGlobalQuantRGBShader(leData));
    rgbShader.enabled = false;
    if (PlayState.SONG != null && PlayState.SONG.options.disableStrumRGB) useRGBShader = false;

    var arr:Array<FlxColor> = !quantizedNotes ? ClientPrefs.data.arrowRGB[leData] : ClientPrefs.data.arrowRGBQuantize[leData];
    if (texture.contains('pixel') || style.contains('pixel') || containsPixelTexture) arr = ClientPrefs.data.arrowRGBPixel[leData];

    if (leData <= arr.length)
    {
      @:bypassAccessor
      {
        rgbShader.r = arr[0];
        rgbShader.g = arr[1];
        rgbShader.b = arr[2];
      }
    }

    noteData = leData;
    this.player = player;
    this.noteData = leData;
    this.daStyle = style;
    this.quantizedNotes = quantizedNotes;
    this.inEditor = inEditor;
    super(x, y);

    var skin:String = null;
    if (PlayState.SONG != null
      && PlayState.SONG.options.strumSkin != null
      && PlayState.SONG.options.strumSkin.length > 1) skin = PlayState.SONG.options.strumSkin;
    else
      skin = Note.defaultNoteSkin;

    var customSkin:String = skin + Note.getNoteSkinPostfix();
    if (Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;
    if (style == null)
    {
      texture = skin;
      daStyle = skin;
    }
    scrollFactor.set();

    if (texture.contains('pixel') || style.contains('pixel') || daStyle.contains('pixel')) containsPixelTexture = true;
    loadNoteAnims(style != "" ? style : skin, true);

    if (ClientPrefs.data.vanillaStrumAnimations)
    {
      animation.callback = onAnimationFrame;
      animation.finishCallback = onAnimationFinished;
    }
  }

  #if SCEModchartingTools
  public dynamic function loadLineSegment()
  {
    lineSegment = new ArrowPathSegmentConstant3D(this, Std.int(Note.swagWidth) - 80, 2160);
  }
  #end

  var confirmHoldTimer:Float = -1;

  static final CONFIRM_HOLD_TIME:Float = 0.15;

  public dynamic function reloadNote(style:String)
  {
    var lastAnim:String = null;
    if (animation.curAnim != null) lastAnim = animation.curAnim.name;
    if (PlayState.instance != null)
    {
      PlayState.instance.bfStrumStyle = style;
      PlayState.instance.dadStrumStyle = style;
    }

    loadNoteAnims(style);
    updateHitbox();

    if (lastAnim != null)
    {
      playAnim(lastAnim, true);
    }
  }

  function onAnimationFrame(name:String, frameNumber:Int, frameIndex:Int):Void {}

  function onAnimationFinished(name:String):Void
  {
    // Run a timer before we stop playing the confirm animation.
    // On opponent, this prevent issues with hold notes.
    // On player, this allows holding the confirm key to fall back to press.
    if (name == 'confirm' && (player != 0))
    {
      confirmHoldTimer = 0;
    }
  }

  public var isPixel:Bool = false;

  public dynamic function loadNoteAnims(style:String, ?first:Bool = false)
  {
    daStyle = style;

    var foundFirstPath:Bool = #if MODS_ALLOWED FileSystem.exists(Paths.getPath('images/notes/$style.png',
      IMAGE)) || #end Assets.exists(Paths.getPath('images/notes/$style.png', IMAGE));
    var foundSecondPath:Bool = #if MODS_ALLOWED FileSystem.exists(Paths.getPath('images/$style.png',
      IMAGE)) || #end Assets.exists(Paths.getPath('images/$style.png', IMAGE));

    switch (strumType)
    {
      default:
        switch (style)
        {
          default:
            if ((texture.contains('pixel') || style.contains('pixel') || daStyle.contains('pixel') || containsPixelTexture)
              && !FileSystem.exists(Paths.getPath('$style.xml')))
            {
              if (foundFirstPath)
              {
                loadGraphic(Paths.image(style != "" ? 'notes/' + style : ('pixelUI/' + style), strumPathLib, !notITGStrums));
                width = width / 4;
                height = height / 5;
                loadGraphic(Paths.image(style != "" ? 'notes/' + style : ('pixelUI/' + style), strumPathLib, !notITGStrums), true, Math.floor(width),
                  Math.floor(height));
                addAnims(true);
              }
              else if (foundSecondPath)
              {
                loadGraphic(Paths.image(style != "" ? style : ('pixelUI/' + style), strumPathLib, !notITGStrums));
                width = width / 4;
                height = height / 5;
                loadGraphic(Paths.image(style != "" ? style : ('pixelUI/' + style), strumPathLib, !notITGStrums), true, Math.floor(width), Math.floor(height));
                addAnims(true);
              }
              else
              {
                var noteSkinNonRGB:Bool = (PlayState.SONG != null && PlayState.SONG.options.disableStrumRGB);
                loadGraphic(Paths.image(noteSkinNonRGB ? 'pixelUI/NOTE_assets' : 'pixelUI/noteSkins/NOTE_assets' + Note.getNoteSkinPostfix(), strumPathLib,
                  !notITGStrums));
                width = width / 4;
                height = height / 5;
                loadGraphic(Paths.image(noteSkinNonRGB ? 'pixelUI/NOTE_assets' : 'pixelUI/noteSkins/NOTE_assets' + Note.getNoteSkinPostfix(), strumPathLib,
                  !notITGStrums),
                  true, Math.floor(width), Math.floor(height));
                addAnims(true);
              }
            }
            else
            {
              if (foundFirstPath)
              {
                frames = Paths.getSparrowAtlas('notes/' + style, strumPathLib, !notITGStrums);
                addAnims();
              }
              else if (foundSecondPath)
              {
                frames = Paths.getSparrowAtlas(style, strumPathLib, !notITGStrums);
                addAnims();
              }
              else
              {
                var noteSkinNonRGB:Bool = (PlayState.SONG != null && PlayState.SONG.options.disableStrumRGB);
                frames = Paths.getSparrowAtlas(noteSkinNonRGB ? 'NOTE_assets' : 'noteSkins/NOTE_assets' + Note.getNoteSkinPostfix(), strumPathLib,
                  !notITGStrums);
                addAnims();
              }
            }
        }
    }

    if (first) updateHitbox();
  }

  public dynamic function addAnims(?pixel:Bool = false)
  {
    var notesAnim:Array<String> = quantizedNotes ? ['UP', 'UP', 'UP', 'UP', 'UP', 'UP', 'UP', 'UP'] : ['LEFT', 'DOWN', 'UP', 'RIGHT'];
    var pressAnim:Array<String> = quantizedNotes ? ['up', 'up', 'up', 'up', 'up', 'up', 'up', 'up'] : ['left', 'down', 'up', 'right'];
    var colorAnims:Array<String> = quantizedNotes ? ['green', 'green', 'green', 'green', 'green', 'green', 'green',
      'green'] : ['purple', 'blue', 'green', 'red'];

    if (pixel)
    {
      isPixel = true;
      animation.add('green', [6]);
      animation.add('red', [7]);
      animation.add('blue', [5]);
      animation.add('purple', [4]);

      if (!inEditor) setGraphicSize(Std.int(width * PlayState.daPixelZoom));
      antialiasing = false;

      animation.add('static', [0 + noteData]);
      animation.add('pressed', [4 + noteData, 8 + noteData], 12, false);
      animation.add('confirm', [12 + noteData, 16 + noteData], 12, false);
      animation.add('confirm-hold', [12 + noteData, 16 + noteData], 12, false);
    }
    else
    {
      isPixel = false;
      antialiasing = ClientPrefs.data.antialiasing;
      if (!inEditor) setGraphicSize(Std.int(width * 0.7));

      animation.addByPrefix(colorAnims[noteData], 'arrow' + notesAnim[noteData]);

      animation.addByPrefix('static', 'arrow' + notesAnim[noteData]);
      animation.addByPrefix('pressed', pressAnim[noteData] + ' press', 24, false);
      animation.addByPrefix('confirm', pressAnim[noteData] + ' confirm', 24, false);
      animation.addByPrefix('confirm-hold', pressAnim[noteData] + ' confirm', 24, false);
    }
  }

  public dynamic function loadLane()
  {
    bgLane = new FlxSkewed();
    bgLane.makeGraphic(Std.int(Note.swagWidth), 2160);
    bgLane.antialiasing = ClientPrefs.data.antialiasing;
    bgLane.color = FlxColor.BLACK;
    bgLane.visible = true;
    bgLane.alpha = ClientPrefs.data.laneTransparency * alpha;
    bgLane.x = x - 2;
    bgLane.y += -300;
    bgLane.updateHitbox();
  }

  public dynamic function postAddedToGroup()
  {
    playAnim('static');
    x += Note.swagWidth * noteData;
    x += 50;
    x += ((FlxG.width / 2) * player);
    ID = noteData;
  }

  override function update(elapsed:Float)
  {
    if (ClientPrefs.data.vanillaStrumAnimations)
    {
      if (confirmHoldTimer >= 0)
      {
        confirmHoldTimer += elapsed;

        // Ensure the opponent stops holding the key after a certain amount of time.
        if (confirmHoldTimer >= CONFIRM_HOLD_TIME)
        {
          confirmHoldTimer = -1;
          playAnim('static', true);
        }
      }
    }
    else
    {
      if (resetAnim > 0)
      {
        resetAnim -= elapsed;
        if (resetAnim <= 0)
        {
          playAnim('static');
          resetAnim = 0;
        }
      }
    }

    if (texture.contains('pixel') || daStyle.contains('pixel')) containsPixelTexture = true;

    if (bgLane != null)
    {
      bgLane.angle = direction - 90;
      if (laneFollowsReceptor) bgLane.x = (x - 2) - (bgLane.angle / 2);

      bgLane.alpha = ClientPrefs.data.laneTransparency * alpha;
      bgLane.visible = visible;
    }

    #if SCEModchartingTools
    if (lineSegment != null && strumPositionData != null)
    {
      lineSegment.updateCapture(elapsed);
    }
    #end
    super.update(elapsed);
  }

  public var handleRendering:Bool = true;

  public dynamic function holdConfirm():Void
  {
    if (!ClientPrefs.data.vanillaStrumAnimations) return;
    if (getLastAnimationPlayed() == "confirm-hold")
    {
      return;
    }
    else if (getLastAnimationPlayed() == "confirm")
    {
      if (isAnimationFinished())
      {
        confirmHoldTimer = -1;
        playAnim('confirm-hold', false, false);
      }
    }
    else
    {
      playAnim('confirm', false, false);
    }
  }

  override public function playAnim(anim:String, force:Bool = false, reverse:Bool = false, frame:Int = 0)
  {
    super.playAnim(anim, force, reverse, frame);

    _lastPlayedAnimation = anim;

    if ((anim.toLowerCase() == 'confirm' || anim.toLowerCase() == 'confirm-hold') && force)
    {
      confirmHoldTimer = (player != 0) ? -1 : 0;
    }

    animation.play(anim, force, reverse, frame);
    if (animation.curAnim != null)
    {
      centerOffsets();
      centerOrigin();
    }
    if (useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
  }

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (alpha <= 0 || vertices == null || indices == null || uvtData == null || _point == null || offset == null)
    {
      return;
    }

    for (camera in cameras)
    {
      if (!camera.visible || !camera.exists) continue;
      // if (!isOnScreen(camera)) continue; // TODO: Update this code to make it work properly.

      // memory leak with drawTriangles :c

      getScreenPosition(_point, camera) /*.subtractPoint(offset)*/;
      var newGraphic:FlxGraphic = mapData();

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
      if (!alphas.exists(strumType))
      {
        alphas.set(strumType, new Map());
        indexes.set(strumType, new Map());
      }
      if (!alphas.get(strumType).exists(ID))
      {
        alphas.get(strumType).set(ID, new Map());
        indexes.get(strumType).set(ID, new Map());
      }
      if (!alphas.get(strumType).get(ID).exists(animation.curAnim.name))
      {
        alphas.get(strumType).get(ID).set(animation.curAnim.name, new Map());
        indexes.get(strumType).get(ID).set(animation.curAnim.name, new Map());
      }
      if (!alphas.get(strumType)
        .get(ID)
        .get(animation.curAnim.name)
        .exists(animation.curAnim.curFrame))
      {
        alphas.get(strumType)
          .get(ID)
          .get(animation.curAnim.name)
          .set(animation.curAnim.curFrame, []);
        indexes.get(strumType)
          .get(ID)
          .get(animation.curAnim.name)
          .set(animation.curAnim.curFrame, []);
      }
      if (!alphas.get(strumType)
        .get(ID)
        .get(animation.curAnim.name)
        .get(animation.curAnim.curFrame)
        .contains(alpha))
      {
        var pix:FlxGraphic = FlxGraphic.fromFrame(frame, true);
        var nalp:Array<Float> = alphas.get(strumType)
          .get(ID)
          .get(animation.curAnim.name)
          .get(animation.curAnim.curFrame);
        var nindex:Array<Int> = indexes.get(strumType)
          .get(ID)
          .get(animation.curAnim.name)
          .get(animation.curAnim.curFrame);
        pix.bitmap.colorTransform(pix.bitmap.rect, colorTransform);
        glist.push(pix);
        nalp.push(alpha);
        nindex.push(glist.length - 1);
        alphas.get(strumType)
          .get(ID)
          .get(animation.curAnim.name)
          .set(animation.curAnim.curFrame, nalp);
        indexes.get(strumType)
          .get(ID)
          .get(animation.curAnim.name)
          .set(animation.curAnim.curFrame, nindex);
      }
      var dex = alphas.get(strumType)
        .get(ID)
        .get(animation.curAnim.name)
        .get(animation.curAnim.curFrame)
        .indexOf(alpha);
      gpix = glist[indexes.get(strumType)
        .get(ID)
        .get(animation.curAnim.name)
        .get(animation.curAnim.curFrame)[dex]];
      oalp = alpha;
      oanim = animation.curAnim.name;
    }
    return gpix;
  }

  override public function destroy():Void
  {
    vertices = null;
    indices = null;
    uvtData = null;
    for (i in glist)
      i.destroy();
    alphas = new Map();
    indexes = new Map();
    glist = [];
    super.destroy();
  }
}
