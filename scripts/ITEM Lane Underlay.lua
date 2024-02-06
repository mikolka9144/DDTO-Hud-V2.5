local laneTransparency = 0.4               --  Max 1
local strumReflect = false

function onCreate()
  if not getData('ddtoUnderlay', false) then
    close("No underlay")
  end
end
function onCreatePost()
    loadPresets()
    createUnderlay(false)
    createUnderlay(true)
end

function onUpdatePost()
    moveUnderlays()
end

---------

function createUnderlay(opponent)
    prefix = opponent and "Opponent" or ""

    makeLuaSprite('laneunderlay' .. prefix, '', 70, 0)
    makeGraphic('laneunderlay' .. prefix, 500, screenHeight * 2, '000000')
    setProperty('laneunderlay' .. prefix .. '.alpha', laneTransparency)
    setObjectCamera('laneunderlay' .. prefix, 'hud')
    screenCenter('laneunderlay' .. prefix, 'Y')
    addLuaSprite('laneunderlay' .. prefix)
  end

function moveUnderlays()
    if strumReflect
    then
      setProperty('laneunderlay.alpha', 0)
    else
      moveUnderlay(false)
    end
    if middlescroll and (not strumReflect)
    then
      setProperty('laneunderlayOpponent.alpha', 0)
    else
      moveUnderlay(true)
    end
  end

  function moveUnderlay(opponent)
    local laneOffset = -190
    local prefix = opponent and "Opponent" or ""
    setProperty('laneunderlay' .. prefix .. '.x', getStrumsAverage(opponent, 'x') + laneOffset)
    setProperty('laneunderlay' .. prefix .. '.alpha', getStrumsAverage(opponent, 'alpha') * laneTransparency)
  end

  function getStrumsAverage(opponent, value) -- Taken from TimeBar.lua
    local np1x, np2x, np3x, np4x
    local strumType = opponent and "opponent" or "player"
    local srumGroup = strumType .. "Strums"

    np1x, np2x, np3x, np4x = getPropertyFromGroup(srumGroup, 0, value),
        getPropertyFromGroup(srumGroup, 1, value),
        getPropertyFromGroup(srumGroup, 2, value),
        getPropertyFromGroup(srumGroup, 3, value);

    return ((np1x + np2x + np3x + np4x) / 4)
  end


function loadPresets()
    initSaveData('DdtoV2', 'psychengine/mikolka9144')
    strumReflect = getData('strumReflect', false)
    laneTransparency = getData('ddtoUnderlayAlpha', laneTransparency)

  end

function getData(value, fallback)
    return getDataFromSave('DdtoV2', value, fallback)
end