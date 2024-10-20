package backend.song;

// Typedefs first
typedef OptionsData =
{
  /**
   * Disables the Notes RGB Shader.
   */
  @:optional
  @:default(false)
  var disableNoteRGB:Bool;

  /**
   * Disables the Notes Quant RGB (Not the shader!)
   */
  @:optional
  @:default(false)
  var disableNoteCustomRGB:Bool;

  /**
   * Disables the Strums RGB Shader.
   */
  @:optional
  @:default(false)
  var disableStrumRGB:Bool;

  /**
   * Disables the Splashes RGB Shader.
   */
  @:optional
  @:default(false)
  var disableSplashRGB:Bool;

  /**
   * Disables the HoldCover RGB Shader.
   */
  @:optional
  @:default(false)
  var disableHoldCoversRGB:Bool;

  /**
   * Disables the HoldCovers
   */
  @:optional
  @:default(false)
  var disableHoldCovers:Bool;

  /**
   * disabled character and stage caching while in song (stuck in creat until done). (stages are not included yet!)
   */
  @:optional
  @:default(false)
  var disableCaching:Bool;

  // These Affects PlayState in a few ways \\

  /**
   * Enabled if the song can use NOTITG Modcharts.
   */
  @:optional
  @:default(false)
  var notITG:Bool;

  /**
   * Changes the usage of if certain items are in camHUD or in their own camera.
   */
  @:optional
  @:default(false)
  var usesHUD:Bool;

  /**
   * Enabled if the health and time Bars are like 0.7 or like before (separated).
   */
  @:optional
  @:default(false)
  var oldBarSystem:Bool;

  /**
   * Forces non-middleScroll.
   */
  @:optional
  @:default(false)
  var rightScroll:Bool;

  /**
   * Forces middleScroll.
   */
  @:optional
  @:default(false)
  var middleScroll:Bool;

  /**
   * Blocks opponentMode from being used.
   */
  @:optional
  @:default(false)
  var blockOpponentMode:Bool;

  @:optional
  @:default(false)
  var sleHUD:Bool;

  /**
   * The arrow skin used for the notes.
   */
  @:optional
  @:default("")
  var arrowSkin:String;

  /**
   * The strum skin used for the strums.
   */
  @:optional
  @:default("")
  var strumSkin:String;

  /**
   * The splash skin used for the note splashes.
   */
  @:optional
  @:default("")
  var splashSkin:String;

  /**
   * The hold skin used for the holdcovers.
   */
  @:optional
  @:default("")
  var holdCoverSkin:String;

  /**
   * The opponent's noteStyle.
   */
  @:optional
  @:default("")
  var opponentNoteStyle:String;

  /**
   * The opponent's strumStyle.
   */
  @:optional
  @:default("")
  var opponentStrumStyle:String;

  /**
   * The players noteStyle.
   */
  @:optional
  @:default("")
  var playerNoteStyle:String;

  /**
   * The players strumStyle.
   */
  @:optional
  @:default("")
  var playerStrumStyle:String;

  /**
   * The vocals prefix.
   */
  @:optional
  @:default("")
  var vocalsPrefix:String;

  /**
   * The vocals suffix.
   */
  @:optional
  @:default("")
  var vocalsSuffix:String;

  /**
   * The instrumentals prefix.
   */
  @:optional
  @:default("")
  var instrumentalPrefix:String;

  /**
   * The instrumentals suffix.
   */
  @:optional
  @:default("")
  var instrumentalSuffix:String;
}

// Song Classes
class SongOptionsData
{
  /**
   * Disables the Notes RGB Shader.
   */
  @:optional
  @:default(false)
  public var disableNoteRGB:Bool = false;

  /**
   * Disables the Notes Quant RGB (Not the shader!)
   */
  @:optional
  @:default(false)
  public var disableNoteCustomRGB:Bool = false;

  /**
   * Disables the Strums RGB Shader.
   */
  @:optional
  @:default(false)
  public var disableStrumRGB:Bool = false;

  /**
   * Disables the Splashes RGB Shader.
   */
  @:optional
  @:default(false)
  public var disableSplashRGB:Bool = false;

  /**
   * Disables the HoldCover RGB Shader.
   */
  @:optional
  @:default(false)
  public var disableHoldCoverRGBs:Bool = false;

  /**
   * Disables the HoldCovers
   */
  @:optional
  @:default(false)
  public var disableHoldCovers:Bool = false;

  /**
   * disabled character and stage caching while in song (stuck in creat until done). (stages are not included yet!)
   */
  @:optional
  @:default(false)
  public var disableCaching:Bool = false;

  // These Affects PlayState in a few ways \\

  /**
   * Enabled if the song can use NOTITG Modcharts.
   */
  @:optional
  @:default(false)
  public var notITG:Bool = false;

  /**
   * Changes the usage of if certain items are in camHUD or in their own camera.
   */
  @:optional
  @:default(false)
  public var usesHUD:Bool = false;

  /**
   * Enabled if the health and time Bars are like 0.7 or like before (separated).
   */
  @:optional
  @:default(false)
  public var oldBarSystem:Bool = false;

