package backend;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

typedef WeekFile =
{
  // JSON variables
  var songs:Array<Dynamic>;
  var weekCharacters:Array<String>;
  var weekBackground:String;
  var weekBefore:String;
  var storyName:String;
  var weekName:String;
  var freeplayColor:Array<Int>;
  var startUnlocked:Bool;
  var hiddenUntilUnlocked:Bool;
  var hideStoryMode:Bool;
  var hideFreeplay:Bool;
  var difficulties:String;
  var defaultDifficulty:String;

  var ?sleSongConfig:Array<Dynamic>;
}

class WeekData
{
  public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
  public static var weeksList:Array<String> = [];

  public var folder:String = '';

  // JSON variables
  public var songs:Array<Dynamic>;
  public var weekCharacters:Array<String>;
  public var weekBackground:String;
  public var weekBefore:String;
  public var storyName:String;
  public var weekName:String;
  public var freeplayColor:Array<Int>;
  public var startUnlocked:Bool;
  public var hiddenUntilUnlocked:Bool;
  public var hideStoryMode:Bool;
  public var hideFreeplay:Bool;
  public var difficulties:String;
  public var defaultDifficulty:String;

  public var sleSongConfig:Array<Dynamic>;

  public var fileName:String;

  public static function createWeekFile():WeekFile
  {
    var weekFile:WeekFile =
      {
        songs: [
          ["Bopeebo", "dad", [146, 113, 253]],
          ["Fresh", "dad", [146, 113, 253]],
          ["Dad Battle", "dad", [146, 113, 253]]
        ],
        #if BASE_GAME_FILES
        weekCharacters: ['dad', 'bf', 'gf'],
        #else
        weekCharacters: ['bf', 'bf', 'gf'],
        #end
        weekBackground: 'mainStage',
        weekBefore: 'tutorial',
        storyName: 'Your New Week',
        weekName: 'Custom Week',
        freeplayColor: [146, 113, 253],
        startUnlocked: true,
        hiddenUntilUnlocked: false,
        hideStoryMode: false,
        hideFreeplay: false,
        difficulties: '',
        defaultDifficulty: '',

        sleSongConfig: [
          false, // Is a specific song for SLE
          "WINDOW TITLE TEST", // Window title for PlayState
        ]
      };
    return weekFile;
  }

  // HELP: Is there any way to convert a WeekFile to WeekData without having to put all variables there manually? I'm kind of a noob in haxe lmao
  public function new(weekFile:WeekFile, fileName:String)
  {
    // here ya go - MiguelItsOut
    for (field in Reflect.fields(weekFile))
      if (Reflect.fields(this).contains(field)) // Reflect.hasField() won't fucking work :/
        Reflect.setProperty(this, field, Reflect.getProperty(weekFile, field));

    this.fileName = fileName;
  }

  public static function reloadWeekFiles(isStoryMode:Null<Bool> = false, modsAllowed:Bool = true)
  {
    weeksList = [];
    weeksLoaded.clear();
    #if MODS_ALLOWED
    var directories:Array<String> = modsAllowed ? [Paths.mods(), Paths.getSharedPath()] : [Paths.getSharedPath()];
    var originalLength:Int = directories.length;

    if (modsAllowed)
    {
      for (mod in Mods.parseList().enabled)
        directories.push(Paths.mods(mod + '/'));
    }
    #else
    var directories:Array<String> = [Paths.getSharedPath()];
    var originalLength:Int = directories.length;
    #end

    var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getSharedPath('data/weeks/weekList.txt'));
    for (i in 0...sexList.length)
    {
      for (j in 0...directories.length)
      {
        var fileToCheck:String = directories[j] + 'data/weeks/' + sexList[i] + '.json';
        if (!weeksLoaded.exists(sexList[i]))
        {
          var week:WeekFile = getWeekFile(fileToCheck);
          if (week != null)
          {
            var weekFile:WeekData = new WeekData(week, sexList[i]);

            #if MODS_ALLOWED
            if (modsAllowed && j >= originalLength)
            {
              weekFile.folder = directories[j].substring(Paths.mods().length, directories[j].length - 1);
            }
            #end

            if (weekFile != null
              && (isStoryMode == null || (isStoryMode && !weekFile.hideStoryMode) || (!isStoryMode && !weekFile.hideFreeplay)))
            {
              weeksLoaded.set(sexList[i], weekFile);
              weeksList.push(sexList[i]);
            }
          }
        }
      }
    }

    if (modsAllowed)
    {
      #if MODS_ALLOWED
      for (i in 0...directories.length)
      {
        var directory:String = directories[i] + 'data/weeks/';
        if (FileSystem.exists(directory))
        {
          var listOfWeeks:Array<String> = CoolUtil.coolTextFile(directory + 'weekList.txt');
          for (daWeek in listOfWeeks)
          {
            var path:String = directory + daWeek + '.json';
            if (FileSystem.exists(path))
            {
              addWeek(daWeek, path, directories[i], i, originalLength, modsAllowed);
            }
          }

          for (file in FileSystem.readDirectory(directory))
          {
            var path = haxe.io.Path.join([directory, file]);
            if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
            {
              addWeek(file.substr(0, file.length - 5), path, directories[i], i, originalLength, modsAllowed);
            }
          }
        }
      }
      #end
    }
  }

  private static function addWeek(weekToCheck:String, path:String, directory:String, i:Int, originalLength:Int, modsAllowed:Bool = true)
  {
    if (!weeksLoaded.exists(weekToCheck))
    {
      var week:WeekFile = getWeekFile(path);
      if (week != null)
      {
        var weekFile:WeekData = new WeekData(week, weekToCheck);
        if (modsAllowed && i >= originalLength)
        {
          #if MODS_ALLOWED
          weekFile.folder = directory.substring(Paths.mods().length, directory.length - 1);
          #end
        }
        if ((PlayState.isStoryMode && !weekFile.hideStoryMode) || (!PlayState.isStoryMode && !weekFile.hideFreeplay))
        {
          weeksLoaded.set(weekToCheck, weekFile);
          weeksList.push(weekToCheck);
        }
      }
    }
  }

  private static function getWeekFile(path:String):WeekFile
  {
    var rawJson:String = null;
    #if sys
    if (FileSystem.exists(path)) rawJson = File.getContent(path);
    else
    #end
    if (OpenFlAssets.exists(path)) rawJson = Assets.getText(path);

    if (rawJson != null && rawJson.length > 0) return cast tjson.TJSON.parse(rawJson);
    return null;
  }

  //   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE
  // To use on PlayState.hx or Highscore stuff
  public static function getWeekFileName():String
  {
    return weeksList[PlayState.storyWeek];
  }

  // Used on LoadingState, nothing really too relevant
  public static function getCurrentWeek():WeekData
  {
    return weeksLoaded.get(weeksList[PlayState.storyWeek]);
  }

  public static function setDirectoryFromWeek(?data:WeekData = null)
  {
    Mods.currentModDirectory = '';
    if (data != null && data.folder != null && data.folder.length > 0)
    {
      Mods.currentModDirectory = data.folder;
    }
  }
}
