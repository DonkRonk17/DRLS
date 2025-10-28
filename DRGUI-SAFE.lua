-- DRGUI Safe Test Version - No Loops, No Spam, Minimal Code
local addonName = ...

print("DRGUI-SAFE: Starting minimal test...")

-- Basic variables only
DRGUI = DRGUI or {}
DRGUIDB = DRGUIDB or {}

-- Very simple character detection (no loops)
local function GetSimpleCombo()
    local race = UnitRace("player") or "Unknown"
    local _, class = UnitClass("player")
    class = class or "Unknown"
    
    return race .. "-" .. class
end

-- Simple initialization (run only once)
local hasInitialized = false
local function SafeInitialize()
    if hasInitialized then
        return -- Prevent multiple runs
    end
    hasInitialized = true
    
    print("DRGUI-SAFE: Initializing (once only)...")
    
    local combo = GetSimpleCombo()
    print("DRGUI-SAFE: Character = " .. combo)
    
    -- Create minimal profile if needed
    if not DRGUIDB[combo] then
        DRGUIDB[combo] = {
            created = date(),
            version = "2.0.0-safe"
        }
        print("DRGUI-SAFE: Created profile for " .. combo)
    else
        print("DRGUI-SAFE: Loaded profile for " .. combo)
    end
    
    print("DRGUI-SAFE: ✅ Success! ElvUI not required!")
    print("DRGUI-SAFE: Type /drgui for test commands")
end

-- Event frame (minimal events only)
local frame = CreateFrame("Frame")
local eventsRegistered = false

local function RegisterEventsOnce()
    if eventsRegistered then
        return
    end
    eventsRegistered = true
    
    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterEvent("PLAYER_LOGIN")
end

-- Safe event handler (no infinite loops)
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        print("DRGUI-SAFE: Addon loaded event")
        -- Don't do anything complex here
        
    elseif event == "PLAYER_LOGIN" then
        print("DRGUI-SAFE: Player login event")
        -- Safe delay before initialization
        C_Timer.After(1, SafeInitialize)
        
        -- Unregister events to prevent spam
        frame:UnregisterEvent("ADDON_LOADED")
        frame:UnregisterEvent("PLAYER_LOGIN")
    end
end)

-- Simple slash command (no complex logic)
SLASH_DRGUI1 = "/drgui"
SlashCmdList["DRGUI"] = function(msg)
    local cmd = (msg or ""):trim():lower()
    
    if cmd == "test" then
        print("=== DRGUI SAFE TEST ===")
        print("DRGUI available:", DRGUI ~= nil)
        print("DRGUIDB available:", DRGUIDB ~= nil)
        print("ElvUI loaded:", IsAddOnLoaded("ElvUI"))
        print("Character:", GetSimpleCombo())
        print("Initialization:", hasInitialized)
        
        local count = 0
        for _ in pairs(DRGUIDB) do 
            count = count + 1 
        end
        print("Profiles:", count)
        print("=== TEST COMPLETE ===")
        
    elseif cmd == "clean" then
        print("DRGUI-SAFE: Cleaning up...")
        hasInitialized = false
        eventsRegistered = false
        print("DRGUI-SAFE: Reset complete")
        
    elseif cmd == "combo" then
        print("Character Combo:", GetSimpleCombo())
        
    elseif cmd == "" or cmd == "help" then
        print("DRGUI-SAFE Commands:")
        print("  /drgui test  - Run safe test")
        print("  /drgui combo - Show character") 
        print("  /drgui clean - Reset state")
        print("✅ This version prevents infinite loops!")
        
    else
        print("Unknown command. Use /drgui help")
    end
end

-- Register events once at load
RegisterEventsOnce()

print("DRGUI-SAFE: Loaded successfully - No spam/loops!")