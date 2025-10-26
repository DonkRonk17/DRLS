local addonName, addon = ...
local E, L, V, P, G = unpack(ElvUI)

DRGUIDB = DRGUIDB or {}
local DEBUG_MODE = true  -- Toggle for testing

local function GetCharacterCombo()
    local race = UnitRace("player")
    local _, class = UnitClass("player")
    local specIndex = GetSpecialization()
    local _, specName, _, _, _, specID = GetSpecializationInfo(specIndex)
    local heroID = C_ClassTalents.GetActiveHeroTalentSpec() or "None"  -- Returns SubTreeID (nil pre-71)
    
    -- Hash into key (e.g., "Human-Mage-Frost-1234" for Sunfury ID)
    local comboKey = race .. "-" .. class .. "-" .. specName .. "-" .. heroID
    
    print("DRGUI Combo Detected: " .. comboKey .. " - Copy for image/code gen prompt!")
    return comboKey
end

local function CreateOrLoadProfile(comboKey)
    if not DRGUIDB[comboKey] then
        -- Copy ElvUI defaults and customize (minimalistic Bushido)
        DRGUIDB[comboKey] = CopyTable(P)  -- From Profile.lua
        DRGUIDB[comboKey].general.font = "Expressway"  -- Cartoony font
        DRGUIDB[comboKey].actionbar.bar1.visibility = "[petbattle] hide; show"  -- Action-packed bars
        
        -- Example customization: Hero-themed border (extend StyleFilters)
        local filter = CopyTable(E.StyleFilterDefaults)
        filter.actions.texture.texture = "media/borders/" .. comboKey .. "_border.tga"  -- Custom media
        E.global.nameplates.filters[comboKey] = filter  -- Save filter
        
        print("DRGUI: New profile created for " .. comboKey .. "! Paste Grok narration for epic install. Optimize on Icy Veins: |Hurl:https://www.icy-veins.com/wow/" .. string.lower(class) .. "-" .. string.lower(specName) .. "-pve-guide|h[Guide]|h")
    else
        -- Load existing (extend ElvUI)
        E.db = CopyTable(DRGUIDB[comboKey])  -- Apply to current session
        print("DRGUI: Loaded profile for " .. comboKey .. ". Ready for action! Check Raider.IO: |Hurl:https://raider.io/|h[Ranks]|h")
    end
    
    -- Hook ElvUI modules (e.g., for animations)
    hooksecurefunc(E:GetModule('ActionBars'), 'UpdateBar', function(self, bar)
        -- Add Bushido flair (integrate with ActionButtonAnimation.lua later)
        bar:SetAlpha(0.9)  -- Example tweak
    end)
end

local function SetupIntegrations(comboKey)
    -- Hook Details! for stats (lean heavy: embed timeline)
    if Details then
        hooksecurefunc(Details, "OpenCurrentRealDPS", function()
            -- Pulse UI on high DPS (e.g., glow border)
            local frame = _G["DRGUI_AI_Panel"]
            frame:SetBackdropColor(1, 0.2, 0.2, 0.9)  -- Action-packed red
            print("DRGUI: High DPS detected! Upload to WarcraftLogs: |Hurl:https://www.warcraftlogs.com/|h[Logs]|h or sim on Raidbots: |Hurl:https://www.raidbots.com/simbot|h[Simbot]|h")
        end)
    end
    
    -- WeakAuras for animations (proc glows)
    if WeakAuras then
        -- Example: Load custom WA for combo (import from Wago.io via hyperlink)
        print("DRGUI: Import WeakAuras for " .. comboKey .. ": |Hurl:https://wago.io/search/" .. comboKey .. "|h[Wago.io]|h")
    end
    
    -- Masque for skins (icons/borders)
    if Masque then
        local group = Masque:Group("DRGUI", "ActionBars")
        group:AddButton(ElvUI_Bar1Button1)  -- Example skin
        group:SetSkin("Bushido")  -- Cartoony
    end
    
    -- Hyperlink sites (Icy Veins, etc.)
    print("Resources: |Hurl:https://www.icy-veins.com/wow/|h[Icy Veins]|h |Hurl:https://www.wowhead.com/|h[Wowhead]|h |Hurl:https://www.mmo-champion.com/|h[MMO-Champion]|h |Hurl:https://wowpedia.fandom.com/wiki/Wowpedia|h[Warcraft Wiki]|h |Hurl:https://blizzardwatch.com/|h[Blizzard Watch]|h")
    print("Community: |Hurl:https://www.reddit.com/r/wow/|h[/r/wow]|h |Hurl:https://www.reddit.com/r/wownoob/|h[/r/wownoob]|h |Hurl:https://us.forums.blizzard.com/en/wow/|h[Blizzard Forums]|h")
    print("Tools: |Hurl:https://www.curseforge.com/wow/addons|h[CurseForge]|h |Hurl:https://www.wowinterface.com/|h[WoWInterface]|h |Hurl:https://wago.io/|h[Wago.io]|h |Hurl:https://wowup.io/|h[WoWUp.io]|h")
    print("Economy/Pets: |Hurl:https://theunderminejournal.com/|h[Undermine Exchange]|h |Hurl:https://saddlebage.exchange/|h[Saddlebag Exchange]|h |Hurl:https://www.warcraftpets.com/|h[WarcraftPets]|h")
    print("YouTube: |Hurl:https://www.youtube.com/results?search_query=world+of+warcraft+ui+setup+2025|h[Tutorials/Streams]|h")
    
    -- Call external Python for AI tips (user runs manually)
    print("Run drgui_integrations.py for Grok tips on " .. comboKey)
end

