package slushi.winSL;

/**
 * A simple class for utils for the WinSL terminal
 * 
 * Author: Slushi
 */

class WinSLConsoleUtils
{

    public static function init(){
        #if windows
        if(FlxG.sound.music != null) {
            FlxG.sound.music.volume = 0.0;
            FlxG.sound.music.stop();
        }
        Sys.println("\033[0m");	
        WindowsTerminalCPP.allocConsole();
        WindowsTerminalCPP.setConsoleTitle('WinSL [${SlushiMain.sleThingsVersions.winSLVersion}]');
        WindowsTerminalCPP.setConsoleWindowIcon(SlushiMain.getSLEPath("WinSL_Assets/windowIcon.ico"));
        WindowsTerminalCPP.centerConsoleWindow();
        WindowsTerminalCPP.setWinConsoleColor();
        WindowsTerminalCPP.hideMainWindow();
        Main.main();
        #end
    }

    public static function printLetterByLetter(text:String, time:Float):Void {
        var str:String = text;
        var index:Int = 0;
        for (c in str.split('')) {
            Sys.print(c);
            index++;
            Sys.sleep(time);
            if(index == str.length) break;
        }
    }
}