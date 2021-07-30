package;

import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
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

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;
	var chalMode:Bool = FreeplayState.isChallenge;

			//CHANGE TO CHALLENGE MENU LOLOLLLLLL --- HALAL HABAB WAS HERE -4AXION AND MODGANG
			var challenges:Array<OptionCategory> = [
				new OptionCategory("Challenges", [
					//new PPSpeed("Arrow speed increases over time"),
					new ContShake("World will shake violently"),
					//new RandomPiss("Some arrows will go super fast while others don't"),
					new HellPer("You don't sick a note? You fucking die."),
					//new Loop("Song will infinately loop and there is no way to finish it."),
					new Degen("Your health will slowly degenerate over time."),
					new Sorry("We'll add more soon!"),
					//new CamZoom("Your camera zooms out really far making it harder to see."),
					//new KeyFuck("Messes with your keys everytime enemy sings"),
					//new DoubleArrows("Arrows have to be clicked twice to do them"),
					//new NoArrows("Arrows are invisible"),
				])
			];


			var options:Array<OptionCategory> = [
				new OptionCategory("Gameplay", [
					new DFJKOption(controls),
					new DownscrollOption("Change the layout of the strumline."),
					new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
					new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
					#if desktop
					new FPSCapOption("Cap your FPS"),
					#end
					new ScrollSpeedOption("Change your scroll speed (1 = Chart dependent)"),
					new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
					new ResetButtonOption("Toggle pressing R to gameover."),
					// new OffsetMenu("Get a note offset based off of your inputs!"),
					new CustomizeGameplay("Drag'n'Drop Gameplay Modules around to your preference")
				]),
				new OptionCategory("Appearance", [
					new NewBF("Allows you to have a cooler mic B)"),
					new PissArrow("Changes the arrow splashes"),
					new Deuteranopia("Applies deuteranopia/red-green filters to view the game"),
					new Protanopia("Applies protanopia/blue-green filters to view the game"),
					new Tritanopia("Applies tritanopia/blue-yellow filters to view the game"),
					new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
					new CamZoomOption("Toggle the camera zoom in-game."),
					#if desktop
					new RainbowFPSOption("Make the FPS Counter Rainbow"),
					new AccuracyOption("Display accuracy information."),
					new NPSDisplayOption("Shows your current Notes Per Second."),
					new SongPositionOption("Show the songs current position (as a bar)"),
					new CpuStrums("CPU's strumline lights up when a note hits it."),
					#end
				]),
				
				new OptionCategory("Misc", [
					#if desktop
					new FPSOption("Toggle the FPS Counter"),
					new ReplayOption("View replays"),
					#end
					new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
					new WatermarkOption("Enable and disable all watermarks from the engine."),
					new ScoreScreen("Show the score screen after the end of a song"),
					new ShowInput("Display every single input in the score screen."),
					new Optimization("No backgrounds, no characters, centered notes, no player 2."),
					new BotPlay("Showcase your charts and mods with autoplay."),
				])
				
			];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;

	private var filters:Array<BitmapFilter> = [];
	private var uiCamera:flixel.FlxCamera;
	private var filterMap:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}>;
	private var onlyonce1:Bool = false;
	private var onlyonce2:Bool = false;
	private var onlyonce3:Bool = false;
	private var onlyonce4:Bool = false;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;
	override function create()
	{	
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		
		filterMap = [
			"Grayscale" => {
				var matrix:Array<Float> = [
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					  0,   0,   0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
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

		if (chalMode)
			{
				menuBG.color = 0xFFbc3823;
			}
		else
			{
				menuBG.color = 0xFFea71fd;
			}
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		if (chalMode)
		{
			for (i in 0...challenges.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, challenges[i].getName(), true, false, true);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			}
		}
		else
		{
			for (i in 0...options.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			}
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)),Std.int(versionShit.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

		super.create();
	}

	var isCat:Bool = false;
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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

		if (acceptInput)
		{
			if (controls.BACK && !isCat)
				{
					if (chalMode)
						{
							chalMode = false;
							FreeplayState.isChallenge = false;
							FlxG.switchState(new FreeplayState());
						}
					else
						{
							FlxG.switchState(new MainMenuState());
						}	
				}
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				if (chalMode)
				{
					for (i in 0...challenges.length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, challenges[i].getName(), true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
				}
				else
				{
					for (i in 0...options.length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
				}
				
				curSelected = 0;
				
				changeSelection(curSelected);
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(1);
				}
			}
			
			if (FlxG.keys.justPressed.UP)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN)
				changeSelection(1);
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
						{
							if (FlxG.keys.pressed.RIGHT)
								currentSelectedCat.getOptions()[curSelected].right();
							if (FlxG.keys.pressed.LEFT)
								currentSelectedCat.getOptions()[curSelected].left();
						}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.offset += 0.1;
						else if (FlxG.keys.justPressed.LEFT)
							FlxG.save.data.offset -= 0.1;
					}
					else if (FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset -= 0.1;
					
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
				else
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;
				
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
		

			if (controls.RESET)
					FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].getDisplay());
						trace(currentSelectedCat.getOptions()[curSelected].getDisplay());
					}
				}
				else
				{
					if (chalMode)
					{
						currentSelectedCat = challenges[curSelected];
					}
					else
					{
						currentSelectedCat = options[curSelected];
					}
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = 0;
				}
				
				changeSelection();
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end
		
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		}
		else
			versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
