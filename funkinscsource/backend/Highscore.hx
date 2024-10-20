package backend;

import vslice.scoring.Scoring;

typedef ComboData =
{
  var swags:Int;
  var sicks:Int;
  var goods:Int;
  var bads:Int;
  var shits:Int;
  var misses:Int;
  var combo:Int;
  var maxCombo:Int;
  var highestCombo:Int;
  var totalNotesHit:Float;
  var totalPlayed:Int;
  var totalNoteCount:Int;
}

typedef MainData =
{
  var name:String;
  var difficulty:Int;
  var score:Int;
  @:optional var opponentMode:Bool;
}

typedef RankData =
{
  var rating:String;
  var comboRank:String;
  var accuracy:Float;
}

typedef HighScoreData =
{
  var mainData:MainData;
  var comboData:ComboData;
  var rankData:RankData;
}

/**
 * Class that handles scoring.
 */
class Highscore
{
  /**
   * A Map of scoring data of a week.
   */
  public static var weekScoreDataMap:Map<String, HighScoreData> = new Map<String, HighScoreData>();

  /**
   * A Map of scoring data of a week opponentMode.
   */
  public static var weekScoreDataOMMap:Map<String, HighScoreData> = new Map<String, HighScoreData>();

  /**
   * A Map of scoring data of a song.
   */
  public static var songScoreDataMap:Map<String, HighScoreData> = new Map<String, HighScoreData>();

  /**
   * A Map of scoring data of a song opponentMode.
   */
  public static var songScoreDataOMMap:Map<String, HighScoreData> = new Map<String, HighScoreData>();

  /**
   * Current song highScoreData.
   */
  public static var songHighScoreData:HighScoreData = null;

  /**
   * Week highscoreData.
   */
  public static var weekHighScoreData:HighScoreData = null;

  public static function resetScoreData():HighScoreData
  {
    var newData:HighScoreData =
      {
        mainData:
          {
            name: "",
            difficulty: 0,
            score: 0,
            opponentMode: false
          },
        comboData:
          {
            swags: 0,
            sicks: 0,
            goods: 0,
            bads: 0,
            shits: 0,
            combo: 0,
            maxCombo: 0,
            highestCombo: 0,
            misses: 0,
            totalNotesHit: 0.0,
            totalPlayed: 0,
            totalNoteCount: 0
          },
        rankData:
          {
            rating: "",
            comboRank: "",
            accuracy: 0.0
          }
      };

    return newData;
  }

  /**
   * Loads all score data
   */
  public static function load():Void
  {
    if (FlxG.save.data.weeksScoreData != null) weekScoreDataMap = FlxG.save.data.weeksScoreData;
    if (FlxG.save.data.songsScoreData != null) songScoreDataMap = FlxG.save.data.songsScoreData;
    if (FlxG.save.data.opponentModeWeeksScoreData != null) weekScoreDataOMMap = FlxG.save.data.opponentModeWeeksScoreData;
    if (FlxG.save.data.opponentModeSongsScoreData != null) songScoreDataOMMap = FlxG.save.data.opponentModeSongsScoreData;
    if (songHighScoreData == null) songHighScoreData = resetScoreData();
    if (weekHighScoreData == null) weekHighScoreData = resetScoreData();
  }

  /**
   * Save Song Score Data, Save's a song's scoreData.
   * @param song
   * @param scoreData
   * @param diff
   */
  public static function saveSongScore(scoreData:HighScoreData):Void
  {
    if (scoreData == null) return;

    // Reminder that I don't need to format this song, it should come formatted!
    // Opponent Mode Noted!
    if (!scoreData.mainData.opponentMode)
    {
      songScoreDataMap.set(formatSong(scoreData.mainData.name, scoreData.mainData.difficulty), scoreData);
      FlxG.save.data.songsScoreData = songScoreDataMap;
    }
    else
    {
      songScoreDataOMMap.set(formatSong(scoreData.mainData.name, scoreData.mainData.difficulty), scoreData);
      FlxG.save.data.opponentModeSongsScoreData = songScoreDataOMMap;
    }
    FlxG.save.flush();
  }

  /**
   * Save Week Score Data, Save's a week's scoreData.
   * @param song
   * @param scoreData
   * @param diff
   */
  public static function saveWeekScore(week:HighScoreData):Void
  {
    if (week == null) return;
    // Reminder that I don't need to format this song, it should come formatted!
    // Opponent Mode Noted!
    if (!week.mainData.opponentMode)
    {
      weekScoreDataMap.set(formatSong(week.mainData.name, week.mainData.difficulty), week);
      FlxG.save.data.weeksScoreData = weekScoreDataMap;
    }
    else
    {
      weekScoreDataOMMap.set(formatSong(week.mainData.name, week.mainData.difficulty), week);
      FlxG.save.data.opponentModeWeeksScoreData = weekScoreDataOMMap;
    }
    FlxG.save.flush();
  }

  /**
   * Formats song.
   * @param song
   * @param diff
   * @return String
   */
  public static function formatSong(song:String, diff:Int):String
  {
    if (song == null) return '';
    var diff:String = Difficulty.getFilePath(diff);
    song = Paths.formatToSongPath(song);
    if (Paths.fileExists('data/songs/$song/' + song + diff + '.json', TEXT)) return song + diff;
    return song;
  }

