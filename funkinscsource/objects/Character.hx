package objects;

import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import haxe.Json;
import objects.stage.TankmenBG;
#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end
#if (HSCRIPT_ALLOWED && HScriptImproved)
import codenameengine.scripting.Script as HScriptCode;
#end
import shaders.FNFShader;
#if HSCRIPT_ALLOWED
import scripting.*;
import crowplexus.iris.Iris;
#end

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
   * Custom strum skin the overrides while playing unless its null.
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
   * Strum skin style of the character (really a backup for finding the original null).
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

  #if LUA_ALLOWED
  /**
   * Scripts the are lua for characters.
   */
  public var luaArray:Array<FunkinLua> = [];
  #end

  #if HSCRIPT_ALLOWED
  /**
   * Iris Scripts that are for characters.
   */
  public var hscriptArray:Array<psychlua.HScript> = [];

  /**
   * SCHS scripts that are for characters.
   */
  public var scHSArray:Array<scripting.SCScript> = [];

  #if HScriptImproved
  /**
   * Codename Scripts the are for characters.
   */
  public var codeNameScripts:codenameengine.scripting.ScriptPack;
  #end

  #end
  public var idleDances:IdleDances = null;
  public var useIdleSequence:Bool = false;

  public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false, ?characterType:CharacterType = OTHER)
  {
    super(x, y);

    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (codeNameScripts == null) (codeNameScripts = new codenameengine.scripting.ScriptPack("Character")).setParent(this);
    #end

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
    final characterPath:String = 'data/characters/$curCharacter.json';
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
    hasMissAnimations = hasOffsetAnimation('singLEFTmiss') || hasOffsetAnimation('singDOWNmiss') || hasOffsetAnimation('singUPmiss')
      || hasOffsetAnimation('singRIGHTmiss');
    isDancing = hasOffsetAnimation('danceLeft') && hasOffsetAnimation('danceRight');
    doMissThing = !hasOffsetAnimation('singUPmiss'); // if for some reason you only have an up miss, why?

    dance();

    var flips:Bool = isPlayer ? (!curCharacter.startsWith('bf') && !isPsychPlayer) : (curCharacter.startsWith('bf') || isPsychPlayer); // Doesn't flip for BF, since his are already in the right place??? --When Player!
    // Flip for just bf --When Not Player!
    if (flips) flipAnims(true);

    callOnScripts('onChangeCharacter', [curCharacter, isPlayer, characterType]);
    callOnScripts('changeCharacter', [curCharacter, isPlayer, characterType]);
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

    final defaultIfNotFoundArrowSkin:String = PlayState.SONG != null ? PlayState.SONG.options.arrowSkin : noteSkinStyleOfCharacter;
    final defaultIfNotFoundStrumSkin:String = PlayState.SONG != null ? PlayState.SONG.options.strumSkin : strumSkinStyleOfCharacter;
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

    if (json.idleDances != null)
    {
      idleDances =
        {
          dances: json.idleDances.dances != null ? json.idleDances.dances : null,
          idle: json.idleDances.idle != null ? json.idleDances.idle : null,
          danceLR:
            {
              left: json.idleDances.danceLR.left != null ? json.idleDances.danceLR.left : null,
              right: json.idleDances.danceLR.right != null ? json.idleDances.danceLR.right : null
            }
        }
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
    final defaultBeat:Int = Std.int(json.defaultBeat);
    idleBeat = (!Math.isNaN(defaultBeat) && defaultBeat != 0) ? defaultBeat : 1;

    if (json.useGFSpeed != null) useGFSpeed = json.useGFSpeed;

    if (animationsArray != null && animationsArray.length > 0)
    {
      for (anim in animationsArray)
      {
        final animAnim:String = '' + anim.anim;
        final animName:String = '' + anim.name;
        final animFps:Int = anim.fps;
        final animLoop:Bool = !!anim.loop; // Bruh
        final animFlipX:Bool = !!anim.flipX;
        final animFlipY:Bool = !!anim.flipY;
        final animIndices:Array<Int> = anim.indices;
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
      callOnScripts('onUpdate', [elapsed]);
      callOnScripts('update', [elapsed]);
      super.update(elapsed);
      callOnScripts('onUpdatePost', [elapsed]);
      callOnScripts('updatePost', [elapsed]);
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

    callOnScripts('onUpdate', [elapsed]);
    callOnScripts('update', [elapsed]);

    super.update(elapsed);

    callOnScripts('onUpdatePost', [elapsed]);
    callOnScripts('updatePost', [elapsed]);
  }

  public var danced:Bool = false;
  public var stoppedDancing:Bool = false;
  public var stoppedUpdatingCharacter:Bool = false;

  var danceIndex:Int = 0;

  public dynamic function dance(forced:Bool = false, altAnim:Bool = false)
  {
    final result:Dynamic = callOnScripts('onDance', [forced, altAnim]);
    final result2:Dynamic = callOnScripts('dance', [forced, altAnim]);

    if (result == LuaUtils.Function_Stop || result2 == LuaUtils.Function_Stop) return;
    if (!ClientPrefs.data.characters) return;
    if (debugMode || stoppedDancing || skipDance || specialAnim || nonanimated || stopIdle) return;

    if (animation.curAnim != null)
    {
      final canInterrupt:Bool = animInterrupt.get(animation.curAnim.name);

      if (canInterrupt)
      {
        if (idleDances == null)
        {
          var animName:String = ''; // Flow the game!
          if (isDancing)
          {
            danced = !danced;
            if (altAnim
              && hasOffsetAnimation('danceRight-alt')
              && hasOffsetAnimation('danceLeft-alt')) animName = 'dance${danced ? 'Right' : 'Left'}-alt';
            else
              animName = 'dance${(danced ? 'Right' : 'Left') + idleSuffix}';
          }
          else
          {
            if (altAnim
              && (hasOffsetAnimation('idle-alt') || hasOffsetAnimation('idle-alt2'))) animName = hasOffsetAnimation('idle-alt2') ? 'idle-alt2' : 'idle-alt';
            else
              animName = 'idle' + idleSuffix;
          }
          playAnim(animName, forced);
        }
        else
        {
          var animName:String = ''; // Flow the game!
          if (idleDances.dances != null)
          {
            // Code borrowed from Troll-Engine
            if (idleDances.dances.length > 1)
            {
              danceIndex++;
              if (danceIndex >= idleDances.dances.length) danceIndex = 0;
            }
            animName = idleDances.dances[danceIndex] + idleSuffix;
          }
          else if (isDancing && idleDances.danceLR.left != null && idleDances.danceLR.right != null)
          {
            danced = !danced;
            if (altAnim
              && hasOffsetAnimation('dance${idleDances.danceLR.right}-alt')
              && hasOffsetAnimation('dance${idleDances.danceLR.left}-alt'))
              animName = 'dance${danced ? idleDances.danceLR.right : idleDances.danceLR.left}-alt';
            else
              animName = 'dance${(danced ? idleDances.danceLR.right : idleDances.danceLR.left) + idleSuffix}';
          }
          else
          {
            if (altAnim && hasOffsetAnimation('${idleDances.idle}-alt')) animName = '${idleDances.idle}-alt';
            else
              animName = idleDances.idle + idleSuffix;
          }
          playAnim(animName, forced);
        }
      }
    }

    if (color != curColor && doMissThing) color = curColor;
  }

  var missed:Bool = false;

  public var doAffectForAnimationName:Bool = true;

  public dynamic function doAffectForName(name:String):String
  {
    if (name.endsWith('alt') && !hasOffsetAnimation(name)) name = name.split('-')[0];
    if (name == 'laugh' && !hasOffsetAnimation(name)) name = 'singUP';
    if (name.endsWith('miss') && !hasOffsetAnimation(name))
    {
      name = name.substr(0, name.length - 4);
      if (doMissThing) missed = true;
    }

    if (!hasOffsetAnimation(name)) // if it's STILL null, just play idle, and if you REALLY messed up, it'll look in the xml for a valid anim
    {
      if (isDancing && hasOffsetAnimation('danceRight')) name = 'danceRight';
      else if (hasOffsetAnimation('idle')) name = 'idle';
    }

    return name;
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
    final result:Dynamic = callOnScripts('onPlayAnim', [AnimName, Force, Reversed, Frame]);
    final result2:Dynamic = callOnScripts('playAnim', [AnimName, Force, Reversed, Frame]);
    if (result == LuaUtils.Function_Stop || result2 == LuaUtils.Function_Stop) return;

    super.playAnim(AnimName, Force, Reversed, Frame);

    final resultPost:Dynamic = callOnScripts('onPlayAnimPost', [AnimName, Force, Reversed, Frame]);
    final resultPost2:Dynamic = callOnScripts('playAnimPost', [AnimName, Force, Reversed, Frame]);

    if (resultPost == LuaUtils.Function_Stop || resultPost2 == LuaUtils.Function_Stop) return;

    if (!ClientPrefs.data.characters) return;

    _lastPlayedAnimation = AnimName;

    specialAnim = false;
    missed = false;

    if (nonanimated || charNotPlaying) return;

    if (doAffectForAnimationName) AnimName = doAffectForName(AnimName);

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
    else if (color != curColor && doMissThing) color = curColor;

    var daOffset = animOffsets.get(AnimName);

    if (debugMode && isPlayer) daOffset = animPlayerOffsets.get(AnimName);

    if (debugMode)
    {
      if ((hasOffsetAnimation(AnimName) && !isPlayer)
        || (animPlayerOffsets.exists(AnimName) && isPlayer)) offset.set(daOffset[0] * daZoom, daOffset[1] * daZoom);
    }
    else
    {
      if (hasOffsetAnimation(AnimName)) offset.set(daOffset[0] * daZoom, daOffset[1] * daZoom);
    }

    if (doAfterAffectForAnimationName) doAfterAffectForName(AnimName);

    callOnScripts('onPlayedAnim', [AnimName, Force, Reversed, Frame]);
    callOnScripts('playedAnim', [AnimName, Force, Reversed, Frame]);
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
      if (beat % idleBeat == 0) dancing = idleToBeat;
      else if (beat % idleBeat != 0) dancing = isDancingType();
      return dancing;
    }
    else
      return (beat % gfSpeed == 0);
    return false;
  }

  public dynamic function loadMappedAnims(json:String = '', tankManNotes:Bool = false):Void
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
    }
    catch (e:haxe.Exception)
    {
      Debug.logError(e.message);
    }
  }

  public dynamic function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
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
      visible = vis;
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
    callOnScripts('onDraw');
    callOnScripts('draw');
    super.draw();
    callOnScripts('onDrawPost');
    callOnScripts('drawPost');
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
    if (animOffsets != null) animOffsets.clear();
    if (animInterrupt != null) animInterrupt.clear();
    if (animNext != null) animNext.clear();
    if (animDanced != null) animDanced.clear();

    if (animationNotes != null && animationNotes.length > 0) animationNotes.resize(0);

    #if flxanimate
    if (atlas != null) atlas = flixel.util.FlxDestroyUtil.destroy(atlas);
    #end

    #if LUA_ALLOWED
    for (lua in luaArray)
    {
      lua.call('onDestroy', []);
      lua.stop();
    }
    luaArray = null;
    #end

    #if HSCRIPT_ALLOWED
    for (script in hscriptArray)
      if (script != null)
      {
        script.executeFunction('onDestroy');
        script.destroy();
      }
    hscriptArray = null;

    for (script in scHSArray)
      if (script != null)
      {
        script.executeFunc('onDestroy');
        script.destroy();
      }
    scHSArray = null;

    #if HScriptImproved
    for (script in codeNameScripts.scripts)
      if (script != null)
      {
        script.call('onDestroy');
        script.destroy();
      }
    codeNameScripts = null;
    #end
    #end
    super.destroy();
  }

  override function set_color(Color:FlxColor):Int
  {
    curColor = Color;
    return super.set_color(Color);
  }

  #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
  public function loadCharacterScript(name:String = "", preloading:Bool = false)
  {
    final scriptName:String = (name != null && name.length > 0) ? name : curCharacter;
    #if LUA_ALLOWED
    startLuasNamed('data/characters/' + scriptName, false);
    #end
    #if HSCRIPT_ALLOWED
    startHScriptsNamed('data/characters/' + scriptName);
    startSCHSNamed('data/characters/sc/' + scriptName);
    #if HScriptImproved startHSIScriptsNamed('data/characters/advanced/' + scriptName); #end
    #end
  }
  #end

  #if LUA_ALLOWED
  public function startLuasNamed(luaFile:String, ?preloading:Bool = false)
  {
    var scriptFilelua:String = luaFile + '.lua';
    #if MODS_ALLOWED
    var luaToLoad:String = Paths.modFolders(scriptFilelua);
    if (!FileSystem.exists(luaToLoad)) luaToLoad = Paths.getSharedPath(scriptFilelua);

    if (FileSystem.exists(luaToLoad))
    #elseif sys
    var luaToLoad:String = Paths.getSharedPath(scriptFilelua);
    if (OpenFlAssets.exists(luaToLoad))
    #end
    {
      for (script in luaArray)
        if (script.scriptName == luaToLoad) return false;

      new FunkinLua(luaToLoad, 'PLAYSTATE', preloading);
      return true;
    }
    return false;
  }
  #end

  #if HSCRIPT_ALLOWED
  public function startHScriptsNamed(scriptFile:String)
  {
    for (extn in CoolUtil.haxeExtensions)
    {
      var scriptFileHx:String = scriptFile + '.$extn';
      #if MODS_ALLOWED
      var scriptToLoad:String = Paths.modFolders(scriptFileHx);
      if (!FileSystem.exists(scriptToLoad)) scriptToLoad = Paths.getSharedPath(scriptFileHx);
      #else
      var scriptToLoad:String = Paths.getSharedPath(scriptFileHx);
      #end

      if (FileSystem.exists(scriptToLoad))
      {
        if (Iris.instances.exists(scriptToLoad)) return false;

        initHScript(scriptToLoad);
        return true;
      }
    }
    return false;
  }

  public function initHScript(file:String)
  {
    var newScript:HScript = null;
    try
    {
      var times:Float = Date.now().getTime();
      newScript = new HScript(null, file);
      newScript.executeFunction('onCreate');
      hscriptArray.push(newScript);
      Debug.logInfo('initialized Hscript interp successfully: $file (${Std.int(Date.now().getTime() - times)}ms)');
    }
    catch (e:Dynamic)
    {
      var newScript:HScript = cast(Iris.instances.get(file), HScript);
      Debug.logInfo('ERROR ON LOADING ($file) - $e');

      if (newScript != null) newScript.destroy();
    }
  }

  public function startSCHSNamed(scriptFile:String)
  {
    for (extn in CoolUtil.haxeExtensions)
    {
      var scriptFileHx:String = scriptFile + '.$extn';
      #if MODS_ALLOWED
      var scriptToLoad:String = Paths.modFolders(scriptFileHx);
      if (!FileSystem.exists(scriptToLoad)) scriptToLoad = Paths.getSharedPath(scriptFileHx);
      #else
      var scriptToLoad:String = Paths.getSharedPath(scriptFileHx);
      #end

      if (FileSystem.exists(scriptToLoad))
      {
        for (script in scHSArray)
          if (script.hsCode.path == scriptToLoad) return false;

        initSCHS(scriptToLoad);
        return true;
      }
    }
    return false;
  }

  public function initSCHS(file:String)
  {
    var newScript:SCScript = null;
    try
    {
      var times:Float = Date.now().getTime();
      newScript = new SCScript();
      newScript.loadScript(file);
      newScript.executeFunc('onCreate');
      scHSArray.push(newScript);
      Debug.logInfo('initialized SCHScript interp successfully: $file (${Std.int(Date.now().getTime() - times)}ms)');
    }
    catch (e:Dynamic)
    {
      var script:SCScript = null;
      for (scripts in scHSArray)
        if (scripts.hsCode.path == file) script = scripts;
      var newScript:SCScript = script;
      // addTextToDebug('ERROR ON LOADING ($file) - $e', FlxColor.RED);

      if (newScript != null) newScript.destroy();
    }
  }

  #if HScriptImproved
  public function startHSIScriptsNamed(scriptFile:String)
  {
    for (extn in CoolUtil.haxeExtensions)
    {
      var scriptFileHx:String = scriptFile + '.$extn';
      #if MODS_ALLOWED
      var scriptToLoad:String = Paths.modFolders(scriptFileHx);
      if (!FileSystem.exists(scriptToLoad)) scriptToLoad = Paths.getSharedPath(scriptFileHx);
      #else
      var scriptToLoad:String = Paths.getSharedPath(scriptFileHx);
      #end

      if (FileSystem.exists(scriptToLoad))
      {
        for (script in codeNameScripts.scripts)
          if (script.fileName == scriptToLoad) return false;
        initHSIScript(scriptToLoad);
        return true;
      }
    }
    return false;
  }

  public function initHSIScript(scriptFile:String)
  {
    try
    {
      var times:Float = Date.now().getTime();
      #if (HSCRIPT_ALLOWED && HScriptImproved)
      for (ext in CoolUtil.haxeExtensions)
      {
        if (scriptFile.toLowerCase().contains('.$ext'))
        {
          Debug.logInfo('INITIALIZED SCRIPT: ' + scriptFile);
          var script = HScriptCode.create(scriptFile);
          if (!(script is codenameengine.scripting.DummyScript))
          {
            codeNameScripts.add(script);

            // Then CALL SCRIPT
            script.load();
            script.call('onCreate');
          }
        }
      }
      #end
      Debug.logInfo('initialized hscript-improved interp successfully: $scriptFile (${Std.int(Date.now().getTime() - times)}ms)');
    }
    catch (e)
    {
      Debug.logError('Error on loading Script!' + e);
    }
  }
  #end
  #end
  public function callOnAllHS(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var result:Dynamic = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
    if (result == null || excludeValues.contains(result)) result = callOnHSI(funcToCall, args, ignoreStops, exclusions, excludeValues);
    if (result == null || excludeValues.contains(result)) result = callOnSCHS(funcToCall, args, ignoreStops, exclusions, excludeValues);
    return result;
  }

  public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
    if (result == null || excludeValues.contains(result))
    {
      result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
      if (result == null || excludeValues.contains(result)) result = callOnHSI(funcToCall, args, ignoreStops, exclusions, excludeValues);
      if (result == null || excludeValues.contains(result)) result = callOnSCHS(funcToCall, args, ignoreStops, exclusions, excludeValues);
    }
    return result;
  }

  public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;
    #if LUA_ALLOWED
    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var arr:Array<FunkinLua> = [];
    for (script in luaArray)
    {
      if (script.closed)
      {
        arr.push(script);
        continue;
      }

      if (exclusions.contains(script.scriptName)) continue;

      var myValue:Dynamic = script.call(funcToCall, args);
      if ((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll)
        && !excludeValues.contains(myValue)
        && !ignoreStops)
      {
        returnVal = myValue;
        break;
      }

      if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;

      if (script.closed) arr.push(script);
    }

    if (arr.length > 0) for (script in arr)
      luaArray.remove(script);
    #end
    return returnVal;
  }

  public function callOnHScript(funcToCall:String, ?args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;

    #if HSCRIPT_ALLOWED
    if (exclusions == null) exclusions = new Array();
    if (excludeValues == null) excludeValues = new Array();
    excludeValues.push(LuaUtils.Function_Continue);

    var len:Int = hscriptArray.length;
    if (len < 1) return returnVal;
    for (script in hscriptArray)
    {
      @:privateAccess
      if (script == null || !script.exists(funcToCall) || exclusions.contains(script.origin)) continue;

      try
      {
        var callValue = script.call(funcToCall, args);
        var myValue:Dynamic = callValue.signature;

        // compiler fuckup fix
        if ((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll)
          && !excludeValues.contains(myValue)
          && !ignoreStops)
        {
          returnVal = myValue;
          break;
        }
        if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;
      }
      catch (e:Dynamic)
      {
        Debug.logInfo('ERROR (${script.origin}: $funcToCall) - $e');
      }
    }
    #end

    return returnVal;
  }

  public function callOnHSI(funcToCall:String, ?args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;

    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (args == null) args = [];
    if (exclusions == null) exclusions = [];
    if (excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

    var len:Int = codeNameScripts.scripts.length;
    if (len < 1) return returnVal;

    for (script in codeNameScripts.scripts)
    {
      var myValue:Dynamic = script.active ? script.call(funcToCall, args) : null;
      if ((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll)
        && !excludeValues.contains(myValue)
        && !ignoreStops)
      {
        returnVal = myValue;
        break;
      }
      if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;
    }
    #end

    return returnVal;
  }

  public function callOnSCHS(funcToCall:String, ?args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null,
      excludeValues:Array<Dynamic> = null):Dynamic
  {
    var returnVal:Dynamic = LuaUtils.Function_Continue;

    #if HSCRIPT_ALLOWED
    if (exclusions == null) exclusions = new Array();
    if (excludeValues == null) excludeValues = new Array();
    excludeValues.push(LuaUtils.Function_Continue);

    var len:Int = scHSArray.length;
    if (len < 1) return returnVal;
    for (script in scHSArray)
    {
      if (script == null || !script.existsVar(funcToCall) || exclusions.contains(script.hsCode.path)) continue;

      try
      {
        var callValue = script.callFunc(funcToCall, args);
        var myValue:Dynamic = callValue.funcReturn;

        // compiler fuckup fix
        if ((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll)
          && !excludeValues.contains(myValue)
          && !ignoreStops)
        {
          returnVal = myValue;
          break;
        }
        if (myValue != null && !excludeValues.contains(myValue)) returnVal = myValue;
      }
      catch (e:Dynamic)
      {
        Debug.logInfo('ERROR (${script.hsCode.path}: $funcToCall) - $e');
      }
    }
    #end

    return returnVal;
  }

  public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    if (exclusions == null) exclusions = [];
    setOnLuas(variable, arg, exclusions);
    setOnHScript(variable, arg, exclusions);
    setOnHSI(variable, arg, exclusions);
    setOnSCHS(variable, arg, exclusions);
  }

  public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    #if LUA_ALLOWED
    if (exclusions == null) exclusions = [];
    for (script in luaArray)
    {
      if (exclusions.contains(script.scriptName)) continue;

      script.set(variable, arg);
    }
    #end
  }

  public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    #if HSCRIPT_ALLOWED
    if (exclusions == null) exclusions = [];
    for (script in hscriptArray)
    {
      if (exclusions.contains(script.origin)) continue;

      script.set(variable, arg);
    }
    #end
  }

  public function setOnHSI(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (exclusions == null) exclusions = [];
    for (script in codeNameScripts.scripts)
    {
      if (exclusions.contains(script.fileName)) continue;

      script.set(variable, arg);
    }
    #end
  }

  public function setOnSCHS(variable:String, arg:Dynamic, exclusions:Array<String> = null)
  {
    #if HSCRIPT_ALLOWED
    if (exclusions == null) exclusions = [];
    for (script in scHSArray)
    {
      if (exclusions.contains(script.hsCode.path)) continue;

      script.setVar(variable, arg);
    }
    #end
  }

  public function getOnScripts(variable:String, arg:String, exclusions:Array<String> = null)
  {
    if (exclusions == null) exclusions = [];
    getOnLuas(variable, arg, exclusions);
    getOnHScript(variable, exclusions);
    getOnHSI(variable, exclusions);
    getOnSCHS(variable, exclusions);
  }

  public function getOnLuas(variable:String, arg:String, exclusions:Array<String> = null)
  {
    #if LUA_ALLOWED
    if (exclusions == null) exclusions = [];
    for (script in luaArray)
    {
      if (exclusions.contains(script.scriptName)) continue;

      script.get(variable, arg);
    }
    #end
  }

  public function getOnHScript(variable:String, exclusions:Array<String> = null)
  {
    #if HSCRIPT_ALLOWED
    if (exclusions == null) exclusions = [];
    for (script in hscriptArray)
    {
      if (exclusions.contains(script.origin)) continue;

      script.get(variable);
    }
    #end
  }

  public function getOnHSI(variable:String, exclusions:Array<String> = null)
  {
    #if (HSCRIPT_ALLOWED && HScriptImproved)
    if (exclusions == null) exclusions = [];
    for (script in codeNameScripts.scripts)
    {
      if (exclusions.contains(script.fileName)) continue;

      script.get(variable);
    }
    #end
  }

  public function getOnSCHS(variable:String, exclusions:Array<String> = null)
  {
    #if HSCRIPT_ALLOWED
    if (exclusions == null) exclusions = [];
    for (script in scHSArray)
    {
      if (exclusions.contains(script.hsCode.path)) continue;

      script.getVar(variable);
    }
    #end
  }

  public function searchForVarsOnScripts(variable:String, arg:String, result:Bool)
  {
    var result:Dynamic = searchLuaVar(variable, arg, result);
    if (result == null)
    {
      result = searchHxVar(variable, arg, result);
      if (result == null) result = searchHSIVar(variable, arg, result);
    }
    return result;
  }

  public function searchLuaVar(variable:String, arg:String, result:Bool)
  {
    #if LUA_ALLOWED
    for (script in luaArray)
    {
      if (script.get(variable, arg) == result)
      {
        return result;
      }
    }
    #end
    return !result;
  }

  public function searchHxVar(variable:String, arg:String, result:Bool)
  {
    #if HSCRIPT_ALLOWED
    for (script in hscriptArray)
    {
      if (LuaUtils.convert(script.get(variable), arg) == result)
      {
        return result;
      }
    }
    #end
    return !result;
  }

  public function searchHSIVar(variable:String, arg:String, result:Bool)
  {
    #if (HSCRIPT_ALLOWED && HScriptImproved)
    for (script in codeNameScripts.scripts)
    {
      if (LuaUtils.convert(script.get(variable), arg) == result)
      {
        return result;
      }
    }
    #end
    return !result;
  }

  public function getHxNewVar(name:String, type:String):Dynamic
  {
    #if HSCRIPT_ALLOWED
    var hxVar:Dynamic = null;

    // we prioritize modchart cuz frick you

    for (script in hscriptArray)
    {
      var newHxVar = Std.isOfType(script.get(name), Type.resolveClass(type));
      hxVar = newHxVar;
    }
    if (hxVar != null) return hxVar;
    #end

    return null;
  }

  public function getLuaNewVar(name:String, type:String):Dynamic
  {
    #if LUA_ALLOWED
    var luaVar:Dynamic = null;

    // we prioritize modchart cuz frick you

    for (script in luaArray)
    {
      var newLuaVar = script.get(name, type).getVar(name, type);
      if (newLuaVar != null) luaVar = newLuaVar;
    }
    if (luaVar != null) return luaVar;
    #end

    return null;
  }

  public function addScript(file:String, type:ScriptType = CODENAME, ?externalArguments:Array<Dynamic> = null)
  {
    if (externalArguments == null) externalArguments = [];
    switch (type)
    {
      case CODENAME:
        initHSIScript(file);
      case IRIS:
        initHScript(file);
      case SC:
        initSCHS(file);
      case LUA:
        var state:String = (externalArguments[0] != null && externalArguments[0].length > 0) ? externalArguments[0] : 'PLAYSTATE';
        var preload:Bool = externalArguments[1] != null ? externalArguments[1] : false;
        new FunkinLua(file, state, preload);
        Debug.logInfo('length ${luaArray.length}');
    }
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
   * **Note: bf => "bf-dead", bf-pixel => "bf-dead-pixel", bf-holding-gf => "bf-holding-gf-dead"**
   * @default ""
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

  /**
   *
   * @default idle: "idle"
   */
  var ?idleDances:IdleDances;
}

typedef IdleDances =
{
  var ?dances:Array<String>;
  var ?idle:String;
  var ?danceLR:DanceLR;
}

typedef DanceLR =
{
  var left:String;
  var right:String;
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
