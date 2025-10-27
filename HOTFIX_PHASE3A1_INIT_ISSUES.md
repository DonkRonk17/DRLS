# HOTFIX: Phase 3A.1 Initialization Issues

## Issues Fixed
```
1. UnitFrames ERROR: Failed to create target frame - powerHeight nil value
2. ActionBars ERROR: IsAddOnLoaded timing issue during initialization
```

## Root Causes
1. **Target Frame Config:** Missing powerHeight and castBarHeight in target frame configuration
2. **API Timing:** IsAddOnLoaded not available during early addon initialization

## Fixes Applied

### Fix 1: UnitFrames Target Frame Configuration
**File:** `unitframes_enhanced.lua`
**Lines:** 67-85

**Before:**
```lua
target = {
    // ... config ...
    enhancedTargetInfo = true -- Missing powerHeight!
},
```

**After:**
```lua
target = {
    // ... config ...
    powerHeight = 11, -- Added missing powerHeight
    castBarHeight = 18, -- Added missing castBarHeight  
    enhancedTargetInfo = true
},
```

### Fix 2: ActionBars Safe Addon Detection
**File:** `actionbars_enhanced.lua`
**Lines:** 52-62

**Before:**
```lua
if IsAddOnLoaded("Bartender4") then
    detection.addon_loaded = true
```

**After:**
```lua
local success, isLoaded = pcall(function()
    return IsAddOnLoaded and IsAddOnLoaded("Bartender4")
end)

if not success then
    -- Fallback detection using _G presence
    detection.addon_loaded = _G.Bartender4 ~= nil
else
    detection.addon_loaded = isLoaded
end
```

## Expected Results After Fix
- ✅ Target frame should create successfully without powerHeight errors
- ✅ ActionBars should initialize without IsAddOnLoaded errors
- ✅ All modules should load cleanly: UnitFrames ✓ | Nameplates ✓ | ActionBars ✓

## Applied At
October 26, 2025 - Phase 3A.1 Testing Session

## Notes
- Using proven Phase 1 & 2 rapid debugging methodology
- Fixes target both configuration and timing issues
- Maintains backward compatibility and error handling