  /**
   * Grabs a song's score based on difficulty.
   * @param song
   * @param diff
   * @return Int
   */
  public static function getSongScore(song:String, diff:Int, opponentMode:Bool = false):HighScoreData
  {
    if (song == null) return resetScoreData();
    var daSong:String = formatSong(song, diff);
    var emptyData:HighScoreData = resetScoreData();
    emptyData.mainData.opponentMode = opponentMode;
    emptyData.mainData.name = daSong;
    emptyData.mainData.difficulty = diff;

    if (!emptyData.mainData.opponentMode)
    {
      if (!songScoreDataMap.exists(daSong)) saveSongScore(emptyData);
      return songScoreDataMap.get(daSong);
    }
    else
    {
      if (!songScoreDataOMMap.exists(daSong)) saveSongScore(emptyData);
      return songScoreDataOMMap.get(daSong);
    }
  }

  /**
   * Grabs a week score based on difficulty.
   * @param week
   * @param diff
   * @return HighScoreData
   */
  public static function getWeekScore(week:String, diff:Int, opponentMode:Bool = false):HighScoreData
  {
    if (week == null) return resetScoreData();
    var daWeek:String = formatSong(week, diff);
    var emptyData:HighScoreData = resetScoreData();
    emptyData.mainData.opponentMode = opponentMode;
    emptyData.mainData.name = daWeek;
    emptyData.mainData.difficulty = diff;

    if (!emptyData.mainData.opponentMode)
    {
      if (!weekScoreDataMap.exists(daWeek)) saveWeekScore(emptyData);
      return weekScoreDataMap.get(daWeek);
    }
    else
    {
      if (!weekScoreDataOMMap.exists(daWeek)) saveWeekScore(emptyData);
      return weekScoreDataOMMap.get(daWeek);
    }
  }

  /**
   * Reset Song, resets a songs score, combo and rating based on difficulty.
   * @param song
   * @param diff
   */
  public static function resetSong(song:String, diff:Int = 0, opponentMode:Bool = false):Void
  {
    if (song == null) return;
    var daSong:String = formatSong(song, diff);
    var emptyData:HighScoreData = resetScoreData();
    emptyData.mainData.opponentMode = opponentMode;
    emptyData.mainData.name = daSong;
    emptyData.mainData.difficulty = diff;
    saveSongScore(emptyData);
  }

  /**
   * Reset week, resets a week's song based on difficulty.
   * @param week
   * @param diff
   */
  public static function resetWeek(week:String, diff:Int = 0, opponentMode:Bool = false):Void
  {
    if (week == null) return;
    var daWeek:String = formatSong(week, diff);
    var emptyData:HighScoreData = resetScoreData();
    emptyData.mainData.opponentMode = opponentMode;
    emptyData.mainData.name = daWeek;
    emptyData.mainData.difficulty = diff;
    saveWeekScore(emptyData);
  }

  /**
   * Only replace the ranking data for the song, because the old score is still better.
   */
  public static function applySongRank(newScoreData:Null<HighScoreData> = null):Void
  {
    var newRank = Scoring.calculateRank(newScoreData);
    if (newScoreData == null || newRank == null) return;

    var daSong:String = formatSong(newScoreData.mainData.name, newScoreData.mainData.difficulty);
    var previousScoreData = newScoreData.mainData.opponentMode ? songScoreDataOMMap.get(daSong) : songScoreDataMap.get(daSong);

    var previousRank = Scoring.calculateRank(previousScoreData);

    if (previousScoreData == null || previousRank == null)
    {
      // Directly set the highscore.
      saveSongScore(newScoreData);
      return;
    }

    // Set the high score and the high rank separately.
    var completeData:HighScoreData = resetScoreData();
    completeData.mainData =
      {
        name: newScoreData.mainData.name,
        difficulty: newScoreData.mainData.difficulty,
        score: (previousScoreData.mainData.score > newScoreData.mainData.score) ? previousScoreData.mainData.score : newScoreData.mainData.score,
        opponentMode: newScoreData.mainData.opponentMode
      };
    completeData.comboData = (previousRank > newRank) ? previousScoreData.comboData : newScoreData.comboData;
    completeData.rankData = (previousRank > newRank) ? previousScoreData.rankData : newScoreData.rankData;
    final newScore:HighScoreData = completeData;

    saveSongScore(newScore);
  }

