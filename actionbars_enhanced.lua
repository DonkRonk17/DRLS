-- actionbars_enhanced.lua - Phase 3A.1: Enhanced Bartender4 Integration Layer
-- DRGUI Enhanced Action Bars System
-- Version: 2.0.0-enhanced-phase3a
-- Following proven Phase 1 & 2 methodology for safe, comprehensive integration

-- Namespace protection
if not DRGUI then
    DRGUI = {}
end

-- Prevent double loading
if DRGUI_ActionBars_Loading then
    return
end
DRGUI_ActionBars_Loading = true

-- ============================================================================
-- CORE ACTIONBARS MODULE
-- ============================================================================

-- Safe API wrappers
local function SafeGetTime()
    return (_G.GetTime and _G.GetTime()) or 0
end

DRGUI.ActionBars = DRGUI.ActionBars or {}
local AB = DRGUI.ActionBars

-- Module state tracking
AB.isInitialized = false
AB.bartenderDetected = false
AB.integrationLevel = "none" -- none, basic, full
AB.actionBars = {}
AB.enhancedFeatures = {}
AB.events = {}

-- Protection flags
local LOOP_PROTECTION = {}
local MAX_RETRIES = 3
local RETRY_DELAY = 0.5

-- ============================================================================
-- BARTENDER4 DETECTION & INTEGRATION
-- ============================================================================

local function DetectBartender4()
    -- Comprehensive Bartender4 detection with multiple methods
    local detection = {
        addon_loaded = false,
        core_available = false,
        bars_available = false,
        version = nil,
        api_level = "none",
        detection_method = "none"
    }
    
    -- Method 1: Check _G.Bartender4 first (most reliable)
    if _G.Bartender4 then
        detection.addon_loaded = true
        detection.core_available = true
        detection.detection_method = "_G.Bartender4"
        
        -- Get version if available
        if _G.Bartender4.GetVersion then
            local versionSuccess, version = pcall(_G.Bartender4.GetVersion, _G.Bartender4)
            if versionSuccess then
                detection.version = version
            end
        end
        
        -- Check for bar manager
        if _G.Bartender4.BarManager then
            detection.bars_available = true
            detection.api_level = "full"
        elseif _G.Bartender4.bars then
            detection.bars_available = true
            detection.api_level = "basic"
        else
            detection.api_level = "limited"
        end
        
        return detection
    end
    
    -- Method 2: Try IsAddOnLoaded if available
    local success, isLoaded = pcall(function()
        return _G.IsAddOnLoaded and _G.IsAddOnLoaded("Bartender4")
    end)
    
    if success and isLoaded then
        detection.addon_loaded = true
        detection.detection_method = "IsAddOnLoaded"
        -- But we still need to wait for _G.Bartender4 to be available
        detection.api_level = "pending"
        return detection
    end
    
    -- Method 3: Check addon metadata as last resort
    local getNumAddOns = _G.GetNumAddOns
    local getAddOnMetadata = _G.GetAddOnMetadata
    local isAddOnLoaded = _G.IsAddOnLoaded
    
    if getNumAddOns and getAddOnMetadata and isAddOnLoaded then
        local enumSuccess, addonCount = pcall(getNumAddOns)
        if enumSuccess and addonCount then
            for i = 1, addonCount do
                local nameSuccess, name = pcall(getAddOnMetadata, i, "Title")
                if nameSuccess and name and name:find("Bartender") then
                    local loadedSuccess, loaded = pcall(isAddOnLoaded, i)
                    if loadedSuccess and loaded then
                        detection.addon_loaded = true
                        detection.detection_method = "metadata_scan"
                        detection.api_level = "pending"
                        return detection
                    end
                end
            end
        end
    end
    
    detection.detection_method = "not_found"
    return detection
end

local function InitializeBartenderIntegration()
    if AB.bartenderDetected then
        return true -- Already initialized
    end
    
    local detection = DetectBartender4()
    
    if not detection.addon_loaded then
        print("DRGUI ActionBars: Bartender4 not detected - will use fallback mode")
        AB.integrationLevel = "none"
        return false
    end
    
    print("DRGUI ActionBars: Bartender4 detected! Version: " .. (detection.version or "Unknown"))
    
    AB.bartenderDetected = true
    AB.bartenderInfo = detection
    
    if detection.api_level == "full" then
        AB.integrationLevel = "full"
        print("DRGUI ActionBars: Full Bartender4 integration available")
    elseif detection.api_level == "basic" then
        AB.integrationLevel = "basic"
        print("DRGUI ActionBars: Basic Bartender4 integration available")
    else
        AB.integrationLevel = "limited"
        print("DRGUI ActionBars: Limited Bartender4 integration - core features only")
    end
    
    return true
