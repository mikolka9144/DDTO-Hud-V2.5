isNewPsych = false
BG = ""

function onCreate()
    addHaxeLibrary("Std", '')
end

function onCreatePost()
    isNewPsych = version:find('0.7')
    BG = isNewPsych and "timeBar" or "timeBarBG"
    runHaxeCode('game.' .. BG .. '.kill();')
    debugPrint(BG)
    makeTimeBarBG()
    if not isNewPsych then
        setObjectOrder('timeBar', getObjectOrder('timeBarBack') + 1)
        setObjectOrder('timeTxt', getObjectOrder('timeBar') + 1)
    end
end

function onUpdatePost()
    -- some mods love to fuck with time bar, so let's help them by syncing background with it.
    setProperty("timeBarBack.alpha", getProperty("timeBar.alpha"))
    setProperty("timeBarBack.visible", getProperty("timeBar.visible"))
end

function onEvent(eventName, value1, value2)
    if eventName == "Refresh NewBar" and not isNewPsych then
        dad = 'dad'
        boyfriend = 'boyfriend'
        if value1 == "true" then
            dad = 'boyfriend'
            boyfriend = 'dad'
        end
        colorShitBF = getHealthColor(boyfriend)
        colorShitDad = getHealthColor(dad)

        daCode = [[
        game.timeBar.createGradientBar([0x0], [Std.parseInt('0xFF' + ']] ..
        colorShitBF .. [['), Std.parseInt('0xFF' + ']] .. colorShitDad .. [[')]);
        ]]
        runHaxeCode(daCode)
    end
end

--------------------

function makeTimeBarBG()
    makeLuaSprite('timeBarBack', 'timeBar')
    setObjectCamera('timeBarBack', 'hud')
    setProperty('timeBarBack.alpha', 0)
    setProperty('timeBarBack.x', getProperty(BG..'.x'))
    setProperty('timeBarBack.y', getProperty(BG..'.y'))
    addLuaSprite('timeBarBack')
end

function getHealthColor(chr)
    array = getProperty(chr .. ".healthColorArray")
    rgbToHex = string.format('%.2x%.2x%.2x', array[1], array[2], array[3])
    print(rgbToHex .. "")
    return rgbToHex
end
