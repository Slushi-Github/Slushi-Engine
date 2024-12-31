-- Window.lua -- Versión 1.1.0 -- Ultima modificación: 23/12/2024
--[[
    [Window.lua] es una seccion
]] --

function windowTransparent(transparent, camToApply)
    --[[
    Activa o desactiva la transparencia de la ventana.
    transparent: Booleano que indica si activar (true) o desactivar (false) la transparencia.
    camToApply: Nombre de la cámara a la cual se aplicará el efecto de transparencia (string).
    ]] --
end

function setWindowAlpha(alpha)
    --[[
    Ajusta la opacidad de la ventana.
    alpha: Valor de opacidad a establecer (float).
    ]] --
end

function doTweenWinAlpha(value, duration, ease)
    --[[
    Realiza un tween en la opacidad de la ventana.
    value: Valor de la opacidad (float).
    duration: Duración del tween (float).
    ease: Tipo de easing a aplicar (string).
    ]] --
end

function centerWindow()
    --[[
    Centra la ventana en la pantalla.
    ]] --
end

function setMainWindowVisible(visible)
    --[[
    Muestra u oculta la ventana.
    visible: Booleano que indica si la ventana debe ser visible (true) o no (false).
    ]] --
end    -- USE_CAREFULLY

function windowAlert(text, title)
    --[[
    Muestra una alerta en la ventana.
    text: Texto del mensaje de alerta (string).
    title: Título de la ventana de alerta (string).
    ]] --
end

function resizableWindow(mode)
    --[[
    Habilita o deshabilita la capacidad de cambiar el tamaño de la ventana.
    mode: Booleano que indica si habilitar (true) o deshabilitar (false) la capacidad de redimensionar.
    ]] --
end

function windowMaximized(mode)
    --[[
    Maximiza o restaura la ventana.
    mode: Booleano que indica si maximizar (true) o restaurar (false) la ventana.
    ]] --
end

function doTweenWinPos(mode, tag, value, duration, ease)
    --[[
    Realiza un tween en la posición de la ventana.
    mode: La propiedad del tween ("X" o "Y") (string).
    tag: Etiqueta del tween (string).
    value: Valor final de la posición (int).
    duration: Duración del tween (float).
    ease: Tipo de easing a aplicar (string).
    ]] --
end

function centerWindowTween(tag, duration, ease)
    --[[
    Centra la ventana en la pantalla con un tween.
    tag: Etiqueta del tween (string).
    duration: Duración del tween (float).
    ease: Tipo de easing a aplicar (string).
    ]] --
end

function resetWindowParameters()
    --[[
    Restaura los parámetros de la ventana a su configuración predeterminada.
    ]] --
end

function doTweenWinSize(mode, toValue, duration, ease)
    --[[
    Realiza un tween en el tamaño de la ventana.
    mode: La propiedad del tween ("WIDTH", "W", "HEIGHT", "H") (string).
    toValue: Valor final del tamaño (float).
    duration: Duración del tween (float).
    ease: Tipo de easing a aplicar (por defecto "linear") (string).
    ]] --
end

function setWindowTitle(text)
    --[[
    Cambia el título de la ventana.
    text: Nuevo título de la ventana (si pones "defualt", se pone el nombre por defecto del programa) (string).
    ]] --
end

function getWindowTitle()
    --[[
    Obtiene el título de la ventana.
    return: El título de la ventana (string).
    ]] --
end

function setWindowPos(mode, value)
    --[[
    Establece la posición de la ventana.
    mode: La propiedad a establecer ("X" o "Y") (string).
    value: Valor de la posición (int).
    ]] --
end

function getWindowPos(mode)
    --[[
    Obtiene la posición de la ventana.
    mode: La propiedad a obtener ("X" o "Y") (string).
    return: La posición de la ventana (int).
    ]] --
end

function getScreenSize(mode)
    --[[
    Obtiene el tamaño de la pantalla.
    mode: La propiedad a obtener ("WIDTH", "W", "HEIGHT", "H") (string).
    return: El tamaño de la pantalla (int).
    ]] --
end

function getWindowSize(mode)
    --[[
    Obtiene el tamaño de la ventana.
    mode: La propiedad a obtener ("WIDTH", "W", "HEIGHT", "H") (string).
    return: El tamaño de la ventana (int).
    ]] --
end

function setWindowSize(mode, value)
    --[[
    Establece el tamaño de la ventana.
    mode: La propiedad a establecer ("WIDTH", "W", "HEIGHT", "H") (string).
    value: Valor del tamaño (int).
    ]] --
end

function setWindowBorderColor(rgb, mode)
    --[[
    Establece el color del borde de la ventana (solo Windows 11).
    rgb: Color del borde (Array<Int>).
    mode: Booleano que indica si permitir cambios de color con las notas (true) o no (false).
    ]] --
end

function tweenWindowBorderColor(fromColor, toColor, duration, ease, mode)
    --[[
    Realiza un tween en el color del borde de la ventana (solo Windows 11).
    fromColor: Color inicial del borde (Array<Int>).
    toColor: Color final del borde (Array<Int>).
    duration: Duración del tween (float).
    ease: Tipo de easing a aplicar (string).
    mode: Booleano que indica si permitir cambios de color con las notas (true) o no (false).
    ]] --
end
