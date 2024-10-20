package states.freeplay;

class FreeplaySongMetaData
{
  public var songName:String = "";
  public var week:Int = 0;
  public var songCharacter:String = "";
  public var color:Int = -7179779;
  public var folder:String = "";
  public var blockOpponentMode:Null<Bool> = false;
  public var lastDifficulty:String = null;

  public function new(songName:String, week:Int, songCharacter:String, color:Int, blockOpponentMode:Bool)
  {
    this.songName = songName;
    this.week = week;
    this.songCharacter = songCharacter;
    this.color = color;
    this.blockOpponentMode = blockOpponentMode;
    this.folder = Mods.currentModDirectory;
    if (this.folder == null) this.folder = '';
  }
}
