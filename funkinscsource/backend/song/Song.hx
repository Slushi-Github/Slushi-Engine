package backend.song;

import tjson.TJSON as Json;
import lime.utils.Assets;
import objects.note.Note;

using backend.song.SongData;

class Song
{
  public var song:String;
  public var songId:String;

  public var notes:Array<SwagSection>;
  public var events:Array<Dynamic>;
  public var bpm:Float = 100.0;
  public var speed:Float = 1.0;
  public var offset:Float = 0.0;
  public var needsVoices:Bool = true;

  public var stage:String = null;
  public var format:String = '';

  public var options:OptionsData;
  public var gameOverData:GameOverData;
  public var characters:CharacterData;

  public static function convert(songJson:Dynamic) // Convert old charts to psych_v1 format
  {
    if (songJson.events == null)
    {
      songJson.events = [];
      for (secNum in 0...songJson.notes.length)
      {
        var sec:SwagSection = songJson.notes[secNum];

        var i:Int = 0;
        var notes:Array<Dynamic> = sec.sectionNotes;
        var len:Int = notes.length;
        while (i < len)
        {
          var note:Array<Dynamic> = notes[i];
          if (note[1] < 0)
          { // StrumTime /EventName,         V1,   V2,     V3,      V4,      V5,      V6,      V7,      V8,       V9,       V10,      V11,      V12,      V13,      V14
            songJson.events.push([
              note[0],
              [
                [
                  note[2],
                  [
                    note[3], note[4], note[5], note[6], note[7], note[8], note[9], note[10], note[11], note[12], note[13], note[14], note[15], note[16]]
                ]
              ]
            ]);
            notes.remove(note);
            len = notes.length;
          }
          else
            i++;
        }
      }
    }

    var sectionsData:Array<SwagSection> = songJson.notes;
    if (sectionsData == null) return;

    for (section in sectionsData)
    {
      var beats:Null<Float> = cast section.sectionBeats;
      if (beats == null || Math.isNaN(beats))
      {
        section.sectionBeats = 4;
        if (Reflect.hasField(section, 'lengthInSteps')) Reflect.deleteField(section, 'lengthInSteps');
      }

      for (note in section.sectionNotes)
      {
        var gottaHitNote:Bool = (note[1] < 4) ? section.mustHitSection : !section.mustHitSection;
        note[1] = (note[1] % 4) + (gottaHitNote ? 0 : 4);

        if (note[3] != null && !Std.isOfType(note[3], String)) note[3] = Note.defaultNoteTypes[note[3]]; // compatibility with Week 7 and 0.1-0.3 psych charts
      }
    }
  }

  public static var chartPath:String;
  public static var loadedSongName:String;
  public static var formattedSongName:String;

  public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
  {
    if (folder == null) folder = jsonInput;
    PlayState.SONG = getChart(jsonInput, folder);
    loadedSongName = folder;
    chartPath = _lastPath.replace('/', '\\');
    formattedSongName = Paths.formatToSongPath(PlayState.SONG.songId);
    Debug.logInfo(_lastPath);
    Debug.logInfo(chartPath);
    StageData.loadDirectory(PlayState.SONG);
    return PlayState.SONG;
  }

  static var _lastPath:String;

  public static function getChart(jsonInput:String, ?folder:String):SwagSong
  {
    if (folder == null) folder = jsonInput;
    var rawData:String = null;

    var formattedFolder:String = Paths.formatToSongPath(folder);
    var formattedSong:String = Paths.formatToSongPath(jsonInput);
    _lastPath = Paths.json('songs/$formattedFolder/$formattedSong');
    #if MODS_ALLOWED
    if (FileSystem.exists(_lastPath)) rawData = File.getContent(_lastPath);
    else
    #end
    rawData = Assets.getText(_lastPath);

    return rawData != null ? parseJSON(rawData, jsonInput) : null;
  }

  public static function parseJSON(rawData:String, ?nameForError:String = null, ?convertTo:String = 'psych_v1'):SwagSong
  {
    var songJson:SwagSong = cast Json.parse(rawData);
    if (Reflect.hasField(songJson, 'song'))
    {
      var subSong:SwagSong = Reflect.field(songJson, 'song');
      if (subSong != null && Type.typeof(subSong) == TObject) songJson = subSong;
    }

    if (convertTo != null && convertTo.length > 0)
    {
      var fmt:String = songJson.format;
      if (fmt == null) fmt = songJson.format = 'unknown';

      switch (convertTo)
      {
        case 'psych_v1':
          if (!fmt.startsWith('psych_v1')) // Convert to Psych 1.0 format
          {
            Debug.logInfo('converting chart $nameForError with format $fmt to psych_v1 format...');
            songJson.format = 'psych_v1_convert';
            convert(songJson);
          }
      }
    }

    processSongDataToSCEData(songJson);
    return songJson;
  }

