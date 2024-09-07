package backend.stage.base;

#if BASE_GAME_FILES
import sobjects.stages.*;
import objects.Character;

class PhillyTrain extends BaseStage
{
  var phillyLightsColors:Array<FlxColor>;
  var phillyWindow:BGSprite;
  var phillyStreet:BGSprite;
  var phillyTrain:PhillyTrainSprite;
  var curLight:Int = -1;

  // For Philly Glow events
  var blammedLightsBlack:FlxSprite;
  var phillyGlowGradient:PhillyGlowGradient;
  var phillyGlowParticles:FlxTypedGroup<PhillyGlowParticle>;
  var phillyWindowEvent:BGSprite;
  var curLightEvent:Int = -1;

  public function new()
  {
    super();
  }

  override public function buildStage(baseStage:Stage)
  {
    if (!ClientPrefs.data.lowQuality)
    {
      var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
      baseStage.stageSpriteHandler(bg, -1, 'sky');
    }

    var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
    city.setGraphicSize(Std.int(city.width * 0.85));
    city.updateHitbox();
    baseStage.stageSpriteHandler(city, -1, 'city');

    phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
    phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
    phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
    phillyWindow.updateHitbox();
    baseStage.stageSpriteHandler(phillyWindow, -1, 'window');
    phillyWindow.alpha = 0;

    if (!ClientPrefs.data.lowQuality)
    {
      var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
      baseStage.stageSpriteHandler(streetBehind, -1, 'behindTrain');
    }

    phillyTrain = new PhillyTrainSprite(2000, 360);
    baseStage.stageSpriteHandler(phillyTrain, -1, 'train');

    phillyStreet = new BGSprite('philly/street', -40, 50);
    baseStage.stageSpriteHandler(phillyStreet, -1, 'street');

    blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
    blammedLightsBlack.visible = false;
    baseStage.stageSpriteHandler(blammedLightsBlack, -1, 'blammedLightsBlack');

    phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
    phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
    phillyWindowEvent.updateHitbox();
    phillyWindowEvent.visible = false;
    baseStage.stageSpriteHandler(phillyWindowEvent, -1, 'phillyWindowEvent');

    phillyGlowGradient = new PhillyGlowGradient(-400, 225); // This shit was refusing to properly load FlxGradient so fuck it
    phillyGlowGradient.visible = false;
    baseStage.stageSpriteHandler(phillyGlowGradient, -1, 'phillyGlowGradient');
    if (!ClientPrefs.data.flashing) phillyGlowGradient.intendedAlpha = 0.7;

    Paths.image('philly/particle'); // precache philly glow particle image
    phillyGlowParticles = new FlxTypedGroup<PhillyGlowParticle>();
    phillyGlowParticles.visible = false;
    baseStage.stageSpriteHandler(phillyGlowParticles, -1, 'phillyGlowParticles');
  }

  override public function update(elapsed:Float)
  {
    phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
    if (phillyGlowParticles != null)
    {
      phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle) {
        if (particle.alpha <= 0) particle.kill();
      });
    }
  }

  override public function beatHit()
  {
    phillyTrain.beatHit(curBeat);
    if (curBeat % 4 == 0)
    {
      curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
      phillyWindow.color = phillyLightsColors[curLight];
      phillyWindow.alpha = 1;
    }
  }

  override public function onEvent(eventName:String, eventParams:Array<String>, flValue:Array<Null<Float>>, strumTime:Float)
  {
    switch (eventName)
    {
      case "Philly Glow":
        if (flValue[0] == null || flValue[0] <= 0) flValue[0] = 0;
        var lightId:Int = Math.round(flValue[0]);

        var chars:Array<Character> = [boyfriend, gf, dad];
        switch (lightId)
        {
          case 0:
            if (phillyGlowGradient.visible)
            {
              doFlash();
              if (ClientPrefs.data.camZooms)
              {
                FlxG.camera.zoom += 0.5;
                camHUD.zoom += 0.1;
              }

              blammedLightsBlack.visible = false;
              phillyWindowEvent.visible = false;
              phillyGlowGradient.visible = false;
              phillyGlowParticles.visible = false;
              curLightEvent = -1;

              for (who in chars)
              {
                who.color = FlxColor.WHITE;
              }
              phillyStreet.color = FlxColor.WHITE;
            }

          case 1: // turn on
            curLightEvent = FlxG.random.int(0, phillyLightsColors.length - 1, [curLightEvent]);
            var color:FlxColor = phillyLightsColors[curLightEvent];

            if (!phillyGlowGradient.visible)
            {
              doFlash();
              if (ClientPrefs.data.camZooms)
              {
                FlxG.camera.zoom += 0.5;
                camHUD.zoom += 0.1;
              }

              blammedLightsBlack.visible = true;
              blammedLightsBlack.alpha = 1;
              phillyWindowEvent.visible = true;
              phillyGlowGradient.visible = true;
              phillyGlowParticles.visible = true;
            }
            else if (ClientPrefs.data.flashing)
            {
              var colorButLower:FlxColor = color;
              colorButLower.alphaFloat = 0.25;
              FlxG.camera.flash(colorButLower, 0.5, null, true);
            }

            var charColor:FlxColor = color;
            if (!ClientPrefs.data.flashing) charColor.saturation *= 0.5;
            else
              charColor.saturation *= 0.75;

            for (who in chars)
            {
              who.color = charColor;
            }
            phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle) {
              particle.color = color;
            });
            phillyGlowGradient.color = color;
            phillyWindowEvent.color = color;

            color.brightness *= 0.5;
            phillyStreet.color = color;

          case 2: // spawn particles
            if (!ClientPrefs.data.lowQuality)
            {
              var particlesNum:Int = FlxG.random.int(8, 12);
              var width:Float = (2000 / particlesNum);
              var color:FlxColor = phillyLightsColors[curLightEvent];
              for (j in 0...3)
              {
                for (i in 0...particlesNum)
                {
                  var particle:PhillyGlowParticle = phillyGlowParticles.recycle(PhillyGlowParticle);
                  particle.x = -400 + width * i + FlxG.random.float(-width / 5, width / 5);
                  particle.y = phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40);
                  particle.color = color;
                  phillyGlowParticles.add(particle);
                }
              }
            }
            phillyGlowGradient.bop();
        }
    }
  }

  public function doFlash()
  {
    var color:FlxColor = FlxColor.WHITE;
    if (!ClientPrefs.data.flashing) color.alphaFloat = 0.5;

    FlxG.camera.flash(color, 0.15, null, true);
  }
}
#end
