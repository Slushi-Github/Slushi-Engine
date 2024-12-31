-- Shaders.lua -- Versión 1.1.0 -- Ultima modificación: 23/12/2024

function addShader3DToCamStrumsAndCamNotes()
    --[[
    Añade un shader 3D a la camara de los strums y las notas.
    ]]--
end

function addShader3DToNotes()
    --[[
    Añade un shader 3D a las notas. (acortacion de addShader3DToCamStrumsAndCamNotes)
    ]]--
end

function removeShader3DFromCamStrumsAndCamNotes()
    --[[
    Elimina el shader 3D de la camara de los strums y las notas.
    ]]--
end

function removeShader3DFromNotes()
    --[[
    Elimina el shader 3D de las notas (acortacion de removeShader3DFromCamStrumsAndCamNotes).
    ]]--
end

function setNotesShader3DProperty(prop, value)
    --[[
    Establece una propiedad del shader 3D de las notas.
    prop: La propiedad a establecer (string).
    value: El valor de la propiedad (Dynamic).
    ]]--
end

function doTweenNotesShader3D(prop, tag, value, time, ease)
    --[[
    Realiza un tween en una propiedad del shader 3D de las notas.
    prop: La propiedad a establecer (string).
    tag: La etiqueta de la interpolación (string).
    value: El valor final del tween (Dynamic).
    time: El tiempo de la interpolación (float).
    ease: El tipo de easing a aplicar (por defecto "linear") (string).
    ]]--
end

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