package options;

import backend.StageData;
import states.MainMenuState;
import flixel.FlxObject;

class OptionsState extends MusicBeatState
{
  public static final options:Array<String> = [
    'Slushi Engine Options',
    'Note Options',
    'Controls',
    'Adjust Delay and Combo',
    'Graphics',
    'Visuals',
    'Gameplay',
    'Misc'
    #if TRANSLATIONS_ALLOWED, 'Language', #end
  ];

  private var grpOptions:FlxTypedGroup<Alphabet>;

  private static var curSelected:Int = 0;
  public static var menuBG:FlxSprite;
  public static var onPlayState:Bool = false;

  function openSelectedSubstate(label:String)
  {
    switch (label)
    {
      case 'Slushi Engine Options':
        FlxTransitionableState.skipNextTransOut = true;
        FlxTransitionableState.skipNextTransIn = true;
        MusicBeatState.switchState(new slushi.slushiOptions.SlushiOptionsState());
      case 'Note Options':
        FlxTransitionableState.skipNextTransOut = true;
        FlxTransitionableState.skipNextTransIn = true;
        MusicBeatState.switchState(new options.NoteOptions());
      case 'Controls':
        openSubState(new options.ControlsSubState());
      case 'Graphics':
        openSubState(new options.GraphicsSettingsSubState());
      case 'Visuals':
        openSubState(new options.VisualsSettingsSubState());
      case 'Gameplay':
        openSubState(new options.GameplaySettingsSubState());
      case 'Misc':
        openSubState(new options.MiscSettingsSubState());
      case 'Adjust Delay and Combo':
        MusicBeatState.switchState(new options.NoteOffsetState());
      case 'Language':
        openSubState(new options.LanguageSubState());
    }
  }

  var selectorLeft:Alphabet;
  var selectorRight:Alphabet;

  var bg:FlxSprite;

  var camFollow:FlxObject;
  var camFollowPos:FlxObject;
  var camMain:FlxCamera;
  var camSub:FlxCamera;

  override function create()
  {
    #if DISCORD_ALLOWED
    DiscordClient.changePresence("Options Menu", null);
    #end

    Conductor.bpm = 128.0;

    final yScroll:Float = Math.max(0.25 - (0.05 * (options.length - 5)), 0.1);
    bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
    bg.color = 0xFF98f0f8;
    bg.scale.set(1.07, 1.07);
    bg.updateHitbox();
    bg.updateHitbox();
    bg.screenCenter();
    bg.y += 5;
    add(bg);

    grpOptions = new FlxTypedGroup<Alphabet>();
    add(grpOptions);

    for (num => option in options)
    {
      var optionText:Alphabet = new Alphabet(0, 0, Language.getPhrase('options_$option', option), true);
      optionText.screenCenter();
      optionText.y += (78 * (num - (options.length / 2))) + 65;
      grpOptions.add(optionText);
    }

    selectorLeft = new Alphabet(0, 0, '>', true);
    add(selectorLeft);
    selectorRight = new Alphabet(0, 0, '<', true);
    add(selectorRight);

    changeSelection();
    ClientPrefs.saveSettings();

    super.create();
  }

  override function closeSubState()
  {
    super.closeSubState();
    ClientPrefs.saveSettings();
    #if DISCORD_ALLOWED
    DiscordClient.changePresence("Options Menu", null);
    #end
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

    var mult:Float = FlxMath.lerp(1.07, bg.scale.x, CoolUtil.clamp(1 - (elapsed * 9), 0, 1));
    bg.scale.set(mult, mult);
    bg.updateHitbox();
    bg.offset.set();

    if (controls.UI_UP_P) changeSelection(-1);

    if (controls.UI_DOWN_P) changeSelection(1);

    var shiftMult:Int = 1;

    if (FlxG.mouse.wheel != 0)
    {
      FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
      changeSelection(-shiftMult * FlxG.mouse.wheel);
    }

    if (controls.BACK)
    {
      FlxG.sound.play(Paths.sound('cancelMenu'));
      if (onPlayState)
      {
        StageData.loadDirectory(PlayState.SONG);
        LoadingState.loadAndSwitchState(new PlayState());
        FlxG.sound.music.volume = 0;
      }
      else
      {
        MusicBeatState.switchState(new slushi.states.SlushiMainMenuState());
      }
    }
    else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
  }

  function changeSelection(change:Int = 0)
  {
    curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

    for (num => item in grpOptions.members)
    {
      item.targetY = num - curSelected;
      item.alpha = 0.6;
      if (item.targetY == 0)
      {
        item.alpha = 1;
        selectorLeft.x = item.x - 63;
        selectorLeft.y = item.y;
        selectorRight.x = item.x + item.width + 15;
        selectorRight.y = item.y;
      }
    }
    FlxG.sound.play(Paths.sound('scrollMenu'));
  }

  override function beatHit()
  {
    super.beatHit();

    bg.scale.set(1.11, 1.11);
    bg.updateHitbox();
    bg.offset.set();
  }

  override function destroy()
  {
    ClientPrefs.loadPrefs();
    ClientPrefs.keybindSaveLoad();
    super.destroy();
  }
}
