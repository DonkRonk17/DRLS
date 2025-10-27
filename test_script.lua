-- DRGUI Test Script
-- Run this in-game to test ElvUI-independent functionality

print("=== DRGUI FUNCTIONALITY TEST ===")

-- Test 1: Basic Variable Availability
print("1. Testing Core Variables:")
print("   DRGUI available:", DRGUI ~= nil)
print("   DRGUIDB available:", DRGUIDB ~= nil)
print("   Engine available:", DRGUI_Engine ~= nil)

-- Test 2: Module Availability
if DRGUI then
    print("2. Testing Modules:")
    print("   ActionBars module:", DRGUI.ActionBars ~= nil)
    print("   UnitFrames module:", DRGUI.UnitFrames ~= nil)
    print("   Engine reference:", DRGUI.Engine ~= nil)
end

-- Test 3: Function Availability
print("3. Testing Functions:")
print("   GetCharacterCombo():", type(GetCharacterCombo) == "function")

if GetCharacterCombo then
    local combo = GetCharacterCombo()
    print("   Current combo:", combo)
end

-- Test 4: Profile System
if DRGUIDB then
    local profileCount = 0
    for k, v in pairs(DRGUIDB) do
        profileCount = profileCount + 1
    end
    print("4. Profile System:")
    print("   Total profiles:", profileCount)
    if GetCharacterCombo then
        local currentCombo = GetCharacterCombo()
        print("   Current profile exists:", DRGUIDB[currentCombo] ~= nil)
    end
end

-- Test 5: ElvUI Independence
print("5. ElvUI Independence:")
print("   ElvUI addon loaded:", IsAddOnLoaded("ElvUI"))
print("   DRGUI works without ElvUI:", DRGUI ~= nil and not IsAddOnLoaded("ElvUI"))

-- Test 6: Integration Tests
print("6. Optional Integrations:")
local integrations = {
    "Details",
    "WeakAuras", 
    "DBM-Core",
    "BigWigs",
    "Plater"
}

for _, addon in ipairs(integrations) do
    print("   " .. addon .. ":", IsAddOnLoaded(addon))
end

print("=== END TEST ===")
print("Copy and paste this script in-game to test DRGUI!")