package options;

import objects.note.Note;
import objects.note.StrumArrow;
import objects.note.NoteSplash;
import objects.Alphabet;

class VisualsSettingsSubState extends BaseOptionsMenu
{
  var noteOptionID:Int = -1;
  var notes:FlxTypedGroup<StrumArrow>;
  var splashes:FlxTypedGroup<NoteSplash>;
  var noteY:Float = 90;
  var stringedNote:String = '';

  public function new()
  {
    title = 'Visuals and UI';
    rpcTitle = Language.getPhrase('visuals_menu', 'Visuals Settings'); // for Discord Rich Presence

    // for note skins and splash skin
    notes = new FlxTypedGroup<StrumArrow>();
    splashes = new FlxTypedGroup<NoteSplash>();
    for (i in 0...Note.colArray.length)
    {
      stringedNote = (OptionsState.onPlayState ? (PlayState.isPixelStage ? 'pixelUI/noteSkins/NOTE_assets' + Note.getNoteSkinPostfix() : 'noteSkins/NOTE_assets'
        + Note.getNoteSkinPostfix()) : 'noteSkins/NOTE_assets'
        + Note.getNoteSkinPostfix());
      var note:StrumArrow = new StrumArrow((ClientPrefs.data.middleScroll ? 370 + (560 / Note.colArray.length) * i : 620 + (560 / Note.colArray.length) * i),
        !ClientPrefs.data.downScroll ? -200 : 760, i, 0, stringedNote);
      note.centerOffsets();
      note.centerOrigin();
      note.reloadNote(stringedNote);
      note.loadNoteAnims(stringedNote, true);
      note.playAnim('static');
      note.loadLane();
      note.bgLane.updateHitbox();
      note.bgLane.scrollFactor.set();
      notes.add(note);

      var splash:NoteSplash = new NoteSplash();
      splash.noteData = i;
      splash.setPosition(note.x, noteY);
      splash.loadSplash();
      splash.visible = false;
      splash.alpha = ClientPrefs.data.splashAlpha;
      splash.animation.finishCallback = function(name:String) splash.visible = false;
      splashes.add(splash);

      Note.initializeGlobalRGBShader(i % Note.colArray.length);
      splash.rgbShader.copyValues(Note.globalRgbShaders[i % Note.colArray.length]);
    }

    // options

    var noteSkins:Array<String> = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
    if (noteSkins.length > 0)
    {
      if (!noteSkins.contains(ClientPrefs.data.noteSkin))
        ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin; // Reset to default if saved noteskin couldnt be found

      noteSkins.insert(0, ClientPrefs.defaultData.noteSkin); // Default skin always comes first
      var option:Option = new Option('Note Skins:', "Select your prefered Note skin.", 'noteSkin', STRING, noteSkins);
      addOption(option);
      option.onChange = onChangeNoteSkin;
      noteOptionID = optionsArray.length - 1;
    }

    var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
    if (noteSplashes.length > 0)
    {
      if (!noteSplashes.contains(ClientPrefs.data.splashSkin))
        ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; // Reset to default if saved splashskin couldnt be found

      noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); // Default skin always comes first
      var option:Option = new Option('Note Splashes:', "Select your prefered Note Splash variation or turn it off.", 'splashSkin', STRING, noteSplashes);
      addOption(option);
      option.onChange = onChangeSplashSkin;
    }

    var option:Option = new Option('Note Splash Opacity', 'How much transparent should the Note Splashes be.', 'splashAlpha', PERCENT);
    option.scrollSpeed = 1.6;
    option.minValue = 0.0;
    option.maxValue = 1;
    option.changeValue = 0.1;
    option.decimals = 1;
    addOption(option);
    option.onChange = playNoteSplashes;

    var option:Option = new Option('Note Lanes Opacity', 'How much transparent should the lanes under the notes be?', 'laneTransparency', PERCENT);
    option.scrollSpeed = 1.6;
    option.minValue = 0.0;
    option.maxValue = 1;
    option.changeValue = 0.1;
    option.decimals = 1;
    addOption(option);