  /**
   * Use when loading an unknown song json or when song json is newly created in the chart editor. (new json without data / null json).
   * @param songJson
   */
  public static function defaultIfNotFound(songJson:Dynamic)
  {
    if (songJson.options == null)
    {
      songJson.options =
        {
          disableNoteRGB: false,
          disableNoteQuantRGB: false,
          disableStrumRGB: false,
          disableSplashRGB: false,
          disableHoldCoversRGB: false,
          disableHoldCovers: false,
          disableCaching: false,
          notITG: false,
          usesHUD: false,
          oldBarSystem: false,
          rightScroll: false,
          middleScroll: false,
          blockOpponentMode: false,
          arrowSkin: "",
          strumSkin: "",
          splashSkin: "",
          holdCoverSkin: "",
          opponentNoteStyle: "",
          opponentStrumStyle: "",
          playerNoteStyle: "",
          playerStrumStyle: "",
          vocalsPrefix: "",
          vocalsSuffix: "",
          instrumentalPrefix: "",
          instrumentalSuffix: ""
        }
    }
    if (songJson.gameOverData == null)
    {
      songJson.gameOverData =
        {
          gameOverChar: "bf-dead",
          gameOverSound: "fnf_loss_sfx",
          gameOverLoop: "gameOver",
          gameOverEnd: "gameOverEnd"
        }
    }
    if (songJson.characters == null)
    {
      songJson.characters =
        {
          player: "bf",
          girlfriend: "dad",
          opponent: "gf",
          secondOpponent: "",
        }
    }
  }

