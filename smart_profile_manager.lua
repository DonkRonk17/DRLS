-- smart_profile_manager.lua - Phase 3B.2: Smart Profile Manager with Hero Talent Integration
-- DRGUI Enhanced ActionBars Smart Profile Management System
-- Version: 2.0.0-enhanced-phase3b2-fixed

-- Ensure ActionBars module exists
print("DRGUI Smart Profile Manager: Loading...")
print("DRGUI Smart Profile Manager: Debug - DRGUI available: " .. tostring(DRGUI ~= nil))
if DRGUI then
    print("DRGUI Smart Profile Manager: Debug - DRGUI.ActionBars available: " .. tostring(DRGUI.ActionBars ~= nil))
end

if not DRGUI or not DRGUI.ActionBars then
    print("DRGUI Smart Profile Manager: ActionBars module required!")
    print("DRGUI Smart Profile Manager: DRGUI: " .. tostring(DRGUI ~= nil))
    print("DRGUI Smart Profile Manager: DRGUI.ActionBars: " .. tostring(DRGUI and DRGUI.ActionBars ~= nil))
    return
end

print("DRGUI Smart Profile Manager: Prerequisites met, initializing ProfileManager...")

-- ============================================================================
-- SMART PROFILE MANAGER CORE
-- ============================================================================

-- Initialize Profile Manager
DRGUI.ActionBars.ProfileManager = DRGUI.ActionBars.ProfileManager or {}
local PM = DRGUI.ActionBars.ProfileManager

-- Safe API wrappers
local function SafeGetTime()
    return _G.GetTime and _G.GetTime() or 0
end

local function SafeGetSpecialization()
    return _G.GetSpecialization and _G.GetSpecialization() or 1
end

local function SafeGetSpecializationInfo(specIndex)
    if _G.GetSpecializationInfo then
        return _G.GetSpecializationInfo(specIndex)
    else
        return "Unknown", nil, nil, nil, nil, nil
    end
end

-- ============================================================================
-- TWW HERO TALENT DETECTION (Phase 3B.2)
-- ============================================================================

local function GetHeroTalentInfo()
    local heroID = nil
    local heroName = "None"
    
    -- FAST: Direct hero talent detection (ID-based for performance)
    if _G.C_ClassTalents and _G.C_ClassTalents.GetActiveHeroTalentSpec then
        heroID = _G.C_ClassTalents.GetActiveHeroTalentSpec()
        
        if heroID and heroID > 0 then
            -- Simple, fast ID-based naming (no complex API calls)
            heroName = "Hero" .. heroID
            print("DRGUI Hero Debug: Hero talent ID " .. heroID .. " detected as " .. heroName)
        else
            print("DRGUI Hero Debug: No active hero talent detected")
        end
    else
        print("DRGUI Hero Debug: Hero talent API not available")
    end
    
    return heroID, heroName
end

local function UpdateHeroTalentContext()
    -- Add protection for early initialization
    if not _G.UnitExists or not _G.UnitExists("player") then
        PM.context.heroTalentID = nil
        PM.context.heroTalent = "Loading"
        return nil, "Loading"
    end
    
    local heroID, heroName = GetHeroTalentInfo()
    PM.context.heroTalentID = heroID
    PM.context.heroTalent = heroName
    return heroID, heroName
end

-- ============================================================================
-- PERFORMANCE OPTIMIZATION (Phase 3B.4)
-- ============================================================================

-- Performance cache
PM.cache = PM.cache or {
    lastUpdate = 0,
    updateInterval = 2.0, -- Update every 2 seconds instead of constantly
    heroTalent = nil,
    heroTalentID = nil,
    context = nil
}

-- Smart throttling for updates
local function ShouldUpdate()
    local now = SafeGetTime()
    if now - PM.cache.lastUpdate < PM.cache.updateInterval then
        return false -- Too soon, use cached values
    end
    PM.cache.lastUpdate = now
    return true
end

-- ============================================================================
-- PROFILE MANAGER STATE (Optimized)
-- ============================================================================

PM.profiles = PM.profiles or {}
PM.currentProfile = PM.currentProfile or nil
PM.autoSwitching = PM.autoSwitching or true
PM.isInitialized = PM.isInitialized or false

