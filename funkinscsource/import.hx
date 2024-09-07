#if !macro
import lime.app.Application;
import openfl.Lib;
// Windows things
#if windows
import slushi.windows.CppAPI;
import slushi.windows.WindowsCPP;
import slushi.windows.WindowsCPP.MessageBoxIcon;
import slushi.windows.WindowsFuncs;
import slushi.windows.WinConsoleUtils;
#end
// Window, main of the engine and other things
import slushi.windowThings.WindowFuncs;
import slushi.SlushiMain;
import slushi.slushiUtils.SlushiDebugText.*;
import slushi.slushiUtils.*;
import slushi.slushiEngineHUD.SlushiEngineHUD;
import slushi.slushiUtils.LyricsUtils;
import slushi.others.CustomFuncs;
// Use own Debug class
import slushi.slushiUtils.Debug.*;
import slushi.slushiUtils.Debug;
// Shaders
import shaders.FunkinSourcedShaders;
import openfl.display.Shader;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import shaders.FunkinSourcedShaders.ShaderBase;
/////////////////////////////////////////

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end
// Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end
// Achievements
#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end
// Backend
import backend.Paths;
import backend.CoolUtil;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Difficulty;
import backend.Mods;
// import backend.Debug;
import backend.Language;
import backend.StageData;
import backend.WeekData;
import backend.song.Song;
import backend.song.SongData;
import backend.stage.*;
// Psych-UI
import backend.ui.*;
// Objects
import objects.Alphabet;
import objects.BGSprite;
import objects.FunkinSCSprite;
import objects.note.*;
import objects.note.constant.*;
import objects.stage.*;
// States
import states.PlayState;
import states.LoadingState;
import states.MusicBeatState;
// Substates
import substates.MusicBeatSubState;
import substates.IndieDiamondTransSubState;
// Flixel
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.graphics.FlxGraphic;
// Flixel Addons
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.effects.FlxSkewedSprite as FlxSkewed;
// FlxAnimate
#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end
// Modcharting Tools
#if SCEModchartingTools
import modcharting.*;
#end
// Gamejolt
import gamejolt.GJKeys;
import gamejolt.GameJoltAPI;
// Input
import input.Controls;
// Utils
import utils.Constants;

// Usings
using Lambda;
using StringTools;
using thx.Arrays;
using utils.tools.ArraySortTools;
using utils.tools.ArrayTools;
using utils.tools.FloatTools;
using utils.tools.Int64Tools;
using utils.tools.IntTools;
using utils.tools.IteratorTools;
using utils.tools.MapTools;
using utils.tools.StringTools;
#end