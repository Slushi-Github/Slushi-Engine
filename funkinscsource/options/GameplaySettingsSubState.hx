package options;

class GameplaySettingsSubState extends BaseOptionsMenu
{
  public function new()
  {
    title = Language.getPhrase('gameplay_menu', 'Gameplay Settings');
    rpcTitle = 'Gameplay Settings Menu'; // for Discord Rich Presence

    // I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
    var option:Option = new Option('Downscroll', // Name
      'If checked, notes go Down instead of Up, simple enough.', // Description
      'downScroll', // Save data variable name
      BOOL); // Variable type
    addOption(option);

    var option:Option = new Option('Middlescroll', 'If checked, your notes get centered.', 'middleScroll', BOOL);
    addOption(option);

    var option:Option = new Option('Ghost Tapping', "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
      'ghostTapping', BOOL);
    addOption(option);

    var option:Option = new Option('Disable Reset Button', "If checked, pressing Reset won't do anything.", 'noReset', BOOL);
    addOption(option);

    var option:Option = new Option('Swag!! Hit Window', 'Changes the amount of time you have\nfor hitting a "Swag" in milliseconds.', 'swagWindow', FLOAT);
    option.displayFormat = '%vms';
    option.scrollSpeed = 8;
    option.minValue = 5;
    option.maxValue = 22.5;
    option.changeValue = 0.1;
    addOption(option);

    var option:Option = new Option('Sick! Hit Window', 'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.', 'sickWindow', FLOAT);
    option.displayFormat = '%vms';
    option.scrollSpeed = 15;
    option.minValue = 15;
    option.maxValue = 45;
    option.changeValue = 0.1;
    addOption(option);

    var option:Option = new Option('Good Hit Window', 'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.', 'goodWindow', FLOAT);
    option.displayFormat = '%vms';
    option.scrollSpeed = 30;
    option.minValue = 15;
    option.maxValue = 90;
    option.changeValue = 0.1;
    addOption(option);

    var option:Option = new Option('Bad Hit Window', 'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.', 'badWindow', FLOAT);
    option.displayFormat = '%vms';
    option.scrollSpeed = 60;
    option.minValue = 15;
    option.maxValue = 135;
    option.changeValue = 0.1;
    addOption(option);

    var option:Option = new Option('Shit Hit Window', 'Changes the amount of time you have\nfor hitting a "Shit" in milliseconds.', 'shitWindow', FLOAT);
    option.displayFormat = '%vms';
    option.scrollSpeed = 60;
    option.minValue = 15;
    option.maxValue = 180;
    option.changeValue = 0.1;
    addOption(option);

    var option:Option = new Option('Safe Frames', 'Changes how many frames you have for\nhitting a note earlier or late.', 'safeFrames', FLOAT);
    option.scrollSpeed = 5;
    option.minValue = 2;
    option.maxValue = 10;
    option.changeValue = 0.1;
    addOption(option);

    var option:Option = new Option('Hitsound in what way', 'if checked, note and keys do a hitsound when pressed!, else just when notes are hit!',
      'hitsoundType', STRING, ['None', 'Keys', 'Notes']);
    addOption(option);

    var option:Option = new Option('Hitsound Volume', 'Funny notes does \"Tick!\" when you hit them.', 'hitsoundVolume', PERCENT);
    addOption(option);
    option.scrollSpeed = 1.6;
    option.minValue = 0.0;
    option.maxValue = 1;
    option.changeValue = 0.1;
    option.decimals = 1;
    option.onChange = onChangeHitsoundVolume;

    var option:Option = new Option('Hitsound', 'Funny notes does \"Any Sound\" when you hit them.', 'hitSounds', STRING, [
      'None',
      'quaver',
      'osu',
      'clap',
      'camellia',
      'stepmania',
      '21st century humor',
      'vine boom',
      'sexus'
    ]);
    addOption(option);

    var option:Option = new Option('Instant Respawning', "If checked, You have to respawn, Else instant respawn!", 'instantRespawn', BOOL);
    addOption(option);

    var option:Option = new Option('Camera Movement', "If checked, The notes impact the camera direction.", 'cameraMovement', BOOL);
    addOption(option);

    var option:Option = new Option('Miss Sounds', "If checked, Miss sounds are active.", 'missSounds', BOOL);
    addOption(option);

    super();
  }

  var daHitSound:FlxSound = new FlxSound();

  function onChangeHitsound()
  {
    if (ClientPrefs.data.hitSounds != "None" && ClientPrefs.data.hitsoundVolume != 0)
    {
      daHitSound.loadEmbedded(Paths.sound('hitsounds/${ClientPrefs.data.hitSounds}'));
      daHitSound.volume = ClientPrefs.data.hitsoundVolume;
      daHitSound.play();
    }
  }

  function onChangeHitsoundVolume()
  {
    if (ClientPrefs.data.hitSounds != "None")
    {
      daHitSound.loadEmbedded(Paths.sound('hitsounds/${ClientPrefs.data.hitSounds}'));
      daHitSound.volume = ClientPrefs.data.hitsoundVolume;
      daHitSound.play();
    }
  }
}
