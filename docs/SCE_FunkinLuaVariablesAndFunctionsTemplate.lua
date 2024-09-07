--Variables
--Variable, Type, Set Value (What is contains by default or what is set by default), Desc

--Lua Stuff
	local LuaStuff = {
		'Function_StopLua', "Dynamic", "##PSYCHLUA_FUNCTIONSTOPLUA", "Stops Lua",
		'Function_StopHScript', "Dynamic", "##PSYCHLUA_FUNCTIONSTOPHSCRIPT", "Stops HScript",
		'Function_StopAll', "Dynamic", "##PSYCHLUA_FUNCTIONSTOPALL", "Stops Everything",
		'Function_Stop', "Dynamic", "##PSYCHLUA_FUNCTIONSTOP", "Function to Stop",
		'Function_Continue', "Dynamic", "##PSYCHLUA_FUNCTIONCONTINUE", "Function to Continue",
		'luaDebugMode', "Boolean", "false", "uses DebugMode?",
		'luaDeprecatedWarnings', "Boolean", "true", "uses DeprecatedWarnings?",
		'inChartEditor', "Boolean", "false", "in Chart Editor?",
		'inModchartEditor', "Boolean", "false", "in Modchart Editor?"
	}

--Song/Week Stuff
	local SongWeekStuff = {
		'curBpm', "Float", "100", "Conductor Bpm", -- Conductor.bpm
		'bpm', "Float", "0", "PlayState's SONG Bpm", --PlayState.SONG.bpm
		'scrollSpeed', "Float", "1", "PlayState's SONG Speed", --PlayState.SONG.speed
		'crochet', "Float", "((60) / bpm) * 1000", "Beats in miliseconds", -- Grabs 60 and divides it by bpm but multiplies by 1000
		'stepCrochet', "Float", "crochet / 4", "Steps in miliseconds", --Grabs crochet and divides by 4
		'songLength', "Float", "music.length", "music's Length", --inst.length when playstate or if not then FlxG.sound.music.length;
		'songName', "String", "Song Id", "Song's name", --Grabs PlayState.SONG.songId;
		'songPath', "String", "Song's path", "Song's formatted path", --Grabs Paths.formatToSongPath(PlayState.SONG.songId);
		'startedCountDown', "Boolean", "false", "if count down has started",
		'curStage', "String", "stage", "PlayState's SONG Stage", --Grabs PlayState.SONG.stage;

		'isStoryMode', "Boolean", "false", "PlayState is in storyMode", --Grabs PlayState.isStoryMode;
		'difficulty', "Int", "0", "PlayState's story difficulty", --Grabs PlayState.storyDifficutly;

		'difficultyName', "String", "Difficulty Name", "Song's difficulty in string form", --Grabs Difficulty.getString();
		'difficultyPath', "String", "Difficulty Path", "Song's difficulyt path name", --Grabs Paths.formathToSongPath(Difficulty.getString());
		'weekRaw', "Int", "Story Week", "Story week number", --Grabs PlayState.storyWeek;
		'week', "Int", "weekList from storyWeek", "Song's name", --Grabs WeekData.weekList[PlayState.storyWeeek];
		'seenCutscene', "Boolean", "fale", "If cutscene has been seen", --Grabs PlayState.seenCutscene;
		'hasVocals', "Boolean", "Song's need for vocals", "PlayState Song's needsVoices", --Grabs PlayState.SONG.needsVoices;
	}

--Camera Pos
	local CameraPos = {
		'cameraX', "Int", "0", "Camera's X Pos",
		'cameraY', "Int", "0", "Camera's Y Pos",
	}

--Screen Stuff
	local ScreenStuff = {
		'screenWidth', "Int", "1280", "Screen's width", --Grabs FlxG.width;
		'screenHeight', "Int", "720", "Screen's height", --Grabs FlxG.width;
	}

