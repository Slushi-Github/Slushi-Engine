
package slushi.slushiUtils.stepManiaTools;

import haxe.ds.StringMap;
import slushi.slushiUtils.stepManiaTools.SMUtils.SwagSection;

typedef FNFJson = {
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

    // var format:String,

	var validScore:Bool;

    var notITG:Bool;
    var sleHUD:Bool;
}

typedef SongConfig = {
    ?song:String,
    ?speed:Float,
    ?player1:String,
    ?player2:String,
    ?gfVersion:String
};

class SMFile
{
    public var extraHeaderTags:StringMap<String>;
    public var bpms:Array<Array<Float>>;
    public var charts:Array<SMChart>;
    public var title:String;
    
    public var chartOffset:Float;

    public function new(filecontent:String)
    {
        bpms = [];
        charts = [];
        extraHeaderTags = new StringMap();
        _parseChart(filecontent);
    }

    function _parseChart(chartstr:String)
    {
        var currHeaderEntry = '';
        var parsingTag = false;
        for(i in 0...chartstr.length)
        {
            var ch = chartstr.charAt(i);
            switch (ch)
            {
                case SMUtils.TAG_START:
                    parsingTag = true;
                case SMUtils.TAG_END:
                    parsingTag = false;
                    var parsedentry = SMUtils.parseEntry(currHeaderEntry);
                    if(!parsedentry.shouldParse)
                    {
                        currHeaderEntry = '';
                        continue;
                    }

                    switch (parsedentry.tag)
                    {
                        case 'BPMS':
                            bpms = SMUtils.parseBPMStr(parsedentry.value);
                        case 'NOTES':
                            charts.push(new SMChart(parsedentry.value));
                        case 'OFFSET':
                            chartOffset = Std.parseFloat(parsedentry.value);
                        case 'TITLE':
                            title = parsedentry.value;
                        default:
                            extraHeaderTags.set(parsedentry.tag, parsedentry.value);
                    }
                    currHeaderEntry = '';
                default:
                    if(parsingTag)
                        currHeaderEntry += ch;
            }
        }
    }

    public static inline function getOrDefault<T>(val:Null<T>, defaultVal:T)
    {
        if(val == null)
            return defaultVal;

        return val;
    }

    public function makeFNFChart(chartIndex=0, song_config:SongConfig=null, flipchart=false)
    {
        if(song_config == null)
            song_config = {};

        var fnfjson:FNFJson = {
            song: getOrDefault(song_config.song, extraHeaderTags.get('TITLE')),
            notes: [],
            events: [],
            bpm: bpms[0][1],
            needsVoices: false,
            speed: getOrDefault(song_config.speed, 1.0),
            player1: getOrDefault(song_config.player1, 'bf'),
            player2: getOrDefault(song_config.player2, 'dad'),
            gfVersion: getOrDefault(song_config.gfVersion, 'gf'),
            stage: '',
            validScore: true,
            // format: 'psych_v1_convert',
            notITG: true,
            sleHUD: true
        };
        var fnfchart = charts[chartIndex].toFNF(bpms, chartOffset, flipchart);
        fnfjson.notes = fnfjson.notes.concat(fnfchart);
        return { song: fnfjson };
    }
}