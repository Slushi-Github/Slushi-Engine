package objects;

import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;
import openfl.utils.Assets;
import haxe.Json;
import objects.stage.TankmenBG;
import flixel.graphics.frames.FlxAtlasFrames;

class Character extends FunkinSCSprite
{
  /**
   * Default Character In case not finding the original or is just the default one.
   */
  public static var DEFAULT_CHARACTER:String = 'bf'; // In case a character is missing, it will use BF on its place

  /**
   *  Useless to know but the before string.
   */
  public static var colorPreString:FlxColor;

  /**
   * Useless to know but the color pre cut.
   */
  public static var colorPreCut:String;

  /**
   * Offsets for when the character is player.
   */
  public var animPlayerOffsets:Map<String, Array<Float>>; // for saving as jsons lol

  /**
   * If the animation can interrupt.
   */
  public var animInterrupt:Map<String, Bool>;

  /**
   * If the animaiton stated to go to the next one.
   */
  public var animNext:Map<String, String>;

  /**
   * If the animation stated that it danced.
   */
  public var animDanced:Map<String, Bool>;

  /**
   * Any extra data you may want to include.
   */
  public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();

  /**
   * If the character is a player character or not.
   */
  public var isPlayer:Bool = false;

  /**
   * The current character.
   */
  public var curCharacter:String = DEFAULT_CHARACTER;

  /**
   * On how long the hold is.
   */
  public var holdTimer:Float = 0;

  /**
   * When doing a "Hey!" Animation, How long is it until reset?
   */
  public var heyTimer:Float = 0;

  /**
   * If the animation is special or not.
   */
  public var specialAnim:Bool = false;

  /**
   * Used for the tankman week on stress for pico.
   */
  public var animationNotes:Array<Dynamic> = [];

  /**
   * If the character is stunned or not.
   */
  public var stunned:Bool = false;

  /**
   * Multiplier of how long a character holds the sing pose.
   */
  public var singDuration:Float = 4;

  /**
   * The dancing animation's suffix (for alt animation and such).
   */
  public var idleSuffix:String = '';

  /**
   * Skips the dancing animation.
   */
  public var skipDance:Bool = false;

  /**
   * stops the dancing animation.
   */
  public var stopIdle:Bool = false;

  /**
   * nonanimted for mid-singing song events!
   */
  public var nonanimated:Bool = false;

  /**
   * Custom note skin the overrides while playing unless its null.
   */
  public var noteSkin:String;

  /**
   * Custom sturm skin the overrides while playing unless its null.
   */
  public var strumSkin:String;

  /**
   * A zoom the modifies the scale of the character.
   */
  public var daZoom:Float = 1;

  /**
   * Allows for when the character dies, the file you want to use for death animations is set in the character file.
   * Used for game over characters.
   */
  public var deadChar:String = "";

  /**
   * If the charatcer is psych engine player character.
   */
  public var isPsychPlayer:Null<Bool>;

  /**
   * If the character replaces GF (takes gf's place, used for dad in tutorial).
   */
  public var replacesGF:Bool;

  /**
   * Whether or not the character uses dance Left and Right instead of Idle.
   */
  public var isDancing:Bool;

  /**
   * The health icon the character has.
   */
  public var healthIcon:String = 'face';

  /**
   * The array of animations taken from the character file.
   */
  public var animationsArray:Array<AnimArray> = [];

  /**
   * The position of the character added on to the original but in case the charatcer is not player.
   */
  public var positionArray:Array<Float> = [0, 0];

  /**
   * The position of the character added on to the original but in case the charatcer is player.
   */
  public var playerPositionArray:Array<Float> = [0, 0];

  /**
   * The position of the camera added on to the original but in case the charatcer is not player.
   */
  public var cameraPosition:Array<Float> = [0, 0];

  /**
   * The position of the camera added on to the original but in case the charatcer is player.
   */
  public var playerCameraPosition:Array<Float> = [0, 0];

  /**
   * If the character has miss animations.
   */
  public var hasMissAnimations:Bool = false;

  /**
   * A Vocals file in case you want to load a vocals file by this variables definition.
   */
  public var vocalsFile:String = '';

  // Used on Character Editor

  /**
   * Image file taken from the character file.
   * Used in the character editor.
   */
  public var imageFile:String = '';

  /**
   * Scale taken from the character file.
   * Used in the character editor.
   */
  public var jsonScale:Float = 1;

  /**
   * Graphic scale taken from the character file.
   * Used in the character editor.
   */
  public var jsonGraphicScale:Float = 1;

  /**
   * no antialiasing.
   * Used in the character editor.
   */
  public var noAntialiasing:Bool = false;

