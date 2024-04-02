--[[
CREDITS:
Script Created By MinecraftBoy2038
Modified By Zaxh#9092 (Made the script more accurate from the original ddto+ source code)
Graident Lua Timebar by Betopia#5677 (Fixed Character Change by Aaron ♡#0001, luv u)
PlayAsDad by Kevin Kuntz
NPS logic made by beihu(北狐丶逐梦) https://b23.tv/gxqO0GH
Lane overlay/underlay by Nox#5005
HUD Originated By DDTO+
Please credit me if you are using this hud
]]

-- SETTINGS --
local customScoreBar = false
local earlyLate = true
local uiFont = "Aller.ttf"
local pixelFont = "vcr.ttf"
-- CODE N SUCH --
local funcReflect = false
local isNewPsych = false
local isAnyMirror = false
local isUMM = false
local botplaySine = 0
local allowTextResizing = false
-- Psych Constants --
local IS_PIXEL = false
local COMBO_OFFSET = nil
local timeBarBG = nil
local bgY = nil
--

--#region Funkin' LUA METHODS
function onCreate()
  initSaveData('DdtoV2', 'psychengine/mikolka9144')
  
  isAnyMirror = getData('anyMirror', false)
  earlyLate = getData('noteDelay', earlyLate)
  customScoreBar = getData('customScoreBar', customScoreBar)
  uiFont = getData('UIFont', uiFont)
  pixelFont = getData('UIPixelFont', pixelFont)

  configureExternalVars()
end

function onCreatePost()
  funcReflect = getData('funcReflect', false)
  if customScoreBar then
    setProperty('scoreTxt.visible', false)
    makeDDTOScoreBar()
  end
  setupTimeBar(downscroll and 4 or -17)
  makePracticeText()
  makeKadeWatermark()
  
  allowTextResizing = true
  setHudStyle(IS_PIXEL)
  allowTextResizing = false
  runHaxeCode('game.botplayTxt.kill();')
end

function onUpdate()
  refreshStrumText()
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

function noteHit(noteID)
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

--#endregion

--#region SPRITES METHODS

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

  setProperty('practiceTxt.y', defaultPlayerStrumY0 + 30)
end
function makeKadeWatermark()
  
  local kadeTxt = isUMM 
  and songName.." "..difficultyName.." - UMM "..UMMversion.." ("..version..")"
  or songName.." "..difficultyName.." - PE "..version
  makeLuaText('kade', kadeTxt, 0, 0)
  setTextSize('kade', 16)
  setProperty("kade.x", 2)
  setProperty("kade.antialiasing", false)
  setProperty("kade.y", screenHeight-(10+15))
  setTextBorder('kade', 1, '000000')
  addLuaText('kade')
end
--#endregion

--#region LOGIC METHODS

function tweenScoreTxt()
  setProperty('ddtoScoreTxt.scale.x', 1.075)
  setProperty('ddtoScoreTxt.scale.y', 1.075)
  cancelTween('ddtoScoreTxtTweenX')
  cancelTween('ddtoScoreTxtTweenY')
  doTweenX('ddtoScoreTxtTweenX', 'ddtoScoreTxt.scale', 1, 0.2)
  doTweenY('ddtoScoreTxtTweenY', 'ddtoScoreTxt.scale', 1, 0.2)
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

function setHudStyle(isPixel)
  setPropertyFromClass(isNewPsych and "states.PlayState" or "PlayState", 'isPixelStage', isPixel)
  setupMSText(isPixel)
  if luaTextExists("judgementCounter") then
    if isPixel then
      crawlFont('judgementCounter', 'pixel')
      setProperty('judgementCounter.y', 346 + (earlyLate and -58 or -31))
    else
      crawlFont('judgementCounter', '')
      setProperty('judgementCounter.y', 346 + (earlyLate and -88 or -52))
    end
  end
  if luaTextExists('ddtoScoreTxt') then
    crawlFont('ddtoScoreTxt', isPixel and 'pixel' or '')
  end
  if isPixel then
    crawlFont('scoreTxt', 'pixel')
    crawlFont('timeTxt', 'pixel')
    crawlFont('practiceTxt', 'pixel')
  else
    crawlFont('scoreTxt', '')
    crawlFont('timeTxt', '')
    crawlFont('practiceTxt', 'riffic')
  end
end

