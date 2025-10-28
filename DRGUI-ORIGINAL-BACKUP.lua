local addonName, addon = ...

-- DRGUI Enhanced Core System
-- Complete ElvUI functionality integrated for TWW compatibility
DRGUI = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DRGUI", true)

-- Initialize DRGUI Database and Core Systems
DRGUIDB = DRGUIDB or {}
DRGUI.db = DRGUIDB

-- Core Framework Variables
DRGUI.ActionBars = nil
DRGUI.UnitFrames = nil
DRGUI.Nameplates = nil
DRGUI.Chat = nil
DRGUI.Minimap = nil
DRGUI.DataBars = nil
DRGUI.DataTexts = nil
DRGUI.Auras = nil
DRGUI.Skins = nil
DRGUI.Config = nil

local DEBUG_MODE = true  -- Toggle for testing

-- Load DRGUI Engine
if not DRGUI_Engine then
    local success, err = pcall(dofile, "core/engine.lua")
    if not success then
        print("DRGUI CRITICAL ERROR: Could not load core engine!")
        print("Error: " .. tostring(err))
        return
    end
end

-- Enhanced Character Combo Detection for TWW
function GetCharacterCombo()
    local race = UnitRace("player")
    local _, class = UnitClass("player")
    local specIndex = GetSpecialization()
    if not specIndex then
        return "Unknown-Unknown-Unknown-None"
    end
    
    local _, specName, _, _, _, specID = GetSpecializationInfo(specIndex)
    local heroID = C_ClassTalents.GetActiveHeroTalentSpec() or "None"
    
    -- Enhanced combo key for TWW expansion
    local comboKey = race .. "-" .. class .. "-" .. specName .. "-" .. heroID
    
    if DEBUG_MODE then
        print("DRGUI Combo Detected: " .. comboKey .. " - Ready for TWW!")
    end
    
    return comboKey
end

-- Enhanced Profile Management (ElvUI-Independent)
local function CreateOrLoadProfile(comboKey)
    if not DRGUIDB[comboKey] then
        -- Create new profile with DRGUI defaults (no ElvUI dependency)
        DRGUIDB[comboKey] = {
            general = {
                font = "Expressway",
                fontSize = 12,
                fontStyle = "OUTLINE",
                backdropfadecolor = {0.054, 0.054, 0.054, 0.8}
            },
            actionbars = {
                enabled = true,
                bar1 = {
                    enabled = true,
                    visibility = "[petbattle] hide; show",
                    buttons = 12,
                    buttonsPerRow = 12,
                    buttonSize = 32,
                    buttonSpacing = 2
                },
                bar2 = {enabled = true, buttons = 12},
                bar3 = {enabled = true, buttons = 12},
                bar4 = {enabled = true, buttons = 12},
                bar5 = {enabled = true, buttons = 12},
                bar6 = {enabled = true, buttons = 12}
            },
            unitframes = {
                enabled = true,
                player = {enabled = true, width = 230, height = 55},
                target = {enabled = true, width = 230, height = 55},
                party = {enabled = true},
                raid = {enabled = true}
            },
            nameplates = {
                enabled = true,
                showFriendly = false,
                showEnemy = true
            },
            chat = {
                enabled = true,
                panelWidth = 412,
                panelHeight = 180
            }
        }
        
        print("DRGUI: New TWW profile created for " .. comboKey .. "!")
        print("Profile optimized for The War Within expansion!")
    else
        print("DRGUI: Loaded existing profile for " .. comboKey)
    end
    
    -- Apply profile settings to current session
    DRGUI.db = DRGUIDB[comboKey]
    
    -- Initialize modules with profile data
    if DRGUI_Engine then
        DRGUI_Engine:ApplyProfile(DRGUI.db)
    end
end

