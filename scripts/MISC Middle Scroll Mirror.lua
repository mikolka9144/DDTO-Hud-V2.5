isMirror = false
isUMM = false

function onCreatePost()
    initSaveData('DdtoV2', 'psychengine/mikolka9144')
    isMirror = getDataFromSave('DdtoV2', 'strumReflect', false)
    isUMM = UMMversion ~= nil
end

function onUpdate(elapsed)
    if middlescroll and isMirror and not isUMM then
        reverse(0)
        reverse(1)
        reverse(2)
        reverse(3)
        setAlpha(0)
        setAlpha(1)
        setAlpha(2)
        setAlpha(3)
        copyValue(0, "x")
        copyValue(1, "x")
        copyValue(2, "x")
        copyValue(3, "x")
        copyValue(0, "y")
        copyValue(1, "y")
        copyValue(2, "y")
        copyValue(3, "y")
    end
end

function copyValue(index, name)
    setPropertyFromGroup('opponentStrums', index, name, getPropertyFromGroup("playerStrums", index, name))
end

function reverse(index)
    setPropertyFromGroup('opponentStrums', index, "visible", true)
    setPropertyFromGroup('playerStrums', index, "visible", false)
    setPropertyFromGroup('playerStrums', index, "alpha", 0)
end

function setAlpha(index)
    setPropertyFromGroup('opponentStrums', index, "alpha", 1)
end
