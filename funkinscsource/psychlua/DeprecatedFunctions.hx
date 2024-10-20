package psychlua;

import objects.Character;

//
// This is simply where i store deprecated functions for it to be more organized.
// I would suggest not messing with these, as it could break mods.
//
class DeprecatedFunctions
{
  public static function implement(funk:FunkinLua)
  {
    // DEPRECATED, DONT MESS WITH THESE SHITS, ITS JUST THERE FOR BACKWARD COMPATIBILITY
    funk.set("addAnimationByIndicesLoop", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
      FunkinLua.luaTrace("addAnimationByIndicesLoop is deprecated! Use addAnimationByIndices instead", false, true);
      return LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, true);
    });

    funk.set("objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0) {
      FunkinLua.luaTrace("objectPlayAnimation is deprecated! Use playAnim instead", false, true);
      var spr:FlxSprite = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);

      if (MusicBeatState.variableMap(obj).exists(obj))
      {
        spr = MusicBeatState.variableMap(obj).get(obj);
        spr.animation.play(name, forced, false, startFrame);
        return true;
      }

      if (spr != null)
      {
        spr.animation.play(name, forced, false, startFrame);
        return true;
      }
      return false;
    });
    funk.set("characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false) {
      FunkinLua.luaTrace("characterPlayAnim is deprecated! Use playAnim instead", false, true);
      if (!ClientPrefs.data.characters) return;
      switch (character.toLowerCase())
      {
        case 'dad':
          if (PlayState.instance.dad.hasOffsetAnimation(anim)) PlayState.instance.dad.playAnim(anim, forced);
        case 'gf' | 'girlfriend':
          if (PlayState.instance.gf != null
            && PlayState.instance.gf.hasOffsetAnimation(anim)) PlayState.instance.gf.playAnim(anim, forced);
        case 'mom':
          if (PlayState.instance.mom != null
            && PlayState.instance.mom.hasOffsetAnimation(anim)) PlayState.instance.mom.playAnim(anim, forced);
        case 'boyfriend' | 'bf':
          if (PlayState.instance.boyfriend.hasOffsetAnimation(anim)) PlayState.instance.boyfriend.playAnim(anim, forced);
        default:
          if (MusicBeatState.variableMap(character).exists(character))
          {
            final spr:Character = MusicBeatState.variableMap(character).get(character);
            if (spr.hasOffsetAnimation(anim)) spr.playAnim(anim, forced);
          }
      }
    });
    funk.set("luaSpriteMakeGraphic", function(tag:String, width:Int, height:Int, color:String) {
      FunkinLua.luaTrace("luaSpriteMakeGraphic is deprecated! Use makeGraphic instead", false, true);
      if (MusicBeatState.findVariableObj(tag)) MusicBeatState.variableMap(tag).get(tag).makeGraphic(width, height, CoolUtil.colorFromString(color));
    });
    funk.set("luaSpriteAddAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
      FunkinLua.luaTrace("luaSpriteAddAnimationByPrefix is deprecated! Use addAnimationByPrefix instead", false, true);
      if (MusicBeatState.findVariableObj(tag))
      {
        var cock:ModchartSprite = MusicBeatState.variableMap(tag).get(tag);
        cock.animation.addByPrefix(name, prefix, framerate, loop);
        if (cock.animation.curAnim == null)
        {
          cock.animation.play(name, true);
        }
      }
    });
    funk.set("luaSpriteAddAnimationByIndices", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
      FunkinLua.luaTrace("luaSpriteAddAnimationByIndices is deprecated! Use addAnimationByIndices instead", false, true);
      if (MusicBeatState.findVariableObj(tag))
      {
        var strIndices:Array<String> = indices.trim().split(',');
        var die:Array<Int> = [];
        for (i in 0...strIndices.length)
        {
          die.push(Std.parseInt(strIndices[i]));
        }
        var pussy:ModchartSprite = MusicBeatState.variableMap(tag).get(tag);
        pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
        if (pussy.animation.curAnim == null)
        {
          pussy.animation.play(name, true);
        }
      }
    });
    funk.set("luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false) {
      FunkinLua.luaTrace("luaSpritePlayAnimation is deprecated! Use playAnim instead", false, true);
      if (MusicBeatState.findVariableObj(tag)) MusicBeatState.variableMap(tag).get(tag).animation.play(name, forced);
    });
    funk.set("setLuaSpriteCamera", function(tag:String, camera:String = '') {
      FunkinLua.luaTrace("setLuaSpriteCamera is deprecated! Use setObjectCamera instead", false, true);
      if (MusicBeatState.findVariableObj(tag))
      {
        MusicBeatState.variableMap(tag).get(tag).cameras = [LuaUtils.cameraFromString(camera)];
        return true;
      }
      FunkinLua.luaTrace("Lua sprite with tag: " + tag + " doesn't exist!");
      return false;
    });
    funk.set("setLuaSpriteScrollFactor", function(tag:String, scrollX:Float, scrollY:Float) {
      FunkinLua.luaTrace("setLuaSpriteScrollFactor is deprecated! Use setScrollFactor instead", false, true);
      if (MusicBeatState.findVariableObj(tag))
      {
        MusicBeatState.variableMap(tag).get(tag).scrollFactor.set(scrollX, scrollY);
        return true;
      }
      return false;
    });
    funk.set("scaleLuaSprite", function(tag:String, x:Float, y:Float) {
      FunkinLua.luaTrace("scaleLuaSprite is deprecated! Use scaleObject instead", false, true);
      if (MusicBeatState.findVariableObj(tag))
      {
        final shit:ModchartSprite = MusicBeatState.variableMap(tag).get(tag);
        shit.scale.set(x, y);
        shit.updateHitbox();
        return true;
      }
      return false;
    });
    funk.set("getPropertyLuaSprite", function(tag:String, variable:String) {
      FunkinLua.luaTrace("getPropertyLuaSprite is deprecated! Use getProperty instead", false, true);
      if (MusicBeatState.findVariableObj(tag))
      {
        var split:Array<String> = variable.split('.');
        if (split.length > 1)
        {
          var coverMeInPiss:Dynamic = Reflect.getProperty(MusicBeatState.variableMap(tag).get(tag), split[0]);
          for (i in 1...split.length - 1)
          {
            coverMeInPiss = Reflect.getProperty(coverMeInPiss, split[i]);
          }
          return Reflect.getProperty(coverMeInPiss, split[split.length - 1]);
        }
        return Reflect.getProperty(MusicBeatState.variableMap(tag).get(tag), variable);
      }
      return null;
    });
    funk.set("setPropertyLuaSprite", function(tag:String, variable:String, value:Dynamic) {
      FunkinLua.luaTrace("setPropertyLuaSprite is deprecated! Use setProperty instead", false, true);
      if (MusicBeatState.findVariableObj(tag))
      {
        var split:Array<String> = variable.split('.');
        if (split.length > 1)
        {
          var coverMeInPiss:Dynamic = Reflect.getProperty(MusicBeatState.variableMap(tag).get(tag), split[0]);
          for (i in 1...split.length - 1)
          {
            coverMeInPiss = Reflect.getProperty(coverMeInPiss, split[i]);
          }
          Reflect.setProperty(coverMeInPiss, split[split.length - 1], value);
          return true;
        }
        Reflect.setProperty(MusicBeatState.variableMap(tag).get(tag), variable, value);
        return true;
      }
      FunkinLua.luaTrace("setPropertyLuaSprite: Lua sprite with tag: " + tag + " doesn't exist!");
      return false;
    });
    funk.set("musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
      FlxG.sound.music.fadeIn(duration, fromValue, toValue);
      FunkinLua.luaTrace('musicFadeIn is deprecated! Use soundFadeIn instead.', false, true);
    });
    funk.set("musicFadeOut", function(duration:Float, toValue:Float = 0) {
      FlxG.sound.music.fadeOut(duration, toValue);
      FunkinLua.luaTrace('musicFadeOut is deprecated! Use soundFadeOut instead.', false, true);
    });
    funk.set("updateHitboxFromGroup", function(group:String, index:Int) {
      if (Std.isOfType(Reflect.getProperty(LuaUtils.getTargetInstance(), group), FlxTypedGroup))
      {
        Reflect.getProperty(LuaUtils.getTargetInstance(), group).members[index].updateHitbox();
        return;
      }
      Reflect.getProperty(LuaUtils.getTargetInstance(), group)[index].updateHitbox();
      FunkinLua.luaTrace('updateHitboxFromGroup is deprecated! Use updateHitbox instead.', false, true);
    });
  }
}
