package backend.stage.base;

#if BASE_GAME_FILES
import flixel.addons.effects.FlxTrail;
import objects.stage.*;
import substates.GameOverSubstate;
import cutscenes.DialogueBox;
import openfl.utils.Assets as OpenFlAssets;

class SchoolEvil extends BaseStage
{
  public function new()
  {
    super();
  }

  override public function buildStage(baseStage:Stage)
  {
    var posX = 400;
    var posY = 200;

    var bg:BGSprite;
    if (!ClientPrefs.data.lowQuality) bg = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
    else
      bg = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);

    bg.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
    bg.antialiasing = false;
    baseStage.stageSpriteHandler(bg, -1, 'animatedEvilSchool');
    setDefaultGF('gf-pixel');

    if (!ClientPrefs.data.lowQuality)
    {
      bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
      bgGhouls.setGraphicSize(Std.int(bgGhouls.width * PlayState.daPixelZoom));
      bgGhouls.updateHitbox();
      bgGhouls.visible = false;
      bgGhouls.antialiasing = false;
      bgGhouls.animation.finishCallback = function(name:String) {
        if (name == 'BG freaks glitch instance') bgGhouls.visible = false;
      }
      baseStage.stageSpriteHandler(bgGhouls, -1, 'bgGhouls');
    }

    FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
    FlxG.sound.music.fadeIn(1, 0, 0.8);
    if (isStoryMode && !seenCutscene)
    {
      initDoof();
      setStartCallback(schoolIntro);
    }
  }

  override function createPost()
  {
    var _song = PlayState.SONG.gameOverData;
    if (_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
    if (_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-pixel';
    if (_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
    if (_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'bf-pixel-dead';
  }

  // Ghouls event
  var bgGhouls:BGSprite;

  override public function onEvent(eventName:String, eventParams:Array<String>, flValues:Array<Null<Float>>, strumTime:Float)
  {
    switch (eventName)
    {
      case "Trigger BG Ghouls":
        if (!ClientPrefs.data.lowQuality)
        {
          bgGhouls.dance(true);
          bgGhouls.visible = true;
        }
    }
  }

  var doof:DialogueBox = null;

  function initDoof()
  {
    var file:String = Paths.txt('songs/$songName/${songName}Dialogue_${ClientPrefs.data.language}'); // Checks for vanilla/Senpai dialogue
    #if MODS_ALLOWED
    if (!FileSystem.exists(file))
    #else
    if (!OpenFlAssets.exists(file))
    #end
    {
      file = Paths.txt('songs/$songName/${songName}Dialogue');
    }

    #if MODS_ALLOWED
    if (!FileSystem.exists(file))
    #else
    if (!OpenFlAssets.exists(file))
    #end
    {
      startCountdown();
      return;
    }

    doof = new DialogueBox(false, CoolUtil.coolTextFile(file));
    doof.cameras = [camHUD];
    doof.scrollFactor.set();
    doof.finishThing = startCountdown;
    doof.nextDialogueThing = PlayState.instance.startNextDialogue;
    doof.skipDialogueThing = PlayState.instance.skipDialogue;
  }

  function schoolIntro():Void
  {
    inCutscene = true;
    var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
    red.scrollFactor.set();
    add(red);

    var senpaiEvil:FlxSprite = new FlxSprite();
    senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
    senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
    senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
    senpaiEvil.scrollFactor.set();
    senpaiEvil.updateHitbox();
    senpaiEvil.screenCenter();
    senpaiEvil.x += 300;
    camHUD.visible = false;

    new FlxTimer().start(2.1, function(tmr:FlxTimer) {
      if (doof != null)
      {
        add(senpaiEvil);
        senpaiEvil.alpha = 0;
        new FlxTimer().start(0.3, function(swagTimer:FlxTimer) {
          senpaiEvil.alpha += 0.15;
          if (senpaiEvil.alpha < 1)
          {
            swagTimer.reset();
          }
          else
          {
            senpaiEvil.animation.play('idle');
            FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function() {
              remove(senpaiEvil);
              senpaiEvil.destroy();
              remove(red);
              red.destroy();
              FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function() {
                add(doof);
                camHUD.visible = true;
              }, true);
            });
            new FlxTimer().start(3.2, function(deadTime:FlxTimer) {
              FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
            });
          }
        });
      }
    });
  }
}
#end
