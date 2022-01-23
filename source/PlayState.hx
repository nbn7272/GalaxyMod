package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.Lib;
import flixel.system.scaleModes.FixedScaleMode;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var mania:Int = 0;
	public static var keyAmmo:Array<Int> = [4, 6, 9];

	public static var misses:Int = 0;
	public static var maxc:Int = 0;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	private var hits:Float = 0.00;
	private var total:Float = 0;
	private var acc:Float = 0.00;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var whitefg:FlxSprite;
	var shine:Array<Float>;
	var shinetime:Int;
	var blbg:FlxSprite;
	var hexes:FlxTypedGroup<FlxSprite>;
	var kasti1:FlxSprite;
	var kasti2:FlxSprite;
	var sky0:FlxSprite;
	var ground0:FlxSprite;
	var city0:FlxSprite;
	var fg0:FlxSprite;
	var ufo:FlxSprite;
	var ufoy:Float;
	var anime:FlxSprite;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	
	var planets:FlxTypedGroup<FlxSprite>;
	var earth:FlxSprite;

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	public static var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{
		if (SONG.song.toLowerCase() == "senpai" || SONG.song.toLowerCase() == "roses" || SONG.song.toLowerCase() == "thorns")
			daPixelZoom = 6;
		else
			daPixelZoom = 1;
		
		if(SONG.song.toLowerCase() == "cyber" && storyDifficulty != 0)
			PlayWindow.reset();
		PlayWindow.nreset();
		PlayMoving.reset();
		misses = 0;
		acc = 0.00;
		hits = 0;
		total = 0;
		maxc = 0;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		mania = SONG.mania;

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			case 'galaxy':
				dialogue = CoolUtil.coolTextFile(Paths.txt('galaxy/galaxyDialogue'));
			case 'game':
				dialogue = CoolUtil.coolTextFile(Paths.txt('game/gameDialogue'));
			case 'kastimagina':
				dialogue = CoolUtil.coolTextFile(Paths.txt('kastimagina/kastimaginaDialogue'));
			case 'cona':
				dialogue = CoolUtil.coolTextFile(Paths.txt('cona/conaDialogue1'));
			case 'underworld':
				dialogue = CoolUtil.coolTextFile(Paths.txt('underworld/underworldDialogue'));
			case 'cyber':
				dialogue = CoolUtil.coolTextFile(Paths.txt('cyber/cyberDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			if(storyWeek == 7)
				detailsText = "Story Mode: Week S";
			else if(storyWeek == 8)
				detailsText = "Story Mode: Week K";
			else
				detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		defaultCamZoom = 1.05;
		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }
		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                          var posY = 200;

		                  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
		                           fg.scale.set(6, 6);
		                           // fg.setGraphicSize(Std.int(fg.width * 6));
		                           // fg.updateHitbox();
		                           add(fg);

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;
		                    */

		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /* 
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */
		          }
				  case 'galaxy' | "game" | "kastimagina": 
                    {
		              curStage = 'ship';
		              var bg:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('ship/space'));
		              bg.scrollFactor.set(0.1, 0.1);
		              add(bg);
		              planets = new FlxTypedGroup<FlxSprite>();
		              add(planets);
		              for (i in 1...4)
		              {
		                      var light:FlxSprite = new FlxSprite(-600,-360).loadGraphic(Paths.image('ship/star' + i));
		                      light.scrollFactor.set(0.1, 0.1);
		                      light.visible = i == 1;
		                      light.antialiasing = true;
		                      planets.add(light);
		              }
					  earth = new FlxSprite(-650,-360);
		                  earth.frames = Paths.getSparrowAtlas('ship/earth');
		                  earth.animation.addByPrefix('bump', "earth bump", 24, false);
		                  earth.antialiasing = true;
		                  earth.scrollFactor.set(0.2, 0.2);
		                  earth.updateHitbox();
		                  add(earth);
					  var wall:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('ship/wall'));
		              wall.scrollFactor.set(0.9, 0.9);
		              add(wall);
					  var fg:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('ship/front'));
		              fg.scrollFactor.set(1, 1);
		              add(fg);
		          }
				  case 'cona' | 'underworld' | 'cyber':
				  {
					  curStage = "cona";
					  defaultCamZoom = 0.85;
					  if(SONG.song.toLowerCase() == "cyber")
					  {
					  	var sky:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/sky'));
						sky.scrollFactor.set(0.1, 0.1);
						add(sky); 
						var city:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/city'));
						city.scrollFactor.set(0.3, 0.3);
						add(city);
						ufo = new FlxSprite(1200,300).loadGraphic(Paths.image('cor/ufo'));
						ufo.scrollFactor.set(0.5, 0.5);
						ufo.antialiasing = true;
						add(ufo);
						var ground:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/rock'));
						ground.scrollFactor.set(0.9, 0.9);
						add(ground);
						var fg:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/ground'));
						fg.scrollFactor.set(1, 1);
						add(fg);
					  }
					  else
					  {
						var sky:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/sky0'));
						sky.scrollFactor.set(0.1, 0.1);
						add(sky); 
						sky0 = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/sky'));
						sky0.scrollFactor.set(0.1, 0.1);
						sky0.alpha = 0;
						add(sky0); 
						var city:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/city0'));
						city.scrollFactor.set(0.3, 0.3);
						add(city);
						city0 = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/city'));
						city0.scrollFactor.set(0.3, 0.3);
						city0.alpha = 0;
						add(city0);
						ufo = new FlxSprite(1200,300).loadGraphic(Paths.image('cor/ufo'));
						ufo.scrollFactor.set(0.5, 0.5);
						ufo.antialiasing = true;
						add(ufo);
						var ground:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/rock0'));
						ground.scrollFactor.set(0.9, 0.9);
						add(ground);
						ground0 = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/rock'));
						ground0.scrollFactor.set(0.9, 0.9);
						ground0.alpha = 0;
						add(ground0);
						var fg:FlxSprite = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/ground0'));
						fg.scrollFactor.set(1, 1);
						add(fg);
						fg0 = new FlxSprite(-600,-300).loadGraphic(Paths.image('cor/ground'));
						fg0.scrollFactor.set(1, 1);
						fg0.alpha = 0;
						add(fg0);
					  }
					  if(SONG.song.toLowerCase() == "underworld")
					  {
							blbg = new FlxSprite(-600, -300).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
							blbg.scrollFactor.set(1,1);
							blbg.alpha = 0;
							add(blbg);
							hexes = new FlxTypedGroup<FlxSprite>();
							add(hexes);
					  }
				  }
		          default:
		          {
		                  defaultCamZoom = 0.9;
		                  curStage = 'stage';
		                  var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);
		          }
              }

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'cona':
				gfVersion = 'gf-twin';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'kastimagina':
				camPos.x += 600;
				dad.y += 350;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'kalisa':
				dad.x -= 170;
				dad.y += 200;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'cona':
				boyfriend.x += 300;
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.unfinish = cutscene;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 480, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if(SONG.song.toLowerCase() == "kastimagina" && storyDifficulty != 0)
		{
			whitefg = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFffffff);
			whitefg.scrollFactor.set();
			whitefg.alpha = 0;
			add(whitefg);
			whitefg.cameras = [camHUD];
			shine = [2651.9337016574586,2983.425414364641,3314.9171270718234,3646.4088397790056,
				3977.9005524861877,4309.39226519337,4640.883977900552,4972.375690607734,5303.867403314917,
				5635.359116022099,5966.850828729282,6298.342541436465,6629.834254143647,6961.325966850829,
				7292.817679558011,7624.309392265193,7955.801104972376,8287.29281767956,8618.784530386742,
				8950.276243093924,9281.767955801106,9613.259668508288,9944.75138121547,10276.243093922652,
				10607.734806629835,10939.226519337017,11270.718232044199,11602.209944751381,11933.701657458563,
				12265.193370165745,12596.685082872928,12928.17679558011,13259.668508287292,23867.403314917123,
				45082.87292817678,46408.83977900551,47734.80662983424,49060.77348066297,49723.75690607733,
				50386.740331491696,51712.707182320424,53038.67403314915,54364.64088397788,55027.624309392246,
				55690.60773480661,57016.57458563534,58342.54143646407,59668.508287292796,60331.49171270716,
				60662.98342541434,60994.475138121525,62320.44198895025,63646.40883977898,64972.37569060771,
				65635.35911602208,65966.85082872926,66298.34254143645,82209.94475138119,103425.41436464085,
				124640.8839779005,135248.61878453035,136574.58563535908,137900.5524861878,139226.51933701654,
				139889.5027624309,140552.48618784526,141878.453038674,143204.41988950272,144530.38674033145,
				145193.37016574582,145856.35359116018,147182.3204419889,148508.28729281764,149834.25414364637,
				150497.23756906073,151160.2209944751,152486.18784530382,153812.15469613255,155138.12154696128,
				155801.10497237564,156464.08839779,156795.5801104972,157127.07182320437,157458.56353591155,
				157790.05524861874,158121.54696132592,158453.0386740331,158784.53038674028,159116.02209944747,
				159447.51381215465,159779.00552486183,160110.497237569,160441.9889502762,160773.48066298338,
				161104.97237569056,161436.46408839774,161767.95580110492,162099.4475138121,162430.9392265193,
				162762.43093922647,163093.92265193365,163425.41436464083,163756.90607734802,164088.3977900552,
				164419.88950276238,164751.38121546956,165082.87292817674,165414.36464088393,165745.8563535911,
				166077.3480662983,166408.83977900547,166740.33149171266
			];
			shinetime = 0;
		}
		if(SONG.song.toLowerCase() == "cyber" && storyDifficulty != 0)
		{
			if(storyDifficulty == 1)
			  	kasti1 = new FlxSprite(-240,400).loadGraphic(Paths.image('cor/war'));
			else
			  	kasti1 = new FlxSprite(-240,400).loadGraphic(Paths.image('cor/war1'));
			kasti1.scrollFactor.set();
			kasti1.antialiasing = true;
			add(kasti1);
			kasti1.cameras = [camHUD];
			if(storyDifficulty == 1)
			  	kasti2 = new FlxSprite(-240,400).loadGraphic(Paths.image('cor/war0'));
			else
			  	kasti2 = new FlxSprite(-240,400).loadGraphic(Paths.image('cor/war2'));
			kasti2.scrollFactor.set();
			kasti2.antialiasing = true;
			add(kasti2);
			kasti2.cameras = [camHUD];
		}

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'galaxy':
					schoolIntro(doof);
				case 'game':
					schoolIntro(doof);
				case 'kastimagina':
					schoolIntro(doof);
				case 'cona':
					schoolIntro(doof);
				case 'underworld':
					schoolIntro(doof);
				case 'cyber':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox,numbbb:Int = 0):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (
			SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns' || 
			SONG.song.toLowerCase() == "galaxy" || SONG.song.toLowerCase() == "game" || SONG.song.toLowerCase() == "kastimagina" || 
			SONG.song.toLowerCase() == "cona" || SONG.song.toLowerCase() == "underworld" || SONG.song.toLowerCase() == "cyber"
		)
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}
		if(SONG.song.toLowerCase() == "cona" && numbbb == 0)
		{
			anime = new FlxSprite(0,0).loadGraphic(Paths.image('cor/anime'));
			anime.antialiasing = true;
			anime.cameras = [camHUD];
			add(anime);
		}
		if(SONG.song.toLowerCase() == "cyber")
		{
			anime = new FlxSprite(0,0).loadGraphic(Paths.image('cor/goodpic'));
			anime.antialiasing = true;
			anime.cameras = [camHUD];
			add(anime);
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function cutscene():Void
	{
		switch(SONG.song.toLowerCase())
		{
			case "cona":
				remove(anime);
				var sddd:Array<String> = CoolUtil.coolTextFile(Paths.txt('cona/conaDialogue2'));
				var sth:DialogueBox = new DialogueBox(false, sddd, 1);
				sth.scrollFactor.set();
				sth.finishThing = startCountdown;
				sth.cameras = [camHUD];
				schoolIntro(sth,1);
			case "cyber":
				remove(anime);
				startCountdown();
		}
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
						FlxG.sound.play(Paths.sound('intro3-pixel'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
						FlxG.sound.play(Paths.sound('intro2-pixel'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
						FlxG.sound.play(Paths.sound('intro1-pixel'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
						FlxG.sound.play(Paths.sound('introGo-pixel'), 0.6);
					else
						FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;
		var randoms:Array<Int> = [];
		var randtime:Int = 0;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % keyAmmo[mania]);

				var gottaHitNote:Bool = section.mustHitSection;

				if ((songNotes[1] > keyAmmo[mania] - 1 && songNotes[1] < 10) ||(songNotes[1] >= 10 && songNotes[1] % 10 == 5))
				{
					gottaHitNote = !section.mustHitSection;
				}

				switch Std.int(songNotes[1] / 10)
				{
					case 1:
						daNoteData = FlxG.random.int(0,3);
						randoms.push(daNoteData);
					case 2:
						daNoteData = randoms[randtime];
						randtime += 1;
					case 3:
						daNoteData = FlxG.random.int(0,3);
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int,type:String="null",twe:Bool = true):Void
	{
		for (i in 0...keyAmmo[mania])
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			if (type == "kali")
			{
				babyArrow.frames = Paths.getSparrowAtlas('cor/cyber');
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.antialiasing = true;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

				var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				var pPre:Array<String> = ['left', 'down', 'up', 'right'];
				switch (mania)
				{
					case 1:
						nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
						pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
					case 2:
						nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
						pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
						babyArrow.x -= Note.tooMuch;
				}
				babyArrow.x += Note.swagWidth * i;
				babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
				babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
				babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
			}
			else
			{
				switch (curStage)
				{
					case 'school' | 'schoolEvil':
						babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
						babyArrow.animation.add('green', [6]);
						babyArrow.animation.add('red', [7]);
						babyArrow.animation.add('blue', [5]);
						babyArrow.animation.add('purplel', [4]);

						babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
						babyArrow.updateHitbox();
						babyArrow.antialiasing = false;

						switch (Math.abs(i))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.add('static', [0]);
								babyArrow.animation.add('pressed', [4, 8], 12, false);
								babyArrow.animation.add('confirm', [12, 16], 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.add('static', [1]);
								babyArrow.animation.add('pressed', [5, 9], 12, false);
								babyArrow.animation.add('confirm', [13, 17], 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.add('static', [2]);
								babyArrow.animation.add('pressed', [6, 10], 12, false);
								babyArrow.animation.add('confirm', [14, 18], 12, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.add('static', [3]);
								babyArrow.animation.add('pressed', [7, 11], 12, false);
								babyArrow.animation.add('confirm', [15, 19], 24, false);
						}

					default:
						babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
						babyArrow.animation.addByPrefix('green', 'arrowUP');
						babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
						babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
						babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

						babyArrow.antialiasing = true;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

						var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
						var pPre:Array<String> = ['left', 'down', 'up', 'right'];
						switch (mania)
						{
							case 1:
								nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
								pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
							case 2:
								nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
								pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
								babyArrow.x -= Note.tooMuch;
						}
						babyArrow.x += Note.swagWidth * i;
						babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
						babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
						babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
						
						
				}
			}
			

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode && twe)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
			case "cona":
				updateUFO();
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}
		switch(SONG.song.toLowerCase())
		{
			case "kastimagina":
				if(storyDifficulty != 0)
				{
					if(shinetime < shine.length && Conductor.songPosition >= shine[shinetime])
					{
						whitefg.alpha = 1;
						shinetime += 1;
					}
					updatewhite();
				}
			case "underworld":
				sky0.alpha = Conductor.songPosition/157784.81012658245;
				city0.alpha = Conductor.songPosition/157784.81012658245;
				ground0.alpha = Conductor.songPosition/157784.81012658245;
				fg0.alpha = Conductor.songPosition/157784.81012658245;
				hexes.forEachAlive(function(dahex:FlxSprite)
				{
					dahex.y -= 5;
					dahex.angle += 2;
					if(blbg.alpha == 1)
						dahex.alpha = 1;
					else
						dahex.alpha = 0;
					if (dahex.y < -300)
					{
						dahex.kill();
						hexes.remove(dahex, true);
						dahex.destroy();
					}
				});
			case "cyber":
				if(storyDifficulty != 0)
				{
					if (Conductor.songPosition > 60000)
						kasti1.alpha = 0;
					else if (Conductor.songPosition >= 56629.213483146064 && kasti1.x < 10)
						kasti1.x += 5;
					if (Conductor.songPosition > 136179.7752808992)
						kasti2.alpha = 0;
					else if (Conductor.songPosition >= 132134.8314606745 && kasti2.x < 10)
						kasti2.x += 5;
				}
		}

		super.update(elapsed);

		scoreTxt.text = "Score:" + songScore + " | MaxCombo:" + maxc + " | Misses:" + misses + " | Accuracy:" + acc + "%";
		
		if(SONG.song.toLowerCase() == "cyber" && storyDifficulty != 0)
			PlayWindow.move(camHUD);

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			
			if(SONG.song.toLowerCase() == "cyber" && storyDifficulty != 0)
				PlayWindow.back(camHUD);

			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(PlayWindow.camz, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			if(SONG.song.toLowerCase() == "cyber" && storyDifficulty != 0)
				PlayWindow.back(camHUD);

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 5000)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}


		strumLineNotes.forEachAlive(function(dastrum:FlxSprite)
		{
			PlayMoving.spos(dastrum,strumLine);
		});
		playerStrums.forEachAlive(function(dastrum:FlxSprite)
		{
			PlayMoving.pspos(dastrum,strumLine);
		});

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (PlayMoving.show(daNote))
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				PlayMoving.pos(daNote,strumLine);

				if(daNote.isSustainNote)
				{
					if(PlayMoving.ups(daNote,strumLine) == 1)
					{
						if(daNote.animation.curAnim.name.endsWith('end'))
							daNote.y += daNote.height;
						daNote.flipY = true;
					}
					else
						daNote.flipY = false;
					daNote.clipRect = null;
				}
				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& ((PlayMoving.ups(daNote,strumLine) == 1 && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= PlayMoving.stry(daNote,strumLine) + Note.swagWidth / 2) || 
					(PlayMoving.ups(daNote,strumLine) == 2 && daNote.y + daNote.offset.y <= PlayMoving.stry(daNote,strumLine) + Note.swagWidth / 2) ||
					(PlayMoving.ups(daNote,strumLine) == 0 && daNote.x + daNote.offset.x <= PlayMoving.stry(daNote,strumLine) + Note.swagWidth / 2) ||
					(PlayMoving.ups(daNote,strumLine) == 3 && daNote.x - daNote.offset.x * daNote.scale.y + daNote.height >= PlayMoving.stry(daNote,strumLine) + Note.swagWidth / 2))
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, PlayMoving.stry(daNote,strumLine) + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					switch(PlayMoving.ups(daNote,strumLine))
					{
						case 0:
							swagRect.y = PlayMoving.stry(daNote,strumLine) + Note.swagWidth / 2 - daNote.x;
							swagRect.x /= daNote.scale.y;
							swagRect.height -= swagRect.y;
						case 1:
							swagRect.height = (PlayMoving.stry(daNote,strumLine) + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
						case 2:
							swagRect.y /= daNote.scale.y;
							swagRect.height -= swagRect.y;
						case 3:
							swagRect.height = (PlayMoving.stry(daNote,strumLine) + Note.swagWidth / 2 - daNote.x) / daNote.scale.y;
							swagRect.y = daNote.frameWidth - swagRect.height;
					}

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (mania == 0)
						{
							switch (Math.abs(daNote.noteData))
							{
								case 2:
									dad.playAnim('singUP' + altAnim, true);
								case 3:
									dad.playAnim('singRIGHT' + altAnim, true);
								case 1:
									dad.playAnim('singDOWN' + altAnim, true);
								case 0:
									dad.playAnim('singLEFT' + altAnim, true);
							}
						}
						else if (mania == 1)
						{
							switch (Math.abs(daNote.noteData))
							{
								case 1:
									dad.playAnim('singUP' + altAnim, true);
								case 0:
									dad.playAnim('singLEFT' + altAnim, true);
								case 2:
									dad.playAnim('singRIGHT' + altAnim, true);
								case 3:
									dad.playAnim('singLEFT' + altAnim, true);
								case 4:
									dad.playAnim('singDOWN' + altAnim, true);
								case 5:
									dad.playAnim('singRIGHT' + altAnim, true);
							}
						}
						else
						{
							switch (Math.abs(daNote.noteData))
							{
								case 0:
									dad.playAnim('singLEFT' + altAnim, true);
								case 1:
									dad.playAnim('singDOWN' + altAnim, true);
								case 2:
									dad.playAnim('singUP' + altAnim, true);
								case 3:
									dad.playAnim('singRIGHT' + altAnim, true);
								case 4:
									dad.playAnim('singUP' + altAnim, true);
								case 5:
									dad.playAnim('singLEFT' + altAnim, true);
								case 6:
									dad.playAnim('singDOWN' + altAnim, true);
								case 7:
									dad.playAnim('singUP' + altAnim, true);
								case 8:
									dad.playAnim('singRIGHT' + altAnim, true);
							}
						}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (PlayMoving.kill(daNote))
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.0475;//0.0475
						if(!daNote.isSustainNote)
						{
							misses += 1;
						}
						total += 1;
						acc = hits / total * 100;
						acc = Math.round(acc*100) / 100;
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
		}
		if(SONG.song.toLowerCase() == "cyber" && storyDifficulty != 0)
			PlayWindow.back(camHUD);

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		var inc:Float = 1.0;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
			inc = 0.1;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
			inc = 0.25;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			inc = 0.8;
		}

		songScore += score;
		hits += inc;
		total += 1;
		acc = hits / total * 100;
		acc = Math.round(acc*100) / 100;
		if (combo > maxc)
		{
			maxc = combo;
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var l1 = controls.L1;
		var u = controls.U1;
		var r1 = controls.R1;
		var l2 = controls.L2;
		var d = controls.D1;
		var r2 = controls.R2;

		var l1P = controls.L1_P;
		var uP = controls.U1_P;
		var r1P = controls.R1_P;
		var l2P = controls.L2_P;
		var dP = controls.D1_P;
		var r2P = controls.R2_P;

		var l1R = controls.L1_R;
		var uR = controls.U1_R;
		var r1R = controls.R1_R;
		var l2R = controls.L2_R;
		var dR = controls.D1_R;
		var r2R = controls.R2_R;


		var n0 = controls.N0;
		var n1 = controls.N1;
		var n2 = controls.N2;
		var n3 = controls.N3;
		var n4 = controls.N4;
		var n5 = controls.N5;
		var n6 = controls.N6;
		var n7 = controls.N7;
		var n8 = controls.N8;

		var n0P = controls.N0_P;
		var n1P = controls.N1_P;
		var n2P = controls.N2_P;
		var n3P = controls.N3_P;
		var n4P = controls.N4_P;
		var n5P = controls.N5_P;
		var n6P = controls.N6_P;
		var n7P = controls.N7_P;
		var n8P = controls.N8_P;

		var n0R = controls.N0_R;
		var n1R = controls.N1_R;
		var n2R = controls.N2_R;
		var n3R = controls.N3_R;
		var n4R = controls.N4_R;
		var n5R = controls.N5_R;
		var n6R = controls.N6_R;
		var n7R = controls.N7_R;
		var n8R = controls.N8_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		var ankey = (upP || rightP || downP || leftP);
		if (mania == 1)
		{ 
			ankey = (l1P || uP || r1P || l2P || dP || r2P);
			controlArray = [l1P, uP, r1P, l2P, dP, r2P];
		}
		else if (mania == 2)
		{
			ankey = (n0P || n1P || n2P || n3P || n4P || n5P || n6P || n7P || n8P);
			controlArray = [n0P, n1P, n2P, n3P, n4P, n5P, n6P, n7P, n8P];
		}
		if (ankey && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote, true);

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote, true);
					}
					else
					{
						var dafirst:Bool = true;
						for (coolNote in possibleNotes)
						{
							var checkbadd:Bool = false;
							if (dafirst)
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...4)
								{
									if(controlArray[shit])
									{
										for (stupid in ignoreList)
										{
											if (shit==stupid)
												inIgnoreList = true;
										}
										if(!inIgnoreList)
											checkbadd = true;
									}
								}
							}
							noteCheck(controlArray[coolNote.noteData], coolNote, checkbadd);
							dafirst = false;
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote, true);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}

					//this is already done in noteCheck / goodNoteHit
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				 */
			}
			else
			{
				badNoteCheck();
			}
		}

		var condition = ((up || right || down || left) && !boyfriend.stunned && generatedMusic);
		if (mania == 1)
		{
			condition = ((l1 || u || r1 || l2 || d || r2) && !boyfriend.stunned && generatedMusic);
		}
		else if (mania == 2)
		{
			condition = ((n0 || n1 || n2 || n3 || n4 || n5 || n6 || n7 || n8) && !boyfriend.stunned && generatedMusic);
		}
		if (condition)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					if (mania == 0)
					{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 2:
									if (up)
										goodNoteHit(daNote);
								case 3:
									if (right)
										goodNoteHit(daNote);
								case 1:
									if (down)
										goodNoteHit(daNote);
								case 0:
									if (left)
										goodNoteHit(daNote);
							}
					}
					else if (mania == 1)
					{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 0:
									if (l1)
										goodNoteHit(daNote);
								case 1:
									if (u)
										goodNoteHit(daNote);
								case 2:
									if (r1)
										goodNoteHit(daNote);
								case 3:
									if (l2)
										goodNoteHit(daNote);
								case 4:
									if (d)
										goodNoteHit(daNote);
								case 5:
									if (r2)
										goodNoteHit(daNote);
							}
					}
					else
					{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 0: if (n0) goodNoteHit(daNote);
								case 1: if (n1) goodNoteHit(daNote);
								case 2: if (n2) goodNoteHit(daNote);
								case 3: if (n3) goodNoteHit(daNote);
								case 4: if (n4) goodNoteHit(daNote);
								case 5: if (n5) goodNoteHit(daNote);
								case 6: if (n6) goodNoteHit(daNote);
								case 7: if (n7) goodNoteHit(daNote);
								case 8: if (n8) goodNoteHit(daNote);
							}
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (mania == 0)
			{
					switch (spr.ID)
					{
						case 2:
							if (upP && spr.animation.curAnim.name != 'confirm')
							{
								spr.animation.play('pressed');
								trace('play');
							}
							if (upR)
							{
								spr.animation.play('static');
								
							}
						case 3:
							if (rightP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (rightR)
							{
								spr.animation.play('static');
								
							}
						case 1:
							if (downP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (downR)
							{
								spr.animation.play('static');
								
							}
						case 0:
							if (leftP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (leftR)
							{
								spr.animation.play('static');
								
							}
					}
			}
			else if (mania == 1)
			{
					switch (spr.ID)
					{
						case 0:
							if (l1P && spr.animation.curAnim.name != 'confirm')
							{
								spr.animation.play('pressed');
								trace('play');
							}
							if (l1R)
							{
								spr.animation.play('static');
								
							}
						case 1:
							if (uP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (uR)
							{
								spr.animation.play('static');
								
							}
						case 2:
							if (r1P && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (r1R)
							{
								spr.animation.play('static');
								
							}
						case 3:
							if (l2P && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (l2R)
							{
								spr.animation.play('static');
								
							}
						case 4:
							if (dP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (dR)
							{
								spr.animation.play('static');
								
							}
						case 5:
							if (r2P && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (r2R)
							{
								spr.animation.play('static');
								
							}
					}
			}
			else if (mania == 2)
			{
					switch (spr.ID)
					{
						case 0:
							if (n0P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n0R) spr.animation.play('static');
						case 1:
							if (n1P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n1R) spr.animation.play('static');
						case 2:
							if (n2P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n2R) spr.animation.play('static');
						case 3:
							if (n3P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n3R) spr.animation.play('static');
						case 4:
							if (n4P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n4R) spr.animation.play('static');
						case 5:
							if (n5P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n5R) spr.animation.play('static');
						case 6:
							if (n6P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n6R) spr.animation.play('static');
						case 7:
							if (n7P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n7R) spr.animation.play('static');
						case 8:
							if (n8P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n8R) spr.animation.play('static');
					}
			}

			if (spr.animation.curAnim.name=='confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0;//0.04
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 4:
					boyfriend.playAnim('singDOWNmiss', true);
				case 5:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 6:
					boyfriend.playAnim('singDOWNmiss', true);
				case 7:
					boyfriend.playAnim('singUPmiss', true);
				case 8:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var l1P = controls.L1_P;
			var uP = controls.U1_P;
			var r1P = controls.R1_P;
			var l2P = controls.L2_P;
			var dP = controls.D1_P;
			var r2P = controls.R2_P;

			var n0P = controls.N0_P;
			var n1P = controls.N1_P;
			var n2P = controls.N2_P;
			var n3P = controls.N3_P;
			var n4P = controls.N4_P;
			var n5P = controls.N5_P;
			var n6P = controls.N6_P;
			var n7P = controls.N7_P;
			var n8P = controls.N8_P;
			
			if (mania == 0)
			{
				if (leftP)
					noteMiss(0);
				if (upP)
					noteMiss(2);
				if (rightP)
					noteMiss(3);
				if (downP)
					noteMiss(1);
			}
			else if (mania == 1)
			{
				if (l1P)
					noteMiss(0);
				else if (uP)
					noteMiss(1);
				else if (r1P)
					noteMiss(2);
				else if (l2P)
					noteMiss(3);
				else if (dP)
					noteMiss(4);
				else if (r2P)
					noteMiss(5);
			}
			else
			{
				if (n0P) noteMiss(0);
				if (n1P) noteMiss(1);
				if (n2P) noteMiss(2);
				if (n3P) noteMiss(3);
				if (n4P) noteMiss(4);
				if (n5P) noteMiss(5);
				if (n6P) noteMiss(6);
				if (n7P) noteMiss(7);
				if (n8P) noteMiss(8);
			}
	}

	function noteCheck(keyP:Bool, note:Note,checkbad:Bool):Void
	{
		if (keyP)
			goodNoteHit(note);
		else if(checkbad)
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}
			else
			{
				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
				var rating:FlxSprite = new FlxSprite();
				hits += 1;
				total += 1;
				acc = hits / total * 100;
				acc = Math.round(acc*100) / 100;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			if (mania == 1)
			{
				sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
			}
			else if (mania == 2)
			{
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
			}

			boyfriend.playAnim('sing' + sDir[note.noteData], true);

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm'+PlayMoving.ns, true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}
	function updateUFO():Void
	{
		ufo.x -= 0.4;
		ufo.y = ufoy + 10 * FlxMath.fastSin(Conductor.songPosition/500);
		if(ufo.x < -800)
		{
			ufo.x = 1200;
			ufoy = FlxG.random.int(0,500);
		}
	}
	function updatewhite():Void
		{
			if (whitefg.alpha > 0)
			{
				whitefg.alpha -= 0.1; 
			}
		}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function changestrum(type:String)
	{
		remove(strumLineNotes);
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		strumLineNotes.cameras = [camHUD];
		
		generateStaticArrows(0,type,false);
		generateStaticArrows(1,type,false);

		notes.forEachAlive(function(daNote:Note)
		{
			var oriani:String = daNote.animation.curAnim.name;

			if (type == "kali")
				daNote.frames = Paths.getSparrowAtlas('cor/cyber');
			else
				daNote.frames = Paths.getSparrowAtlas('NOTE_assets');
			daNote.animation.addByPrefix('greenScroll', 'green0');
			daNote.animation.addByPrefix('redScroll', 'red0');
			daNote.animation.addByPrefix('blueScroll', 'blue0');
			daNote.animation.addByPrefix('purpleScroll', 'purple0');
			daNote.animation.addByPrefix('whiteScroll', 'white0');
			daNote.animation.addByPrefix('yellowScroll', 'yellow0');
			daNote.animation.addByPrefix('violetScroll', 'violet0');
			daNote.animation.addByPrefix('blackScroll', 'black0');
			daNote.animation.addByPrefix('darkScroll', 'dark0');


			daNote.animation.addByPrefix('purpleholdend', 'pruple end hold');
			daNote.animation.addByPrefix('greenholdend', 'green hold end');
			daNote.animation.addByPrefix('redholdend', 'red hold end');
			daNote.animation.addByPrefix('blueholdend', 'blue hold end');
			daNote.animation.addByPrefix('whiteholdend', 'white hold end');
			daNote.animation.addByPrefix('yellowholdend', 'yellow hold end');
			daNote.animation.addByPrefix('violetholdend', 'violet hold end');
			daNote.animation.addByPrefix('blackholdend', 'black hold end');
			daNote.animation.addByPrefix('darkholdend', 'dark hold end');

			daNote.animation.addByPrefix('purplehold', 'purple hold piece');
			daNote.animation.addByPrefix('greenhold', 'green hold piece');
			daNote.animation.addByPrefix('redhold', 'red hold piece');
			daNote.animation.addByPrefix('bluehold', 'blue hold piece');
			daNote.animation.addByPrefix('whitehold', 'white hold piece');
			daNote.animation.addByPrefix('yellowhold', 'yellow hold piece');
			daNote.animation.addByPrefix('violethold', 'violet hold piece');
			daNote.animation.addByPrefix('blackhold', 'black hold piece');
			daNote.animation.addByPrefix('darkhold', 'dark hold piece');
			
			daNote.animation.play(oriani);
			daNote.setGraphicSize(Std.int(daNote.width * Note.noteScale));
			daNote.updateHitbox();
			if(daNote.isSustainNote)
			{
				daNote.scale.x = Note.noteScale;
				if(daNote.animation.curAnim.name.endsWith('hold'))
					daNote.scale.y = Note.noteScale * Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				else
					daNote.scale.y = Note.noteScale;
				daNote.updateHitbox();
			}
		});
		for (daNote in unspawnNotes)
		{
			var oriani:String = daNote.animation.curAnim.name;

			if (type == "kali")
				daNote.frames = Paths.getSparrowAtlas('cor/cyber');
			else
				daNote.frames = Paths.getSparrowAtlas('NOTE_assets');
			daNote.animation.addByPrefix('greenScroll', 'green0');
			daNote.animation.addByPrefix('redScroll', 'red0');
			daNote.animation.addByPrefix('blueScroll', 'blue0');
			daNote.animation.addByPrefix('purpleScroll', 'purple0');
			daNote.animation.addByPrefix('whiteScroll', 'white0');
			daNote.animation.addByPrefix('yellowScroll', 'yellow0');
			daNote.animation.addByPrefix('violetScroll', 'violet0');
			daNote.animation.addByPrefix('blackScroll', 'black0');
			daNote.animation.addByPrefix('darkScroll', 'dark0');


			daNote.animation.addByPrefix('purpleholdend', 'pruple end hold');
			daNote.animation.addByPrefix('greenholdend', 'green hold end');
			daNote.animation.addByPrefix('redholdend', 'red hold end');
			daNote.animation.addByPrefix('blueholdend', 'blue hold end');
			daNote.animation.addByPrefix('whiteholdend', 'white hold end');
			daNote.animation.addByPrefix('yellowholdend', 'yellow hold end');
			daNote.animation.addByPrefix('violetholdend', 'violet hold end');
			daNote.animation.addByPrefix('blackholdend', 'black hold end');
			daNote.animation.addByPrefix('darkholdend', 'dark hold end');

			daNote.animation.addByPrefix('purplehold', 'purple hold piece');
			daNote.animation.addByPrefix('greenhold', 'green hold piece');
			daNote.animation.addByPrefix('redhold', 'red hold piece');
			daNote.animation.addByPrefix('bluehold', 'blue hold piece');
			daNote.animation.addByPrefix('whitehold', 'white hold piece');
			daNote.animation.addByPrefix('yellowhold', 'yellow hold piece');
			daNote.animation.addByPrefix('violethold', 'violet hold piece');
			daNote.animation.addByPrefix('blackhold', 'black hold piece');
			daNote.animation.addByPrefix('darkhold', 'dark hold piece');
			
			daNote.animation.play(oriani);
			daNote.setGraphicSize(Std.int(daNote.width * Note.noteScale));
			daNote.updateHitbox();
			if(daNote.isSustainNote)
			{
				daNote.scale.x = Note.noteScale;
				if(daNote.animation.curAnim.name.endsWith('hold'))
					daNote.scale.y = Note.noteScale * Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				else
					daNote.scale.y = Note.noteScale;
				daNote.updateHitbox();
			}
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		if (SONG.song.toLowerCase() == "underworld")
		{
			for(i in 0...FlxG.random.int(1,8))
			{
				var newhex:FlxSprite = new FlxSprite(FlxG.random.int(-500,3000), 1500).loadGraphic(Paths.image('cor/hexagon'));
				hexes.add(newhex);
			}
			if(curBeat == 96 || curBeat == 256)
			{
				gf.alpha = 0;
				blbg.alpha = 1;
				remove(boyfriend);
				boyfriend = new Boyfriend(1070, 450, 'bf-pur');
				add(boyfriend);
				remove(dad);
				dad = new Character(-70, 300, "kalisax");
				add(dad);
				changestrum("kali");
			}
			else if(curBeat == 160 || curBeat == 384)
			{
				gf.alpha = 1;
				blbg.alpha = 0;
				remove(boyfriend);
				boyfriend = new Boyfriend(1070, 450, 'bf');
				add(boyfriend);
				remove(dad);
				dad = new Character(-70, 300, "kalisa");
				add(dad);
				changestrum("null");
			}
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case "ship":
				earth.animation.play('bump',true);
				if (curBeat % 4 == 0)
					{
						var vi:Bool = true;
						while(vi)
						{
							planets.forEach(function(light:FlxSprite)
							{
								light.visible = FlxG.random.bool();
								if(light.visible)
									vi = false;
							});
						}
					}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
