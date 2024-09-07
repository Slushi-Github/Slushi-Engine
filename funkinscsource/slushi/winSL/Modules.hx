package slushi.winSL;

import slushi.winSL.termvm.Terminal;
import slushi.winSL.termvm.CommandModule;

/**
 * Custom modules for the WinSL terminal.
 * 
 * Author: Slushi
 */

class Modules {
    public static var modules:Array<CommandModule> = [];

    public static function getModules():Array<CommandModule> {
            modules = [
            new CommandModule(["soy"], SoyModule.soy),
            new CommandModule(["itsthisforthat", "ittft"], ItsThisForThatModule.itsthisforthat),
            new CommandModule(["WriteTheWord", "writetheword"], WriteTheWordModule.writeTheWord),
            new CommandModule(["convertSM", "convertsm"], ConvertToFNFModule.main)
        ];
        return modules;
    }
}

class ModuleUtils {
    public static function clearConsole():Void {
        #if windows
        return WinConsoleUtils.clearTerminal();
        #else
        Sys.print("\033[3J\033[H\033[2J");
        #end
    }

    public static function getSandboxPath():String {
        return SlushiMain.getSLEPath("WinSL_Assets/sandbox/");
    }
    
    public static function getWinSLVersion():String {
        return SlushiMain.winSLVersion;
    }

    public static function printAlert(text:String, alertType:String):Void {
        switch(alertType) {
            case "error":
                Sys.println("\033[31m" + text + "\033[0m");
            case "warning":
                Sys.println("\033[33m" + text + "\033[0m");
            case "success":
                Sys.println("\033[32m" + text + "\033[0m");
            case "info":
                Sys.println("\033[34m" + text + "\033[0m");
            default:
                Sys.println(text);
        }
    }

    public static function wait(time:Float):Void {
        Sys.sleep(time);
    }
}

class SoyModule {
    public static function soy(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void {
        if(args[0] != null){
            terminal.stdout.writeString("hola " + args[0] + "!\n");
        }
        else{
            terminal.stdout.writeString("Necesitas introducir un argumento.\n");
        }
    }
}

class ItsThisForThatModule extends ModuleUtils {
    public static function itsthisforthat(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void {
        var urlToRequest:String = "https://itsthisforthat.com/api.php?text";
        var http = new Http(urlToRequest);

        http.onData = function(response:String) {
            terminal.stdout.writeString(response + "\n");
        }
        
        http.onError = function(error:String) {
            printAlert('Error while getting [itsthisforthat.com] API data: ' + error, 'error');
        }

        http.request();
    }
}

class WriteTheWordModule extends ModuleUtils {

    static var points = 0;

    static var terminalForGame:Terminal;

    public static function writeTheWord(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void {

        terminalForGame = terminal;

        terminal.stdout.writeString("Welcome to Write The Word!\n");
        terminal.stdout.writeString("Type the word as fast as you can, and accumulate as many points as possible.\n");

        wait(3);

        clearConsole();

        game();

        wait(0.8);

        terminal.stdout.writeString('You want to continue? (y/n) ');

        if (terminal.stdin.readLine().toString() == 'y') {
            game();
        }
        else {
            terminal.stdout.writeString("Your total points: " + points + "\n");
            terminal.stdout.writeString('Bye!\n\n');
        }
    }

    static function game():Void {
        var startTime:Float;
        var endTime:Float;
        var input:String;

        var word = getWord();

        terminalForGame.stdout.writeString("Press Enter to start\n");

        terminalForGame.stdin.readLine();

        wait(1);

        terminalForGame.stdout.writeString("Go!\n");

        terminalForGame.stdout.writeString("Type the word!: " + word + "\n--> ");

        startTime = Date.now().getTime();

        input = terminalForGame.stdin.readLine();

        endTime = Date.now().getTime();

        var elapsedTime = endTime - startTime;

        var finalTime = Math.floor(elapsedTime / 1000);

        if (input == word) {
            if (elapsedTime < 1000) {
                terminalForGame.stdout.writeString('Great job! you took ' + finalTime + ' seconds, +10 points\n');
                points += 10;
            } else if (elapsedTime < 2000) {
                terminalForGame.stdout.writeString('Good! you took ' + finalTime + ' seconds, +7 points\n');
                points += 7;
            } else if (elapsedTime < 3000) {
                terminalForGame.stdout.writeString('Well done! you took ' + finalTime + ' seconds, +5 points\n');
                points += 5;
            }
            else {
                terminalForGame.stdout.writeString('You took ' + finalTime + ' seconds, +2 points\n');
            }
        } else {
            terminalForGame.stdout.writeString('Wrong! The word was ' + word + ', you took ' + finalTime + ' seconds, -5 points\n');
            points -= 5;	
        }
    }

    static function getWord():String {
        var urlToRequest:String = "https://random-word-api.herokuapp.com/word";
        var http = new Http(urlToRequest);
        var word:String = null;

        http.onData = function(response:String) {
            word = response;
        }
        
        http.onError = function(error:String) {
            printAlert('Error while getting [random-word-api.herokuapp.com] API data: ' + error, 'error');
        }

        http.request();

        final finalWord =  word.replace('["', '').replace('"]', '');

        return finalWord;
    }
}

class ConvertToFNFModule {
    static var curSMFile:SMFile;
    static var finalFNFFile:String = '';
    static var finalFNFFileName:String = '';
    static var finalFNFFileNameLowerCase:String = '';
    static var finalDifficulty:String = '';
    static var finalSpeed:Float = 1.0;

