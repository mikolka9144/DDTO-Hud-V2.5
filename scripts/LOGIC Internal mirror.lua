red = 1
green = 1
blue = 1


local enabled = true
local keys = { "left", "down", "up", "right" }
local bfHoldTimer = 0
local canHold = false
local holdKey = ""

function onCreatePost()
  if not getDataFromSave('DdtoV2', 'internalMirror') or not getDataFromSave('DdtoV2', 'anyMirror') then
    close()
    enabled = false
    return 
  end
  mirrorNotes()
end

function onUpdate(elapsed)
  if not enabled then return end
  if canHold then
    if keyPressed(holdKey) then
      bfHoldTimer = bfHoldTimer + elapsed
      setProperty('dad.holdTimer', 0)
    else
      canHold = false
      setProperty('dad.holdTimer', bfHoldTimer)
      bfHoldTimer = 0
    end
  end
end

function onTimerCompleted(tag, loops, loopsLeft)
  if tag == "missRevert" then
    blueballDad(false)
  end
end

---------------------------

function blueballDad(miss)
  if miss then
    if getProperty('dad.colorTransform.redMultiplier') ~= 0.6 and getProperty('dad.colorTransform.greenMultiplier') ~= 0.1 and getProperty('dad.colorTransform.blueMultiplier') ~= 0.1 then
      red = getProperty('dad.colorTransform.redMultiplier')
      green = getProperty('dad.colorTransform.greenMultiplier')
      blue = getProperty('dad.colorTransform.blueMultiplier')
    end
    setProperty('dad.colorTransform.redMultiplier', 0.6)
    setProperty('dad.colorTransform.greenMultiplier', 0.1)
    setProperty('dad.colorTransform.blueMultiplier', 0.6)
  else
    cancelTimer("missRevert")
    setProperty('dad.colorTransform.redMultiplier', red)
    setProperty('dad.colorTransform.greenMultiplier', green)
    setProperty('dad.colorTransform.blueMultiplier', blue)
  end
end

function noteMiss(id, noteData, noteType, isSustainNote)
  animToPlay = getProperty('singAnimations')[noteData + 1]
  char = 'dad'
  --debugPrint(getPropertyFromGroup('notes', id, 'noMissAnimation'))
  if (getPropertyFromGroup('notes', id, 'noMissAnimation')) then
    if checkAnimationExists(char, animToPlay, 'miss') then
      playAnim(char, animToPlay .. 'miss', true)
    else
      blueballDad(true)
      time = stepCrochet * (0.0011 / playbackRate) * getProperty('dad.singDuration')
      runTimer("missRevert", time, 1)
      playAnim(char, animToPlay, true)
    end
  end
  return Function_Stop
end

---------------
function mirrorNotes()
  if not middlescroll then
    for i = 0, getProperty('strumLineNotes.members.length') do
      local name = i >= 4 and 'Opponent' or 'Player'
      setProperty('strumLineNotes.members[' .. i .. '].x', _G['default' .. name .. 'StrumX' .. i % 4])
      setProperty('strumLineNotes.members[' .. i .. '].y', _G['default' .. name .. 'StrumY' .. i % 4])
    end
  end
  for i = 0, getProperty('unspawnNotes.length') - 1 do
    setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)
    setPropertyFromGroup('unspawnNotes', i, 'noMissAnimation', true)
    setPropertyFromGroup('unspawnNotes', i, 'mustPress', not getPropertyFromGroup('unspawnNotes', i, 'mustPress'))
  end
end

---
function checkAnimationExists(char, anim, suffix)
  anim = 'anim'
  if (version:find('0.7')) then anim = anim .. "ation" end
  if suffix == nil then
    return runHaxeCode("game." .. char .. "." .. anim .. ".exists('" .. anim .. "');")
  else
    return runHaxeCode("game." .. char .. "." .. anim .. ".exists('" .. anim .. "' + '" .. suffix .. "');")
  end
end

function noteHit(char, noteData, noteType,a,b)
  if getPropertyFromGroup('unspawnNotes', a, 'eventVal1') == "REPEAT_NOTE" 
  then return end
  animToPlay = getProperty('singAnimations')[noteData + 1]
  blueballDad(false)

  if gfSection then
    --playAnim('gf', animToPlay, true)
    char = 'gf'
  end

  if noteType == 'GF Sing' then
    playAnim('gf', animToPlay, true)
    char = 'gf'

  elseif noteType == 'Hey!' then
    playAnim(char, 'hey', true)
    setProperty(char .. '.specialAnim', true)
    setProperty(char .. '.heyTimer', 0.6)

  elseif noteType == 'Alt Animation' then
    if checkAnimationExists(char, animToPlay, '-alt') then
      playAnim(char, animToPlay .. '-alt', true)
    else
      playAnim(char, animToPlay, true)
    end

  elseif noteType == 'No Animation' then
    playAnim(char, 'idle')
  else 
    if altAnim then
      if checkAnimationExists(char, animToPlay, '-alt') then
        playAnim(char, animToPlay .. '-alt', true)
      else
        playAnim(char, animToPlay, true)
      end
    else
      playAnim(char, animToPlay, true)
    end

    if noteType ~= '' then 
      setPropertyFromGroup('unspawnNotes', a, 'eventVal1', "REPEAT_NOTE")
      if char == 'boyfriend' then
        callOnLuas('goodNoteHit', {a, noteData, noteType, b}, true,false,{},{})
      else
        callOnLuas('opponentNoteHit', {a, noteData, noteType, b}, true,false,{},{})
      end
    end 
  end

  if char == "dad" then
    canHold = true
    bfHoldTimer = 0
    holdKey = keys[noteData + 1]
  end
  setProperty(char .. '.holdTimer', 0)
end

---------

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
  if not enabled then return end
  noteHit("dad", noteData, noteType,membersIndex,isSustainNote)
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
  if not enabled then return end
  noteHit("boyfriend", noteData, noteType,membersIndex,isSustainNote)
end
