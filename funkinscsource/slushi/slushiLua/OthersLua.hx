package slushi.slushiLua;

import slushi.slushiUtils.SlushiEngineHUD;
import slushi.slushiUtils.SlushiDebugText;
import psychlua.FunkinLua;
import psychlua.LuaUtils;
import lime.system.System;
import objects.note.StrumArrow;
import objects.note.Note;

class OthersLua
{
	public static function loadOthersLua(funkLua:FunkinLua)
	{
		Debug.logSLEInfo('Loaded Slushi Others Lua functions!');

		funkLua.set("camGame", "game");
		funkLua.set("camHUD", "hud");
		funkLua.set("camOther", "other");
		funkLua.set("camNoteStuff", "notestuff");
		funkLua.set("camSLEHUD", "slehud");
		funkLua.set("camThings", "camthings");
		funkLua.set("camThings2", "camthings2");
		funkLua.set("camThings3", "camthings3");
		funkLua.set("camThings4", "camthings4");
		funkLua.set("camThings5", "camthings5");
		funkLua.set("camWaterMark", "camwatermark");

		funkLua.set("printInGameplay", function(text:Dynamic = '', time:Float = 6)
		{
			if (text == null)
				text = '';
			SlushiDebugText.printInDisplay(text, FlxColor.WHITE, time);
		});

		funkLua.set("tweenObjectFromSLEHUD", function(mode:String, value:Dynamic, time:Float, ease:String = "linear")
		{
			switch (mode)
			{
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
			var variables = MusicBeatState.getVariables("Camera");
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

		funkLua.set("removeCopyCamera", function(camTag:String)
		{
			var variables = MusicBeatState.getVariables("Camera");

			if (variables.exists(camTag))
			{
				FlxG.cameras.remove(variables.get(camTag));
				variables.remove(camTag);
				FunkinLua.lua_Cameras.remove(camTag);
				variables.get(camTag).destroy();
			}
		});

		funkLua.set("tweenNumer", function(tag:String, startNum:Float, endNum:Float, duration:Float, ease:String = "linear")
		{
			var variables = MusicBeatState.getVariables("Tween");

			variables.set(tag, FlxTween.num(startNum, endNum, duration, {
				ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: function(twn:FlxTween)
				{
					variables.remove(tag);
					if (PlayState.instance != null)
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					return endNum;
				},
				onUpdate: function(tween:FlxTween)
				{
					return tween.percent;
				}
			}));
		});

		funkLua.set("getSLEVersion", function():String
		{
			var version = SlushiMain.slushiEngineVersion;

			// This should not happen in an official build, but well, to avoid problems
			if (version.contains(' - [DEV]'))
				version = version.replace(' - [DEV]', '');

			return version;
		});

		funkLua.set("getMTCurrentModifiers", function(equalizer:String = ":"):String
		{
			var leText = '';
			// if (!PlayState.instance.notITGMod)
			// 	Debug.logSLEInfo('getMTCurrentModifiers called while not in ITG mode!');
			// 	return '';

			// Code from Hitmans AD
			for (modName => mod in PlayState.instance.playfieldRenderer.modifierTable.modifiers)
			{
				if (mod.currentValue != mod.baseValue)
				{
					leText += modName + equalizer + " " + FlxMath.roundDecimal(mod.currentValue, 2);
					for (subModName => subMod in mod.subValues)
					{
						leText += "    " + subModName + equalizer + " " + FlxMath.roundDecimal(subMod.value, 2);
					}
					leText += "\n";
				}
			}

			return leText;
		});

		funkLua.set("colorIntToRGB", function(color:Int):Array<Int>
		{
			return CustomFuncs.colorIntToRGB(color);
		});
	}
}