    public static function main(terminal:Terminal, command:String, args:Array<String>, metadata:Dynamic):Void {
        if (args[0] == null) {
            return terminal.stdout.writeString("You need to specify the path to an SM file.\n");
        }

        var smFilePath:String = "./engineUtils/SMToConvert/" + args[0];

        if (!smFilePath.endsWith(".sm")) {
            return terminal.stdout.writeString("You need to specify a .sm file.\n");
        }

        if (!FileSystem.exists(smFilePath)) {
            terminal.stdout.writeString("File not found: [" + args[0] + "]\n");
            terminal.stdout.writeString('You can put it in "engineUtils/SMToConvert"\n');
            return;
        }

        terminal.stdout.writeString("Welcome to StepMania to FNF converter v1.3!\n");

        terminal.stdout.writeString("Loading SM file...\n");
        Sys.sleep(1.2);

        try {
            parseSMFile(smFilePath);
        }
        catch (e) {
            terminal.stdout.writeString("Error: " + e.toString() + "\n");
            return;
        }

        terminal.stdout.writeString("Enter the desired song name (press Enter to use SM file name): ");
        var songName:String = terminal.stdin.readLine().toString();
        if (songName == "") {
            songName = curSMFile.title;
        }

        while (true) {
            terminal.stdout.writeString("Enter the desired difficulty: ");
            var difficulty:String = terminal.stdin.readLine().toString();
            if (difficulty == "") {
                return terminal.stdout.writeString("You need to specify a difficulty.\n");
            }
            else{
                finalDifficulty = difficulty;
                break;
            }
        }

        terminal.stdout.writeString("Enter the desired speed (press Enter to use 3.0): ");
        var speed:String = terminal.stdin.readLine().toString();
        if (speed == "") {
            finalSpeed = 3.0;
        }
        else{
            finalSpeed = Std.parseFloat(speed);
        }

        Sys.sleep(1.2);

        terminal.stdout.writeString("Generating FNF chart...\n");
        generateChart(songName);

        while (true) {
            terminal.stdout.writeString("Do you like delete the original SM file? (y/n): ");
            if (terminal.stdin.readLine().toString() == "y") {
                if(FileSystem.exists(smFilePath))
                    FileSystem.deleteFile(smFilePath);
                terminal.stdout.writeString("Done!\n");
                break;
            }
            else {
                break;
            }
        } 
        
        while (true) {
            terminal.stdout.writeString("Do you want create the rest of the files for the FNF Song (like week JSON)? (y/n): ");
            if (terminal.stdin.readLine().toString() == "y") {
                createMoreFiles();
                terminal.stdout.writeString("Done!\n");
                break;
            }
            else {
                break;
            }
        }
    }

    static function parseSMFile(smFilePath:String):Void {
        var smContent:String = File.getContent(smFilePath);
        smContent = smContent.replace('\r\n', '\n');
        curSMFile = new SMFile(smContent);

        Sys.println("Song name: " + curSMFile.title);
        Sys.println("Song BPMS: " + curSMFile.bpms);
        Sys.println("Song offset: " + curSMFile.chartOffset + "\n");
    }

