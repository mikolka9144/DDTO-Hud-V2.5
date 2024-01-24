--[[

CREDITS:
Script Created By MinecraftBoy2038
Modified By Zaxh#9092 (Made the script more accurate from the original ddto+ source code)
Graident Lua Timebar by Betopia#5677 (Fixed Character Change by Aaron ♡#0001, luv u)
PlayAsDad by Kevin Kuntz
NPS logic made by beihu(北狐丶逐梦) https://b23.tv/gxqO0GH
Lane overlay/underlay by Nox#5005
Tweaked by Mikolka9144
HUD Originated By DDTO+
Please credit me if you are using this hud

]]

-- SETTINGS --
local judgementCounter = true              --  [true/false]
local earlyLate = true                     -- [true/false]
local customScoreBar = false               -- Do you want to show ddto score bar? [true/false]
local earlyLateMSTime = true               --  [true/false]
----


-- CODE N SUCH --

local funcReflect = false
local isNewPsych = false

local early = 0
local late = 0
local maxCombo = 0
local botplaySine = 0
-- Psych Constants --
local IS_PIXEL = false
local COMBO_OFFSET = nil
local RATING_OFFSET = nil
local timeBarBG = nil
local bgY = nil
local judgementNameTable = {}
--

--#region Funkin' LUA METHODS
function onCreate()
  loadPresets()
  configureExternalVars()
  if judgementCounter then createJudgementCounter() end
  if earlyLate then createLatencyIndicator() end
end

function onCreatePost()
  loadEnv()
  if customScoreBar then
    setProperty('scoreTxt.visible', false)
    makeDDTOScoreBar()
  end
  setupTimeBar(-17)
  makePracticeText()
  setHudStyle(IS_PIXEL)
  killAllDokisExceptMonika()
end

function onUpdate()
  refreshStrumText()
  setMaxCombo()
  if judgementCounter then
    setTextString('judgementCounter', generateJudgementCounterText())
  end
  if customScoreBar then setProperty('ddtoScoreTxt.text', getProperty('scoreTxt.text')) end
end

function onUpdatePost(elapsed)
  botplaySine = botplaySine + 180 * elapsed
  setProperty('practiceTxt.alpha', 1 - math.sin(math.pi * botplaySine / 180))
  
  setTimeBarTxt()
  
end

function onSongStart()
  doTweenAlpha('timeTween', 'timeBarBack', 1, 0.5, 'circOut')
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
  if funcReflect and not isSustainNote then noteHit(id) end
end

function goodNoteHit(noteID, noteData, noteType, isSustainNote)
  if not funcReflect and not isSustainNote then noteHit(noteID) end
end

function noteHit(noteID)
  if earlyLate then calculateHitTime(noteID) end
  if not botPlay then tweenScoreTxt() end
end

function onEvent(name, value1, value2)
 if name == "Set Pixel Mode" then
    if value1 == "true" then
      setHudStyle(true)
    else
      setHudStyle(false)
    end
  end
end

function onTimerCompleted(tag, loops, loopsLeft)
  if tag == "Hide msText" then
    doTweenAlpha("msTween", "latencyIndicator", 0, 0.2 / playbackRate, "linear")
  end
end

--#endregion

--#region SPRITES METHODS


function createLatencyIndicator()
  -- You might want to tweak X and Y to your liking, but OLNY FIRST NUMBER
  X = 40.0 - 90 + COMBO_OFFSET[1]
  Y = 60.0 - 80 - COMBO_OFFSET[2]
  if IS_PIXEL then Y = Y + 60 end
  makeLuaText("latencyIndicator", "", screenWidth, 0, 0)
  setTextSize('latencyIndicator', 28)
  setTextFont('latencyIndicator', 'riffic.ttf')
  setTextBorder('latencyIndicator', 1.25, '000000')
  screenCenter("latencyIndicator", 'xy')
  setProperty("latencyIndicator.x", getProperty("latencyIndicator.x") + X)
  setProperty("latencyIndicator.y", getProperty("latencyIndicator.y") + Y)
  setProperty("latencyIndicator.alpha", 1)
  addLuaText("latencyIndicator")
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

