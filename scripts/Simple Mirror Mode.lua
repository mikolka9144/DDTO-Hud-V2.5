MirrorMode = false

function onCreatePost()
    MirrorMode = getDataFromSave('DdtoV2', 'internalMirror')
    if MirrorMode then 
        mirrorNotes()
    end
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if MirrorMode then
        playMirrorAnim("dad",noteData,noteType)
    end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if MirrorMode then
      playMirrorAnim("boyfriend",noteData,noteType)
    end
end

function noteMiss(id, noteData, noteType, isSustainNote)
  if MirrorMode then
    animToPlay = getProperty('singAnimations')[noteData + 1]
    char = 'dad'
    if true then -- (getPropertyFromGroup('notes', id, 'noMissAnimation')) then
      if checkAnimationExists(char, animToPlay, 'miss') then
        playAnim(char, animToPlay .. 'miss', true)
      else
        playAnim(char, animToPlay, true)
      end
    end
    return Function_Stop
  end
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
  if suffix == nil then
    return runHaxeCode("game."..char..".anim.exists('"..anim.."');")
  else
    return runHaxeCode("game."..char..".anim.exists('"..anim.."' + '"..suffix.."');")
  end
  --return runHaxeCode("game.]]..char..[[.animOffsets.exists(']]..anim..[[' + ']]..animSuffix..[[');")
end

function playMirrorAnim(char,noteData,noteType)
    animToPlay = getProperty('singAnimations')[noteData + 1]
    if noteType == 'GF Sing' then
      playAnim('gf', animToPlay, true)
      char = 'gf'
    end

    if noteType == 'Hey!' then
      playAnim(char, 'hey', true)
      setProperty(char .. '.specialAnim', true)
      setProperty(char .. '.heyTimer', 0.6)
    end

    if noteType == 'Alt Animation' then
      if checkAnimationExists(char, animToPlay, '-alt') then
        playAnim(char, animToPlay .. '-alt', true)
      else
        playAnim(char, animToPlay, true)
      end
    end

    if noteType == 'No Animation' then
      playAnim(char, 'idle')
    end

    if noteType == '' then
      playAnim(char, animToPlay, true)
    end

    if gfSection then
      playAnim('gf', animToPlay, true)
      char = 'gf'
    elseif altAnim then
      if checkAnimationExists(char, animToPlay, '-alt') then
        playAnim(char, animToPlay .. '-alt', true)
      else
        playAnim(char, animToPlay, true)
      end
    end
    setProperty(char .. '.holdTimer', 0)
end
