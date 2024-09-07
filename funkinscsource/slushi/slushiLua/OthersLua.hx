package slushi.slushiLua;

import slushi.slushiEngineHUD.SlushiEngineHUD;
import slushi.slushiUtils.SlushiDebugText;

import psychlua.FunkinLua;
import psychlua.LuaUtils;

import lime.system.System;

class OthersLua
{
	public static function loadOthersLua(funkLua:FunkinLua)
	{
		Debug.logSLEInfo('Loaded Slushi Others Lua functions!');

		funkLua.set("printInGameplay", function(text:Dynamic = '', time:Float = 6)
		{
			if (text == null)
				text = '';
			SlushiDebugText.printInDisplay(text, FlxColor.WHITE, time);
		});

		funkLua.set("tweenObjectFromSLEHUD", function(mode:String, value:Dynamic, time:Float, ease:String = "linear")
		{
			switch(mode) {
				case "X":
					SlushiEngineHUD.instance.moveSLELogoX(value, time, ease);
				case "Y":
					SlushiEngineHUD.instance.moveSLELogoY(value, time, ease);
				case "ANGLE":
					SlushiEngineHUD.instance.moveSLELogoAngle(value, time, ease);
				case "BLACKALPHA":
					SlushiEngineHUD.instance.setblackAlpha(value, time);
				default:
					SlushiDebugText.printInDisplay("Invalid object mode: " + mode, FlxColor.RED);
			}
		});

		funkLua.set("luaMathCosecant", function(angle:Null<Float>):Float
		{
			return 1 / Math.sin(angle);
		});

		funkLua.set("showFPSText", function(mode:Bool)
		{
			if (Main.fpsVar != null)
				Main.fpsVar.visible = mode;
		});

		funkLua.set("getOSVersion", function()
		{
			return System.platformVersion;
		});

		funkLua.set("CopyCamera", function(camTag:String, camToCopy:String)
		{
			var variables = MusicBeatState.getVariables();
			if (!variables.exists(camTag))
			{
				var camera = new backend.CameraCopy(LuaUtils.cameraFromString(camToCopy));
				camera.bgColor.alpha = 0;
				FlxG.cameras.add(camera, false);
				variables.set(camTag, camera);
				FunkinLua.lua_Cameras.set(camTag, {cam: camera, shaders: [], shaderNames: []});
				Debug.logSLEInfo("Created new CameraCopy from [" + camToCopy + "] with tag [" + camTag + "]");
			}
		});

		funkLua.set("removeCopyCamera", function(camTag:String) {
			var variables = MusicBeatState.getVariables();

			if (variables.exists(camTag))
			{
				FlxG.cameras.remove(variables.get(camTag));
				variables.remove(camTag);
				FunkinLua.lua_Cameras.remove(camTag);
				variables.get(camTag).destroy();
			}
		});

		funkLua.set("tweenNumer", function(tag:String, startNum:Float, endNum:Float, duration:Float, ease:String = "linear") {
			var originalTag:String = tag;
			tag = LuaUtils.checkVariable(tag, 'tween_');
			var variables = MusicBeatState.getVariables();

			variables.set(tag, FlxTween.num(startNum, endNum, duration, {
				ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: function(twn:FlxTween) {
					variables.remove(tag);
					if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag]);
					return endNum;
				},
				onUpdate: function(tween:FlxTween) {
					return tween.percent;
				}
			}));
		});
	}
}
