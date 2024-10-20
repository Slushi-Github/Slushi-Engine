package;

import flixel.input.keyboard.FlxKey;
import flixel.system.scaleModes.*;
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.system.FlxAssets.FlxShader;
import openfl.Assets;
import openfl.Lib;
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
#end
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.filters.ShaderFilter;
import openfl.display.StageQuality;
import lime.app.Application;
// crash handler stuff
#if CRASH_HANDLER
import haxe.CallStack;
import haxe.io.Path;
#end
// Other Things
import debug.FPSCounter;
import gamejolt.GameJoltGroup.GJToastManager;
import gamejolt.*;
import states.TitleState;

import slushi.MainGame;

class Main extends Sprite
{
  public static var focused:Bool = true;
  public static var fpsVar:FPSCounter;

  public static var appName:String = ''; // Application name.

  public static var gameContainer:Main = null; // Main instance to access when needed.

  public static var gjToastManager:GJToastManager;

  public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
  public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
  public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

  public function new()
  {
    super();

    // #if CRASH_HANDLER
    // utils.logging.CrashHandler.initialize();
    // utils.logging.CrashHandler.queryStatus();
    // #end

    // WindowsFuncs.initThreadForWindowRespondingHandler();

    setupGame();
  }

  var oldVol:Float = 1.0;
  var newVol:Float = 0.2;

  public static var focusMusicTween:FlxTween;

  private function setupGame():Void
  {
    var game:MainGame = new MainGame(1280, 720, Init, 60, 60, true, false);
    @:privateAccess
    game._customSoundTray = backend.soundtray.FunkinSoundTray;
    addChild(game);
    addChild(gjToastManager = new GJToastManager());

    gameContainer = this;

    #if HSCRIPT_ALLOWED
    codenameengine.scripting.GlobalScript.init();
    #end
    Paths.init();

    FlxGraphic.defaultPersist = false;
    FlxG.signals.preStateSwitch.add(function() {
      if (Type.getClass(FlxG.state) != TitleState) // Resetting title state makes this unstable so we make it only for other states!
      {
        // i tihnk i finally fixed it
        @:privateAccess
        for (key in FlxG.bitmap._cache.keys())
        {
          var obj = FlxG.bitmap._cache.get(key);
          if (obj != null)
          {
            lime.utils.Assets.cache.image.remove(key);
            openfl.Assets.cache.removeBitmapData(key);
            FlxG.bitmap._cache.remove(key);
          }
        }

        // idk if this helps because it looks like just clearing it does the same thing
        for (k => f in lime.utils.Assets.cache.font)
          lime.utils.Assets.cache.font.remove(k);
        for (k => s in lime.utils.Assets.cache.audio)
          lime.utils.Assets.cache.audio.remove(k);
      }

      lime.utils.Assets.cache.clear();

      openfl.Assets.cache.clear();

      FlxG.bitmap.dumpCache();

      #if cpp
      cpp.vm.Gc.enable(true);
      #end

      #if sys
      openfl.system.System.gc();
      #end
    });

    FlxG.signals.postStateSwitch.add(function() {
      #if cpp
      cpp.vm.Gc.enable(true);
      #end

      #if sys
      openfl.system.System.gc();
      #end
    });

    #if desktop
    // Get first window in case the coder creates more windows.
    @:privateAccess
    appName = openfl.Lib.application.windows[0].__backend.parent.__attributes.title;
    Application.current.window.onFocusIn.add(onWindowFocusIn);
    Application.current.window.onFocusOut.add(onWindowFocusOut);
    #end

    // shader coords fix
    FlxG.signals.gameResized.add(function(w, h) {
      resetSpriteCache(Main.gameContainer);

      if (FlxG.game != null) resetSpriteCache(FlxG.game);

      if (FlxG.cameras != null)
      {
        for (cam in FlxG.cameras.list)
        {
          if (cam != null && cam.filters != null)
          {
            resetSpriteCache(cam.flashSprite);
          }
        }
      }
    });
    #if VIDEOS_ALLOWED
    hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
    #end
  }

  static function resetSpriteCache(sprite:Sprite):Void
  {
    if (sprite == null) return;
    @:privateAccess {
      sprite.__cacheBitmap = null;
      sprite.__cacheBitmapData = null;
      sprite.__cacheBitmapData2 = null;
      sprite.__cacheBitmapData3 = null;
      sprite.__cacheBitmapColorTransform = null;
    }
  }

  public static function checkGJKeysAndId():Bool
  {
    var result:Bool = (GJKeys.key != '' && GJKeys.id != 0);
    return result;
  }

  function onWindowFocusOut()
  {
    focused = false;

    oldVol = FlxG.sound.volume;
    if (oldVol > 0.3)
    {
      newVol = 0.3;
    }
    else
    {
      if (oldVol > 0.1)
      {
        newVol = 0.1;
      }
      else
      {
        newVol = 0;
      }
    }

    if (focusMusicTween != null) focusMusicTween.cancel();
    focusMusicTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.5);
  }

  function onWindowFocusIn()
  {
    new FlxTimer().start(0.2, function(tmr:FlxTimer) {
      focused = true;
    });

    // Normal global volume when focused
    if (focusMusicTween != null) focusMusicTween.cancel();

    focusMusicTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.5);
  }
}
