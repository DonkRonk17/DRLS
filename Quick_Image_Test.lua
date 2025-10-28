-- DRLS Image Manager Test Script
-- Quick test to verify Image Manager functionality

print("|cffff0000🧪 DRLS Image Manager Test Starting...|r")

-- Test 1: Check if Image Manager is loaded
if DRLS and DRLS.ImageManager then
    print("|cff00ff00✅ Image Manager system loaded|r")
else
    print("|cffff0000❌ Image Manager system NOT loaded|r")
    return
end

-- Test 2: Check database structure
if DRLSDB and DRLSDB.images then
    print("|cff00ff00✅ Image Manager database initialized|r")
    print("|cffff9900   Cache enabled: " .. tostring(DRLSDB.images.settings.enableCaching) .. "|r")
    print("|cffff9900   Max cache size: " .. DRLSDB.images.settings.maxCacheSize .. "|r")
else
    print("|cffff0000❌ Image Manager database NOT initialized|r")
end

-- Test 3: Test core functions
local functions = {
    "LoadImage",
    "GetBorder", 
    "GetIcon",
    "GetTexture",
    "GetBackground",
    "ShowStatus",
    "ClearCache",
    "AddCustomPath"
}

for _, funcName in pairs(functions) do
    if DRLS.ImageManager[funcName] then
        print("|cff00ff00✅ " .. funcName .. " function available|r")
    else
        print("|cffff0000❌ " .. funcName .. " function missing|r")
    end
end

-- Test 4: Test image loading with fallbacks
print("|cffff9900🔍 Testing image loading with fallbacks...|r")

local testImages = {
    {name = "default", category = "borders", expected = true},
    {name = "nonexistent", category = "icons", expected = true}, -- Should fallback
    {name = "test", category = "textures", expected = true} -- Should fallback
}

for _, test in pairs(testImages) do
    local success, result = pcall(function()
        return DRLS.ImageManager:LoadImage(test.name, test.category)
    end)
    
    if success and result then
        print("|cff00ff00✅ LoadImage('" .. test.name .. "', '" .. test.category .. "') = " .. tostring(result) .. "|r")
    else
        print("|cffff0000❌ LoadImage('" .. test.name .. "', '" .. test.category .. "') failed|r")
    end
end

-- Test 5: Test convenience functions
print("|cffff9900🔍 Testing convenience functions...|r")
local convenienceTests = {
    {func = "GetBorder", param = "default"},
    {func = "GetIcon", param = "default"},
    {func = "GetTexture", param = "default"},
    {func = "GetBackground", param = "default"}
}

for _, test in pairs(convenienceTests) do
    local success, result = pcall(function()
        return DRLS.ImageManager[test.func](DRLS.ImageManager, test.param)
    end)
    
    if success and result then
        print("|cff00ff00✅ " .. test.func .. "('" .. test.param .. "') = " .. tostring(result) .. "|r")
    else
        print("|cffff0000❌ " .. test.func .. "('" .. test.param .. "') failed|r")
    end
end

print("|cffff0000🧪 Image Manager Test Complete!|r")
print("|cffff9900💡 Try these commands:|r")
print("|cff00ff00   /drls images - Show image manager status|r")
print("|cff00ff00   /drls clearcache - Clear image cache|r")