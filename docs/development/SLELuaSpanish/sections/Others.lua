-- Others.lua -- Version: 1.1.0 -- Ultima modificación: 2/9/2024

function printInGameplay(text, time)
    --[[
    Muestra un texto en la pantalla de juego durante un tiempo específico, al estilo de NotITG.
    text: El texto que se mostrará (string).
    time: El tiempo que el texto permanecerá en pantalla (float).
    ]]--
end

function tweenObjectFromSLEHUD(mode, value, time, ease)
    --[[
    Realiza un tween en un objeto del HUD de SLE.
    mode: El modo del tween (X, Y, ANGLE, BLACKALPHA) (string).
    value: El valor del tween (float).
    time: El tiempo del tween (float).
    ease: El tipo de easing a aplicar (por defecto "linear") (string).
    ]]--
end

function luaMathCosecant(angle)
    --[[
    retorna el calculo de la cosecante de un ángulo dado (float).
    angle: El ángulo en radianes (float).
    ]]--
end

function showFPSText(mode)
    --[[
    Muestra u oculta el texto de FPS en pantalla.
    mode: Booleano para mostrar (true) u ocultar (false) el texto de FPS.
    ]]--
end

function getOSVersion()
    --[[
    Obtiene la versión del sistema operativo.
    return: La versión del sistema operativo (string).
    ]]--
end

function CopyCamera(camTag, camToCopy)
    --[[
    Crea una nueva cámara, igual a una ya existente, con una etiqueta específica.
    camTag: La etiqueta de la cámara a crear (string).
    camToCopy: La etiqueta de la cámara a copiar (string).
    ]]--
end

function removeCopyCamera(camTag)
    --[[
    Elimina una cámara existente con una etiqueta específica.
    camTag: La etiqueta de la cámara a eliminar (string).
    ]]--
end

function tweenNumer(tag, startNum, endNum, duration, ease)
    --[[
    Realiza un tween de un numero a otro de mayor o menor valor.
    tag: La etiqueta del objeto (string).
    startNum: El valor inicial del tween (float).
    endNum: El valor final del tween (float).
    duration: El tiempo del tween (float).
    ease: El tipo de easing a aplicar (por defecto "linear") (string).
    ]]--
end