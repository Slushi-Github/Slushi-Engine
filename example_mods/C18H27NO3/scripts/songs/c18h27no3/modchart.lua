-- Generated by StepMania to FNF Converter v1.3.5 (By Slushi) --

function onCreatePost()
    startGDIThread(); -- :3
    prepareGDIEffect("ScreenGlitches", 0);

    resizableWindow(false);
    addShader3DToNotes();
    initShaderFromSource("chromAB", "ChromAbBlueSwapEffect");
    initShaderFromSource("threeShader", "ThreeDEffect");
    initShaderFromSource("glitch", "GlitchedEffect");
    initShaderFromSource("mosaic", "MosaicEffect");
    initShaderFromSource("angel", "AngelEffect");
    initShaderFromSource("individualGlitches", "IndividualGlitchesEffect");

    setCameraShader(camNoteStuff, "chromAB");
    setCameraShader(camSLEHUD, "chromAB");
    setCameraShader(camThings2, "chromAB");
    setCameraShader(camWaterMark, "chromAB");

    setCameraShader(camSLEHUD, "threeShader");
    setCameraShader(camThings2, "threeShader");
    setCameraShader(camWaterMark, "threeShader");

    setCameraShader(camNoteStuff, "mosaic");
    setCameraShader(camSLEHUD, "mosaic");
    setCameraShader(camThings2, "mosaic");
    setCameraShader(camWaterMark, "mosaic");

    setCameraShader(camNoteStuff, "angel");
    setCameraShader(camSLEHUD, "angel");
    setCameraShader(camThings2, "angel");
    setCameraShader(camWaterMark, "angel");

    setProperty('camZooming', false);
    setProperty('healthBar.visible', false);
    setProperty('healthBarBG.visible', false);
    setProperty('scoreTxtSprite.visible', false);
    setProperty('scoreTxt.visible', false);
    setProperty('timeBar.visible', false);
    setProperty('timeBarBG.visible', false);
    setProperty('timeTxt.visible', false);
    setProperty('camGame.visible', false);
    setProperty('camHUD.visible', false);
    tweenObjectFromSLEHUD("BLACKALPHA", 1, 0.1, "linear");
    setProperty('camSLEHUD.alpha', 0);
    setProperty('camThings2.alpha', 0);
    setPropertyFromClass("slushi.slushiUtils.SlushiEngineHUD", "instance.slushiSprite.visible", false);

    makeLuaText("mtModsText", "TEST", 0, 0.0, 0.0);
    setTextFont("mtModsText", "vcr.ttf");
    setTextSize("mtModsText", 16);
    setScrollFactor("mtModsText", 0.0, 0.0)
    setTextAlignment("mtModsText", "CENTER");
    screenCenter("mtModsText", "XY");
    addLuaText("mtModsText");
    setObjectCamera("mtModsText", camThings2);
    setProperty("mtModsText.y", getProperty("mtModsText.y") + 60);

    for i = 1, 10 do
        makeLuaSprite("slushiCodeImage" .. i, "slushiSongs/c18h27no3/slushiCodes/slushiCode" .. i, 0, 0);
        screenCenter("slushiCodeImage" .. i, "XY");
        addLuaSprite("slushiCodeImage" .. i, false);
        setObjectCamera("slushiCodeImage" .. i, camThings);
        setProperty("slushiCodeImage" .. i .. ".alpha", 0);
    end
end