--PlayState variables
	local PlayStateVars = {
		'curSection', "Int", "0", "Every Section",
		'curStep', "Int", "0", "Every Step",
		'curBeat', "Int", "0", "Every Beat",
		'curDecStep', "Float", "0", "Every Decimal Step",
		'curDecBeat', "Float", "0", "Every Decimal Beat",

		'score', "Int", "0", "Total Score",
		'misses', "Int", "0", "Total Misses",
		'hits', "Int", "0", "Total Hits",
		'combo', "Int", "0", "Total Combo",

		'rating', "Float", "0", "Total Rating",
		'ratingName', "String", "", "Rating's Name's",
		'version', "String", "psychEngineVersion", "Psych Engine's Version", --Grabs MainMenuState.psychEngineVersion.trim();
		'SCEversion', "String", "SCEEngineVersion", "SC Engine's Version", --Grabs MainMenuState.SCEVersion.trim();

		'inGameOver', "Boolean", "false", "is in gameOver",
		'mustHitSection', "Boolean", "false", "is musthitsection",
		'altAnim', "Boolean", "false", "turn on/off altAnim",
		'playerAltAnim', "Boolean", "false", "is player's AltAnim section?",
		'CPUAltAnim', "Boolean", "false", "is cpu's AltAnim section?",
		'gfSection', "Boolean", "false", "is gf's section?",
		'player4Section', "Boolean", "false", "is player4's section?",
		'playDadSing', "Boolean", "true", "PlayState dad sing's?",
		'playBFSing', "Boolean", "true", "PlayState boyfriend sing's?",
	}

--Gameplay Settings
	local gameplaySettings = {
		'healthGainMult', "Float", "1", "Health gain amount", --Grabs game.healthGain;
		'healthLossMult', "Float", "1", "Health loss amount", --Grabs game.healthLoss;
		'playbackRate', "Float", "1", "Song playback rate", --Grabs game.playbackRate;
		'guitarHeroSustains', "Boolean", "true", "Hero Sustains", --Grabs game.guitarHeroSustains;
		'instakillOnMiss', "Boolean", "false", "Killed on miss", --Grabs game.instakillOnMiss;
		'botplay', "Boolean", "false", "Bot plays for you", --Grabs game.cpuControlled;
		'practice', "Boolean", "false", "Practice the game", --Grabs game.practiceMode;
		'modchart', "Boolean", "true", "Active Modcharts", --Grabs game.notITG;
		'opponent', "Boolean", "false", "Play as opponent", --Grabs game.opponentMode;
		'showCaseMode', "Boolean", "false", "Show case the gameplay", --Grabs game.showCaseMode;
		'holdsActive', "Boolean", "true", "Long notes are active", --Grabs game.holdsActive;
	}

--Sturms
	for i = 0, 4 do
		local defaultPlayerStrumsX = {'defaultPlayerStrumX'..i, "Float", "0", "Default Player X Strum Number"..i}
		local defaultPlayerStrumsY = {'defaultPlayerStrumY'..i, "Float", "0", "Default Player Y Strum Number"..i}
		local defaultOpponentStrumsX = {'defaultOpponentStrumX'..i, "Float", "0", "Default Opponent X Strum Number"..i}
		local defaultOpponentStrumsY = {'defaultOpponentStrumY'..i, "Float", "0", "Default Opponent Y Strum Number"..i}
	end

--Default character
	local characterPos = {
		'defaultBoyfriendX', "Float", "770", "Default boyfriend X pos", --Grabs game.BF_X;
		'defaultBoyfriendY', "Float", "450", "Default boyfriend Y pos", --Grabs game.BF_Y;
		'defaultOpponentX', "Float", "100", "Default opponent X pos", --Grabs game.DAD_X;
		'defaultOpponentY', "Float", "100", "Default opponent Y pos", --Grabs game.DAD_Y;
		'defaultGirlfriendX', "Float", "400", "Default girlfriend X pos", --Grabs game.GF_X;
		'defaultGirlfriendY', "Float", "130", "Default girlfriend Y pos", --Grabs game.GF_Y;
		'defaultMomX', "Float", "100", "Default opponent2 X pos", --Grabs game.MOM_X;
		'defaultMomY', "Float", "100", "Default opponent2 Y pos", --Grabs game.MOM_Y;
	}

