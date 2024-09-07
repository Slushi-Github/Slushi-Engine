package slushi.slushiUtils.shaders;

import psychlua.LuaUtils;

class SlushiShaders
{
	public static function addAllShadersToNotes()
	{
		Shader3DForNotes.addShader3DToCamStrumsAndCamNotes();
		WhiteShaderForNotes.addWhiteShaderToNotes();
        Debug.logSLEInfo('Added ALL shaders to Notes');
	}

	public static function removeAllShadersToNotes()
	{
		Shader3DForNotes.remove3DShaderFromCamNotesAndCamStrums();
		WhiteShaderForNotes.removeWhiteShaderFromNotes();
        Debug.logSLEInfo('Removed ALL shaders to Notes');
	}
}

class Shader3DForNotes
{
	public static function addShader3DToCamStrumsAndCamNotes()
	{
		if (!ClientPrefs.data.shaders)
			return;

			var name:String = "Shader3DforNotes";

			var shaderClass = shaders.FunkinSourcedShaders.ThreeDEffect;

			var shad = Type.createInstance(shaderClass, []);
			psychlua.FunkinLua.lua_Shaders.set(name, shad);

			Debug.logSLEInfo('Created shader 3D');

			var cam = psychlua.LuaUtils.getCameraByName("notestuff");
			var shad = psychlua.FunkinLua.lua_Shaders.get(name);

			Debug.logSLEInfo('Trying to add shader 3D to notes cam...');

			if (cam != null){
				cam.shaders.push(new ShaderFilter(Reflect.getProperty(shad, 'shader')));
				cam.shaderNames.push(name);
				cam.cam.setFilters(cam.shaders);
				Debug.logSLEInfo('Shader 3D added to CamNotes!');
			}
			else{
				Debug.logSLEError('cam or cam2 not found... cameras: cam1: ' + cam);
			}
	}

	public static function remove3DShaderFromCamNotesAndCamStrums()
	{
		if (!ClientPrefs.data.shaders)
			return;
		var shaderName:String = "Shader3DforNotes";
		var cam = psychlua.LuaUtils.getCameraByName("notestuff");
		if (cam != null)
		{
			if (cam.shaderNames.contains(shaderName))
			{
				var idx:Int = cam.shaderNames.indexOf(shaderName);
				if (idx != -1)
				{
					cam.shaderNames.remove(cam.shaderNames[idx]);
					cam.shaders.remove(cam.shaders[idx]);
					cam.cam.setFilters(cam.shaders); // refresh filters
				}
			}
		}
	}

	public static function setNotesShader3DProperty(prop:String, value:Dynamic)
	{
		if (!ClientPrefs.data.shaders)
			return;

		var shaderName:String = "Shader3DforNotes";
		var shad = psychlua.FunkinLua.lua_Shaders.get(shaderName);

		if (shad != null && prop != null)
		{
			Reflect.setProperty(shad, prop, value);
		}
	};

	public static function doTweenNotesShader3DInX(tag:String, value:Float, time:Float, easeStr:String = "linear")
	{
		if (!ClientPrefs.data.shaders)
			return;
		var shaderName:String = "Shader3DforNotes";
		var shad = psychlua.FunkinLua.lua_Shaders.get(shaderName);
		var ease = psychlua.LuaUtils.getTweenEaseByString(easeStr);

		var prop:String = "xrot";

		var startVal = Reflect.getProperty(shad, prop);

		if (shad != null)
		{

			var variables = MusicBeatState.getVariables();
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('tween_$tag');

			variables.set(tag, PlayState.tweenManager.num(startVal, value, time, {
				onUpdate: function(tween:FlxTween)
				{
					var ting = FlxMath.lerp(startVal, value, ease(tween.percent));
					Reflect.setProperty(shad, prop, ting);
				},
				ease: ease,
				onComplete: function(tween:FlxTween)
				{
					Reflect.setProperty(shad, prop, value);
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					variables.remove(tag);
					// Debug.logInfo('Shader tween completed: '+ tag);
				}
			}));
		}
		else
		{
			Debug.logWarn('Shader not added');
		}
	}

