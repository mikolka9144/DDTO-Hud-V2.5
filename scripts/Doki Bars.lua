hpReflect = false
mirrorUI = false
alternativeHPBar = false

isNewPsych = false

function onCreatePost()
    loadEnv()
    if not isNewPsych then changeGradientBar() end
end

function onUpdatePost(elapsed)
    if mirrorUI then mirrorHpBar() end
end

function onEvent(name, value1, value2)
  if name == 'Change Character' then
    changeGradientBar()
  end
end

function changeGradientBar()
  if mirrorUI and alternativeHPBar then
    triggerEvent("Refresh NewBar", "true", nil)
  else
    triggerEvent("Refresh NewBar", "false", nil)
  end
end
function loadEnv()
    initSaveData('DdtoV2', 'psychengine/mikolka9144')
    isNewPsych = version:find('0.7')
    alternativeHPBar = getData('alternativeHPBar', alternativeHPBar)
    hpReflect = getData('hpReflect', false)
  
    mirrorUI = getData('anyMirror', false)
  end
  
  function getData(value, fallback)
    return getDataFromSave('DdtoV2', value, fallback)
  end
-- Larger, but more readable
function mirrorHpBar()
    if mirrorUI and (not hpReflect)  then
      if isNewPsych then
        setProperty("healthBar.percent", 100 - (getProperty("health") * 50))
      else
        setProperty("healthBar.value", 2 - getProperty("health"))
      end
      --TODO
    end
  
    local iconP2 = "iconP2"
    local iconP1 = "iconP1"
    local curFrame = ".animation.curAnim.curFrame"
    
  
    barX = getProperty("healthBar.x", false)
    barWidth = getProperty("healthBar.width", false)
    barPrecent = getProperty("healthBar.percent", false)
    p1X = getProperty(iconP1 .. ".scale.x", false)
    p2X = getProperty(iconP2 .. ".scale.x", false)

    if alternativeHPBar then --
      setProperty('iconP2.flipX', true)
      setProperty('iconP1.flipX', true)
      setProperty('healthBar.flipX', true)
      iconP2 = "iconP1"
      iconP1 = "iconP2"
    else
      barPrecent = 100 - barPrecent
    end
    iconOffset = 26;
  
    setProperty(iconP1 .. ".x", barX + (barWidth * (barPrecent * 0.01)) + ((150 * p1X) - 150) / 2 - iconOffset)
    setProperty(iconP2 .. ".x", barX + (barWidth * (barPrecent * 0.01)) - (150 * p2X) / 2 - iconOffset * 2)
  
    setProperty(iconP2 .. curFrame, (barPrecent < 20) and 1 or 0, false)
    setProperty(iconP1 .. curFrame, (barPrecent > 80) and 1 or 0, false)
  end