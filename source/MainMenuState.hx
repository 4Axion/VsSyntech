package;

import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
#if shaders_supported
#if (openfl >= "8.0.0")
import openfl8.*;
#else
import openfl3.*;
#end
import openfl.filters.ShaderFilter;
import openfl.Lib;
#end


#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	private var filters:Array<BitmapFilter> = [];
	private var uiCamera:flixel.FlxCamera;
	private var filterMap:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}>;
	private var onlyonce1:Bool = false;
	private var onlyonce2:Bool = false;
	private var onlyonce3:Bool = false;
	private var onlyonce4:Bool = false;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.4" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		//YOOOOO COLOR SHIT, LETS GO COLOR BLIND PEOPLE
		
		filterMap = [
			"Invert" => {
				var matrix:Array<Float> = [
					-1,  0,  0, 0, 255,
					 0, -1,  0, 0, 255,
					 0,  0, -1, 0, 255,
					 0,  0,  0, 1,   0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Deuteranopia" => {
				var matrix:Array<Float> = [
					0.43, 0.72, -.15, 0, 0,
					0.34, 0.57, 0.09, 0, 0,
					-.02, 0.03,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Protanopia" => {
				var matrix:Array<Float> = [
					0.20, 0.99, -.19, 0, 0,
					0.16, 0.79, 0.04, 0, 0,
					0.01, -.01,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Tritanopia" => {
				var matrix:Array<Float> = [
					0.97, 0.11, -.08, 0, 0,
					0.02, 0.82, 0.16, 0, 0,
					0.06, 0.88, 0.18, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			}];

			FlxG.camera.setFilters(filters);
			FlxG.game.setFilters(filters);
			
		
			//filters.remove(Grayscale);
	
			FlxG.game.filtersEnabled = true;

			//after color applied

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0x37dfaf;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			if (firstStart)
				FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuItem.y = 60 + (i * 160);
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer + " - Programming by 4Axion - Art by Clownix - Music by NeoBeat", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.save.data.canSplash == null)
			{
				FlxG.save.data.canSplash == true;
			}

		//Copy color filter code lol
		if (FlxG.save.data.filter1)
			{
				if (!onlyonce1)
				{
				filters.push(filterMap.get("Deuteranopia").filter);
				onlyonce1 = true;
				}
			}
			else
			{
				filters.remove(filterMap.get("Deuteranopia").filter);
			}
			if (FlxG.save.data.filter2)
				{
					if (!onlyonce2)
					{
					filters.push(filterMap.get("Protanopia").filter);
					onlyonce2 = true;
					}
				}
				else
				{
					filters.remove(filterMap.get("Protanopia").filter);
				}
				if (FlxG.save.data.filter3)
					{
						if (!onlyonce3)
						{
						filters.push(filterMap.get("Tritanopia").filter);
						onlyonce3 = true;
						}
					}
					else
					{
						filters.remove(filterMap.get("Tritanopia").filter);
					}
					if (FlxG.save.data.filter4)
						{
							if (!onlyonce4)
							{
							filters.push(filterMap.get("Invert").filter);
							onlyonce4 = true;
							}
						}
						else
						{
							filters.remove(filterMap.get("Invert").filter);
						}
						//after color

		if (!selectedSomethin)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'options':
				FlxG.switchState(new OptionsMenu());
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
