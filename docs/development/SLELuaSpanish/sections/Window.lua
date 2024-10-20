-- Window.lua -- Versión 1.0 -- Ultima modificación: 23/08/2024

function windowTrans(trans, camToApply)
    --[[
    Activa o desactiva la transparencia de la ventana.
    trans: Booleano que indica si activar (true) o desactivar (false) la transparencia.
    camToApply: Nombre de la cámara a la cual se aplicará el efecto de transparencia (string).
    ]]--
end

function windowAlpha(alpha)
    --[[
    Ajusta la opacidad de la ventana.
    alpha: Valor de opacidad a establecer (float).
    ]]--
end

function doTweenWinAlpha(toValue, duration, ease)
    --[[
    Realiza un tween en la opacidad de la ventana.
    fromValue: Valor inicial de opacidad (float).
    toValue: Valor final de opacidad (float).
    duration: Duración del tween (float).
    ease: Tipo de easing a aplicar (string).
    ]]--
end

function centerWindow()
    --[[
    Centra la ventana en la pantalla.
    ]]--
end

function setWindowVisible(visible)
    --[[
    Muestra u oculta la ventana.
    visible: Booleano que indica si la ventana debe ser visible (true) o no (false).
    ]]--
end -- USE_CAREFULLY

function winAlert(text, title)
    --[[
    Muestra una alerta en la ventana.
    text: Texto del mensaje de alerta (string).
    title: Título de la ventana de alerta (string).
    ]]--
end

function canResizableWindow(mode)
    --[[
    Habilita o deshabilita la capacidad de cambiar el tamaño de la ventana.
    mode: Booleano que indica si habilitar (true) o deshabilitar (false) la capacidad de redimensionar.
    ]]--
end

function windowMaximized(mode)
    --[[
    Maximiza o restaura la ventana.
    mode: Booleano que indica si maximizar (true) o restaurar (false) la ventana.
    ]]--
end

function DisableCloseButton(mode)
    --[[
    Habilita o deshabilita el botón de cierre de la ventana.
    mode: Booleano que indica si deshabilitar (true) o habilitar (false) el botón de cierre.
    ]]--
end

function doTweenWinPos(mode, tag, value, duration, ease)
    --[[
    Realiza un tween en la posición de la ventana.
    mode: La propiedad del tween ("X" o "Y") (string).
    tag: Etiqueta del tween (string).
    value: Valor final de la posición (int).
    duration: Duración del tween (float).
    ease: Tipo de easing a aplicar (string).
    ]]--
end

function resetWindowParameters()
    --[[
    Restaura los parámetros de la ventana a su configuración predeterminada.
    ]]--
end

function doTweenWinSize(mode, toValue, duration, ease)
    --[[
    Realiza un tween en el tamaño de la ventana.
    mode: La propiedad del tween ("WIDTH", "W", "HEIGHT", "H") (string).
    toValue: Valor final del tamaño (float).
    duration: Duración del tween (float).
    ease: Tipo de easing a aplicar (por defecto "linear") (string).
    ]]--
end

function winTitle(text)
    --[[
    Cambia el título de la ventana.
    text: Nuevo título de la ventana (si pones "defualt", se pone el nombre por defecto del programa) (string).
    ]]--
end

function setWindowPos(mode, value)
    --[[
    Establece la posición de la ventana.
    mode: La propiedad a establecer ("X" o "Y") (string).
    value: Valor de la posición (int).
    ]]--
end

function getWindowPos(mode)
    --[[
    Obtiene la posición de la ventana.
    mode: La propiedad a obtener ("X" o "Y") (string).
    ]]--
    return 0
end

function getScreenSize(mode)
    --[[
    Obtiene el tamaño de la pantalla.
    mode: La propiedad a obtener ("WIDTH", "W", "HEIGHT", "H") (string).
    ]]--
    return 0
end

function getWindowSize(mode)
    --[[
    Obtiene el tamaño de la ventana.
    mode: La propiedad a obtener ("WIDTH", "W", "HEIGHT", "H") (string).
    ]]--
    return 0
end

function setWindowSize(mode, value)
    --[[
    Establece el tamaño de la ventana.
    mode: La propiedad a establecer ("WIDTH", "W", "HEIGHT", "H") (string).
    value: Valor del tamaño (int).
    ]]--
end

function setWindowBorderColor(r, g, b, mode)
    --[[
    Establece el color del borde de la ventana (solo Windows 11).
    r: Valor rojo (int).
    g: Valor verde (int).
    b: Valor azul (int).
    mode: Booleano que indica si permitir cambios de color con las notas (true) o no (false).
    ]]--
end
