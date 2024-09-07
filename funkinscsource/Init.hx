package;

import flixel.graphics.FlxGraphic;
import flixel.FlxState;
import states.TitleState;
import states.FlashingState;
import debug.FPSCounter;
import openfl.Lib;
import backend.Highscore;
// import backend.Debug;
import lime.app.Application;

import slushi.states.SlushiTitleState;

class Init extends FlxState
{
  public static var mouseCursor:FlxSprite;

  override function create()
  {
    FlxTransitionableState.skipNextTransOut = true;
    Paths.clearStoredMemory();

    // Run this first so we can see logs.
    Debug.onInitProgram();

    Application.current.window.setIcon(lime.utils.Assets.getImage('assets/art/iconOG.png'));

    #if !mobile
    if (Main.fpsVar == null) Lib.current.stage.addChild(Main.fpsVar = new FPSCounter(10, 3, 0xFFFFFF));
    #end

    #if !MODS_ALLOWED
    final path:String = 'mods';
    if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path))
    {
      var entries = sys.FileSystem.readDirectory(path);
      for (entry in entries)
        sys.FileSystem.deleteFile(path + '/' + entry);
      FileSystem.deleteDirectory(path);
    }
    #end

    #if linux
    Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("icon.png"));
    #end

    FlxG.autoPause = false;

    // Setup window events (like callbacks for onWindowClose)
    // and fullscreen keybind setup - Not Used
    utils.WindowUtil.initWindowEvents();
    // Disable the thing on Windows where it tries to send a bug report to Microsoft because why do they care?
    utils.WindowUtil.disableCrashHandler();

    FlxGraphic.defaultPersist = true;

    #if LUA_ALLOWED
    Mods.pushGlobalMods();
    #end
    Mods.loadTopMod();

    FlxG.save.bind('funkin', CoolUtil.getSavePath());

    ClientPrefs.loadPrefs();
    ClientPrefs.keybindSaveLoad();
    Language.reloadPhrases();

    FlxG.fixedTimestep = false;
    FlxG.game.focusLostFramerate = 60;
    FlxG.keys.preventDefaultKeys = [TAB];

    FlxG.updateFramerate = FlxG.drawFramerate = ClientPrefs.data.framerate;

    FlxG.mouse.enabled = true;
    FlxG.mouse.visible = true;

    #if !mobile
    if (Main.fpsVar != null)
    {
      Main.fpsVar.visible = ClientPrefs.data.showFPS;
    }
    #end

    #if LUA_ALLOWED llua.Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.LuaCallbackHandler.call)); #end
    Controls.instance = new Controls();
    ClientPrefs.loadDefaultKeys();
    #if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
    Highscore.load();

    if (FlxG.save.data.weekCompleted != null) states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

    #if DISCORD_ALLOWED
    DiscordClient.prepare();
    #end

    #if cpp
    cpp.NativeGc.enable(true);
    cpp.NativeGc.run(true);
    #end

    // Finish up loading debug tools.
    Debug.onGameStart();

     // Load Slushi Engine initial functions
		SlushiMain.loadSlushiEngineFunctions();

    if (Main.checkGJKeysAndId())
    {
      GameJoltAPI.connect();
      GameJoltAPI.authDaUser(ClientPrefs.data.gjUser, ClientPrefs.data.gjToken, true);
    }

    if (ClientPrefs.data.gjUser.toLowerCase() == 'glowsoony') FlxG.scaleMode = new flixel.system.scaleModes.FillScaleMode();

    if (FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;

    FlxG.switchState(new SlushiTitleState());
  }
}
