package objects;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;
import math.VectorHelpers;
import math.Vector3;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Vector;
import openfl.geom.ColorTransform;
import openfl.display.Shader;
import flixel.system.FlxAssets.FlxShader;

// Code from CNE (CodenameEngine)
// Edited by me -glow
class FunkinSCSprite extends FlxSkewed
{
  public var extraSpriteData:Map<String, Dynamic> = new Map<String, Dynamic>();

  public var zoomFactor:Float = 1;
  public var initialZoom:Float = 1;

  public var debugMode:Bool = false;
  public var failedLoadingAutoAtlas:Bool = false;

  #if flxanimate
  public var atlasPath:String;
  public var secondAtlasPath:String;
  #end

  public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
  {
    super(X, Y);

    if (SimpleGraphic != null)
    {
      if (SimpleGraphic is String) this.loadSprite(cast SimpleGraphic);
      else
        this.loadGraphic(SimpleGraphic);
    }
  }

  public static function copyFrom(source:FunkinSCSprite)
  {
    var spr = new FunkinSCSprite();
    @:privateAccess {
      spr.setPosition(source.x, source.y);
      spr.frames = source.frames;
      #if flxanimate if (source.atlas != null && source.atlasPath != null) spr.loadSprite(source.atlasPath, source.secondAtlasPath); #end
      spr.animation.copyFrom(source.animation);
      spr.visible = source.visible;
      spr.alpha = source.alpha;
      spr.antialiasing = source.antialiasing;
      spr.scale.set(source.scale.x, source.scale.y);
      spr.scrollFactor.set(source.scrollFactor.x, source.scrollFactor.y);
      spr.skew.set(source.skew.x, source.skew.y);
      spr.transformMatrix = source.transformMatrix;
      spr.matrixExposed = source.matrixExposed;
      spr.animOffsets = source.animOffsets.copy();
    }
    return spr;
  }

  override public function update(elapsed:Float)
  {
    super.update(elapsed);
    #if flxanimate
    if (!(this is Character))
    {
      if (this.isAnimateAtlas) this.atlas.update(elapsed);
    }
    #end
  }