  /**
   * Checks to save song data.
   * @param scoreData
   * @return Bool
   */
  public static function isSongHighScore(scoreData:HighScoreData):Bool
  {
    if (scoreData == null) return false;
    var daSong:String = formatSong(scoreData.mainData.name, scoreData.mainData.difficulty);
    var highScoreData = scoreData.mainData.opponentMode ? songScoreDataOMMap.get(daSong) : songScoreDataMap.get(daSong);
    if (highScoreData == null)
    {
      highScoreData.mainData =
        {
          name: daSong,
          difficulty: scoreData.mainData.difficulty,
          score: 0,
          opponentMode: scoreData.mainData.opponentMode
        };
      highScoreData.comboData =
        {
          swags: 0,
          sicks: 0,
          goods: 0,
          bads: 0,
          shits: 0,
          misses: 0,
          combo: 0,
          maxCombo: 0,
          highestCombo: 0,
          totalNotesHit: 0.0,
          totalNoteCount: 0,
          totalPlayed: 0
        };
      highScoreData.rankData =
        {
          rating: "",
          comboRank: "",
          accuracy: 0.0
        };
      final scoreData:HighScoreData = highScoreData;
      saveSongScore(scoreData);
    }

    var currentHighScore = highScoreData;
    if (currentHighScore == null) return true;
    return scoreData.mainData.score > currentHighScore.mainData.score;
  }

  /**
   * Checks to save song data.
   * @param scoreData
   * @return Bool
   */
  public static function isWeekHighScore(scoreData:HighScoreData):Bool
  {
    if (scoreData == null) return false;
    var daWeek:String = formatSong(scoreData.mainData.name, scoreData.mainData.difficulty);
    var highScoreData = scoreData.mainData.opponentMode ? weekScoreDataOMMap.get(daWeek) : weekScoreDataMap.get(daWeek);
    if (highScoreData == null)
    {
      highScoreData.mainData =
        {
          name: daWeek,
          difficulty: scoreData.mainData.difficulty,
          score: 0,
          opponentMode: scoreData.mainData.opponentMode
        };
      highScoreData.comboData =
        {
          swags: 0,
          sicks: 0,
          goods: 0,
          bads: 0,
          shits: 0,
          misses: 0,
          combo: 0,
          maxCombo: 0,
          highestCombo: 0,
          totalNotesHit: 0.0,
          totalNoteCount: 0,
          totalPlayed: 0
        };
      highScoreData.rankData =
        {
          rating: "",
          comboRank: "",
          accuracy: 0.0
        }
      final scoreData:HighScoreData = highScoreData;
      saveWeekScore(highScoreData);
    }

    var currentHighScore = highScoreData;
    if (currentHighScore == null) return true;
    return scoreData.mainData.score > currentHighScore.mainData.score;
  }

  /**
   * Combines two different HighScoreData variables into one.
   * @param newData
   * @param baseData
   * @return HighScoreData
   */
  public static function combineScoreData(newData:HighScoreData, baseData:HighScoreData):HighScoreData
  {
    final newComboData:ComboData = newData.comboData;
    final baseComboData:ComboData = baseData.comboData;
    var combinedScoreData:HighScoreData = resetScoreData();
    combinedScoreData.mainData =
      {
        name: baseData.mainData.name,
        difficulty: baseData.mainData.difficulty,
        score: newData.mainData.score + baseData.mainData.score,
        opponentMode: baseData.mainData.opponentMode
      };
    combinedScoreData.comboData =
      {
        swags: newComboData.swags + baseComboData.swags,
        sicks: newComboData.sicks + baseComboData.sicks,
        goods: newComboData.goods + baseComboData.goods,
        bads: newComboData.bads + baseComboData.bads,
        shits: newComboData.shits + baseComboData.shits,
        misses: newComboData.misses + baseComboData.misses,
        combo: newComboData.combo,
        maxCombo: Std.int(Math.max(newComboData.maxCombo, baseComboData.maxCombo)),
        highestCombo: newComboData.highestCombo,
        totalNotesHit: newComboData.totalNotesHit + baseComboData.totalNotesHit,
        totalNoteCount: newComboData.totalNoteCount + baseComboData.totalNoteCount,
        totalPlayed: newComboData.totalPlayed + baseComboData.totalPlayed
      };
    combinedScoreData.rankData =
      {
        rating: newData.rankData.rating,
        comboRank: newData.rankData.comboRank,
        accuracy: newData.rankData.accuracy + baseData.rankData.accuracy
      };
    final scoreData:HighScoreData = combinedScoreData;
    return scoreData;
  }

  /**
   * Grabs rating Int from rating String.
   * @param rating
   * @return Int
   */
  static function getRatingInt(rating:String):Int
  {
    switch (rating)
    {
      default:
        return -1;
      case '?':
        return 0;
      case 'F':
        return 1;
      case 'E':
        return 2;
      case 'D':
        return 3;
      case 'C':
        return 4;
      case 'B':
        return 5;
      case 'A':
        return 6;
      case 'S':
        return 7;
      case 'SS':
        return 8;
      case 'SSS':
        return 9;
      case 'P':
        return 10;
    }
  }

  /**
   * Grabs combo Int from combo String.
   * @param combo
   * @return Int
   */
  static function getComboInt(combo:String, format:Bool = true):Int
  {
    if (format) combo = combo.split(')')[0].replace('(', '');
    switch (combo)
    {
      case 'Clear':
        return 0;
      case 'SDCB':
        return 1;
      case 'FC':
        return 2;
      case 'GFC':
        return 3;
      case 'SFC':
        return 4;
      case 'MFC':
        return 5;
      case '???':
        return 6;
      default:
        return -1;
    }
  }
}
