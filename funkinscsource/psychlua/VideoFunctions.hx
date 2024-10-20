package psychlua;

import objects.VideoSprite;
import substates.GameOverSubstate;

#if (VIDEOS_ALLOWED && hxvlc)
class VideoFunctions
{
  // Code by DMMaster636
  public static function implement(funk:FunkinLua)
  {
    funk.set("makeVideoSprite", function(tag:String, video:String, ext:String = 'mp4', ?x:Float = 0, ?y:Float = 0, ?loop:Dynamic = false) {
      tag = tag.replace('.', '');
      LuaUtils.findToDestroy(tag);
      final leVideo:VideoSprite = new VideoSprite(Paths.video(video, ext), true, false, loop, false);
      leVideo.setPosition(x, y);
      MusicBeatState.getVariables("Video").set(tag, leVideo);
    });
    funk.set("setVideoSize", function(tag:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
      final split:Array<String> = tag.split('.');
      final poop:VideoSprite = split.length > 1 ? LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split),
        split[split.length - 1]) : LuaUtils.getObjectDirectly(split[0]);

      if (poop != null)
      {
        if (!poop.isPlaying)
        {
          poop.videoSprite.bitmap.onFormatSetup.add(function() {
            poop.videoSprite.setGraphicSize(x, y);
            if (updateHitbox) poop.videoSprite.updateHitbox();
          });
        }
        poop.setGraphicSize(x, y);
        if (updateHitbox) poop.updateHitbox();
        return;
      }
      FunkinLua.luaTrace('setVideoSize: Couldnt find video: ' + tag, false, false, FlxColor.RED);
    });
    // TODO: find a way to do this?
    /*funk.set("scaleVideo", function(tag:String, x:Float, y:Float, updateHitbox:Bool = true) {
      var obj:VideoSprite = MusicBeatState.variableMap(tag).get(tag);
      if (obj != null)
      {
        if (!obj.isPlaying) {
          obj.videoSprite.bitmap.onFormatSetup.add(function(){
            obj.videoSprite.scale.set(x, y);
            if (updateHitbox) obj.videoSprite.updateHitbox();
          });
        }
        obj.videoSprite.scale.set(x, y);
        if (updateHitbox) obj.videoSprite.updateHitbox();
        return;
      }

      var split:Array<String> = tag.split('.');
      var poop:VideoSprite = LuaUtils.getObjectDirectly(split[0]);
      if (split.length > 1) poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);

       if (poop != null)
      {
        if (!poop.isPlaying)
        {
          poop.videoSprite.bitmap.onFormatSetup.add(function() {
            poop.videoSprite.scale.set(x, y);
            if (updateHitbox) poop.videoSprite.updateHitbox();
          });
        }
        poop.scale.set(x, y);
        if (updateHitbox) poop.updateHitbox();
        return;
      }
      FunkinLua.luaTrace('scaleVideo: Couldnt find video: ' + obj, false, false, FlxColor.RED);
    });*/

    funk.set("addLuaVideo", function(tag:String, front:Bool = false) {
      var myVideo:VideoSprite = MusicBeatState.variableMap(tag).get(tag);
      if (myVideo == null) return false;

      var instance = LuaUtils.getTargetInstance();
      if (front) instance.add(myVideo);
      else
      {
        if (PlayState.instance == null || !PlayState.instance.isDead) instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterPlacement()),
          myVideo);
        else
          GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), myVideo);
      }
      return true;
    });
    funk.set("removeLuaVideo", function(tag:String, destroy:Bool = true, ?group:String = null) {
      var obj:VideoSprite = LuaUtils.getObjectDirectly(tag);
      if (obj == null || obj.destroy == null) return;

      var groupObj:Dynamic = null;
      if (group == null) groupObj = LuaUtils.getTargetInstance();
      else
        groupObj = LuaUtils.getObjectDirectly(group);

      groupObj.remove(obj, true);
      if (destroy)
      {
        var variables = MusicBeatState.variableMap(tag);
        if (variables != null) variables.remove(tag);
        obj.destroy();
      }
    });

    funk.set("playVideo", function(tag:String) {
      final split:Array<String> = tag.split('.');
      var poop:VideoSprite = LuaUtils.getObjectDirectly(split[0]);
      if (split.length > 1)
      {
        poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
      }

      if (poop != null)
      {
        if (!poop.isPlaying) poop.play();
        return;
      }
      FunkinLua.luaTrace('playVideo: Couldnt find video: ' + tag, false, false, FlxColor.RED);
    });
    funk.set("resumeVideo", function(tag:String) {
      final split:Array<String> = tag.split('.');
      var poop:VideoSprite = LuaUtils.getObjectDirectly(split[0]);
      if (split.length > 1)
      {
        poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
      }

      if (poop != null)
      {
        if (!poop.isPlaying && poop.isPaused) poop.resume();
        return;
      }
      FunkinLua.luaTrace('resumeVideo: Couldnt find video: ' + tag, false, false, FlxColor.RED);
    });
    funk.set("pauseVideo", function(tag:String) {
      final split:Array<String> = tag.split('.');
      var poop:VideoSprite = LuaUtils.getObjectDirectly(split[0]);
      if (split.length > 1)
      {
        poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
      }

      if (poop != null)
      {
        if (poop.isPlaying && !poop.isPaused) poop.pause();
        return;
      }
      FunkinLua.luaTrace('pauseVideo: Couldnt find video: ' + tag, false, false, FlxColor.RED);
    });

    funk.set("luaVideoExists", function(tag:String) {
      var obj:VideoSprite = MusicBeatState.variableMap(tag).get(tag);
      return (obj != null && Std.isOfType(obj, VideoSprite));
    });
  }
}
#end