function setupMSText(isPixel)
  if not luaTextExists("latencyIndicator") then return end
  crawlFont('latencyIndicator', isPixel and 'vcr' or 'riffic')
  indexOff = (isUMM and isAnyMirror) and 4 or 0
  X = 40.0 - 90 + COMBO_OFFSET[1+indexOff]
  Y = 60.0 - 80 - COMBO_OFFSET[2+indexOff]

  if isUMM then X=X+(isAnyMirror and -90 or (90*6) ) end
  if isPixel then Y = Y + 60 end
  screenCenter("latencyIndicator", 'xy')
  setProperty("latencyIndicator.x", getProperty("latencyIndicator.x") + X)
  setProperty("latencyIndicator.y", getProperty("latencyIndicator.y") + Y)
end

function setupTimeBar(Yoffset)
  setTextSize('timeTxt', 18)
  setTextWidth("timeTxt", 1000)
  screenCenter("timeTxt", 'x')
  setTextBorder("timeTxt", 1, "000000")
  setProperty('timeTxt.y', getProperty(timeBarBG .. '.y') + Yoffset)
  if not isNewPsych then
    setProperty(timeBarBG .. '.y', getProperty(timeBarBG .. '.y') + Yoffset)
  end
  setProperty("timeBar.y", getProperty("timeBar.y") + Yoffset)
end

function configureExternalVars()
  isNewPsych = version:find('0.7')
  isUMM = UMMversion ~= nil

  if isNewPsych then
    noteSkin = getPropertyFromClass('backend.ClientPrefs', "data.noteSkin")
    if noteSkin:lower() == "doki" then
      setPropertyFromClass("states.PlayState", "SONG.disableNoteRGB", true)
    end
  end
  if isNewPsych then
    IS_PIXEL = getPropertyFromClass('states.PlayState', 'isPixelStage')
    COMBO_OFFSET = getPropertyFromClass('backend.ClientPrefs', "data.comboOffset") -- X,Y
    timeBarBG = "timeBar.bg"
    bgY = "healthBar.bg.y"
  else
    IS_PIXEL = getPropertyFromClass('PlayState', 'isPixelStage')
    COMBO_OFFSET = getPropertyFromClass('ClientPrefs', "comboOffset") -- X,Y
    timeBarBG = 'timeBarBG'
    bgY = 'healthBarBG.y'
  end
end

function setTimeBarTxt()
  local barType = string.lower(timeBarType)
  if getProperty("timeTxt.alpha") == 0 or
      inGameOver or -- this code fails to calculate "remaining time" in game over
      barType == "disabled"
  then
    return
  end

  local barTxt = songName
  if playbackRate ~= 1 then
    barTxt = barTxt .. ' (' .. playbackRate .. 'x)'
  end
  if barType == "time left" then
    local remTime = formatTime(remainingTime())
    barTxt = barTxt .. ' (' .. remTime .. ')'
  elseif barType == "time elapsed" then
    local totalTime = formatTime(getProperty('songLength'))
    local elapsedTime = formatTime((getSongPosition() - noteOffset))
    barTxt = barTxt .. ' [' .. elapsedTime .. " | " .. totalTime .. ']'
  end
  setTextString('timeTxt', barTxt)
end

--#endregion

--#region UTILLS

function getData(value, fallback)
  local item = getDataFromSave('DdtoV2', value, fallback)
  if (item == nil) then return fallback end
  return item
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
  if funcReflect and not isSustainNote then noteHit(id) end
end

function goodNoteHit(noteID, noteData, noteType, isSustainNote)
  if not funcReflect and not isSustainNote then noteHit(noteID) end
end

function setTxt(text)
  currentText = getTextString("practiceTxt")
  if currentText ~= text then
    setTextString('practiceTxt', text)
  end
end

function formatTime(millisecond)
  local seconds = math.floor(millisecond / 1000)
  return string.format("%01d:%02d", (seconds / 60) % 60, seconds % 60)
end

function remainingTime()
  return getProperty('songLength') - (getSongPosition() - noteOffset)
end

function crawlFont(objName, type)
  local font = ""
  if type == 'pixel' then
    font = pixelFont
  elseif type == 'riffic' then
    font = 'riffic.ttf'
  elseif type == 'vcr' then
    font = 'vcr.ttf'
  else
    font = uiFont
  end
  setTextFont(objName, font)
  if not allowTextResizing then return end

  if (font == "Journal.ttf") then
    setProperty(objName..".y", getProperty(objName..".y")-5)
    setTextSize(objName, getTextSize(objName) + 6) -- For you Monika <3
  elseif (font == "CyberpunkWaifus.ttf") then
    setTextSize(objName, getTextSize(objName) + 5)
  end
end

--#endregion