local function CheckDependencies()
    local requiredAddons = {
        "ElvUI",
        "Details",
        "WeakAuras"
    }
    
    local optionalAddons = {
        "DBM-Core",
        "Masque",
        "Bartender4",
        "Plater",
        "Hekili",
        "GuildRosterManager"
    }
    
    local missingRequired = {}
    local missingOptional = {}
    
    for _, addon in ipairs(requiredAddons) do
        if not IsAddOnLoaded(addon) then
            table.insert(missingRequired, addon)
        end
    end
    
    for _, addon in ipairs(optionalAddons) do
        if not IsAddOnLoaded(addon) then
            table.insert(missingOptional, addon)
        end
    end
    
    if #missingRequired > 0 then
        print("DRGUI ERROR: Missing required addons: " .. table.concat(missingRequired, ", "))
        print("=" .. string.rep("=", 50))
        print("AUTO-INSTALLER AVAILABLE!")
        print("=" .. string.rep("=", 50))
        print("Option 1 (RECOMMENDED): Run the auto-installer:")
        print("  1. Close World of Warcraft")
        print("  2. Open Command Prompt or PowerShell")
        print("  3. Navigate to DRGUI folder:")
        print("     cd \"" .. "C:\\Program Files (x86)\\Battle.net\\World of Warcraft\\_retail_\\Interface\\AddOns\\DRGUI_BK" .. "\"")
        print("  4. Run: python scripts/drgui_dependency_installer.py --required-only")
        print("  5. Restart WoW and enable the installed addons")
        print("")
        print("Option 2: Manual download from:")
        print("  |Hurl:https://www.curseforge.com/wow/addons|h[CurseForge]|h or |Hurl:https://www.wowinterface.com/|h[WoWInterface]|h")
        print("")
        print("Option 3: Use |Hurl:https://wowup.io/|h[WoWUp.io]|h for easy addon management!")
        print("=" .. string.rep("=", 50))
        return false
    end
    
    if #missingOptional > 0 then
        print("DRGUI: Optional addons not loaded: " .. table.concat(missingOptional, ", "))
        print("Some features may be limited. Install for full experience.")
    end
    
    return true
end

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
            -- Safe mode: use pcall to catch errors
            local success, err = pcall(dofile, hook)
            if not success then
                print("DRGUI: Failed to load " .. hook .. " (continuing in safe mode)")
                if DEBUG_MODE then
                    print("Error: " .. tostring(err))
                end
            end
        else
            -- Normal mode: load directly
            dofile(hook)
        end
    end
end

local function CheckAndGenMissingFiles(comboKey)
    -- Use the file_handler checker
    if _G.DRGUI_CheckMissingFiles then
        local missing = _G.DRGUI_CheckMissingFiles(comboKey)
        if missing and #missing > 0 then
            print("DRGUI: File generation needed. Run Python scripts or borrow from existing addons.")
            -- Still try to load existing hooks with error handling
            LoadHooks(true)  -- true = safe mode
        else
            LoadHooks(false)  -- false = normal mode
        end
    else
        print("DRGUI: file_handler.lua not loaded. Loading hooks in safe mode.")
        LoadHooks(true)
    end
end

-- Initialize on startup
local function Initialize()
    -- Check dependencies first
    if not CheckDependencies() then
        print("DRGUI: Cannot initialize without required addons!")
        return
    end
    
    -- Load file handler
    local success, err = pcall(dofile, "integrations/file_handler.lua")
    if not success then
        print("DRGUI: Warning - file_handler.lua failed to load: " .. tostring(err))
    end
    
    -- Check for existing profile
    local comboKey = GetCharacterCombo()
    if not DRGUIDB[comboKey] then
        print("DRGUI: No profile found for current combo! Creating new profile...")
        CreateOrLoadProfile(comboKey)
    else
        print("DRGUI: Profile loaded successfully! Use /drgui to customize further.")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        Initialize()
        local comboKey = GetCharacterCombo()
        CheckAndGenMissingFiles(comboKey)
        SetupIntegrations(comboKey)
    elseif strfind(event, "TALENT") or event == "SPECIALIZATION_CHANGED" then
        local comboKey = GetCharacterCombo()
        CreateOrLoadProfile(comboKey)
        CheckAndGenMissingFiles(comboKey)
        SetupIntegrations(comboKey)
        local _, class = UnitClass("player")
        print("DRGUI Update: Combo changed! Join Class Discord: |Hurl:https://www.wowhead.com/discord-servers|h[Discords]|h or watch YouTube stream: |Hurl:https://www.youtube.com/results?search_query=wow+" .. string.lower(class) .. "+guide+2025|h[Streams]|h")
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
        ExportProfile(comboKey)
    
    -- Help & Info
    elseif command == "help" or command == "" then
        print("=" .. string.rep("=", 50))
        print("DRGUI Commands:")
        print("=" .. string.rep("=", 50))
        print("Setup & Configuration:")
        print("  /drgui wizard - Show setup wizard")
        print("  /drgui deps - Check dependencies")
        print("  /drgui install - Auto-installer instructions")
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
        print("  /drgui toggleanims - Toggle animations")
        print("  /drgui fontsize <size> - Set font size")
        print("  /drgui uiscale <scale> - Set UI scale")
        print("  /drgui apply - Apply changes")
        print("")
        print("Scripts & Tools:")
        print("  /drgui codegen - Code generator")
        print("  /drgui imagegen - Image generator")
        print("  /drgui aihelp - AI integration")
        print("")
        print("For detailed documentation, see FEATURES_DOCUMENTATION.md")
        print("=" .. string.rep("=", 50))
    else
        print("Unknown command: " .. command)
        print("Type /drgui help for available commands")
    end
end
