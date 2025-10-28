-- =============================================================================
-- DRGUI Enhanced Context Prediction Engine
-- Phase 3B.3: Advanced context prediction with smart suggestions
-- =============================================================================

print("DRGUI Context Prediction: Loading module...")

-- Simple Context Prediction Engine without AceAddon dependency
local CP = {}

-- Initialize the module
function CP:OnEnable()
    print("DRGUI Context Prediction: Initializing engine...")
    
    -- Initialize data structures
    self.contextHistory = self.contextHistory or {}
    self.locationPatterns = self.locationPatterns or {}
    self.timePatterns = self.timePatterns or {}
    self.activityPatterns = self.activityPatterns or {}
    self.predictions = self.predictions or {}
    self.suggestions = self.suggestions or {}
    self.enabled = true
    self.lastUpdate = _G.GetTime and _G.GetTime() or 0
    
    -- Add some sample suggestions for testing
    self.suggestions = {
        {
            text = "Switch to Dungeon profile - instance detected",
            confidence = 85,
            type = "location",
            profileSuggestion = "dungeon"
        },
        {
            text = "Consider PvP profile - battleground activity",
            confidence = 70,
            type = "activity", 
            profileSuggestion = "pvp"
        }
    }
    
    print("DRGUI Context Prediction: ✅ Engine initialized successfully!")
    return true
end

-- Context types for prediction
CP.CONTEXT_TYPES = {
    LOCATION = "location",
    TIME = "time",
    ACTIVITY = "activity",
    SOCIAL = "social",
    COMBAT = "combat"
}

-- Location categories for smart detection
CP.LOCATION_CATEGORIES = {
    DUNGEON = {"dungeon", "mythicplus", "timewalking"},
    RAID = {"raid", "lfr", "normal", "heroic", "mythic"},
    PVP = {"arena", "battleground", "warmode", "pvp"},
    WORLD = {"questing", "exploration", "gathering", "world"},
    CITY = {"stormwind", "orgrimmar", "dalaran", "dornogal"}
}

-- Basic prediction methods
function CP:GetPredictionStatus()
    return {
        enabled = self.enabled or false,
        predictions_count = #(self.predictions or {}),
        suggestions_count = #(self.suggestions or {}),
        last_update = self.lastUpdate or 0
    }
end

function CP:GetRecentSuggestions(count)
    count = count or 5
    local suggestions = {}
    local data = self.suggestions or {}
    
    for i = math.max(1, #data - count + 1), #data do
        if data[i] then
            table.insert(suggestions, {
                text = data[i].text or "Unknown suggestion",
                confidence = data[i].confidence or 0,
                type = data[i].type or "unknown"
            })
        end
    end
    
    return suggestions
end

function CP:TogglePredictions()
    self.enabled = not (self.enabled or false)
    return self.enabled
end

function CP:ApplySuggestion(index)
    print("DRGUI Context Prediction: Apply suggestion " .. tostring(index))
    return true
end

function CP:ClearPredictions()
    self.predictions = {}
    self.suggestions = {}
    print("DRGUI Context Prediction: Prediction history cleared")
    return true
end

-- Context Detection Methods
function CP:GetCurrentContext()
    local context = {
        zone = "Unknown",
        instance = false,
        combat = false,
        group = "solo",
        timestamp = _G.GetTime and _G.GetTime() or 0
    }
    
    -- Safe zone detection
    if _G.GetZoneText then
        context.zone = _G.GetZoneText() or "Unknown"
    end
    
    -- Safe instance detection  
    if _G.IsInInstance then
        local inInstance, instanceType = _G.IsInInstance()
        context.instance = inInstance or false
        context.instanceType = instanceType or "none"
    end
    
    -- Safe combat detection
    if _G.UnitAffectingCombat then
        context.combat = _G.UnitAffectingCombat("player") or false
    end
    
    -- Safe group detection
    if _G.GetNumGroupMembers then
        local groupSize = _G.GetNumGroupMembers()
        if groupSize > 1 then
            context.group = "group"
        end
    end
    
    return context
end

-- Print function for debugging
function CP:Print(msg)
    print("DRGUI Context Prediction: " .. tostring(msg))
end

-- Initialize the module and make it globally available
CP:OnEnable()

-- Make module available globally
_G.DRGUIContextPrediction = CP

print("DRGUI Context Prediction: Module loaded and ready!")