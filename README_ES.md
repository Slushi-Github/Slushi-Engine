<h1 align="center">Slushi Engine</h1>
<h2 align="center">¡El motor que integra funciones de la API de Windows en un motor de FNF'!</h2>

<table align="center">
    <tr>
        <td><a href="./README.md">English<a></td>
        <td><a href="./README_ES.md">Español</a></td>
    </tr>
</table>

![Logo de Slushi Engine](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/readmeImages/SlushiEngineLogo.png)

# ¡IMPORTANTE!
**Este proyecto lo considero finalmente terminado y esta en un estado el cual me gusta, no pienso darle mas soporte o actualizaciones, lo siento si el engine esta algo mal optimizado.**

realmente gracias a todos los que le gustaron o apoyaron este proyecto! realmente este fue mi primer proyecto de programacion..

Tengo nuevos proyectos actualmente que mantengo, estos son [HxCompileU](https://github.com/Slushi-Github/hxCompileU) y [Leafy Engine](https://github.com/Slushi-Github/leafyEngine), mi proyecto general de llevar Haxe a la Nintendo WIi U, recomendaria que le eches un vistazo jeje.

Como ultimo, incluyo aqui la carpeta ``.haxelib`` en un archivo ZIP para el que desee compilar SLE a pesar de que algunas librerias cambien o no existan mas.

----

![Windows Workflow Status](https://img.shields.io/github/actions/workflow/status/Slushi-Github/Slushi-Engine/.github%2Fworkflows%2Fwindows.yml?label=Windows)
![Linux Workflow Status](https://img.shields.io/github/actions/workflow/status/Slushi-Github/Slushi-Engine/.github%2Fworkflows%2Flinux.yml?label=Linux)
![MacOS Workflow Status](https://img.shields.io/github/actions/workflow/status/Slushi-Github/Slushi-Engine/.github%2Fworkflows%2Fmacos.yml?label=MacOS)
![GitHub Downloads](https://img.shields.io/github/downloads/Slushi-Github/Slushi-Engine/total) 
![GitHub repo size](https://img.shields.io/github/repo-size/Slushi-Github/Slushi-Engine)


[GameBanana](https://gamebanana.com/tools/17953) - [Gamejolt](https://gamejolt.com/games/SlushiEngine/884361)

Slushi Engine es un motor de FNF' que te permite hacer modcharts con [Modcharting Tools](https://github.com/EdwhakKB/FNF-Modcharting-Tools) y otras utilidades del [SC Engine](https://github.com/glowsoony/SC-Engine), ¡mientras que también te permite hacer un tipo único de modchart que utiliza funciones de Windows!
Además, SLE toma algo de inspiración de [NotITG](https://www.noti.tg/) y [HITMANS: THE ANNIHILATE AND DESTROY PROJECT](https://gamebanana.com/mods/453997)

¡Puedes hacer cosas como esta, o incluso mejores!

![](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/readmeImages/VideoDemonstration0.gif)
[Video de esto](https://youtu.be/lT-9rTg6f_o?si=8srv0LmbzZ6avGgb)

El único límite está en tu mente, y claro, en el sistema operativo donde ejecutes el motor jeje.

¿Te gustaron los efectos de mods como No More Innocence, Paranoia de [Mario Madness V2](https://gamebanana.com/mods/359554)? ¿Maelstrom de [Friday Night Troubleshootin'](https://gamebanana.com/mods/320006)?
¿Esas modificaciones al fondo de pantalla, modificaciones al cursor, ocultar la barra de tareas?

Ah, espera, ¿NMI no tiene el código fuente público, verdad? Y tampoco Friday Night Troubleshootin', y no te facilitan hacer tus canciones con esos efectos, o más bien es imposible hacerlo nativamente con el motor del mod.

Bueno, estás mirando el motor de FNF' que te permitirá alcanzar tu máximo potencial en relación a ciertas mecánicas de esos mods mencionados, gracias a su gran cantidad de funciones Lua para hacer tus canciones con todo esto.

SLE, lo creé yo, Andrés, mejor conocido en internet como Slushi, yo soy quien hizo TODO, entre el arte, la mayoría del código y eso, pero claro, la mayor parte del código en C++ ha sido tomado de [StackOverflow](https://stackoverflow.com), o con la ayuda de IAs (como [ChatGPT](https://chatgpt.com), [Google Gemini](https://gemini.google.com/app), etc...), pero también con la ayuda de mis amigos, como [Glowsoony](https://github.com/glowsoony), o [EdwhakKB](https://github.com/EdwhakKB), prestándome código o ayudándome en esto, ya que son quienes desarrollaron SCE, la base de SLE.
Y por último, pero no menos importante, también he recibido ayuda de mi buen amigo [Trock](https://github.com/Gametrock), ¡él es quien hizo realidad WinSL!
Sin más que decir, esto ES Slushi Engine, un motor que no solo usa FNF' como base, sino también al hermoso Slushi, de [Chikn Nuggit](https://twitter.com/chikn_nuggit?t=YohD2quSHtamaiJyzT-FOA&s=09).

SLE tiene una [wiki](https://github.com/Slushi-Github/Slushi-Engine/tree/main/docs/development/SLELuaSpanish) en español detallando su funcionalidad añadida en Lua, para que puedas ver todo lo que este motor puede hacer a través de un lenguaje tan sencillo jeje.

### Instrucciones de compilación:

[Lee esto](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/development/BuildInstructions.md) para saber cómo compilar SLE.

### Preguntas frecuentes durante el desarrollo del motor:

¿Es seguro el motor?:
> ¡Sí! SLE pudo haber tenido código sospechoso en el pasado, como abstracciones de funciones para hacer crashear Windows en modcharts, modificar el registro de Windows, pero ya no lo tiene actualmente, y nunca algo que deje cambios permanentes o difíciles de eliminar. El único cambio que puede permanecer, dependiendo de cómo maneje Windows esto, es mover los íconos del escritorio, que pueden quedar desordenados, pero se arregla reiniciando el Explorador de Windows.
(Si estás trabajando con el código fuente del motor, eliminando `SLUSHI_CPP_CODE` de `Project.xml` eliminarás la mayoría de las funciones relacionadas con Windows.)

¡No quiero que el motor modifique cosas en mi sistema!:
> Ok, puedes desactivar los efectos relacionados con Windows en las opciones.

¿SLE puede ser usado en otros sistemas?:
> Mm, sí y no, depende, ya que SLE es un motor que depende mucho de las APIs de Windows para su funcionamiento, su funcionalidad puede estar limitada cuando se usa en sistemas que ejecutan Linux o macOS, donde estas APIs específicas no están disponibles. En tales casos, recomendaría usar SCE directamente, pero al menos puedes compilarlo en Linux ([Ubuntu 23.10](https://ubuntu.com)).
![](https://github.com/Slushi-Github/Slushi-Engine/blob/main/docs/readmeImages/SLEInUbuntu.png)

¿En Linux o macOS, SLE es usable a través de [Wine](https://www.winehq.org)?:
> Según lo que he probado por mi cuenta, sí, pero Wine no se lleva bien con cosas como mover mucho la ventana, al menos lo he probado en [Ubuntu 22.04](https://ubuntu.com), no sé en otras distros, basadas en Debian o no.

¿Puedo usar SLE para mi mod?:
> ¡Por supuesto! Me encantaría ver SLE como base para un mod, pero ten en cuenta que aunque usa SCE como base, SLE ha sido muy modificado. Esto puede que no lo haga la mejor opción para mods típicos de FNF'. Sin embargo, si buscas crear mods que aprovechen lo que el motor puede hacer, ¡siéntete libre de experimentar! Solo recuerda darme créditos donde subas el mod.\
> **Dónde NO permitiría que se use SLE es para**
> - Mods de Dave And Bambi
> - En la creación o distribución de malware o software malicioso

----
SLE no está hecho para competir con otros motores como [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine), ~~[SB Engine](https://github.com/Stefan2008Git/FNF-SB-Engine)~~, [Codename Engine](https://github.com/FNF-CNE-Devs/CodenameEngine) (¿Me pregunto por qué los desarrolladores de CNE descompilaron SLE? No tenían razón para hacerlo), u otros motores existentes. En cambio, SLE está diseñado para facilitar tareas que de otro modo serían desafiantes y permitirte crear modcharts como los hechos en NotITG o Hitman's AD, con características más allá de simplemente mover las notas o la ventana.

En un futuro cercano, puedes esperar encontrar todo el código C++ de SLE disponible como una biblioteca de Haxe en Haxelib. Esto te permitirá usarlo en tus proyectos no relacionados con FNF'. Lo mismo ocurre con WinSL. :3:

[SL-Windows-API](https://lib.haxe.org/p/sl-windows-api/) (Funciones de la API de Windows en Haxe).

### Creditos:

Slushi, no es ni mi personaje original (OC) ni un personaje que me pertenezca. Ella es de la serie web [Chikn Nuggit](https://twitter.com/chikn_nuggit?t=YohD2quSHtamaiJyzT-FOA&s=09), de Kyra Kupetsky. No tengo permiso directo para usar a Slushi en este motor, todos los derechos sobre el personaje pertenecen a ellos.

Slushi Engine usa codigo de [Codename Engine](https://github.com/FNF-CNE-Devs/CodenameEngine) (SC Engine tambien, pero solo me quiero referir al codigo que use en SLE) y de [HITMANS: THE ANNIHILATE AND DESTROY PROJECT](https://gamebanana.com/mods/453997).

Para mas detalles de los creditos, [PORFA revisa esto en el README de SCE](https://github.com/glowsoony/SC-Engine?tab=readme-ov-file#credits-to-other-engine--most-engine-features-and-where-they-come-from-sorry-if-only-now-the-credits-exist-extermely-sorry)

[SC Engine](https://github.com/glowsoony/SC-Engine), es solo la base de SLE, no es mío, es de ~~[EdwhakKB](https://github.com/EdwhakKB)~~ [Glowsoony](https://github.com/glowsoony), tengo su permiso completo para usar SLE en este maravilloso motor.

----

<details>
<summary>...</summary>
"Gracias [...] por siempre apoyarme en este proyecto desde que se me ocurrió la idea de iniciarlo, y también a ti [...], incluso si ya no estás en este mundo." 
- Andrés.
</details>

----

## Características del Slushi Engine:
- Un HUD hecho específicamente para canciones usando el modo NotITG, para que se vea como el de ese juego, facilitando deshacerte del look normal de FNF'.
- Nuevos shaders disponibles solo en SLE.
- Un extenso número de nuevas funciones en Lua para que experimentes al crear tus canciones o mods.
- Basado en las versiones más recientes de SC Engine.
- ~~Pantalla de resultados del FNF' V-SLICE (Sacado de [P-Slice](https://github.com/mikolka9144/P-Slice))~~ (Ahora SCE tiene esto, ya no es una característica de SLE)
