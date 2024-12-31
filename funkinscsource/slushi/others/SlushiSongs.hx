package slushi.others;

/**
 * A simple class for things of the Slushi Engine songs
 * 
 * Author: Slushi
 */
class SlushiSongs
{
	private static var slSongs:Array<Array<String>> = [["C18H27NO3", "slushi"]];

	public static function checkSong(songName:String, difficulty:String):Bool
	{
		for (i in slSongs)
		{
			if (songName == i[0] && difficulty == i[1])
			{
				return true;
				break;
			}
		}
		return false;
	}
}
