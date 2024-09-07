package backend;

import backend.ClientPrefs;
import flixel.util.FlxColor;

class Rating
{
  public static var timingWindows:Array<RatingWindow> = []; // highest rating goes first

  public static function judgeNote(noteDiff:Float, botplay:Bool):RatingWindow
  {
    var shitWindows:Array<RatingWindow> = timingWindows.copy();
    shitWindows.reverse();

    if (botplay) return shitWindows[0];

    for (index in 0...shitWindows.length)
    {
      if (noteDiff <= shitWindows[index].timingWindow)
      {
        return shitWindows[index];
      }
    }
    return shitWindows[shitWindows.length - 1];
  }

  public static function generateComboRank(songMisses:Int):String // generate a letter ranking
  {
    var comboranking:String = "N/A";

    if (songMisses != 10 && songMisses > 10)
    {
      comboranking = "(Clear)";
    }
    else if (songMisses < 10 && songMisses != 0) // Single Digit Combo Breaks
      comboranking = "(SDCB)";
    else
    {
      var reverseWindows = timingWindows.copy();
      reverseWindows.reverse();
      for (rate in reverseWindows)
      {
        if (rate.count > 0)
        {
          comboranking = '(${rate.comboRanking})';
        }
      }
    }

    if (comboranking == '?') comboranking = "N/A";
    return comboranking;
  }

  public static function generateComboLetter(updateAcc:Float):String
  {
    if (updateAcc == 100) return 'P'; // return 10
    else if (updateAcc >= 98) return 'SSS'; // reutrn 9
    else if (updateAcc >= 95) return 'SS'; // return 8
    else if (updateAcc >= 90) return 'S'; // return 7
    else if (updateAcc >= 85) return 'A'; // return 6
    else if (updateAcc >= 80) return 'B'; // return 5
    else if (updateAcc >= 70) return 'C'; // return 4
    else if (updateAcc >= 40) return 'D'; // return 3
    else if (updateAcc >= 20) return 'E'; // return 2
    else if (updateAcc > 0 && updateAcc < 20) return 'F'; // return 1
    else
      return '?'; // return 0
    return 'Unknown Rating';
  }
}

class RatingWindow
{
  public var name:String;
  public var timingWindow:Float;
  public var displayColor:FlxColor;
  public var healthBonus:Float;
  public var scoreBonus:Float;
  public var defaultTimingWindow:Float;
  public var causeMiss:Bool;
  public var doNoteSplash:Bool;
  public var count:Int = 0;
  public var accuracyBonus:Float;

  public var pluralSuffix:String;

  public var comboRanking:String;

  public function new(name:String, timingWindow:Float, comboRanking:String, displayColor:FlxColor, healthBonus:Float, scoreBonus:Float, accuracyBonus:Float,
      causeMiss:Bool, doNoteSplash:Bool)
  {
    this.name = name;
    this.timingWindow = timingWindow;
    this.comboRanking = comboRanking;
    this.displayColor = displayColor;
    this.healthBonus = healthBonus;
    this.scoreBonus = scoreBonus;
    this.accuracyBonus = accuracyBonus;
    this.causeMiss = causeMiss;
    this.doNoteSplash = doNoteSplash;
  }

  public static function createRatings():Void
  {
    Rating.timingWindows = [];

    var ratings:Array<String> = ['Shit', 'Bad', 'Good', 'Sick', 'Swag'];
    var timings:Array<Float> = [
      ClientPrefs.data.shitWindow,
      ClientPrefs.data.badWindow,
      ClientPrefs.data.goodWindow,
      ClientPrefs.data.sickWindow,
      ClientPrefs.data.swagWindow
    ];
    var colors:Array<FlxColor> = [
      FlxColor.fromString('0x8b0000'),
      FlxColor.RED,
      FlxColor.LIME,
      FlxColor.CYAN,
      FlxColor.YELLOW
    ];
    var acc:Array<Float> = [-1.00, 0.5, 0.75, 1.00, 1.00];

    var healthBonuses:Array<Float> = [-0.2, -0.06, 0, 0.04, 0.06];
    var scoreBonuses:Array<Int> = [-300, 0, 200, 350, 450];
    var defaultTimings:Array<Float> = [180, 135, 90, 45, 22.5];
    var missArray:Array<Bool> = [true, false, false, false, false];
    var splashArray:Array<Bool> = [false, false, false, true, true];
    var suffixes:Array<String> = ['s', 's', 's', 's', 's'];
    var combos:Array<String> = ['?', 'FC', 'GFC', 'PFC', 'MFC'];

    for (i in 0...ratings.length)
    {
      var rClass = new RatingWindow(ratings[i], timings[i], combos[i], colors[i], healthBonuses[i], scoreBonuses[i], acc[i], missArray[i], splashArray[i]);
      rClass.defaultTimingWindow = defaultTimings[i];
      rClass.pluralSuffix = suffixes[i];
      Rating.timingWindows.push(rClass);
    }

    if (Rating.timingWindows.length == 0) createRatings();
  }
}
