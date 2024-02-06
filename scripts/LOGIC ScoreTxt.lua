
local customScoreBarText = false
local npsEnabled = false
local funcReflect = false
--------------------------
local nps = 0
local npsMax = 0
local reduce = true
----------------
function getData(value)
  return getDataFromSave('DdtoV2', value)
end
---
function onCreate()
  initSaveData('DdtoV2', 'psychengine/mikolka9144')
  if not getData('customScoreBarText') then
    close("No SCORE")
    return
  end
  npsEnabled = getData('npsEnabled')
end

function onCreatePost()
  funcReflect = getData('funcReflect', false)
end

function onUpdate()
    if customScoreBarText then calculateScore() end

    if nps > 0 and reduce == true then
        reduce = false
        runTimer('reduce nps', 1 / nps, 1)
      end
      if nps == 0 then
        reduce = true
      end
    
      if nps > npsMax then
        npsMax = nps
      end
end

function NoteHit()
     nps = nps + 1
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'reduce nps' and nps > 0 then
        runTimer('reduce nps', 1 / nps, 1)
        nps = nps - 1
    end
end


function calculateScore()
    ratingName = GetRatingName()
    ratingFC = GetFCRatingName()
    
    beforeScore = 'Score: 0 | Breaks: 0 | Rating: ?'
    finalScore = 
    'Score: ' ..score .. 
    ' | Breaks: ' .. misses .. 
    ' | Rating: ' .. ratingName .. ' (' .. round(rating * 100, 2) .. '%) - ' ..ratingFC
    if npsEnabled then
      beforeScore = 'NPS: 0 (Max: 0) | '..beforeScore
      finalScore = 'NPS: ' ..nps ..' (Max: ' ..npsMax ..') | '..finalScore
    end
      if rating == 0 then
          setProperty('scoreTxt.text', beforeScore)
      else
          setProperty('scoreTxt.text', finalScore)
      end
  end
  function GetRatingName()
    if rating >= 0.9935 then
      return  'AAAAA'
    elseif rating >= 0.980 then
      return  'AAAA:'
    elseif rating >= 0.970 then
      return  'AAAA.'
    elseif rating >= 0.955 then
      return  'AAAA'
    elseif rating >= 0.90 then
      return  'AAA:'
    elseif rating >= 0.80 then
      return  'AAA.'
    elseif rating >= 0.70 then
      return  'AAA'
    elseif rating >= 0.99 then
      return  'AA:'
    elseif rating >= 0.9650 then
      return  'AA.'
    elseif rating >= 0.93 then
      return  'AA'
    elseif rating >= 0.90 then
      return  'A:'
    elseif rating >= 0.85 then
      return  'A.'
    elseif rating >= 0.80 then
      return  'A'
    elseif rating >= 0.70 then
      return  'B'
    elseif rating >= 0.60 then
      return  'C'
    elseif rating < 60 then
      return  'D'
    else
      return  'D'
    end
  end

function GetFCRatingName()
    if getProperty('songMisses') == 0 and getProperty('bads') == 0 and getProperty('shits') == 0 and getProperty('goods') == 0 then
      return  'SFC'  -- Sick Full Combo
    elseif getProperty('songMisses') == 0 and getProperty('bads') == 0 and getProperty('shits') == 0 and getProperty('goods') >= 1 then
      return  'GFC'  -- Good Full Combo
    elseif getProperty('songMisses') == 0 then
      return  'FC'   -- Full Combo
    elseif getProperty('songMisses') < 10 then
      return  'SDCB' -- Single Digit Combo Break
    else
      return  'Clear'
    end
  end

  function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
  end
  function opponentNoteHit(id, noteData, noteType, isSustainNote) 
    if funcReflect and not isSustainNote then noteHit() end end
  
  function goodNoteHit(noteID, noteData, noteType, isSustainNote)
    if not funcReflect and not isSustainNote then noteHit() end
  end
