JudgementNameTable = {}
local funcReflect = false
local early = 0
local late = 0
local maxCombo = 0

local judgementCounter = true

function onCreate()
    configureExternalVars()
    if not getData('ddtoNoteCounter', false) then
        close("No judge")
        return
    end
    createJudgementCounter()
end
function onCreatePost()
    funcReflect = getData('funcReflect', false)
end

function onUpdate(elapsed)
    setMaxCombo()
    if judgementCounter then
        setTextString('judgementCounter', generateJudgementCounterText())
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if funcReflect and not isSustainNote then noteHit(id) end
end

  function goodNoteHit(noteID, noteData, noteType, isSustainNote)
    if not funcReflect and not isSustainNote then noteHit(noteID) end
  end

  function noteHit(noteID)
    if EarlyLate then calculateHitTime(noteID) end
  end
function onUpdatePost()
    setProperty("judgementCounter.alpha", getProperty("timeTxt.alpha"), false)
end

function createJudgementCounter()
    makeLuaText('judgementCounter', 'AA', screenWidth, 20, 0)
    setTextSize('judgementCounter', 20)
    setTextBorder('judgementCounter', 2, '000000')
    setProperty('judgementCounter.borderQuality', 2)
    setTextFont('judgementCounter', 'Aller_Rg.ttf')
    setTextAlignment('judgementCounter', 'left')
    setProperty("judgementCounter.visible", true)
    addLuaText('judgementCounter')
end

function calculateHitTime(noteID)
    local msTime = (getSongPosition() - getPropertyFromGroup('notes', noteID, 'strumTime')) - RATING_OFFSET
    local rating = getPropertyFromGroup('notes', noteID, 'rating')
  
    if rating ~= "sick" then
      if msTime < 0
      then
        early = early + 1
      else
        late = late + 1
      end
    end 
end

function setMaxCombo()
    combo = getProperty('combo')
    if combo > maxCombo then
        maxCombo = combo
    end
end

function generateJudgementCounterText()
    -- WE STEALIN' CODE  BABY
    local sicks = getProperty(JudgementNameTable[1])
    local goods = getProperty(JudgementNameTable[2])
    local bads = getProperty(JudgementNameTable[3])
    local shits = getProperty(JudgementNameTable[4])
    local misses = getProperty("songMisses")
    --
    local judgementText = 'Doki: ' .. sicks ..
        '\nGood: ' .. goods ..
        '\nOk: ' .. bads ..
        '\nNo: ' .. shits ..
        '\nMiss: ' .. misses
    if EarlyLate then
        judgementText = judgementText .. '\n\n' ..
            "Early: " .. early ..
            "\nLate: " .. late
    end
    judgementText = judgementText .. '\n\n' .. "Max: " .. maxCombo
    return judgementText
end

function configureExternalVars()
    initSaveData('DdtoV2', 'psychengine/mikolka9144')
    EarlyLate = getData('noteDelay', earlyLate)
    local isNewPsych = version:find('0.7')

    JudgementNameTable = isNewPsych
    and { 'ratingsData[0].hits', 'ratingsData[1].hits', 'ratingsData[2].hits', 'ratingsData[3].hits' }
    or { 'sicks', 'goods', 'bads', 'shits' }

    RATING_OFFSET = isNewPsych
    and getPropertyFromClass('backend.ClientPrefs', 'data.ratingOffset')
    or getPropertyFromClass('ClientPrefs', 'ratingOffset')
    
end

function getData(value, fallback)
    return getDataFromSave('DdtoV2', value, fallback)
end