    static function generateChart(songName:String):Void {
        var cfg: SongConfig = {
            song: (songName != '') ? songName : 'SMSong',
            speed: finalSpeed, // You can set the default speed or ask the user for input
            player1: 'bf',
            player2: 'gf',
            gfVersion: 'gf'
        };

        var fnfchart:Dynamic = curSMFile.makeFNFChart(0, cfg, true);
        
        var jsonContent:String = haxe.Json.stringify(fnfchart, null, '\t');

        var outputFileName:String = cfg.song;
        var outputFilePath:String = "./engineUtils/SMToConvert/" + outputFileName.toLowerCase() + ".json";

        if (FileSystem.exists(outputFilePath)) {
            FileSystem.deleteFile(outputFilePath);
            Sys.println("Deleted existing file: " + outputFilePath + "\n");
        }

        File.saveContent(outputFilePath, jsonContent);

        finalFNFFileNameLowerCase = outputFileName.toLowerCase().replace(' ', '-');
        finalFNFFileName = outputFileName;
        finalFNFFile = outputFilePath;

        Sys.println("Conversion complete! Check the output file\n");
        Sys.sleep(1.4);
    }

    static function createMoreFiles() {
        var modsChartsFolder:String = './mods/data/songs/';
        var modsWeeksFolder:String = './mods/data/weeks/';
        var modsSongOGGFolder:String = './mods/songs/';
        var modsLuaFolder:String = './mods/scripts/songs/';
        var finalPath:String = '';

        var oggFile = "";

        var directory = FileSystem.readDirectory("./engineUtils/SMToConvert");

        for (file in directory) {
            if(file.endsWith(".ogg")) {
                oggFile = file;
                break;
            }
        }

        if(FileSystem.exists(finalFNFFile)) {
            if(!FileSystem.exists('$modsChartsFolder$finalFNFFileNameLowerCase')){
                FileSystem.createDirectory('$modsChartsFolder$finalFNFFileNameLowerCase');
            }
            finalPath = '$modsChartsFolder$finalFNFFileNameLowerCase/';
            File.copy(finalFNFFile, '$finalPath$finalFNFFileNameLowerCase-$finalDifficulty.json');
            Sys.println("Copied " + finalFNFFile + " to " + finalPath + finalFNFFileNameLowerCase + "-" + finalDifficulty + ".json");
            Sys.sleep(0.8);
        }

        if(FileSystem.exists("./engineUtils/SMToConvert/" + oggFile)) {
            {
                if(!FileSystem.exists('$modsSongOGGFolder$finalFNFFileNameLowerCase')){
                    FileSystem.createDirectory('$modsSongOGGFolder$finalFNFFileNameLowerCase');
                }
                finalPath = '$modsSongOGGFolder$finalFNFFileNameLowerCase/';
                File.copy("./engineUtils/SMToConvert/" + oggFile, '$finalPath' + 'Inst.ogg');
                Sys.println("Copied " + "./engineUtils/SMToConvert/" + oggFile + " to " + finalPath + 'Inst.ogg');
                Sys.sleep(0.8);
            }
        }
        else {
            Sys.println("File not found: [" + oggFile + "]\n");
            return;
        }

        var weekStructure:String = '
        {
            "songs": [
                ["$finalFNFFileName", "gf", [0, 0, 0]]
            ],
        
            "difficulties": "$finalDifficulty",

            "storyName": "",
            "weekBefore": "none",
            "weekName": "",
            "startUnlocked": true,
            "hideStoryMode": true,
            "hideFreeplay": false,
        }';

        File.saveContent('$modsWeeksFolder$finalFNFFileNameLowerCase.json', weekStructure);
        Sys.println('Created $modsWeeksFolder$finalFNFFileNameLowerCase.json file');
        Sys.sleep(0.8);

        var luaStructure:String = '-- Generated by StepMania to FNF Converter v1.3 (By Slushi) --\n\nfunction onCreatePost()\nend\n\nfunction onBeatHit()\nend\n\nfunction onUpdatePost(elapsed)\nend';
        if(!FileSystem.exists('$modsLuaFolder$finalFNFFileNameLowerCase')) {
            FileSystem.createDirectory('$modsLuaFolder$finalFNFFileNameLowerCase');
        }
        File.saveContent('$modsLuaFolder$finalFNFFileNameLowerCase/modchart.lua', luaStructure);
        Sys.println('Created $modsLuaFolder$finalFNFFileNameLowerCase/modchart.lua file');
    }
}