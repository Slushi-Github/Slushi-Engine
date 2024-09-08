package slushi.slushiOptions;
#if windows

import options.Option;

class WindowsOptions extends options.BaseOptionsMenu
{
	var windowAlphaOption:Int;
	var windowOsuOption:Int;
	var notiOption:Int;

	public static var windowGeneral:FlxSprite;
	public static var windowCloseAnim:FlxSprite;
	public static var cursor:FlxSprite;
	public static var noti:FlxSprite;


	public function new()
	{
		title = 'Windows Options';
		rpcTitle = 'Windows Options Menu'; // for Discord Rich Presence

		windowGeneral = new FlxSprite(370, -30);
		windowGeneral.loadGraphic(SlushiMain.getSLEPath('optionsAssets/SLEWindow.png'));
		windowGeneral.setGraphicSize(Std.int(windowGeneral.width * 0.4));
		windowGeneral.antialiasing = ClientPrefs.data.antialiasing;
		FlxTween.tween(windowGeneral, {y: windowGeneral.y + 20}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(windowGeneral, {alpha: 0}, 1.6, {ease: FlxEase.quadInOut, type: PINGPONG});

		windowCloseAnim = new FlxSprite(980, 300);
		windowCloseAnim.loadGraphic(SlushiMain.getSLEPath('optionsAssets/WindowCloseButton.png'));
		windowCloseAnim.setGraphicSize(Std.int(windowCloseAnim.width * 1.4));
		windowCloseAnim.antialiasing = ClientPrefs.data.antialiasing;
		FlxTween.tween(windowCloseAnim, {alpha: 0}, 1.7, {ease: FlxEase.quadInOut, type: PINGPONG});

		noti = new FlxSprite(830, 260);
		noti.loadGraphic(SlushiMain.getSLEPath('optionsAssets/Windows11Notification.png'));
		noti.setGraphicSize(Std.int(noti.width * 0.8));
		noti.antialiasing = ClientPrefs.data.antialiasing;

		var text:FlxText = new FlxText(0, 60, 0, "Remember, all functions of this menu (and the is not in that), \nis reseted when you change the state, close the game, etc.", 25);	
		text.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.scrollFactor.set();
		text.screenCenter(X);
		text.antialiasing = ClientPrefs.data.antialiasing;
		
		var option:Option = new Option('Window Alpha', 
		'If unchecked, disables Window Alpha Functions \n(this has no effect with respect to the animation when you close the window)', 
		'windowAlpha', 
		BOOL);
		addOption(option);
		windowAlphaOption = optionsArray.length - 1;

		var option:Option = new Option('Hide Task Bar and change\n opacity', 
		'If unchecked, disables the ability to hide the Windows Task Bar and change the opacity of the it', 
		'winTaskBar', 
		BOOL);
		addOption(option);

		var option:Option = new Option('Hide Desktop Icons can move and change opacity', 
		'If unchecked, disables the ability to hide the Windows desktop icons, move the icons and change the opacity of the it', 
		'winDesktopIcons', 
		BOOL);
		addOption(option);

		var option:Option = new Option('Change wallpaper', 
		'If unchecked, disable the ability to change your desktop wallpaper \n(may cause lag)', 
		'ChangeWallPaper',
		BOOL);
		addOption(option);

		var option:Option = new Option('Send Notifications', 
		"Do you allow the game to send notifications? (may cause lag)",
		'windowsNotifications', 
		BOOL);
		addOption(option);
		notiOption = optionsArray.length - 1;

		var option:Option = new Option('Windows GDI Effects', 
		'If unchecked, disable the possibility to use Windows GDI effects (like MENZ effects!)', 
		'gdiEffects',
		BOOL);
		addOption(option);

		var option:Option = new Option('ScreenShots', 
		'If unchecked, disable the possibility to take screenshots of the entire screen', 
		'winScreenShots',
		BOOL);
		addOption(option);

		super();
		insert(1, windowGeneral);
		insert(2, noti);
		insert(3, text);
	}


	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		windowGeneral.visible = (windowAlphaOption == curSelected);
		noti.visible = (notiOption == curSelected);
	}
}
#end