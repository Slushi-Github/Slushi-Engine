package slushi.slushiUtils.stepManiaTools;

typedef ParsedEntry = {
    shouldParse:Bool,
    ?tag:String,
    ?value:String
};

typedef SwagSection = {
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
};

class SMUtils
{
    public static inline final TAG_START = '#';
    public static inline final TAG_END = ';';
    public static inline final TAG_SEP = ':';

    public static final TAGS_TO_INCLUDE = [
        'TITLE', 
        'OFFSET', 
        'BPMS', 
        'STOPS', 
        'NOTES',
        'ARTIST',
        'CREDIT'
    ];

    public static inline final NOTE_NONE = '0';
    public static inline final NOTE_STEP = '1';
    public static inline final NOTE_HOLD_HEAD = '2';
    public static inline final NOTE_TAIL = '3';
    public static inline final NOTE_ROLL_HEAD = '4';
    public static inline final NOTE_MINE = 'M';

    public static inline final BEATS_PER_MEASURE = 4;

    public static function parseBPMStr(bpmstr:String)
    {
        var bpmmap:Array<Array<Float>> = [];
        bpmstr = bpmstr.trim();
        var bpmpairs = bpmstr.split(',');
        for(pair in bpmpairs)
        {
            var splitpar = pair.split('=');
            bpmmap.push([ Std.parseFloat(splitpar[0]), Std.parseFloat(splitpar[1]) ]);
        }
        bpmmap.sort((a, b)->{
            if(a[0] > b[0]) return 1;
            else if(a[0] < b[0]) return -1;
            else return 0;
        });
        return bpmmap;
    }

    public static function parseEntry(entry:String):ParsedEntry
    {
        var pair = entry.trim().split(TAG_SEP);
        var tag = pair[0];
        if(!TAGS_TO_INCLUDE.contains(tag))
        {
            return {
                shouldParse: false,
                tag: tag
            };
        }
        var value:String;
        if(pair.length > 2)
        {
            value = pair.slice(1).join(TAG_SEP);
        }
        else
        {
            value = pair[1];
        }
        if(value.endsWith(';'))
            value = value.substring(0, value.length-1);

        return {
            shouldParse: true, 
            tag: tag, 
            value: value
        };
    }

    public static inline function getBeatsPerRow(measure:String)
    {
        return BEATS_PER_MEASURE/measure.trim().split('\n').length;
    }

    public static function bpmFromMap(bpmmap:Array<Array<Float>>, beatn:Float)
    {
        for(i in 0...bpmmap.length)
        {
            if(bpmmap[i][0] > beatn)
                return bpmmap[i-1][1];
        }

        return bpmmap[bpmmap.length - 1][1];
    }

    public static inline function makeSwagSection(bpm:Float, changebpm:Bool, bfsection:Bool = false):SwagSection
    {
        return {
            sectionNotes: [],
            sectionBeats: 4,
            typeOfSection: 0,
            mustHitSection: bfsection,
            gfSection: false,
            bpm: bpm,
            changeBPM: changebpm,
            altAnim: false
        };
    }

    public static function cleanChart(chartstr:String)
    {
        // removes comments from the simfiles
        var newchartstr = '';
        var valid = true;

        for(i in 0...chartstr.length)
        {
            var ch = chartstr.charAt(i);
            if(ch == '/' && (i+1 < chartstr.length && chartstr.charAt(i+1) == '/'))
            {
                valid = false;
            }
            else if(ch == '\n')
            {
                newchartstr += ch;
                valid = true;
            }
            else
            {
                if(valid)
                {
                    newchartstr += ch;
                }
            }
        }
        return newchartstr;
    }
}