end

-- ============================================================================
-- ENHANCED ACTIONBAR MANAGEMENT
-- ============================================================================

local function EnhanceActionBar(barId, barObject)
    if not barId or not barObject then
        return false
    end
    
    -- Protection against multiple enhancements
    if AB.actionBars[barId] and AB.actionBars[barId].enhanced then
        return true
    end
    local getTime = SafeGetTime
    
    local enhanced = {
        id = barId,
        original = barObject,
        enhanced = true,
        drgui_features = {},
        created = getTime()
    }
    
    -- Add DRGUI-specific enhancements
    local success, err = pcall(function()
        -- Enhanced visibility management
        enhanced.drgui_features.visibility = {
            combat_alpha = 1.0,
            ooc_alpha = 0.8,
            auto_fade = false,
            smart_show = true
        }
        
        -- Enhanced button management
        enhanced.drgui_features.buttons = {
            enhanced_tooltips = true,
            proc_highlighting = true,
            cooldown_enhancements = true,
            keybind_display = true
        }
        
        -- TWW-specific features
        enhanced.drgui_features.tww = {
            hero_talent_support = true,
            new_ability_highlighting = true,
            dynamic_layout = false
        }
        
        -- Combat state tracking
        enhanced.drgui_features.combat = {
            in_combat = false,
            last_state_change = SafeGetTime(),
            auto_adjustments = true
        }
    end)
    
    if not success then
        print("DRGUI ActionBars: Warning - Failed to enhance bar " .. barId .. ": " .. tostring(err))
        return false
    end
    
    AB.actionBars[barId] = enhanced
    return true
end

local function UpdateActionBars()
    if not AB.bartenderDetected or AB.integrationLevel == "none" then
        return
    end
    
    -- Throttling protection
    local now = SafeGetTime()
    if AB.lastUpdate and (now - AB.lastUpdate) < 0.1 then
        return
    end
    AB.lastUpdate = now
    
    local updated = 0
    
    -- Update based on integration level
    if AB.integrationLevel == "full" and _G.Bartender4.BarManager then
        -- Full integration - access all bars
        local success, err = pcall(function()
            for i = 1, 10 do -- Bartender4 supports up to 10 bars
                local bar = _G.Bartender4.BarManager:GetBar("ActionBarAnchor" .. i)
                if bar then
                    if EnhanceActionBar("bar" .. i, bar) then
                        updated = updated + 1
                    end
                end
            end
            
            -- Special bars
            local specialBars = {"PetBar", "StanceBar", "BagBar", "MicroMenu"}
            for _, barType in ipairs(specialBars) do
                local bar = _G.Bartender4.BarManager:GetBar(barType)
                if bar then
                    if EnhanceActionBar(barType:lower(), bar) then
                        updated = updated + 1
                    end
                end
            end
        end)
        
        if not success then
            print("DRGUI ActionBars: Error updating bars (full mode): " .. tostring(err))
        end
        
    elseif AB.integrationLevel == "basic" and _G.Bartender4.bars then
        -- Basic integration - limited bar access
        local success, err = pcall(function()
            for barId, bar in pairs(_G.Bartender4.bars) do
                if bar and type(bar) == "table" then
                    if EnhanceActionBar(barId, bar) then
                        updated = updated + 1
                    end
                end
            end
        end)
        
        if not success then
            print("DRGUI ActionBars: Error updating bars (basic mode): " .. tostring(err))
        end
    end
    
    if updated > 0 then
        print("DRGUI ActionBars: Enhanced " .. updated .. " action bars")
    end
end

-- ============================================================================
-- DRGUI-SPECIFIC FEATURES
-- ============================================================================

local function ApplyComboSpecificSettings(comboKey)
    if not comboKey or not AB.actionBars then
        return
    end
    
    -- Apply settings based on race/class/spec combination
    local success, err = pcall(function()
        for barId, bar in pairs(AB.actionBars) do
            if bar.enhanced and bar.drgui_features then
                -- Example: Different alpha for different roles
                if comboKey:find("Tank") then
                    bar.drgui_features.visibility.combat_alpha = 1.0
                    bar.drgui_features.visibility.ooc_alpha = 0.9
                elseif comboKey:find("Healer") then
                    bar.drgui_features.visibility.combat_alpha = 1.0
                    bar.drgui_features.visibility.ooc_alpha = 0.85
                else -- DPS
                    bar.drgui_features.visibility.combat_alpha = 1.0
                    bar.drgui_features.visibility.ooc_alpha = 0.8
                end
                
                -- TWW Hero Talent specific adjustments
                if comboKey:find("Hero") then
                    bar.drgui_features.tww.hero_talent_support = true
                    bar.drgui_features.tww.dynamic_layout = true
                end
            end
        end
    end)
    
    if not success then
        print("DRGUI ActionBars: Error applying combo settings: " .. tostring(err))
    end
