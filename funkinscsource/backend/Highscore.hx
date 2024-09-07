package backend;

class Highscore
{
  public static var weekScores:Map<String, Int> = new Map();
  public static var songScores:Map<String, Int> = new Map<String, Int>();
  public static var songRating:Map<String, Float> = new Map<String, Float>();
  public static var songCombos:Map<String, String> = new Map<String, String>();
  public static var songLetter:Map<String, String> = new Map<String, String>();

  public static function resetSong(song:String, diff:Int = 0):Void
  {
    var daSong:String = formatSong(song, diff);
    setScore(daSong, 0);
    setRating(daSong, 0);
    setCombo(daSong, '');
    setLetter(daSong, '');
  }

  public static function resetWeek(week:String, diff:Int = 0):Void
  {
    var daWeek:String = formatSong(week, diff);
    setWeekScore(daWeek, 0);
  }

  public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1):Void
  {
    if(song == null) return;
    var daSong:String = formatSong(song, diff);

    if (songScores.exists(daSong))
    {
      if (songScores.get(daSong) < score)
      {
        setScore(daSong, score);
        if (rating >= 0) setRating(daSong, rating);
      }
    }
    else
    {
      setScore(daSong, score);
      if (rating >= 0) setRating(daSong, rating);
    }
  }

  public static function saveLetter(song:String, letter:String, ?diff:Int = 0):Void
  {
    var daSong:String = formatSong(song, diff);

    if (songLetter.exists(daSong))
    {
      if (getLetterInt(songLetter.get(daSong)) < getLetterInt(letter)) setLetter(daSong, letter);
    }
    else
    {
      setLetter(daSong, letter);
    }
  }

  public static function saveCombo(song:String, combo:String, ?diff:Int = 0):Void
  {
    var daSong:String = formatSong(song, diff);
    var finalCombo:String = combo.split(')')[0].replace('(', '');

    if (songCombos.exists(daSong))
    {
      if (getComboInt(songCombos.get(daSong)) < getComboInt(finalCombo)) setCombo(daSong, finalCombo);
    }
    else
      setCombo(daSong, finalCombo);
  }

  public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
  {
    var daWeek:String = formatSong(week, diff);

    if (weekScores.exists(daWeek))
    {
      if (weekScores.get(daWeek) < score) setWeekScore(daWeek, score);
    }
    else
      setWeekScore(daWeek, score);
  }

  /**
   * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
   */
  static function setScore(song:String, score:Int):Void
  {
    // Reminder that I don't need to format this song, it should come formatted!
    songScores.set(song, score);
    FlxG.save.data.songScores = songScores;
    FlxG.save.flush();
  }

  static function setLetter(song:String, letter:String):Void
  {
    songLetter.set(song, letter);
    FlxG.save.data.songLetter = songLetter;
    FlxG.save.flush();
  }

  static function setCombo(song:String, combo:String):Void
  {
    songCombos.set(song, combo);
    FlxG.save.data.songCombos = songCombos;
    FlxG.save.flush();
  }

  static function setWeekScore(week:String, score:Int):Void
  {
    // Reminder that I don't need to format this song, it should come formatted!
    weekScores.set(week, score);
    FlxG.save.data.weekScores = weekScores;
    FlxG.save.flush();
  }

  static function setRating(song:String, rating:Float):Void
  {
    // Reminder that I don't need to format this song, it should come formatted!
    songRating.set(song, rating);
    FlxG.save.data.songRating = songRating;
    FlxG.save.flush();
  }

  public static function formatSong(song:String, diff:Int):String
  {
    var diff:String = Difficulty.getFilePath(diff);
    song = Paths.formatToSongPath(song);

    if (Paths.fileExists('data/songs/$song/' + song + diff + '.json', TEXT)) return song + diff;
    return song;
  }

  static function getLetterInt(letter:String):Int
  {
    switch (letter)
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

  static function getComboInt(combo:String):Int
  {
    switch (combo)
    {
      case '???':
        return 6;
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
      default:
        return -1;
    }
  }

  public static function getLetter(song:String, diff:Int):String
  {
    var daSong:String = formatSong(song, diff);
    if (!songLetter.exists(daSong)) setLetter(daSong, '');
    return songLetter.get(daSong);
  }

  public static function getScore(song:String, diff:Int):Int
  {
    var daSong:String = formatSong(song, diff);
    if (!songScores.exists(daSong)) setScore(daSong, 0);

    return songScores.get(daSong);
  }

  public static function getCombo(song:String, diff:Int):String
  {
    var daSong:String = formatSong(song, diff);
    if (!songCombos.exists(daSong)) setCombo(daSong, '');

    return songCombos.get(daSong);
  }

  public static function getRating(song:String, diff:Int):Float
  {
    var daSong:String = formatSong(song, diff);
    if (!songRating.exists(daSong)) setRating(daSong, 0);

    return songRating.get(daSong);
  }

  public static function getWeekScore(week:String, diff:Int):Int
  {
    var daWeek:String = formatSong(week, diff);
    if (!weekScores.exists(daWeek)) setWeekScore(daWeek, 0);

    return weekScores.get(daWeek);
  }

  public static function load():Void
  {
    if (FlxG.save.data.weekScores != null)
    {
      weekScores = FlxG.save.data.weekScores;
    }
    if (FlxG.save.data.songScores != null)
    {
      songScores = FlxG.save.data.songScores;
    }
    if (FlxG.save.data.songCombos != null)
    {
      songCombos = FlxG.save.data.songCombos;
    }
    if (FlxG.save.data.songRating != null)
    {
      songRating = FlxG.save.data.songRating;
    }
    if (FlxG.save.data.songLetter != null)
    {
      songLetter = FlxG.save.data.songLetter;
    }
  }
}
