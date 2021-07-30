package;

import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import openfl.Assets;

using StringTools;

class Caching extends MusicBeatState
{
    var toBeDone = 0;
    var done = 0;
	var curFunny:Array<String>;
	var loadSyn:FlxSprite;
	var funnyEmote:FlxSprite;

    var text:FlxText;
    var kadeLogo:FlxSprite;

	override function create()
	{
        FlxG.mouse.visible = false;

        FlxG.worldBounds.set(0,0);
		curFunny = FlxG.random.getObject(getFunnyMichael());

		funnyEmote = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('loadingemotes/pisscry'));
		funnyEmote.antialiasing = true;
        funnyEmote.visible = false;
		funnyEmote.setGraphicSize(Std.int(funnyEmote.width));
		funnyEmote.updateHitbox();
        funnyEmote.x = 100;
        funnyEmote.y = 610;

		loadSyn = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('LoadSyntech'));
		loadSyn.frames = Paths.getSparrowAtlas('LoadSyntech');
		loadSyn.animation.addByPrefix('bump', 'Loader', 60, true);
		loadSyn.antialiasing = true;
		loadSyn.setGraphicSize(Std.int(loadSyn.width));
		loadSyn.updateHitbox();
		loadSyn.animation.play('bump');
        loadSyn.x = 25;
        loadSyn.y = 170;

        text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300,0,"Loading...");
		text.setFormat(Paths.font("Petitinho.ttf"), 34);
        //text.color = FlxColor.GREEN;
        //text.size = 34; it was already defined lol
        text.alignment = FlxTextAlign.CENTER;
        text.alpha = 0;
        text.x = 25;
        text.y = 610;

        kadeLogo = new FlxSprite(0, 0).loadGraphic(Paths.image('SUSSY_LOADING')); //We get it kade dev

        loadSyn.alpha = 0;
        kadeLogo.alpha = 0;

        add(kadeLogo);
        add(text);
		add(loadSyn);
		add(funnyEmote);

        trace('starting caching..');
        
        sys.thread.Thread.create(() -> {
            cache();
        });


        super.create();
    }

	function getFunnyMichael():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('LoadingTextBy4Axion'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

    var calledDone = false;

    override function update(elapsed) 
    {

        if (toBeDone != 0 && done != toBeDone)
        {
            var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;
            kadeLogo.alpha = alpha;
            text.alpha = alpha;
            loadSyn.alpha = alpha;
            if(done >= 45)
            {
                if (curFunny[1] == "pisscry")
                    {
                        funnyEmote.visible = true;
                        text.text = "Loading... (" + Std.string(flixel.math.FlxMath.roundDecimal(done / toBeDone * 100, 0)) + "%) ";
                    }
                else if (curFunny[1] == "Sustech")
                    {
                        PlayState.AMOGUS = true;
                        text.text = "Loading... (" + Std.string(flixel.math.FlxMath.roundDecimal(done / toBeDone * 100, 0)) + "%) " + curFunny[1];
                    }
                else
                    {
                        text.text = "Loading... (" + Std.string(flixel.math.FlxMath.roundDecimal(done / toBeDone * 100, 0)) + "%) " + curFunny[1];
                    }
            }
            else
            {
                text.text = "Loading... (" + Std.string(flixel.math.FlxMath.roundDecimal(done / toBeDone * 100, 0)) + "%) " + curFunny[0];
            }
        }

        super.update(elapsed);
    }


    function cache()
    {

        var images = [];
        var music = [];

        trace("caching images...");

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
        {
            if (!i.endsWith(".png"))
                continue;
            images.push(i);
        }
        Sys.sleep(0.1);

        trace("caching music...");

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
        {
            music.push(i);
        }
        Sys.sleep(0.1);

        toBeDone = Lambda.count(images) + Lambda.count(music);

        trace("LOADING: " + toBeDone + " OBJECTS.");

        for (i in images)
        {
            var replaced = i.replace(".png","");
            FlxG.bitmap.add(Paths.image("characters/" + replaced,"shared"));
            trace("cached " + replaced);
            done++;
        }
        Sys.sleep(0.1);

        for (i in music)
        {
            FlxG.sound.cache(Paths.inst(i));
            FlxG.sound.cache(Paths.voices(i));
            trace("cached " + i);
            done++;
        }

        trace("Finished caching...");

        FlxG.switchState(new TitleState());
    }

}