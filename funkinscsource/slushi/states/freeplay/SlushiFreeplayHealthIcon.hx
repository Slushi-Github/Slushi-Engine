package slushi.states.freeplay;

import objects.HealthIcon;

class SlushiFreeplayHealthIcon extends HealthIcon
{
    public var songTxtTracker:FlxSprite;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (songTxtTracker != null) {
            setPosition(
                songTxtTracker.x + (songTxtTracker.width / 2) - (this.width / 2) + offsetX,
                songTxtTracker.y - 100 + offsetY
            );
        }
    }
}