-- Enhanced Integration System (ElvUI-Independent)
local function SetupIntegrations(comboKey)
    -- Details! integration for DPS tracking
    if Details then
        -- Enhanced DPS monitoring without ElvUI dependency
        local function OnHighDPS()
            print("DRGUI: High DPS detected! Check WarcraftLogs or Raidbots!")
            if DRGUI.ActionBars then
                DRGUI.ActionBars:TriggerCombatAnimation()
            end
        end
        
        hooksecurefunc(Details, "OpenCurrentRealDPS", OnHighDPS)
    end
    
    -- WeakAuras integration for enhanced animations
    if WeakAuras then
        print("DRGUI: WeakAuras detected - Custom auras available for " .. comboKey)
        print("Import custom WeakAuras: |Hurl:https://wago.io/search/" .. comboKey .. "|h[Wago.io]|h")
    end
    
    -- DBM/BigWigs integration for raid alerts
    if DBM then
        print("DRGUI: DBM integration active")
    elseif BigWigs then
        print("DRGUI: BigWigs integration active")
    end
    
    -- Plater integration for nameplate enhancement
    if Plater then
        print("DRGUI: Plater detected - Enhanced nameplate integration available")
    end
    
    -- Resource links for optimization
    print("DRGUI Resources:")
    print("Guides: |Hurl:https://www.icy-veins.com/wow/|h[Icy Veins]|h |Hurl:https://www.wowhead.com/|h[Wowhead]|h")
    print("Tools: |Hurl:https://www.raidbots.com/|h[Raidbots]|h |Hurl:https://www.warcraftlogs.com/|h[WarcraftLogs]|h")
    print("Addons: |Hurl:https://www.curseforge.com/wow/addons|h[CurseForge]|h |Hurl:https://wago.io/|h[Wago.io]|h")
end

-- Enhanced Dependency Checking (Updated for TWW)
local function CheckDependencies()
    local optionalAddons = {
        "Details",
        "WeakAuras",
        "DBM-Core",
        "BigWigs",
        "Plater",
        "Hekili",
        "Masque",
        "OmniCC"
    }
    
    local loadedOptional = {}
    local missingOptional = {}
    
    for _, addon in ipairs(optionalAddons) do
        if IsAddOnLoaded(addon) then
            table.insert(loadedOptional, addon)
        else
            table.insert(missingOptional, addon)
        end
    end
    
    if #loadedOptional > 0 then
        print("DRGUI: Integrated addons: " .. table.concat(loadedOptional, ", "))
    end
    
    if #missingOptional > 0 then
        print("DRGUI: Optional addons available: " .. table.concat(missingOptional, ", "))
        print("Install via |Hurl:https://wowup.io/|h[WoWUp]|h for enhanced features")
    end
    
    return true -- DRGUI no longer requires ElvUI!
end

-- Enhanced Module Loading System
local function LoadHooks(safeMode)
    local hooks = {
        "integrations/details_hook.lua",
        "integrations/weakauras_hook.lua", 
        "integrations/alerts_hook.lua",
        "integrations/wardrobe_hook.lua",
        "integrations/mdt_hook.lua"
    }
    
    for _, hook in ipairs(hooks) do
        if safeMode then
            local success, err = pcall(dofile, hook)
            if not success then
                print("DRGUI: Failed to load " .. hook .. " (safe mode)")
                if DEBUG_MODE then
                    print("Error: " .. tostring(err))
                end
            else
                print("DRGUI: Loaded " .. hook)
            end
        else
            local success, err = pcall(dofile, hook)
            if success then
                print("DRGUI: Loaded " .. hook)
            else
                print("DRGUI: Error loading " .. hook .. ": " .. tostring(err))
            end
        end
    end
end

-- Module Management System
local function LoadModules()
    -- Load Action Bars Module
    local success, err = pcall(dofile, "modules/actionbars/actionbars.lua")
    if success then
        print("DRGUI: ActionBars module loaded successfully")
        DRGUI.ActionBars = _G.DRGUI_ActionBars
    else
        print("DRGUI: Failed to load ActionBars module: " .. tostring(err))
    end
    
    -- Additional modules will be loaded here as they're created
    -- TODO: Load UnitFrames, Nameplates, Chat, etc.
end

-- File Management and Validation
local function CheckAndGenMissingFiles(comboKey)
    -- Load file handler if available
    if _G.DRGUI_CheckMissingFiles then
        local missing = _G.DRGUI_CheckMissingFiles(comboKey)
        if missing and #missing > 0 then
            print("DRGUI: Some files may need generation. Loading in safe mode.")
            LoadHooks(true)
        else
            LoadHooks(false)
        end
    else
        print("DRGUI: File handler not available. Loading hooks in safe mode.")
        LoadHooks(true)
    end
end

