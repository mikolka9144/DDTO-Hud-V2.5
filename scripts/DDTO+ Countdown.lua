function importSettings()
    initSaveData('DdtoV2', 'psychengine/mikolka9144')
    gfCountdown = getData("gfCountdown", false)
end

function onCreate()
    isEvil = curStage:lower():find('evil')
    importSettings()
    makeCountdownObject('ready')
    makeCountdownObject('set')
    makeCountdownObject('go')
end

function setCountdown(swagCounter)
    if swagCounter == 0 then
        if gfCountdown and checkAnimationExists('gf', 'countdownThree') then
            playAnim('gf', 'countdownThree')
        end
    elseif swagCounter == 1 then
        showCountdownObject('ready')
        setProperty('countdownReady.visible', false)
        if gfCountdown and checkAnimationExists('gf', 'countdownTwo') then
            playAnim('gf', 'countdownTwo')
        end
    elseif swagCounter == 2 then
        showCountdownObject('set')
        setProperty('countdownSet.visible', false)
        if gfCountdown and checkAnimationExists('gf', 'countdownOne') then
            playAnim('gf', 'countdownOne')
        end
    elseif swagCounter == 3 then
        showCountdownObject('go')
        setProperty('countdownGo.visible', false)
        if gfCountdown and checkAnimationExists('gf', 'countdownGo') then
            playAnim('gf', 'countdownGo')
        end
    end
end

function onCountdownTick(swagCounter)
    if swagCounter == 4 then return end
    if usePixelSplash and isEvil then
        setProperty('introSoundsSuffix', '-glitch')
    end
    setCountdown(swagCounter)
end

function onTweenCompleted(tag)
    if tag == 'ready' then
        removeLuaSprite('ready')
    elseif tag == 'set' then
        removeLuaSprite('set')
    elseif tag == 'go' then
        removeLuaSprite('go')
    end
end

function showCountdownObject(name)
    setProperty(name .. '.alpha', 1)
    doTweenAlpha(name, name, 0, crochet / 1000, 'cubeInOut')
end

function makeCountdownObject(name)
    makeLuaSprite(name, name)
    setObjectCamera(name, 'hud')
    setGraphicSize(name, getProperty(name .. '.width') * 0.6)
    if usePixelSplash then
        if name == 'go' then
            if isEvil then
                loadGraphic(name, 'pixelUI/demise-date')
            else
                loadGraphic(name, 'pixelUI/date-pixel')
            end
        else
            loadGraphic(name, 'pixelUI/' .. name .. '-pixel')
        end

        setGraphicSize(name, getProperty(name .. '.width') * 6)
        setProperty(name .. '.antialiasing', false)
    end
    screenCenter(name)
    setProperty(name .. '.alpha', 0)
    addLuaSprite(name)
end

function getData(value, fallback)
    return getDataFromSave('DdtoV2', value, fallback)
end
