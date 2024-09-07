package objects;

import haxe.Json as Json;
import lime.utils.Assets;
import flixel.math.FlxMath;

class HealthIcon extends FunkinSCSprite
{
  public var char:String = '';
  public var isPlayer:Bool = false;
  public var iconOffset:Array<Float> = [0, 0];

  public var sprTracker:FlxSprite;
  public var hasWinning:Bool = true;
  public var hasWinningAnimated:Bool = false;
  public var hasLosingAnimated:Bool = false;

  public var alreadySized:Bool = true;
  public var findAutomaticSize:Bool = false;
  public var needAutoSize:Bool = true;
  public var defaultSize:Bool = false;
  public var isOneSized:Bool = false;
  public var divisionMult:Int = 1;
  public var iconStoppedBop:Bool = false;

  // Animated Icon Stuff
  public var animatedIcon:Bool = false;
  public var animationStopped:Bool = false;
  public var autoAnimatedSetup:Bool = false;
  public var overrideIconOnUpdate:Bool = false;
  public var overrideIconPlacement:Bool = false;

  public var offsetX:Float = 0;
  public var offsetY:Float = 0;

  public var losingAnimation:Bool = false;
  public var winningAnimation:Bool = false;
  public var normalAnimation:Bool = false;

  public var healthIndication:Float = 1;

  public var percent20or80:Bool = false;
  public var percent80or20:Bool = false;

  public var speedBopLerp:Float = 1;
  public var setIconScale:Float = 1.2;

  public var iconBopSpeed:Int = 2;
  public var iconBopAngleSpeed:Int = 2;

  public var overrideBeatBop:Bool = false;

  public var ableSizes:Array<Float> = [450, 600, 750, 900];
  public var choosenDivisionMult:Int = 3;

  public var divideByWidthAndHeight:Bool = false;

  public var characterId:String = "";

  public var stopBop:Bool = false;

  private var animName:String = 'normal';
  private var changedComplete:Bool = true;

  public function new(char:String = 'face', isPlayer:Bool = false, ?allowGPU:Bool = true)
  {
    super();
    this.isPlayer = isPlayer;
    changeIcon(char, allowGPU);
    scrollFactor.set();
    stopBop = (FlxG.state is states.editors.ChartingState);
  }

  public dynamic function changeIcon(char:String, ?allowGPU:Bool = true)
  {
    changedComplete = false;
    var name:String = 'icons/';
    var iconSuffix:String = 'icon-';
    if (!Paths.fileExists('images/' + name + char + '.png', IMAGE))
    {
      iconSuffix = '';
    }

    if (iconSuffix != '')
    {
      name = name + char;
      if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/' + iconSuffix + 'face';
    }
    else
      name = name + 'icon-' + char;

    var frameName:String = name;
    if (frameName.contains('.png')) frameName = frameName.substring(0, frameName.length - 4);

    var filePath:String = 'images/$frameName.json';
    var path:String = Paths.getPath(filePath, TEXT);

    // now with winning icon support
    try
    {
      #if MODS_ALLOWED
      if (FileSystem.exists(Paths.getPath('images/$frameName.xml', TEXT))) loadIconFile(Json.parse(File.getContent(path)), frameName, name);
      else
      #end
      if (Assets.exists(Paths.getPath('images/$frameName.xml', TEXT))) loadIconFile(Json.parse(Assets.getText(path)), frameName, name);
      else
        loadGraphicIcon(name, allowGPU);
    }
    catch (e:Dynamic)
    {
      Debug.displayAlert("Error: " + e, "Couldn't find sprite and xml, nor single sprite to load!");
    }

    changedComplete = true;
    this.char = char;
  }