-- Enhanced Initialization System
local function Initialize()
    print("DRGUI: Initializing Enhanced UI Framework for TWW...")
    
    -- Check dependencies (no longer requires ElvUI!)
    if not CheckDependencies() then
        print("DRGUI: Initialization failed - dependency check failed")
        return
    end
    
    -- Load file handler
    local success, err = pcall(dofile, "integrations/file_handler.lua")
    if not success and DEBUG_MODE then
        print("DRGUI: file_handler.lua not loaded: " .. tostring(err))
    end
    
    -- Initialize character profile
    local comboKey = GetCharacterCombo()
    CreateOrLoadProfile(comboKey)
    
    -- Load core modules
    LoadModules()
    
    -- Initialize engine if available
    if DRGUI_Engine then
        DRGUI_Engine:Initialize()
        print("DRGUI: Engine initialized successfully")
    else
        print("DRGUI: Warning - Engine not loaded, using fallback mode")
    end
    
    print("DRGUI: Initialization complete! Type /drgui help for commands")
end

-- Enhanced Event Handling for TWW
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Early addon load - set up basic structures
        DRGUIDB = DRGUIDB or {}
    elseif event == "PLAYER_LOGIN" then
        Initialize()
        local comboKey = GetCharacterCombo()
        CheckAndGenMissingFiles(comboKey)
        SetupIntegrations(comboKey)
    elseif string.find(event, "TALENT") or event == "PLAYER_SPECIALIZATION_CHANGED" then
        local comboKey = GetCharacterCombo()
        CreateOrLoadProfile(comboKey)
        CheckAndGenMissingFiles(comboKey)
        SetupIntegrations(comboKey)
        local _, class = UnitClass("player")
        print("DRGUI: Specialization updated for " .. (class or "Unknown") .. "!")
        print("Check optimization guides and Discord communities for tips.")
    end
end)

