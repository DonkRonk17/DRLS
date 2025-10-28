-- DRLS AI Core System - WoW Compatible Version
local DRLS_AI_Core = {}

-- Basic status
DRLS_AI_Core.status = "OPERATIONAL"
DRLS_AI_Core.version = "1.0.0"

-- Initialize function
function DRLS_AI_Core:Initialize()
    print("|cff00ff00🤖 DRLS AI Core: Revolutionary intelligence online!|r")
    return true
end

-- Show status function
function DRLS_AI_Core:ShowStatus()
    -- Get character info safely
    local race = "Unknown"
    local class = "Unknown" 
    local spec = "Unknown"
    local level = 0
    local itemLevel = 0
    
    -- Safe API calls with pcall
    if UnitRace then
        race = UnitRace("player") or "Unknown"
    end
    
    if UnitClass then
        local _, className = UnitClass("player")
        class = className or "Unknown"
    end
    
    if GetSpecialization and GetSpecializationInfo then
        local specIndex = GetSpecialization()
        if specIndex then
            local _, specName = GetSpecializationInfo(specIndex)
            spec = specName or "Unknown"
        end
    end
    
    if UnitLevel then
        level = UnitLevel("player") or 0
    end
    
    if GetAverageItemLevel then
        itemLevel = GetAverageItemLevel() or 0
    end
    
    -- Count addons safely
    local totalAddons = 0
    if GetNumAddOns and IsAddOnLoaded then
        for i = 1, GetNumAddOns() do
            local name = GetAddOnInfo(i)
            if name and IsAddOnLoaded(name) then
                totalAddons = totalAddons + 1
            end
        end
    end
    
    -- Display status
    print("|cff00ff00🤖 DRLS AI System Status:|r")
    print("|cffff9900   Status: " .. self.status .. " | Version: " .. self.version .. "|r")
    print("|cffff9900   Character: " .. race .. " " .. class .. " (" .. spec .. ")|r")
    print("|cffff9900   Level: " .. level .. " | Item Level: " .. itemLevel .. "|r")
    print("|cff00ff00📊 Ecosystem Analysis:|r")
    print("|cffff9900   Total Addons: " .. totalAddons .. "|r")
    print("|cffff0000🚀 Revolutionary intelligence at your service!|r")
end

-- Make globally available
_G.DRLS_AI_Core = DRLS_AI_Core

-- Return for loadfile
return DRLS_AI_Core