package backend.stage.base;

#if BASE_GAME_FILES
import objects.stage.*;

class MallXMas extends BaseStage
{
  var upperBoppers:BGSprite;
  var bottomBoppers:MallCrowd;
  var santa:BGSprite;

  public function new()
  {
    super();
  }

  override public function buildStage(baseStage:Stage)
  {
    var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
    bg.setGraphicSize(Std.int(bg.width * 0.8));
    bg.updateHitbox();
    baseStage.stageSpriteHandler(bg, -1, 'bgWalls');

    if (!ClientPrefs.data.lowQuality)
    {
      upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
      upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
      upperBoppers.updateHitbox();
      baseStage.stageSpriteHandler(upperBoppers, -1, 'bgWalls');
      baseStage.addAnimatedBack(upperBoppers);

      var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
      bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
      bgEscalator.updateHitbox();
      baseStage.stageSpriteHandler(bgEscalator, -1, 'bgWalls');
    }

    var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
    baseStage.stageSpriteHandler(tree, -1, 'chritmasTree');

    bottomBoppers = new MallCrowd(-300, 140);
    baseStage.stageSpriteHandler(bottomBoppers, -1, 'bottomBoppers');
    baseStage.addAnimatedBack(bottomBoppers);

    var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
    baseStage.stageSpriteHandler(fgSnow, -1, 'fgSnow');

    santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
    baseStage.stageSpriteHandler(santa, -1, 'santa');
    baseStage.addAnimatedBack(santa);
    Paths.sound('Lights_Shut_off');
    setDefaultGF('gf-christmas');

    if (isStoryMode && !seenCutscene) setEndCallback(eggnogEndCutscene);
  }

  override public function countdownTick(count:Countdown, num:Int)
    everyoneDance();

  override public function beatHit()
    everyoneDance();

  override public function onEvent(eventName:String, eventParams:Array<String>, flValues:Array<Null<Float>>, strumTime:Float)
  {
    switch (eventName)
    {
      case "Hey!":
        switch (eventParams[0].toLowerCase().trim())
        {
          case 'bf' | 'boyfriend' | '0':
            return;
        }
        bottomBoppers.animation.play('hey', true);
        bottomBoppers.heyTimer = flValues[1];
    }
  }

  function everyoneDance()
  {
    if (!ClientPrefs.data.lowQuality) upperBoppers.dance(true);

    bottomBoppers.dance(true);
    santa.dance(true);
  }

  function eggnogEndCutscene()
  {
    if (PlayState.storyPlaylist[1] == null)
    {
      endSong();
      return;
    }

    var nextSong:String = Paths.formatToSongPath(PlayState.storyPlaylist[1]);
    if (nextSong == 'winter-horrorland')
    {
      FlxG.sound.play(Paths.sound('Lights_Shut_off'));

      var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
        -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
      blackShit.scrollFactor.set();
      add(blackShit);
      camHUD.visible = false;

      inCutscene = true;
      canPause = false;

      new FlxTimer().start(1.5, function(tmr:FlxTimer) {
        endSong();
      });
    }
    else
      endSong();
  }
}
#end