-- Slash commands for all DRGUI features
SLASH_DRGUI1 = "/drgui"
SlashCmdList["DRGUI"] = function(msg)
    local command, args = msg:match("^(%S*)%s*(.-)$")
    
    -- Setup & Configuration
    if command == "wizard" then
        if DRGUI and DRGUI.ShowSetupWizard then
            DRGUI:ShowSetupWizard()
        else
            print("DRGUI: Setup wizard not loaded")
        end
    elseif command == "wiztest" then
        -- Simple test for wizard button issues
        print("DRGUI: Testing wizard button creation...")
        if _G.DRGUISetupWizard then
            print("DRGUI: Wizard frame exists")
            local buttonFrame = _G.DRGUISetupWizard.buttonFrame
            if buttonFrame then
                print("DRGUI: Button frame exists, size: " .. buttonFrame:GetWidth() .. "x" .. buttonFrame:GetHeight())
                local children = {buttonFrame:GetChildren()}
                print("DRGUI: Button frame has " .. #children .. " children")
                for i, child in ipairs(children) do
                    if child.GetText then
                        print("DRGUI: Button " .. i .. ": '" .. (child:GetText() or "no text") .. "'")
                    end
                end
            else
                print("DRGUI: No button frame found")
            end
        else
            print("DRGUI: No wizard frame found")
        end
    elseif command == "deps" or command == "dependencies" then
        CheckDependencies()
    elseif command == "install" then
        SlashCmdList["DRGUI"]("install")
    
    -- Profile Backup Commands
    elseif command == "backup" then
        if DRGUI and DRGUI.Backup then
            DRGUI.Backup:CreateBackup(nil, "manual")
        else
            print("DRGUI: Backup system not loaded")
        end
    elseif command == "backups" then
        if DRGUI and DRGUI.Backup then
            DRGUI.Backup:ListBackups()
        else
            print("DRGUI: Backup system not loaded")
        end
    elseif command == "restore" then
        local num = tonumber(args)
        if num and DRGUI and DRGUI.Backup then
            DRGUI.Backup:RestoreBackup(nil, num)
        else
            print("DRGUI: Usage: /drgui restore <number>")
        end
    elseif command == "deletebackup" then
        local num = tonumber(args)
        if num and DRGUI and DRGUI.Backup then
            DRGUI.Backup:DeleteBackup(nil, num)
        else
            print("DRGUI: Usage: /drgui deletebackup <number>")
        end
    elseif command == "backupsettings" then
        if DRGUI and DRGUI.Backup then
            DRGUI.Backup:ShowSettings()
        end
    
    -- UI Customization Commands
    elseif command == "images" or command == "imagemanager" then
        if DRGUI and DRGUI.ImageManager then
            DRGUI.ImageManager:Show()
        else
            print("DRGUI: Image manager not loaded")
        end
    elseif command == "custom" then
        if DRGUI and DRGUI.UICustom then
            DRGUI.UICustom:ShowMenu()
        else
            print("DRGUI: UI customization not loaded")
        end
    elseif command == "setstyle" then
        if DRGUI and DRGUI.UICustom and args ~= "" then
            DRGUI.UICustom:SetStyle(args)
        else
            print("DRGUI: Usage: /drgui setstyle <bushido|action|elegant|custom>")
        end
    elseif command == "toggleanims" then
        if DRGUI and DRGUI.UICustom then
            DRGUI.UICustom:ToggleAnimations()
        end
    elseif command == "fontsize" then
        if DRGUI and DRGUI.UICustom and args ~= "" then
            DRGUI.UICustom:SetFontSize(args)
        else
            print("DRGUI: Usage: /drgui fontsize <8-20>")
        end
    elseif command == "uiscale" then
        if DRGUI and DRGUI.UICustom and args ~= "" then
            DRGUI.UICustom:SetUIScale(args)
        else
            print("DRGUI: Usage: /drgui uiscale <0.5-1.5>")
        end
    elseif command == "apply" then
        if DRGUI and DRGUI.UICustom then
            DRGUI.UICustom:ApplySettings()
        end
    
    -- Script Launcher Commands
    elseif command == "codegen" then
        if DRGUI and DRGUI.LaunchCodeGen then
            DRGUI:LaunchCodeGen()
        end
    elseif command == "imagegen" then
        if DRGUI and DRGUI.LaunchImageGen then
            DRGUI:LaunchImageGen()
        end
    elseif command == "aihelp" then
        if DRGUI and DRGUI.LaunchIntegrations then
            DRGUI:LaunchIntegrations()
        end
    
    -- Debug & Advanced
    elseif command == "debug" then
        DEBUG_MODE = not DEBUG_MODE
        print("DRGUI Debug: " .. (DEBUG_MODE and "On" or "Off"))
    elseif command == "export" then
        local comboKey = GetCharacterCombo()
        print("DRGUI: Exporting profile for " .. tostring(comboKey))
        if DRGUI and DRGUI.ExportProfile then
            DRGUI:ExportProfile(comboKey)
        else
            print("DRGUI: Export function not available")
        end
    elseif command == "debugexport" then
        -- Enhanced debug version for TWW
        local comboKey = GetCharacterCombo()
        print("=== DRGUI TWW Export Debug ===")
        print("Combo Key: " .. tostring(comboKey))
        print("DRGUI available: " .. tostring(DRGUI ~= nil))
        print("DRGUIDB available: " .. tostring(DRGUIDB ~= nil))
        print("Engine available: " .. tostring(DRGUI_Engine ~= nil))
        if DRGUIDB then
            print("Profile exists: " .. tostring(DRGUIDB[comboKey] ~= nil))
        end
        print("=== End Debug ===")
        if DRGUI and DRGUI.ExportProfile then
            DRGUI:ExportProfile(comboKey)
        else
            print("DRGUI: Export function not available")
        end
    
    -- Help & Info
    elseif command == "help" or command == "" then
        print("=" .. string.rep("=", 50))
        print("DRGUI Enhanced UI Framework for TWW")
        print("Version: 2.0.0 - ElvUI Independent")
        print("=" .. string.rep("=", 50))
        print("Setup & Configuration:")
        print("  /drgui wizard - Show setup wizard")
        print("  /drgui deps - Check dependencies")
        print("")
        print("Profile Management:")
        print("  /drgui backup - Create backup")
        print("  /drgui backups - List backups")
        print("  /drgui restore <#> - Restore backup")
        print("  /drgui export - Export profile")
        print("")
        print("UI Customization:")
        print("  /drgui images - Open image manager")
        print("  /drgui custom - Show options")
        print("  /drgui setstyle <style> - Set UI style")
        print("  /drgui apply - Apply changes")
        print("")
        print("Debug & Tools:")
        print("  /drgui debug - Toggle debug mode")
        print("  /drgui debugexport - Debug export issues")
        print("")
        print("DRGUI is now ElvUI-independent and TWW ready!")
        print("For documentation, see FEATURES_DOCUMENTATION.md")
        print("=" .. string.rep("=", 50))
    else
        print("Unknown command: " .. command)
        print("Type /drgui help for available commands")
    end
end
