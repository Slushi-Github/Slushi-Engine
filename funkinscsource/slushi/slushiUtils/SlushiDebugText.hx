package slushi.slushiUtils;

import flixel.util.FlxGradient;
import flixel.group.FlxGroup;

/**
 * This class is used to print debug texts in the game, like NotITG style.
 */

class SlushiDebugText extends FlxSpriteGroup
{
    static var timeToHide:Float = 6;
    static var cantAddMoreTexts:Bool = false;
    static var camState:FlxCamera;

    public static function printInDisplay(textToPrint:String = "", color:FlxColor = FlxColor.WHITE, time:Float = 6)
    { 
        if(cantAddMoreTexts)
            return;
        cantAddMoreTexts = true;
        timeToHide = time;

        camState = new FlxCamera();
        camState.bgColor.alpha = 0;
        FlxG.cameras.add(camState, false);

        var spriteGrp = new FlxGroup();
        FlxG.state.add(spriteGrp);

        spriteGrp.camera = camState;

        var txtSpriteBG = FlxGradient.createGradientFlxSprite(FlxG.width, 40, [FlxColor.WHITE, FlxColor.BLACK]);
        txtSpriteBG.scrollFactor.set();
        txtSpriteBG.alpha = 0.5;
        spriteGrp.add(txtSpriteBG);

        var text:FlxText = new FlxText(0, 0, FlxG.width - 20, textToPrint);
        text.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.scrollFactor.set();
        text.borderSize = 1.25;
        text.color = color;
        spriteGrp.add(text);

        txtSpriteBG.setPosition(0, 50);
        text.setPosition(60, txtSpriteBG.y + 8);

        FlxTween.tween(text, {x: text.x + 15}, 0.4, {ease: FlxEase.linear});

        logInfo("Text to print: " + textToPrint);

        new FlxTimer().start(timeToHide, function(tmr:FlxTimer)
        {
            FlxTween.tween(txtSpriteBG, {alpha: 0}, 0.4, {ease: FlxEase.linear});
            FlxTween.tween(text, {alpha: 0}, 0.4, {ease: FlxEase.linear, onComplete: function(tween:FlxTween){
                text.destroy();
                txtSpriteBG.destroy();
                FlxG.cameras.remove(camState, false);
                if(spriteGrp != null) FlxG.state.remove(spriteGrp);
                cantAddMoreTexts = false;
            }});
        });
    }
}