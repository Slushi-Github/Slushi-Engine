package backend;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import states.TitleState;

// Add a variable here and it will get automatically saved
@:structInit class SaveVariables
{
  #if windows
	public var windowAlpha:Bool = true;
	public var windowsNotifications:Bool = true;
	public var changeWindowBorderColorWithNoteHit:Bool = true;
	#if SLUSHI_CPP_CODE
	public var winTaskBar:Bool = true;
	public var changeWallPaper:Bool = true;
	public var winDesktopIcons:Bool = true;
	public var gdiEffects:Bool = true;
	public var winScreenShots:Bool = true;
  public var useSavedWallpaper:Bool = true;
	#end
  #end

  public var downScroll:Bool = false;
  public var middleScroll:Bool = false;
  public var LightUpStrumsOP:Bool = true;
  public var showFPS:Bool = true;
  public var flashing:Bool = true;
  public var autoPause:Bool = true;
  public var antialiasing:Bool = true;
  public var noteSkin:String = 'Default';
  public var splashSkin:String = 'Psych';
  public var splashAlpha:Float = 0.6;
  public var lowQuality:Bool = false;
  public var shaders:Bool = true;
  public var cacheOnGPU:Bool = #if ! switch false #else true #end; // From Stilic
  public var framerate:Int = 60;
  public var cursing:Bool = true;
  public var violence:Bool = true;
  public var camZooms:Bool = true;
  public var hideHud:Bool = false;
  public var noteOffset:Int = 0;
  public var arrowRGB:Array<Array<FlxColor>> = [
    [0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
    [0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
    [0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
    [0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
  ];
  public var arrowRGBPixel:Array<Array<FlxColor>> = [
    [0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
    [0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
    [0xFF71E300, 0xFFF6FFE6, 0xFF003100],
    [0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]
  ];
  public var arrowRGBQuantize:Array<Array<FlxColor>> = [
    [0xFFFF0000, 0xFFFFFFFF, 0xFF7F0000], // 4th step
    [0xFF0000FF, 0xFFFFFFFF, 0xFF00007F], // 8th step
    [0xFF800080, 0xFFFFFFFF, 0xFF400040], // 12th step
    [0xFF00FF00, 0xFFFFFFFF, 0xFF007F00], // 16th step
    [0xFFFFFF00, 0xFFFFFFFF, 0xFF7F7F00], // 24th step
    [0xFF00FFDD, 0xFFFFFFFF, 0xFF018573], // 32nd step
    [0xFFFF00FF, 0xFFFFFFFF, 0xFF8A018A], // 48th step
    [0xFFFF7300, 0xFFFFFFFF, 0xFF883D00] // 64th step
  ];

  /*public var arrowRGBQuantizeALLSTEPS:Array<Array<FlxColor>> = [ //Smth
      [0xFFFF0000, 0xFFFFFFFF, 0xFF7F0000], //4th step
      [0xFF0000FF, 0xFFFFFFFF, 0xFF00007F], //8th step
      [0xFF800080, 0xFFFFFFFF, 0xFF400040], //12th step
      [0xFFFFFF00, 0xFFFFFFFF, 0xFF7F7F00], //16th step
      [0xFFFF00FF, 0xFFFFFFFF, 0xFF8A018A], //24th step
      [0xFFFF7300, 0xFFFFFFFF, 0xFF883D00], //32nd step
      [0xFF00FFDD, 0xFFFFFFFF, 0xFF018573], //48th step
      [0xFF00FF00, 0xFFFFFFFF, 0xFF007F00], //64th step
      [0xFFFD9B9B, 0xFFFFFFFF, 0xFFBD7676], //96th step`
      [0xFFBE97FC, 0xFFFFFFFF, 0xFF67518C], //128th step
      [0xFF97FC9E, 0xFFFFFFFF, 0xFF558D59], //192th step
      [0xFFB6490B, 0xFFFFFFFF, 0xFF5F2808], //256th step
      [0xA5316D75, 0xFFFFFFFF, 0xA8245054], //384th step
      [0xFF0B0994, 0xFFFFFFFF, 0xFF070658], //512th step
      [0xFFA6A6A6, 0xFFFFFFFF, 0xFF6A6969], //768th step
      [0xFF2DAD91, 0xFFFFFFFF, 0xFF14715D], //1024th step
      [0xFF000000, 0xFFFFFFFF, 0xFF000000], //1536th step
      [0xFFB4AB00, 0xFFFFFFFF, 0xFF525213], //2048th step
      [0xFFE7E38D, 0xFFFFFFFF, 0xFF949466], //3072nd step
      [0xFF1E7444, 0xFFFFFFFF, 0xFF144D21] //6144th step
    ]; */
  public var ghostTapping:Bool = true;
  public var timeBarType:String = 'Time Left';
  public var scoreZoom:Bool = true;
  public var noReset:Bool = false;
  public var healthBarAlpha:Float = 1;
  public var hitsoundVolume:Float = 0;
  public var hitSounds:String = "None";
  public var hitsoundType:String = "None";
  public var pauseMusic:String = 'Tea Time';
  public var checkForUpdates:Bool = true;
  public var comboStacking:Bool = true;
  public var gameplaySettings:Map<String, Dynamic> = [
    'scrollspeed' => 1.0,
    'scrolltype' => 'multiplicative',
    // anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
    // an amod example would be chartSpeed * multiplier
    // cmod would just be constantSpeed = chartSpeed
    // and xmod basically works by basing the speed on the bpm.
    // iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
    // bps is calculated by bpm / 60
    // oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
    // just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
    // oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
    // -kade
    'songspeed' => 1.0,
    'healthgain' => 1.0,
    'healthloss' => 1.0,
    'opponent' => false,
    'instakill' => false,
    'practice' => false,
    'showcasemode' => false,
    'sustainnotesactive' => true,
    'modchart' => true,
    'botplay' => false,
  ];

  public var comboOffset:Array<Int> = [0, 0, 0, 0];
  public var swagWindow:Float = 22.5;
  public var sickWindow:Float = 45;
  public var goodWindow:Float = 90;
  public var badWindow:Float = 135;
  public var shitWindow:Float = 180;
  public var safeFrames:Float = 10;
  public var discordRPC:Bool = true;

  public var hudStyle:String = 'PSYCH';

  public var gjUser:String = "";
  public var gjToken:String = "";
  public var gjleaderboardToggle:Bool = false;

  // New Stuff
  public var useGL:Bool = true;
  public var healthColor:Bool = true;
  public var instantRespawn:Bool = false;
  public var stillCombo:Bool = false;
  public var colorBarType:String = 'No Colors';
  public var mouseLook:String = 'FNF Cursor';
  public var judgementCounter:Bool = false;
  public var memoryDisplay:Bool = true;
  public var cameraMovement:Bool = false;
  public var missSounds:Bool = true;

  // Date Stuff For StatsCounter
  public var militaryTime:Bool = true;
  public var monthAsInt:Bool = true;
  public var dayAsInt:Bool = true;
  public var dateDisplay:Bool = true;

  // Custom hud stuff
  public var customHudName:String = 'FNF';
  public var healthBarStyle:String = 'healthBar';
  public var countDownStyle:Array<String> = ["ready", "set", "go"];
  public var countDownSounds:Array<String> = ["intro3", "intro2", "intro1", "introGo"];
  public var ratingStyle:Array<String> = ["", ""];
  public var gameOverStyle:String = "gameOver";

  public var gameCombo:Bool = false;

  public var splashAlphaAsStrumAlpha:Bool = false;
  public var showCombo:Bool = false;
  public var showComboNum:Bool = true;
  public var showRating:Bool = true;

  public var popupScoreForOp:Bool = true;

  public var behaviourType:String = 'NONE';

  public var systemUserName:String = "";

  public var language:String = 'en-US';

  public var SCEWatermark:Bool = true;

  public var breakTimer:Bool = false;

  public var laneTransparency:Float = 0;

  // Started Freeplay Warn!
  public var freeplayWarn:Bool = false;

  public var newSustainBehavior:Bool = true;

  public var coloredText:Bool = false;

  public var splashOption:String = 'Both';

  public var characters:Bool = true;
  public var background:Bool = true;

  public var clearFolderOnStart:Bool = false;

  public var iconMovement:String = 'None';

  public var gradientSystemForOldBars:Bool = false;

  public var heyIntro:Bool = false;

  public var pauseCountDown:Bool = false;

  public var vanillaStrumAnimations:Bool = false;
  public var holdCoverPlay:Bool = true;

  public var colorNoteType:String = 'None';
}

class ClientPrefs
{
  public static var data:SaveVariables = {};
  public static var defaultData:SaveVariables = {};

  // Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
  public static var keyBinds:Map<String, Array<FlxKey>> = [
    // Key Bind, Name for ControlsSubState
    'note_up' => [W, UP],
    'note_left' => [A, LEFT],
    'note_down' => [S, DOWN],
    'note_right' => [D, RIGHT],
    'ui_up' => [W, UP],
    'ui_left' => [A, LEFT],
    'ui_down' => [S, DOWN],
    'ui_right' => [D, RIGHT],
    'accept' => [SPACE, ENTER],
    'back' => [BACKSPACE, ESCAPE],
    'pause' => [ENTER, ESCAPE],
    'reset' => [R],
    'volume_mute' => [ZERO],
    'volume_up' => [NUMPADPLUS, PLUS],
    'volume_down' => [NUMPADMINUS, MINUS],
    'debug_1' => [SEVEN],
    'debug_2' => [EIGHT],
    'debug_3' => [SIX],
    'space' => [SPACE]
  ];
  public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
    'note_up' => [DPAD_UP, Y],
    'note_left' => [DPAD_LEFT, X],
    'note_down' => [DPAD_DOWN, A],
    'note_right' => [DPAD_RIGHT, B],
    'ui_up' => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
    'ui_left' => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
    'ui_down' => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
    'ui_right' => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
    'accept' => [A, START],
    'back' => [B],
    'pause' => [START],
    'reset' => [BACK]
  ];
  public static var defaultKeys:Map<String, Array<FlxKey>> = null;
  public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

  public static function resetKeys(controller:Null<Bool> = null) // Null = both, False = Keyboard, True = Controller
  {
    if (controller != true) for (key in keyBinds.keys())
      if (defaultKeys.exists(key)) keyBinds.set(key, defaultKeys.get(key).copy());
    if (controller != false) for (button in gamepadBinds.keys())
      if (defaultButtons.exists(button)) gamepadBinds.set(button, defaultButtons.get(button).copy());
  }

  public static function clearInvalidKeys(key:String)
  {
    var keyBind:Array<FlxKey> = keyBinds.get(key);
    var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
    while (keyBind != null && keyBind.contains(NONE))
      keyBind.remove(NONE);
    while (gamepadBind != null && gamepadBind.contains(NONE))
      gamepadBind.remove(NONE);
  }

  public static function loadDefaultKeys()
  {
    defaultKeys = keyBinds.copy();
    defaultButtons = gamepadBinds.copy();
  }

  public static function saveSettings()
  {
    for (key in Reflect.fields(data))
    {
      Debug.logTrace('saved variable: $key');
      Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
    }
    #if ACHIEVEMENTS_ALLOWED Achievements.save(); #end
    flush();

    // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
    var save:FlxSave = new FlxSave();
    save.bind('controls_v3', CoolUtil.getSavePath());
    save.data.keyboard = keyBinds;
    save.data.gamepad = gamepadBinds;
    flush(save);
    FlxG.log.add("Settings saved!");
  }

  public static function flush(?save:FlxSave):Void
  {
    if (save != null) save.flush();
    else
      FlxG.save.flush();
  }

  public static function loadPrefs()
  {
    // Prevent crashes if the save data is corrupted.
    utils.SerializerUtil.initSerializer();

    #if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

    for (key in Reflect.fields(data))
      if (key != 'gameplaySettings' && Reflect.hasField(FlxG.save.data, key)) Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));

    if (Main.fpsVar != null)
    {
      Main.fpsVar.visible = data.showFPS;
    }

    #if (!html && ! switch)
    if (FlxG.save.data.framerate == null)
    {
      final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
      data.framerate = Std.int(FlxMath.bound(refreshRate, 60, 240));
    }
    #end

    if (data.framerate > FlxG.drawFramerate)
    {
      FlxG.updateFramerate = data.framerate;
      FlxG.drawFramerate = data.framerate;
    }
    else
    {
      FlxG.drawFramerate = data.framerate;
      FlxG.updateFramerate = data.framerate;
    }

    if (FlxG.save.data.gameplaySettings != null)
    {
      var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
      for (name => value in savedMap)
        data.gameplaySettings.set(name, value);
    }

    // flixel automatically saves your volume!
    if (FlxG.save.data.volume != null) FlxG.sound.volume = FlxG.save.data.volume;
    if (FlxG.save.data.mute != null) FlxG.sound.muted = FlxG.save.data.mute;

    #if DISCORD_ALLOWED DiscordClient.check(); #end
  }

  public static function keybindSaveLoad()
  {
    // controls on a separate save file
    var save:FlxSave = new FlxSave();
    save.bind('controls_v3', CoolUtil.getSavePath());
    if (save != null)
    {
      if (save.data.keyboard != null)
      {
        var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
        for (control => keys in loadedControls)
        {
          if (keyBinds.exists(control)) keyBinds.set(control, keys);
        }
      }
      if (save.data.gamepad != null)
      {
        var loadedControls:Map<String, Array<FlxGamepadInputID>> = save.data.gamepad;
        for (control => keys in loadedControls)
        {
          if (gamepadBinds.exists(control)) gamepadBinds.set(control, keys);
        }
      }
      reloadVolumeKeys();
    }
  }

  inline public static function getGameplaySetting(name:String, defaultValue:Dynamic = null, ?customDefaultValue:Bool = false):Dynamic
  {
    if (!customDefaultValue) defaultValue = defaultData.gameplaySettings.get(name);
    return /*PlayState.isStoryMode ? defaultValue : */ (data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue);
  }

  public static function reloadVolumeKeys()
  {
    Main.muteKeys = keyBinds.get('volume_mute').copy();
    Main.volumeDownKeys = keyBinds.get('volume_down').copy();
    Main.volumeUpKeys = keyBinds.get('volume_up').copy();
    toggleVolumeKeys(true);
  }

  public static function toggleVolumeKeys(?turnOn:Bool = true)
  {
    final emptyArray = [];
    FlxG.sound.muteKeys = turnOn ? Main.muteKeys : emptyArray;
    FlxG.sound.volumeDownKeys = turnOn ? Main.volumeDownKeys : emptyArray;
    FlxG.sound.volumeUpKeys = turnOn ? Main.volumeUpKeys : emptyArray;
  }

  public static function getkeys(keyname:String, separator:String = ' | ') // for lazyness
  {
    var keys:Array<String> = [];
    for (i in 0...2)
    {
      var randomKey:String = InputFormatter.getKeyName(keyBinds.get(keyname)[i]);
      keys[i] = randomKey;
    }
    return keys[0] == '---' ? keys[1] : keys[1] == '---' ? keys[0] : keys[0] + separator + keys[1];
  }

  public static function splashOption(type:String):Bool
  {
    switch (type)
    {
      case 'Player':
        return (data.splashOption == 'Player' || data.splashOption == 'Both') ? true : false;
      default:
        return (data.splashOption == 'Opponent' || data.splashOption == 'Both') ? true : false;
    }
    return false;
  }
}
