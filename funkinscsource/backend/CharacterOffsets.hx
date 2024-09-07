package backend;

// bcuz god damn it. those offset things in playstate take up a bunch of space
class CharacterOffsets
{
  public var daOffsetArray:Array<Float> = [0, 0, 0, 0, 0, 0];
  public var hasOffsets:Bool = true;

  public function new(curCharacter:String = 'dad', isPlayer:Bool = false, ?isGF:Bool = false)
  {
    // in order this is +x, +y, +camPosX, +camPosY, +camPosX from midpoint, +camPosY from midpoint.
    daOffsetArray = [0, 0, 0, 0, 0, 0];

    if (isGF)
    {
      switch (curCharacter)
      {
        default:
          daOffsetArray = [0, 0, 0, 0, 0, 0];
      }
      return;
    }
    if (!isPlayer)
    {
      switch (curCharacter)
      {
        case 'tankman':
          daOffsetArray = [0, 200, 0, 0, 0, 0];
        case 'spooky':
          daOffsetArray = [-100, 190, 0, 0, 0, 0];
          if (curCharacter == 'spooky') daOffsetArray[1] = 200;
        case 'bf':
          daOffsetArray = [0, 350, 0, 0, 0, 0];
        case 'monster-christmas' | 'monster':
          daOffsetArray = [-60, 90, 0, 0, 0, 0];
          if (curCharacter == 'monster-christmas') daOffsetArray[1] = 50;
        case 'dad':
          daOffsetArray = [0, -10, 400, 0, 0, 0];
        case 'bf-gf':
          daOffsetArray = [-30, 350, 600, 0, 0, 0];
        case 'senpai' | 'senpai-angry':
          if (PlayState.curStage.contains('school')) daOffsetArray = [150, 360, 0, 0, 300, 0];
          else
            daOffsetArray = [160, 260, 0, 0, 300, 0];
        case 'bf-gf-pixel' | 'bf-pixel':
          daOffsetArray = [150, 460, 0, 0, 300, 0];
        case 'spirit':
          daOffsetArray = [-150, 100, 0, 0, 300, 200];
        case 'parents-christmas': // for characters who literally change one value
          daOffsetArray = [0, 0, 0, 0, 0, 0];
          switch (curCharacter)
          {
            case 'parents-christmas': daOffsetArray[0] = -500;
          }
        default:
          daOffsetArray = [0, 0, 0, 0, 0, 0];
          hasOffsets = false;
      }
    }
    else if (isPlayer)
    {
      switch (curCharacter)
      {
        case 'pico':
          daOffsetArray = [0, -50, 0, 0, 0, 0];
        case 'monster' | 'monster-christmas':
          daOffsetArray = [20, -260, 0, 0, -100, -100];
          if (curCharacter == 'monster-christmas') daOffsetArray[1] = -300;
        case 'senpai' | 'senpai-angry':
          if (PlayState.curStage.contains('school')) daOffsetArray = [0, -200, 0, 0, 0, 0];
          else
            daOffsetArray = [120, -70, 0, 0, 0, 0];
        case 'spooky':
          daOffsetArray = [10, -145, 0, 0, 0, 0];
        case 'dad':
          daOffsetArray = [0, -350, 0, 0, 0, 0];
        case 'mom-car' | 'mom' | 'bf-mom-car' | 'bf-mom':
          daOffsetArray = [10, -380, 0, 0, 0, 0];
        case 'tankman':
          daOffsetArray = [0, -150, 0, 0, 0, 0];
        case 'bf-pixel' | 'bf-tankman-pixel' | 'bf-tankman-pixel-happy' | 'bf-senpai-pixel':
          if (!PlayState.curStage.contains('school'))
          {
            daOffsetArray = [190, 150, 0, 0, 0, 0];
            if (curCharacter.contains('tankman'))
            {
              daOffsetArray[0] -= 20;
              daOffsetArray[1] -= 20;
            }
          }
        case 'bf-gf' | 'bf-gf-demon':
          daOffsetArray = [60, -30, 0, 0, 0, 0];
        case 'bf-dad':
          daOffsetArray = [0, -350, 0, 0, 0, 0];
        default:
          daOffsetArray = [0, 0, 0, 0, 0, 0];
          hasOffsets = false;
      }
    }
  }
}
