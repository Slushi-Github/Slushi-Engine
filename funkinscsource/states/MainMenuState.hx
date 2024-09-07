package states;

import backend.WeekData;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEvent;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;

enum MainMenuColumn
{
  LEFT;
  CENTER;
  RIGHT;
}

class MainMenuState extends MusicBeatState
{
  public static final psychEngineVersion:String = '1.0-prerelease'; // This is also used for Discord RPC
  public static var SCEVersion:String = '1.5.2'; // This is also used for Discord RPC
  public static var curSelected:Int = 0;
  public static var curColumn:MainMenuColumn = CENTER;

  var allowMouse:Bool = true; // Turn this off to block mouse movement in menus

  var menuItems:FlxTypedGroup<FlxSprite>;
  var leftItem:FlxSprite;
  var rightItem:FlxSprite;

  var gameJoltButton:FlxSprite;

  // Centered/Text Options
  final optionShit:Array<String> = ['story_mode', 'freeplay', #if MODS_ALLOWED 'mods', #end 'credits'];

  var leftOption:String = #if ACHIEVEMENTS_ALLOWED 'achievements' #else null #end;
  var rightOption:String = 'options';

  var magenta:FlxSprite;

  var bg:FlxSprite;
  var camFollow:FlxObject;

  public static var freakyPlaying:Bool = false;

  var grid:FlxBackdrop;

  var camFollowPos:FlxObject;

  override function create()
  {
    #if MODS_ALLOWED
    Mods.pushGlobalMods();
    #end
    Mods.loadTopMod();

    #if DISCORD_ALLOWED
    // Updating Discord Rich Presence
    DiscordClient.changePresence("Waiting for an menu option - Main Menu", null);
    #end

    Conductor.bpm = 128.0;

    persistentUpdate = persistentDraw = true;

    FlxG.mouse.visible = true;

    bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menuBG'));
    bg.antialiasing = ClientPrefs.data.antialiasing;
    bg.scrollFactor.set();
    bg.alpha = 0.5;
    // bg.setGraphicSize(FlxG.width * 2, FlxG.height * 2);
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    camFollow = new FlxObject(0, 0, 1, 1);
    camFollowPos = new FlxObject(0, 0, 1, 1);
    add(camFollow);
    add(camFollowPos);

    magenta = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
    magenta.antialiasing = ClientPrefs.data.antialiasing;
    magenta.scrollFactor.set();
    magenta.alpha = 0.5;
    // magenta.setGraphicSize(Std.int(bg.width * 4), Std.int(bg.height * 4));
    // magenta.setGraphicSize(FlxG.width * 2, FlxG.height * 2);
    magenta.updateHitbox();
    magenta.screenCenter();
    magenta.visible = false;
    magenta.color = 0xFFfd719b;
    add(magenta);

    // magenta.scrollFactor.set();

    grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
    grid.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
    grid.alpha = 0;
    FlxTween.tween(grid, {alpha: 0.56}, 0.5, {ease: FlxEase.quadOut});
    add(grid);

    menuItems = new FlxTypedGroup<FlxSprite>();
    add(menuItems);

    for (num => option in optionShit)
    {
      var item:FlxSprite = createMenuItem(option, 60 * num, (num * 140) + 90);
      item.y += (4 - optionShit.length) * 70; // Offsets for when you have anything other than 4 items
      item.screenCenter(X);
    }

    if (rightOption != null)
    {
      rightItem = createMenuItem(rightOption, FlxG.width - 60, 490, true);
      rightItem.x -= rightItem.width;
    }

    if (leftOption != null) leftItem = createMenuItem(leftOption, 60, 490, true);

    final sceVersion:FlxText = new FlxText(12, FlxG.height - 64, 0, "SCE v" + SCEVersion, 16);
    sceVersion.active = false;
    sceVersion.scrollFactor.set();
    sceVersion.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
    sceVersion.borderColor = FlxColor.BLACK;
    sceVersion.font = Paths.font('vcr.ttf');
    if (ClientPrefs.data.SCEWatermark) add(sceVersion);
    final psychVersion:FlxText = new FlxText(12, FlxG.height - 44, 0, 'Psych Engine v' + psychEngineVersion, 16);
    psychVersion.active = false;
    psychVersion.scrollFactor.set();
    psychVersion.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
    psychVersion.borderColor = FlxColor.BLACK;
    psychVersion.font = Paths.font('vcr.ttf');
    add(psychVersion);
    final fnfVersion:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 16);
    fnfVersion.active = false;
    fnfVersion.scrollFactor.set();
    fnfVersion.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
    fnfVersion.borderColor = FlxColor.BLACK;
    fnfVersion.font = Paths.font('vcr.ttf');
    add(fnfVersion);

    // NG.core.calls.event.logEvent('swag').send();

    changeItem(0);

    #if ACHIEVEMENTS_ALLOWED
    // Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
    final leDate = Date.now();
    if (leDate.getDay() == 5 && leDate.getHours() >= 18) Achievements.unlock('friday_night_play');
    #if MODS_ALLOWED
    Achievements.reloadList();
    #end
    #end

    super.create();

    FlxG.camera.follow(camFollowPos, null, 0.15);
  }

