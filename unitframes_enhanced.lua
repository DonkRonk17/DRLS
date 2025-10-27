-- DRGUI Enhanced Unit Frames System
-- ElvUI Complete Functionality + DRGUI Enhancements + TWW Optimization
-- PROTECTED VERSION with comprehensive loop guards

local addonName, addon = ...

-- CRITICAL: Only prevent loading if already in progress
if DRGUI_UnitFrames_Loading then
    return
end

-- Initialize DRGUI if not available
DRGUI = DRGUI or {}

-- LOOP PROTECTION FLAGS
DRGUI_UnitFrames_Loading = true
local UNIT_FRAMES_INITIALIZED = false
local EVENTS_REGISTERED = false
local FRAME_CREATION_IN_PROGRESS = false

-- Enhanced Unit Frames Module
DRGUI.UnitFrames = DRGUI.UnitFrames or {}
local UF = DRGUI.UnitFrames

-- Enhanced TWW Constants
local TWW_SPECS = {
    -- Death Knight
    [250] = {name = "Blood", role = "TANK", heroTalents = {"Deathbringer", "San'layn"}},
    [251] = {name = "Frost", role = "MELEE_DPS", heroTalents = {"Deathbringer", "Rider of the Apocalypse"}},
    [252] = {name = "Unholy", role = "MELEE_DPS", heroTalents = {"San'layn", "Rider of the Apocalypse"}},
    
    -- Demon Hunter  
    [577] = {name = "Havoc", role = "MELEE_DPS", heroTalents = {"Aldrachi Reaver", "Fel-scarred"}},
    [581] = {name = "Vengeance", role = "TANK", heroTalents = {"Aldrachi Reaver", "Fel-scarred"}},
    
    -- Druid
    [102] = {name = "Balance", role = "RANGED_DPS", heroTalents = {"Elune's Chosen", "Keeper of the Grove"}},
    [103] = {name = "Feral", role = "MELEE_DPS", heroTalents = {"Druid of the Claw", "Wildstalker"}},
    [104] = {name = "Guardian", role = "TANK", heroTalents = {"Druid of the Claw", "Elune's Chosen"}},
    [105] = {name = "Restoration", role = "HEALER", heroTalents = {"Keeper of the Grove", "Wildstalker"}},
    
    -- Enhanced for all classes with TWW Hero Talents
}

-- Frame Configuration with Enhanced Options
local FRAME_CONFIGS = {
    player = {
        enabled = true,
        width = 230,
        height = 55,
        point = "BOTTOMLEFT",
        relativeTo = "UIParent", 
        relativePoint = "BOTTOM",
        x = -413,
        y = 140,
        showPower = true,
        showCastBar = true,
        showPortrait = true,
        showClassIcon = true,
        showHeroTalents = true, -- DRGUI Enhancement
        showComboPoints = true,
        powerHeight = 11,
        castBarHeight = 18,
        enhancedTWWInfo = true -- DRGUI Enhancement
    },
    target = {
        enabled = true,
        width = 230,
        height = 55,
        point = "BOTTOMRIGHT",
        relativeTo = "UIParent",
        relativePoint = "BOTTOM", 
        x = 413,
        y = 140,
        showPower = true,
        showCastBar = true,
        showPortrait = true,
        showClassIcon = true,
        showThreatInfo = true, -- DRGUI Enhancement
        showDebuffs = true,
        showBuffs = false,
        powerHeight = 11, -- Added missing powerHeight
        castBarHeight = 18, -- Added missing castBarHeight
        enhancedTargetInfo = true -- DRGUI Enhancement
    },
    targettarget = {
        enabled = true,
        width = 130,
        height = 36,
        point = "BOTTOMRIGHT",
        relativeTo = "DRGUI_TargetFrame",
        relativePoint = "BOTTOMLEFT",
        x = -3,
        y = 0,
        showPower = false
    },
    party = {
        enabled = true,
        width = 138,
        height = 46,
        point = "TOPLEFT",
        relativeTo = "UIParent",
        relativePoint = "TOPLEFT",
        x = 15,
        y = -260,
        orientation = "VERTICAL",
        spacing = 5,
        showRoleIcons = true, -- DRGUI Enhancement
        showHeroTalentIcons = true, -- DRGUI Enhancement
        enhancedPartyInfo = true -- DRGUI Enhancement
    },
    raid = {
        enabled = true,
        width = 92,
        height = 42, 
        point = "TOPLEFT",
        relativeTo = "UIParent",
        relativePoint = "TOPLEFT",
        x = 15,
        y = -260,
        numGroups = 8,
        groupsPerRowCol = 1,
        orientation = "VERTICAL",
        showRoleIcons = true, -- DRGUI Enhancement
        raidHealthFormat = "PERCENT", -- DRGUI Enhancement
        enhancedRaidInfo = true -- DRGUI Enhancement
    }
}

