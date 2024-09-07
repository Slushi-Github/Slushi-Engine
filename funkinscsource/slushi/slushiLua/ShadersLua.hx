package slushi.slushiLua;

import psychlua.FunkinLua;

import slushi.slushiUtils.shaders.SlushiShaders;
import slushi.slushiUtils.shaders.SlushiShaders.Shader3DForNotes;
import slushi.slushiUtils.shaders.SlushiShaders.WhiteShaderForNotes;
import slushi.slushiUtils.shaders.SlushiShaders.SetShaderToFlxGame;

class ShadersLua
{
	public static function loadShadersLua(funkLua:FunkinLua)
	{
		Debug.logSLEInfo('Loaded Slushi Shaders Lua functions!');

		FunkinLua.lua_Cameras.set("camSLEHUD", {cam: PlayState.instance.camSLEHUD, shaders: [], shaderNames: []});
		FunkinLua.lua_Cameras.set("camFor3D", {cam: PlayState.instance.camFor3D, shaders: [], shaderNames: []});
		FunkinLua.lua_Cameras.set("camFor3D2", {cam: PlayState.instance.camFor3D2, shaders: [], shaderNames: []});
		FunkinLua.lua_Cameras.set("camFor3D3", {cam: PlayState.instance.camFor3D3, shaders: [], shaderNames: []});
		FunkinLua.lua_Cameras.set("camFor3D4", {cam: PlayState.instance.camFor3D4, shaders: [], shaderNames: []});
		FunkinLua.lua_Cameras.set("camFor3D5", {cam: PlayState.instance.camFor3D5, shaders: [], shaderNames: []});
		FunkinLua.lua_Cameras.set("camWaterWark", {cam: PlayState.instance.camWaterMark, shaders: [], shaderNames: []});

		funkLua.set("addShader3DToCamStrumsAndCamNotes", function()
		{
			Shader3DForNotes.addShader3DToCamStrumsAndCamNotes();
		});

		funkLua.set("addShader3DToNotes", function()
		{
			Shader3DForNotes.addShader3DToCamStrumsAndCamNotes();
		});

		funkLua.set("remove3DShaderFromCamNotesAndCamStrums", function()
		{
			Shader3DForNotes.remove3DShaderFromCamNotesAndCamStrums();
		});

		funkLua.set("remove3DShaderFromNotes", function()
		{
			Shader3DForNotes.remove3DShaderFromCamNotesAndCamStrums();
		});

		funkLua.set("setNotesShader3DProperty", function(prop:String, value:Dynamic)
		{
			Shader3DForNotes.setNotesShader3DProperty(prop, value);
		});

		funkLua.set("doTweenNotesShader3D", function(mode:String, tag:String, value:Dynamic, time:Float, easeStr:String = "linear")
		{
			switch(mode) {
				case "X" | "x":
					Shader3DForNotes.doTweenNotesShader3DInX(tag, value, time, easeStr);
				case "Y" | "y":
					Shader3DForNotes.doTweenNotesShader3DInY(tag, value, time, easeStr);
				case "Z" | "z":
					Shader3DForNotes.doTweenNotesShader3DInZ(tag, value, time, easeStr);
				case "DEPTH" | "depth" | "DEP" | "dep":
					Shader3DForNotes.doTweenNotesShader3DInDepth(tag, value, time, easeStr);
				default:
					printInDisplay("doTweenNotesShader3D: Invalid mode!", FlxColor.RED);
			}
		});

		funkLua.set("addWhiteShaderToNotes", function()
		{
			WhiteShaderForNotes.addWhiteShaderToNotes();
		});

		funkLua.set("removeWhiteShaderFromNotes", function()
		{
			WhiteShaderForNotes.removeWhiteShaderFromNotes();
		});

		funkLua.set("doTweenNotesWhiteShaderInAmount", function(tag:String, value:Dynamic, time:Float, easeStr:String = "linear")
		{
			WhiteShaderForNotes.doTweenNotesWhiteShaderInAmount(tag, value, time, easeStr);
		});

		funkLua.set("flashNotesWhiteShader", function(value:Dynamic, time:Float, easeStr:String = "linear")
		{
			WhiteShaderForNotes.flashNotesWhiteShader(value, time, easeStr);
		});

		funkLua.set("setShaderToFlxGame", function(shaderName:String)
		{
			SetShaderToFlxGame.setShaderToFlxGame(shaderName);
		});
	}
}