  /**
   * Forces non-middleScroll.
   */
  @:optional
  @:default(false)
  public var rightScroll:Bool = false;

  /**
   * Forces middleScroll.
   */
  @:optional
  @:default(false)
  public var middleScroll:Bool = false;

  /**
   * Blocks opponentMode from being used.
   */
  @:optional
  @:default(false)
  public var blockOpponentMode:Bool = false;

  /**
   * The arrow skin used for the notes.
   */
  @:optional
  @:default("")
  public var arrowSkin:String = "";

  /**
   * The arrow skin used for the strums.
   */
  @:optional
  @:default("")
  public var strumSkin:String = "";

  /**
   * The splash skin used for the note splashes.
   */
  @:optional
  @:default("")
  public var splashSkin:String = "";

  /**
   * The hold skin used for the holdcovers.
   */
  @:optional
  @:default("")
  public var holdCoverSkin:String = "";

  /**
   * The opponent's noteStyle.
   */
  @:optional
  @:default("")
  public var opponentNoteStyle:String = "";

  /**
   * The opponent's strumStyle.
   */
  @:optional
  @:default("")
  public var opponentStrumStyle:String = "";

  /**
   * The players noteStyle.
   */
  @:optional
  @:default("")
  public var playerNoteStyle:String = "";

  /**
   * The players strumStyle.
   */
  @:optional
  @:default("")
  public var playerStrumStyle:String = "";

  /**
   * The vocals prefix.
   */
  @:optional
  @:default("")
  public var vocalsPrefix:String = "";

  /**
   * The vocals suffix.
   */
  @:optional
  @:default("")
  public var vocalsSuffix:String = "";

  /**
   * The instrumentals prefix.
   */
  @:optional
  @:default("")
  public var instrumentalPrefix:String = "";

  /**
   * The instrumentals suffix.
   */
  @:optional
  @:default("")
  public var instrumentalSuffix:String = "";
}

typedef GameOverData =
{
  /**
   * The game over character for the song.
   */
  @:optional
  @:default('')
  var gameOverChar:String;

  /**
   * The sound the plays when you lost all your health.
   */
  @:optional
  @:default('')
  var gameOverSound:String;

  /**
   * The loop atfer sound is played in game over.
   */
  @:optional
  @:default('')
  var gameOverLoop:String;

  /**
   * The end of game over.
   */
  @:optional
  @:default('')
  var gameOverEnd:String;
}

/**
 * Data loaded for the game over from the song json.
 */
class SongGameOverData
{
  /**
   * The game over character for the song.
   */
  @:optional
  @:default('')
  public var gameOverChar:String = '';

  /**
   * The sound the plays when you lost all your health.
   */
  @:optional
  @:default('')
  public var gameOverSound:String = '';

  /**
   * The loop atfer sound is played in game over.
   */
  @:optional
  @:default('')
  public var gameOverLoop:String = '';

  /**
   * The end of game over.
   */
  @:optional
  @:default('')
  public var gameOverEnd:String = '';
}

typedef CharacterData =
{
  @:optional
  @:default('')
  var player:String;

  @:optional
  @:default('')
  var girlfriend:String;

  @:optional
  @:default('')
  var opponent:String;

  @:optional
  @default('')
  var secondOpponent:String;
}

/**
 * Information about the characters used in this variation of the song.
 * Create a new variation if you want to change the characters.
 */
class SongCharacterData
{
  @:optional
  @:default('')
  public var player:String = '';

  @:optional
  @:default('')
  public var girlfriend:String = '';

  @:optional
  @:default('')
  public var opponent:String = '';

  @:optional
  @default('')
  public var secondOpponent:String = "";
}

typedef SwagSection =
{
  var sectionNotes:Array<Dynamic>;
  var sectionBeats:Float;
  var mustHitSection:Bool;
  @:optional var playerAltAnim:Bool;
  @:optional var CPUAltAnim:Bool;
  @:optional var player4Section:Bool;
  @:optional var gfSection:Bool;
  @:optional var altAnim:Bool;
  @:optional var changeBPM:Bool;
  @:optional var bpm:Float;
  @:optional var dType:Int;
  @:optional var index:Int;
}

typedef SwagSong =
{
  /**
   * Use to be the internal name of the song.
   */
  var song:String;

  /**
   * The internal name of the song, as used in the file system.
   */
  var songId:String;

  /**
   * Variable used to display a name.
   */
  var ?displayName:String;

  var notes:Array<SwagSection>;
  var events:Array<Dynamic>;
  var bpm:Float;
  var needsVoices:Bool;
  var speed:Float;
  var offset:Float;

  var stage:String;
  var format:String;

  var notITG:Bool;
  var sleHUD:Bool;

  var ?options:OptionsData;
  var ?gameOverData:GameOverData;
  var ?characters:CharacterData;

  /**
   * Using this, you can create custom data inside the song Json. But data only you can use for whatever else.
   */
  var ?_extraData:Dynamic;
}