-- Enhanced Power Colors for TWW
local POWER_COLORS = {
    MANA = {0.31, 0.45, 0.63},
    RAGE = {0.69, 0.31, 0.31},
    FOCUS = {0.71, 0.43, 0.27},
    ENERGY = {0.65, 0.63, 0.35},
    RUNIC_POWER = {0.00, 0.82, 1.00},
    SOUL_SHARDS = {0.50, 0.32, 0.55},
    LUNAR_POWER = {0.30, 0.52, 0.90},
    HOLY_POWER = {0.95, 0.90, 0.60},
    MAELSTROM = {0.00, 0.50, 1.00},
    CHI = {0.71, 1.00, 0.92},
    INSANITY = {0.40, 0.00, 0.80},
    ARCANE_CHARGES = {0.41, 0.8, 0.94},
    FURY = {0.788, 0.259, 0.992},
    PAIN = {0.90, 0.80, 0.50},
    -- TWW Enhancement: Hero Talent Power
    HERO_POWER = {1.00, 0.82, 0.00} -- DRGUI Enhancement
}

-- Frame Creation and Management
UF.frames = {}
UF.events = {}

-- PROTECTED: Create Unit Frame with comprehensive safety
local function CreateUnitFrame(unit, config)
    -- LOOP GUARD
    if FRAME_CREATION_IN_PROGRESS then
        print("DRGUI UnitFrames: Frame creation already in progress, skipping " .. unit)
        return nil
    end
    
    if UF.frames[unit] then
        print("DRGUI UnitFrames: Frame for " .. unit .. " already exists")
        return UF.frames[unit]
    end
    
    FRAME_CREATION_IN_PROGRESS = true
    
    local success, frame = pcall(function()
        local frameName = "DRGUI_" .. unit:gsub("^%l", string.upper) .. "Frame"
        local frame = CreateFrame("Frame", frameName, UIParent, "SecureUnitButtonTemplate")
        
        if not frame then
            error("Failed to create frame for " .. unit)
        end
        
        -- Basic frame setup
        frame:SetSize(config.width, config.height)
        frame:SetPoint(config.point, config.relativeTo or UIParent, config.relativePoint or config.point, config.x or 0, config.y or 0)
        frame:SetAttribute("unit", unit)
        
        -- Enhanced background with DRGUI styling
        frame.bg = frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetAllPoints()
        frame.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        
        -- Enhanced border
        frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.border:SetAllPoints()
        frame.border:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        frame.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        
        -- Health Bar with enhanced TWW styling
        frame.health = CreateFrame("StatusBar", nil, frame)
        frame.health:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        frame.health:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, config.showPower and (config.powerHeight + 2) or 1)
        frame.health:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        frame.health:SetStatusBarColor(0.2, 0.8, 0.2, 1)
        
        -- Enhanced health text with TWW formatting
        frame.health.text = frame.health:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.health.text:SetPoint("CENTER", frame.health, "CENTER", 0, 0)
        frame.health.text:SetTextColor(1, 1, 1, 1)
        
        -- Power Bar (if enabled)
        if config.showPower then
            frame.power = CreateFrame("StatusBar", nil, frame)
            frame.power:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
            frame.power:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
            frame.power:SetHeight(config.powerHeight)
            frame.power:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            
            -- Enhanced power text
            frame.power.text = frame.power:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.power.text:SetPoint("CENTER", frame.power, "CENTER", 0, 0)
            frame.power.text:SetTextColor(1, 1, 1, 1)
        end
        
        -- Name text with enhanced formatting
        frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.name:SetPoint("TOPLEFT", frame.health, "TOPLEFT", 3, -3)
        frame.name:SetPoint("TOPRIGHT", frame.health, "TOPRIGHT", -3, -3)
        frame.name:SetJustifyH("LEFT")
        frame.name:SetTextColor(1, 1, 1, 1)
        
        -- DRGUI Enhancement: Hero Talent Display
        if config.showHeroTalents then
            frame.heroTalent = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.heroTalent:SetPoint("TOPRIGHT", frame.health, "TOPRIGHT", -3, -3)
            frame.heroTalent:SetJustifyH("RIGHT")
            frame.heroTalent:SetTextColor(1, 0.82, 0, 1) -- Gold color for hero talents
        end
        
        -- Enhanced Portrait (if enabled) - ROBUST VERSION
        if config.showPortrait then
            frame.portrait = CreateFrame("PlayerModel", nil, frame)
            frame.portrait:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
            frame.portrait:SetSize(config.height - 4, config.height - 4)
            frame.portrait:SetModelScale(4.25)
            frame.portrait:SetPosition(0, 0, 0.5)
            
            -- Portrait stability tracking
            frame.portrait.lastUpdate = 0
            frame.portrait.updateInterval = 1.0 -- Update every second
            frame.portrait.failureCount = 0
            frame.portrait.maxFailures = 3
            
            -- Enhanced portrait validation function
            frame.portrait.ValidateModel = function(self)
                if not self:GetModel() or self:GetModel() == "" then
                    return false
                end
                return true
            end
            
            -- Portrait refresh function with error handling
            frame.portrait.RefreshModel = function(self, unit)
                local success = pcall(function()
                    self:SetUnit(unit)
                    self:SetCamera(0)
                    
                    -- Additional model stability settings
                    if unit == "player" then
                        self:SetModelScale(4.25)
                        self:SetPosition(0, 0, 0.5)
                        -- Force model reload for player
                        C_Timer.After(0.1, function()
                            if self:IsShown() then
                                self:RefreshUnit()
                            end
                        end)
                    end
                end)
                
                if not success then
                    self.failureCount = (self.failureCount or 0) + 1
                    if self.failureCount < self.maxFailures then
                        -- Retry after a short delay
                        C_Timer.After(2.0, function()
                            self:RefreshModel(unit)
                        end)
                    end
                end
                
                return success
            end
            
            -- Set up automatic portrait monitoring
            frame.portrait:SetScript("OnUpdate", function(self, elapsed)
                self.lastUpdate = (self.lastUpdate or 0) + elapsed
                if self.lastUpdate >= self.updateInterval then
                    self.lastUpdate = 0
                    
                    -- Check if model is still valid
                    if not self:ValidateModel() and UnitExists(unit) then
                        -- Model disappeared, attempt to restore it
                        self:RefreshModel(unit)
                    end
                end
            end)
            
            -- Initial model setup
            frame.portrait:RefreshModel(unit)
        end
        
        -- Store frame reference
        frame.unit = unit
        frame.config = config
        
        return frame
    end)
    
    FRAME_CREATION_IN_PROGRESS = false
    
    if not success then
        print("DRGUI UnitFrames ERROR: Failed to create " .. unit .. " frame: " .. tostring(frame))
        return nil
    end
    
    UF.frames[unit] = frame
    print("DRGUI UnitFrames: Created " .. unit .. " frame successfully")
    return frame