  /**
   * Loads a sprite, image, or atlas.
   * @param path path to find
   * @param imageFile image file
   * @param newEndString ending string for multi-atlas that isn't found with ','
   * @param parentfolder the files parent folder it's found in.
   * @param forceLoad forces the function to load externl instead of already placed rules for loading sprite.
   */
  public dynamic function loadSprite(path:String, ?imageFile:String, ?newEndString:String = null, ?parentfolder:String = null, ?forceLoad:Bool = false)
  {
    #if flxanimate
    var atlasToFind:String = Paths.getPath(haxe.io.Path.withoutExtension(path) + '/Animation.json', TEXT);
    if (#if MODS_ALLOWED FileSystem.exists(atlasToFind) || #end openfl.utils.Assets.exists(atlasToFind)) isAnimateAtlas = true;
    #end

    if (!isAnimateAtlas) loadFrameAtlas(path, imageFile, parentfolder, newEndString, null, forceLoad);
    #if flxanimate
    else
      loadAnimateAtlas(atlasToFind, imageFile);
    #end
  }

  /**
   * Loads regular atlas frames (sparrow, packer, json, xml)
   * @param imageFile
   */
  public dynamic function loadFrameAtlas(path:String, imageFile:String, ?parentfolder:String, ?newEndString:String, ?searchWhenNull:Null<Bool> = null,
      ?forceLoad:Bool = false)
  {
    // Use a way for using mult frames lol
    if (!forceLoad) this.frames = Paths.getMultiAtlas(imageFile.split(','));
    else if ((searchWhenNull == null || searchWhenNull)
      && forceLoad) this.frames = Paths.getFrames(path, true, parentfolder, newEndString);
  }

  #if flxanimate
  public dynamic function loadAnimateAtlas(atlasToFind:String, imageFile:String)
  {
    this.atlasPath = atlasToFind;
    this.secondAtlasPath = imageFile;
    this.isAnimateAtlas = true;
    this.atlas = new FlxAnimate(this.x, this.y);
    this.atlas.showPivot = false;
    try
    {
      Paths.loadAnimateAtlas(this.atlas, imageFile);
    }
    catch (e:haxe.Exception)
    {
      this.failedLoadingAutoAtlas = true;
      Debug.logError('Could not load atlas ${path}: ${e.message}');
      Debug.logError(e.stack);
    }
  }
  #end

  public function beatHit(curBeat:Int) {}

  public function stepHit(curStep:Int) {}

  public function sectionHit(curSection:Int) {}

  public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
  {
    __doPreZoomScaleProcedure(camera);
    var r = super.getScreenBounds(newRect, camera);
    __doPostZoomScaleProcedure();
    return r;
  }

  public override function drawComplex(camera:FlxCamera)
  {
    super.drawComplex(camera);
  }

  public override function doAdditionalMatrixStuff(matrix:flixel.math.FlxMatrix, camera:FlxCamera)
  {
    super.doAdditionalMatrixStuff(matrix, camera);
    matrix.translate(-camera.width / 2, -camera.height / 2);

    var requestedZoom = FlxMath.lerp(1, camera.zoom, zoomFactor);
    var diff = requestedZoom / camera.zoom;
    matrix.scale(diff, diff);
    matrix.translate(camera.width / 2, camera.height / 2);
  }

  public override function getScreenPosition(?point:FlxPoint, ?Camera:FlxCamera):FlxPoint
  {
    if (__shouldDoScaleProcedure())
    {
      __oldScrollFactor.set(scrollFactor.x, scrollFactor.y);
      var requestedZoom = FlxMath.lerp(initialZoom, camera.zoom, zoomFactor);
      var diff = requestedZoom / camera.zoom;

      scrollFactor.scale(1 / diff);

      var r = super.getScreenPosition(point, Camera);

      scrollFactor.set(__oldScrollFactor.x, __oldScrollFactor.y);

      return r;
    }
    return super.getScreenPosition(point, Camera);
  }

  // SCALING FUNCS
  #if REGION
  private inline function __shouldDoScaleProcedure()
    return zoomFactor != 1;

  static var __oldScrollFactor:FlxPoint = new FlxPoint();
  static var __oldScale:FlxPoint = new FlxPoint();

  var __skipZoomProcedure:Bool = false;

  private function __doPreZoomScaleProcedure(camera:FlxCamera)
  {
    if (__skipZoomProcedure = !__shouldDoScaleProcedure()) return;
    __oldScale.set(scale.x, scale.y);
    var requestedZoom = FlxMath.lerp(initialZoom, camera.zoom, zoomFactor);
    var diff = requestedZoom * camera.zoom;

    scale.scale(diff);
  }

  private function __doPostZoomScaleProcedure()
  {
    if (__skipZoomProcedure) return;
    scale.set(__oldScale.x, __oldScale.y);
  }
  #end

  public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();

  public function addOffset(name:String, x:Float = 0, y:Float = 0)
  {
    this.animOffsets[name] = [x, y];
  }

  public function removeOffset(name:String)
  {
    this.animOffsets.remove(name);
  }

  public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
  {
    if (AnimName != null)
    {
      if (!(this is Character))
      {
        if (!this.isAnimateAtlas) this.animation.play(AnimName, Force, Reversed, Frame);
        #if flxanimate
        else
        {
          this.atlas.anim.play(AnimName, Force, Reversed, Frame);
          this.atlas.update(0);
        }
        #end
      }
      _lastPlayedAnimation = AnimName;

      var daOffset = this.getAnimOffset(AnimName);
      if (daOffset != null && daOffset.length > 1) this.offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
    }
  }

  public function getAnimOffset(name:String):Array<Float>
  {
    if (this.hasOffsetAnimation(name)) return this.animOffsets.get(name);
    return null;
  }

  inline public function isAnimationNull():Bool
  {
    return
      #if flxanimate !this.isAnimateAtlas ? (animation.curAnim == null) : (atlas.anim.curInstance == null || atlas.anim.curSymbol == null) #else (animation.curAnim == null) #end;
  }

  var _lastPlayedAnimation:String;

  inline public function getLastAnimationPlayed():String
  {
    return _lastPlayedAnimation;
  }

  inline public function getAnimationName():String
  {
    var name:String = '';
    @:privateAccess
    if (!isAnimationNull()) name = #if flxanimate !this.isAnimateAtlas ? animation.curAnim.name : getLastAnimationPlayed(); #else animation.curAnim.name; #end
    return (name != null) ? name : '';
  }

  inline public function removeAnimation(name:String)
  {
    #if flxanimate
    @:privateAccess
    if (this.atlas != null) this.atlas.anim.animsMap.remove(name);
    else
    #end
    this.animation.remove(name);
  }

  public function isAnimationFinished():Bool
  {
    if (this.isAnimationNull()) return false;
    return #if flxanimate !this.isAnimateAtlas ? this.animation.curAnim.finished : this.atlas.anim.finished; #else this.animation.curAnim.finished; #end
  }

  public function finishAnimation():Void
  {
    if (this.isAnimationNull()) return;

    if (!this.isAnimateAtlas) this.animation.curAnim.finish();
    #if flxanimate
    else
      this.atlas.anim.curFrame = this.atlas.anim.length - 1;
    #end
  }

  public function switchOffset(anim1:String, anim2:String)
  {
    var old = this.animOffsets[anim1];
    this.animOffsets[anim1] = this.animOffsets[anim2];
    this.animOffsets[anim2] = old;
  }

  public function hasOffsetAnimation(anim:String):Bool
  {
    return animOffsets.exists(anim);
  }

  public function hasAnimation(anim:String)
  {
    @:privateAccess
    return #if flxanimate this.isAnimateAtlas ? (atlas.anim.animsMap.exists(anim)
      || atlas.anim.symbolDictionary.exists(anim)) : animation.exists(anim) #else animation.exists(anim) #end;
  }