end

local function HandleCombatStateChange()
    local inCombat = InCombatLockdown()
    
    for barId, bar in pairs(AB.actionBars) do
        if bar.enhanced and bar.drgui_features then
            local combat = bar.drgui_features.combat
            if combat.in_combat ~= inCombat then
                combat.in_combat = inCombat
                combat.last_state_change = SafeGetTime()
                
                -- Apply visibility changes if auto-adjustments enabled
                if combat.auto_adjustments then
                    local visibility = bar.drgui_features.visibility
                    local targetAlpha = inCombat and visibility.combat_alpha or visibility.ooc_alpha
                    
                    -- Apply alpha change to original bar if possible
                    if bar.original and bar.original.SetAlpha then
                        bar.original:SetAlpha(targetAlpha)
                    end
                end
            end
        end
    end
end

-- ============================================================================
-- EVENT HANDLING
-- ============================================================================

local function OnActionBarsEvent(event, ...)
    -- Throttling protection
    local now = SafeGetTime()
    if AB.lastEventTime and (now - AB.lastEventTime) < 0.05 then
        return
    end
    AB.lastEventTime = now
    
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        HandleCombatStateChange()
    elseif event == "ACTIONBAR_SLOT_CHANGED" or event == "UPDATE_BINDINGS" then
        UpdateActionBars()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
        -- Reapply combo-specific settings
        if DRGUI.GetCurrentCombo then
            local comboKey = DRGUI.GetCurrentCombo()
            if comboKey then
                ApplyComboSpecificSettings(comboKey)
            end
        end
    end
end

-- ============================================================================
-- INITIALIZATION & CLEANUP
-- ============================================================================

function AB:Initialize()
    if self.isInitialized then
        return true
    end
    
    print("DRGUI ActionBars: Initializing Enhanced Integration Layer...")
    
    -- Initialize Bartender4 integration
    local success, err = pcall(function()
        InitializeBartenderIntegration()
        
        -- Set up event handling
        if not EVENTS_REGISTERED then
            local eventFrame = CreateFrame("Frame")
            eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
            eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
            eventFrame:RegisterEvent("UPDATE_BINDINGS")
            eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
            eventFrame:SetScript("OnEvent", OnActionBarsEvent)
            
            EVENTS_REGISTERED = true
        end
        
        -- Initial action bar scan
        UpdateActionBars()
        
        -- Apply combo-specific settings if available
        if DRGUI.GetCurrentCombo then
            local comboKey = DRGUI.GetCurrentCombo()
            if comboKey then
                ApplyComboSpecificSettings(comboKey)
            end
        end
        
        self.isInitialized = true
        
        print("DRGUI ActionBars: Enhanced Integration Layer initialized successfully!")
        print("DRGUI ActionBars: Integration Level: " .. AB.integrationLevel)
        print("DRGUI ActionBars: Enhanced Bars: " .. #AB.actionBars)
    end)
    
    if not success then
        print("DRGUI ActionBars: Initialization failed: " .. tostring(err))
        return false
    end
    
    return true
end

function AB:GetStatus()
    local status = {
        initialized = self.isInitialized,
        bartender_detected = self.bartenderDetected,
        integration_level = self.integrationLevel,
        enhanced_bars = 0,
        features_active = {}
    }
    
    -- Count enhanced bars
    for _ in pairs(self.actionBars) do
        status.enhanced_bars = status.enhanced_bars + 1
    end
    
    -- Check active features
    if self.bartenderDetected then
        table.insert(status.features_active, "Bartender4 Integration")
    end
    table.insert(status.features_active, "Enhanced Visibility")
    table.insert(status.features_active, "Combat State Tracking")
    table.insert(status.features_active, "TWW Support")
    
    return status
end

function AB:Cleanup()
    -- Cleanup enhanced bars
    for barId, bar in pairs(self.actionBars or {}) do
        if bar.original and bar.original.SetAlpha then
            bar.original:SetAlpha(1.0) -- Reset to full opacity
        end
    end
    
    self.actionBars = {}
    self.isInitialized = false
    print("DRGUI ActionBars: Enhanced Integration Layer cleaned up")
end

-- ============================================================================
-- GLOBAL INTEGRATION
-- ============================================================================

-- Integration with main DRGUI system
if DRGUI and DRGUI.RegisterModule then
    DRGUI.RegisterModule("ActionBars", AB)
end

-- Mark loading complete
DRGUI_ActionBars_Loading = false

print("DRGUI ActionBars: Enhanced Integration Layer loaded successfully!")