  public dynamic function loadGraphicIcon(icon:String, gpuAllowed:Bool)
  {
    frames = null;
    if (animatedIcon) animatedIcon = false;
    var graphic = Paths.image(icon, gpuAllowed);

    // If null once it turns into icon-face, but it that fails, fully stop working!
    if (graphic == null) graphic = Paths.image("icons/icon-face", gpuAllowed);
    if (graphic == null)
    {
      graphic = Paths.image('missingRating', gpuAllowed);
      return;
    }

    isOneSized = (graphic.height == 150 && graphic.width == 150);

    for (size in ableSizes)
      if (graphic.width == size && graphic.height == 150) needAutoSize = false;

    switch (graphic.width)
    {
      case 450:
        choosenDivisionMult = 3;
      case 600:
        choosenDivisionMult = 4;
      case 750:
        choosenDivisionMult = 5;
      case 900:
        choosenDivisionMult = 6;
    }

    if (graphic.width == 300 && graphic.height == 150) alreadySized = true;
    else
      alreadySized = false;

    // Fixed icons that don't use perfect height and width with these!
    if (!isOneSized)
    {
      findAutomaticSize = (((graphic.width <= 300 && graphic.height <= 150) || (graphic.width >= 300 && graphic.height >= 150))
        && needAutoSize);
      if (alreadySized || findAutomaticSize) divisionMult = 2;
      else if (!findAutomaticSize && needAutoSize)
      {
        divisionMult = 2;
        divideByWidthAndHeight = true;
      }
      else
        divisionMult = choosenDivisionMult;
    }
    else
      divisionMult = 1;

    if (divideByWidthAndHeight)
    {
      loadGraphic(graphic); // Load stupidly first for getting the file size
      loadGraphic(graphic, true, Math.floor(width / divisionMult), Math.floor(height));
    }
    else
      loadGraphic(graphic, true, Math.floor(graphic.width / divisionMult), Math.floor(graphic.height));
    iconOffset[0] = (width - 150) / divisionMult;
    iconOffset[1] = (height - 150) / divisionMult;
    if (divisionMult == 2)
    {
      hasWinning = false;
      defaultSize = true;
    }
    else if (divisionMult >= 3) hasWinning = true;

    offset.set(iconOffset[0], iconOffset[1]);
    updateHitbox();

    var animArray:Array<Int> = [];

    if (hasWinning) animArray = [0, 1, 2];
    else if (divisionMult > 3)
    {
      switch (divisionMult)
      {
        case 4:
          animArray = [0, 1, 2, 3];
        case 5:
          animArray = [0, 1, 2, 3, 4];
        case 6:
          animArray = [0, 1, 2, 3, 4, 5];
      }
    }
    else
    {
      if (defaultSize) animArray = [0, 1];
      else
        animArray = [0];
    }

    animation.add(char, animArray, 0, false, isPlayer);
    animation.play(char);

    antialiasing = (ClientPrefs.data.antialiasing && !char.endsWith('-pixel'));
  }

  public dynamic function loadIconFile(json:Dynamic, path:String, graphicIcon:String)
  {
    if (json.image != null) path = 'images/' + json.image + '.json';

    frames = Paths.getSparrowAtlas(path);

    animatedIcon = true;

    if (frames == null)
    {
      frames = null;
      animatedIcon = false;
      return;
    }

    scale.set(1, 1);
    updateHitbox();

    if (json.scale != 1)
    {
      scale.set(json.scale, json.scale);
      updateHitbox();
    }

    if (json.graphicScale != 1)
    {
      setGraphicSize(Std.int(width * json.graphicScale));
      updateHitbox();
    }

    final speed:Int = json.bopSpeed;

    flipX = (json.flip_x != null ? json.flip_x : isPlayer);
    iconBopSpeed = (!Math.isNaN(speed) && speed != 0) ? speed : 2;

    final noAntialiasing = (json.no_antialiasing == true);
    antialiasing = ClientPrefs.data.antialiasing ? !noAntialiasing && !char.endsWith('-pixel') : false;

    // animations
    final animations:Array<IconAnimations> = json.animations;

    // Let people override it to autoAnimateSetup
    if (animations != null && animations.length > 0)
    {
      for (anim in animations)
      {
        var animAnim:String = '' + anim.anim;
        var animName:String = '' + anim.name;
        var animFps:Int = anim.fps;
        var animLoop:Bool = !!anim.loop; // Bruh
        var animIndices:Array<Int> = anim.indices;
        if (animIndices != null && animIndices.length > 0) animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
        else
          animation.addByPrefix(animAnim, animName, animFps, animLoop);

        var offsets:Array<Int> = anim.offsets;
        var swagOffsets:Array<Int> = offsets;

        if (swagOffsets != null && swagOffsets.length > 1) addOffset(anim.anim, swagOffsets[0], swagOffsets[1]);
      }
    }

    if (hasOffsetAnimation('losing')) hasLosingAnimated = true;
    if (hasOffsetAnimation('winning')) hasWinningAnimated = true;

    json.startingAnim != null ? playAnim(json.startingAnim) : playAnim('normal', true);
  }

