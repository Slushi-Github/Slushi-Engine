import backend.CoolUtil;

function onCreate()
{
  FreeplayState.scorecolorDifficulty.set('HARD', CoolUtil.returnColor('red'));
  FreeplayState.scorecolorDifficulty.set('NORMAL', CoolUtil.returnColor('yellow'));
  FreeplayState.scorecolorDifficulty.set('EASY', CoolUtil.returnColor('green'));
  FreeplayState.scorecolorDifficulty.set('', CoolUtil.returnColor('transparent'));
}
