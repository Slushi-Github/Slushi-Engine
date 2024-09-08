-- Windows.lua -- Versión 1.0 -- Ultima modificación: 23/08/2024

function resetAllCPPFunctions()
    --[[
    Restablece todas las funciones CPP.
    ]]--
end

function getRAM()
    --[[
    Obtiene la cantidad de memoria RAM disponible en el sistema.
    ]]--
end

function hideTaskBar(hide)
    --[[
    Oculta o muestra la barra de tareas.
    hide: true para ocultar, false para mostrar.
    ]]--
end

function setWallpaper(image)
    --[[
    Establece una imagen como fondo de pantalla.
    image: Nombre de la imagen a usar como fondo (string).
    ]]--
end

function winScreenCapture(nameToSave)
    --[[
    Captura una pantalla de la ventana del juego.
    nameToSave: Nombre del archivo para guardar la captura (string).
    ]]--
end

function setOldWindowsWallpaper()
    --[[
    Restaura el fondo de pantalla anterior de Windows.
    ]]--
end

function moveDesktopWindows(mode, value)
    --[[
    Mueve las iconos del escritorio en una dirección específica.
    mode: Dirección para mover ("X", "Y", "XY").
    value: Cantidad de píxeles a mover.
    ]]--
end

function doTweenDesktopWindows(mode, toValue, duration, ease)
    --[[
    Realiza un tween en las ventanas del escritorio.
    mode: Dirección del tween ("X", "Y", "XY").
    toValue: Valor final del tween.
    duration: Duración del tween.
    ease: Tipo de easing (por defecto "linear").
    ]]--
end

function doTweenDesktopWindowsAlpha(fromValue, toValue, duration, ease)
    --[[
    Realiza un tween de transparencia en los iconos del escritorio.
    fromValue: Valor inicial de transparencia.
    toValue: Valor final de transparencia.
    duration: Duración del tween.
    ease: Tipo de easing (por defecto "linear").
    ]]--
end

function doTweenTaskBarAlpha(fromValue, toValue, duration, ease)
    --[[
    Realiza un tween de transparencia en la barra de tareas.
    fromValue: Valor inicial de transparencia.
    toValue: Valor final de transparencia.
    duration: Duración del tween.
    ease: Tipo de easing (por defecto "linear").
    ]]--
end

function getDesktopWindowsPos(mode)
    --[[
    Obtiene la posición de los iconos del escritorio en una dirección específica.
    mode: Dirección para obtener ("X", "Y").
    ]]--
end

function getWindowsVersion()
    --[[
    Obtiene el numero de la versión de Windows en el sistema.
    ]]--
end

function sendNoti(desc, title)
    --[[
    Envía una notificación en Windows.
    desc: Descripción de la notificación (string).
    title: Título de la notificación (string).
    ]]--
end

function hideDesktopIcons(hide)
    --[[
    Oculta o muestra los iconos del escritorio.
    hide: true para ocultar, false para mostrar.
    ]]--
end

function setDesktopWindowsAlpha(alpha)
    --[[
    Establece la transparencia de los iconos del escritorio.
    alpha: Valor de transparencia (float).
    ]]--
end

function setTaskBarAlpha(alpha)
    --[[
    Establece la transparencia de la barra de tareas.
    alpha: Valor de transparencia (float).
    ]]--
end

function setOtherWindowLayeredMode(window)
    --[[
    Establece el modo de capa de otra ventana de Windows.
    window: Nombre de la ventana ("desktop", "taskBar").
    ]]--
end

---------------------------------------------------------------

function windowsEffectModifier(tag, gdiEffect, activeEffect)
    --[[
    Modifica un efecto GDI en Windows.
    tag: Etiqueta del efecto (string).
    gdiEffect: Tipo de efecto GDI (string).
    activeEffect: true para activar, false para desactivar.
    ]]--
end -- USE_CAREFULLY

function setWinEffectProperty(tag, prop, value)
    --[[
    Establece una propiedad para un efecto GDI en Windows.
    tag: Etiqueta del efecto (string).
    prop: Propiedad a modificar (string).
    value: Valor a establecer (dynamic).
    ]]--
end -- USE_CAREFULLY

function setTitleTextToWindows(titleText)
    --[[
    Establece el texto del título en la ventana de Windows.
    titleText: Texto del título (string).
    ]]--
end -- USE_CAREFULLY