	public static function doTweenNotesShader3DInY(tag:String, value:Float, time:Float, easeStr:String = "linear")
	{
		if (!ClientPrefs.data.shaders)
			return;
		var shaderName:String = "Shader3DforNotes";
		var shad = psychlua.FunkinLua.lua_Shaders.get(shaderName);
		var ease = psychlua.LuaUtils.getTweenEaseByString(easeStr);

		var prop:String = "yrot";

		var startVal = Reflect.getProperty(shad, prop);

		if (shad != null)
		{
			var variables = MusicBeatState.getVariables();
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('tween_$tag');

			variables.set(tag, PlayState.tweenManager.num(startVal, value, time, {
				onUpdate: function(tween:FlxTween)
				{
					var ting = FlxMath.lerp(startVal, value, ease(tween.percent));
					Reflect.setProperty(shad, prop, ting);
				},
				ease: ease,
				onComplete: function(tween:FlxTween)
				{
					Reflect.setProperty(shad, prop, value);
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					variables.remove(tag);
					// Debug.logInfo('Shader tween completed: '+ tag);
				}
			}));
		}
		else
		{
			Debug.logSLEWarn('Shader not added');
		}
	}

	public static function doTweenNotesShader3DInZ(tag:String, value:Float, time:Float, easeStr:String = "linear")
	{
		if (!ClientPrefs.data.shaders)
			return;
		var shaderName:String = "Shader3DforNotes";
		var shad = psychlua.FunkinLua.lua_Shaders.get(shaderName);
		var ease = psychlua.LuaUtils.getTweenEaseByString(easeStr);

		var prop:String = "zrot";

		var startVal = Reflect.getProperty(shad, prop);

		if (shad != null)
		{
			var variables = MusicBeatState.getVariables();
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('tween_$tag');

			variables.set(tag, PlayState.tweenManager.num(startVal, value, time, {
				onUpdate: function(tween:FlxTween)
				{
					var ting = FlxMath.lerp(startVal, value, ease(tween.percent));
					Reflect.setProperty(shad, prop, ting);
				},
				ease: ease,
				onComplete: function(tween:FlxTween)
				{
					Reflect.setProperty(shad, prop, value);
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					variables.remove(tag);
					// Debug.logInfo('Shader tween completed: '+ tag);
				}
			}));
		}
		else
		{
			Debug.logSLEWarn('Shader not added');
		}
	}

	public static function doTweenNotesShader3DInDepth(tag:String, value:Float, time:Float, easeStr:String = "linear")
	{
		if (!ClientPrefs.data.shaders)
			return;
		var shaderName:String = "Shader3DforNotes";
		var shad = psychlua.FunkinLua.lua_Shaders.get(shaderName);
		var ease = psychlua.LuaUtils.getTweenEaseByString(easeStr);

		var prop:String = "depth";

		var startVal = Reflect.getProperty(shad, prop);

		if (shad != null)
		{
			var variables = MusicBeatState.getVariables();
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('tween_$tag');

			variables.set(tag, PlayState.tweenManager.num(startVal, value, time, {
				onUpdate: function(tween:FlxTween)
				{
					var ting = FlxMath.lerp(startVal, value, ease(tween.percent));
					Reflect.setProperty(shad, prop, ting);
				},
				ease: ease,
				onComplete: function(tween:FlxTween)
				{
					Reflect.setProperty(shad, prop, value);
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					variables.remove(tag);
					// Debug.logInfo('Shader tween completed: '+ tag);
				}
			}));
		}
		else
		{
			Debug.logSLEWarn('Shader not added');
		}
	}
}

