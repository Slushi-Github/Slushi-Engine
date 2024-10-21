<h1 align="center">Slushi Engine</h1>
<h2 align="center">The engine that integrates Windows API functions into an FNF' engine!</h2>

<table align="center">
    <tr>
        <td><a href="./README.md">English<a></td>
        <td><a href="./README_ES.md">Español</a></td>
    </tr>
</table>

![Slushi Engine Logo](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/readmeImages/SlushiEngineLogo.png)

![Windows Workflow Status](https://img.shields.io/github/actions/workflow/status/Slushi-Github/Slushi-Engine/.github%2Fworkflows%2Fwindows.yml?label=Windows)
![Linux Workflow Status](https://img.shields.io/github/actions/workflow/status/Slushi-Github/Slushi-Engine/.github%2Fworkflows%2Flinux.yml?label=Linux)
![MacOS Workflow Status](https://img.shields.io/github/actions/workflow/status/Slushi-Github/Slushi-Engine/.github%2Fworkflows%2Fmacos.yml?label=MacOS)
![GitHub Downloads](https://img.shields.io/github/downloads/Slushi-Github/Slushi-Engine/total) 
![GitHub repo size](https://img.shields.io/github/repo-size/Slushi-Github/Slushi-Engine)


[Gamejolt](https://gamejolt.com/games/SlushiEngine/884361) - [GameBanana](https://gamebanana.com/tools/17953)


Slushi Engine is an FNF' engine that allows you to make modcharts with [Modcharting Tools](https://github.com/EdwhakKB/FNF-Modcharting-Tools) and other [SC Engine](https://github.com/EdwhakKB/SC-SP-ENGINE) utilities, while also being able to make a unique kind of modchart that uses Windows functions!
In addition, SLE takes some inspiration from [NotITG](https://www.noti.tg/) and [HITMANS: THE ANNIHILATE AND DESTROY PROJECT](https://gamebanana.com/mods/453997)

You can do things like this, or even better things!

![](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/readmeImages/VideoDemonstration0.gif)
[Video of this](https://youtu.be/lT-9rTg6f_o?si=8srv0LmbzZ6avGgb)

The limit is in your mind, and of course, the OS where you run the engine hehe.

Did you like the effects of mods such as No More Innocence, Paranoia from [Mario Madness V2](https://gamebanana.com/mods/359554)? Maelstrom from [Friday Night Troubleshootin'](https://gamebanana.com/mods/320006)?
That changing the wallpaper, changing the cursor, hiding your taskbar?

Oh, wait, NMI doesn't have public source code right? And neither does Friday Night Troubleshootin', and they don't make it easy for you to make your songs with such effects, or rather it's impossible to do it natively with the mod's engine. 

Well, you are looking at the FNF' engine that will let you obtain your full potential in relation to certain mechanics of these mods mentioned, through its large amount of Lua functions to make your songs with all of this.

SLE, is created by me, Andrés, better known on the internet as Slushi, I'm the one who made EVERYTHING, between arts, most of the code and that, but of course, most of the C++ code has been taken from [StackOverflow](https://stackoverflow.com/), or with the help of AIs (like [ChatGPT](https://chatgpt.com/), [Google Gemini](https://gemini.google.com/app), etc...), but also with the help of my friends, like [Glowsoony](https://github.com/glowsoony), or [EdwhakKB](https://github.com/EdwhakKB), like lending me code or helping me in this, that these are the ones who developed SCE, the base of SLE.
and last but not least, I have also received help from my good friend, [Trock](https://github.com/Gametrock), he is the one who made WinSL a reality!
Without more to say, this IS Slushi Engine. an engine that not only uses FNF as a base, but also the beautiful Slushi, from [Chikn Nuggit](https://twitter.com/chikn_nuggit?t=YohD2quSHtamaiJyzT-FOA&s=09).

SLE has a [wiki](https://github.com/Slushi-Github/Slushi-Engine/tree/main/docs/development/SLELuaSpanish) in Spanish detailing its added Lua functionality, so you can see everything that this engine can do through such a simple language hehe

### Build Instructions:

[Read this](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/development/BuildInstructions.md) to know how to build SLE

### Frequently asked questions during the development of the engine:

Is the engine safe?:
> Yes! SLE may have had suspicious code in the past, like abstracting functions for crashing Windows to modcharts, modifying the Windows registry, but not currently, and never something that leaves permanent or difficult to remove changes,the only change that can stay depending on how your Windows handles it, is to move the desktop icons, they can stay bugged, but it is fixed by restarting the Windows Explorer.
(If you are working with the engine source code, removing `SLUSHI_CPP_CODE` from `Project.xml` will eliminate most of the functions related to Windows.)

I don't want the engine to be able to modify things on my system!:

> Ok, you can disable the Windows related effects of the engine in options.

Can SLE be for other systems?:
> Mm, yes and no, it depends, as SLE is an engine that is heavily reliant on Windows APIs for its functionality, its functionality may be limited when used in systems running Linux or macOS where these specific APIs aren't available. In such cases, I would recommend using SCE directly, but at least you can compile it on Linux ([Ubuntu 23.10](https://ubuntu.com/)).
![](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/readmeImages/SLEInUbuntu.png)

On Linux or macOS, is SLE usable through [Wine](https://www.winehq.org/)?:
> As far as I've tested on my own, yes, but Wine doesn't get along with things like moving the window a lot, at least I've tested on [Ubuntu 22.04](https://ubuntu.com/), I don't know on other distros, Debian based or not.

Can I use SLE for my mod?:
> Sure! I would love to see SLE as a base for a mod, but keep in mind that even though it uses SCE as a foundation, SLE has been heavily modified. This might not make it the best choice for typical FNF mods. However, if you're looking to create mods that leverage what the engine can do, feel free to experiment! Just remember to give me credits where you upload the mod.\
> **Where I would NOT allow SLE to be used is for**
> - For Dave And Bambi mods
> - In the creation or distribution of malware or malicious software

----
SLE is not made to compete with other engines such as [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine), [SB Engine](https://github.com/Stefan2008Git/FNF-SB-Engine), [Codename Engine](https://github.com/FNF-CNE-Devs/CodenameEngine) (I wonder why CNE developers decompiled SLE; they had no reason to do that?), or any other existing engines. Instead, SLE is designed to facilitate tasks that might otherwise be challenging and enable you to create modcharts like the ones made in NotITG or Hitmans AD with features beyond simply moving notes or the window.

In the near future, you can expect to find all C++ code from SLE available as a Haxe library on Haxelib. This will allow you to use it in your projects unrelated to FNF. The same goes for WinSL. :3:

[SL-Windows-API](https://lib.haxe.org/p/sl-windows-api/) (usable Windows API functions in Haxe).

### Credits:

Slushi, is neither my original character (OC) nor a character owned by me. She is from the web series, [Chikn Nuggit](https://twitter.com/chikn_nuggit?t=YohD2quSHtamaiJyzT-FOA&s=09), by Kyra Kupetsky. I do not have direct permission to use Slushi in this engine, all rights to the character belong to them.

Slushi Engine uses code from [Codename Engine](https://github.com/FNF-CNE-Devs/CodenameEngine) (SC Engine too, but I only want to refer to the code I used in SLE) and [HITMANS: THE ANNIHILATE AND DESTROY PROJECT](https://gamebanana.com/mods/453997).

For more credit details, [PLEASE check this from SCE README!](https://github.com/EdwhakKB/SC-SP-ENGINE?tab=readme-ov-file#credits-to-other-engine--most-engine-features-and-where-they-come-from-sorry-if-only-now-the-credits-exist-extermely-sorry)

[SC Engine](https://github.com/EdwhakKB/SC-SP-ENGINE), is only the base of SLE, it is not mine, it is from [EdwhakKB](https://github.com/EdwhakKB), I have his full permission to use SLE on this wonderful engine.

----

<details>
<summary>...</summary>
"Gracias [...] por siempre apoyarme en este proyecto desde que se me ocurrio la idea de iniciarlo, y tambien a ti [...], incluso si ya no estas en este mundo." 
- Andrés.
</details>

## Features of Slushi Engine:
- A HUD specifically made for songs using the NotITG mode, to make it look like the one behind this game, making it easy to get rid of the normal FNF' look.
- New shaders available only in SLE
- An extensive number of new Lua functions for you to experiment with when creating your songs or mods
- Based on the newest versions of SC Engine
- ~~Result screen of FNF' V-SLICE (From [P-Slice](https://github.com/mikolka9144/P-Slice))~~ (Now SCE has this, no longer feature of SLE)
