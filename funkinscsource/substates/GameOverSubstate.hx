package substates;

import backend.WeekData;
import flixel.FlxObject;
import flixel.FlxSubState;
import objects.Character;
import states.StoryMenuState;

class GameOverSubstate extends MusicBeatSubState
{
  public static var characterName:String = '';
  public static var deathSoundName:String = 'fnf_loss_sfx';
  public static var loopSoundName:String = 'gameOver';
  public static var endSoundName:String = 'gameOverEnd';
  public static var deathDelay:Float = 0;

  public static var instance:GameOverSubstate;

  public var boyfriend:Character;

  var camFollow:FlxObject;

  var stageSuffix:String = "";

  public function new(?playStateBoyfriend:Character = null)
  {
    if (playStateBoyfriend != null
      && playStateBoyfriend.curCharacter == characterName) // Avoids spawning a second boyfriend cuz animate atlas is laggy
    {
      this.boyfriend = playStateBoyfriend;
    }
    super();
  }

  public static function resetVariables()
  {
    characterName = 'bf-dead';
    deathSoundName = 'fnf_loss_sfx';
    loopSoundName = 'gameOver';
    endSoundName = 'gameOverEnd';
    deathDelay = 0;

    var _song = PlayState.SONG.gameOverData;
    if (_song != null)
    {
      if (_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
      if (_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
      if (_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) loopSoundName = _song.gameOverLoop;
      if (_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) endSoundName = _song.gameOverEnd;
    }
  }

  var charX:Float = 0;
  var charY:Float = 0;

  var overlay:FlxSprite;
  var overlayConfirmOffsets:FlxPoint = FlxPoint.get();

  override function create()
  {
    instance = this;

    #if windows
    WindowsFuncs.tweenWindowBorderColor([255, 0, 0], [0, 0, 0], 1, 'linear');
    #end

    Conductor.songPosition = 0;

    if (boyfriend == null)
    {
      boyfriend = new Character(PlayState.instance.boyfriend.getScreenPosition().x, PlayState.instance.boyfriend.getScreenPosition().y, characterName, true,
        'BF');
      boyfriend.x += boyfriend.positionArray[0] - PlayState.instance.boyfriend.positionArray[0];
      boyfriend.y += boyfriend.positionArray[1] - PlayState.instance.boyfriend.positionArray[1];
    }
    boyfriend.skipDance = true;
    add(boyfriend);

    FlxG.sound.play(Paths.sound(deathSoundName));
    FlxG.camera.scroll.set();
    FlxG.camera.target = null;

    boyfriend.playAnim('firstDeath');

    camFollow = new FlxObject(0, 0, 1, 1);
    camFollow.setPosition(boyfriend.getGraphicMidpoint().x + boyfriend.cameraPosition[0], boyfriend.getGraphicMidpoint().y + boyfriend.cameraPosition[1]);
    FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
    FlxG.camera.follow(camFollow, LOCKON, 0.01);
    add(camFollow);

    PlayState.instance.setOnScripts('inGameOver', true);
    PlayState.instance.callOnScripts('onGameOverStart', []);
    FlxG.sound.music.loadEmbedded(Paths.music(loopSoundName), true);

    if (characterName == 'pico-dead')
    {
      overlay = new FlxSprite(boyfriend.x + 205, boyfriend.y - 80);
      overlay.frames = Paths.getSparrowAtlas('Pico_Death_Retry');
      overlay.animation.addByPrefix('deathLoop', 'Retry Text Loop', 24, true);
      overlay.animation.addByPrefix('deathConfirm', 'Retry Text Confirm', 24, false);
      overlay.antialiasing = ClientPrefs.data.antialiasing;
      overlayConfirmOffsets.set(250, 200);
      overlay.visible = false;
      add(overlay);

      boyfriend.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
        switch (name)
        {
          case 'firstDeath':
            if (frameNumber >= 36 - 1)
            {
              overlay.visible = true;
              overlay.animation.play('deathLoop');
              boyfriend.animation.callback = null;
            }
          default:
            boyfriend.animation.callback = null;
        }
      }

      if (PlayState.instance.gf != null && PlayState.instance.gf.curCharacter == 'nene')
      {
        var neneKnife:FlxSprite = new FlxSprite(boyfriend.x - 450, boyfriend.y - 250);
        neneKnife.frames = Paths.getSparrowAtlas('NeneKnifeToss');
        neneKnife.animation.addByPrefix('anim', 'knife toss', 24, false);
        neneKnife.antialiasing = ClientPrefs.data.antialiasing;
        neneKnife.animation.finishCallback = function(_) {
          remove(neneKnife);
          neneKnife.destroy();
        }
        insert(0, neneKnife);
        neneKnife.animation.play('anim', true);
      }
    }

    super.create();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    PlayState.instance.callOnScripts('onUpdate', [elapsed]);

    var justPlayedLoop:Bool = false;
    if (!boyfriend.isAnimationNull() && boyfriend.getLastAnimationPlayed() == 'firstDeath' && boyfriend.isAnimationFinished())
    {
      boyfriend.playAnim('deathLoop');
      if (overlay != null && overlay.animation.exists('deathLoop'))
      {
        overlay.visible = true;
        overlay.animation.play('deathLoop');
      }
      justPlayedLoop = true;
    }

    if (!isEnding)
    {
      if (controls.ACCEPT)
      {
        endBullshit();
      }
      else if (controls.BACK)
      {
        #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
        FlxG.camera.visible = false;
        FlxG.sound.music.stop();
        PlayState.deathCounter = 0;
        PlayState.seenCutscene = false;
        PlayState.chartingMode = false;
        PlayState.modchartMode = false;

        if (ClientPrefs.data.behaviourType != 'VSLICE')
        {
          if (PlayState.isStoryMode) MusicBeatState.switchState(new StoryMenuState());
          else
            MusicBeatState.switchState(new slushi.states.freeplay.SlushiFreeplayState());
        }
        #if BASE_GAME_FILES
        else
        {
          if (PlayState.isStoryMode)
          {
            PlayState.storyPlaylist = [];
            openSubState(new vslice.transition.StickerSubState(null, (sticker) -> new StoryMenuState(sticker)));
          }
          else
            openSubState(new vslice.transition.StickerSubState(null, (sticker) -> new slushi.states.freeplay.SlushiFreeplayState(sticker)));
        }
        #end

        FlxG.sound.playMusic(SlushiMain.getSLEPath("Musics/SLE_HackNet_Resonance.ogg"));
        PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
      }
      else if (justPlayedLoop)
      {
        switch (PlayState.SONG.stage)
        {
          case 'tank':
            coolStartDeath(0.2);

            var exclude:Array<Int> = [];
            // if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];
            FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
              if (!isEnding)
              {
                FlxG.sound.music.fadeIn(0.2, 1, 4);
              }
            });
          default:
            coolStartDeath();
        }
      }

      if (FlxG.sound.music != null)
      {
        if (FlxG.sound.music.playing)
        {
          Conductor.songPosition = FlxG.sound.music.time;
        }

        FlxG.sound.music.onComplete = function() {
          timesMusicRepeated += 1;
        }
      }
    }
    if (!isEnding && timesMusicRepeated == 2) // Really? you let the music repeat 2 times now?
    {
      endBullshit();
    }
    PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
  }

  var timesMusicRepeated:Int = 0;
  var isEnding:Bool = false;

  function coolStartDeath(?volume:Float = 1):Void
  {
    FlxG.sound.music.play(true);
    FlxG.sound.music.volume = volume;
  }

  function endBullshit():Void
  {
    if (!isEnding)
    {

      #if windows
      WindowsFuncs.tweenWindowBorderColor([185, 157, 0], CustomFuncs.colorIntToRGB(SlushiMain.slushiColor), 2, 'linear');
      #end

      isEnding = true;
      if (boyfriend.hasOffsetAnimation('deathConfirm')) boyfriend.playAnim('deathConfirm', true);

      if (overlay != null && overlay.animation.exists('deathConfirm'))
      {
        overlay.visible = true;
        overlay.animation.play('deathConfirm');
        overlay.offset.set(overlayConfirmOffsets.x, overlayConfirmOffsets.y);
      }
      FlxG.sound.music.stop();
      FlxG.sound.play(Paths.music(endSoundName));
      new FlxTimer().start(0.7, function(tmr:FlxTimer) {
        FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
          LoadingState.loadAndSwitchState(new PlayState());
        });
      });
      PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
    }
  }

  override function destroy()
  {
    instance = null;
    super.destroy();
  }
}
