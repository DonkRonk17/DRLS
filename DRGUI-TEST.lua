local addonName, addon = ...

-- DRGUI Enhanced Core System (Simplified for Testing)
-- ElvUI-Independent version ready for TWW
print("DRGUI: Loading Enhanced UI Framework v2.0.0...")

-- Initialize core variables
DRGUI = DRGUI or {}
DRGUIDB = DRGUIDB or {}
local DEBUG_MODE = true

-- Enhanced Character Combo Detection for TWW
function GetCharacterCombo()
    local race = UnitRace("player")
    local _, class = UnitClass("player") 
    local specIndex = GetSpecialization()
    if not specIndex then
        return "Unknown-Unknown-Unknown-None"
    end
    
    local _, specName = GetSpecializationInfo(specIndex)
    local heroID = "None"
    
    -- Try to get Hero Talent (TWW feature)
    if C_ClassTalents and C_ClassTalents.GetActiveHeroTalentSpec then
        heroID = C_ClassTalents.GetActiveHeroTalentSpec() or "None"
    end
    
    local comboKey = race .. "-" .. class .. "-" .. specName .. "-" .. heroID
    
    if DEBUG_MODE then
        print("DRGUI: Character Combo = " .. comboKey)
    end
    
    return comboKey
end

-- Enhanced Profile Management (ElvUI-Independent)
local function CreateOrLoadProfile(comboKey)
    if not DRGUIDB[comboKey] then
        -- Create new TWW-optimized profile
        DRGUIDB[comboKey] = {
            general = {
                font = "Friz Quadrata TT",
                fontSize = 12,
                version = "2.0.0"
            },
            actionbars = {
                enabled = true,
                bar1 = {enabled = true, buttons = 12},
                bar2 = {enabled = true, buttons = 12}
            },
            unitframes = {
                enabled = true,
                player = {enabled = true},
                target = {enabled = true}
            }
        }
        print("DRGUI: Created new TWW profile for " .. comboKey)
    else
        print("DRGUI: Loaded existing profile for " .. comboKey)
    end
    
    DRGUI.db = DRGUIDB[comboKey]
end

-- Dependency Checking (Updated for ElvUI Independence)
local function CheckDependencies()
    local optionalAddons = {
        "Details",
        "WeakAuras", 
        "DBM-Core",
        "BigWigs",
        "Plater"
    }
    
    local loadedAddons = {}
    local missingAddons = {}
    
    for _, addon in ipairs(optionalAddons) do
        if IsAddOnLoaded(addon) then
            table.insert(loadedAddons, addon)
        else
            table.insert(missingAddons, addon)
        end
    end
    
    if #loadedAddons > 0 then
        print("DRGUI: Optional addons loaded: " .. table.concat(loadedAddons, ", "))
    end
    
    if #missingAddons > 0 then
        print("DRGUI: Available addons: " .. table.concat(missingAddons, ", "))
    end
    
    print("DRGUI: ✅ ElvUI-Independent! No required dependencies!")
    return true
end

-- Enhanced Initialization System  
local function Initialize()
    print("DRGUI: 🚀 Initializing ElvUI-Independent Framework...")
    
    -- Check dependencies (no longer requires ElvUI!)
    if not CheckDependencies() then
        print("DRGUI: ❌ Dependency check failed")
        return
    end
    
    -- Initialize character profile
    local comboKey = GetCharacterCombo()
    CreateOrLoadProfile(comboKey)
    
    -- Try to load engine
    local engineSuccess = false
    if DRGUI_Engine then
        engineSuccess = true
        print("DRGUI: ✅ Engine available")
    else
        print("DRGUI: ⚠️ Engine not loaded, using basic mode")
    end
    
    -- Try to load ActionBars module
    if DRGUI_ActionBars then
        DRGUI.ActionBars = DRGUI_ActionBars
        print("DRGUI: ✅ ActionBars module available")
    else
        print("DRGUI: ⚠️ ActionBars module not loaded")
    end
    
    print("DRGUI: ✅ Initialization complete! Type /drgui help for commands")
end

-- Event Handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        print("DRGUI: Addon loaded successfully!")
        DRGUIDB = DRGUIDB or {}
    elseif event == "PLAYER_LOGIN" then
        Initialize()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        local comboKey = GetCharacterCombo()
        CreateOrLoadProfile(comboKey)
        print("DRGUI: Profile updated for specialization change")
    end
end)

-- Slash Commands
SLASH_DRGUI1 = "/drgui"
SlashCmdList["DRGUI"] = function(msg)
    local command = msg:match("^(%S*)") or ""
    
    if command == "test" then
        print("=== DRGUI TEST RESULTS ===")
        print("DRGUI available:", DRGUI ~= nil)
        print("DRGUIDB available:", DRGUIDB ~= nil)
        print("Engine available:", DRGUI_Engine ~= nil)
        print("ActionBars available:", DRGUI.ActionBars ~= nil)
        print("ElvUI loaded:", IsAddOnLoaded("ElvUI"))
        print("Current combo:", GetCharacterCombo())
        local profileCount = 0
        for _ in pairs(DRGUIDB) do profileCount = profileCount + 1 end
        print("Total profiles:", profileCount)
        print("=== END TEST ===")
        
    elseif command == "debug" then
        DEBUG_MODE = not DEBUG_MODE
        print("DRGUI Debug:", DEBUG_MODE and "ON" or "OFF")
        
    elseif command == "deps" then
        CheckDependencies()
        
    elseif command == "combo" then
        local combo = GetCharacterCombo()
        print("Current Character Combo: " .. combo)
        
    elseif command == "profile" then
        local combo = GetCharacterCombo()
        if DRGUIDB[combo] then
            print("Profile exists for " .. combo)
            print("Version:", DRGUIDB[combo].general and DRGUIDB[combo].general.version or "Unknown")
        else
            print("No profile found for " .. combo)
        end
        
    elseif command == "reload" then
        print("DRGUI: Reloading UI...")
        ReloadUI()
        
    elseif command == "help" or command == "" then
        print("=" .. string.rep("=", 50))
        print("DRGUI v2.0.0 - ElvUI Independent Edition")
        print("=" .. string.rep("=", 50))
        print("Testing Commands:")
        print("  /drgui test    - Run comprehensive test")
        print("  /drgui debug   - Toggle debug mode")
        print("  /drgui deps    - Check dependencies")
        print("  /drgui combo   - Show character combo")
        print("  /drgui profile - Show profile info")
        print("  /drgui reload  - Reload UI")
        print("")
        print("🎯 DRGUI is now ElvUI-Independent!")
        print("✅ Ready for The War Within expansion!")
        print("=" .. string.rep("=", 50))
    else
        print("Unknown command: " .. command)
        print("Type /drgui help for available commands")
    end
end

print("DRGUI: 📋 Simplified test version loaded successfully!")
print("DRGUI: 🔥 Ready to test ElvUI independence!")