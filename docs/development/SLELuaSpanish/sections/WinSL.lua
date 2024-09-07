-- WinSL.lua -- Version 1.0 -- Ultima modificación: 23/08/2024

function winSL_console_getVersion()
    --[[
    Obtiene la versión de WinSL.
    ]]--
end

function winSL_console_printLetterByLetter(text, time)
    --[[
    Imprime un texto letra por letra en la terminal.
    text: El texto a imprimir (string).
    time: Tiempo entre cada letra (float).
    ]]--
end

function winSL_console_showWindow(mode)
    --[[
    Muestra u oculta la ventana de la terminal.
    mode: true para mostrar, false para ocultar.
    ]]--
end

function winSL_console_disableResize()
    --[[
    Desactiva la opción de redimensionar la ventana de la terminal.
    ]]--
end

function winSL_console_disableClose()
    --[[
    Desactiva la opción de cerrar la ventana de la terminal.
    ]]--
end

function winSL_console_setTitle(title)
    --[[
    Establece el título de la ventana de la terminal.
    title: El título a establecer (string).
    ]]--
end

function winSL_console_setWinPos(mode, value)
    --[[
    Establece la posición de la ventana de la terminal.
    mode: Dirección para establecer la posición ("X", "Y").
    value: Valor en píxeles de la posición (int).
    ]]--
end

function winSL_console_tweenWinPos(mode, value, time, ease)
    --[[
    Haz un tween de la ventana de la terminal.
    mode: Dirección para el tween ("X", "Y").
    value: Valor final de la posición (int).
    time: Duración del tween (float).
    ease: Tipo de easing (por defecto "linear").
    ]]--
end

function winSL_console_getWinPos(mode)
    --[[
    Obtiene la posición actual de la ventana de la terminal.
    mode: Dirección para obtener la posición ("X", "Y").
    ]]--
end

function winSL_console_centerWindow()
    --[[
    Centra la ventana de la terminal en la pantalla.
    ]]--
end
