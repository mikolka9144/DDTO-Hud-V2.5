local earlyLateMSTime = true
local funcReflect = false
--
local RATING_OFFSET = nil
--

function onCreate()
    initSaveData('DdtoV2', 'psychengine/mikolka9144')
    if not getData('noteDelay', false) then
        close("Early indicator disabled")
        return
    end

    configureExternalVars()
    earlyLateMSTime = getData('noteMs', earlyLateMSTime)
    createLatencyIndicator()
end

function onCreatePost()
    funcReflect = getData('funcReflect', false)
end

-----------
function createLatencyIndicator()
    -- You might want to tweak X and Y to your liking, but OLNY FIRST NUMBER

    makeLuaText("latencyIndicator", "", screenWidth, 0, 0)
    setTextSize('latencyIndicator', 28)
    setTextFont('latencyIndicator', 'riffic.ttf')
    setTextBorder('latencyIndicator', 1.25, '000000')
    screenCenter("latencyIndicator", 'xy')
    setProperty("latencyIndicator.alpha", 1)
    addLuaText("latencyIndicator")
end

------------

function noteHit(noteID)
    local msTime = (getSongPosition() - getPropertyFromGroup('notes', noteID, 'strumTime')) - RATING_OFFSET
    local rating = getPropertyFromGroup('notes', noteID, 'rating')

    if (earlyLateMSTime or rating ~= "sick") and getProperty("showRating") then
        cancelTimer("Hide msText")
        cancelTween("msTween")
        popLatencyIndicator(msTime)
    else
        setProperty("latencyIndicator.alpha", 0)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == "Hide msText" then
        doTweenAlpha("msTween", "latencyIndicator", 0, 0.2 / playbackRate, "linear")
    end
end

----------

function popLatencyIndicator(msTime)
    if msTime < 0 then
        setTextColor("latencyIndicator", "00FFFF")
        setTextString("latencyIndicator", "EARLY")
    else
        setTextColor("latencyIndicator", "FF0000")
        setTextString("latencyIndicator", "LATE")
    end
    if earlyLateMSTime then
        setTextString("latencyIndicator", round(msTime, 2) .. "ms")
    end
    setProperty("latencyIndicator.alpha", 1)
    local displayTime = crochet * 0.001 / playbackRate
    runTimer("Hide msText", displayTime, 1)
end

function configureExternalVars()
    isNewPsych = version:find('0.7')

    if isNewPsych then
        RATING_OFFSET = getPropertyFromClass('backend.ClientPrefs', 'data.ratingOffset')
    else
        RATING_OFFSET = getPropertyFromClass('ClientPrefs', 'ratingOffset')
    end
end

------

function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

-----
function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if funcReflect and not isSustainNote then noteHit(id) end
end

function goodNoteHit(noteID, noteData, noteType, isSustainNote)
    if not funcReflect and not isSustainNote then noteHit(noteID) end
end

function getData(value, fallback)
    local item = getDataFromSave('DdtoV2', value, fallback)
    if (item == nil) then return fallback end
    return item
end