--Character shit
	local characterShit = {
		'boyfriendName', "String", "boyfriend", "PlayState's SONG Player 1", --Grabs PlayState.SONG.characters.player;
		'dadName', "String", "dad", "PlayState's SONG Player 2", --Grabs PlayState.SONG.characters.opponent;
		'gfName', "String", "gf", "PlayState's SONG gfVersion", --Grabs PlayState.SONG.characters.girlfriend;
		'momName', "String", "mom", "PlayState's SONG Player 4", --Grabs PlayState.SONG.characters.secondOpponent;
	}

-- Other settings
	local settings = {
		'downscroll', "Boolean", "false", "Scroll Type", --Grabs ClientPrefs.data.downScroll;
		'middlescroll', "Boolean", "false", "Scroll Center", --Grabs ClientPrefs.data.middleScroll;
		'framerate', "Int", "60", "Framerate of the game", --Grabs ClientPrefs.data.framerate;
		'ghostTapping', "Boolean", "true", "Not miss on touching key's without notes present", --Grabs ClientPrefs.data.ghostTapping;
		'hideHud', "Boolean", "false", "Hides Hud", --Grabs ClientPrefs.data.hideHud;
		'timeBarType', "String", "Time Left", "Types of the time bar", --Grabs ClientPrefs.data.timeBarType;
		'scoreZoom', "Boolean", "true", "A zoom takes place on the scoreText", --Grabs ClientPrefs.data.scoreZoom;
		'cameraZoomOnBeat', "Boolean", "true", "Allows zooms on beat in the cameras", --Grabs ClientPrefs.data.camZooms;
		'flashingLights', "Boolean", "true", "Allow Flashes of cameras", --Grabs ClientPrefs.data.flashing;
		'noteOffset', "Int", "0", "A Offset for notes", --Grabs ClientPrefs.data.noteOffset;
		'healthBarAlpha', "Float", "1", "Health bar's alpha", --Grabs ClientPrefs.data.healthBarAlpha;
		'noResetButton', "Boolean", "false", "Disables reset button 'R'", --Grabs ClientPrefs.data.noReset;
		'lowQuality', "Boolean", "false", "Makes the game lowQuality", --Grabs ClientPrefs.data.lowQuality;
		'shadersEnabled', "Boolean", "true", "Scroll Type", --Grabs ClientPrefs.data.shaders;
		'scriptName', "String", "Unknown", "The Script's Name", --Grabs ScriptName;
		'currentModDirectory', "String", "", "The current mod directory found", --Grabs Mods.currentModDirectory;
	}

-- NoteSkin/Splash
	local noteSkinSplashStuff = {
		'noteSkin', "String", "", "The Noteskin of the notes", --Grabs ClientPrefs.data.noteSkin;
		'noteSkinPostfix', "String", "", "The Postfix of the noteSkin", --Grabs Note.getNoteSkinPostfix();
		'splashSkin', "String", "", "The splashSkin of the splashes", --Grabs ClientPrefs.data.splashSkin;
		'splashSkinPostfix', "String", "", "The Postfix of the noteSkin", --Grabs NoteSplash.getSplashSkinPostfix();
		'splashSkinPostfix', "String", "", "The Postfix of the noteSkin", --Grabs NoteSplash.getSplashSkinPostfix();
		'splashAlpha', "Float", "0.6", "The Alpha of the splashes", --Grabs ClientPrefs.data.splashAlpha;
	}

--Some more song stuff
	local songStuff = {
		'songPos', "Float", "0", "The current song pos", --Grabs Conductor.songPosition
		'hudZoom', "Float", "1", "The hud's zoom", --Grabs game.camHUD.zoom;
		'cameraZoom', "Float", "1", "The camera's zoom", --Grabs FlxG.camera.zoom;
		'buildTarget', "String", "", "The main target for building" --Grabs getBuildTarget();
	}

--FunkinLua Functions--
getRunningScripts()

callScript(luaFile, funcName, null)

