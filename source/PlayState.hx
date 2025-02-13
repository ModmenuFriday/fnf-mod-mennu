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

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;
	var songs:Array<String> = [];

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	private var misses:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camHUD2:FlxCamera;
	private var camGame:FlxCamera;
	private var totalPlayed:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	var fc:Bool = true;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	var scoretxtnotmoved:Bool = true;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var cityLights:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;
	var keyP:Bool = false;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var accuracytext:FlxText;
	var sniperenginemark:FlxText;
	var debuginfo:FlxText;
	var debuginfo2:FlxText;
	var debuginfo3:FlxText;
	var debuginfo4:FlxText;
	var debuginfo5:FlxText;
	var debuginfo6:FlxText;
	var debuginfo7:FlxText;
	var debuginfo8:FlxText;
	var debuginfo9:FlxText;
	var debuginfo10:FlxText;
	var debuginfo11:FlxText;
	var debuginfo12:FlxText;
	var debuginfo13:FlxText;
	var debuginfo14:FlxText;
	///that is alot of FlxTexts am i right

	public static var campaignScore:Int = 0;
	public static var ghost:Bool = true;
	public static var debug:Bool = true;
	var notesHit:Float = 0;
	var cpunotesHit:Float = 0;
	var notesnotmissed:Float = 0;
	var notesPassing:Float = 0;
	var baseText2:String = "Current Accuracy: ";
	var baseText:String = " Current Accuracy:";

	var defaultCamZoom:Float = 1.05;

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
		songs = CoolUtil.coolTextFile(Paths.txt('songs'));
		ghost = FlxG.save.data.ghosttapping;
		debug = FlxG.save.data.debug;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD2 = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		if (FlxG.save.data.hideHUD)
			{
				FlxG.cameras.add(camHUD2);
				camHUD2.bgColor.alpha = 0;
				camHUD.visible = false;
			}
			else
				{
					camHUD.visible = true;	
				}

				if (FlxG.save.data.cinematic)
					{
						camHUD.visible = false;
					}

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('ugh');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
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

		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;
							 if (FlxG.save.data.optimizations)
								{
									var hallowTex = Paths.getSparrowAtlas('halloween_bg_opt', 'week2');

									halloweenBG = new FlxSprite(-200, -100);
								    halloweenBG.frames = hallowTex;
									if (FlxG.save.data.antialiasing)
										{
											halloweenBG.antialiasing = true;
										}
										else
											{
												halloweenBG.antialiasing = false;
											}
									halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
									halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
									halloweenBG.animation.play('idle');
									add(halloweenBG);
								}
								else
									{
										var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
							  if (FlxG.save.data.antialiasing)
								{
									halloweenBG.antialiasing = true;
								}
								else
									{
										halloweenBG.antialiasing = false;
									}
	                          add(halloweenBG);
									}

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
		                  bg.scrollFactor.set(0.1, 0.1);
						  if (FlxG.save.data.antialiasing)
							{
								bg.antialiasing = true;
							}
							else
								{
									bg.antialiasing = false;
								}
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
						  if (FlxG.save.data.antialiasing)
							{
								city.antialiasing = true;
							}
							else
								{
									city.antialiasing = false;
								}
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);
						  if (FlxG.save.data.optimizations)
							{
								var cityLights:FlxSprite = new FlxSprite().loadGraphic(Paths.image('philly/win0', 'week3'));
								cityLights.scrollFactor.set(0.3, 0.3);
								cityLights.visible = true;
								cityLights.setGraphicSize(Std.int(cityLights.width * 0.85));
								cityLights.updateHitbox();
								add(cityLights);
								if (FlxG.save.data.antialiasing)
									{
										cityLights.antialiasing = true;
									}
									else
										{
											cityLights.antialiasing = false;
										}
							}
							else
								{
									for (i in 0...5)
										{
												var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
												light.scrollFactor.set(0.3, 0.3);
												light.visible = false;
												light.setGraphicSize(Std.int(light.width * 0.85));
												light.updateHitbox();
												if (FlxG.save.data.antialiasing)
												  {
													  light.antialiasing = true;
												  }
												  else
													  {
														  light.antialiasing = false;
													  }
												phillyCityLights.add(light);
										}
								}

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
						  if (FlxG.save.data.antialiasing)
							{
								streetBehind.antialiasing = true;
							}
							else
								{
									streetBehind.antialiasing = false;
								}
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
							  if (FlxG.save.data.antialiasing)
								{
									phillyTrain.antialiasing = true;
								}
								else
									{
										phillyTrain.antialiasing = false;
									}
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'shared'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
						  if (FlxG.save.data.antialiasing)
							{
								street.antialiasing = true;
							}
							else
								{
									street.antialiasing = false;
								}
	                          add(street);
		          }
                 /// secret stage lmaoooo
				  case 'hand-crushed-by-a-mallet': 
					{
					  curStage = 'mallet';

					  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					  bg.scrollFactor.set(0.1, 0.1);
					  if (FlxG.save.data.antialiasing)
						{
							bg.antialiasing = true;
						}
						else
							{
								bg.antialiasing = false;
							}
					  add(bg);

						  var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					  city.scrollFactor.set(0.3, 0.3);
					  city.setGraphicSize(Std.int(city.width * 0.85));
					  city.updateHitbox();
					  if (FlxG.save.data.antialiasing)
						{
							city.antialiasing = true;
						}
						else
							{
								city.antialiasing = false;
							}
					  add(city);

					  phillyCityLights = new FlxTypedGroup<FlxSprite>();
					  add(phillyCityLights);
					  if (FlxG.save.data.optimizations)
						{
							var cityLights:FlxSprite = new FlxSprite().loadGraphic(Paths.image('philly/win0', 'shared'));
							cityLights.scrollFactor.set(0.3, 0.3);
							cityLights.visible = true;
							cityLights.setGraphicSize(Std.int(cityLights.width * 0.85));
							cityLights.updateHitbox();
							add(cityLights);
							if (FlxG.save.data.antialiasing)
								{
									cityLights.antialiasing = true;
								}
								else
									{
										cityLights.antialiasing = false;
									}
						}
						else
							{
								for (i in 0...5)
									{
											var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'shared'));
											light.scrollFactor.set(0.3, 0.3);
											light.visible = false;
											light.setGraphicSize(Std.int(light.width * 0.85));
											light.updateHitbox();
											if (FlxG.save.data.antialiasing)
											  {
												  light.antialiasing = true;
											  }
											  else
												  {
													  light.antialiasing = false;
												  }
											phillyCityLights.add(light);
									}
							}

					  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
					  if (FlxG.save.data.antialiasing)
						{
							streetBehind.antialiasing = true;
						}
						else
							{
								streetBehind.antialiasing = false;
							}
					  add(streetBehind);

						  phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
						  if (FlxG.save.data.antialiasing)
							{
								phillyTrain.antialiasing = true;
							}
							else
								{
									phillyTrain.antialiasing = false;
								}
					  add(phillyTrain);

					  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'shared'));
					  FlxG.sound.list.add(trainSound);

					  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
					  if (FlxG.save.data.antialiasing)
						{
							street.antialiasing = true;
						}
						else
							{
								street.antialiasing = false;
							}
						  add(street);
			  }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
						  if (FlxG.save.data.antialiasing)
							{
								skyBG.antialiasing = true;
							}
							else
								{
									skyBG.antialiasing = false;
								}
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
						  if (FlxG.save.data.antialiasing)
							{
								bgLimo.antialiasing = true;
							}
							else
								{
									bgLimo.antialiasing = false;
								}
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
						  if (FlxG.save.data.antialiasing)
							{
								limo.antialiasing = true;
							}
							else
								{
									limo.antialiasing = false;
								}

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
						  if (FlxG.save.data.antialiasing)
							{
								fastCar.antialiasing = true;
							}
							else
								{
									fastCar.antialiasing = false;
								}
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
						  if (FlxG.save.data.antialiasing)
							{
								bg.antialiasing = true;
							}
							else
								{
									bg.antialiasing = false;
								}
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);
						  if (FlxG.save.data.optimizations)
							{
								upperBoppers = new FlxSprite(-240, -90);
								upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop_opt', 'week5');
								upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
								if (FlxG.save.data.antialiasing)
								  {
									  upperBoppers.antialiasing = true;
								  }
								  else
									  {
										  upperBoppers.antialiasing = false;
									  }
								upperBoppers.scrollFactor.set(0.33, 0.33);
								upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
								upperBoppers.updateHitbox();
								add(upperBoppers);
							}
							else
								{
									upperBoppers = new FlxSprite(-240, -90);
									upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
									upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
									if (FlxG.save.data.antialiasing)
									  {
										  upperBoppers.antialiasing = true;
									  }
									  else
										  {
											  upperBoppers.antialiasing = false;
										  }
									upperBoppers.scrollFactor.set(0.33, 0.33);
									upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
									upperBoppers.updateHitbox();
									add(upperBoppers);
								}

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
						  if (FlxG.save.data.antialiasing)
							{
								bgEscalator.antialiasing = true;
							}
							else
								{
									bgEscalator.antialiasing = false;
								}
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
						  if (FlxG.save.data.antialiasing)
							{
								tree.antialiasing = true;
							}
							else
								{
									tree.antialiasing = false;
								}
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);
                          if (FlxG.save.data.optimizations)
							{
								bottomBoppers = new FlxSprite(-300, 140);
								bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop_opt', 'week5');
								bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
								if (FlxG.save.data.antialiasing)
								  {
									  bottomBoppers.antialiasing = true;
								  }
								  else
									  {
										  bottomBoppers.antialiasing = false;
									  }
									bottomBoppers.scrollFactor.set(0.9, 0.9);
									bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
								bottomBoppers.updateHitbox();
								add(bottomBoppers);
							}
							else
								{
									bottomBoppers = new FlxSprite(-300, 140);
									bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
									bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
									if (FlxG.save.data.antialiasing)
									  {
										  bottomBoppers.antialiasing = true;
									  }
									  else
										  {
											  bottomBoppers.antialiasing = false;
										  }
										bottomBoppers.scrollFactor.set(0.9, 0.9);
										bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
									bottomBoppers.updateHitbox();
									add(bottomBoppers);
								}

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
		                  fgSnow.active = false;
						  if (FlxG.save.data.antialiasing)
							{
								fgSnow.antialiasing = true;
							}
							else
								{
									fgSnow.antialiasing = false;
								}
		                  add(fgSnow);
						  if (FlxG.save.data.optimizations)
							{
								santa = new FlxSprite(-840, 150);
								santa.frames = Paths.getSparrowAtlas('christmas/santaopt', 'week5');
								santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
								if (FlxG.save.data.antialiasing)
								  {
									  santa.antialiasing = true;
								  }
								  else
									  {
										  santa.antialiasing = false;
									  }
								add(santa);
							}
							else
								{
                                    santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
						  if (FlxG.save.data.antialiasing)
							{
								santa.antialiasing = true;
							}
							else
								{
									santa.antialiasing = false;
								}
		                  add(santa);
								}
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
						  if (FlxG.save.data.antialiasing)
							{
								bg.antialiasing = true;
							}
							else
								{
									bg.antialiasing = false;
								}
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
						  if (FlxG.save.data.antialiasing)
							{
								evilTree.antialiasing = true;
							}
							else
								{
									evilTree.antialiasing = false;
								}
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
							  if (FlxG.save.data.antialiasing)
								{
									evilSnow.antialiasing = true;
								}
								else
									{
										evilSnow.antialiasing = false;
									}
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
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
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
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
				  case 'test':
					   /// secret stage lmaoooo part 2
					  {
						defaultCamZoom = 0.9;
						curStage = 'test';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stagebackwolves'));
						bg.scrollFactor.set(0.9, 0.9);
						if (FlxG.save.data.antialiasing)
						  {
							  bg.antialiasing = true;
						  }
						  else
							  {
								  bg.antialiasing = false;
							  }
						add(bg);

						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefrontwolves'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						if (FlxG.save.data.antialiasing)
						  {
							  stageFront.antialiasing = true;
						  }
						  else
							  {
								  stageFront.antialiasing = false;
							  }
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);

						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('ascending_bf_lmao', 'shared'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						if (FlxG.save.data.antialiasing)
						  {
							  stageCurtains.antialiasing = true;
						  }
						  else
							  {
								  stageCurtains.antialiasing = false;
							  }
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						add(stageCurtains); 
					  } 		
		          default:
		          {
		                  defaultCamZoom = 0.9;
		                  curStage = 'stage';
		                  var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		                  bg.scrollFactor.set(0.9, 0.9);
						  if (FlxG.save.data.antialiasing)
							{
								bg.antialiasing = true;
							}
							else
								{
									bg.antialiasing = false;
								}
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
						  if (FlxG.save.data.antialiasing)
							{
								stageFront.antialiasing = true;
							}
							else
								{
									stageFront.antialiasing = false;
								}
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
						  if (FlxG.save.data.antialiasing)
							{
								stageCurtains.antialiasing = true;
							}
							else
								{
									stageCurtains.antialiasing = false;
								}
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
			case 'test':
				gfVersion = 'gf-normal';
			case 'mallet':
				gfVersion = 'gf-normal';	
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';



		if (FlxG.save.data.healthdrain)
			{
				trace("draining health -0.0004 unless told not to");
			}


		if (FlxG.save.data.healthdrain && SONG.song.toLowerCase() == 'tutorial')
			{
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						trace("-0.0002");
						tmr.reset();
					});
			}

			if (FlxG.save.data.healthdrain && SONG.song.toLowerCase() == 'hand-crushed-by-a-mallet')
				{
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
						{
							trace("-0.0001");
							tmr.reset();
						});
				}

				if (FlxG.save.data.healthdrain && SONG.song.toLowerCase() == 'blammed')
					{
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								trace("-0.0003");
								tmr.reset();
							});
					}

					if (FlxG.save.data.healthdrain && SONG.song.toLowerCase() == 'spookeez')
						{
							new FlxTimer().start(0.3, function(tmr:FlxTimer)
								{
									trace("-0.0003");
									tmr.reset();
								});
						}
						
						if (FlxG.save.data.healthdrain && SONG.song.toLowerCase() == 'monster')
							{
								new FlxTimer().start(0.3, function(tmr:FlxTimer)
									{
										trace("-0.0003");
										tmr.reset();
									});
							}

	
			if (FlxG.save.data.healthdrain && SONG.song.toLowerCase() == 'winter-horrorland')
				{
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
						{
							trace("-0.0003");
							tmr.reset();
						});
				}

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
			case 'picomallet':
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

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

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

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);
		if (FlxG.save.data.downscroll)
			{
				scoreTxt = new FlxText(380, 700, "", 20);
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				scoreTxt.scrollFactor.set();
				if (FlxG.save.data.antialiasing)
					{
						scoreTxt.antialiasing = false;
					}
					else
						{
							scoreTxt.antialiasing = true;
						}
				add(scoreTxt);
			}
			else
				{
					scoreTxt = new FlxText(380, 0, "", 20);
					scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					scoreTxt.scrollFactor.set();
					if (FlxG.save.data.antialiasing)
						{
							scoreTxt.antialiasing = false;
						}
						else
							{
								scoreTxt.antialiasing = true;
							}
					add(scoreTxt);
				}

				if (FlxG.save.data.debug)
					{
						var sniperenginemark = new FlxText(4,420, "FNF " + MainMenuState.gameVer + " | " + MainMenuState.sniperengineversionA + " | DEBUG", 12);
						sniperenginemark.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
						sniperenginemark.scrollFactor.set();
						if (FlxG.save.data.antialiasing)
							{
								sniperenginemark.antialiasing = false;
							}
							else
								{
									sniperenginemark.antialiasing = true;
								}
						add(sniperenginemark);
						sniperenginemark.cameras = [camHUD];
						/// for some fucking reason if there is an if statement you have to move the fucking camhud shit up into it, that is dumb and stupid
					}
					else
						{
							var sniperenginemark = new FlxText(4,700 - 4,0,SONG.song + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy") + " -" + MainMenuState.sniperengineversionA + MainMenuState.nightly, 12);
							sniperenginemark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
							sniperenginemark.scrollFactor.set();
							if (FlxG.save.data.antialiasing)
								{
									sniperenginemark.antialiasing = false;
								}
								else
									{
										sniperenginemark.antialiasing = true;
									}
							add(sniperenginemark);
							sniperenginemark.cameras = [camHUD];
						}

		if (FlxG.save.data.debug)
			{
				var debuginfo = new FlxText(4,640, "Player1: " + SONG.player1 , 12);
				debuginfo.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				debuginfo.scrollFactor.set();
				if (FlxG.save.data.antialiasing)
					{
						debuginfo.antialiasing = false;
					}
					else
						{
							debuginfo.antialiasing = true;
						}
				add(debuginfo);
				debuginfo.cameras = [camHUD];
			}

			if (FlxG.save.data.debug)
				{
					var debuginfo2 = new FlxText(4,660, "Player2: " + SONG.player2 , 12);
					debuginfo2.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
					debuginfo2.scrollFactor.set();
					if (FlxG.save.data.antialiasing)
						{
							debuginfo2.antialiasing = false;
						}
						else
							{
								debuginfo2.antialiasing = true;
							}
					add(debuginfo2);
					debuginfo2.cameras = [camHUD];
				}

				if (FlxG.save.data.debug)
					{
						var debuginfo3 = new FlxText(4,620, "Difficulty: " + CoolUtil.difficultyString() , 12);
						debuginfo3.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
						debuginfo3.scrollFactor.set();
						if (FlxG.save.data.antialiasing)
							{
								debuginfo3.antialiasing = false;
							}
							else
								{
									debuginfo3.antialiasing = true;
								}
						add(debuginfo3);
						debuginfo3.cameras = [camHUD];
					}

					if (FlxG.save.data.debug)
						{
							var debuginfo4 = new FlxText(4,680, "GF Version: " + gfVersion , 12);
							debuginfo4.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
							debuginfo4.scrollFactor.set();
							if (FlxG.save.data.antialiasing)
								{
									debuginfo4.antialiasing = false;
								}
								else
									{
										debuginfo4.antialiasing = true;
									}
							add(debuginfo4);
							debuginfo4.cameras = [camHUD];
						}

						if (FlxG.save.data.debug)
							{
								debuginfo5 = new FlxText(4, 560, "", 12);
								debuginfo5.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
								debuginfo5.scrollFactor.set();
								if (FlxG.save.data.antialiasing)
									{
										debuginfo5.antialiasing = false;
									}
									else
										{
											debuginfo5.antialiasing = true;
										}
								add(debuginfo5);
								debuginfo5.cameras = [camHUD];
							}

							if (FlxG.save.data.debug)
								{
									debuginfo6 = new FlxText(4, 540, "", 12);
									debuginfo6.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
									debuginfo6.scrollFactor.set();
									if (FlxG.save.data.antialiasing)
										{
											debuginfo6.antialiasing = false;
										}
										else
											{
												debuginfo6.antialiasing = true;
											}
									add(debuginfo6);
									debuginfo6.cameras = [camHUD];
								}

								if (FlxG.save.data.debug)
									{
										debuginfo7 = new FlxText(4, 520, "", 12);
										debuginfo7.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
										debuginfo7.scrollFactor.set();
										if (FlxG.save.data.antialiasing)
											{
												debuginfo7.antialiasing = false;
											}
											else
												{
													debuginfo7.antialiasing = true;
												}
										add(debuginfo7);
										debuginfo7.cameras = [camHUD];
									}

									if (FlxG.save.data.debug)
										{
											debuginfo9 = new FlxText(4, 500, "", 12);
											debuginfo9.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
											debuginfo9.scrollFactor.set();
											if (FlxG.save.data.antialiasing)
												{
													debuginfo9.antialiasing = false;
												}
												else
													{
														debuginfo9.antialiasing = true;
													}
											add(debuginfo9);
											debuginfo9.cameras = [camHUD];
										}

										if (FlxG.save.data.debug)
											{
												debuginfo10 = new FlxText(4, 480, "", 12);
												debuginfo10.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
												debuginfo10.scrollFactor.set();
												if (FlxG.save.data.antialiasing)
													{
														debuginfo10.antialiasing = false;
													}
													else
														{
															debuginfo10.antialiasing = true;
														}
												add(debuginfo10);
												debuginfo10.cameras = [camHUD];
											}

											if (FlxG.save.data.debug)
												{
													debuginfo11 = new FlxText(4, 460, "", 12);
													debuginfo11.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
													debuginfo11.scrollFactor.set();
													if (FlxG.save.data.antialiasing)
														{
															debuginfo11.antialiasing = false;
														}
														else
															{
																debuginfo11.antialiasing = true;
															}
													add(debuginfo11);
													debuginfo11.cameras = [camHUD];
												}

												if (FlxG.save.data.debug)
													{
														debuginfo12 = new FlxText(4, 440, "", 12);
														debuginfo12.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
														debuginfo12.scrollFactor.set();
														if (FlxG.save.data.antialiasing)
															{
																debuginfo12.antialiasing = false;
															}
															else
																{
																	debuginfo12.antialiasing = true;
																}
														add(debuginfo12);
														debuginfo12.cameras = [camHUD];
													}

									if (FlxG.save.data.debug)
										{
											debuginfo8 = new FlxText(4, 580, "Stage: " + curStage, 12);
											debuginfo8.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
											debuginfo8.scrollFactor.set();
											if (FlxG.save.data.antialiasing)
												{
													debuginfo8.antialiasing = false;
												}
												else
													{
														debuginfo8.antialiasing = true;
													}
											add(debuginfo8);
											debuginfo8.cameras = [camHUD];
										}

										if (FlxG.save.data.debug)
											{
												debuginfo13 = new FlxText(4, 600, "Song: " + SONG.song, 12);
												debuginfo13.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
												debuginfo13.scrollFactor.set();
												if (FlxG.save.data.antialiasing)
													{
														debuginfo13.antialiasing = false;
													}
													else
														{
															debuginfo13.antialiasing = true;
														}
												add(debuginfo13);
												debuginfo13.cameras = [camHUD];
											}


											if (FlxG.save.data.debug)
												{
													debuginfo14 = new FlxText(4, 700, " ", 12);
													debuginfo14.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
													debuginfo14.scrollFactor.set();
													if (FlxG.save.data.antialiasing)
														{
															debuginfo14.antialiasing = false;
														}
														else
															{
																debuginfo13.antialiasing = true;
															}
													add(debuginfo14);
													debuginfo14.cameras = [camHUD];
												}
					

		if (FlxG.save.data.downscroll)
			{
				accuracytext = new FlxText(180, 700, "", 20);
				accuracytext.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				accuracytext.scrollFactor.set();
				if (FlxG.save.data.antialiasing)
					{
						accuracytext.antialiasing = false;
					}
					else
						{
							accuracytext.antialiasing = true;
						}
				add(accuracytext);
			}
			else
				{
					accuracytext = new FlxText(180, 0, "", 20);
					accuracytext.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
					accuracytext.scrollFactor.set();
					if (FlxG.save.data.antialiasing)
						{
							accuracytext.antialiasing = false;
						}
						else
							{
								accuracytext.antialiasing = true;
							}
					add(accuracytext);
				}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		if (FlxG.save.data.hideHUD)
			{
				strumLineNotes.cameras = [camHUD2];
				notes.cameras = [camHUD2];
			}
			else
				{
					strumLineNotes.cameras = [camHUD];
					notes.cameras = [camHUD];
				}
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		accuracytext.cameras = [camHUD];
		doof.cameras = [camHUD];

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
							if (FlxG.save.data.cinematic)
								{
									camHUD.visible = false;
								}
								else
									{
										camHUD.visible = true;
									}
							
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

	function schoolIntro(?dialogueBox:DialogueBox):Void
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

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
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

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	

	function startCountdown():Void
	{
		inCutscene = false;
		trace('started countdown');

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
			trace('conductor running');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

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
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					trace('3');
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
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					trace('2');
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
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					trace('1');
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
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
					trace('go');
				case 4:
					trace('hit');
					FlxG.sound.music.volume = 1;
					trace('sound check');
	             	vocals.volume = 1;
					 trace('voice check');
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
			{
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				trace('vocals loaded');
				trace('INFOMATION ABOUT WAT U PLAYIN WIT:' + '\nOFFSET: ' + FlxG.save.data.offset + '\nSONG: ' + SONG.song + '\nSTAGE: ' + curStage + '\nDIFFICULTY: ' + PlayState.storyDifficulty + '\nP1: ' + SONG.player1 + '\nP2: ' + SONG.player2 + '\nNOTES: ' + PlayState.SONG.notes);
			}
		else
			{
				vocals = new FlxSound();
				trace('no vocals needed');
			}

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

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
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
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

		 trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		if (generatedMusic)
			{
				trace('song generated');
			}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			trace(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

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
					if (FlxG.save.data.downscroll)
						{
							babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_downscroll');
							babyArrow.animation.addByPrefix('green', 'arrowUP');
							babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
							babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
							babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
		
							if (FlxG.save.data.antialiasing)
								{
									babyArrow.antialiasing = true;
								}
								else
									{
										babyArrow.antialiasing = false;
									}
							babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
		
							switch (Math.abs(i))
							{
								case 0:
									babyArrow.x += Note.swagWidth * 0;
									babyArrow.animation.addByPrefix('static', 'arrowLEFT');
									babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
									babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
								case 1:
									babyArrow.x += Note.swagWidth * 1;
									babyArrow.animation.addByPrefix('static', 'arrowDOWN');
									babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
									babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
								case 2:
									babyArrow.x += Note.swagWidth * 2;
									babyArrow.animation.addByPrefix('static', 'arrowUP');
									babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
									babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
								case 3:
									babyArrow.x += Note.swagWidth * 3;
									babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
									babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
									babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
							}
						}
						else
							{
								babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
								babyArrow.animation.addByPrefix('green', 'arrowUP');
								babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
								babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
								babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
			
								if (FlxG.save.data.antialiasing)
									{
										babyArrow.antialiasing = true;
									}
									else
										{
											babyArrow.antialiasing = false;
										}
								babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			
								switch (Math.abs(i))
								{
									case 0:
										babyArrow.x += Note.swagWidth * 0;
										babyArrow.animation.addByPrefix('static', 'arrowLEFT');
										babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
										babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
									case 1:
										babyArrow.x += Note.swagWidth * 1;
										babyArrow.animation.addByPrefix('static', 'arrowDOWN');
										babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
										babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
									case 2:
										babyArrow.x += Note.swagWidth * 2;
										babyArrow.animation.addByPrefix('static', 'arrowUP');
										babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
										babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
									case 3:
										babyArrow.x += Note.swagWidth * 3;
										babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
										babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
										babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
								}
							}

			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}


			cpuStrums.forEach(function(spr:FlxSprite)
				{					
					spr.centerOffsets(); //CPU arrows start out slightly off-center
				});

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


	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}

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
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}


		switch (curStage)
		{
			case 'mallet':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		if (boyfriend.animation.curAnim.name.startsWith('sing') && scoretxtnotmoved)
			{
			accuracytext.x -= 30;
			scoreTxt.x -= 30;
			scoretxtnotmoved = false;
			trace("MOVED");		
			}


		///scoreTxt.text = 'Misses: $misses | Score: $songScore | Combo: $combo';
		/// so ummm there are two accuracy thinges cuz one is good at calculating it and the other is shit
		scoreTxt.text = " | Overall Accuracy: " + truncateFloat(accuracy, 2) + "% " + (fc ? "| FC" : misses == 0 ? "| A" : accuracy <= 75 ? "| BAD" : "") + " | Misses: " + misses + " | " + "Score: " + songScore + " | Combo: " + combo + " | Health: " + Math.round(health * 50);
		accuracytext.text = baseText;

		var pauseBtt:Bool = FlxG.keys.justPressed.ENTER;
		if (Main.woops)
		{
			pauseBtt = FlxG.keys.justPressed.ESCAPE;
		}

		if (FlxG.save.data.debug)
			{
				debuginfo5.text = "Player1 sequence:" + boyfriend.animation.curAnim.name;
			}

		if (FlxG.save.data.debug)
			{
				debuginfo6.text = "Player2 sequence:" + dad.animation.curAnim.name;
			}

		if (FlxG.save.data.debug)
			{
				debuginfo7.text = "GF sequence:" + gf.animation.curAnim.name;
			}

		if (FlxG.save.data.debug)
			{
				debuginfo9.text = "CurBeat: " + curBeat;
			}

		if (FlxG.save.data.debug)
			{
				debuginfo10.text = "CurStep: " + curStep;
			}

		if (FlxG.save.data.debug)
			{
				debuginfo11.text = "Notes hit: " + notesnotmissed;
			}

		if (FlxG.save.data.debug)
			{
				debuginfo12.text = "CPU Notes hit: " + cpunotesHit;
			}

			if (FlxG.save.data.debug)
				{
					debuginfo14.text = "GF Speed: " + gfSpeed;
				}

		if (health >= 0)
			{
				accuracytext.text = baseText2;
			}

		var baseText:String = "Current Accuracy:";
		
		if (notesPassing != 0) {
			baseText = "Current Accuracy:" + Math.round((notesHit/notesPassing) * 100) + "%";
		} else {
			baseText = "Current Accuracy:100%";
		}
		
		if (notesPassing != 0) {
			baseText2 = "Current Accuracy: " + Math.round((notesHit/notesPassing) * 100) + "%";
		} else {
			baseText2 = "Current Accuracy: 100%";
		}

		if (curSong.toLowerCase() == 'blammed' && curStep == 1)
			{
				
				camZooming = true;

			}

           ////BLAMMED ZOOMING
			if (curSong.toLowerCase() == 'blammed' && curStep == 127)
				{
						{
							        FlxG.camera.zoom += 0.015;
							        camHUD.zoom += 0.03;
									FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
									camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
									trace('BEAT');
						}
				}

				if (curSong.toLowerCase() == 'blammed' && curStep == 141)
					{
							{
								FlxG.camera.zoom += 0.015;
								camHUD.zoom += 0.03;
								FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
								camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
								trace('BEAT');
							}
					}

					if (curSong.toLowerCase() == 'blammed' && curStep == 148)
						{
								{
									FlxG.camera.zoom += 0.015;
									camHUD.zoom += 0.03;
									FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
									camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
									trace('BEAT');
								}
						}

						if (curSong.toLowerCase() == 'blammed' && curStep == 160)
							{
									{
										FlxG.camera.zoom += 0.015;
										camHUD.zoom += 0.03;
										FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
										camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
										trace('BEAT');
									}
							}


							if (curSong.toLowerCase() == 'blammed' && curStep == 167)
								{
										{
											FlxG.camera.zoom += 0.015;
											camHUD.zoom += 0.03;
											FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
											camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
											trace('BEAT');
										}
								}


								if (curSong.toLowerCase() == 'blammed' && curStep == 173)
									{
											{
												FlxG.camera.zoom += 0.015;
												camHUD.zoom += 0.03;
												FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
												camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
												trace('BEAT');
											}
									}


									if (curSong.toLowerCase() == 'blammed' && curStep == 180)
										{
												{
													FlxG.camera.zoom += 0.015;
													camHUD.zoom += 0.03;
													FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
													camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
													trace('BEAT');
												}
										}


										if (curSong.toLowerCase() == 'blammed' && curStep == 191)
											{
													{
														FlxG.camera.zoom += 0.015;
														camHUD.zoom += 0.03;
														FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
														camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
														trace('BEAT');
													}
											}

											if (curSong.toLowerCase() == 'blammed' && curStep == 205)
												{
														{
															FlxG.camera.zoom += 0.015;
															camHUD.zoom += 0.03;
															FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
															camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
															trace('BEAT');
														}
												}


												if (curSong.toLowerCase() == 'blammed' && curStep == 213)
													{
															{
																FlxG.camera.zoom += 0.015;
																camHUD.zoom += 0.03;
																FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																trace('BEAT');
															}
													}

													if (curSong.toLowerCase() == 'blammed' && curStep == 225)
														{
																{
																	FlxG.camera.zoom += 0.015;
																	camHUD.zoom += 0.03;
																	FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																	camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																	trace('BEAT');
																}
														}

														if (curSong.toLowerCase() == 'blammed' && curStep == 230)
															{
																	{
																		FlxG.camera.zoom += 0.015;
																		camHUD.zoom += 0.03;
																		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																		trace('BEAT');
																	}
															}

															if (curSong.toLowerCase() == 'blammed' && curStep == 237)
																{
																		{
																			FlxG.camera.zoom += 0.015;
																			camHUD.zoom += 0.03;
																			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																			trace('BEAT');
																		}
																}

																if (curSong.toLowerCase() == 'blammed' && curStep == 245)
																	{
																			{
																				FlxG.camera.zoom += 0.015;
																				camHUD.zoom += 0.03;
																				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																				trace('BEAT');
																			}
																	}

																	if (curSong.toLowerCase() == 'blammed' && curStep == 257)
																		{
																				{
																					FlxG.camera.zoom += 0.015;
																					camHUD.zoom += 0.03;
																					FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																					camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																					trace('BEAT');
																				}
																		}


																		if (curSong.toLowerCase() == 'blammed' && curStep == 268)
																			{
																					{
																						FlxG.camera.zoom += 0.015;
																						camHUD.zoom += 0.03;
																						FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																						camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																						trace('BEAT');
																					}
																			}

																			if (curSong.toLowerCase() == 'blammed' && curStep == 277)
																				{
																						{
																							FlxG.camera.zoom += 0.015;
																							camHUD.zoom += 0.03;
																							FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																							camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																							trace('BEAT');
																						}
																				}

																				if (curSong.toLowerCase() == 'blammed' && curStep == 289)
																					{
																							{
																								FlxG.camera.zoom += 0.015;
																								camHUD.zoom += 0.03;
																								FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																								camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																								trace('BEAT');
																							}
																					}

																					if (curSong.toLowerCase() == 'blammed' && curStep == 294)
																						{
																								{
																									FlxG.camera.zoom += 0.015;
																									camHUD.zoom += 0.03;
																									FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																									camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																									trace('BEAT');
																								}
																						}


																						if (curSong.toLowerCase() == 'blammed' && curStep == 301)
																							{
																									{
																										FlxG.camera.zoom += 0.015;
																										camHUD.zoom += 0.03;
																										FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																										camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																										trace('BEAT');
																									}
																							}

																							if (curSong.toLowerCase() == 'blammed' && curStep == 308)
																								{
																										{
																											FlxG.camera.zoom += 0.015;
																											camHUD.zoom += 0.03;
																											FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																											camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																											trace('BEAT');
																										}
																								}

																								if (curSong.toLowerCase() == 'blammed' && curStep == 320)
																									{
																											{
																												FlxG.camera.zoom += 0.015;
																												camHUD.zoom += 0.03;
																												FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																												camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																												trace('BEAT');
																											}
																									}

																									if (curSong.toLowerCase() == 'blammed' && curStep == 332)
																										{
																												{
																													FlxG.camera.zoom += 0.015;
																													camHUD.zoom += 0.03;
																													FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																													camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																													trace('BEAT');
																												}
																										}

																										if (curSong.toLowerCase() == 'blammed' && curStep == 340)
																											{
																													{
																														FlxG.camera.zoom += 0.015;
																														camHUD.zoom += 0.03;
																														FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																														camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																														trace('BEAT');
																													}
																											}

																											if (curSong.toLowerCase() == 'blammed' && curStep == 353)
																												{
																														{
																															FlxG.camera.zoom += 0.015;
																															camHUD.zoom += 0.03;
																															FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																															camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																															trace('BEAT');
																														}
																												}

																												if (curSong.toLowerCase() == 'blammed' && curStep == 359)
																													{
																															{
																																FlxG.camera.zoom += 0.015;
																																camHUD.zoom += 0.03;
																																FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																trace('BEAT');
																															}
																													}

																													if (curSong.toLowerCase() == 'blammed' && curStep == 364)
																														{
																																{
																																	FlxG.camera.zoom += 0.015;
																																	camHUD.zoom += 0.03;
																																	FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																	camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																	trace('BEAT');
																																}
																														}

																														if (curSong.toLowerCase() == 'blammed' && curStep == 373)
																															{
																																	{
																																		FlxG.camera.zoom += 0.015;
																																		camHUD.zoom += 0.03;
																																		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																		trace('BEAT');
																																	}
																															}

																															if (curSong.toLowerCase() == 'blammed' && curStep == 513)
																																{
																																		{
																																			FlxG.camera.zoom += 0.015;
																																			camHUD.zoom += 0.03;
																																			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																			trace('BEAT');
																																		}
																																}

																																if (curSong.toLowerCase() == 'blammed' && curStep == 524)
																																	{
																																			{
																																				FlxG.camera.zoom += 0.015;
																																				camHUD.zoom += 0.03;
																																				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																				trace('BEAT');
																																			}
																																	}

																																	if (curSong.toLowerCase() == 'blammed' && curStep == 533)
																																		{
																																				{
																																					FlxG.camera.zoom += 0.015;
																																					camHUD.zoom += 0.03;
																																					FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																					camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																					trace('BEAT');
																																				}
																																		}

																																		if (curSong.toLowerCase() == 'blammed' && curStep == 544)
																																			{
																																					{
																																						FlxG.camera.zoom += 0.015;
																																						camHUD.zoom += 0.03;
																																						FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																						camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																						trace('BEAT');
																																					}
																																			}

																																			if (curSong.toLowerCase() == 'blammed' && curStep == 550)
																																				{
																																						{
																																							FlxG.camera.zoom += 0.015;
																																							camHUD.zoom += 0.03;
																																							FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																							camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																							trace('BEAT');
																																						}
																																				}

																																				if (curSong.toLowerCase() == 'blammed' && curStep == 557)
																																					{
																																							{
																																								FlxG.camera.zoom += 0.015;
																																								camHUD.zoom += 0.03;
																																								FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																								camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																								trace('BEAT');
																																							}
																																					}

																																					if (curSong.toLowerCase() == 'blammed' && curStep == 565)
																																						{
																																								{
																																									FlxG.camera.zoom += 0.015;
																																									camHUD.zoom += 0.03;
																																									FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																									camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																									trace('BEAT');
																																								}
																																						}

																																						if (curSong.toLowerCase() == 'blammed' && curStep == 577)
																																							{
																																									{
																																										FlxG.camera.zoom += 0.015;
																																										camHUD.zoom += 0.03;
																																										FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																										camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																										trace('BEAT');
																																									}
																																							}

																																							if (curSong.toLowerCase() == 'blammed' && curStep == 589)
																																								{
																																										{
																																											FlxG.camera.zoom += 0.015;
																																											camHUD.zoom += 0.03;
																																											FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																											camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																											trace('BEAT');
																																										}
																																								}

																																								if (curSong.toLowerCase() == 'blammed' && curStep == 597)
																																									{
																																											{
																																												FlxG.camera.zoom += 0.015;
																																												camHUD.zoom += 0.03;
																																												FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																												camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																												trace('BEAT');
																																											}
																																									}

																																									if (curSong.toLowerCase() == 'blammed' && curStep == 608)
																																										{
																																												{
																																													FlxG.camera.zoom += 0.015;
																																													camHUD.zoom += 0.03;
																																													FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																													camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																													trace('BEAT');
																																												}
																																										}

																																										if (curSong.toLowerCase() == 'blammed' && curStep == 614)
																																											{
																																													{
																																														FlxG.camera.zoom += 0.015;
																																														camHUD.zoom += 0.03;
																																														FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																														camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																														trace('BEAT');
																																													}
																																											}

																																											if (curSong.toLowerCase() == 'blammed' && curStep == 620)
																																												{
																																														{
																																															FlxG.camera.zoom += 0.015;
																																															camHUD.zoom += 0.03;
																																															FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																															camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																															trace('BEAT');
																																														}
																																												}

																																												if (curSong.toLowerCase() == 'blammed' && curStep == 628)
																																													{
																																															{
																																																FlxG.camera.zoom += 0.015;
																																																camHUD.zoom += 0.03;
																																																FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																trace('BEAT');
																																															}
																																													}

																																													if (curSong.toLowerCase() == 'blammed' && curStep == 641)
																																														{
																																																{
																																																	FlxG.camera.zoom += 0.015;
																																																	camHUD.zoom += 0.03;
																																																	FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																	camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																	trace('BEAT');
																																																}
																																														}

																																														if (curSong.toLowerCase() == 'blammed' && curStep == 653)
																																															{
																																																	{
																																																		FlxG.camera.zoom += 0.015;
																																																		camHUD.zoom += 0.03;
																																																		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																		trace('BEAT');
																																																	}
																																															}

																																															if (curSong.toLowerCase() == 'blammed' && curStep == 660)
																																																{
																																																		{
																																																			FlxG.camera.zoom += 0.015;
																																																			camHUD.zoom += 0.03;
																																																			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																			trace('BEAT');
																																																		}
																																																}

																																																if (curSong.toLowerCase() == 'blammed' && curStep == 673)
																																																	{
																																																			{
																																																				FlxG.camera.zoom += 0.015;
																																																				camHUD.zoom += 0.03;
																																																				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																				trace('BEAT');
																																																			}
																																																	}

																																																	if (curSong.toLowerCase() == 'blammed' && curStep == 678)
																																																		{
																																																				{
																																																					FlxG.camera.zoom += 0.015;
																																																					camHUD.zoom += 0.03;
																																																					FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																					camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																					trace('BEAT');
																																																				}
																																																		}

																																																		if (curSong.toLowerCase() == 'blammed' && curStep == 684)
																																																			{
																																																					{
																																																						FlxG.camera.zoom += 0.015;
																																																						camHUD.zoom += 0.03;
																																																						FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																						camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																						trace('BEAT');
																																																					}
																																																			}

																																																			if (curSong.toLowerCase() == 'blammed' && curStep == 692)
																																																				{
																																																						{
																																																							FlxG.camera.zoom += 0.015;
																																																							camHUD.zoom += 0.03;
																																																							FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																							camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																							trace('BEAT');
																																																						}
																																																				}

																																																				if (curSong.toLowerCase() == 'blammed' && curStep == 704)
																																																					{
																																																							{
																																																								FlxG.camera.zoom += 0.015;
																																																								camHUD.zoom += 0.03;
																																																								FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																								camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																								trace('BEAT');
																																																							}
																																																					}

																																																					if (curSong.toLowerCase() == 'blammed' && curStep == 717)
																																																						{
																																																								{
																																																									FlxG.camera.zoom += 0.015;
																																																									camHUD.zoom += 0.03;
																																																									FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																									camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																									trace('BEAT');
																																																								}
																																																						}

																																																						if (curSong.toLowerCase() == 'blammed' && curStep == 724)
																																																							{
																																																									{
																																																										FlxG.camera.zoom += 0.015;
																																																										camHUD.zoom += 0.03;
																																																										FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																										camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																										trace('BEAT');
																																																									}
																																																							}

																																																							if (curSong.toLowerCase() == 'blammed' && curStep == 737)
																																																								{
																																																										{
																																																											FlxG.camera.zoom += 0.015;
																																																											camHUD.zoom += 0.03;
																																																											FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																											camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																											trace('BEAT');
																																																										}
																																																								}

																																																								if (curSong.toLowerCase() == 'blammed' && curStep == 742)
																																																									{
																																																											{
																																																												FlxG.camera.zoom += 0.015;
																																																												camHUD.zoom += 0.03;
																																																												FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																												camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																												trace('BEAT');
																																																											}
																																																									}

																																																									if (curSong.toLowerCase() == 'blammed' && curStep == 748)
																																																										{
																																																												{
																																																													FlxG.camera.zoom += 0.015;
																																																													camHUD.zoom += 0.03;
																																																													FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																													camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																													trace('BEAT');
																																																												}
																																																										}

																																																										if (curSong.toLowerCase() == 'blammed' && curStep == 756)
																																																											{
																																																													{
																																																														FlxG.camera.zoom += 0.015;
																																																														camHUD.zoom += 0.03;
																																																														FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																														camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																														trace('BEAT');
																																																													}
																																																											}

																																																											if (curSong.toLowerCase() == 'blammed' && curStep == 1024)
																																																												{
																																																														{
																																																															FlxG.camera.zoom += 0.030;
																																																															camHUD.zoom += 0.06;
																																																															FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																															FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																															trace('BEAT');
																																																														}
																																																												}

																																																												if (curSong.toLowerCase() == 'hand-crushed-by-a-mallet' && curStep == 1024)
																																																													{
																																																															{
																																																																FlxG.camera.zoom += 0.030;
																																																																camHUD.zoom += 0.06;
																																																																FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
																																																																FlxMath.lerp(1, camHUD.zoom, 0.95);
																																																																trace('BEAT');
																																																															}
																																																													}

																																																												
					
				
			
		
	


		if (FlxG.save.data.healthdrain)
			{
				if (SONG.song.toLowerCase() == 'tutorial')
					{		
						new FlxTimer().start(0.001, function(tmr:FlxTimer)
							{
								health -= 0.0002;
							});
					}
                    else if (SONG.song.toLowerCase() == 'winter-horrorland')
						{
							new FlxTimer().start(0.001, function(tmr:FlxTimer)
								{
									health -= 0.0003;
								});
						}
						else if (SONG.song.toLowerCase() == 'monster')
							{
								new FlxTimer().start(0.001, function(tmr:FlxTimer)
									{
										health -= 0.0003;
									});
							}
							else if (SONG.song.toLowerCase() == 'south')
								{
									new FlxTimer().start(0.001, function(tmr:FlxTimer)
										{
											health -= 0.0003;
										});
								}
								else if (SONG.song.toLowerCase() == 'spookeez')
									{
										new FlxTimer().start(0.001, function(tmr:FlxTimer)
											{
												health -= 0.0003;
											});
									}
									else if (SONG.song.toLowerCase() == 'blammed')
										{
											new FlxTimer().start(0.001, function(tmr:FlxTimer)
												{
													health -= 0.0003;
												});
										}
										else if (SONG.song.toLowerCase() == 'hand-crushed-by-a-mallet')
											{
												new FlxTimer().start(0.001, function(tmr:FlxTimer)
													{
														health -= 0.0001;
													});
											}
						else 
							{
								new FlxTimer().start(0.001, function(tmr:FlxTimer)
									{
										health -= 0.0004;
									});
							}
			}
		
      if (Main.woops)
		{
			if (FlxG.keys.justPressed.SPACE && startedCountdown && canPause)
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
				
					#if desktop
					DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
					#end
				}
		}
		else
			{
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
					
						#if desktop
						DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
						#end
					}
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

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, 0.15)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, 0.15)));

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
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
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
		if (FlxG.save.data.reset)
			{
				if (controls.RESET)
					{
						health = 0;
						trace("RESET = True");
					}
			
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
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}


				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != '')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

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
							
					}

					dad.holdTimer = 0;




					///yeah this kinda fucked me over lmaoooooooo
					{
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
								cpunotesHit += 1;			
							}
							else if (dad.animation.curAnim.name.startsWith('idle') && !dad.animation.curAnim.name.endsWith('idle'))
								{
									cpuStrums.forEach(function(spr:FlxSprite)
										{
											{
												spr.animation.play('static');
												spr.centerOffsets();
												trace('reset cpu strums');
											}
										});
								}
								else
									{
										{
									
											spr.centerOffsets();
											if (spr.animation.finished)
												{
													spr.animation.play('static');
													spr.centerOffsets();
												}	
										}
									}

							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else if (dad.animation.curAnim.name.startsWith('idle') && !dad.animation.curAnim.name.endsWith('idle'))
								{
									cpuStrums.forEach(function(spr:FlxSprite)
										{
											{
												spr.animation.play('static');
												spr.centerOffsets();
												trace('reset cpu strums');
											}
										});
								}
								else
									{
										{
									
											spr.centerOffsets();
											if (spr.animation.finished)
												{
													spr.animation.play('static');
													spr.centerOffsets();
												}	
										}
									}
					
		
						});
					}
		
					{
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (spr.animation.finished)
							{
								spr.animation.play('static');
								spr.centerOffsets();
							}
						});
					}
					//// notes getting stuck!?!?!?!? FlxTimer always works :troll:
					/*new FlxTimer().start(10, function(tmr:FlxTimer)
						{
							cpuStrums.forEach(function(spr:FlxSprite)
								{
									{
										spr.animation.play('static');
										spr.centerOffsets();
									}
								});
								
						/*////});

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}




						
			


				if (FlxG.save.data.downscroll)
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				else
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height && !FlxG.save.data.downscroll  || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.0475;
						vocals.volume = 0;
						noteMiss(daNote.noteData);
						notesPassing += 1;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

			});
		}

		cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		
		#end
	}	

	function endSong():Void
	{
		trace('ending song');
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

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
		var score:Int = 300;
	
		var daRating:String = "sick";
		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
			notesHit += 0.25;
			notesnotmissed += 1;
			totalNotesHit -= 2;
			if (FlxG.save.data.debug)
				{
					trace('shit');
				}
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
			notesHit += 0.25;
			notesnotmissed += 1;
			totalNotesHit += 0.2;
			if (FlxG.save.data.debug)
				{
					trace('bad');
				}
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			notesHit += 0.95;
			notesnotmissed += 1;
			totalNotesHit += 0.65;
			if (FlxG.save.data.debug)
				{
					trace('good');
				}
		}


		if (daRating == 'sick')
		{
			if (FlxG.save.data.debug)
				{
					trace('sick');
				}
			notesHit += 1;
			totalNotesHit += 1;
			notesnotmissed += 1;
			notesPassing -= 0.25;
			if (notesHit > notesPassing) {
				notesHit = notesPassing;
			}
		}

		songScore += score;

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

		if (curStage.startsWith('school'))
			{
				if (FlxG.save.data.antialiasing)
					{
						rating.antialiasing = true;
					}
					else
						{
							rating.antialiasing = true;
						}
			}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		
		if (FlxG.save.data.antialiasing)
			{
				rating.antialiasing = true;
			}
			else
				{
					///my if statements be like
					rating.antialiasing = true;
				}
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		if (FlxG.save.data.antialiasing)
			{
				comboSpr.antialiasing = true;
			}
			else
				{
					///my if statements be like part 2
					comboSpr.antialiasing = true;
				}
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			if (FlxG.save.data.antialiasing)
				{
					rating.antialiasing = true;
				}
				else
					{
						rating.antialiasing = true;
					}
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			if (FlxG.save.data.antialiasing)
				{
					comboSpr.antialiasing = true;
				}
				else
					{
						comboSpr.antialiasing = false;
					}
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

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
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
					noteCheck(true, daNote);

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
								if (!inIgnoreList && !ghost)
									badNoteCheck();
								updateAccuracy();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				 if (FlxG.save.data.debug)
					{
					  trace(daNote.noteData);
					}
				
						/*switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
								    trace('ghost tapping');
							case 3:
								if (upP || rightP || downP || leftP)
									trace('ghost tapping');
							case 1:
								if (upP || rightP || downP || leftP)
									trace('ghost tapping');
							case 0:
								if (upP || rightP || downP || leftP)
									trace('ghost tapping');
						}

					//this is already done in noteCheck / goodNoteHit
					/*if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				 */
			}
			else if (!ghost)
				{
					badNoteCheck();
				}
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
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
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						{
							trace('ghost tapping');
							spr.animation.play('pressed');
						}
						if (leftR)
							{
								spr.animation.play('static');
							}
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						{
							trace('ghost tapping');
							spr.animation.play('pressed');
						}
					if (downR)
						{
							spr.animation.play('static');
						}
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						{
							trace('ghost tapping');
							spr.animation.play('pressed');
						}
					if (upR)
						{
							spr.animation.play('static');
						}
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						{
							trace('ghost tapping');
							spr.animation.play('pressed');
						}
					if (rightR)
						{
							spr.animation.play('static');
						}
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
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
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			songScore -= 10;
			notesPassing += 1;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			misses +=1;
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			 FlxG.log.add('played imss note');

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
			}
			updateAccuracy();
		}

	}

  
			function badNoteCheck()
				{
					// just double pasting this shit cuz fuk u
					// REDO THIS SYSTEM!
					/// week7 input be like
					/// well yn this but better
					var upP = controls.UP_P;
					var rightP = controls.RIGHT_P;
					var downP = controls.DOWN_P;
					var leftP = controls.LEFT_P;
			
					if (leftP)
						noteMiss(0);
					if (downP)
						noteMiss(1);
					if (upP)
						noteMiss(2);
					if (rightP)
						noteMiss(3);
					updateAccuracy();
				}

				function updateAccuracy()
					{
						if (misses > 0)
							fc = false;
						else
							fc = true;
						totalPlayed += 1;
						accuracy = totalNotesHit / totalPlayed * 100;
					}


	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (FlxG.save.data.debug)
				{
					trace('note hit');
				}
				if (FlxG.save.data.debug)
					{
						trace(combo);
					}
			updateAccuracy();
			if (!note.isSustainNote)
			{
				notesPassing += 1;
				popUpScore(note.strumTime);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
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

			if (curSong.toLowerCase() == 'fresh' && curBeat >= 48 && curBeat < 80)
				{
					if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 1 == 0)
						{
							FlxG.camera.zoom += 0.015;
							camHUD.zoom += 0.03;
							camHUD2.zoom += 0.03;
							trace('zooming %1 == 0');
						}
				}


				if (curSong.toLowerCase() == 'fresh' && curBeat >= 112 && curBeat < 144)
					{
						if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 1 == 0)
							{
								FlxG.camera.zoom += 0.015;
								camHUD.zoom += 0.03;
								camHUD2.zoom += 0.03;
								trace('zooming %1 == 0');
							}
					}
					if (curSong.toLowerCase() == 'fresh' && curBeat >= 16 && curBeat < 48)
						{
							if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
								{
									FlxG.camera.zoom += 0.015;
									camHUD.zoom += 0.03;
									trace('zooming %4 == 0');
								}
						}


						if (curSong.toLowerCase() == 'fresh' && curBeat >= 80 && curBeat < 112)
							{
								if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
									{
										FlxG.camera.zoom += 0.015;
										camHUD.zoom += 0.03;
										trace('zooming %4 == 0');
									}
							}

							if (curSong.toLowerCase() == 'bopeebo')
								{
									if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
										{
											FlxG.camera.zoom += 0.015;
											camHUD.zoom += 0.03;
											trace('zooming %4 == 0');
										}
								}

								if (curSong.toLowerCase() == 'dadbattle')
									{
										if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
											{
												FlxG.camera.zoom += 0.015;
												camHUD.zoom += 0.03;
												trace('zooming %2 == 0');
											}
									}


									if (curSong.toLowerCase() == 'spookeez')
										{
											if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
												{
													FlxG.camera.zoom += 0.015;
													camHUD.zoom += 0.03;
													trace('zooming %4 == 0');
												}
										}



										if (curSong.toLowerCase() == 'south')
											{
												if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
													{
														FlxG.camera.zoom += 0.015;
														camHUD.zoom += 0.03;
														trace('zooming %4 == 0');
													}
											}



											if (curSong.toLowerCase() == 'monster' && curBeat >= 20 && curBeat < 72)
												{
													if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
														{
															FlxG.camera.zoom += 0.015;
															camHUD.zoom += 0.03;
															trace('zooming %2 == 0');
														}
												}

												if (curSong.toLowerCase() == 'monster' && curBeat >= 72 && curBeat < 203)
													{
														if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 1 == 0)
															{
																FlxG.camera.zoom += 0.015;
																camHUD.zoom += 0.03;
																trace('zooming %1 == 0');
															}
													}

													if (curSong.toLowerCase() == 'monster' && curBeat >= 203 && curBeat < 217)
														{
															if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																{
																	FlxG.camera.zoom += 0.015;
																	camHUD.zoom += 0.03;
																	trace('zooming %4 == 0');
																}
														}

														if (curSong.toLowerCase() == 'monster' && curBeat >= 203 && curBeat < 232)
															{
																if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																	{
																		FlxG.camera.zoom += 0.015;
																		camHUD.zoom += 0.03;
																		trace('zooming %2 == 0');
																	}
															}

															if (curSong.toLowerCase() == 'monster' && curBeat >= 232 && curBeat < 308)
																{
																	if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 1 == 0)
																		{
																			FlxG.camera.zoom += 0.015;
																			camHUD.zoom += 0.03;
																			trace('zooming %1 == 0');
																		}
																}

																if (curSong.toLowerCase() == 'monster' && curBeat >= 308 && curBeat < 312)
																	{
																		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																			{
																				FlxG.camera.zoom += 0.015;
																				camHUD.zoom += 0.03;
																				trace('zooming %2 == 0');
																			}
																	}

																	if (curSong.toLowerCase() == 'monster' && curBeat >= 312 && curBeat < 319)
																		{
																			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																				{
																					FlxG.camera.zoom += 0.015;
																					camHUD.zoom += 0.03;
																					trace('zooming %4 == 0');
																				}
																		}

												if (curSong.toLowerCase() == 'pico')
													{
														if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
															{
																FlxG.camera.zoom += 0.015;
																camHUD.zoom += 0.03;
																trace('zooming %4 == 0');
															}
													}


													if (curSong.toLowerCase() == 'philly')
														{
															if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																{
																	FlxG.camera.zoom += 0.015;
																	camHUD.zoom += 0.03;
																	trace('zooming %2 == 0');
																}
														}

														if (curSong.toLowerCase() == 'blammed' && curBeat >= 96 && curBeat < 128)
															{
																if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																	{
																		FlxG.camera.zoom += 0.015;
																		camHUD.zoom += 0.03;
																		camHUD2.zoom += 0.03;
																		trace('zooming %4 == 0');
																	}
															}


															if (curSong.toLowerCase() == 'blammed' && curBeat >= 128 && curBeat < 160)
																{
																	if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																		{
																			FlxG.camera.zoom += 0.015;
																			camHUD.zoom += 0.03;
																			camHUD2.zoom += 0.03;
																			trace('zooming %2 == 0');
																		}
																}

																
															if (curSong.toLowerCase() == 'blammed' && curBeat >= 160 && curBeat < 192)
																{
																	if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 1 == 0)
																		{
																			FlxG.camera.zoom += 0.015;
																			camHUD.zoom += 0.03;
																			camHUD2.zoom += 0.03;
																			trace('zooming %1 == 0');
																		}
																}


																if (curSong.toLowerCase() == 'blammed' && curBeat >= 192 && curBeat < 256)
																	{
																		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																			{
																				FlxG.camera.zoom += 0.015;
																				camHUD.zoom += 0.03;
																				camHUD2.zoom += 0.03;
																				trace('zooming %2 == 0');
																			}
																	}

																	if (curSong.toLowerCase() == 'blammed' && curBeat >= 256 && curBeat < 293)
																		{
																			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																				{
																					FlxG.camera.zoom += 0.015;
																					camHUD.zoom += 0.03;
																					camHUD2.zoom += 0.03;
																					trace('zooming %4 == 0');
																				}
																		}

																		if (curSong.toLowerCase() == 'hand-crushed-by-a-mallet' && curBeat >= 31 && curBeat < 96)
																			{
																				if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																					{
																						FlxG.camera.zoom += 0.015;
																						camHUD.zoom += 0.03;
																						camHUD2.zoom += 0.03;
																						trace('zooming %4 == 0');
																					}
																			}

																			if (curSong.toLowerCase() == 'hand-crushed-by-a-mallet' && curBeat >= 96 && curBeat < 128)
																				{
																					if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 8 == 0)
																						{
																							FlxG.camera.zoom += 0.015;
																							camHUD.zoom += 0.03;
																							camHUD2.zoom += 0.03;
																							trace('zooming %8 == 0');
																						}
																				}

																				if (curSong.toLowerCase() == 'hand-crushed-by-a-mallet' && curBeat >= 128 && curBeat < 160)
																					{
																						if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																							{
																								FlxG.camera.zoom += 0.015;
																								camHUD.zoom += 0.03;
																								camHUD2.zoom += 0.03;
																								trace('zooming %2 == 0');
																							}
																					}

																					if (curSong.toLowerCase() == 'hand-crushed-by-a-mallet' && curBeat >= 160 && curBeat < 192)
																						{
																							if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 1 == 0)
																								{
																									FlxG.camera.zoom += 0.015;
																									camHUD.zoom += 0.03;
																									camHUD2.zoom += 0.03;
																									trace('zooming %1 == 0');
																								}
																						}

																						if (curSong.toLowerCase() == 'hand-crushed-by-a-mallet' && curBeat >= 192 && curBeat < 224)
																							{
																								if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																									{
																										FlxG.camera.zoom += 0.015;
																										camHUD.zoom += 0.03;
																										camHUD2.zoom += 0.03;
																										trace('zooming %4 == 0');
																									}
																							}

																							if (curSong.toLowerCase() == 'hand-crushed-by-a-mallet' && curBeat >= 224 && curBeat < 256)
																								{
																									if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																										{
																											FlxG.camera.zoom += 0.015;
																											camHUD.zoom += 0.03;
																											camHUD2.zoom += 0.03;
																											trace('zooming %2 == 0');
																										}
																								}

																								if (curSong.toLowerCase() == 'hand-crushed-by-a-mallet' && curBeat >= 256 && curBeat < 293)
																									{
																										if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																											{
																												FlxG.camera.zoom += 0.015;
																												camHUD.zoom += 0.03;
																												camHUD2.zoom += 0.03;
																												trace('zooming %4 == 0');
																											}
																									}

																		if (curSong.toLowerCase() == 'satin-panties')
																			{
																				if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																					{
																						FlxG.camera.zoom += 0.015;
																						camHUD.zoom += 0.03;
																						trace('zooming %4 == 0');
																					}
																			}

																			if (curSong.toLowerCase() == 'milf')
																				{
																					if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																						{
																							FlxG.camera.zoom += 0.015;
																							camHUD.zoom += 0.03;
																							trace('zooming %2 == 0');
																						}
																				}

																				if (curSong.toLowerCase() == 'cocoa' && curBeat >= 0 && curBeat < 144)
																					{
																						if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																							{
																								FlxG.camera.zoom += 0.015;
																								camHUD.zoom += 0.03;
																								camHUD2.zoom += 0.03;
																								trace('zooming %2 == 0');
																							}
																					}

																					if (curSong.toLowerCase() == 'cocoa' && curBeat >= 144 && curBeat < 176)
																						{
																							if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 1 == 0)
																								{
																									FlxG.camera.zoom += 0.015;
																									camHUD.zoom += 0.03;
																									camHUD2.zoom += 0.03;
																									trace('zooming %1 == 0');
																								}
																						}

																						if (curSong.toLowerCase() == 'cocoa' && curBeat >= 176 && curBeat < 191)
																							{
																								if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																									{
																										FlxG.camera.zoom += 0.015;
																										camHUD.zoom += 0.03;
																										camHUD2.zoom += 0.03;
																										trace('zooming %4 == 0');
																									}
																							}

																							if (curSong.toLowerCase() == 'eggnog')
																								{
																									if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																										{
																											FlxG.camera.zoom += 0.015;
																											camHUD.zoom += 0.03;
																											trace('zooming %2 == 0');
																										}
																								}

																								if (curSong.toLowerCase() == 'winter-horrorland')
																									{
																										if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																											{
																												FlxG.camera.zoom += 0.015;
																												camHUD.zoom += 0.03;
																												trace('zooming %4 == 0');
																											}
																									}

																									if (curSong.toLowerCase() == 'senpai')
																										{
																											if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																												{
																													FlxG.camera.zoom += 0.015;
																													camHUD.zoom += 0.03;
																													trace('zooming %2 == 0');
																												}
																										}


																										if (curSong.toLowerCase() == 'roses' && curBeat >= 0 && curBeat < 112)
																											{
																												if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																													{
																														FlxG.camera.zoom += 0.015;
																														camHUD.zoom += 0.03;
																														camHUD2.zoom += 0.03;
																														trace('zooming %4 == 0');
																													}
																											}

																											if (curSong.toLowerCase() == 'roses' && curBeat >= 112 && curBeat < 128)
																												{
																													if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																														{
																															FlxG.camera.zoom += 0.015;
																															camHUD.zoom += 0.03;
																															camHUD2.zoom += 0.03;
																															trace('zooming %2 == 0');
																														}
																												}

																												if (curSong.toLowerCase() == 'roses' && curBeat >= 128 && curBeat < 160)
																													{
																														if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																															{
																																FlxG.camera.zoom += 0.015;
																																camHUD.zoom += 0.03;
																																camHUD2.zoom += 0.03;
																																trace('zooming %4 == 0');
																															}
																													}

																													if (curSong.toLowerCase() == 'roses' && curBeat >= 160 && curBeat < 183)
																														{
																															if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
																																{
																																	FlxG.camera.zoom += 0.015;
																																	camHUD.zoom += 0.03;
																																	camHUD2.zoom += 0.03;
																																	trace('zooming %2 == 0');
																																}
																														}

																														if (curSong.toLowerCase() == 'thorns')
																															{
																																if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
																																	{
																																		FlxG.camera.zoom += 0.015;
																																		camHUD.zoom += 0.03;
																																		camHUD2.zoom += 0.03;
																																		trace('zooming %4 == 0');
																																	}
																															}
																		


													

													////'pico' | 'philly' | 'blammed' | 'satin-panties' | 'high' | 'milf' | 'cocoa' | 'eggnog' | 'winter-horrorland' | 'senpai' | 'roses' | 'thorns'



											

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

		if (curBeat % 16 == 15 && SONG.song == 'Ugh' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
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
                if (FlxG.save.data.optimizations)
					{
                        if (curBeat % 4 == 0)
							{
							
							}
					}
					else
						{
							if (curBeat % 4 == 0 && curSong.toLowerCase() == 'pico')
								{
									phillyCityLights.forEach(function(light:FlxSprite)
									{
										light.visible = false;
									});
				
									curLight = FlxG.random.int(0, phillyCityLights.length - 1);
				
									phillyCityLights.members[curLight].visible = true;
									// phillyCityLights.members[curLight].alpha = 1;
									trace('lights 4% == 0');
								}

								if (curBeat % 4 == 0 && curSong.toLowerCase() == 'philly')
									{
										phillyCityLights.forEach(function(light:FlxSprite)
										{
											light.visible = false;
										});
					
										curLight = FlxG.random.int(0, phillyCityLights.length - 1);
					
										phillyCityLights.members[curLight].visible = true;
										// phillyCityLights.members[curLight].alpha = 1;
										trace('lights 4% == 0');
									}

									if (curSong.toLowerCase() == 'blammed' && curBeat >= 0 && curBeat < 128)
										{
											if (curBeat % 4 == 0)
												{
													phillyCityLights.forEach(function(light:FlxSprite)
													{
														light.visible = false;
													});
								
													curLight = FlxG.random.int(0, phillyCityLights.length - 1);
								
													phillyCityLights.members[curLight].visible = true;
													// phillyCityLights.members[curLight].alpha = 1;
													trace('lights 4% == 0');
												}
										}

										if (curSong.toLowerCase() == 'blammed' && curBeat >= 128 && curBeat < 160)
											{
												if (curBeat % 2 == 0)
													{
														phillyCityLights.forEach(function(light:FlxSprite)
														{
															light.visible = false;
														});
									
														curLight = FlxG.random.int(0, phillyCityLights.length - 1);
									
														phillyCityLights.members[curLight].visible = true;
														// phillyCityLights.members[curLight].alpha = 1;
														trace('lights 2% == 0');
													}
											}

											if (curSong.toLowerCase() == 'blammed' && curBeat >= 160 && curBeat < 192)
												{
													if (curBeat % 1 == 0)
														{
															phillyCityLights.forEach(function(light:FlxSprite)
															{
																light.visible = false;
															});
										
															curLight = FlxG.random.int(0, phillyCityLights.length - 1);
										
															phillyCityLights.members[curLight].visible = true;
															// phillyCityLights.members[curLight].alpha = 1;
															trace('lights 1% == 0');
														}
												}

												if (curSong.toLowerCase() == 'blammed' && curBeat >= 192 && curBeat < 256)
													{
														if (curBeat % 2 == 0)
															{
																phillyCityLights.forEach(function(light:FlxSprite)
																{
																	light.visible = false;
																});
											
																curLight = FlxG.random.int(0, phillyCityLights.length - 1);
											
																phillyCityLights.members[curLight].visible = true;
																// phillyCityLights.members[curLight].alpha = 1;
																trace('lights 2% == 0');
															}
													}

													if (curSong.toLowerCase() == 'blammed' && curBeat >= 256 && curBeat < 293)
														{
															if (curBeat % 4 == 0)
																{
																	phillyCityLights.forEach(function(light:FlxSprite)
																	{
																		light.visible = false;
																	});
												
																	curLight = FlxG.random.int(0, phillyCityLights.length - 1);
												
																	phillyCityLights.members[curLight].visible = true;
																	// phillyCityLights.members[curLight].alpha = 1;
																	trace('lights 4% == 0');
																}
														}
						}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}



				case "mallet":
				if (!trainMoving)
					trainCooldown += 1;
                if (FlxG.save.data.optimizations)
					{
                        if (curBeat % 4 == 0)
							{
							
							}
					}
					else
						{
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
						}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
