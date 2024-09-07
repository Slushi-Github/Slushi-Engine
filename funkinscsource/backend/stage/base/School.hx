package backend.stage.base;

#if BASE_GAME_FILES
import states.stages.objects.*;
import substates.GameOverSubstate;
import cutscenes.DialogueBox;
import openfl.utils.Assets as OpenFlAssets;

class School extends BaseStage
{
  var bgGirls:BackgroundGirls;

  public function new()
  {
    super();
  }

  override public function buildStage(baseStage:Stage)
  {
    var _song = PlayState.SONG.gameOverData;
    if (_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
    if (_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-pixel';
    if (_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
    if (_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'bf-pixel-dead';

    var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
    bgSky.antialiasing = false;
    baseStage.stageSpriteHandler(bgSky, -1, 'weebSky');

    var repositionShit = -200;

    var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
    baseStage.stageSpriteHandler(bgSchool, -1, 'weebSchool');
    bgSchool.antialiasing = false;

    var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
    baseStage.stageSpriteHandler(bgStreet, -1, 'weebStreet');
    bgStreet.antialiasing = false;

    var widShit = Std.int(bgSky.width * PlayState.daPixelZoom);
    if (!ClientPrefs.data.lowQuality)
    {
      var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
      fgTrees.setGraphicSize(Std.int(widShit * 0.8));
      fgTrees.updateHitbox();
      baseStage.stageSpriteHandler(fgTrees, -1, 'weebTreesBack');
      fgTrees.antialiasing = false;
    }

    var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
    bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
    bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
    bgTrees.animation.play('treeLoop');
    bgTrees.scrollFactor.set(0.85, 0.85);
    baseStage.stageSpriteHandler(bgTrees, -1, 'weebTrees');
    bgTrees.antialiasing = false;

    if (!ClientPrefs.data.lowQuality)
    {
      var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
      treeLeaves.setGraphicSize(widShit);
      treeLeaves.updateHitbox();
      baseStage.stageSpriteHandler(treeLeaves, -1, 'petals');
      treeLeaves.antialiasing = false;
    }

    bgSky.setGraphicSize(widShit);
    bgSchool.setGraphicSize(widShit);
    bgStreet.setGraphicSize(widShit);
    bgTrees.setGraphicSize(Std.int(widShit * 1.4));

    bgSky.updateHitbox();
    bgSchool.updateHitbox();
    bgStreet.updateHitbox();
    bgTrees.updateHitbox();

    if (!ClientPrefs.data.lowQuality)
    {
      bgGirls = new BackgroundGirls(-100, 190, '');
      bgGirls.scrollFactor.set(0.9, 0.9);
      baseStage.stageSpriteHandler(bgGirls, -1, 'bgGirls');
    }
    setDefaultGF('gf-pixel');

    switch (songName)
    {
      case 'senpai':
        FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
        FlxG.sound.music.fadeIn(1, 0, 0.8);
      case 'roses':
        FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
    }
    if (isStoryMode && !seenCutscene)
    {
      if (songName == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
      initDoof();
      baseStage.setStartCallbackStage(schoolIntro);
    }
  }

  override public function beatHit()
  {
    if (bgGirls != null) bgGirls.beatHit(curBeat);
  }

  // For events
  override public function onEvent(eventName:String, eventParams:Array<String>, flValues:Array<Null<Float>>, time:Float)
  {
    switch (eventName)
    {
      case "BG Freaks Expression":
        if (bgGirls != null) bgGirls.swapDanceType();
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
    var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
    black.scrollFactor.set();
    if (songName == 'senpai') add(black);

    new FlxTimer().start(0.3, function(tmr:FlxTimer) {
      black.alpha -= 0.15;

      if (black.alpha <= 0)
      {
        if (doof != null) add(doof);
        else
          startCountdown();

        remove(black);
        black.destroy();
      }
      else
        tmr.reset(0.3);
    });
  }
}
#end
