package objects.note;

import psychlua.LuaUtils;
import openfl.Assets;
import objects.note.Note;
import shaders.RGBPalette;
import shaders.RGBPixelShader.RGBPixelShaderReference;

// Most of the Original code from Mr.Bruh (mr.bruh69)
// Ported to haxe and edited by me (glowsoony)

typedef HoldCoverData =
{
  texture:String,
  useRGBShader:Bool,
  r:FlxColor,
  g:FlxColor,
  b:FlxColor,
  a:Int
}

enum abstract HoldCoverStep(String) to String from String
{
  var STOP = 'Stop';
  var DONE = 'Done';
  var HOLDING = 'Holding';
  var SPLASHING = 'Splashing';
}

class HoldCoverSprite extends FunkinSCSprite
{
  public var boom:Bool = false;
  public var isPlaying:Bool = false;
  public var activatedSprite:Bool = true;
  public var useRGBShader:Bool = false;

  public var rgbShader:RGBPixelShaderReference;
  public var spriteId:String = "";
  public var spriteIntID:Int = -1;
  public var skin:String = "";
  public var coverData:HoldCoverData =
    {
      texture: null,
      useRGBShader: (PlayState.SONG != null) ? !(PlayState.SONG.options.disableSplashRGB == true) : true,
      r: -1,
      g: -1,
      b: -1,
      a: 1
    }
  public var offsetX:Float = 0;
  public var offsetY:Float = 0;

  public dynamic function initShader(noteData:Int)
  {
    rgbShader = new RGBPixelShaderReference();
    shader = rgbShader.shader;
  }

  public dynamic function initFrames(i:Int, hcolor:String)
  {
    if (PlayState.SONG != null)
    {
      var changeHoldCover:Bool = (PlayState.SONG.options.holdCoverSkin != null
        && PlayState.SONG.options.holdCoverSkin != "default"
        && PlayState.SONG.options.holdCoverSkin != "");

      // Before replace
      var holdCoverSkin:String = (changeHoldCover ? PlayState.SONG.options.holdCoverSkin : 'holdCover');

      this.skin = holdCoverSkin;

      var foundFirstPath:Bool = #if MODS_ALLOWED FileSystem.exists(Paths.getPath('images/HoldNoteEffect/RGB/$holdCoverSkin$hcolor.png', IMAGE))
        || #end Assets.exists(Paths.getPath('images/HoldNoteEffect/RGB/$holdCoverSkin$hcolor.png', IMAGE));
      var foundSecondPath:Bool = #if MODS_ALLOWED FileSystem.exists(Paths.getPath('images/HoldNoteEffect/$holdCoverSkin$hcolor.png', IMAGE))
        || #end Assets.exists(Paths.getPath('images/HoldNoteEffect/$holdCoverSkin$hcolor.png', IMAGE));
      var foundThirdPath:Bool = #if MODS_ALLOWED FileSystem.exists(Paths.getPath('images/$holdCoverSkin$hcolor.png',
        TEXT)) || #end Assets.exists(Paths.getPath('images/$holdCoverSkin$hcolor.png', TEXT));

      if (frames == null)
      {
        if (foundFirstPath)
        {
          var holdCoverSkinNonRGB:Bool = PlayState.SONG.options.disableHoldCoversRGB;
          this.frames = Paths.getSparrowAtlas(holdCoverSkinNonRGB ? 'HoldNoteEffect/$holdCoverSkin$hcolor' : 'HoldNoteEffect/RGB/$holdCoverSkin$hcolor');
          if (!holdCoverSkinNonRGB) this.initShader(i);
        }
        else if (foundSecondPath)
        {
          this.frames = Paths.getSparrowAtlas('HoldNoteEffect/$holdCoverSkin$hcolor');
        }
        else if (foundThirdPath)
        {
          this.frames = Paths.getSparrowAtlas('$holdCoverSkin$hcolor');
        }
        else
        {
          this.frames = Paths.getSparrowAtlas('HoldNoteEffect/holdCover$hcolor');
        }
      }
    }
    else
    {
      this.skin = "holdCover";
      this.frames = Paths.getSparrowAtlas('HoldNoteEffect/holdCover$hcolor');
    }
  }

  public dynamic function initAnimations(i:Int, hcolor:String)
  {
    this.animation.addByPrefix(Std.string(i), 'holdCover$hcolor', 24, true);
    this.animation.addByPrefix(Std.string(i) + 'p', 'holdCoverEnd$hcolor', 24, false);
  }

  public dynamic function shaderCopy(noteData:Int, note:Note)
  {
    this.antialiasing = ClientPrefs.data.antialiasing;
    if (skin.contains('pixel') || !ClientPrefs.data.antialiasing) this.antialiasing = false;
    var tempShader:RGBPalette = null;
    if ((note == null || this.coverData.useRGBShader) && (PlayState.SONG == null || !PlayState.SONG.options.disableHoldCoversRGB))
    {
      // If Splash RGB is enabled:
      if (note != null)
      {
        if (this.coverData.r != -1) note.rgbShader.r = this.coverData.r;
        if (this.coverData.g != -1) note.rgbShader.g = this.coverData.g;
        if (this.coverData.b != -1) note.rgbShader.b = this.coverData.b;
        tempShader = note.rgbShader.parent;
      }
      else
        tempShader = Note.globalRgbShaders[noteData];
    }
    rgbShader.containsPixel = (skin.contains('pixel') || PlayState.isPixelStage);
    rgbShader.copyValues(tempShader);
  }

  public dynamic function affectSplash(splashStep:HoldCoverStep, ?noteData:Int = -1, ?note:Note = null)
  {
    if (noteData == -1 && note == null) return;
    switch (splashStep)
    {
      // Stop
      case STOP:
        shaderCopy(noteData, note);
        isPlaying = boom = visible = false;
        animation.stop();
      // Done
      case DONE:
        isPlaying = boom = visible = false;
      // While Holding
      case HOLDING:
        shaderCopy(noteData, note);
        visible = true;
        if (!isPlaying) playAnim(Std.string(noteData));
      // When splash happens
      case SPLASHING:
        isPlaying = false;
        boom = true;
        playAnim(Std.string(noteData) + 'p');
    }
  }
}
