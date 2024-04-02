-- OPTIONS --
local judgeHitSound = true
local judgeMin = 1
local hitSoundVolume = 0.9

-- DO NOT TOUCH --
local enemyHit = false

function onCreate()
  if not getData("hitSound", true) then
    close("No hitsounds")
    return
  end
  precacheSound('hitsound/snap')
  precacheSound('hitsound/perfect')
  precacheSound('hitsound/great')
  precacheSound('hitsound/good')
  precacheSound('hitsound/tap')
end

function onCreatePost()
  importSettings()
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
  if not enemyHit then
    noteHit(membersIndex, noteData, noteType, isSustainNote)
  end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
  if enemyHit then
    noteHit(membersIndex, noteData, noteType, isSustainNote)
  end
end

----------
function noteHit(noteID, noteData, noteType, isSustainNote)
  if getPropertyFromGroup('unspawnNotes', noteID, 'eventVal1') == "REPEAT_NOTE" 
    then return end
    
  rating = getPropertyFromGroup('notes', noteID, 'rating') -- TODO
  if not isSustainNote then
    if not judgeHitSound then
      playChord("noteHit")
    elseif rating == 'sick' then
      playChord('doki')
    elseif rating == 'good' then
      playChord('good')
    elseif rating == 'bad' then
      playChord('ok')
    elseif rating == 'rating' or rating == 'unknown' then
      playChord("invalid")
    else
      playChord("no")
    end
  end
end

function playChord(rating)
  if rating == "noteHit" then
    playSnd('snap', 'chord')
  elseif rating == 'doki' then
    playSnd('perfect', 'chord')
  elseif rating == 'good' and judgeMin ~= "Sick" then
    playSnd('great', 'chord')
  elseif rating == 'ok' and judgeMin ~= "Good" and judgeMin ~= "Sick" then
    playSnd('good', 'chord')
  elseif rating == "no" and judgeMin == "Shit" then
    playSnd('tap', "bad")
  elseif rating == "invalid" then
    playSnd('snap', "chord")
  end
end

function playSnd(name, type)
  stopSound(type)
  playSound('hitsound/' .. name, hitSoundVolume, type)
end

function getData(value, fallback)
  local item = getDataFromSave('DdtoV2', value, fallback)
  if (item == nil) then return fallback end
  return item
end

function importSettings()
  initSaveData('DdtoV2', 'psychengine/mikolka9144')
  OpponentHasSplash = getData("OpponentHasSplash", false)
  judgeHitSound = getData("judgeHitSound", judgeHitSound)
  judgeMin = getData("judgeMinimum", "Shit")
  hitSoundVolume = getData("hitSoundVolume", 0.9)
  enemyHit = getData("funcReflect", false)
end
