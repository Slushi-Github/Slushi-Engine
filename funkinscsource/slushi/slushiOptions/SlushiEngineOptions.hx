package slushi.slushiOptions;

import options.Option;

class SlushiEngineOptions extends options.BaseOptionsMenu
{
	public function new()
	{
		title = 'Slushi Engine Options';
		rpcTitle = 'Slushi Engine Options'; // for Discord Rich Presence
	
		#if windows
		var option:Option = new Option('change Window Border Color With Note Hit', 
		'Can change the color of the window border when you hit a note. \n(Only for Windows 11, sry)', 
		'changeWindowBorderColorWithNoteHit', 
		BOOL);
		addOption(option); 
		#end

		super();
	}
}