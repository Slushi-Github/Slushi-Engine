package backend.stage.base;

import openfl.display.BlendMode;

class MainStage extends BaseStage
{
  var dadbattleBlack:BGSprite;
  var dadbattleLight:BGSprite;
  var dadbattleFog:DadBattleFog;

  public function new()
  {
    super();
  }

  override public function buildStage(baseStage:Stage):Void
  {
    var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
    baseStage.stageSpriteHandler(bg, -1, "stageBack");

    var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
    stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
    stageFront.updateHitbox();
    baseStage.stageSpriteHandler(stageFront, -1, "stageFront");
    if (!ClientPrefs.data.lowQuality)
    {
      var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
      stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
      stageLight.updateHitbox();
      baseStage.stageSpriteHandler(stageLight, 4, "stageLight_L");
      var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
      stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
      stageLight.updateHitbox();
      stageLight.flipX = true;
      baseStage.stageSpriteHandler(stageLight, 4, "stageLight_R");

      var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
      stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
      stageCurtains.updateHitbox();
      baseStage.stageSpriteHandler(stageCurtains, -1, "stageCurtains");
    }

    dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
    dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
    dadbattleBlack.alpha = 0.25;
    dadbattleBlack.visible = false;
    baseStage.stageSpriteHandler(dadbattleBlack, 4, "dadbattleBlack");

    dadbattleLight = new BGSprite('spotlight', 400, -400);
    dadbattleLight.alpha = 0.375;
    dadbattleLight.blend = BlendMode.ADD;
    dadbattleLight.visible = false;
    baseStage.stageSpriteHandler(dadbattleLight, 4, "dadbattleLight");

    dadbattleFog = new DadBattleFog();
    dadbattleFog.visible = false;
    baseStage.stageSpriteHandler(dadbattleFog, 4, "dadbattleFog");
  }

  override public function onEvent(name:String, params:Array<String>, flValues:Array<Null<Float>>, time:Float)
  {
    switch (name)
    {
      case "Dadbattle Spotlight":
        if (flValues[0] == null) flValues[0] = 0;
        var val:Int = Math.round(flValues[0]);

        switch (val)
        {
          case 1, 2, 3: // enable and target dad
            if (val == 1) // enable
            {
              dadbattleBlack.visible = true;
              dadbattleLight.visible = true;
              dadbattleFog.visible = true;
              defaultCamZoom += 0.12;
            }

            var who:Character = dad;
            if (val > 2) who = boyfriend;
            // 2 only targets dad
            dadbattleLight.alpha = 0;
            new FlxTimer().start(0.12, function(tmr:FlxTimer) {
              dadbattleLight.alpha = 0.375;
            });
            dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);
            FlxTween.tween(dadbattleFog, {alpha: 0.7}, 1.5, {ease: FlxEase.quadInOut});

          default:
            dadbattleBlack.visible = false;
            dadbattleLight.visible = false;
            defaultCamZoom -= 0.12;
            FlxTween.tween(dadbattleFog, {alpha: 0}, 0.7, {onComplete: function(twn:FlxTween) dadbattleFog.visible = false});
        }
    }
  }
}
