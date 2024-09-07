package objects.stage;

import flixel.math.FlxAngle;

class BackgroundTank extends BGSprite
{
  public var offsetX:Float = 400;
  public var offsetY:Float = 1300;
  public var tankSpeed:Float = 0;
  public var tankAngle:Float = 0;

  public function new()
  {
    super('tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
    tankSpeed = FlxG.random.float(5, 7);
    tankAngle = FlxG.random.int(-90, 45);
    antialiasing = ClientPrefs.data.antialiasing;
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);
    var daAngleOffset:Float = 1;
    tankAngle += elapsed * tankSpeed;
    angle = tankAngle - 90 + 15;
    x = offsetX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
    y = offsetY + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
  }
}
