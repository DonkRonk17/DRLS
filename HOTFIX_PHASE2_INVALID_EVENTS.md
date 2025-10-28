# HOTFIX: Phase 2 Invalid Events Fix

## Issue
```
DRGUI Enhanced: Unit Frames init error: Frame:RegisterEvent():Frame:RegisterEvent(): 
Attempt to register unknown event "UNIT_HEALTH_FREQUENT"
```

## Root Cause
Invalid WoW API events were being registered in unit frames system:
- `UNIT_HEALTH_FREQUENT` (doesn't exist in WoW API)
- `UNIT_POWER_FREQUENT` (doesn't exist in WoW API)

## Fix Applied
**File:** `unitframes_enhanced.lua`

### Event Registration Fix (Lines 447-448)
**Before:**
```lua
eventFrame:RegisterEvent("UNIT_HEALTH_FREQUENT")
eventFrame:RegisterEvent("UNIT_POWER_FREQUENT")
```

**After:**
```lua
-- Removed invalid events, keeping only valid WoW API events
```

### Event Handling Fix (Lines 377, 382)
**Before:**
```lua
if event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" then
elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT" then
```

**After:**
```lua
if event == "UNIT_HEALTH" then
elseif event == "UNIT_POWER_UPDATE" then
```

## Validation Required
- ✅ Unit frames should initialize without event registration errors
- ✅ All `/drgui` commands should work properly
- ✅ Health/power updates should still function normally

## Applied At
October 26, 2025 - Phase 2 Testing Session

## Notes
- This was a development artifact that made it into the release code
- Functionality remains the same with valid events only
- Part of ongoing Phase 2 validation process