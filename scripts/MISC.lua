coolGameplay = false

function onCreatePost()
    loadPresets()
    if coolGameplay then 
        makeGameplayCool() 
    else
        close()
    end
end

function loadPresets()
    initSaveData('DdtoV2', 'psychengine/mikolka9144')

    coolGameplay = getData('coolGameplay', coolGameplay)
  end

function makeGameplayCool()
    makeAnimatedLuaSprite('hueh231', 'coolgameplay')
    addAnimationByPrefix('hueh231', 'idle', 'Symbol', 24, true)
    playAnim('hueh231', 'idle')
    setObjectCamera('hueh231', 'hud')
    addLuaSprite('hueh231', true)
end

function getData(value, fallback)
    return getDataFromSave('DdtoV2', value, fallback)
end