  public var animPaused(get, set):Bool;

  private function get_animPaused():Bool
  {
    if (this.isAnimationNull()) return false;
    return #if flxanimate !this.isAnimateAtlas ? this.animation.curAnim.paused : this.atlas.anim.isPlaying; #else this.animation.curAnim.paused; #end
  }

  private function set_animPaused(value:Bool):Bool
  {
    if (this.isAnimationNull()) return value;
    if (!this.isAnimateAtlas) this.animation.curAnim.paused = value;
    #if flxanimate
    else
    {
      if (value) this.atlas.pauseAnimation();
      else
        this.atlas.resumeAnimation();
    }
    #end

    return value;
  }

  // Atlas support
  // special thanks ne_eo for the references, you're the goat!!
  @:allow(states.editors.CharacterEditorState)
  public var isAnimateAtlas(default, null):Bool = false;

  #if flxanimate
  public var atlas:FlxAnimate;

  public override function draw()
  {
    if (!(this is Character))
    {
      if (this.atlas != null && this.atlas.anim.curInstance != null)
      {
        this.copyAtlasValues();
        this.atlas.draw();
        return;
      }
    }
    super.draw();
  }

  public function copyAtlasValues()
  {
    @:privateAccess
    {
      if (this.atlas != null)
      {
        this.atlas.cameras = this.cameras;
        this.atlas.scrollFactor = this.scrollFactor;
        this.atlas.scale = this.scale;
        this.atlas.offset = this.offset;
        this.atlas.origin = this.origin;
        this.atlas.x = this.x;
        this.atlas.y = this.y;
        this.atlas.angle = this.angle;
        this.atlas.alpha = this.alpha;
        this.atlas.visible = this.visible;
        this.atlas.flipX = this.flipX;
        this.atlas.flipY = this.flipY;
        this.atlas.shader = this.shader;
        this.atlas.antialiasing = this.antialiasing;
        this.atlas.colorTransform = this.colorTransform;
        this.atlas.color = this.color;
      }
    }
  }
  #end

  // More Functions

  /**
   * Acts similarly to `makeGraphic`, but with improved memory usage,
   * at the expense of not being able to paint onto the resulting sprite.
   *
   * @param width The target width of the sprite.
   * @param height The target height of the sprite.
   * @param color The color to fill the sprite with.
   * @return This sprite, for chaining.
   */
  public function makeSolidColor(width:Int, height:Int, color:FlxColor = FlxColor.WHITE):FunkinSCSprite
  {
    // Create a tiny solid color graphic and scale it up to the desired size.
    var graphic:flixel.graphics.FlxGraphic = FlxG.bitmap.create(2, 2, color, false, 'solid#${color.toHexString(true, false)}');
    frames = graphic.imageFrame;
    scale.set(width / 2.0, height / 2.0);
    updateHitbox();

    return this;
  }

  override public function destroy()
  {
    if (this.animOffsets != null) this.animOffsets.clear();

    #if flxanimate
    if (this.atlas != null) this.atlas = flixel.util.FlxDestroyUtil.destroy(this.atlas);
    #end
    super.destroy();
  }
}