end

-- PROTECTED: Update Unit Frame with enhanced TWW information
local function UpdateUnitFrame(frame)
    if not frame or not frame.unit then return end
    
    local unit = frame.unit
    
    -- SAFE: Update with error protection
    local success, err = pcall(function()
        if not UnitExists(unit) then
            frame:Hide()
            return
        end
        
        frame:Show()
        
        -- Enhanced Health Update
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        local healthPercent = maxHealth > 0 and (health / maxHealth) or 0
        
        frame.health:SetMinMaxValues(0, maxHealth)
        frame.health:SetValue(health)
        
        -- Enhanced health formatting
        if maxHealth > 999999 then
            frame.health.text:SetText(string.format("%.1fM", health / 1000000))
        elseif maxHealth > 999 then
            frame.health.text:SetText(string.format("%.1fK", health / 1000))
        else
            frame.health.text:SetText(health)
        end
        
        -- Enhanced health color based on percentage
        if healthPercent > 0.8 then
            frame.health:SetStatusBarColor(0.2, 0.8, 0.2, 1) -- Green
        elseif healthPercent > 0.5 then
            frame.health:SetStatusBarColor(0.8, 0.8, 0.2, 1) -- Yellow
        elseif healthPercent > 0.2 then
            frame.health:SetStatusBarColor(0.8, 0.4, 0.2, 1) -- Orange
        else
            frame.health:SetStatusBarColor(0.8, 0.2, 0.2, 1) -- Red
        end
        
        -- Enhanced Power Update
        if frame.power then
            local power = UnitPower(unit)
            local maxPower = UnitPowerMax(unit)
            local powerType = UnitPowerType(unit)
            
            frame.power:SetMinMaxValues(0, maxPower)
            frame.power:SetValue(power)
            
            -- Enhanced power color
            local powerName = PowerBarColor[powerType] and PowerBarColor[powerType].code or "MANA"
            local color = POWER_COLORS[powerName] or POWER_COLORS.MANA
            frame.power:SetStatusBarColor(color[1], color[2], color[3], 1)
            
            -- Enhanced power text
            if maxPower > 0 then
                frame.power.text:SetText(power .. "/" .. maxPower)
            else
                frame.power.text:SetText("")
            end
        end
        
        -- Enhanced Name Update
        local name = UnitName(unit)
        if name then
            frame.name:SetText(name)
        end
        
        -- DRGUI Enhancement: Hero Talent Information
        if frame.heroTalent and unit == "player" then
            local specIndex = GetSpecialization()
            if specIndex then
                local _, specName, _, _, _, specID = GetSpecializationInfo(specIndex)
                local heroID = C_ClassTalents.GetActiveHeroTalentSpec()
                
                if heroID and TWW_SPECS[specID] then
                    local heroName = TWW_SPECS[specID].heroTalents and TWW_SPECS[specID].heroTalents[1] or "Hero"
                    frame.heroTalent:SetText(heroName)
                    frame.heroTalent:Show()
                else
                    frame.heroTalent:Hide()
                end
            end
        end
        
        -- Enhanced Portrait Update - ROBUST VERSION
        if frame.portrait then
            -- Enhanced portrait update with validation
            local success = pcall(function()
                -- Validate that the portrait model is still working
                if not frame.portrait:GetModel() or frame.portrait:GetModel() == "" then
                    -- Model disappeared - force refresh
                    frame.portrait:SetUnit(unit)
                    frame.portrait:SetCamera(0)
                    
                    -- Additional refresh for player frame stability
                    if unit == "player" then
                        frame.portrait:SetModelScale(4.25)
                        frame.portrait:SetPosition(0, 0, 0.5)
                        -- Force refresh with delay to ensure model loads
                        if _G.C_Timer and _G.C_Timer.After then
                            _G.C_Timer.After(0.1, function()
                                if frame.portrait and frame.portrait:IsShown() then
                                    frame.portrait:RefreshUnit()
                                end
                            end)
                        end
                    end
                else
                    -- Normal update for working portrait
                    frame.portrait:SetUnit(unit)
                    frame.portrait:SetCamera(0)
                end
            end)
            
            if not success then
                -- Portrait update failed, try to recreate it
                if FRAME_CONFIGS[unit] and FRAME_CONFIGS[unit].showPortrait then
                    frame.portrait:SetUnit(unit)
                end
            end
        end
    end)
    
    if not success then
        print("DRGUI UnitFrames: Update error for " .. unit .. ": " .. tostring(err))
    end
