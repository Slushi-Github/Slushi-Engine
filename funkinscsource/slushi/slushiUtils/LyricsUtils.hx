package slushi.slushiUtils;

import tjson.TJSON as Json;
import psychlua.LuaUtils;

/*
 * This class is used to display lyrics on the gameplay, using a JSON file
 * 
 * Author: Slushi
 */
class LyricsUtils extends FlxSprite
{
	static var lyricsJsonData:Dynamic = null;
	static var mainText:FlxText;
	static var stop:Bool = false;

	public function new()
	{
		super();

		var playStateCurrentChart = PlayState.SONG;
		if (playStateCurrentChart == null)
			return;

		var finalModsPath:String = Paths.modsJson('songs/${Paths.formatToSongPath(playStateCurrentChart.songId.toLowerCase())}/lyrics');

		if (FileSystem.exists(finalModsPath))
		{
			Debug.logSLEInfo('Lyrics JSON file found!');
			Debug.logSLEInfo('Trying to load lyrics from: [$finalModsPath]');
			getLycrisData(finalModsPath);
		}
		else
		{
			Debug.logSLEInfo('Lyrics JSON file not found!');
			stop = true;
			return;
		}

		if (lyricsJsonData == null)
			return;

		Debug.logSLEInfo('Lyrics System started!');

		try
		{
			mainText = new FlxText(0, lyricsJsonData.textConfig.y, 0, "", lyricsJsonData.textConfig.textSize);
			mainText.setFormat(Paths.font(lyricsJsonData.textConfig.font), lyricsJsonData.textConfig.textSize, FlxColor.WHITE, CENTER,
				FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			mainText.scrollFactor.set();
			mainText.screenCenter(X);
			mainText.antialiasing = ClientPrefs.data.antialiasing;
			mainText.color = CoolUtil.colorFromString(lyricsJsonData.textConfig.textColor);
			PlayState.instance.add(mainText);
			mainText.camera = LuaUtils.cameraFromString(lyricsJsonData.textConfig.camera);

			if (lyricsJsonData.textConfig.font == null)
				mainText.font = Paths.font("vcr.ttf");
			if (lyricsJsonData.textConfig.textColor == null)
				mainText.color = FlxColor.WHITE;
			if (lyricsJsonData.textConfig.camera == null)
				mainText.camera = LuaUtils.cameraFromString("camthings");
		}
		catch (e)
		{
			Debug.logSLEError('Failed to create lyrics text: $e');
			stop = true;
			return;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (stop)
			return;
		else if (lyricsJsonData == null)
			return;
		else if (!PlayState.instance.songStarted)
			return;

		for (i in 0...lyricsJsonData.lyricsTexts.length)
		{
			if (Conductor.songPosition / 1000 > lyricsJsonData.lyricsTimes[i].startTime && !lyricsJsonData.lyricsTimes[i].started)
			{
				lyricsJsonData.lyricsTimes[i].started = true;
				setStringToText(lyricsJsonData.lyricsTexts[i], true, true);
			}

			if (Conductor.songPosition / 1000 > lyricsJsonData.lyricsTimes[i].endTime && !lyricsJsonData.lyricsTimes[i].fade)
			{
				lyricsJsonData.lyricsTimes[i].fade = true;
				setStringToText("", false, false);
			}

			if (i == lyricsJsonData.lyricsTimes.length + 1)
			{
				Debug.logSLEInfo('Finished lyrics!');
				stop = true;
				return;
			}
		}
	}

	static function getLycrisData(filePath:String)
	{
		var fileContent:String = "";
		try
		{
			fileContent = File.getContent(filePath);
			if (fileContent != null)
			{
				lyricsJsonData = Json.parse(fileContent);
			}
		}
		catch (e)
		{
			Debug.logSLEError('Failed to load lyrics file data: $e');
			stop = true;
		}
	}

	static function setStringToText(str:String, incoming:Bool, changeText:Bool)
	{
		var ease:String = lyricsJsonData.textConfig.ease;
		if (lyricsJsonData.textConfig.ease == null)
		{
			ease = "linear";
		}

		switch (incoming)
		{
			case true:
				mainText.y = lyricsJsonData.textConfig.y;
				FlxTween.tween(mainText, {y: mainText.y + 10}, 0.3, {ease: LuaUtils.getTweenEaseByString(ease)});
				FlxTween.tween(mainText, {alpha: 1}, 0.1, {ease: LuaUtils.getTweenEaseByString(ease)});
			case false:
				FlxTween.tween(mainText, {y: mainText.y + 10}, 0.3, {ease: LuaUtils.getTweenEaseByString(ease)});
				FlxTween.tween(mainText, {alpha: 0}, 0.1, {ease: LuaUtils.getTweenEaseByString(ease)});
		}

		if (changeText)
			mainText.text = str;
		mainText.screenCenter(X);
	}
}
