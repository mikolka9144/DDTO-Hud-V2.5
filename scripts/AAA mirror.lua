-- NOTE: This file MUST be first in alphabetical order.
-- THIS MUST BE RUNNING AS A FIRST SCRIPT!!!

local onlyBFSongs = { 'remix4', 'tug-o-war' ,'null-code-v2'}

---- SCRIPT ENV ----
local funcReflect06 = true
local funcReflect07 = true
local strumlineReflect06 = true
local strumlineReflect07 = false
local hpReflect06 = true
local hpReflect07 = false
local playsAsOpponent = false

local RATING_OFFSET = 0

function onCreate()
    initSaveData('DdtoV2', 'psychengine/mikolka9144')
    isNewPsych = version:find('0.7')
    curMirror = getData('mirror', "none")
    alternativeHPBar = getData('alternativeHPBar', false)

    for i = 1, #onlyBFSongs do
      if songName == onlyBFSongs[i] then
        curMirror = "none"
      end
    end

    setData('internalMirror', (curMirror == 'simple'))
    setData('anyMirror', (curMirror ~= 'none'))
    if curMirror ~= 'complex' then
        setData('complexMirror', false)
        setData('funcReflect', false)
        setData('strumReflect', false)
        setData('hpReflect', false)
        
    else
        setData('complexMirror', true)
        if isNewPsych then 
            setHaxeVars()
            RATING_OFFSET = getPropertyFromClass('backend.ClientPrefs', 'data.ratingOffset')
            playsAsOpponent = funcReflect07
            setData('funcReflect', funcReflect07)
            setData('strumReflect', strumlineReflect07)
            setData('hpReflect', hpReflect07)
        else
            playsAsOpponent = funcReflect06
            RATING_OFFSET = getPropertyFromClass('ClientPrefs', 'ratingOffset')
            setData('funcReflect', funcReflect06)
            setData('strumReflect', strumlineReflect06)
            setData('hpReflect', hpReflect06)
        end
    end
    flushSaveData("DdtoV2")
end


function goodNoteHit(membersIndex, noteData, noteType, isSustainNote) -- ShadowMario did it... AGAIN
  if not playsAsOpponent then
    checkNote(membersIndex,isSustainNote)
  end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote) -- ShadowMario... Why do you torture me like this
  if playsAsOpponent then
    checkNote(membersIndex,isSustainNote)
  end
end

function checkNote(id,sus) -- Amogus
  curRating = getPropertyFromGroup('notes', id, 'rating')
  if curRating == "unknown" or curRating == "rating" and not sus then
    noteHit(id)
  end
end

function noteHit(membersIndex)
  local noteDiff = math.abs((getSongPosition() - getPropertyFromGroup('notes', membersIndex, 'strumTime')) - RATING_OFFSET)
  local diff = noteDiff / playbackRate
  daRating = getProperty('ratingsData['..(getProperty('ratingsData.length'))..'].name')

  for i = 1, getProperty('ratingsData.length')-1 do
    if diff <= getProperty('ratingsData['..(i - 1)..'].hitWindow') then
      daRating = getProperty('ratingsData['..(i - 1)..'].name')
      break
    end  
  end
  setPropertyFromGroup('notes', membersIndex, 'rating',daRating)
end

function setHaxeVars()
    if (curMirror == "simple" or curMirror == "complex") and alternativeHPBar then
        setVar("mirror", "true") 
      elseif curMirror == "none" then
        setVar("mirror", "false") 
      else
        print("MIRROR IS NOT DEFINED IN MIRROR!!!")
      end
end

function getData(value, fallback)
    return getDataFromSave('DdtoV2', value, fallback)
  end
  
  function setData(name, value)
    return setDataFromSave('DdtoV2', name, value)
  end
