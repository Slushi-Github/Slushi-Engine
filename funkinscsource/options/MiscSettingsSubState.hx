package options;

import states.MainMenuState;

class MiscSettingsSubState extends BaseOptionsMenu
{
  public function new()
  {
    title = 'Misc Settings';
    rpcTitle = 'Misc Settings Menu'; // for Discord Rich Presence

    var option:Option = new Option('Watermark', "If checked, SCE Watermarks are on!", 'SCEWatermark', BOOL);
    option.onChange = onChangeMenuMusic;
    addOption(option);

    #if !mobile
    var option:Option = new Option('FPS Counter', 'If unchecked, hides FPS Counter.', 'showFPS', BOOL);
    addOption(option);
    option.onChange = onChangeFPSCounter;

    var option:Option = new Option('Memory Display', 'If unchecked, Memory is displayed in counter.', 'memoryDisplay', BOOL);
    addOption(option);

    var option:Option = new Option('Date Display', 'If unchecked, Date is displayed in counter.', 'dateDisplay', BOOL);
    addOption(option);

    var option:Option = new Option('Military Time', 'If unchecked, Date Time will be 0-23, else PM and AM.', 'militaryTime', BOOL);
    addOption(option);

    var option:Option = new Option('Day As Int', 'If unchecked, Date Day will be 0-6 (1-7), else Monday-Friday.', 'dayAsInt', BOOL);
    addOption(option);

    var option:Option = new Option('Month As Int', 'If unchecked, Date Month is 0-11 (1-12), else January-December.', 'monthAsInt', BOOL);
    addOption(option);
    #end

    var option:Option = new Option('Auto Pause', "If checked, the game automatically pauses if the screen isn't on focus. (turns down volume!)", 'autoPause',
      BOOL);
    addOption(option);

    var resultArray:Array<String> = ['NONE', 'KADE'];

    #if BASE_GAME_FILES resultArray.push('VSLICE'); #end
    var option:Option = new Option('Behavior Engine Type', "May change resultsScreen and/or may change state switching transitions!", 'behaviourType', STRING,
      resultArray);
    addOption(option);

    var option:Option = new Option('Clear Logs Folder On TitleState', "Clear the 'logs' folder", 'clearFolderOnStart', BOOL);
    addOption(option);

    var option:Option = new Option('Hey! Intro', "A Hey! Intro starts for characters that use Hey! animations.", 'heyIntro', BOOL);
    addOption(option);

    var option:Option = new Option('Pause Count Down', "A countdown plays after pressing 'resume' in the pause menu.", 'pauseCountDown', BOOL);
    addOption(option);

    var option:Option = new Option('Opponent Pop Up Score', "If checked, The opponent can have ratings appear!", 'popupScoreForOp', BOOL);
    addOption(option);

    var option:Option = new Option('New Sustain Behavior',
      "If checked, Hold Notes can't be pressed if you miss or don't hit their arrow note first,\nand count as a single Hit/Miss.\nUncheck this if you prefer the old Input System.",
      'newSustainBehavior', BOOL);
    addOption(option);

    super();
  }

  function onChangeMenuMusic()
  {
    FlxG.sound.music.stop();
    FlxG.sound.playMusic(SlushiMain.getSLEPath("Musics/SLE_HackNet_Resonance.ogg"));
    MainMenuState.freakyPlaying = true;
    Conductor.bpm = 102;
  }

  #if !mobile
  function onChangeFPSCounter()
  {
    if (Main.fpsVar != null) Main.fpsVar.visible = ClientPrefs.data.showFPS;
  }
  #end
}