end

-- PROTECTED: Event Handler with throttling
local function OnUnitFrameEvent(self, event, ...)
    if not UF.frames then return end
    
    local arg1 = ...
    
    -- Event throttling to prevent spam
    local now = GetTime()
    if UF.lastEventTime and (now - UF.lastEventTime) < 0.05 then
        return -- Throttle to 20 FPS max
    end
    UF.lastEventTime = now
    
    -- Update relevant frames based on event
    if event == "UNIT_HEALTH" then
        local frame = UF.frames[arg1]
        if frame then
            UpdateUnitFrame(frame)
        end
    elseif event == "UNIT_POWER_UPDATE" then
        local frame = UF.frames[arg1]
        if frame then
            UpdateUnitFrame(frame)
        end
    elseif event == "UNIT_NAME_UPDATE" then
        local frame = UF.frames[arg1]
        if frame then
            UpdateUnitFrame(frame)
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UF.frames.target then
            UpdateUnitFrame(UF.frames.target)
        end
        if UF.frames.targettarget then
            UpdateUnitFrame(UF.frames.targettarget)
        end
    elseif event == "PLAYER_TALENT_UPDATE" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        -- DRGUI Enhancement: Update hero talent info
        if UF.frames.player then
            UpdateUnitFrame(UF.frames.player)
        end
    end