local beat = 0;
local useNegative = false;
function onBeatHit()
    beat = curBeat;
    if curBeat >= 12 and curBeat <= 44 then
        if curBeat % 4 == 0 then
            useNegative = not useNegative;
            local randomNumber = getRandomInt(1, 10);
            local randomNumber2 = getRandomInt(0, 256);
            local randomNumber3 = getRandomInt(350, 450);
            startTween("tweenSLImgTween1A" .. randomNumber2, "slushiCodeImage" .. randomNumber, { alpha = 1 }, 1,
                { ease = "linear" });
            setProperty("slushiCodeImage" .. randomNumber .. ".y",
                getProperty("slushiCodeImage" .. randomNumber .. ".y") + 420);
            if useNegative then
                setProperty("slushiCodeImage" .. randomNumber .. ".x",
                    getProperty("slushiCodeImage" .. randomNumber .. ".x") - randomNumber3);
            else
                setProperty("slushiCodeImage" .. randomNumber .. ".x",
                    getProperty("slushiCodeImage" .. randomNumber .. ".x") + randomNumber3);
            end
            setProperty("slushiCodeImage" .. randomNumber .. ".angle", 5);
            startTween("tweenSLImgTween2A" .. randomNumber2, "slushiCodeImage" .. randomNumber, { y = -1200 }, 8,
                { ease = "linear" });
        end
    end

    if curBeat == 60 then
        tweenShaderFloat("chromABTweenA", "chromAB", "strength", 0.005, 1, "linear");
    end

    if curBeat == 62 then
        tweenShaderFloat("chromABTween2", "chromAB", "strength", -0.005, 1, "linear");
    end

    if curBeat == 64 then
        tweenShaderFloat("chromABTween3", "chromAB", "strength", 0.005, 1, "linear");
    end

    if curBeat == 66 then
        tweenShaderFloat("chromABTween4", "chromAB", "strength", -0.005, 1, "linear");
    end

    if curBeat == 68 then
        tweenShaderFloat("chromABTween5", "chromAB", "strength", 0.010, 1, "linear");
    end

    if curBeat == 73 then
        tweenShaderFloat("chromABTween6", "chromAB", "strength", 0, 2, "elasticInOut");
    end

    if curBeat == 78 then
        setProperty("camSLEHUD.zoom", getProperty("camSLEHUD.zoom") + 15);
        setProperty("camSLEHUD.angle", 10);
        setProperty('camSLEHUD.alpha', 1);

        setProperty("camThings2.zoom", getProperty("camThings2.zoom") + 15);
        setProperty("camThings2.angle", 10);
        setProperty('camThings2.alpha', 1);
        tweenObjectFromSLEHUD("BLACKALPHA", 0.8, 1.5, "linear");
        startTween("camTween", "camSLEHUD", { zoom = 1 }, 1, { ease = "linear" });
        startTween("camTween2", "camSLEHUD", { angle = 0 }, 1, { ease = "linear" });
        startTween("camTween3", "camThings2", { zoom = 1 }, 1, { ease = "linear" });
        startTween("camTween4", "camThings2", { angle = 0 }, 1, { ease = "linear" });
    end

    if curBeat >= 80 and curBeat <= 144 then
        if curBeat % 2 == 0 then
            setWindowPos("X", getWindowPos("X") - 20);
            doTweenWinPos("X", "windowTween1", getWindowPos("X") + 20, 0.2, "linear");

            setWindowPos("Y", getWindowPos("Y") - 20);
            doTweenWinPos("Y", "windowTween2", getWindowPos("Y") + 20, 0.2, "linear");
        else
            setWindowPos("X", getWindowPos("X") + 20);
            doTweenWinPos("X", "windowTween3", getWindowPos("X") - 20, 0.2, "linear");

            setWindowPos("Y", getWindowPos("Y") + 20);
            doTweenWinPos("Y", "windowTween4", getWindowPos("Y") - 20, 0.2, "linear");
        end
    end

    if curBeat == 110 then
        tweenShaderFloat("mosaicTween", "mosaic", "strength", 0, 1, "circoutin", 8);
    end

    if curBeat == 126 then
        tweenShaderFloat("mosaicTween2", "mosaic", "strength", 0, 1, "circoutin", 8);
    end

    if curBeat == 136 then
        tweenShaderFloat("mosaicTween3", "mosaic", "strength", 6, 0.6, "backinout");
    end

    if curBeat == 137 then
        tweenShaderFloat("mosaicTween4", "mosaic", "strength", -6, 0.6, "backinout");
    end

    if curBeat == 140 then
        tweenShaderFloat("mosaicTween5", "mosaic", "strength", 0, 0.6, "backinout");
    end

    if curBeat == 144 then
        setCameraShader(camNoteStuff, "individualGlitches");
        setCameraShader(camSLEHUD, "individualGlitches");
        setCameraShader(camThings2, "individualGlitches");
        setCameraShader(camWaterMark, "individualGlitches");
        tweenShaderFloat("individualGlitchesTween", "individualGlitches", "binaryIntensity", 0.2, 0.6, "linear");
    end

    if curBeat == 208 then
        removeCameraShader(camNoteStuff, "individualGlitches");
        removeCameraShader(camSLEHUD, "individualGlitches");
        removeCameraShader(camThings2, "individualGlitches");
        removeCameraShader(camWaterMark, "individualGlitches");
        startTween("camTween1", "camSLEHUD", { angle = 0 }, 0.8, { ease = "linear" });
        startTween("camTween2", "camThings2", { angle = 0 }, 0.8, { ease = "linear" });
        startTween("camTween3", "camWaterMark", { angle = 0 }, 0.8, { ease = "linear" });
        centerWindowTween("centerWindowTween", 0.8, "linear");
    end

    if curBeat == 212 then
        tweenShaderFloat("chromABTween7", "chromAB", "strength", 0, 1, "linear", -0.015);
        tweenShaderFloat("threeShaderTween2", "threeShader", "yrot", 0, 0.6, "linear", -0.4);
        setNotesShader3DProperty("yrot", 0.4);
        doTweenNotesShader3D("y", "threeShaderTween4", 0, 0.6, "linear");
        setWindowPos("X", getWindowPos("X") - 20);
        doTweenWinPos("X", "windowTween1", getWindowPos("X") + 20, 0.2, "linear");
        setDesktopWindowsPos("X", getDesktopWindowsPos("X") - 40);
        doTweenDesktopWindowsPos("X", getDesktopWindowsPos("X") + 40, 0.2, "linear");
    end
    if curBeat == 220 then
        tweenShaderFloat("chromABTween8", "chromAB", "strength", 0, 1, "linear", 0.015);
        tweenShaderFloat("threeShaderTween3", "threeShader", "yrot", 0, 0.6, "linear", 0.4);
        setNotesShader3DProperty("yrot", -0.4);
        doTweenNotesShader3D("y", "threeShaderTween5", 0, 0.6, "linear");
        setWindowPos("X", getWindowPos("X") + 20)
        doTweenWinPos("X", "windowTween2", getWindowPos("X") - 20, 0.2, "linear");
        setDesktopWindowsPos("X", getDesktopWindowsPos("X") + 40);
        doTweenDesktopWindowsPos("X", getDesktopWindowsPos("X") - 40, 0.2, "linear");
    end
    if curBeat == 228 then
        tweenShaderFloat("chromABTween7", "chromAB", "strength", 0, 1, "linear", -0.015);
        tweenShaderFloat("threeShaderTween4", "threeShader", "xrot", 0, 0.6, "linear", -0.4);
        setNotesShader3DProperty("xrot", 0.4);
        doTweenNotesShader3D("x", "threeShaderTween6", 0, 0.6, "linear");
        setWindowPos("Y", getWindowPos("Y") - 20);
        doTweenWinPos("Y", "windowTween3", getWindowPos("Y") + 20, 0.2, "linear");
        setDesktopWindowsPos("Y", getDesktopWindowsPos("Y") - 40);
        doTweenDesktopWindowsPos("Y", getDesktopWindowsPos("Y") + 40, 0.2, "linear");
    end
    if curBeat == 240 then
        tweenShaderFloat("chromABTween8", "chromAB", "strength", 0, 1, "linear", 0.015);
        tweenShaderFloat("threeShaderTween5", "threeShader", "xrot", 0, 0.6, "linear", 0.4);
        setNotesShader3DProperty("xrot", -0.4);
        doTweenNotesShader3D("x", "threeShaderTween7", 0, 0.6, "linear");
        setWindowPos("Y", getWindowPos("Y") + 20);
        doTweenWinPos("Y", "windowTween4", getWindowPos("Y") - 20, 0.2, "linear");
        setDesktopWindowsPos("Y", getDesktopWindowsPos("Y") + 40);
        doTweenDesktopWindowsPos("Y", getDesktopWindowsPos("Y") - 40, 0.2, "linear");
    end
    if curBeat == 244 then
        tweenShaderFloat("chromABTween7", "chromAB", "strength", 0, 1, "linear", -0.015);
        tweenShaderFloat("threeShaderTween6", "threeShader", "zrot", 0, 0.6, "linear", -0.4);
        setNotesShader3DProperty("zrot", 0.4);
        doTweenNotesShader3D("z", "threeShaderTween8", 0, 0.6, "linear");
        setWindowPos("X", getWindowPos("X") - 20);
        setWindowPos("Y", getWindowPos("Y") - 20);
        doTweenWinPos("X", "windowTween5", getWindowPos("X") + 20, 0.2, "linear");
        doTweenWinPos("Y", "windowTween6", getWindowPos("Y") + 20, 0.2, "linear");
        setDesktopWindowsPos("X", getDesktopWindowsPos("X") - 40);
        setDesktopWindowsPos("Y", getDesktopWindowsPos("Y") - 40);
        doTweenDesktopWindowsPos("X", getDesktopWindowsPos("X") + 40, 0.2, "linear");
        doTweenDesktopWindowsPos("Y", getDesktopWindowsPos("Y") + 40, 0.2, "linear");
    end
    if curBeat == 252 then
        tweenShaderFloat("chromABTween7", "chromAB", "strength", 0, 1, "linear", 0.015);
        tweenShaderFloat("threeShaderTween7", "threeShader", "zrot", 0, 0.6, "linear", 0.4);
        setNotesShader3DProperty("zrot", -0.4);
        doTweenNotesShader3D("z", "threeShaderTween9", 0, 0.6, "linear");
        setWindowPos("X", getWindowPos("X") + 20);
        setWindowPos("Y", getWindowPos("Y") + 20);
        doTweenWinPos("X", "windowTween7", getWindowPos("X") - 20, 0.2, "linear");
        doTweenWinPos("Y", "windowTween8", getWindowPos("Y") - 20, 0.2, "linear");
        setDesktopWindowsPos("X", getDesktopWindowsPos("X") + 40);
        setDesktopWindowsPos("Y", getDesktopWindowsPos("Y") + 40);
        doTweenDesktopWindowsPos("X", getDesktopWindowsPos("X") - 40, 0.2, "linear");
        doTweenDesktopWindowsPos("Y", getDesktopWindowsPos("Y") - 40, 0.2, "linear");
    end
    if curBeat == 260 then
        tweenShaderFloat("chromABTween7", "chromAB", "strength", 0, 1, "linear", -0.015);
        tweenShaderFloat("threeShaderTween8", "threeShader", "yrot", 0, 0.6, "linear", -0.4);
        setNotesShader3DProperty("yrot", 0.4);
        doTweenNotesShader3D("y", "threeShaderTween8", 0, 0.6, "linear");
        setWindowPos("X", getWindowPos("X") - 20)
        doTweenWinPos("X", "windowTween8", getWindowPos("X") + 20, 0.2, "linear");
        setDesktopWindowsPos("X", getDesktopWindowsPos("X") - 40);
        doTweenDesktopWindowsPos("X", getDesktopWindowsPos("X") + 40, 0.2, "linear");
    end

    if curBeat == 272 then
        setCameraShader(camNoteStuff, "individualGlitches");
        setCameraShader(camSLEHUD, "individualGlitches");
        setCameraShader(camThings2, "individualGlitches");
        setCameraShader(camWaterMark, "individualGlitches");
        tweenShaderFloat("individualGlitchesTween", "individualGlitches", "binaryIntensity", 0.2, 3, "linear");
        tweenShaderFloat("angelTween", "angel", "strength", 0.4, 0.6, "linear");
    end

    if curBeat == 275 or curBeat == 279 or curBeat == 283 or curBeat == 287 or curBeat == 289 or curBeat == 291 or curBeat == 293 or curBeat == 295 or curBeat == 297 or curBeat == 298 or curBeat == 299 then
        tweenShaderFloat("individualGlitchesTween", "individualGlitches", "binaryIntensity", 0, 0.6, "linear", 0.2);
        tweenWindowBorderColor({255, 0, 0}, {0, 0, 0}, 0.6, "linear", false);
    end

    if curBeat == 308 then
        setShaderProperty("individualGlitches", "binaryIntensity", 0.2);
        setShaderProperty("angel", "strength", 0.4);
    end

    if curBeat == 316 then
        removeCameraShader(camNoteStuff, "individualGlitches");
        removeCameraShader(camSLEHUD, "individualGlitches");
        removeCameraShader(camThings2, "individualGlitches");
        removeCameraShader(camWaterMark, "individualGlitches");
        setShaderProperty("angel", "strength", 0);

        enableGDIEffect("ScreenGlitches", true);
        hideTaskBar(true);
        -- enableGDIEffect("DrawIcons", true);
        -- enableGDIEffect("ScreenShake", true);
    end

    if curBeat >= 316 and curBeat <= 380 then
        if curBeat % 2 == 0 then
            setDesktopWindowsPos("X", getDesktopWindowsPos("X") - 40);
            doTweenDesktopWindowsPos("X", getDesktopWindowsPos("X") + 40, 0.2, "linear");
            tweenWindowBorderColor({255, 0, 0}, {0, 0, 0}, 0.3, "linear", false);
        else
            setDesktopWindowsPos("X", getDesktopWindowsPos("X") + 40);
            doTweenDesktopWindowsPos("X", getDesktopWindowsPos("X") - 40, 0.2, "linear");
            tweenWindowBorderColor({0, 0, 0}, {255, 0, 0}, 0.3, "linear", false);
        end
    end

    if curBeat == 404 then
        enableGDIEffect("ScreenGlitches", false);
    end