function makeDDTOScoreBar()
  makeLuaText('ddtoScoreTxt', '')
  setTextFont('ddtoScoreTxt', 'Aller_Rg.ttf')
  setTextBorder('ddtoScoreTxt', 1.25, '000000')
  setTextSize('ddtoScoreTxt', 20)
  setProperty('ddtoScoreTxt.x', getProperty('scoreTxt.x'))
  setProperty('ddtoScoreTxt.y', getProperty(bgY) + 48)
  setTextWidth('ddtoScoreTxt', getTextWidth('scoreTxt'))
  setTextAlignment('ddtoScoreTxt', 'CENTER')
  addLuaText('ddtoScoreTxt', true)
end

function makePracticeText()
  makeLuaText('practiceTxt', '', 0, 0)
  setTextSize('practiceTxt', 32)
  setTextFont('practiceTxt', 'riffic.ttf')
  screenCenter('practiceTxt', 'X')
  setTextAlignment('practiceTxt', 'center')
  setProperty('practiceTxt.visible', true)
  setTextBorder('practiceTxt', 1.25, '000000')
  addLuaText('practiceTxt')

  setObjectOrder('practiceTxt', getObjectOrder('botplayTxt'))
  setProperty('practiceTxt.y', defaultPlayerStrumY0 + 30)
end

--#endregion

--#region LOGIC METHODS

function setTimeBarTxt()
  if getProperty("timeTxt.alpha") == 0 then return end
  if playbackRate == 1 then
    setTextString('timeTxt', songName .. ' (' .. formatTime(remainingTime()) .. ')')
  else
    setTextString('timeTxt', songName .. ' (' .. playbackRate .. 'x) (' .. formatTime(remainingTime()) .. ')')
  end
end

function tweenScoreTxt()
  setProperty('ddtoScoreTxt.scale.x', 1.075)
  setProperty('ddtoScoreTxt.scale.y', 1.075)
  cancelTween('ddtoScoreTxtTweenX')
  cancelTween('ddtoScoreTxtTweenY')
  doTweenX('ddtoScoreTxtTweenX', 'ddtoScoreTxt.scale', 1, 0.2)
  doTweenY('ddtoScoreTxtTweenY', 'ddtoScoreTxt.scale', 1, 0.2)
end

function setMaxCombo()
  combo = getProperty('combo')
  if combo > maxCombo then
    maxCombo = combo
  end
end

function refreshStrumText()
  practice = getProperty('practiceMode')
  if botPlay then
    setTxt("BOTPLAY")
  elseif practice then
    setTxt("PRACTICE MODE")
  elseif not (botPlay or practice) and currentText ~= "" then
    setTxt("")
  else
    return
  end
  screenCenter('practiceTxt', 'X')
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
    if (earlyLateMSTime or rating ~= "sick") and getProperty("showRating") then
      cancelTimer("Hide msText")
      cancelTween("msTween")
      popLatencyIndicator(msTime)
    else
      setProperty("latencyIndicator.alpha", 0)
    end
end

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
  displayTime = crochet * 0.001 / playbackRate
  runTimer("Hide msText", displayTime, 1)
end

function setHudStyle(isPixel)
  setPropertyFromClass(isNewPsych and "states.PlayState" or "PlayState", 'isPixelStage',isPixel)
  if isPixel then
    setTextFont('scoreTxt', getFont('vcr'))
    setTextFont('ddtoScoreTxt', getFont('vcr'))
    setTextFont('timeTxt', getFont('vcr'))
    setTextFont('judgementCounter', getFont('vcr'))
    setTextFont('practiceTxt', getFont('vcr'))
    setTextFont('latencyIndicator', getFont('vcr'))
    setProperty('judgementCounter.y', 346 + (earlyLate and -58 or -31))
  else
    setTextFont('scoreTxt', getFont())
    setTextFont('ddtoScoreTxt', getFont())
    setTextFont('timeTxt', getFont())
    setTextFont('judgementCounter', getFont())
    setTextFont('practiceTxt', getFont('riffic'))
    setTextFont('latencyIndicator', getFont('riffic'))
    setProperty('judgementCounter.y', 346 + (earlyLate and -88 or -52))
  end
end

function killAllDokisExceptMonika()
  killADoki("botplayTxt")
  if isNewPsych then
    setProperty("timeBar.visiblity", false)
  else
    killADoki("timeBarBG")
  end
end

function setupTimeBar(Yoffset)
  setTextSize('timeTxt', 18)
  setTextBorder("timeTxt", 1, "000000")
  setProperty('timeTxt.y', getProperty(timeBarBG .. '.y') + Yoffset)
  if not isNewPsych then
    setProperty(timeBarBG .. '.y', getProperty(timeBarBG .. '.y') + Yoffset)
  end
  setProperty("timeBar.y", getProperty("timeBar.y") + Yoffset)
