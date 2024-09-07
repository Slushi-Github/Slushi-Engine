package slushi.windowThings;

/**
 * This class is used to get the resolutions of the screen, and seting it in the window game.
 * 
 * Author: Slushi
 */

class WindowSizeUtil
{
    public static var screenResolutions:Array<Int> = [
        1280, 720,
        1366, 768,
        1440, 900,
        1600, 900,
        1920, 1080,
        2560, 1440
    ];

    public static var screenResolutionsString:Array<String> = [
        "1280x720",
        "1366x768",
        "1440x900",
        "1600x900",
        "1920x1080",
        "2560x1440"
    ];

    public static function getScreenResolutions(resolution:String):Array<Int> {
        switch (resolution){
            case "1280x720":
                return [1280, 720];
            case "1280x800":
                return [1280, 800];
            case "1280x960":
                return [1280, 960];
            case "1366x768":
                return [1366, 768];
            case "1440x900":
                return [1440, 900];
            case "1600x900":
                return [1600, 900];
            case "1920x1080":
                return [1920, 1080];
            case "2560x1440":
                return [2560, 1440];
            default:
                Debug.logSLEInfo('Invalid resolution: $resolution, using 1280x720');
                return [1280, 720];
        }
    }

    public static function getScreenResolutionsString():Array<String> {
        return screenResolutionsString;
    }

    public static function getScreenActualesolutionInString():String {
        return '${openfl.system.Capabilities.screenResolutionX}x${openfl.system.Capabilities.screenResolutionY}';

    }

    public static function setScreenResolution(newResolution:String) {
        if(getScreenResolutions(newResolution)[0] > openfl.system.Capabilities.screenResolutionX || getScreenResolutions(newResolution)[1] > openfl.system.Capabilities.screenResolutionY) {
            Debug.logSLEInfo("The requested resolution is larger than the actual resolution.");
            return;
        }

        // if(!Application.current.window.fullscreen && !Application.current.window.maximized) {
            FlxG.resizeGame(getScreenResolutions(newResolution)[0], getScreenResolutions(newResolution)[1]);
            Application.current.window.resize(getScreenResolutions(newResolution)[0], getScreenResolutions(newResolution)[1]);
            CppAPI.centerWindow();
        // }

        Debug.logSLEInfo("Set resolution to: " + newResolution);

        ClientPrefs.data.windowAndGameResolutionString = newResolution;
        ClientPrefs.data.windowAndGameResolution = getScreenResolutions(newResolution);
        ClientPrefs.saveSettings();
    }

    public static function setScreenResolutionOnStart() {
        if(ClientPrefs.data.windowAndGameResolutionString != "1280x720" && !Application.current.window.fullscreen && !Application.current.window.maximized) {
            FlxG.resizeGame(ClientPrefs.data.windowAndGameResolution[0], ClientPrefs.data.windowAndGameResolution[1]);
            Application.current.window.resize(ClientPrefs.data.windowAndGameResolution[0], ClientPrefs.data.windowAndGameResolution[1]);
            CppAPI.centerWindow();
            Debug.logSLEInfo("Set resolution to: " + ClientPrefs.data.windowAndGameResolutionString);
        }
    }
}