end

function onStepHit()
    if curStep >= 1250 and curStep < 1264 then
        local screenWidth = getScreenSize("WIDTH")
        local screenHeight = getScreenSize("HEIGHT")
        local windowWidth = getWindowSize("WIDTH")
        local windowHeight = getWindowSize("HEIGHT")
        local maxX = screenWidth - windowWidth
        local maxY = screenHeight - windowHeight

        local randomX = getRandomInt(0, maxX)
        local randomY = getRandomInt(0, maxY)

        setWindowPos("X", randomX)
        setWindowPos("Y", randomY)
    end

    if curStep == 1265 then
        centerWindowTween("centerWindowTween2", 0.6, "linear");
    end
end

local speed = 2
local elapsedTime = 0
local angleRange = 8

local levitationSpeed = 1.6
local levitationHeight = 0.4
local elapsedTime2 = 0
local initialWindowX = getWindowPos("X")

function onUpdatePost(elapsed)
    --[[
    getMTCurrentModifiers() only exists because the same code that has that function in source, did not work in HScript
    So.. New function to SLE's Lua API XD
    ]]
    setTextString("mtModsText", "Actual modifiers:\n" .. getMTCurrentModifiers(":"));
    screenCenter("mtModsText", "X");

    elapsedTime = elapsedTime + (elapsed * speed)
    local angle = math.sin(elapsedTime) * angleRange

    elapsedTime2 = elapsedTime2 + (elapsed * levitationSpeed)
    local y = math.sin(elapsedTime2) * levitationHeight
    setProperty("mtModsText.y", getProperty("mtModsText.y") + y);

    if beat >= 144 and beat <= 208 then
        setProperty("camSLEHUD.angle", angle);
        setProperty("camWaterMark.angle", angle);
        setProperty("camThings2.angle", angle);
        setWindowPos("X", 300 * math.cos(elapsedTime) / 5 + initialWindowX);
    end
end