-- Context detection state
PM.context = PM.context or {
    spec = SafeGetSpecialization(),
    specName = nil,
    zone = nil,
    content = "solo",
    combat = false,
    group = "solo",
    heroTalent = nil,        -- TWW Hero Talent tracking
    heroTalentID = nil,      -- Hero Talent ID for precise matching
    lastUpdate = SafeGetTime()
}

-- Smart Learning System state
PM.analytics = PM.analytics or {
    enabled = true,
    sessions = {},
    patterns = {},
    predictions = {},
    userPreferences = {},
    learningData = {
        profileUsage = {},      
        switchTriggers = {},    
        contextPatterns = {},   
        timePatterns = {},      
        overrides = {}          
    }
}

-- Integration state
PM.integration = PM.integration or {
    actionBars = false,
    bartender4 = false,
    level = "none",
    userConfig = {}
}

-- Profile switching history for learning
PM.history = PM.history or {
    switches = {},
    preferences = {},
    lastSwitch = SafeGetTime()
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function PM:Initialize()
    if self.isInitialized then
        return true
    end
    
    print("DRGUI Profile Manager: Initializing Smart Profile Manager...")
    
    -- Verify ActionBars integration
    if not DRGUI.ActionBars or not DRGUI.ActionBars.isInitialized then
        return false, "ActionBars module not ready"
    end
    
    -- Update integration state
    if DRGUI.ActionBars.GetStatus then
        local status = DRGUI.ActionBars:GetStatus()
        self.integration.actionBars = true
        self.integration.bartender4 = status.bartender_detected or false
        self.integration.level = status.integration_level or "none"
    end
    
    -- Update initial context with protection
    local success, error = pcall(function()
        self:UpdateContext()
    end)
    
    if not success then
        print("DRGUI Profile Manager: Warning - Context update failed: " .. tostring(error))
        print("DRGUI Profile Manager: Continuing with basic initialization...")
    end
    
    self.isInitialized = true
    print("DRGUI Profile Manager: Smart Profile Manager initialized successfully!")
    print("DRGUI Profile Manager: Integration Level: " .. self.integration.level)
    print("DRGUI Profile Manager: Hero Talent: " .. (self.context.heroTalent or "None"))
    
    return true
end

function PM:UpdateContext()
    local currentTime = SafeGetTime()
    local currentSpec = SafeGetSpecialization()
    
    -- Update hero talent context first
    UpdateHeroTalentContext()
    
    -- Update basic context
    self.context.spec = currentSpec
    self.context.lastUpdate = currentTime
    
    return self:GetCurrentContext()
end

function PM:GetCurrentContext()
    return {
        spec = self.context.spec,
        specName = self.context.specName,
        content = self.context.content,
        combat = self.context.combat,
        zone = self.context.zone,
        heroTalent = self.context.heroTalent,
        heroTalentID = self.context.heroTalentID,
        lastUpdate = self.context.lastUpdate
    }
end

-- ============================================================================
-- PROFILE MANAGEMENT FUNCTIONS
-- ============================================================================

function PM:CreateProfile(name, spec, content, heroTalent)
    if not name or name == "" then
        print("DRGUI Profile Manager: Profile name required")
        return false
    end
    
    if not self.isInitialized then
        print("DRGUI Profile Manager: Not initialized yet")
        return false
    end
    
    -- Generate unique profile key
    local profileKey = name .. "_" .. SafeGetTime()
    
    -- Create profile data structure
    local profile = {
        name = name,
        key = profileKey,
        spec = spec or self.context.spec,
        content = content or "solo",
        heroTalent = heroTalent,
        created = SafeGetTime(),
        lastUsed = SafeGetTime(),
        usageCount = 0
    }
    
    -- Store profile
    self.profiles[profileKey] = profile
    
    -- Save to database if available
    if DRGUIDB then
        DRGUIDB.SmartProfiles = DRGUIDB.SmartProfiles or {}
        DRGUIDB.SmartProfiles[profileKey] = profile
    end
    
    print("DRGUI Profile Manager: ✅ Profile '" .. name .. "' created successfully!")
    if heroTalent then
        print("DRGUI Profile Manager: Hero Talent: " .. (heroTalent.name or "Unknown") .. " (ID: " .. (heroTalent.id or "Unknown") .. ")")
    end
    
    return profileKey
end

function PM:ListProfiles()
    if not self.isInitialized then
        print("DRGUI Profile Manager: Not initialized yet")
        return
    end
    
    print("=== DRGUI Smart Profile Manager ===")
    print("Available Profiles:")
    
    local count = 0
    for key, profile in pairs(self.profiles or {}) do
        count = count + 1
        local status = (key == self.currentProfile) and " (ACTIVE)" or ""
        print("  " .. count .. ". " .. (profile.name or key) .. status)
        if profile.spec then print("     Spec: " .. profile.spec) end
        if profile.content then print("     Content: " .. profile.content) end
        if profile.heroTalent and profile.heroTalent.name then 
            print("     Hero Talent: " .. profile.heroTalent.name .. " (ID: " .. (profile.heroTalent.id or "Unknown") .. ")")
        end
    end
    
    if count == 0 then
        print("  No profiles created yet")
        print("  Use: /drgui create-profile <name> or /drgui create-hero-profile <name>")
    else
        print("Total: " .. count .. " profiles")
    end
    
    print("Auto-switching: " .. (self.autoSwitching and "ENABLED" or "DISABLED"))
    print("Current Profile: " .. (self.currentProfile or "None"))
end

function PM:ShowStatus()
    if not self.isInitialized then
        print("DRGUI Profile Manager: Not initialized yet")
        return
    end
    
    print("=== DRGUI Smart Profile Manager Status ===")
    
    local status = self:GetStatus()
    print("Initialization: " .. (status.initialized and "✅ Ready" or "❌ Not Ready"))
    print("Current Profile: " .. (status.current_profile or "None"))
    print("Auto-switching: " .. (status.auto_switching and "✅ Enabled" or "❌ Disabled"))
    
    if status.context then
        print("Current Context:")
        print("  Spec: " .. (status.context.spec or "Unknown"))
        print("  Content: " .. (status.context.content or "Unknown"))
        print("  Hero Talent: " .. (status.context.heroTalent or "None"))
        print("  Hero ID: " .. (status.context.heroTalentID or "None"))
    end
    
    if status.integration then
        print("Integration: ✅ ActionBars connected")
        print("  Level: " .. (status.integration.level or "unknown"))
        print("  Bartender4: " .. (status.integration.bartender4 and "detected" or "not detected"))
    else
        print("Integration: ⚠️ ActionBars not connected")
    end
    
    -- Count profiles
    local profileCount = 0
    for _ in pairs(self.profiles or {}) do
        profileCount = profileCount + 1
    end
    print("Total Profiles: " .. profileCount)
end

-- ============================================================================
-- PROFILE SWITCHING & NOTIFICATIONS
-- ============================================================================

function PM:SetCurrentProfile(profileKey, reason)
    if not profileKey or not self.profiles[profileKey] then
        print("DRGUI Profile Manager: ❌ Profile not found: " .. tostring(profileKey))
        return false
    end
    
    local oldProfile = self.currentProfile
    local newProfile = self.profiles[profileKey]
    
    self.currentProfile = profileKey
    
    -- Show notification
    if reason then
        if reason == "auto_switch" then
            print("DRGUI Profile Manager: 🔄 Auto-switched to profile '" .. newProfile.name .. "'")
            if newProfile.heroTalent and newProfile.heroTalent.name then
                print("DRGUI Profile Manager: Hero Talent: " .. newProfile.heroTalent.name)
            end
        elseif reason == "manual_switch" then
            print("DRGUI Profile Manager: ✅ Manually switched to profile '" .. newProfile.name .. "'")
        else
            print("DRGUI Profile Manager: Switched to profile '" .. newProfile.name .. "' (" .. reason .. ")")
        end
    else
        print("DRGUI Profile Manager: Switched to profile '" .. newProfile.name .. "'")
    end
    
    -- Update usage stats
    newProfile.lastUsed = SafeGetTime()
    newProfile.usageCount = (newProfile.usageCount or 0) + 1
    
    return true
end

function PM:SwitchToProfile(profileName)
    if not self.isInitialized then
        print("DRGUI Profile Manager: Not initialized yet")
        return false
    end
    
    if not profileName or profileName == "" then
        print("DRGUI Profile Manager: Profile name required")
        print("Usage: /drgui switch-profile <name>")
        return false
    end
    
    -- Find profile by name
    local profileKey = nil
    for key, profile in pairs(self.profiles or {}) do
        if profile.name == profileName or key == profileName then
            profileKey = key
            break
        end
    end
    
    if not profileKey then
        print("DRGUI Profile Manager: Profile '" .. profileName .. "' not found")
        print("Use /drgui profiles to see available profiles")
        return false
    end
    
    local success = self:SetCurrentProfile(profileKey, "manual_switch")
    return success
end

function PM:CheckHeroTalentChange()
    if not self.isInitialized then
        return
    end
    
    -- Force fresh hero talent detection to avoid cached values
    local heroID, heroName = GetHeroTalentInfo()
    
    print("DRGUI Hero Debug: Current detection - ID: " .. tostring(heroID) .. ", Name: " .. tostring(heroName))
    print("DRGUI Hero Debug: Cached context - ID: " .. tostring(self.context.heroTalentID) .. ", Name: " .. tostring(self.context.heroTalent))
    
    -- Check if hero talent changed (use both ID and name for accuracy)
    local heroChanged = false
    if heroName ~= self.context.heroTalent then
        heroChanged = true
    elseif heroID ~= self.context.heroTalentID then
        heroChanged = true
    end
    
    if heroChanged then
        print("DRGUI Profile Manager: 🎯 Hero Talent changed!")
        print("DRGUI Profile Manager: " .. (self.context.heroTalent or "None") .. " → " .. (heroName or "None"))
        
        -- Update context with fresh data
        self.context.heroTalent = heroName
        self.context.heroTalentID = heroID
        
        -- Try to find a matching profile for this hero talent
        local matchingProfile = nil
        for key, profile in pairs(self.profiles or {}) do
            if profile.heroTalent and profile.heroTalent.name == heroName then
                matchingProfile = key
                break
            end
        end
        
        if matchingProfile and self.autoSwitching then
            self:SetCurrentProfile(matchingProfile, "auto_switch")
        elseif heroName and heroName ~= "None" and heroName ~= "Unknown" and not heroName:match("^Hero%d+$") then
            print("DRGUI Profile Manager: 💡 Tip: Create a profile for " .. heroName .. " with /drgui create-hero-profile <name>")
        end
    end
end

function PM:TestHeroTalentAPIs()
    print("DRGUI Hero Debug: Testing available hero talent APIs...")
    
    -- Test basic API availability
    local apis = {
        "C_ClassTalents.GetActiveHeroTalentSpec",
        "C_ClassTalents.GetHeroTalentSpecName", 
        "C_ClassTalents.GetHeroTalentSpecInfo",
        "C_Traits.GetSubTreeInfo"
    }
    
    for _, apiPath in ipairs(apis) do
        local parts = {strsplit(".", apiPath)}
        local obj = _G
        local exists = true
        
        for i, part in ipairs(parts) do
            if obj and obj[part] then
                obj = obj[part]
            else
                exists = false
                break
            end
        end
        
        print("DRGUI Hero Debug: " .. apiPath .. " = " .. (exists and "✅ Available" or "❌ Not Available"))
    end
    
    -- Test actual hero talent detection
    print("DRGUI Hero Debug: Current hero talent detection:")
    local heroID, heroName = GetHeroTalentInfo()
    print("DRGUI Hero Debug: Result - ID: " .. tostring(heroID) .. ", Name: " .. tostring(heroName))
    
    return heroID, heroName
end

function PM:ToggleAutoSwitching()
    self.autoSwitching = not self.autoSwitching
    
    if self.autoSwitching then
        print("DRGUI Profile Manager: ✅ Auto-switching enabled")
        print("DRGUI Profile Manager: Profiles will auto-switch based on hero talents and context")
    else
        print("DRGUI Profile Manager: ⏸️ Auto-switching disabled")
        print("DRGUI Profile Manager: Profiles must be switched manually")
    end
    
    return self.autoSwitching
end

function PM:GetStatus()
    if not self.isInitialized then
        print("DRGUI Profile Manager: ❌ Not initialized")
        return
    end
    
    print("DRGUI Profile Manager: Status Report")
    print("==============================================")
    
    -- Basic Status
    print("📊 Basic Status:")
    print("  Initialized: " .. (self.isInitialized and "✅" or "❌"))
    print("  Auto-switching: " .. (self.autoSwitching and "✅ Enabled" or "⏸️ Disabled"))
    
    -- Current Profile
    print("\n🎯 Current Profile:")
    if self.currentProfile and self.profiles[self.currentProfile] then
        local profile = self.profiles[self.currentProfile]
        print("  Name: " .. profile.name)
        print("  Created: " .. os.date("%Y-%m-%d %H:%M", profile.created or 0))
        print("  Last Used: " .. os.date("%Y-%m-%d %H:%M", profile.lastUsed or 0))
        print("  Usage Count: " .. (profile.usageCount or 0))
        if profile.heroTalent then
            print("  Hero Talent: " .. (profile.heroTalent.name or "Unknown"))
        end
    else
        print("  No profile selected")
    end
    
    -- Hero Talent Context
    print("\n🎭 Hero Talent Context:")
    local heroID, heroName = GetHeroTalentInfo()
    print("  Current Hero Talent: " .. (heroName or "None"))
    print("  Hero ID: " .. (heroID or "None"))
    
    -- Available Profiles
    print("\n📁 Available Profiles:")
    local profileCount = 0
    for key, profile in pairs(self.profiles or {}) do
        profileCount = profileCount + 1
        local marker = (key == self.currentProfile) and "➤ " or "  "
        print(marker .. profile.name .. " (" .. (profile.heroTalent and profile.heroTalent.name or "No Hero") .. ")")
    end
    print("Total Profiles: " .. profileCount)
end

function PM:GetStatus()
    return {
        initialized = self.isInitialized,
        auto_switching = self.autoSwitching,
        current_profile = self.currentProfile,
        context = self:GetCurrentContext(),
        integration = self.integration
    }
end

-- ============================================================================
-- INITIALIZATION AND HERO TALENT MONITORING
-- ============================================================================

function PM:Initialize()
    print("DRGUI Smart Profile Manager: Starting initialization...")
    
    -- Initialize state
    self.isInitialized = false
    self.currentProfile = nil
    self.profiles = self.profiles or {}
    self.autoSwitching = true
    self.lastHeroCheck = 0
    
    -- Initialize context tracking
    UpdateHeroTalentContext()
    
    -- Set up hero talent monitoring
    self:SetupHeroTalentMonitoring()
    
    print("DRGUI Smart Profile Manager: ✅ Initialization complete")
    self.isInitialized = true
    return true
end

function PM:SetupHeroTalentMonitoring()
    -- Create a frame for monitoring hero talent changes
    local frame = CreateFrame("Frame", "DRGUIHeroTalentMonitor")
    
    -- Monitor for talent changes
    frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    frame:RegisterEvent("TRAIT_CONFIG_LIST_UPDATED")
    
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "TRAIT_CONFIG_UPDATED" or 
           event == "PLAYER_SPECIALIZATION_CHANGED" or
           event == "TRAIT_CONFIG_LIST_UPDATED" then
            -- Throttle checks to avoid spam
            local currentTime = SafeGetTime()
            if currentTime - PM.lastHeroCheck > 2.0 then
                PM.lastHeroCheck = currentTime
                C_Timer.After(1.0, function()
                    PM:CheckHeroTalentChange()
                end)
            end
        end
    end)
    
    print("DRGUI Smart Profile Manager: Hero talent monitoring active")
end

-- ============================================================================
-- MODULE LOADING
-- ============================================================================

print("DRGUI Smart Profile Manager: Core module loaded successfully!")

-- Auto-initialize if ActionBars is ready
if DRGUI.ActionBars and DRGUI.ActionBars.isInitialized then
    PM:Initialize()
end

-- Return the module
return PM