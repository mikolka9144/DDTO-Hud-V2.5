-- NOTE: This file MUST be first in alphabetical order.
-- THIS MUST BE RUNNING AS A FIRST SCRIPT!!!

local onlyBFSongs = { 'remix4', 'tug-o-war', 'null-code-v2' }

---- SCRIPT ENV ----
local playsAsOpponent = false

local RATING_OFFSET = 0

function onCreate()
  initSaveData('DdtoV2', 'psychengine/mikolka9144')
  luaDebugMode = getData('debug', false)
  isNewPsych = version:find('0.7')

  alternativeHPBar = getData('alternativeHPBar', false)
  local user_internalMirror = getData('user_internalMirror', false)
  user_anyMirror = getData('user_anyMirror', false)
  local user_funcReflect = getData('user_funcReflect', false)
  local user_strumlineReflect = getData('user_strumlineReflect', false)
  local user_hpReflect = getData('user_hpReflect', false)

  if UMMversion ~= nil then 
    if leftSide == true then
      setData('complexMirror', false)
      setData('internalMirror', false)
      setData('anyMirror', true)
      user_funcReflect = true
      user_hpReflect = true
      user_strumlineReflect = true
    else
      setData('anyMirror', false)
      user_funcReflect = false
      user_hpReflect = false
      user_strumlineReflect = false
    end
  else
    for i = 1, #onlyBFSongs do
      if songName == onlyBFSongs[i] then
        user_anyMirror = false
      end
    end
  
    setData('internalMirror', user_anyMirror and user_internalMirror or false)
    setData('anyMirror', user_anyMirror)
    
    if (not user_internalMirror) and user_anyMirror then
      setData('complexMirror', true)
    else
      setData('complexMirror', false)
      user_funcReflect = false
      user_hpReflect = false
      user_strumlineReflect = false
    end
  end

  if isNewPsych then
    setHaxeVars()
    RATING_OFFSET = getPropertyFromClass('backend.ClientPrefs', 'data.ratingOffset')
  else
    RATING_OFFSET = getPropertyFromClass('ClientPrefs', 'ratingOffset')
  end
  setData('funcReflect', user_funcReflect)
  setData('strumReflect', user_strumlineReflect)
  setData('hpReflect', user_hpReflect)

  playsAsOpponent = user_funcReflect
  flushSaveData("DdtoV2")
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote) -- ShadowMario did it... AGAIN
  if not playsAsOpponent then
    noteHit(membersIndex, isSustainNote)
  end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote) -- ShadowMario... Why do you torture me like this
  if playsAsOpponent then
    noteHit(membersIndex, isSustainNote)
  end
end

function noteHit(id, sus) -- Amogus
  curRating = getPropertyFromGroup('notes', id, 'rating')
  if curRating == "unknown" or curRating == "rating" and not sus then
    noteHit(id)
  end
end

function noteHit(membersIndex)
  local noteDiff = math.abs((getSongPosition() - getPropertyFromGroup('notes', membersIndex, 'strumTime')) -
    RATING_OFFSET)
  local diff = noteDiff / playbackRate
  daRating = getProperty('ratingsData[' .. (getProperty('ratingsData.length')) .. '].name')

  for i = 1, getProperty('ratingsData.length') - 1 do
    if diff <= getProperty('ratingsData[' .. (i - 1) .. '].hitWindow') then
      daRating = getProperty('ratingsData[' .. (i - 1) .. '].name')
      break
    end
  end
  setPropertyFromGroup('notes', membersIndex, 'rating', daRating)
end

function setHaxeVars()
  if user_anyMirror and alternativeHPBar then
    setVar("mirror", "true")
  else
    setVar("mirror", "false")
  end
end

function getData(value, fallback)
  return getDataFromSave('DdtoV2', value, fallback)
end

function setData(name, value)
  return setDataFromSave('DdtoV2', name, value)
end
