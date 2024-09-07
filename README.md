# Slushi Engine! the engine that manages to integrate Windows API functions into a FNF' engine!

![](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/readmeImages/SlushiEngineLogo.png)

Slushi Engine is made so that you can make your modcharts (with [Modcharting Tools](https://github.com/EdwhakKB/FNF-Modcharting-Tools)) and other [SC Engine](https://github.com/EdwhakKB/SC-SP-ENGINE) utilities while you can also make a kind of modchart but with Windows!
In addition, SLE takes some inspiration from [NotITG](https://www.noti.tg/) and [HITMANS: THE ANNIHILATE AND DESTROY PROJECT](https://gamebanana.com/mods/453997)

You can do things like this, or even better things!

![](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/readmeImages/VideoDemonstration0.gif)
[video of this](https://youtu.be/lT-9rTg6f_o?si=8srv0LmbzZ6avGgb)

The limit is in your mind, and of course, the OS where you run the engine hehe.

Did you like the effects of mods such as No More Innocence, Paranoia from [Mario Madness V2](https://gamebanana.com/mods/359554)? Maelstrom from [Friday Night Troubleshootin'](https://gamebanana.com/mods/320006)?
That changing the wallpaper, changing the cursor, hiding your taskbar?

Oh, wait, NMI doesn't have public source code right? And neither does Troubleshootin', and they don't make it easy for you to make your songs with such effects, or rather it's impossible to do it natively with the mod engine. 

Well, you are looking at the FNF' engine that will let you get your full potential in relation to certain mechanics of these mods mentioned, through its large amount of Lua functions to make your songs with all this.

SLE, is created by me, Andrés, better known on the internet as Slushi, I'm the one who made EVERYTHING, between arts, most of the code and that, but of course, most of the C++ code has been taken from [StackOverflow](https://stackoverflow.com/), or with the help of AIs (like [ChatGPT](https://chatgpt.com/), [Google Gemini](https://gemini.google.com/app), etc...), but also with the help of my friends, like [Glowsoony](https://github.com/glowsoony), or [EdwhakKB](https://github.com/EdwhakKB), like lending me code or helping me in this, that these are the ones who developed SCE, the base of SLE.
and last but not least, I have also received help from my good friend, [Trock](https://github.com/Gametrock), he is the one who made WinSL a reality!
without more to say, this IS Slushi Engine. an engine that not only uses FNF as a base, but also the beautiful Slushi, from [Chikn Nuggit](https://twitter.com/chikn_nuggit?t=YohD2quSHtamaiJyzT-FOA&s=09).

SLE has a [wiki](https://github.com/Slushi-Github/Slushi-Engine/tree/main/docs/development/SLELuaSpanish) in spanish, of its Lua so you can see all that this engine can do through such a simple language hehe

### Build Instructions:

[Read This](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/development/BuildInstructions.md) to know how to build SLE

### Frequently asked questions during the development of the engine:

Is the engine safe?:
> Yes! SLE may have had suspicious code in the past, like abstracting functions for crashing Windows to modcharts, modifying the Windows registry, but not currently, and never something that leaves permanent or difficult to remove changes,the only change that can stay depending on how your Windows handles it, is to move the desktop icons, they can stay bugged, but it is fixed by restarting windows explorer.
(if you are working with the engine source, you can remove `SLUSHI_CPP_CODE` from `Project.xml` to remove most of the Windows related functions)

I don't want the engine to be able to modify things on my system!:

> Ok, you can disable the Windows related effects of the engine in options.

Can SLE be for other systems?:
> Mm, yes and no, it depends, because SLE is an engine that leverages very strongly the C++ provided for Windows, making that in Linux or Mac, for example, this code is not present, so it does not make much sense to use SLE (In that case I would recommend using SCE directly), but at least if you can compile it on Linux ([Ubuntu 23.10](https://ubuntu.com/)).
![](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/readmeImages/SLEInUbuntu.png)

On Linux (or MacOS?), is SLE usable through [Wine](https://www.winehq.org/)?:
> As far as I've tested on my own, yes, but Wine doesn't get along with things like moving the window a lot, at least I've tested on [Ubuntu 22.04](https://ubuntu.com/), I don't know on other distros, Debian based or not.

Can I use SLE for my mod?:
> Sure! I would love to see SLE as a base for a mod, but of course, SLE, even though it uses SCE as a base, is very modified, making it not always so viable to use it for normal FNF mods, I would recommend you to use it for when you want to make mods that require, what the engine can do, but you are free to experiment, you just have to give me credits where you upload the engine :3
***Where I would NOT allow you to use SLE, would be for Dave And Bambi mods, sorry, but that's my opinion.***

----
SLE is not made to compete with other engines, like [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine), [SB Engine](https://github.com/Stefan2008Git/FNF-SB-Engine), [Codename Engine](https://github.com/FNF-CNE-Devs/CodenameEngine) (I wonder why CNE developers decompiled SLE, they had no reason to do that xd?), or other engines that may exist, SLE is made to facilitate things, that would not be easy for anyone, and allowing you, to make modcharts like NotITG or Hitmans AD, with something more than just moving the notes or the window.

Soon, you could find ALL the code for specifically C++, as a Haxe library, in Haxelib, for you to use in your projects that are not directly related even to FNF.
The same with WinSL :3

----

Slushi, is neither my OC or a character owned by me. She is from the web series, [Chikn Nuggit](https://twitter.com/chikn_nuggit?t=YohD2quSHtamaiJyzT-FOA&s=09), by Kyra Kupetsky. I do not have direct permission to use Slushi in this engine, all rights to the character go to them.

[SC Engine](https://github.com/EdwhakKB/SC-SP-ENGINE), is only the base of SLE, it is not mine, it is from [EdwhakKB](https://github.com/EdwhakKB), I have his full permission to use SLE on this wonderful engine.

----

<details>
<summary>...</summary>
"Gracias [...] por siempre apoyarme en este proyecto desde que se me ocurrio la idea de iniciarlo, y tambien a ti [...], incluso si ya no estas en este mundo." 
- Andrés.
</details>

## Features of Slushi Engine:
- A HUD specifically made for songs using the NotITG mode, to make it look like this game, making it easy to get rid of the normal FNF' look.
- New shaders, available only in SLE
- An extensive number of new Lua functions for you to experiment with when creating your songs or mods
- Based on the newest versions of SC Engine