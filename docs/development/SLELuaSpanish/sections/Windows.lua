-- Windows.lua -- Versión 1.1.0 -- Ultima modificación: 27/12/2024

function resetAllCPPFunctions()
    --[[
    Restablece todas las funciones CPP.
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
    image: Nombre de la imagen a usar como fondo, si pones "defualt", se pone el fondo anterior o original (string).
    ]]--
end

function winScreenCapture(nameToSave)
    --[[
    Captura una pantalla de la ventana del juego.
    nameToSave: Nombre del archivo para guardar la captura (string).
    ]]--
end

function setDesktopWindowsPos(mode, value)
    --[[
    Mueve las iconos del escritorio en una dirección específica.
    mode: Dirección para mover ("X", "Y", "XY").
    value: Cantidad de píxeles a mover.
    ]]--
end

function doTweenDesktopWindowsPos(mode, value, duration, ease)
    --[[
    Realiza un tween en las ventanas del escritorio.
    mode: Dirección del tween ("X", "Y", "XY").
    value: Valor final del tween.
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

function sendNotification(desc, title)
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
    window: Nombre de la ventana ("desktop", "taskBar") (string).
    ]]--
end

-- EFECTOS GDI DE WINDOWS -------------------------------------------------------------
--- En Windows, existe una manera de generar graficos, por medio de las funciones GDI
--- que estan en la API de Windows.
--- Son efectos vistos en virus o malware que esta hecho con ese proposito de generar tales efectos
--- Algunos de los malwares usan estos efectos pueden ser:
--- - MENZ
--- - Sulfoxide.exe
--- 
--- Los efectos GDI, hacen un uso intensivo de la CPU
--- por eso en Slushi Engine, estos efectos corren en un hilo aparte del CPU para que
--- no afecte al juego principal.
--- 
--- ============================================================
--- Los efectos incluidos en SLE a la fecha de [19/12/2024] son:
--- - DrawIcons - Dibuja iconos de Windows en la pantalla en posiciones aleatorias.
--- - ScreenBlink - Realiza un efecto de parpadeo en la pantalla.
--- - ScreenGlitches - Realiza un efecto de errores graficos en la pantalla.
--- - ScreenShake - Realiza un efecto de agitación en la pantalla.
--- - ScreenTunnel - Realiza un efecto de túnel en la pantalla.
--- ============================================================
--- 
--- Los efectos GDI ocurren a pantalla completa modificnado todo lo que se muestre en esta
--- por ende pueden ser incomodos para algunos jugadores, por lo que se recomienda usarlos con precaucion. 
--- Igualmente el jugador tiene la posibilidad de desactivar
--- estos efectos en las opciones de Slushi Engine.

function startGDIThread()
    --[[
    Prepara un hilo del CPU separado para correr los efectos GDI.
    ]]--
end -- USE_CAREFULLY

function prepareGDIEffect(effect, wait)
    --[[
    Inializa un efecto GDI, mas no necesariamente se muestra en la pantalla.
    effect: Nombre del efecto GDI (string).
    wait: Tiempo en milisegundos para esperar a que el efecto se muestre en pantalla, esto para 
    alentar el efecto cuanto mas alto sea el valor de wait (float). 
    ]]--
end -- USE_CAREFULLY

function setGDIEffectWaitTime(effect, wait)
    --[[
    Establece el tiempo en milisegundos para esperar a que el efecto se muestre en pantalla
    effect: Nombre del efecto GDI (string).
    wait: Tiempo en milisegundos para esperar a que el efecto se muestre en pantalla (float).
    ]]--
end -- USE_CAREFULLY

function enableGDIEffect(effect, enabled)
    --[[
    Habilita o deshabilita un efecto GDI.
    effect: Nombre del efecto GDI (string).
    enabled: true para habilitar, false para deshabilitar.
    ]]--
end -- USE_CAREFULLY

function removeGDIEffect(effect)
    --[[
    Elimina un efecto GDI.
    effect: Nombre del efecto GDI (string).
    ]]--
end -- USE_CAREFULLY