class WhiteShaderForNotes
{
	public static function addWhiteShaderToNotes()
	{
		if (!ClientPrefs.data.shaders)
			return;

			var name:String = "whiteShaderforNotes";

			var shaderClass = shaders.FunkinSourcedShaders.ColorWhiteFrameEffect;

			var shad = Type.createInstance(shaderClass, []);
			psychlua.FunkinLua.lua_Shaders.set(name, shad);

			Debug.logSLEInfo('Created White shader');

			var cam = psychlua.LuaUtils.getCameraByName("notestuff");
			var shad = psychlua.FunkinLua.lua_Shaders.get(name);

			Debug.logSLEInfo('Trying to add white shader to notes cam...');

			if (cam != null)
			{
				cam.shaders.push(new ShaderFilter(Reflect.getProperty(shad, 'shader')));
				cam.shaderNames.push(name);
				cam.cam.setFilters(cam.shaders);
				Debug.logSLEInfo('White shader added to CamNotes!');
			}
			else
			{
				Debug.logSLEError('cam or cam2 not found... cameras: cam1: ' + cam);
			}
	}

	public static function doTweenNotesWhiteShaderInAmount(tag:String, value:Float, time:Float, easeStr:String = "linear")
	{
		if (!ClientPrefs.data.shaders)
			return;
		var shaderName:String = "whiteShaderforNotes";
		var shad = psychlua.FunkinLua.lua_Shaders.get(shaderName);
		var ease = psychlua.LuaUtils.getTweenEaseByString(easeStr);

		var prop:String = "amount";

		var startVal = Reflect.getProperty(shad, prop);

		if (shad != null)
		{
			var variables = MusicBeatState.getVariables();
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('tween_$tag');

			variables.set(tag, PlayState.tweenManager.num(startVal, value, time, {
				onUpdate: function(tween:FlxTween)
				{
					var ting = FlxMath.lerp(startVal, value, ease(tween.percent));
					Reflect.setProperty(shad, prop, ting);
				},
				ease: ease,
				onComplete: function(tween:FlxTween)
				{
					Reflect.setProperty(shad, prop, value);
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					variables.remove(tag);
					// Debug.logInfo('Shader tween completed: '+ tag);
				}
			}));
		}
		else
		{
			Debug.logSLEWarn('Shader not added');
		}
	}

	static function setNotesWhiteShaderAmountValue(value:Dynamic)
	{
		if (!ClientPrefs.data.shaders)
			return;

		var shaderName:String = "whiteShaderforNotes";
		var prop:String = "amount";

		var shad = psychlua.FunkinLua.lua_Shaders.get(shaderName);

		if (shad != null && prop != null)
		{
			Reflect.setProperty(shad, prop, value);
		}
	}

	public static function flashNotesWhiteShader(value:Dynamic, time:Float, ease:String = "linear")
	{
		if (!ClientPrefs.data.shaders)
			return;

		setNotesWhiteShaderAmountValue(value);
		doTweenNotesWhiteShaderInAmount("flashShader", 0, time, ease);
	}

	public static function removeWhiteShaderFromNotes()
	{
		if (!ClientPrefs.data.shaders)
			return;
		var shaderName:String = "whiteShaderforNotes";
		var cam = psychlua.LuaUtils.getCameraByName("notestuff");
		if (cam != null)
		{
			if (cam.shaderNames.contains(shaderName))
			{
				var idx:Int = cam.shaderNames.indexOf(shaderName);
				if (idx != -1)
				{
					cam.shaderNames.remove(cam.shaderNames[idx]);
					cam.shaders.remove(cam.shaders[idx]);
					cam.cam.setFilters(cam.shaders); // refresh filters
				}
			}
		}
	}
}

class SetShaderToFlxGame
{
	public static function setShaderToFlxGame(shaderName:String)
	{
		if (!ClientPrefs.data.shaders)
			return;
		var shad = psychlua.FunkinLua.lua_Shaders.get(shaderName);

		if(shad != null)
		{
			FlxG.game.setFilters([new ShaderFilter(Reflect.getProperty(shad, 'shader'))]);
		}
	}

	public static function removeShaderToFlxGame()
		{
			if (!ClientPrefs.data.shaders)
				return;

			FlxG.game.setFilters([]);
		}
}