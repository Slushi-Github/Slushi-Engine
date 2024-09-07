-- Shaders.lua -- Versión 1.0 -- Ultima modificación: 23/08/2024

function addWhiteShaderToNotes()
    --[[
    Añade un shader blanco a las notas.
    ]]--
end

function removeWhiteShaderFromNotes()
    --[[
    Elimina el shader blanco de las notas.
    ]]--
end

function doTweenNotesWhiteShaderInAmount(tag, value, time, easeStr)
    --[[
    Realiza un tween en la cantidad de shader blanco aplicado a las notas.
    tag: La etiqueta de la interpolación (string).
    value: El valor final del tween (Float).
    time: El tiempo de la interpolación (float).
    easeStr: El tipo de easing a aplicar (por defecto "linear") (string).
    ]]--
end

function flashNotesWhiteShader(value, time, easeStr)
    --[[
    Hace un flash del shader blanco en las notas.
    value: El valor final del flash (Float).
    time: El tiempo que durará el flash (float).
    easeStr: El tipo de easing a aplicar (default "linear") (string).
    ]]--
end

function setShaderToFlxGame(shaderName)
    --[[
    Aplica un shader específico a todo el juego.
    shaderName: El nombre del shader a aplicar (string).
    ]]--
end