  public function getCharacter():String
  {
    return char;
  }

  public var autoAdjustOffset:Bool = true;
  public var autoAdjustWidth:Bool = true;
  public var autoAdjustHeight:Bool = true;
  public var autoAdjustToCenter:Bool = true;

  override function updateHitbox()
  {
    super.updateHitbox();
    if (!animatedIcon)
    {
      if (autoAdjustOffset)
      {
        offset.x = iconOffset[0];
        offset.y = iconOffset[1];
      }
      if (autoAdjustWidth) width = Math.abs(scale.x) * frameWidth;
      if (autoAdjustHeight) height = Math.abs(scale.y) * frameHeight;
      if (autoAdjustToCenter) centerOrigin();
    }
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);
    if (sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 12 + offsetX, sprTracker.y - 30 + offsetY);

    if (stopBop) return;

    if (!iconStoppedBop)
    {
      var mult:Float = FlxMath.lerp((setIconScale - 0.2), scale.x, Math.exp(-elapsed * 9 * speedBopLerp));
      scale.set(mult, mult);
      updateHitbox();
    }

    if (!overrideIconOnUpdate)
    {
      if (!animatedIcon)
      {
        if (isPlayer)
        {
          if (percent20or80 && frames.frames.length > 0) animation.curAnim.curFrame = 1;
          else if (percent80or20 && hasWinning && frames.frames.length > 2) animation.curAnim.curFrame = 2;
          else
            animation.curAnim.curFrame = 0;
        }
        else
        {
          if (percent20or80 && hasWinning && frames.frames.length > 2) animation.curAnim.curFrame = 2;
          else if (percent80or20 && frames.frames.length > 0) animation.curAnim.curFrame = 1;
          else
            animation.curAnim.curFrame = 0;
        }
      }
      else
      {
        if (isPlayer)
        {
          normalAnimation = (!(percent80or20 && hasWinningAnimated) && !(percent20or80 && hasLosingAnimated));
          winningAnimation = (percent80or20 && hasWinningAnimated);
          losingAnimation = (percent20or80 && hasLosingAnimated);

          animName = ((percent80or20 && hasWinningAnimated) ? 'winning' : ((percent20or80 && hasLosingAnimated) ? 'losing' : 'normal'));
        }
        else
        {
          normalAnimation = (!(percent20or80 && hasWinningAnimated) && !(percent80or20 && hasLosingAnimated));
          winningAnimation = (percent20or80 && hasWinningAnimated);
          losingAnimation = (percent80or20 && hasLosingAnimated);

          animName = ((percent20or80 && hasWinningAnimated) ? 'winning' : ((percent80or20 && hasLosingAnimated) ? 'losing' : 'normal'));
        }

        if (animatedIcon)
        {
          if (animation.curAnim.finished || (animName != animation.curAnim.name))
          {
            playAnim(animName, true);
          }
        }
      }
    }
  }

  override public function beatHit(curBeat:Int)
  {
    super.beatHit(curBeat);

    if (stopBop) return;

    if (!overrideBeatBop)
    {
      if (curBeat % iconBopSpeed == 0)
      {
        if (!iconStoppedBop)
        {
          scale.set(setIconScale, setIconScale);
          updateHitbox();
        }

        switch (ClientPrefs.data.iconMovement.toLowerCase())
        {
          case 'angled':
            if (iconStoppedBop) return;
            curBeat % iconBopAngleSpeed == 0 ?
            {
              FlxTween.angle(this, -15, 0, Conductor.crochet / 1300 / speedBopLerp, {ease: FlxEase.circOut});
            } :
              {
                FlxTween.angle(this, 15, 0, Conductor.crochet / 1300 / speedBopLerp, {ease: FlxEase.circOut});
              };
        }
      }
    }
  }
}

typedef IconData =
{
  var ?name:String;
  var image:String;
  var animations:Array<IconAnimations>;
  var ?startingAnim:String;
  var ?scale:Float;
  var ?graphicScale:Float;
  var ?no_antialiasing:Bool;
  var ?bopSpeed:Int;
}

typedef IconAnimations =
{
  var name:String;
  var anim:String;
  var ?fps:Int;
  var ?offsets:Array<Int>;
  var ?loop:Bool;
  var ?indices:Array<Int>;
}
