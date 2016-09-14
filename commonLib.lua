-- ============= dimension related =============
function autoResize(target, defaultDimension, immersive, region)
    local oldROI = Settings:getROI();
    local max = 0
    local localX = defaultDimension
    if (region ~= nil) then Settings:setROI(region) end
    if (exists(target, 0)) then
        resumeROI(oldROI)
        return defaultDimension
    end
    usePreviousSnap(true)

    setImmersiveMode(not immersive)
    if (exists(target, 0)) then
        resumeROI(oldROI)
        usePreviousSnap(false)
        return defaultDimension
    end

    setImmersiveMode(immersive)
    target:similar(0.8)
    local range = defaultDimension * 0.15
    for x = defaultDimension - range, defaultDimension + range, 10 do
        Settings:setCompareDimension(true, x)
        if (exists(target, 0)) then
            if (getLastMatch():getScore() < max) then
                localX = x - 10
                break
            end
            max = getLastMatch():getScore()
        end
    end

    max = 0
    for x = (localX - 9), (localX + 9) do
        Settings:setCompareDimension(true, x)
        if (exists(target, 0)) then
            if (getLastMatch():getScore() < max) then
                Settings:setCompareDimension(true, x - 1)
                resumeROI(oldROI)
                usePreviousSnap(false)
                return (x - 1)
            end
            max = getLastMatch():getScore()
        end
    end

    if (max == 0) then
        Settings:setCompareDimension(true, defaultDimension)
        resumeROI(oldROI)
        usePreviousSnap(false)
        return -1
    end

    resumeROI(oldROI)
    usePreviousSnap(false)
    return (localX + 9)
end

-- ============= Image recognition related =============
function regionWaitMulti(target, seconds, debug, skipLocation)
    local timer = Timer()
    local match
    while (true) do
        for i, t in ipairs(target) do
            if (debug) then t.region:highlight(0.5) end
            if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
            if ((t.region and (t.region):exists(t.target, 0)) or
                    (not t.region and exists(t.target, 0))) then -- check once
                usePreviousSnap(false)
                if (t.region) then
                    match = (t.region):getLastMatch()
                else
                    match = getLastMatch
                end
                if (debug) then match:highlight(0.5) end
                return i, t.id, match
            end
        end
        if (skipLocation ~= nil) then click(skipLocation) end
        if (timer:check() > seconds) then
            usePreviousSnap(false)
            return -1, "__none__"
        end
    end
end

function waitMulti(target, seconds, skipLocation)
    local timer = Timer()
    while (true) do
        for i, t in ipairs(target) do
            if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
            if (exists(t, 0)) then -- check once
            usePreviousSnap(false)
            return i, getLastMatch()
            end
        end
        if (skipLocation ~= nil) then click(skipLocation) end
        if (timer:check() > seconds) then
            usePreviousSnap(false)
            return -1
        end
    end
end

function existsMultiMax(target, region)
    local oldROI = Settings:getROI()
    local maxScore = 0
    local maxIndex = 0
    local match
    if (region ~= nil) then Settings:setROI(region) end
    for i, t in ipairs(target) do
        if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
        if (exists(t, 0)) then -- check once
        local score = getLastMatch():getScore()
        if (score > maxScore) then
            maxScore = score
            maxIndex = i
            match = getLastMatch()
        end
        end
    end

    resumeROI(oldROI)
    usePreviousSnap(false)
    if (maxScore == 0) then
        return -1
    end
    return maxIndex, match
end

function resumeROI(oldROI)
    if (oldROI) then
        Settings:setROI(oldROI)
    else
        Settings:setROI()
    end
end

-- ============= UI related ================
function simpleDialog(title, message)
    dialogInit()
    addTextView(message)
    dialogShow(title)
end

function detectLanguage(target, list, region)
    local oldROI = Settings:getROI();
    if (region ~= nil) then Settings:setROI(region) end
    local langList = ""
    for i, l in ipairs(list) do
        if (exists(target..l..".png", 0)) then
            resumeROI(oldROI)
            return l
        end
        langList = langList .. l .."\n"
    end
    return "none", langList

end

function offOnScreen(second, pinLock, pin)
    keyevent(26) -- power
    wait(second)
    keyevent(82) --unlock
    if (pinLock) then
        type(pin) --passcode
        keyevent(66) -- enter
    end
end

-- ============= strings related ================
function fileExists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function loadStrings(path)
    local language = getLanguage()
    local file = path.."strings."..getLanguage()..".lua";
    if (fileExists(file)) then
        dofile(file)
    else
        if (fileExists(path.."strings.lua")) then
            dofile(path.."strings.lua")
        end
    end
end

-- ============= Lua language related =============
function tableLookup(table, item)
    for i, t in ipairs(table) do
        if (t == item) then return i end
    end
    return -1
end

function randomNumer(value)
    return (math.floor((math.random() - 0.5) * 2 * value))
end