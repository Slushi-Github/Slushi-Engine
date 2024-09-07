package backend.stage.base;

import objects.stage.*;
import backend.stage.HenchmenKillState;

#if BASE_GAME_FILES
class LimoRide extends BaseStage
{
  var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
  var fastCar:BGSprite;
  var fastCarCanDrive:Bool = true;

  // event
  var limoKillingState:HenchmenKillState = WAIT;
  var limoMetalPole:BGSprite;
  var limoLight:BGSprite;
  var limoCorpse:BGSprite;
  var limoCorpseTwo:BGSprite;
  var bgLimo:BGSprite;
  var grpLimoParticles:FlxTypedGroup<BGSprite>;
  var dancersDiff:Float = 320;

  public function new()
  {
    super();
  }

  override public function buildStage(baseStage:Stage)
  {
    var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
    baseStage.stageSpriteHandler(skyBG, -1, 'limoSunset');

    if (!ClientPrefs.data.lowQuality)
    {
      limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
      baseStage.stageSpriteHandler(limoMetalPole, -1, 'metalPole');

      bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
      baseStage.stageSpriteHandler(bgLimo, -1, 'bgLimo');

      limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
      baseStage.stageSpriteHandler(limoCorpse, -1, 'corpseOne');

      limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
      baseStage.stageSpriteHandler(limoCorpseTwo, -1, 'corpseTwo');

      grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
      baseStage.stageSpriteHandler(grpLimoDancers, -1, 'grpLimoDancers');
      baseStage.setSwagGroup('grpLimoDancers', grpLimoDancers);

      for (i in 0...5)
      {
        var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + dancersDiff + bgLimo.x, bgLimo.y - 400);
        dancer.scrollFactor.set(0.4, 0.4);
        grpLimoDancers.add(dancer);
      }

      limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
      baseStage.stageSpriteHandler(limoLight, -1, 'limoLight');

      grpLimoParticles = new FlxTypedGroup<BGSprite>();
      baseStage.stageSpriteHandler(grpLimoParticles, -1, 'grpLimoParticles');
      baseStage.setSwagGroup('grpLimoParticles', grpLimoParticles);

      // PRECACHE BLOOD
      var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
      particle.alpha = 0.01;
      grpLimoParticles.add(particle);
      resetLimoKill();

      // PRECACHE SOUND
      Paths.sound('dancerdeath');
      setDefaultGF('gf-car');
    }

    fastCar = new BGSprite('limo/fastCarLol', -300, 160);
    fastCar.active = true;
    resetFastCar();
    baseStage.stageSpriteHandler(fastCar, 4, 'fastCar');