    var option:Option = new Option('Note Splash Opacity As Strum Opacity', 'Should splashes be transparent as strums?', 'splashAlphaAsStrumAlpha', BOOL);
    addOption(option);

    var option:Option = new Option('Hide HUD', 'If checked, hides most HUD elements.', 'hideHud', BOOL);
    addOption(option);

    var option:Option = new Option('HUD style:', "What HUD you like more??.", 'hudStyle', STRING, ['PSYCH', 'GLOW_KADE', 'HITMANS', 'CLASSIC']);
    addOption(option);

    var option:Option = new Option('Time Bar:', "What should the Time Bar display?", 'timeBarType', STRING,
      ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
    addOption(option);

    var option:Option = new Option('Time Bar Color:', "What colors should the Time Bar display?", 'colorBarType', STRING,
      ['No Colors', 'Main Colors', 'Reversed Colors']);
    addOption(option);

    var option:Option = new Option('Flashing Lights', "Uncheck this if you're sensitive to flashing lights!", 'flashing', BOOL);
    addOption(option);

    var option:Option = new Option('Camera Zooms', "If unchecked, the camera won't zoom in on a beat hit.", 'camZooms', BOOL);
    addOption(option);

    var option:Option = new Option('Score Text Grow on Hit', "If unchecked, disables the Score text growing\neverytime you hit a note.", 'scoreZoom', BOOL);
    addOption(option);

    var option:Option = new Option('Health Colors', "If unchecked, No health colors, Back to normal funkin colors", 'healthColor', BOOL);
    addOption(option);

    var option:Option = new Option('Health Bar Opacity', 'How much transparent should the health bar and icons be.', 'healthBarAlpha', PERCENT);
    option.scrollSpeed = 1.6;
    option.minValue = 0.0;
    option.maxValue = 1;
    option.changeValue = 0.1;
    option.decimals = 1;
    addOption(option);

    var option:Option = new Option('Pause Music:', "What song do you prefer for the Pause Screen?", 'pauseMusic', STRING,
      ['None', 'Tea Time', 'Breakfast', 'Breakfast (Pico)']);
    addOption(option);
    option.onChange = onChangePauseMusic;

    var option:Option = new Option('Check for Updates', 'On Release builds, turn this on to check for updates when you start the game.', 'checkForUpdates',
      BOOL);
    addOption(option);

    #if DISCORD_ALLOWED
    var option:Option = new Option('Discord Rich Presence',
      "Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord", 'discordRPC', BOOL);
    addOption(option);
    option.onChange = onChangediscord;
    #end

    var option:Option = new Option('Combo Stacking', "If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
      'comboStacking', BOOL);
    addOption(option);

    var option:Option = new Option('Judgement Counter', "If checked, A Judgement Counter is shown", 'judgementCounter', BOOL);
    addOption(option);

    var option:Option = new Option('Game Combo', "If checked, Combo UI will be automated to camGame (stage, pl, op, gf)", 'gameCombo', BOOL);
    addOption(option);

    var option:Option = new Option('Show Combo', "If checked, Combo Sprite will appear when note is hit.", 'showCombo', BOOL);
    addOption(option);

    var option:Option = new Option('Show Combo Num', "If checked, Combo Number Sprite will appear when note is hit.", 'showComboNum', BOOL);
    addOption(option);

    var option:Option = new Option('Show Rating', "If checked, Rating Sprite will appear when note is hit.", 'showRating', BOOL);
    addOption(option);

    var option:Option = new Option('Voiid Chronicles BreakTimer', "If checked, A timer will appear to tell you when next notes are.", 'breakTimer', BOOL);
    addOption(option);

    var option:Option = new Option('Lights Opponent Strums Notes', 'If unchecked, opponent Strums wont light up.', 'LightUpStrumsOP', BOOL);
    addOption(option);

    var option:Option = new Option('Icon Movement', "Do you want Icon to have some movement?", 'iconMovement', STRING, ['None', 'Angled']);
    addOption(option);

    var option:Option = new Option('Gradient System For Old Bars.', 'A gradient system will be used if the old bar system is activated in PlayState.',
      'gradientSystemForOldBars', BOOL);
    addOption(option);

    var option:Option = new Option('Colored Changing Text.',
      'Mainly all text in playstate will change color on character change and will start with dad\'s character color.', 'coloredText', BOOL);
    addOption(option);

    var option:Option = new Option('Note Splashes Option', "Different options on how the splashes show.", 'splashOption', STRING,
      ['None', 'Player', 'Opponent', 'Both']);
    addOption(option);

    var option:Option = new Option('Hold Cover Animation And Splash', "If checked, A Splash and Hold Note animation wil show.", 'holdCoverPlay', BOOL);
    addOption(option);

    var option:Option = new Option('Vanilla Strum Animations', "If checked, Strums animations play like vanilla FNF.", 'vanillaStrumAnimations', BOOL);
    addOption(option);

    var option:Option = new Option('Color Notes A Way', 'What kinda of RGB note coloring !(only if RGB shader is active)!', 'colorNoteType', STRING,
      ['None', 'Quant', 'Rainbow']);
    addOption(option);

    super();
    add(notes);
    add(splashes);
  }

