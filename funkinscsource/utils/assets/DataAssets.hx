package utils.assets;

class DataAssets
{
  public static function listDataFilesInPath(path:String):Array<String>
  {
    var results:Array<String> = [];
    var directories:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$path');
    for (directory in directories)
      if (FileSystem.exists(directory))
      {
        for (file in FileSystem.readDirectory(directory))
        {
          if (!results.contains('$file/$file'))
          {
            if (file.contains('.txt')) {}
            else
            {
              results.push('$file/$file');
            }
          }
        }
      }

    return results;
  }
}