end

-- PROTECTED: Initialize Unit Frames System
function UF:Initialize()
    -- CRITICAL LOOP GUARD
    if UNIT_FRAMES_INITIALIZED then
        print("DRGUI UnitFrames: Already initialized, skipping...")
        return
    end
    UNIT_FRAMES_INITIALIZED = true
    
    print("DRGUI UnitFrames: Initializing Enhanced Unit Frames System...")
    
    -- Get profile configuration
    local profile = DRGUI.db or {}
    local unitframes = profile.unitframes or {}
    
    -- Merge with defaults
    for unit, defaultConfig in pairs(FRAME_CONFIGS) do
        local config = unitframes[unit] or {}
        for key, value in pairs(defaultConfig) do
            if config[key] == nil then
                config[key] = value
            end
        end
        FRAME_CONFIGS[unit] = config
    end
    
    -- Create frames for enabled units
    for unit, config in pairs(FRAME_CONFIGS) do
        if config.enabled then
            local frame = CreateUnitFrame(unit, config)
            if frame then
                print("DRGUI UnitFrames: " .. unit .. " frame created and configured")
            end
        end
    end
    
    -- Register events safely
    if not EVENTS_REGISTERED then
        local eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("UNIT_HEALTH")
        eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
        eventFrame:RegisterEvent("UNIT_NAME_UPDATE")
        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
        eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        eventFrame:SetScript("OnEvent", OnUnitFrameEvent)
        
        UF.eventFrame = eventFrame
        EVENTS_REGISTERED = true
        print("DRGUI UnitFrames: Events registered successfully")
    end
    
    -- Set up portrait monitoring system
    if not UF.portraitMonitor then
        UF.portraitMonitor = CreateFrame("Frame")
        UF.portraitMonitor.elapsed = 0
        UF.portraitMonitor.checkInterval = 5.0 -- Check every 5 seconds
        
        UF.portraitMonitor:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= self.checkInterval then
                self.elapsed = 0
                
                -- Check player portrait specifically
                if UF.frames and UF.frames.player and UF.frames.player.portrait then
                    local portrait = UF.frames.player.portrait
                    if portrait:IsShown() and (not portrait:GetModel() or portrait:GetModel() == "") then
                        -- Portrait disappeared, restore it
                        print("DRGUI: Portrait disappeared, restoring...")
                        portrait:SetUnit("player")
                        portrait:SetCamera(0)
                        portrait:SetModelScale(4.25)
                        portrait:SetPosition(0, 0, 0.5)
                    end
                end
            end
        end)
        
        print("DRGUI UnitFrames: Portrait monitoring system active")
    end
    
    -- Initial update of all frames
    for unit, frame in pairs(UF.frames) do
        UpdateUnitFrame(frame)
    end
    
    print("DRGUI UnitFrames: Enhanced Unit Frames initialization complete!")
    print("Features: ElvUI parity + Hero Talents + TWW optimization + Enhanced styling")
end

-- PROTECTED: Cleanup function
function UF:Cleanup()
    if UF.eventFrame then
        UF.eventFrame:UnregisterAllEvents()
        UF.eventFrame:SetScript("OnEvent", nil)
        UF.eventFrame = nil
        EVENTS_REGISTERED = false
    end
    
    for unit, frame in pairs(UF.frames or {}) do
        if frame then
            frame:Hide()
            frame:SetParent(nil)
        end
    end
    
    UF.frames = {}
    UNIT_FRAMES_INITIALIZED = false
    print("DRGUI UnitFrames: Cleanup complete")
end

-- Auto-initialize when ready (will be called by DRGUI-ENHANCED.lua)
-- Don't auto-initialize here to prevent timing issues

-- Clear loading flag
DRGUI_UnitFrames_Loading = false

print("DRGUI Enhanced Unit Frames: Module loaded successfully!")
print("DRGUI Enhanced Unit Frames: Waiting for initialization call...")