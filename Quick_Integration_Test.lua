-- Quick Integration Hooks Test
-- Simple manual test for immediate verification

print("|cffff0000🧪 Quick Integration Hooks Test Starting...|r")

-- Test 1: Check if DRLS is loaded
if DRLS then
    print("|cff00ff00✅ DRLS main system loaded|r")
else
    print("|cffff0000❌ DRLS main system NOT loaded|r")
    return
end

-- Test 2: Check if Integration Hooks exist
if DRLS.IntegrationHooks then
    print("|cff00ff00✅ Integration Hooks system loaded|r")
else
    print("|cffff0000❌ Integration Hooks system NOT loaded|r")
    return
end

-- Test 3: Check database
if DRLSDB and DRLSDB.integrations then
    print("|cff00ff00✅ Integration database initialized|r")
else
    print("|cffff0000❌ Integration database NOT initialized|r")
end

-- Test 4: Test ShowStatus function
print("|cffff9900🔍 Testing ShowStatus function...|r")
if DRLS.IntegrationHooks.ShowStatus then
    local success, err = pcall(function()
        DRLS.IntegrationHooks:ShowStatus()
    end)
    if success then
        print("|cff00ff00✅ ShowStatus executed successfully|r")
    else
        print("|cffff0000❌ ShowStatus failed: " .. tostring(err) .. "|r")
    end
else
    print("|cffff0000❌ ShowStatus function not found|r")
end

-- Test 5: Test DetectAddons function
print("|cffff9900🔍 Testing DetectAddons function...|r")
if DRLS.IntegrationHooks.DetectAddons then
    local success, err = pcall(function()
        DRLS.IntegrationHooks:DetectAddons()
    end)
    if success then
        print("|cff00ff00✅ DetectAddons executed successfully|r")
    else
        print("|cffff0000❌ DetectAddons failed: " .. tostring(err) .. "|r")
    end
else
    print("|cffff0000❌ DetectAddons function not found|r")
end

print("|cffff0000🧪 Quick Integration Hooks Test Complete!|r")
print("|cffff9900💡 Now try these manual commands:|r")
print("|cff00ff00   /drls integrations|r")
print("|cff00ff00   /drls hooks|r")
print("|cff00ff00   /drls rescan|r")