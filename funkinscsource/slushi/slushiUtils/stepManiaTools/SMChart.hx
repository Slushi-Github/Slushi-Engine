package slushi.slushiUtils.stepManiaTools;

import haxe.ds.Map;
import slushi.slushiUtils.stepManiaTools.SMUtils.SwagSection;
using StringTools;

class SMChart
{
    public var chartType:String;
    public var author:String;
    public var difficulty:String;
    public var numericalMeter:String;
    public var grooveRadarVal:String;

    public var measures:Array<String>;
    public var n_keys:Int;

    public function new(chartstr:String)
    {
        chartstr = SMUtils.cleanChart(chartstr.trim());

        var chartdatasections = chartstr.split(':');
        chartType = _cleanMetadata(chartdatasections[0]);
        author = _cleanMetadata(chartdatasections[1]);
        difficulty = _cleanMetadata(chartdatasections[2]);
        numericalMeter = _cleanMetadata(chartdatasections[3]);
        grooveRadarVal = _cleanMetadata(chartdatasections[4]); // no idea what to do with this `\_(.-.)_/`

        var note_data = chartdatasections[chartdatasections.length-1];
        measures = [ for(x in note_data.split(',')) x.trim() ];
        n_keys = measures[0].trim().split('\n')[0].length;
    }

    public function toFNF(bpmmap:Array<Array<Float>>, offset=0.0, flipChart=false):Array<SwagSection>
    {
        var sections:Array<SwagSection> = [];
        var holdtracker = new Map<Int, Array<Dynamic>>();

        var strumtime = 0.0;
        var beatnum = 0.0;
        var curbpm = SMUtils.bpmFromMap(bpmmap, beatnum);
        var change_bpm = false;
        sections.push(SMUtils.makeSwagSection(curbpm, change_bpm, flipChart));

        for(measure in measures)
        {
            var measure_rows = measure.trim().split('\n');

            for(row in measure_rows)
            {
                var latestSection = sections[sections.length - 1];
                latestSection.bpm = curbpm;

                for(columnIndex in 0...row.length)
                {
                    var notevalue = row.charAt(columnIndex);
                    switch (notevalue)
                    {
                        case SMUtils.NOTE_STEP:
                            latestSection.sectionNotes.push( [ (strumtime - offset)*1000, columnIndex, 0.0 ] );
                        case SMUtils.NOTE_HOLD_HEAD, SMUtils.NOTE_ROLL_HEAD:
                            // treating holds and rolls the same
                            latestSection.sectionNotes.push( [ (strumtime - offset)*1000, columnIndex ] );
                            holdtracker.set(columnIndex, latestSection.sectionNotes[latestSection.sectionNotes.length - 1]);
                        case SMUtils.NOTE_TAIL:
                            var holdhead = holdtracker.get(columnIndex);
                            if(holdhead != null)
                            {
                                holdhead.push((strumtime-offset)*1000 - holdhead[0]);
                                holdtracker.remove(columnIndex);
                            }
                            else
                            {
                                trace('[ERROR] Encountered tail $notevalue with no head!');
                            }
                    }
                }

                var beatsperrow = SMUtils.getBeatsPerRow(measure);
                beatnum += beatsperrow;
                var nextbpm = SMUtils.bpmFromMap(bpmmap, beatnum);
                if(nextbpm != curbpm)
                {
                    // trace('BPM change from $curbpm to $nextbpm at measure: $measure_num , row: $rownum , beat: $beatnum , strumtime: $strumtime');
                    change_bpm = true;
                    sections.push(SMUtils.makeSwagSection(nextbpm, change_bpm, flipChart));
                }
                else
                {
                    change_bpm = false;
                }

                strumtime = beatnum * 60/curbpm;
                curbpm = nextbpm;
            }
        }

        return sections;
    }

    inline static function _cleanMetadata(str:String)
    {
        var arr = str.trim().split('\n');
        return arr[arr.length - 1];
    }

    public function toString()
    {
        return '$chartType - $difficulty - $numericalMeter by $author (${n_keys}k chart)';
    }
}