getGlobalFromScript(luaFile, globalVar)

setGlobalFromScript(luaFile, globalVar, val)

isRunning(isRunning)

setVar(varName, value)

getVar(varName)

getGlobalFromScript(luaFile, globalVar)

addLuaScript(luaFile, ignoreAlreadyRunning)

addHScript(luaFile, ignoreAlreadyRunning)

removeLuaScript(luaFile, ignoreAlreadyRunning)

loadSong(name, difficulty)

loadGraphic(variable, image, gridX, gridY)

loadFrames(variable, image, spriteType)

getObjectOrder(obj)

setObjectOrder(obj, position)

startTween(tag, vars, values, duration, options)

doTweenX(tag, vars, value, duration, ease)

doTweenY(tag, vars, value, duration, ease)

doTweenAngle(tag, vars, value, duration, ease)

doTweenAlpha(tag, vars, value, duration, ease)

doTweenZoom(tag, vars, value, duration, ease)

doTweenColor(tag, vars, targetColor, duration, ease)

noteTweenX(tag, note, value, durationg, ease)

noteTweenY(tag, note, value, durationg, ease)

noteTweenAngle(tag, note, value, durationg, ease)

noteTweenAlpha(tag, note, value, durationg, ease)

noteTweenDirection(tag, note, value, durationg, ease)

noteTweenSkewX(tag, note, value, durationg, ease)

noteTweenSkewY(tag, note, value, durationg, ease)

mouseClicked(button)

mousePressed(button)

mouseReleased(button)

cancelTween(tag)

runTimer(tag, time, loops)

cancelTimer(tag)

addScore(value)

addMisses(value)

addHits(value)

setScore(value)

setMisses(value)

setHits(value)

getScore()

getMisses()

getHits()

setHealth(value)

addHealth(value)

getHealth()

FlxColor(color)

getColorFromName(color)

getColorFromHex(color)

getColorFromString(color)

addCharacterToList(name, charType)

precacheImage(name, allowGPU)

precacheMusic(name)

precacheSound(name)

triggerEventLegacy(name, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)

startCountdown()

endSong()

restartSong(skipTransition)

exitSong(skipTransition)

getSongPosition()

getCharacterX(x)

setCharacterX(x)

getCharacterY(y)

setCharacterY(y)

cameraSetTarget(target)

cameraShake(camera, intensity, duration)

cameraFlash(camera, color, duration, forced)

cameraFade(camera, color, duration, forced)

setRatingPercent(value)

setRatingName(value)

setRatingFC(value)

getMouseX(camera)

getMouseY(camera)

getMidpointX(variable)

getMidpointY(variable)

getGraphicMidpointX(variable)

getGraphicMidpointY(variable)

getScreenPositionX(variable, camera)

getScreenPositionY(variable, camera)

characterForceDance(character, forcedToIdle)

makeLuaBackdrop(tag, image, x, y, axes)

makeLuaSprite(tag, image, x, y)

makeAnimatedLuaSprite(tag, image, x, y, spriteType)

makeLuaSkewedSprite(tag, image, x, y, skewX, skewY)

makeGraphic(obj, width, height, color)

addAnimationByPrefix(obj, name, prefix, framerate, loop)

addAnimation(obj, name, frames, framerate, loop)

addAnimationByIndices(obj, name, prefix, indices, framerate, loop)

playActorAnimation(obj, name, force, reverse, frame)

playAnim(obj, name, froced, reverse, startFrame)

playAnimOld(obj, name, forced, reverse, startFrame)

addOffset(obj, anim, x, y)

setScrollFactor(obj, scrollX, scrollY)

addLuaSprite(tag, place)

addSkewedSprite(tag, front)

addBackdrop(tag, front)

setGraphicSize(obj, x, y, updateHitBox)

scaleObject(obj, x, y, updateHitBox)

updateHitBox(obj)

updateHitBoxFromGroup(group, index)

removeLuaSprite(tag, destroy)

removeSkewedSprite(tag, destroy)

removeBackdrop(tag, destroy)

luaSpriteExists(tag)