  function onChangediscord()
  {
    if (ClientPrefs.data.discordRPC) DiscordClient.initialize();
    else
      DiscordClient.shutdown();
  }

  var notesShown:Bool = false;

  override function changeSelection(change:Int = 0)
  {
    super.changeSelection(change);

    switch (curOption.variable)
    {
      case 'noteSkin', 'splashSkin', 'splashAlpha':
        if (!notesShown)
        {
          for (note in notes.members)
          {
            FlxTween.cancelTweensOf(note);
            FlxTween.tween(note, {y: noteY}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
          }
        }
        notesShown = true;
        if (curOption.variable.startsWith('splash') && Math.abs(notes.members[0].y - noteY) < 25) playNoteSplashes();
      default:
        if (notesShown)
        {
          for (note in notes.members)
          {
            FlxTween.cancelTweensOf(note);
            FlxTween.tween(note, {y: -200}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
          }
        }
        notesShown = false;
    }
  }

  var changedMusic:Bool = false;

  function onChangePauseMusic()
  {
    if (ClientPrefs.data.pauseMusic == 'None') FlxG.sound.music.volume = 0;
    else
      FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

    changedMusic = true;
  }

  function onChangeNoteSkin()
  {
    notes.forEachAlive(function(note:StrumArrow) {
      changeNoteSkin(note);
      note.centerOffsets();
      note.centerOrigin();
    });
  }

  function changeNoteSkin(note:StrumArrow)
  {
    var skin:String = Note.defaultNoteSkin;
    var customSkin:String = skin + Note.getNoteSkinPostfix();
    if (Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

    note.reloadNote(skin);
    note.playAnim('static');
  }

  function onChangeSplashSkin()
  {
    for (splash in splashes)
      splash.loadSplash();
    playNoteSplashes();
  }

  function playNoteSplashes()
  {
    for (splash in splashes)
    {
      var anim:String = splash.playDefaultAnim();
      splash.visible = true;
      splash.alpha = ClientPrefs.data.splashAlpha;

      var conf = splash.config.animations.get(anim);
      var offsets:Array<Float> = [0, 0];
      if (conf != null) offsets = conf.offsets;
      if (offsets != null)
      {
        splash.centerOffsets();
        splash.offset.set(offsets[0], offsets[1]);
      }
    }
  }

  override function destroy()
  {
    if (changedMusic && !OptionsState.onPlayState) FlxG.sound.playMusic(Paths.music(ClientPrefs.data.SCEWatermark ? "SCE_freakyMenu" : "freakyMenu"), 1, true);
    super.destroy();
  }
}