end

function configureExternalVars()
  isNewPsych = version:find('0.7')

  
  if isNewPsych then
    noteSkin = getPropertyFromClass('backend.ClientPrefs', "data.noteSkin")
    if noteSkin:lower() == "doki" then
      setPropertyFromClass("states.PlayState", "SONG.disableNoteRGB", true)
    end
  end

  if isNewPsych then
    COMBO_OFFSET = getPropertyFromClass('backend.ClientPrefs', "data.comboOffset") -- X,Y
    RATING_OFFSET = getPropertyFromClass('backend.ClientPrefs', 'data.ratingOffset')
    IS_PIXEL = getPropertyFromClass('states.PlayState', 'isPixelStage')
    timeBarBG = "timeBar.bg"
    bgY = "healthBar.bg.y"
    judgementNameTable = { 'ratingsData[0].hits', 'ratingsData[1].hits', 'ratingsData[2].hits', 'ratingsData[3].hits' }
  else
    COMBO_OFFSET = getPropertyFromClass('ClientPrefs', "comboOffset") -- X,Y
    RATING_OFFSET = getPropertyFromClass('ClientPrefs', 'ratingOffset')
    IS_PIXEL = getPropertyFromClass('PlayState', 'isPixelStage')
    timeBarBG = 'timeBarBG'
    bgY = 'healthBarBG.y'
    judgementNameTable = { 'sicks', 'goods', 'bads', 'shits' }
  end
end

--#endregion

--#region SAVE STATE CODE

function loadPresets()
  initSaveData('DdtoV2', 'psychengine/mikolka9144')

  judgementCounter = getData('ddtoNoteCounter', judgementCounter)
  earlyLate = getData('noteDelay', earlyLate)
  earlyLateMSTime = getData('noteMs', earlyLateMSTime)
  customScoreBar = getData('customScoreBar', customScoreBar)
  
end

function loadEnv()
  initSaveData('DdtoV2', 'psychengine/mikolka9144')
  funcReflect = getData('funcReflect', false)
end

function getData(value, fallback)
  return getDataFromSave('DdtoV2', value, fallback)
end

--#endregion


--#region UTILLS

function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return x / n
end

function generateJudgementCounterText()
  -- WE STEALIN' CODE  BABY
  sicks = getProperty(judgementNameTable[1])
  goods = getProperty(judgementNameTable[2])
  bads = getProperty(judgementNameTable[3])
  shits = getProperty(judgementNameTable[4])
  misses = getProperty("songMisses")
  --
  judgementText = 'Doki: ' .. sicks ..
      '\nGood: ' .. goods ..
      '\nOk: ' .. bads ..
      '\nNo: ' .. shits ..
      '\nMiss: ' .. misses
  if earlyLate then
    judgementText = judgementText .. '\n\n' ..
        "Early: " .. early ..
        "\nLate: " .. late
  end
  judgementText = judgementText .. '\n\n' .. "Max: " .. maxCombo
  return judgementText
end

function formatTime(millisecond)
  local seconds = math.floor(millisecond / 1000)
  return string.format("%01d:%02d", (seconds / 60) % 60, seconds % 60)
end

function killADoki(object)
  runHaxeCode([[
     game.]] .. object .. [[.kill();
   ]])
end

function setTxt(text)
  currentText = getTextString("practiceTxt")
  if currentText ~= text then
    setTextString('practiceTxt', text)
  end
end

function remainingTime()
  return getProperty('songLength') - (getSongPosition() - noteOffset)
end

function getFont(type)
  -- if type == 'pixel' then return 'LanaPixel.ttf' end

  if type == 'aller' then
    return 'Aller_Rg.ttf'
  elseif type == 'riffic' then--
    return 'riffic.ttf'
  elseif type == 'vcr' then--
    return 'vcr.ttf'
  -- elseif type == 'halogen' then
  --   return 'Halogen.otf'
  -- elseif type == 'grotesk' then
  --   return 'HKGrotesk-Bold.otf'
  -- elseif type == 'dos' then
  --   return 'Perfect DOS VGA 437 Win.ttf'
  
  -- elseif type == 'waifu' then
  --   return 'CyberpunkWaifus.ttf'
  else
    return 'Aller_Rg.ttf'
  end
end

--#endregion