  /**
   * original Flip X.
   * Used in the character editor.
   */
  public var originalFlipX:Bool = false;

  /**
   * Health color array used to color the healthBar (I use iconColor but its converted from this variable).
   */
  public var healthColorArray:Array<Int> = [255, 0, 0];

  /**
   * The icon color but not formatted.
   */
  public var iconColor:String; // Original icon color change!

  /**
   * The icon color but formatted.
   */
  public var iconColorFormatted:String; // New icon color change!

  /**
   * if the character is fliped! (**NOT THE SAME AS FLIPX NOR FLIPY!**).
   */
  public var flipMode:Bool = false;

  /**
   * Note skin style of the character (really a backup for finding the original null).
   */
  public var noteSkinStyleOfCharacter:String = 'noteSkins/NOTE_assets';

  /**
   * Sturm skin style of the character (really a backup for finding the original null).
   */
  public var strumSkinStyleOfCharacter:String = 'noteSkins/NOTE_assets';

  /**
   * change if bf and dad would idle to the beat of the song.
   */
  public var idleToBeat:Bool = true;

  /**
   * how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on).
   */
  public var idleBeat:Int = 1;

  /**
   * Current color. (A different way, not the true color of the sprite unless taken into affect!)
   */
  public var curColor:FlxColor = 0xFFFFFFFF;

  /**
   * When the character has no miss animations but you want it to seem like they do.
   */
  public var doMissThing:Bool = false;

  /**
   * Detect when no frames exist that the character has no use.
   */
  public var charNotPlaying:Bool = false;

  /**
   * Check if the character is custom but not loaded originaly from source.
   */
  public var isCustomCharacter:Bool = false;

  /**
   * Check if the character is not external or like custom or lua character.
   */
  public var hardCodedCharacter:Bool = false;

  /**
   * To check if in editor the charatcer is player.
   */
  public var editorIsPlayer:Null<Bool> = null;

  /**
   * Used to override the HEY Timer to leave it only for the length of the animation and not a timer.
   */
  public var skipHeyTimer:Bool = false;

  /**
   * plays an animation before switch (or after).
   * False because some characters HAVE NULL before switch and that creates null = null.
   */
  public var playAnimationBeforeSwitch:Bool = false;

  /**
   * Whether the player is an active character (char) or not.
   */
  public var characterType(default, set):CharacterType = OTHER;

  function set_characterType(value:CharacterType):CharacterType
  {
    return characterType = value;
  }

  /**
   * A Tag or Name for the character, either a set one or their file name.
   */
  public var characterName:String = "";

  /**
   * A characters Id. curCharacter to be exact.
   */
  public var characterId:String = "";

  /**
   * Missing Character Stuff
   */
  public var missingCharacter:Bool = false;

  /**
   * Missing Character Stuff
   */
  public var missingText:FlxText;

  /**
   * How frequent gf dances (used for other character's when useGFSpeed is active!)
   */
  public var gfSpeed:Int = 1;

  /**
   * If character uses GF Speed to dance (normally for LEFT AND RIGHT DANCES!)
   */
  public var useGFSpeed:Null<Bool> = false;

