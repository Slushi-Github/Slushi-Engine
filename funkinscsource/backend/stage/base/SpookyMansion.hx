package backend.stage.base;

#if BASE_GAME_FILES
class SpookyMansion extends BaseStage
{
  var halloweenBG:BGSprite;
  var halloweenWhite:BGSprite;

  public function new()
  {
    super();
  }

  override public function buildStage(baseStage:Stage):Void
  {
    var bg:String = ClientPrefs.data.lowQuality ? 'halloween_bg_low' : 'halloween_bg';
    var anims:Array<String> = ClientPrefs.data.lowQuality ? ['halloweem bg0', 'halloweem bg lightning strike'] : [];
    halloweenBG = new BGSprite(bg, -200, -100, anims);
    baseStage.stageSpriteHandler(halloweenBG, -1, 'halloweenBG');

    halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
    halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
    halloweenWhite.alpha = 0;
    halloweenWhite.blend = ADD;
    baseStage.stageSpriteHandler(halloweenWhite, 4, 'halloweenWhite');

    // PRECACHE SOUNDS
    Paths.sound('thunder_1');
    Paths.sound('thunder_2');

    // Monster cutscene
    if (isStoryMode && !seenCutscene)
    {
      switch (songName)
      {
        case 'monster':
          setStartCallback(monsterCutscene);
      }
    }
  }

  var lightningStrikeBeat:Int = 0;
  var lightningOffset:Int = 8;

  override public function beatHit()
  {
    if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
    {
      lightningStrikeShit();
    }
  }

  function lightningStrikeShit():Void
  {
    FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    if (!ClientPrefs.data.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

    lightningStrikeBeat = curBeat;
    lightningOffset = FlxG.random.int(8, 24);

    if (boyfriend.hasOffsetAnimation('scared')) boyfriend.playAnim('scared', true);

    if (dad.hasOffsetAnimation('scared')) dad.playAnim('scared', true);

    if (gf != null && gf.hasOffsetAnimation('scared')) gf.playAnim('scared', true);

    if (ClientPrefs.data.camZooms)
    {
      FlxG.camera.zoom += 0.015;
      camHUD.zoom += 0.03;

      if (!game.camZooming)
      { // Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
        FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
        FlxTween.tween(camHUD, {zoom: 1}, 0.5);
      }
    }

    if (ClientPrefs.data.flashing)
    {
      halloweenWhite.alpha = 0.4;
      FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
      FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
    }
  }

  function monsterCutscene()
  {
    inCutscene = true;
    camHUD.visible = false;

    FlxG.camera.focusOn(new FlxPoint(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100));

    // character anims
    FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    if (gf != null) gf.playAnim('scared', true);
    boyfriend.playAnim('scared', true);

    // white flash
    var whiteScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
    whiteScreen.scrollFactor.set();
    whiteScreen.blend = ADD;
    add(whiteScreen);
    FlxTween.tween(whiteScreen, {alpha: 0}, 1,
      {
        startDelay: 0.1,
        ease: FlxEase.linear,
        onComplete: function(twn:FlxTween) {
          remove(whiteScreen);
          whiteScreen.destroy();

          camHUD.visible = true;
          startCountdown();
        }
      });
  }
}
#end
