-- Debug function to check Bartender4 detection manually
local function DebugBartender4Detection()
    print("=== BARTENDER4 DETECTION DEBUG ===")
    
    -- Check IsAddOnLoaded function
    local hasIsAddOnLoaded = IsAddOnLoaded ~= nil
    print("IsAddOnLoaded available: " .. tostring(hasIsAddOnLoaded))
    
    if hasIsAddOnLoaded then
        local loaded = IsAddOnLoaded("Bartender4")
        print("IsAddOnLoaded('Bartender4'): " .. tostring(loaded))
    end
    
    -- Check _G.Bartender4
    local hasGlobal = _G.Bartender4 ~= nil
    print("_G.Bartender4 exists: " .. tostring(hasGlobal))
    
    if hasGlobal then
        print("_G.Bartender4 type: " .. type(_G.Bartender4))
        
        -- Check for specific Bartender4 components
        local hasBarManager = _G.Bartender4.BarManager ~= nil
        print("Has BarManager: " .. tostring(hasBarManager))
        
        local hasBars = _G.Bartender4.bars ~= nil
        print("Has bars table: " .. tostring(hasBars))
        
        if _G.Bartender4.GetVersion then
            local success, version = pcall(_G.Bartender4.GetVersion, _G.Bartender4)
            print("Version detection: " .. tostring(success))
            if success then
                print("Bartender4 version: " .. tostring(version))
            end
        end
    end
    
    -- Check addon list method
    local addonCount = GetNumAddOns()
    print("Total addons: " .. addonCount)
    
    for i = 1, addonCount do
        local name = GetAddOnMetadata(i, "Title") or "Unknown"
        if name:find("Bartender") then
            local loaded = IsAddOnLoaded(i)
            print("Found addon: " .. name .. " (loaded: " .. tostring(loaded) .. ")")
        end
    end
    
    print("=== END DEBUG ===")
end

-- Add this debug command
SLASH_DRGUIDEBUG1 = "/drguidebug"
SlashCmdList["DRGUIDEBUG"] = function(msg)
    if msg == "bartender" then
        DebugBartender4Detection()
    else
        print("Debug commands: /drguidebug bartender")
    end
end