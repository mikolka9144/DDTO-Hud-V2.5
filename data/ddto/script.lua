local countdownstarted = false
local selection = 1
local chosenterm = 1
local curPage = 1

OPTION_SIZE = 12
xPos = 0
SET_DESC_INDEX=1
SET_NAME_INDEX=2
SET_CODE_INDEX=3
SET_TYPE_INDEX=4
SET_DATA_INDEX=5

function tableslice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end



function returnNum(list, item)

    local index={}

    for k,v in pairs(list) do
           index[v]=k
    end

    return index[item]

end

function tostrfb(bool)

    if bool then
        return 'On'
    else
        return 'Off'
    end

end

function mysplit(inputstr, sep)

    if sep == nil then
            sep = "%s"
    end

    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end

    return t

end


function onCreate()

    initSaveData('DdtoV2', 'psychengine/mikolka9144')
    precacheSound('scrollMenu')
    precacheMusic('options')
    playMusic("options", 0.9, true)
    options = {
        {"Do you want to play as the opponent? [none/simple/complex]","Mirror mode", "mirror", "string", "none", {"none","simple","complex"}},
        {"","DDTO HUD SETTINGS", "xxxxxac", "none"},
        {"Do you want to enable the judgement counter?","Judgement counter", "ddtoNoteCounter", "bool",true},
        {"Do you want to enable the lane underlay?","Lane Underlay", "ddtoUnderlay", "bool",true},
        {"Set the underlay on how transparent it is.","Underlay alpha", "ddtoUnderlayAlpha", "number", 0.3, 0, 1, 0.01},
        {"Do you want to display Early/Late indicator? ","Early/Late text", "noteDelay", "bool",true},
        {"Do you want to display raw ms time for Early/Late indicator?","Display note Delays in ms", "noteMs", "bool",true},
        {"Do you want to flip opponent icons in mirror mode?","Use alternative Hp bar", "alternativeHPBar", "bool",true},
        {"","NOTE HIT SETTINGS", "xxxxac", "none"},
        {"Do you want hitsounds?","Note Sounds", "hitSound", "bool",true},
        {"Do you want hitsound to depend on ratings","Judge Notes", "judgeHitSound", "bool",true},
        {"How many judgements will have hitSounds: [sicks, goods, bads,shits]","Judge Notes Count", "judgeCount", "number", 1, 0.0, 4, 1},
        {"Hitsound volume","Note Sound Volume", "hitSoundVolume", "number", 0.3, 0, 1, 0.01},
        {"Do you want oppent notes to splash on press?","Opponent Splashes","OpponentHasSplash","bool","true"},
        {"Do you want to disable custom splash system","Reverted splashes","enablePsychSystem","bool",false},
        {"","DDTO BAR SETTINGS", "xxxxxac", "none"},
        {"Do you want to replace score text with one from DDTO?","DDTO score", "customScoreBarText", "bool",true},
        {"Do you want to enable NPS?","NPS counter", "npsEnabled", "bool",true},
        {"","MISC","xcxcxcz","none"},
        {"Do you want to enable coolGameplay?? lol ","COOL GAMEPLAY","coolGameplay","bool",false},
        {"Do you want to enable gfCountdown? (if your gf has one)","GF Countdown","gfCountdown","bool",false},
        {"Do you have skill issue in coding?","DEBUG", "debug", "bool",false}
        }
    
    --print("All: "..#options)
    for i,optionsdata in pairs(options) do
        
        local saveValue = getDataFromSave('DdtoV2', optionsdata[SET_CODE_INDEX],optionsdata[SET_DATA_INDEX])
        if saveValue ~= nil and saveValue ~= "" then
            optionsdata[SET_DATA_INDEX] = saveValue
        end
    end
	shownoptions = tableslice(options, 1, OPTION_SIZE)

    setProperty('healthBarBG.visible', false)
    makeLuaSprite('bg', "bg", xPos, 0)
    setObjectCamera('bg', 'hud')
    addLuaSprite('bg', true)
    scaleObject("bg", 0.8, 0.8, true)

    for i, optionsdata in pairs(shownoptions) do
        makeLuaText('option'..i, 'placeholder', 900, 60, 15 + 45*i)
        setTextSize('option'..i, 37)
        setTextFont('option'..i, 'riffic.ttf')
        setTextBorder("option"..i, 2, "ff7cff")
        setTextAlignment('option'..i, 'left')
        addLuaText('option'..i)

        changeOptionType(0)
        selection = selection + 1

    end        

    selection = 1
    setTextBorder("option1",2,"ffcfff")

    makeLuaText('optiondummy', '=>', 550, 50, 600)
    setTextSize('optiondummy', 30)
    setTextFont('optiondummy', 'riffic.ttf')
    setTextBorder("optiondummy", 2, "ff7cff")
    setProperty('optiondummy.angle', 90)
    addLuaText('optiondummy')

    makeLuaSprite('bar')
    makeGraphic("bar", screenWidth, 18, "000000")
    screenCenter("bar", 'X')
    setProperty("bar.y", screenHeight-18)
    setProperty('bar.alpha', 0.5)
    setObjectCamera('bar', 'hud')
    addLuaSprite('bar', true)

    makeLuaText('page', 'placeholder', 1500, 6, screenHeight-17)
    setTextAlignment('page', 'left')
    setTextBorder("page", 1, "000000")
    setTextSize('page', 16)
    setTextFont('page', 'vcr.ttf')
    addLuaText('page')

    updatePage()

end

function onStartCountdown()
    return Function_Stop
end

function updatePage()
    desc = options[selection][SET_DESC_INDEX]
    if desc == "" then
        setTextString('page', 'Page: '..curPage)
    elseif options[selection][SET_TYPE_INDEX] == "number" then 
        setTextString('page', 'Current '..options[selection][SET_NAME_INDEX]..': '..options[selection][SET_DATA_INDEX].." - Description - "..desc)
    else
        setTextString('page', 'Page: '..curPage.." - Description - "..desc)
    end

end
function validateSettings()
    for i, optionsdata in pairs(options) do
        if optionsdata[SET_DATA_INDEX] == nil then
            if optionsdata[SET_TYPE_INDEX] == 'bool' then
                options[i][SET_DATA_INDEX] = false -- boolean default value
            elseif optionsdata[SET_TYPE_INDEX] == 'string' then
                optionsdata[SET_DATA_INDEX] = '' -- default selected value
                if #optionsdata[SET_DATA_INDEX+1] > 0 then
                    optionsdata[SET_DATA_INDEX] = optionsdata[SET_DATA_INDEX+1][1] -- first string in options of str
                end
            end
        end
        if optionsdata[SET_DATA_INDEX+1] == nil then
            if optionsdata[SET_TYPE_INDEX] == 'number' then
                optionsdata[SET_DATA_INDEX+1] = 10
            end
        end
        if optionsdata[SET_DATA_INDEX] == nil then
            if optionsdata[SET_TYPE_INDEX] == 'number' then
                optionsdata[SET_DATA_INDEX] = 0
            end
        end
    end
end
function scrollBg(delta)
    step = 55*delta
        max = 80
        xPos = ((xPos+step)%max)
        setProperty("bg.x", -xPos)
        setProperty("bg.y", -xPos)
end
function onUpdate(elapsed)
    
    if countdownstarted == false then
        scrollBg(elapsed)

        if keyJustPressed('accept') then
            exitSettings()
        end

        if keyJustPressed('right') then
            changeOptionType(1)
        end
        if keyJustPressed('left') then
            changeOptionType(-1)
        end
        if keyJustPressed('down') then
            changeSelection(1)
        end
        if keyJustPressed('up') then
            changeSelection(-1)
        end

    end
end

function changeOptionType(num)
    optionItem = 'option'..((selection-1)%OPTION_SIZE)+1

    if options[selection] == nil then
	    shownoptions[((selection-1)%OPTION_SIZE)+1] = nil
        return setTextString(optionItem, '')
    end

    optionName = options[selection][SET_NAME_INDEX]

    if options[selection][SET_TYPE_INDEX] == 'string' then

            chosenterm = (returnNum(options[selection][SET_DATA_INDEX+1], options[selection][SET_DATA_INDEX])) + num

            if chosenterm > #options[selection][SET_DATA_INDEX+1] then
                chosenterm = 1
            elseif chosenterm < 1 then
                chosenterm = #options[selection][SET_DATA_INDEX+1]
            end

            options[selection][SET_DATA_INDEX] = options[selection][SET_DATA_INDEX+1][chosenterm]
            setTextString(optionItem, optionName..' '..options[selection][SET_DATA_INDEX])

    elseif options[selection][SET_TYPE_INDEX] == 'bool' then
            if num ~= 0 then
                options[selection][SET_DATA_INDEX] = not options[selection][SET_DATA_INDEX]
            end
            setTextString(optionItem, optionName..' '..tostrfb(options[selection][SET_DATA_INDEX]))
    elseif options[selection][SET_TYPE_INDEX] == 'none' then
        setTextString(optionItem, '--- '..optionName..' ---')
    else
            if num ~= 0 then
                options[selection][SET_DATA_INDEX] = options[selection][SET_DATA_INDEX] + options[selection][SET_DATA_INDEX+3] * num
                if options[selection][SET_DATA_INDEX] > options[selection][SET_DATA_INDEX+2] then
                    options[selection][SET_DATA_INDEX] = options[selection][SET_DATA_INDEX+2]
                end

                if options[selection][SET_DATA_INDEX] < options[selection][SET_DATA_INDEX+1] then
                    options[selection][SET_DATA_INDEX] = options[selection][SET_DATA_INDEX+1]
                end
                updatePage()
            end
            setTextString(optionItem, optionName)
    end
end

function changeSelection(num)
    
    setTextBorder("option"..((selection-1)%OPTION_SIZE)+1,2,"ff7cff")
    selection = selection + num
    
    if (selection) > curPage*OPTION_SIZE or selection > #options then
        -- pointer is outside of page 
        if selection > #options then
            curPage = 1
        else
            curPage = curPage + 1
        end

        shownOpt()

        selection = (curPage*OPTION_SIZE)-(OPTION_SIZE-1)
        setTextBorder("option1",2,"ffcfff")

    elseif (selection) < (curPage*OPTION_SIZE)-(OPTION_SIZE-1) then
        if selection < 1 then
            selection = selection + math.abs(num)
            setTextBorder("option"..selection%8,2,"ffcfff")
            return
        else
            curPage = curPage - 1
        end

        shownOpt();

        selection = curPage*OPTION_SIZE
    end

    playSound('scrollMenu', 0.8)
    setTextBorder("option"..((selection-1)%OPTION_SIZE)+1,2,"ffcfff")
    updatePage()
end
function shownOpt()
        shownoptions = tableslice(options, OPTION_SIZE*(curPage-1), OPTION_SIZE*curPage)
        while #shownoptions < OPTION_SIZE do
            table.insert(shownoptions, {})
        end

        selection = (curPage*OPTION_SIZE)-(OPTION_SIZE-1)
    for i, optionsdata in pairs(shownoptions) do
        if i>OPTION_SIZE then
            return -- DIRTY FIX please change splitter instead
        end
        setTextString('option'..i, 'placeholder', 700, 100, 150 + 50*i)
        changeOptionType(0)
        selection = selection + 1
    end
end

function exitSettings()
    saveSettings('DdtoV2', 'psychengine/mikolka9144')
    endSong()
end
function saveSettings(bundle,path)
    initSaveData(bundle, path)

	for num,option in pairs(options) do
        setDataFromSave(bundle, option[SET_CODE_INDEX], option[SET_DATA_INDEX])
    end

	flushSaveData(bundle)
end
-- It's midnite I am too lazy to explain this
