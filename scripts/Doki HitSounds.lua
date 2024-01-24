-- OPTIONS --
local hitSound = true      
local judgeHitSound = true 
local judgeCount = 1    
local hitSoundVolume = 0.9 

-- DO NOT TOUCH --
local enemyHit = false

function onCreate()
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
  if not enemyHit  then
    checkNote(membersIndex, noteData, noteType, isSustainNote)
  end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
  if enemyHit then
    checkNote(membersIndex, noteData, noteType, isSustainNote)
  end
end

----------
function checkNote(noteID, noteData, noteType, isSustainNote)
  rating = getPropertyFromGroup('notes', noteID, 'rating') -- TODO
  if not isSustainNote and hitSound then
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
    playSnd('snap','chord')
  elseif rating == 'doki' and judgeCount > 0 then
    playSnd('perfect','chord')
  elseif rating == 'good' and judgeCount > 1 then
    playSnd('great','chord')
  elseif rating == 'ok' and judgeCount > 2 then
    playSnd('good','chord')
  elseif rating == "no" and judgeCount > 3 then
    playSnd('tap',"bad")
  elseif rating == "invalid"then
    playSnd('snap',"chord")
  end
  
end
function playSnd(name,type)
  stopSound(type)
  playSound('hitsound/' .. name, hitSoundVolume, type)
end

function getData(value, fallback)
  return getDataFromSave('DdtoV2', value, fallback)
end
function importSettings()
  initSaveData('DdtoV2', 'psychengine/mikolka9144')
  OpponentHasSplash = getData("OpponentHasSplash",false)
  hitSound = getData("hitSound",true)      
  judgeHitSound = getData("judgeHitSound",true) 
  judgeCount = getData("judgeCount",0)      
  hitSoundVolume = getData("hitSoundVolume",0.9) 
  if getData("funcReflect","none") then
    enemyHit = true
  end
end