luaSkewedExists(tag)

luaTextExists(tag)

setHealthBarColors(left, right)

setTimeBarColors(left, right)

setObjectCamera(obj, camera)

setBlendMode(obj, blend)

screenCenter(obj, pos)

objectOverlap(obj1, obj2)

getPixelColor(obj, x, y)

startDialogue(dialogueFile, music)

startVideo(videoFile, videoType)

playMusic(sound, volume, loop)

playSound(sound, volume, tag)

stopSound(tah)

pauseSound(tag)

resumeSound(tag)

soundFadeIn(tag, duration, fromValue, toValue)

soundFadeOut(tag, duration, toValue)

soundFadeCancel(tag)

getSoundVolume(tag)

setSoundVolume(tag)

getSoundTime(tag)

setSoundTime(tag, value)

getSoundPitch(tag)

setSoundPitch(tag, value)

debugPrint(text1, text2, text3, text4, text5)

doFunction(id, val1, val2, val3, val4)

changeDadCharacter(id, x, y)

changeBoyfriendCharacter(id, x, y)

changeGFCharacter(id, x, y)

changeMomCharacter(id, x, y)

changeStage(stage)

changeDadCharacterBetter(x, y, id)

changeBoyfriendCharacterBetter(x, y, id)

changeGFCharacterBetter(x, y, id)

changeMomCharacterBetter(x, y, id)

changeBFAuto(id, flipped, dontDestroy, playAnimationBeforeSwitch)

changeBoyfriendAuto(id, flipped, dontDestroy, playAnimationBeforeSwitch)

changeDadAuto(id, flipped, dontDestroy, playAnimationBeforeSwitch)

changeGFAuto(id, flipped, dontDestroy, playAnimationBeforeSwitch)

changeMomAuto(id, flipped, dontDestroy, playAnimationBeforeSwitch)

Debug(debugType, input, pos)

makeHealthIcon(tag, character, player)

changeAddedIcon(tag, character)

makeLuaIcon(tag, character, player)

changeLuaIcon(tag, character)

makeLuaCharacter(tag, character, isPlayer, flipped)

changeLuaCharacter(tag, character)

stopIdle(id, bool)

characterDance(character)

initBackgroundOverlayVideo(vidPath, videoType, layInFront)

startCharScripts(name)

setGeneralItem(item, value, instance) --Instance is if it uses the instance or the global item (PlayState.instance or PlayState)

getGeneralItem(item, instance) --Instance is if it uses the instance or the global item (PlayState.instance or PlayState)

--SupportBeta Functions (BETADCIU, EXTRA FUNCTIONS FOR SCE)--
setActorX(x, id)

setActorScreenCenter(id, pos)

setActorAccelerationX(x, id)

setActorDragX(x, id)

setActorVelocityX(x, id, bg)

setActorAlpha(alpha, id, bg)

setActorVisibility(visible, id, bg)

setActorY(y, id)

setActorAccelerationY(y, id)

setActorDragY(y, id)

setActorVelocityY(y, id)

setActorAngle(angle, id)

setActorScale(scale, id)

setActorScaleXY(scaleX, scaleY, id)

setActorFlipX(flip, id)

setActorFlipY(flip, id)

setActorColorRGB(id, color)

setActorScroll(x, y, id)

setActorLayer(id, layer)

getActorWidth(id)

getActorHeight(id)

getActorAlpha(id)

getActorAngle(id)

getActorX(id, bg)

getCameraZoom(id)

getActorY(id, bg)

getActorXMidPoint(id, graphic)

getActorYMidPoint(id, graphic)

getActorLayer(id)

characterZoom(id, zoomAmount)

tweenColor(vars, duration, initColor, finalColor, ease, tag)

doTweenColor2(vars, duration, initColor, finalColor, ease, tag)

enablePurpleMiss(id, toggle)

tweenCameraPos(toX, toY, time, onComplete)

tweenCameraAngle(toAngle, time, onComplete)

tweenCameraZoom(toZoom, time, onComplete)

tweenHudPos(toX, toY, time, onComplete)

