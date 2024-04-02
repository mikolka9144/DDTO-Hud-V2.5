-- OPTIONS --
local OpponentHasSplash = true --allows opponent splash?

--options related to the splash (aplies in all song)--
local customSplashSkin = false --let's you have your custom splashes
local isLibitina = false       --sets the splash into libitina version

--enables the old/psych splash (applies in all song)--
local enablePsychSplashes = false --sets to the default old splashes
local enablePsychSystem = false   --if true makes the properties of the splash appear like the psych

--Mess with it if you want your own custom splash but customSplashSkin MUST be enabled--
local splashPath = ''
local splashTexture = 'noteSplashes'
local splashAnims = {}
local splashOffset = {}
local splashScale = 1
local splashFPS = 24
local splashAntialiasing = true --for pixel version (default:false/non-pixel)


-- CODE N STUFF (No touch unless you know what you doin) --
local reverseArrows = false
local splashesDestroyed = 0
local splashCount = 0
local sickTrack = -1
local usePixelSplash = false

function onCreatePost()
  importSettings()
  isNewPsych = version:find('0.7')
  PlayState = (isNewPsych and 'states.PlayState' or 'PlayState')
end

function goodNoteHit(noteIndex, noteDirection, noteType, isSustainNote)
  spawnSplash(noteIndex, noteDirection, noteType, isSustainNote, true);
end

function opponentNoteHit(noteIndex, noteDirection, noteType, isSustainNote)
  spawnSplash(noteIndex, noteDirection, noteType, isSustainNote, false);
end

function spawnSplash(noteIndex, noteDirection, noteType, isSustainNote, isPlayerSplash)
  if getPropertyFromGroup('unspawnNotes', noteIndex, 'eventVal1') == "REPEAT_NOTE" 
  then return end

  if reverseSplashes then
    isPlayerSplash = not isPlayerSplash
  end
  if isPlayerSplash then
    ratingTrack = getPropertyFromGroup('notes', noteIndex, 'rating')
    if ratingTrack == 'sick' and not isSustainNote and not enablePsychSplashes then
      if reverseArrows then
        spawnPlayerSplash(noteDirection, 'opponentStrums');
      else
        spawnPlayerSplash(noteDirection, 'playerStrums');
      end
    end
  else
    if OpponentHasSplash and not isSustainNote then
      if reverseArrows then
        spawnPlayerSplash(noteDirection, 'playerStrums');
      else
        if OpponentHasSplash then
          spawnPlayerSplash(noteDirection, 'opponentStrums');
        end
      end
    end
  end
end

function spawnPlayerSplash(noteDirection, strumName) -- 'playerStrums'
  splashThing = splashAnims[noteDirection + 1]
  splashCount = splashCount + 1
  splashName = 'noteSplashPlayer' .. splashCount
  NOTES_ORDER = getObjectOrder('notes') == -1 and getObjectOrder('noteGroup') or getObjectOrder('notes')

  precacheImage(splashPath .. splashTexture)
  makeAnimatedLuaSprite(splashName, splashPath .. splashTexture,
    getPropertyFromGroup(strumName, noteDirection, 'x') - splashOffset[1],
    getPropertyFromGroup(strumName, noteDirection, 'y') - splashOffset[2]);
  addAnimationByPrefix(splashName, 'anim', splashThing, splashFPS, false);

  if (enablePsychSystem == true) then
    addAnimationByPrefix(splashName, 'anim', splashThing .. getRandomInt(1, 2), 24, false);
  end

  scaleObject(splashName, splashScale, splashScale)
  setProperty(splashName .. '.antialiasing', splashAntialiasing);

  setObjectCamera(splashName, 'hud');
  setObjectOrder(splashName, NOTES_ORDER + 1); -- this better make the splashes go in front-
  setProperty(splashName .. '.visible', getPropertyFromGroup(strumName, noteDirection, 'visible'));
  setProperty(splashName .. '.alpha', getPropertyFromGroup(strumName, noteDirection, 'alpha'));
  addLuaSprite(splashName);
end

function onUpdate()
  refreshSplashes()
  if enablePsychSplashes then
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      setPropertyFromGroup('unspawnNotes', i, 'noteSplashTexture', splashTexture)
      splashAnims = { 'note splash purple ', 'note splash blue ', 'note splash green ', 'note splash red ' }
      splashOffset = { 100, 120 }
      splashScale = 1
      splashAlpha = 0.8
      splashAntialiasing = true
      if usePixelSplash and enablePsychSplashes then
        setPropertyFromGroup('unspawnNotes', i, 'noteSplashTexture', splashPath .. splashTexture)
        splashPath = 'pixelUI/'
        splashTexture = 'noteSplashes-pixel'
      end
    end
  end


  if sickTrack ~= 0 then
    for splashes = splashesDestroyed, splashCount do
      if getProperty('noteSplashPlayer' .. splashes .. '.animation.curAnim.finished') then
        setProperty('noteSplashPlayer' .. splashes .. '.visible', false)
        removeLuaSprite('noteSplashPlayer' .. splashes, true)
        splashesDestroyed = splashesDestroyed + 1
      end
    end

    for splashesDefault = 0, getProperty('grpNoteSplashes.length') do
      if enablePsychSplashes == true then
        setPropertyFromGroup('grpNoteSplashes', splashesDefault, 'visible', true)
        enablePsychSplashes = true
      else
        setPropertyFromGroup('grpNoteSplashes', splashesDefault, 'visible', false)
        enablePsychSplashes = false
      end
    end
  end
end

function refreshSplashes()
  usePixelSplash = getPropertyFromClass(PlayState, 'isPixelStage')
  if customSplashSkin then
    return
  elseif isLibitina then
    splashTexture = 'libbie_Splash'
    splashAnims = { 'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1' }
    splashOffset = { 75, 80 }
    splashScale = 1
    splashAntialiasing = true
  elseif usePixelSplash then
    splashTexture = 'pixel_Splash'
    splashAnims = { 'note splash purple 1', 'note splash blue 1', 'note splash green 1', 'note splash red 1' }
    splashOffset = { 80, 80 }
    splashScale = 6
    splashAntialiasing = false
  else
    splashTexture = 'NOTE_splashes_doki'
    splashAnims = { 'note splash purple 2', 'note splash blue 2', 'note splash green 2', 'note splash red 2' }
    splashOffset = { 140, 140 }
    splashScale = 1
    splashAntialiasing = true
  end
end

function getData(value, fallback)
  local x = getDataFromSave('DdtoV2', value, fallback)
  return x == nil and fallback or x
end

function importSettings()
  OpponentHasSplash = getData("OpponentHasSplash", false)
  enablePsychSystem = getData("enablePsychSystem", false)
  reverseSplashes = getData("funcReflect", false)

  if getData("strumReflect", false) then
    reverseArrows = true
    OpponentHasSplash = true
  end
end
