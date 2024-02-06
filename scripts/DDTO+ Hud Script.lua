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
local customScoreBar = false 
local earlyLate = true
-- CODE N SUCH --
local funcReflect = false
local isNewPsych = false
local botplaySine = 0
-- Psych Constants --
local IS_PIXEL = false
local COMBO_OFFSET = nil
local timeBarBG = nil
local bgY = nil
--

--#region Funkin' LUA METHODS
function onCreate()
  initSaveData('DdtoV2', 'psychengine/mikolka9144')
  earlyLate = getData('noteDelay', earlyLate)
  customScoreBar = getData('customScoreBar', customScoreBar)
  luaDebugMode = getData('debug', false)
  
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
  setHudStyle(IS_PIXEL)
  runHaxeCode('game.botplayTxt.kill();')
end

function onUpdate()
  refreshStrumText()
  if customScoreBar then setProperty('ddtoScoreTxt.text', getProperty('scoreTxt.text')) end
end

function onUpdatePost(elapsed)
  botplaySine = botplaySine + 180 * elapsed
  setProperty('practiceTxt.alpha', 1 - math.sin(math.pi * botplaySine / 180))
  --debugPrint(getTextString("practiceTxt"))
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
      setTextFont('judgementCounter', getFont('vcr'))
      setProperty('judgementCounter.y', 346 + (earlyLate and -58 or -31))
    else
      setTextFont('judgementCounter', getFont())
      setProperty('judgementCounter.y', 346 + (earlyLate and -88 or -52))
    end
  end
  if luaTextExists('ddtoScoreTxt') then
    setTextFont('ddtoScoreTxt', getFont(isPixel and 'vcr' or ''))
  end
  if isPixel then
    setTextFont('scoreTxt', getFont('vcr'))
    setTextFont('timeTxt', getFont('vcr'))
    setTextFont('practiceTxt', getFont('vcr'))
  else
    setTextFont('scoreTxt', getFont())
    setTextFont('timeTxt', getFont())
    setTextFont('practiceTxt', getFont('riffic'))
  end
  
end

function setupMSText(isPixel)
  if not luaTextExists("latencyIndicator") then return end
  setTextFont('latencyIndicator', getFont(isPixel and 'vcr' or'riffic'))
  X = 40.0 - 90 + COMBO_OFFSET[1]
  Y = 60.0 - 80 - COMBO_OFFSET[2]
  if isPixel then Y = Y + 60 end
  screenCenter("latencyIndicator", 'xy')
  setProperty("latencyIndicator.x", getProperty("latencyIndicator.x") + X)
  setProperty("latencyIndicator.y", getProperty("latencyIndicator.y") + Y)
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
  then return end

  local barTxt = songName
  if playbackRate ~= 1 then
    barTxt = barTxt.. ' (' .. playbackRate .. 'x)'
  end
  if barType == "time left" then
      local remTime = formatTime(remainingTime())
      barTxt = barTxt .. ' (' .. remTime .. ')'
    elseif barType == "time elapsed" then
      local totalTime = formatTime(getProperty('songLength'))
      local elapsedTime = formatTime((getSongPosition() - noteOffset))
      barTxt = barTxt..' ['..elapsedTime.." | "..totalTime..']'
  end
  setTextString('timeTxt', barTxt)
end

--#endregion

--#region UTILLS

function getData(value, fallback)
  return getDataFromSave('DdtoV2', value, fallback)
end

function opponentNoteHit(id, noteData, noteType, isSustainNote) 
  if funcReflect and not isSustainNote then noteHit(id) end end

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

function getFont(type)
  if type == 'aller' then
    return 'Aller_Rg.ttf'
  elseif type == 'riffic' then --
    return 'riffic.ttf'
  elseif type == 'vcr' then    --
    return 'vcr.ttf'
  else
    return 'Aller_Rg.ttf'
  end
end

--#endregion