tweenHudAngle(toAngle, time, onComplete)

tweenHudZoom(toZoom, time, onComplete)

tweenPos(id, toX, toY, time, onComplete)

tweenPosQuad(id, toX, toY, time, onComplete)

tweenPosXAngle(id, toX, toAngle, time, onComplete)

tweenPosYAngle(id, toY, toAngle, time, onComplete)

tweenAngle(id, toAngle, time, onComplete)

tweenCameraPosOut(toX, toY, time, onComplete)

tweenCameraAngleOut(toAngle, time, onComplete)

tweenHudPosOut(toX, toY, time, onComplete)

tweenHudAngleOut(toAngle, time, onComplete)

tweenHudZoomOut(toZoom, time, onComplete)

tweenPosOut(id, toX, toY, time, onComplete)

tweenHudZoomOut(toZoom, time, onComplete)

tweenPosOut(id, toX, toY, time, onComplete)

tweenPosXAngleOut(id, toX, toAngle, time, onComplete)

tweenPosYAngleOut(id, toY, toAngle, time, onComplete)

tweenAngleOut(id, toAngle, time, onComplete)

tweenCameraPosIn(toX, toY, time, onComplete)

tweenCameraAngleIn(toAngle, time, onComplete)

tweenCameraZoomIn(toZoom, time, onComplete)

tweenHudPosIn(toX, toY, time, onComplete)

tweenHudAngleIn(toAngle, time, onComplete)

tweenHudZoomIn(toZoom, time, onComplete)

tweenPosIn(id, toX, toY, time, onComplete)

tweenPosXAngleIn(id, toX, toAngle, time, onComplete)

tweenPosYAngleIn(id, toY, toAngle, time, onComplete)

tweenAngleIn(id, toAngle, time, onComplete)

tweenFadeIn(id, toAlpha, time, onComplete)

tweenFadeInBG(id, toAlpha, time, onComplete)

tweenFadeOut(id, toAlpha, time, onComplete)

tweenFadeOutBG(id, toAlpha, time, onComplete)

tweenFadeOutOneShot(id, toAngle, time)

RGBColor(r, g, b, alpha)

addClipRect(obj, x, y, width, height)

setClipRectAngle(obj, degrees)

objectColorTransform(obj, color)

objectColorTween(obj, duration, color, color2, ease)

inBetweenColor(color, color2, diff, remove0)

setCamFollow(x, y)

offCamFollow(id)

snapCam(x, y)

resetSnapCam(id)

shakeCam(i, d)

shakeHUD(i, d)

setCamZoom(zoomAmount)

addCamZoom(zoomAmount)

addHudZoom(zoomAmount)

getArrayLength(obj)

getMapLength(obj)

getMapKeys(obj, getValue)

getMapKey(obj, valName)

setMapKey(obj, valName, val)

removeObject(obj)

addObject(obj)

animationSwap(char, anim1, anim2)

destroyObject(id, bg)

removeGroupObject(obj, index)

destroyGroupObject(obj, index)

changeAnimOffset(id, x, y)

getDominantColor(sprite)

changeDadIcon(id)

changeBFIcon(id)

changeIcon(obj, iconName)

removeLuaIcon(tag)

changeDadIconNew(id)

changeBFIconNew(id)

setWindowPos(x, y)

getWindowX()

getWindowY()

resizeWindow(width, height)

getScreenWidth()

getScreenHeight()

getWindowWidth()

getWindowHeight()

arrayContains(obj, value)

setOffset(id, x, y)

updateHealthBar(dadColor, bfColor)

getScared(id)

getStageOffsets(char, value)

cacheCharacter(characterType, character)

changeHue(id, hue)

changeSaturation(id, sat)

changeBrightness(id, bright)

changeHSB(id, hue, sat, bright)

changeGroupHue(obj, hue)

changeGroupMemberHue(obj, index, hud)

changeNotes(style, character, postfix)

changeNotes2(style, character, postfix)

changeIndividualNotes(style, i, postfix)

playStrumAnim(isDad, id, time)