  /**
   * Use to transform old data into new data from psych to SCE format to be able to load the Json when not null!
   * @param songJson
   */
  public static function processSongDataToSCEData(songJson:Dynamic)
  {
    try
    {
      /*
        Original Event Format
          event = [
            strumTime,
            [
              event,
              param1,
              param2
            ]
          ]
        Compared to SCE
          event = [
            strumTime,
            [
              events,
              [
                value1
                value2
                value3
                value4
                value5
                value6
                value7
                value8
                value9
                value10
                value11
                value12
                value13
                value14
              ]
            ]
          ]
       */
      if (songJson.events != null)
      {
        // Old Format
        var oldEvents:Array<Dynamic> = songJson.events;

        // New Format
        var newEvents:Array<Dynamic> = [];

        // Formatting Events
        for (event in oldEvents)
        {
          for (i in 0...event[1].length)
          {
            // Comp for old event loading
            var params:Array<String> = [];
            if (Std.isOfType(event[1][i][1], Array)) params = event[1][i][1];
            else if (Std.isOfType(event[1][i][1], String))
            {
              for (j in 1...14)
              {
                params.push(event[1][i][j]);
              }
            }

            newEvents.push([event[0], [[event[1][i][0], params]]]);
          }
        }

        // Old is now New.
        songJson.events = newEvents;
      }

      if (songJson.options == null)
      {
        songJson.options = {}
      }

      var options:Array<String> = [
        // RGB Bools
        'disableNoteRGB',
        'disableNoteQuantRGB',
        'disableStrumRGB',
        'disableSplashRGB',
        'disableHoldCoversRGB',
        // Bools
        'disableHoldCovers',
        'disableCaching',
        'notITG',
        'usesHUD',
        'oldBarSystem',
        'rightScroll',
        'middleScroll',
        'blockOpponentMode',
        // Strings
        'arrowSkin',
        'strumSkin',
        'splashSkin',
        'holdCoverSkin',
        'opponentNoteStyle',
        'opponentStrumStyle',
        'playerNoteStyle',
        'playerStrumStyle',
        // Music Strings
        'vocalsPrefix',
        'vocalsSuffix',
        'instrumentalPrefix',
        'instrumentalSuffix'
      ];

      var defaultOptionValues:Map<String, Dynamic> = [
        'disableNoteRGB' => false,
        'disableNoteQuantRGB' => false,
        'disableStrumRGB' => false,
        'disableSplashRGB' => false,
        'disableHoldCoversRGB' => false,

        'disableHoldCovers' => false,
        'disableCaching' => false,
        'notITG' => false,
        'usesHUD' => true,
        'oldBarSystem' => true,
        'rightScroll' => false,
        'middleScroll' => false,
        'blockOpponentMode' => false,

        'arrowSkin' => "",
        'strumSkin' => "",
        'splashSkin' => "",
        'holdCoverSkin' => "",
        'opponentNoteSyle' => "",
        'opponentStrumStyle' => "",
        'playerNoteStyle' => "",
        'playerStrumStyle' => "",

        'vocalsPrefix' => "",
        'vocalsSuffix' => "",
        'instrumentalPrefix' => "",
        'instrumentalSuffix' => ""
      ];

      for (field in options)
      {
        if (Reflect.hasField(songJson, field))
        {
          if (!Reflect.hasField(songJson.options, field)) Reflect.setProperty(songJson.options, field, Reflect.getProperty(songJson, field));
          Reflect.deleteField(songJson, field);
        }
        else
        {
          if (!Reflect.hasField(songJson.options, field)) Reflect.setProperty(songJson.options, field, defaultOptionValues.get(field));
        }
      }

      if (songJson.gameOverData == null)
      {
        songJson.gameOverData = {}
      }

      var gameOverData:Array<String> = ['gameOverChar', 'gameOverSound', 'gameOverLoop', 'gameOverEnd'];

      var defaultGameOverValues:Map<String, String> = [
        'gameOverChar' => "bf-dead",
        'gameOverSound' => "fnf_loss_sfx",
        'gameOverLoop' => "gameOver",
        'gameOverEnd' => 'gameOverEnd'
      ];

      for (field in gameOverData)
      {
        if (Reflect.hasField(songJson, field))
        {
          if (!Reflect.hasField(songJson.options, field)) Reflect.setProperty(songJson.gameOverData, field, Reflect.getProperty(songJson, field));
          Reflect.deleteField(songJson, field);
        }
        else
        {
          if (Reflect.hasField(songJson, field)) Reflect.setProperty(songJson.gameOverData, field, defaultGameOverValues.get(field));
        }
      }

      if (songJson.characters == null)
      {
        songJson.characters = {}
      }

      var characters:Array<String> = ['player', 'opponent', 'girlfriend', 'secondOpponent'];
      var originalChar:Array<String> = ['player1', 'player2', 'gfVersion', 'player4'];

      var defaultCharacters:Map<String, String> = [
        'player' => "bf",
        'opponent' => "dad",
        'girlfriend' => "gf",
        'secondOpponent' => ""
      ];

      for (field in 0...characters.length)
      {
        if (Reflect.hasField(songJson, originalChar[field]))
        {
          if (!Reflect.hasField(songJson.characters,
            characters[field])) Reflect.setProperty(songJson.characters, characters[field], Reflect.getProperty(songJson, originalChar[field]));
          Reflect.deleteField(songJson, originalChar[field]);
        }
        else
        {
          if (!Reflect.hasField(songJson.characters,
            characters[field])) Reflect.setProperty(songJson.characters, characters[field], defaultCharacters.get(characters[field]));
        }
      }

      if (songJson.characters.girlfriend != songJson.player3 && songJson.player3 != null)
      {
        songJson.characters.girlfriend = songJson.player3;
        if (Reflect.hasField(songJson, 'player3')) Reflect.deleteField(songJson, 'player3');
      }

      if (songJson.options.arrowSkin == '' || songJson.options.arrowSkin == "" || songJson.options.arrowSkin == null)
        songJson.options.arrowSkin = "noteSkins/NOTE_assets"
        + Note.getNoteSkinPostfix();

      if (songJson.options.strumSkin == '' || songJson.options.strumSkin == "" || songJson.options.strumSkin == null)
        songJson.options.strumSkin = "noteSkins/NOTE_assets"
        + Note.getNoteSkinPostfix();

      if (songJson.song != null && songJson.songId == null) songJson.songId = songJson.song;
      else if (songJson.songId != null && songJson.song == null) songJson.song = songJson.songId;
    }
    catch (e:haxe.Exception)
    {
      Debug.logInfo('FAILED TO LOAD CONVERSION JSON DATA FOR SCE ${e.message + e.stack}');
    }
  }
}
//-----------------------------//
/**
 * TO DO: V-Slice Chart Data here.
 */
//-----------------------------//