    var limo:BGSprite = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);
    baseStage.stageSpriteHandler(limo, 0, 'limo'); // Shitty layering but whatev it works LOL
  }

  var limoSpeed:Float = 0;

  override public function update(elapsed:Float)
  {
    if (!ClientPrefs.data.lowQuality)
    {
      grpLimoParticles.forEach(function(spr:BGSprite) {
        if (spr.animation.curAnim.finished)
        {
          spr.kill();
          grpLimoParticles.remove(spr, true);
          spr.destroy();
        }
      });

      switch (limoKillingState)
      {
        case KILLING:
          limoMetalPole.x += 5000 * elapsed;
          limoLight.x = limoMetalPole.x - 180;
          limoCorpse.x = limoLight.x - 50;
          limoCorpseTwo.x = limoLight.x + 35;

          var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
          for (i in 0...dancers.length)
          {
            if (dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170)
            {
              switch (i)
              {
                case 0 | 3:
                  if (i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

                  var diffStr:String = i == 3 ? ' 2 ' : ' ';
                  var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'],
                    false);
                  grpLimoParticles.add(particle);
                  var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4,
                    ['hench arm spin' + diffStr + 'PINK'], false);
                  grpLimoParticles.add(particle);
                  var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'],
                    false);
                  grpLimoParticles.add(particle);

                  var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
                  particle.flipX = true;
                  particle.angle = -57.5;
                  grpLimoParticles.add(particle);
                case 1:
                  limoCorpse.visible = true;
                case 2:
                  limoCorpseTwo.visible = true;
              } // Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
              dancers[i].x += FlxG.width * 2;
            }
          }

          if (limoMetalPole.x > FlxG.width * 2)
          {
            resetLimoKill();
            limoSpeed = 800;
            limoKillingState = SPEEDING_OFFSCREEN;
          }

        case SPEEDING_OFFSCREEN:
          limoSpeed -= 4000 * elapsed;
          bgLimo.x -= limoSpeed * elapsed;
          if (bgLimo.x > FlxG.width * 1.5)
          {
            limoSpeed = 3000;
            limoKillingState = SPEEDING;
          }

        case SPEEDING:
          limoSpeed -= 2000 * elapsed;
          if (limoSpeed < 1000) limoSpeed = 1000;

          bgLimo.x -= limoSpeed * elapsed;
          if (bgLimo.x < -275)
          {
            limoKillingState = STOPPING;
            limoSpeed = 800;
          }
          dancersParenting();

        case STOPPING:
          bgLimo.x = FlxMath.lerp(-150, bgLimo.x, Math.exp(-elapsed * 9));
          if (Math.round(bgLimo.x) == -150)
          {
            bgLimo.x = -150;
            limoKillingState = WAIT;
          }
          dancersParenting();

        default: // nothing
      }
    }
  }

  override public function beatHit()
  {
    if (!ClientPrefs.data.lowQuality)
    {
      grpLimoDancers.forEach(function(dancer:BackgroundDancer) {
        dancer.beatHit(curBeat);
      });
    }

    if (FlxG.random.bool(10) && fastCarCanDrive) fastCarDrive();
  }

  // Substates for pausing/resuming tweens and timers
  override public function closeSubState()
  {
    if (paused)
    {
      if (carTimer != null) carTimer.active = true;
    }
  }

  override public function openSubState(SubState:flixel.FlxSubState)
  {
    if (paused)
    {
      if (carTimer != null) carTimer.active = false;
    }
  }

  override public function onEvent(eventName:String, eventParams:Array<String>, flValue:Array<Null<Float>>, strumTime:Float)
  {
    switch (eventName)
    {
      case "Kill Henchmen":
        killHenchmen();
    }
  }

  function dancersParenting()
  {
    var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
    for (i in 0...dancers.length)
    {
      dancers[i].x = (370 * i) + dancersDiff + bgLimo.x;
    }
  }

  function resetLimoKill():Void
  {
    limoMetalPole.x = -500;
    limoMetalPole.visible = false;
    limoLight.x = -500;
    limoLight.visible = false;
    limoCorpse.x = -500;
    limoCorpse.visible = false;
    limoCorpseTwo.x = -500;
    limoCorpseTwo.visible = false;
  }

  function resetFastCar():Void
  {
    fastCar.x = -12600;
    fastCar.y = FlxG.random.int(140, 250);
    fastCar.velocity.x = 0;
    fastCarCanDrive = true;
  }

  var carTimer:FlxTimer;

  function fastCarDrive()
  {
    // trace('Car drive');
    FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;
    carTimer = new FlxTimer().start(2, function(tmr:FlxTimer) {
      resetFastCar();
      carTimer = null;
    });
  }

  function killHenchmen():Void
  {
    if (!ClientPrefs.data.lowQuality)
    {
      if (limoKillingState == WAIT)
      {
        limoMetalPole.x = -400;
        limoMetalPole.visible = true;
        limoLight.visible = true;
        limoCorpse.visible = false;
        limoCorpseTwo.visible = false;
        limoKillingState = KILLING;

        #if ACHIEVEMENTS_ALLOWED
        var kills = Achievements.addScore("roadkill_enthusiast");
        FlxG.log.add('Henchmen kills: $kills');
        #end
      }
    }
  }
}
#end