  public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false, ?characterType:CharacterType = OTHER)
  {
    super(x, y);

    switch (character)
    {
      // case 'your character name in case you want to hardcode them instead':
      case 'pico-speaker':
        changeCharacter(character, isPlayer);
        skipDance = true;
        stopIdle = false;
        loadMappedAnims('picospeaker', true);
        playAnim("shoot1");
      case 'pico-blazin', 'darnell-blazin':
        changeCharacter(character, isPlayer);
        stopIdle = false;
				skipDance = true;
      default:
        changeCharacter(character, isPlayer);
    }
  }

  public dynamic function resetCharacterAttributes(?character:String = "bf", ?isPlayer:Bool = false, ?characterType:CharacterType = OTHER)
  {
    animPlayerOffsets = new Map<String, Array<Float>>();
    animInterrupt = new Map<String, Bool>();
    animNext = new Map<String, String>();
    animDanced = new Map<String, Bool>();

    healthIcon = character;
    curCharacter = character;
    this.isPlayer = isPlayer;
    this.characterType = characterType;

    idleSuffix = "";

    iconColor = isPlayer ? 'FF66FF33' : 'FFFF0000';
    iconColorFormatted = isPlayer ? '#66FF33' : '#FF0000';

    noteSkinStyleOfCharacter = 'noteSkins/NOTE_assets';

    curColor = 0xFFFFFFFF;

    antialiasing = ClientPrefs.data.antialiasing;

    resetAnimationVars();
  }

  public dynamic function changeCharacter(character:String, ?isPlayer:Bool = false, ?characterType:CharacterType = OTHER)
  {
    resetCharacterAttributes(character, isPlayer, characterType);

    isPsychPlayer = false;
    // Finally a easier way to try-catch characters!
    // Load the data from JSON and cast it to a struct we can easily read.
    var characterPath:String = 'data/characters/$curCharacter.json';
    var path:String = Paths.getPath(characterPath, TEXT);

    if (#if MODS_ALLOWED !FileSystem.exists(path) && #end!Assets.exists(path))
    {
      path = Paths.getSharedPath('data/characters/' + DEFAULT_CHARACTER +
        '.json'); // If a character couldn't be found, change him to BF just to prevent a crash
      missingCharacter = true;
      missingText = new FlxText(0, 0, 300, 'ERROR:\n$character.json', 16);
      missingText.alignment = CENTER;
    }

    try
    {
      loadCharacterFile(Json.parse(#if MODS_ALLOWED File.getContent(path) #else Assets.getText(path) #end));
    }
    catch (e:Dynamic)
    {
      charNotPlaying = true;
      Debug.logError('Error loading character file of "$character": $e');
    }

    if (charNotPlaying) // Leave the character without any animations and ability to dance!
    {
      stoppedDancing = true;
      stoppedUpdatingCharacter = true;
      nonanimated = true;
      stopIdle = true;
    }

    originalFlipX = flipX;

    skipDance = false;
    hasMissAnimations = hasOffsetAnimation('singLEFTmiss') || hasOffsetAnimation('singDOWNmiss') || hasOffsetAnimation('singUPmiss') || hasOffsetAnimation('singRIGHTmiss');
    isDancing = hasOffsetAnimation('danceLeft') && hasOffsetAnimation('danceRight');
    doMissThing = !hasOffsetAnimation('singUPmiss'); // if for some reason you only have an up miss, why?

    dance();

    var flips:Bool = isPlayer ? (!curCharacter.startsWith('bf') && !isPsychPlayer) : (curCharacter.startsWith('bf') || isPsychPlayer); // Doesn't flip for BF, since his are already in the right place??? --When Player!
    // Flip for just bf --When Not Player!
    if (flips) flipAnims(true);
  }

  public dynamic function loadCharacterFile(json:Dynamic)
  {
    scale.set(1, 1);
    updateHitbox();

    var spriteName:String = "characters/" + curCharacter;
    if (json.image != null) spriteName = json.image;

    loadSprite(Paths.checkForImage(spriteName), json.image, spriteName);

    imageFile = json.image;
    jsonScale = json.scale;
    jsonGraphicScale = json.graphicScale;

    scale.set(1, 1);
    updateHitbox();

    var defaultIfNotFoundArrowSkin:String = PlayState.SONG != null ? PlayState.SONG.options.arrowSkin : noteSkinStyleOfCharacter;
    var defaultIfNotFoundStrumSkin:String = PlayState.SONG != null ? PlayState.SONG.options.strumSkin : strumSkinStyleOfCharacter;
    noteSkin = (json.noteSkin != null ? json.noteSkin : defaultIfNotFoundArrowSkin);
    strumSkin = (json.strumSkin != null ? json.strumSkin : defaultIfNotFoundStrumSkin);

    if (json.isPlayerChar) isPsychPlayer = json.isPlayerChar;

    if (json.scale != 1)
    {
      scale.set(jsonScale, jsonScale);
      updateHitbox();
    }

    if (json.graphicScale != 1)
    {
      setGraphicSize(Std.int(width * jsonGraphicScale));
      updateHitbox();
    }

    // positioning
    positionArray = ((!debugMode && isPlayer && json.playerposition != null) ? json.playerposition : json.position);
    (json.playerposition != null ? playerPositionArray = json.playerposition : playerPositionArray = json.position);
    (isPlayer
      && json.player_camera_position != null ? cameraPosition = json.player_camera_position : cameraPosition = json.camera_position);
    (json.player_camera_position != null ? playerCameraPosition = json.player_camera_position : playerCameraPosition = json.camera_position);

    // data
    characterId = curCharacter;
    characterName = json.name != null ? json.name : curCharacter + '-Name';
    replacesGF = json.replacesGF;
    healthIcon = json.healthicon;
    singDuration = json.sing_duration;
    editorIsPlayer = json._editor_isPlayer;
    flipX = (json.flip_x != isPlayer);
    deadChar = (deadChar != null ? json.deadChar : '');
    healthColorArray = (json.healthbar_colors != null && json.healthbar_colors.length > 2) ? json.healthbar_colors : [161, 161, 161];
    vocalsFile = (json.vocals_file != null ? json.vocals_file : '');
    if (json.characterType != null) characterType = json.characterType;

    colorPreString = FlxColor.fromRGB(healthColorArray[0], healthColorArray[1], healthColorArray[2]);
    colorPreCut = colorPreString.toHexString();

    iconColor = colorPreCut.substring(2);
    iconColorFormatted = '0x' + colorPreCut.substring(2);

    // I HATE YOU SO MUCH! -- code by me, glowsoony
    var newIconColorFormat:String = iconColorFormatted;
    if (iconColorFormatted.contains('0xFF') && iconColorFormatted.length == 10) newIconColorFormat = newIconColorFormat.replace('0xFF', '');
    if (iconColorFormatted.contains('0x') && iconColorFormatted.length == 8) newIconColorFormat = newIconColorFormat.replace('0x', '');
    if (iconColorFormatted.contains('#') && iconColorFormatted.length == 7) newIconColorFormat = newIconColorFormat.replace('#', '');
    iconColorFormatted = '#' + newIconColorFormat;

    // antialiasing
    noAntialiasing = (json.no_antialiasing == true);
    antialiasing = ClientPrefs.data.antialiasing ? !noAntialiasing : false;

    // animations
    animationsArray = json.animations;
    if (isPlayer && json.playerAnimations != null) animationsArray = json.playerAnimations;

    // Bound dancing varialbes
    var defaultBeat:Int = Std.int(json.defaultBeat);
    idleBeat = (!Math.isNaN(defaultBeat) && defaultBeat != 0) ? defaultBeat : 1;

    if (json.useGFSpeed != null) useGFSpeed = json.useGFSpeed;

    if (animationsArray != null && animationsArray.length > 0)
    {
      for (anim in animationsArray)
      {
        var animAnim:String = '' + anim.anim;
        var animName:String = '' + anim.name;
        var animFps:Int = anim.fps;
        var animLoop:Bool = !!anim.loop; // Bruh
        var animFlipX:Bool = !!anim.flipX;
        var animFlipY:Bool = !!anim.flipY;
        var animIndices:Array<Int> = anim.indices;
        if (!isAnimateAtlas)
        {
          if (animIndices != null && animIndices.length > 0) animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop, animFlipX,
            animFlipY);
          else
            animation.addByPrefix(animAnim, animName, animFps, animLoop, animFlipX, animFlipY);
        }
        #if flxanimate
        else
        {
          if (animIndices != null && animIndices.length > 0) atlas.anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
          else
            atlas.anim.addBySymbol(animAnim, animName, animFps, animLoop);
        }
        #end

        var offsets:Array<Int> = anim.offsets;
        var playerOffsets:Array<Int> = anim.playerOffsets;
        var swagOffsets:Array<Int> = offsets;

        if (!debugMode && isPlayer && playerOffsets != null && playerOffsets.length > 1) swagOffsets = playerOffsets;
        if (swagOffsets != null && swagOffsets.length > 1) addOffset(anim.anim, swagOffsets[0], swagOffsets[1]);
        if (playerOffsets != null && playerOffsets.length > 1) addPlayerOffset(anim.anim, playerOffsets[0], playerOffsets[1]);
        animInterrupt[anim.anim] = anim.interrupt == null ? true : anim.interrupt;
        if (json.isDancing && anim.isDanced != null) animDanced[anim.anim] = anim.isDanced;
        if (anim.nextAnim != null) animNext[anim.anim] = anim.nextAnim;
      }
    }
    else
    {
      Debug.logError("Character has no Frames!");
      charNotPlaying = true;
    }

    #if flxanimate
    if (isAnimateAtlas) copyAtlasValues();
    #end

    json.startingAnim != null ? playAnim(json.startingAnim) : (hasOffsetAnimation('danceRight') ? playAnim('danceRight') : playAnim('idle'));
  }

  override function update(elapsed:Float)
  {
    if (!ClientPrefs.data.characters) return;
    #if flxanimate if (isAnimateAtlas) atlas.update(elapsed); #end

    if (debugMode
      || (!isAnimateAtlas && animation.curAnim == null) #if flxanimate
      || (isAnimateAtlas && (atlas.anim.curInstance == null || atlas.anim.curSymbol == null)) #end
      || stoppedUpdatingCharacter)
    {
      super.update(elapsed);
      return;
    }

    if (heyTimer > 0)
    {
      var rate:Float = (PlayState.instance != null ? PlayState.instance.playbackRate : 1.0);
      heyTimer -= elapsed * rate;
      if (heyTimer <= 0)
      {
        var anim:String = getLastAnimationPlayed();
        if (specialAnim && (anim == 'hey' || anim == 'cheer'))
        {
          specialAnim = false;
          dance();
        }
        heyTimer = 0;
      }
    }
    else if (specialAnim && isAnimationFinished())
    {
      specialAnim = false;
      dance();
    }
    else if (getLastAnimationPlayed().endsWith('miss') && isAnimationFinished())
    {
      dance();
      finishAnimation();
    }

    switch (curCharacter)
    {
      case 'pico-speaker':
        if (animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
        {
          var noteData:Int = 1;
          if (animationNotes[0][1] > 2) noteData = 3;

          noteData += FlxG.random.int(0, 1);
          playAnim('shoot' + noteData, true);
          animationNotes.shift();
        }
        if (isAnimationFinished()) playAnim(getLastAnimationPlayed(), false, false, animation.curAnim.frames.length - 3);
    }

    if ((flipMode && isPlayer) || (!flipMode && !isPlayer))
    {
      if (getLastAnimationPlayed().startsWith('sing')) holdTimer += elapsed;

      if (!CoolUtil.opponentModeActive || CoolUtil.opponentModeActive && isCustomCharacter)
      {
        if (holdTimer >= Conductor.stepCrochet * singDuration * (0.001 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end))
        {
          dance();
          holdTimer = 0;
        }
      }
    }

    if (isPlayer && !isCustomCharacter && !flipMode)
    {
      if (getLastAnimationPlayed().startsWith('sing')) holdTimer += elapsed;
      else
        holdTimer = 0;
    }

    if (!debugMode)
    {
      var nextAnim = animNext.get(getLastAnimationPlayed());
      var forceDanced = animDanced.get(getLastAnimationPlayed());

      if (nextAnim != null && isAnimationFinished())
      {
        if (isDancing && forceDanced != null) danced = forceDanced;
        playAnim(nextAnim);
      }
      else
      {
        var name:String = getLastAnimationPlayed();
        if (isAnimationFinished() && hasOffsetAnimation('$name-loop')) playAnim('$name-loop');
      }
    }

    super.update(elapsed);
  }

  public var danced:Bool = false;
  public var stoppedDancing:Bool = false;
  public var stoppedUpdatingCharacter:Bool = false;

  public dynamic function dance(forced:Bool = false, altAnim:Bool = false)
  {
    if (!ClientPrefs.data.characters) return;
    if (debugMode || stoppedDancing || skipDance || specialAnim || nonanimated || stopIdle) return;
    if (animation.curAnim != null)
    {
      var canInterrupt = animInterrupt.get(animation.curAnim.name);

      if (canInterrupt)
      {
        var animName:String = ''; // Flow the game!
        if (isDancing)
        {
          danced = !danced;
          if (altAnim && hasOffsetAnimation('danceRight-alt') && hasOffsetAnimation('danceLeft-alt')) animName = 'dance${danced ? 'Right' : 'Left'}-alt';
          else
            animName = 'dance${(danced ? 'Right' : 'Left') + idleSuffix}';
        }
        else
        {
          if (altAnim && (hasOffsetAnimation('idle-alt') || hasOffsetAnimation('idle-alt2'))) animName = 'idle-alt';
          else
            animName = 'idle' + idleSuffix;
        }
        playAnim(animName, forced);
      }
    }

    if (color != curColor && doMissThing) color = curColor;
  }

  var missed:Bool = false;

  public var doAffectForAnimationName:Bool = true;

  public dynamic function doAffectForName(name:String)
  {
    if (name.endsWith('alt') && !hasOffsetAnimation(name)) name = name.split('-')[0];
    if (name == 'laugh' && !hasOffsetAnimation(name)) name = 'singUP';
    if (name.endsWith('miss') && !hasOffsetAnimation(name))
    {
      name = name.substr(0, name.length - 4);
      if (doMissThing) missed = true;
    }

    if (hasOffsetAnimation(name)) // if it's STILL null, just play idle, and if you REALLY messed up, it'll look in the xml for a valid anim
    {
      if (isDancing && hasOffsetAnimation('danceRight')) name = 'danceRight';
      else if (hasOffsetAnimation('idle')) name = 'idle';
    }
  }

  public var doAfterAffectForAnimationName:Bool = true;

  public dynamic function doAfterAffectForName(name:String)
  {
    if (curCharacter.startsWith('gf-') || curCharacter == 'gf')
    {
      if (name == 'singLEFT') danced = true;
      else if (name == 'singRIGHT') danced = false;
      if (name == 'singUP' || name == 'singDOWN') danced = !danced;
    }
  }

  override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
  {
    super.playAnim(AnimName, Force, Reversed, Frame);

    if (!ClientPrefs.data.characters) return;

    _lastPlayedAnimation = AnimName;

    specialAnim = false;
    missed = false;

    if (nonanimated || charNotPlaying) return;

    if (doAffectForAnimationName) doAffectForName(AnimName);

    if (!isAnimateAtlas) animation.play(AnimName, Force, Reversed, Frame);
    #if flxanimate
    else
    {
      atlas.anim.play(AnimName, Force, Reversed, Frame);
      atlas.update(0);
    }
    #end

    // To do full color transformations just do "doMissThing = false;"
    if (missed)
    {
      var realCurColor = curColor;
      color = CoolUtil.blendColors(curColor, FlxColor.fromInt(0xFFCFAFFF));
      curColor = realCurColor;
    }
    else if (color != curColor && doMissThing)
    {
      color = curColor;
    }

    var daOffset = animOffsets.get(AnimName);

    if (debugMode && isPlayer) daOffset = animPlayerOffsets.get(AnimName);

    if (debugMode)
    {
      if ((hasOffsetAnimation(AnimName) && !isPlayer)
        || (animPlayerOffsets.exists(AnimName) && isPlayer)) offset.set(daOffset[0] * scale.x * daZoom, daOffset[1] * scale.y * daZoom);
    }
    else
    {
      if (hasOffsetAnimation(AnimName)) offset.set(daOffset[0] * scale.x * daZoom, daOffset[1] * scale.y * daZoom);
    }

    if (doAfterAffectForAnimationName) doAfterAffectForName(AnimName);
  }

  public dynamic function allowDance():Bool
    return !isAnimationNull() && !getLastAnimationPlayed().startsWith("sing") && !specialAnim && !stunned;

  public dynamic function isDancingType():Bool
    return isDancing;

  public dynamic function allowHoldTimer():Bool
  {
    return !isAnimationNull()
      && holdTimer > Conductor.stepCrochet * singDuration * (0.001 #if FLX_PITCH / FlxG.sound.music.pitch #end)
      && getLastAnimationPlayed().startsWith('sing')
      && !getLastAnimationPlayed().endsWith('miss');
  }

  public dynamic function danceConditions(conditionsMet:Bool, ?forcedToIdle:Null<Bool> = null)
  {
    var forced:Bool = (forcedToIdle != null ? forcedToIdle : false);
    if (conditionsMet) dance(forced);
  }

  public dynamic function danceChar(char:String, ?altBool:Bool, ?forcedToIdle:Bool, ?singArg:Bool)
  {
    switch (char)
    {
      case 'player', 'opponent':
        if (allowDance() && singArg) dance(forcedToIdle, altBool);
      default:
        if (allowDance()) dance();
    }
  }

  public dynamic function beatDance(beat:Int):Bool
  {
    var dancing:Bool = false;
    if (!useGFSpeed)
    {
      if (beat % idleBeat == 0)
      {
        if (idleToBeat)
          dancing = true;
      }
      else if (beat % idleBeat != 0)
      {
        if (isDancingType())
          dancing = true;
      }
      return dancing;
    }
    else return (beat % gfSpeed == 0);
    return false;
  }

  public function loadMappedAnims(json:String = '', tankManNotes:Bool = false):Void
  {
    try
    {
      var songData:SwagSong = Song.getChart(json, Song.formattedSongName);
      if (songData != null)
      {
        for (section in songData.notes)
          for (songNotes in section.sectionNotes)
            animationNotes.push(songNotes);
      }
      if (tankManNotes) TankmenBG.animationNotes = animationNotes;
      animationNotes.sort(sortAnims);
      Debug.logInfo('note lengths ${animationNotes.length}');
    }
    catch (e:haxe.Exception)
    {
      Debug.logError(e.message);
    }
  }

  public function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
  {
    return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
  }

  public function addPlayerOffset(name:String, x:Float = 0, y:Float = 0)
  {
    animPlayerOffsets[name] = [x, y];
  }

  public function quickAnimAdd(name:String, anim:String)
  {
    animation.addByPrefix(name, anim, 24, false);
  }

  public dynamic function setZoom(?toChange:Float = 1):Void
  {
    daZoom = toChange;

    var daMulti:Float = 1;
    daMulti *= 1;
    daMulti = jsonScale;

    var daValue:Float = toChange * daMulti;
    scale.set(daValue, daValue);
  }

  public dynamic function resetAnimationVars()
  {
    for (i in [
      'flipMode', 'stopIdle', 'skipDance', 'nonanimated', 'specialAnim', 'doMissThing', 'stunned', 'stoppedDancing', 'stoppedUpdatingCharacter',
      'charNotPlaying'
    ])
    {
      Reflect.setProperty(this, i, false);
    }
  }

  public function flipAnims(left_right:Bool = true)
  {
    var animSuf:Array<String> = ["", "miss", "-alt", "-alt2", "-loop"];

    // rewrote it -blantados
    for (anim in animationsArray)
    {
      if (anim.anim.contains("singRIGHT") && left_right)
      {
        var animSplit:Array<String> = anim.anim.split('singRIGHT');
        if (animation.getByName('singRIGHT' + animSplit[1]) != null && animation.getByName('singLEFT' + animSplit[1]) != null)
        {
          var oldRight = animation.getByName('singRIGHT' + animSplit[1]).frames;
          animation.getByName('singRIGHT' + animSplit[1]).frames = animation.getByName('singLEFT' + animSplit[1]).frames;
          animation.getByName('singLEFT' + animSplit[1]).frames = oldRight;
        }
      }
      else if (anim.anim.contains("singUP") && !left_right)
      {
        var animSplit:Array<String> = anim.anim.split('singUP');
        if (animation.getByName('singUP' + animSplit[1]) != null && animation.getByName('singDOWN' + animSplit[1]) != null)
        {
          var oldUp = animation.getByName('singUP' + animSplit[1]).frames;
          animation.getByName('singUP' + animSplit[1]).frames = animation.getByName('singDOWN' + animSplit[1]).frames;
          animation.getByName('singDOWN' + animSplit[1]).frames = oldUp;
        }
      }
    }
  }

  public function forOption(forVis:Bool, vis:Bool):Void
  {
    if (!forVis)
    {
      setGraphicSize(Std.int(width * 0.75));
      updateHitbox();
      dance();
      animation.finishCallback = function(name:String) dance();
      visible = false;
    }
    else
    {
      visible = vis;
    }
  }

  public override function draw()
  {
    var lastAlpha:Float = alpha;
    var lastColor:FlxColor = color;
    if (missingCharacter)
    {
      alpha *= 0.6;
      color = FlxColor.BLACK;
    }
    #if flxanimate
    if (isAnimateAtlas)
    {
      copyAtlasValues();
      atlas.draw();
      alpha = lastAlpha;
      color = lastColor;
      if (missingCharacter && visible)
      {
        missingText.x = getMidpoint().x - 150;
        missingText.y = getMidpoint().y - 10;
        missingText.draw();
      }
      return;
    }
    #end
    super.draw();
    if (missingCharacter && visible)
    {
      alpha = lastAlpha;
      color = lastColor;
      missingText.x = getMidpoint().x - 150;
      missingText.y = getMidpoint().y - 10;
      missingText.draw();
    }
  }

  override public function destroy()
  {
    animOffsets.clear();
    animInterrupt.clear();
    animNext.clear();
    animDanced.clear();

    animationNotes.resize(0);

    #if flxanimate
    atlas = flixel.util.FlxDestroyUtil.destroy(atlas);
    #end
    super.destroy();
  }

  override function set_color(Color:FlxColor):Int
  {
    curColor = Color;
    return super.set_color(Color);
  }
}

typedef CharacterFile =
{
  /**
   * Special name for character.
   */
  var ?name:String;

  /**
   * Image path of the character image.
   */
  var image:String;

  /**
   * Begining animation when characters loads.
   */
  var ?startingAnim:String;

  /**
   * If in editor, character is player.
   */
  var ?_editor_isPlayer:Null<Bool>;

  /**
   * Main position added on to the default in game.
   */
  var ?position:Array<Float>;

  /**
   * In case of needing a position for when character is PLAYER.
   */
  var ?playerposition:Array<Float>; // bcuz dammit some of em don't exactly flip right

  /**
   * Main camera positioning.
   */
  var ?camera_position:Array<Float>;

  /**
   * In case of needing a camera_position when character is PLAYER.
   */
  var ?player_camera_position:Array<Float>;

  /**
   * How long animations last.
   */
  var ?sing_duration:Float;

  /**
   * The color of this character's health bar.
   */
  var ?healthbar_colors:Array<Int>;

  /**
   * Health icon used in game.
   */
  var healthicon:String;

  /**
   * Main character animations.
   */
  var animations:Array<AnimArray>;

  /**
   * In case the player has animations that are different when they are PLAYER.
   */
  var ?playerAnimations:Array<AnimArray>; // bcuz player to opponent and opponent to player

  /**
   * Whether this character is flipped horizontally.
   * @default false
   */
  var ?flip_x:Bool;

  /**
   * Let's characters used a custom deadChar based on character.
   * @default ""
   * **Note: bf => "bf-dead" =>, bf-pixel => "bf-dead-pixel", bf-holding-gf => "bf-holding-gf-dead"**
   */
  var ?deadChar:String;

  /**
   * The scale of this character.
   * Pixel characters typically use 6, scale.set(6, 6).
   * @default 1
   */
  var ?scale:Float;

  /**
   * The scale of this character in graphic size.
   * Pixel characters typically use 6.
   * @default 1
   */
  var ?graphicScale:Float;

  /**
   * Whether this character has antialiasing.
   * @default true
   */
  var ?no_antialiasing:Bool;

  /**
   * Whether this character uses a dancing idle instead of a regular idle. used for animation dealing with isDanced.
   * (ex. gf, spooky)
   * @default false
   */
  var ?isDancing:Bool;

  /**
   * Whether this character is a player
   * (ex. bf, bf-pixel)
   * @default false
   */
  var ?isPlayerChar:Bool;

  /**
   * Whether this character replaces gf if they are set as dad.
   * @default false
   */
  var ?replacesGF:Bool;

  /**
   * Whether the character overrides the noteSkin in playstate.hx or note.hx;
   * @default "noteSkins/NOTE_assets"
   */
  var ?noteSkin:String;

  /**
   * Whether the character overrides the strumSkin in playstate.hx or strumarrow.hx;
   * @default "noteSkins/NOTE_assets"
   */
  var ?strumSkin:String;

  /**
   * Whether the character has a vocals file for the game to change to.
   * @default 'Player'
   */
  var ?vocals_file:String;

  /**
   * Idle defualt beat
   * @default 1
   */
  var ?defaultBeat:Int;

  /**
   * What type of character is it? DAD, BF, GF, OTHER
   * @default OTHER
   */
  var ?characterType:String;

  /**
   *
   * @default false
   */
  var ?useGFSpeed:Bool;
}

typedef AnimArray =
{
  var anim:String;
  var name:String;
  var ?offsets:Array<Int>;
  var ?playerOffsets:Array<Int>;

  /**
   * Whether this animation is looped.
   * @default false
   */
  var ?loop:Bool;

  var ?flipX:Bool;
  var ?flipY:Bool;

  /**
   * The frame rate of this animation.
       * @default 24
   */
  var ?fps:Int;

  var ?indices:Array<Int>;

  /**
   * Whether this animation can be interrupted by the dance function.
   * @default true
   */
  var ?interrupt:Bool;

  /**
   * The animation that this animation will go to after it is finished.
   */
  var ?nextAnim:String;

  /**
   * Whether this animation sets danced to true or false.
   * Only works for characters with isDancing enabled.
   */
  var ?isDanced:Bool;
}

/**
 * The type of a given character sprite. Defines its default behaviors.
 * Useful for feature references in this engine. -glowsoony
 */
enum abstract CharacterType(String) to String from String
{
  /**
   * The BF character has the following behaviors.
   * - At idle, dances with `danceLeft` and `danceRight` if available, or `idle` if not.
   * - When the player hits a note, plays the appropriate `singDIR` animation until BF is done singing.
   * - If there is a `singDIR-end` animation, the `singDIR` animation will play once before looping the `singDIR-end` animation until BF is done singing.
   * - If the player misses or hits a ghost note, plays the appropriate `singDIR-miss` animation until BF is done singing.
   */
  var BF = 'BF';

  /**
   * The DAD character has the following behaviors.
   * - At idle, dances with `danceLeft` and `danceRight` if available, or `idle` if not.
   * - When the CPU hits a note, plays the appropriate `singDIR` animation until DAD is done singing.
   * - If there is a `singDIR-end` animation, the `singDIR` animation will play once before looping the `singDIR-end` animation until DAD is done singing.
   * - When the CPU misses a note (NOTE: This only happens via script, not by default),
   *     plays the appropriate `singDIR-miss` animation until DAD is done singing.
   */
  var DAD = 'DAD';

  /**
   * The GF character has the following behaviors.
   * - At idle, dances with `danceLeft` and `danceRight` if available, or `idle` if not.
   * - If available, `combo###` animations will play when certain combo counts are reached.
   *   - For example, `combo50` will play when the player hits 50 notes in a row.
   *   - Multiple combo animations can be provided for different thresholds.
   * - If available, `drop###` animations will play when combos are dropped above certain thresholds.
   *   - For example, `drop10` will play when the player drops a combo larger than 10.
   *   - Multiple drop animations can be provided for different thresholds (i.e. dropping larger combos).
   *   - No drop animation will play if one isn't applicable (i.e. if the combo count is too low).
   */
  var GF = 'GF';

  /**
   * The OTHER character will only perform the `danceLeft`/`danceRight` or `idle` animation by default, depending on what's available.
   * Additional behaviors can be performed via scripts.
   */
  var OTHER = 'OTHER';
}