  function createMenuItem(name:String, x:Float, y:Float, looping:Bool = false):FlxSprite
  {
    var menuItem:FlxSprite = new FlxSprite(x, y);
    menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_$name');
    menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
    menuItem.animation.addByPrefix('selected', '$name selected', 24, !looping);
    menuItem.animation.play('idle');
    menuItem.updateHitbox();

    menuItem.antialiasing = ClientPrefs.data.antialiasing;
    menuItem.scrollFactor.set();
    menuItems.add(menuItem);
    return menuItem;
  }

  var selectedSomethin:Bool = false;

  var timeNotMoving:Float = 0;

  override function update(elapsed:Float)
  {
    if (FlxG.sound.music != null)
    {
      if (FlxG.sound.music.volume < 0.8)
      {
        FlxG.sound.music.volume += 0.5 * elapsed;
      }
      Conductor.songPosition = FlxG.sound.music.time;
    }

    var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
    camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

    for (i in [bg, magenta])
    {
      var mult:Float = FlxMath.lerp(1, i.scale.x, CoolUtil.clamp(1 - (elapsed * 9), 0, 1));
      i.scale.set(mult, mult);
      i.updateHitbox();
      i.offset.set();
    }

    if (!selectedSomethin)
    {
      if (FlxG.mouse.wheel != 0)
      {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        changeItem(-FlxG.mouse.wheel);
      }

      if (controls.UI_UP_P || controls.UI_DOWN_P)
      {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        changeItem(controls.UI_UP_P ? -1 : 1);
      }

      var allowMouse:Bool = allowMouse;
      if (allowMouse
        && ((FlxG.mouse.deltaViewX != 0 && FlxG.mouse.deltaViewY != 0)
          || FlxG.mouse.justPressed)) // FlxG.mouse.deltaViewX/Y checks is more accurate than FlxG.mouse.justMoved
      {
        allowMouse = false;
        FlxG.mouse.visible = true;
        timeNotMoving = 0;

        var selectedItem:FlxSprite;
        switch (curColumn)
        {
          case CENTER:
            selectedItem = menuItems.members[curSelected];
          case LEFT:
            selectedItem = leftItem;
          case RIGHT:
            selectedItem = rightItem;
        }

        if (leftItem != null && FlxG.mouse.overlaps(leftItem))
        {
          allowMouse = true;
          if (selectedItem != leftItem)
          {
            curColumn = LEFT;
            changeItem();
          }
        }
        else if (rightItem != null && FlxG.mouse.overlaps(rightItem))
        {
          allowMouse = true;
          if (selectedItem != rightItem)
          {
            curColumn = RIGHT;
            changeItem();
          }
        }
        else
        {
          var dist:Float = -1;
          var distItem:Int = -1;
          for (i in 0...optionShit.length)
          {
            var memb:FlxSprite = menuItems.members[i];
            if (FlxG.mouse.overlaps(memb))
            {
              var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.viewX, 2)
                + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.viewY, 2));
              if (dist < 0 || distance < dist)
              {
                dist = distance;
                distItem = i;
                allowMouse = true;
              }
            }
          }

          if (distItem != -1 && selectedItem != menuItems.members[distItem])
          {
            curColumn = CENTER;
            curSelected = distItem;
            changeItem();
          }
        }
      }
      else
      {
        timeNotMoving += elapsed;
        if (timeNotMoving > 2) FlxG.mouse.visible = false;
      }

      switch (curColumn)
      {
        case CENTER:
          if (controls.UI_LEFT_P && leftOption != null)
          {
            curColumn = LEFT;
            changeItem();
          }
          else if (controls.UI_RIGHT_P && rightOption != null)
          {
            curColumn = RIGHT;
            changeItem();
          }

        case LEFT:
          if (controls.UI_RIGHT_P)
          {
            curColumn = CENTER;
            changeItem();
          }

        case RIGHT:
          if (controls.UI_LEFT_P)
          {
            curColumn = CENTER;
            changeItem();
          }
      }

      if (controls.BACK)
      {
        selectedSomethin = true;
        FlxG.sound.play(Paths.sound('cancelMenu'));
        MusicBeatState.switchState(new TitleState());
      }

      /*if (FlxG.mouse.overlaps(gameJoltButton))
        {
          if (gameJoltButton.color != 0xB8F500) gameJoltButton.color = 0xB8F500;
          if (FlxG.mouse.justPressed)
          {
            LoadingState.loadAndSwitchState(new gamejolt.GameJoltGroup.GameJoltLogin());
          }
        }
        else
        {
          if (gameJoltButton.color != 0xFFFFFF) gameJoltButton.color = 0xFFFFFF;
      }*/

      if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse) #if android || FlxG.android.justPressed.BACK #end)
      {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        if (optionShit[curSelected] != 'donate')
        {
          FlxG.mouse.visible = false;
          selectedSomethin = true;

          if (ClientPrefs.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

          var item:FlxSprite;
          var option:String;
          switch (curColumn)
          {
            case CENTER:
              option = optionShit[curSelected];
              item = menuItems.members[curSelected];

            case LEFT:
              option = leftOption;
              item = leftItem;

            case RIGHT:
              option = rightOption;
              item = rightItem;
          }

          FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker) {
            switch (option)
            {
              case 'story_mode':
                MusicBeatState.switchState(new StoryMenuState());
              case 'freeplay':
                MusicBeatState.switchState(new states.freeplay.FreeplayState());
              #if MODS_ALLOWED
              case 'mods':
                MusicBeatState.switchState(new ModsMenuState());
              #end

              #if ACHIEVEMENTS_ALLOWED
              case 'achievements':
                MusicBeatState.switchState(new AchievementsMenuState());
              #end

              case 'credits':
                MusicBeatState.switchState(new CreditsState());
              case 'options':
                MusicBeatState.switchState(new OptionsState());
                OptionsState.onPlayState = false;
                if (PlayState.SONG != null)
                {
                  PlayState.SONG.options.arrowSkin = null;
                  PlayState.SONG.options.splashSkin = null;
                  PlayState.SONG.options.strumSkin = null;
                  PlayState.SONG.options.holdCoverSkin = null;
                  PlayState.stageUI = 'normal';
                }
            }
          });

          for (memb in menuItems)
          {
            if (memb == item) continue;
            FlxTween.tween(memb, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
          }
        }
        else
          CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
      }
      #if desktop
      else if (controls.justPressed('debug_1'))
      {
        selectedSomethin = true;
        FlxG.mouse.visible = false;
        MusicBeatState.switchState(new MasterEditorMenu());
      }
      #end
    }

    super.update(elapsed);
  }

  override function beatHit()
  {
    super.beatHit();

    bg.scale.set(1.06, 1.06);
    bg.updateHitbox();
    bg.offset.set();

    FlxTween.tween(bg, {alpha: 0.7}, Conductor.crochet / 1900,
      {
        onComplete: function(flxT:FlxTween) {
          FlxTween.tween(bg, {alpha: 0.4}, Conductor.crochet / 1900);
        }
      });
  }

  function changeItem(change:Int = 0)
  {
    if (change != 0) curColumn = CENTER;
    curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
    FlxG.sound.play(Paths.sound('scrollMenu'));

    for (item in menuItems)
    {
      item.animation.play('idle');
      item.centerOffsets();
    }

    var selectedItem:FlxSprite;
    switch (curColumn)
    {
      case CENTER:
        selectedItem = menuItems.members[curSelected];
      case LEFT:
        selectedItem = leftItem;
      case RIGHT:
        selectedItem = rightItem;
    }
    selectedItem.animation.play('selected');
    selectedItem.centerOffsets();
    camFollow.y = selectedItem.getGraphicMidpoint().y;
  }
}
