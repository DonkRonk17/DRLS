-- DRLS Integration Hooks Testing Suite
-- Comprehensive testing for the Integration Hooks System

local DRLS_IntegrationTest = {}

-- Test Configuration
local testResults = {
    passed = 0,
    failed = 0,
    tests = {}
}

-- Test Helper Functions
local function TestPrint(message, success)
    local color = success and "|cff00ff00✅" or "|cffff0000❌"
    print(color .. " " .. message .. "|r")
    
    if success then
        testResults.passed = testResults.passed + 1
    else
        testResults.failed = testResults.failed + 1
    end
    
    table.insert(testResults.tests, {message = message, success = success})
end

local function TestHeader(title)
    print("|cffff0000=" .. string.rep("=", 60) .. "|r")
    print("|cffff9900🧪 " .. title .. "|r")
    print("|cffff0000-" .. string.rep("-", 58) .. "|r")
end

local function TestSummary()
    print("|cffff0000=" .. string.rep("=", 60) .. "|r")
    print("|cffff9900📊 Test Summary:|r")
    print("|cff00ff00✅ Passed: " .. testResults.passed .. "|r")
    print("|cffff0000❌ Failed: " .. testResults.failed .. "|r")
    print("|cffff9900Total Tests: " .. (testResults.passed + testResults.failed) .. "|r")
    
    local successRate = (testResults.passed / (testResults.passed + testResults.failed)) * 100
    local rateColor = successRate >= 90 and "|cff00ff00" or successRate >= 70 and "|cffff9900" or "|cffff0000"
    print(rateColor .. "Success Rate: " .. string.format("%.1f%%", successRate) .. "|r")
    print("|cffff0000=" .. string.rep("=", 60) .. "|r")
end

-- Test 1: System Initialization
function DRLS_IntegrationTest:TestSystemInitialization()
    TestHeader("DRLS Integration Hooks System Initialization")
    
    -- Check if DRLS is loaded
    TestPrint("DRLS main system loaded", DRLS ~= nil)
    
    -- Check if Integration Hooks exist
    TestPrint("Integration Hooks system exists", DRLS and DRLS.IntegrationHooks ~= nil)
    
    -- Check if database is initialized
    TestPrint("DRLSDB integrations initialized", DRLSDB and DRLSDB.integrations ~= nil)
    
    -- Check core functions exist
    if DRLS and DRLS.IntegrationHooks then
        TestPrint("ShowStatus function exists", type(DRLS.IntegrationHooks.ShowStatus) == "function")
        TestPrint("DetectAddons function exists", type(DRLS.IntegrationHooks.DetectAddons) == "function")
        TestPrint("ToggleIntegration function exists", type(DRLS.IntegrationHooks.ToggleIntegration) == "function")
        TestPrint("InitializeHooks function exists", type(DRLS.IntegrationHooks.InitializeHooks) == "function")
    else
        TestPrint("ShowStatus function exists", false)
        TestPrint("DetectAddons function exists", false)
        TestPrint("ToggleIntegration function exists", false)
        TestPrint("InitializeHooks function exists", false)
    end
end

-- Test 2: Addon Detection
function DRLS_IntegrationTest:TestAddonDetection()
    TestHeader("Addon Detection Testing")
    
    if not DRLS or not DRLS.IntegrationHooks then
        TestPrint("Integration system available for testing", false)
        return
    end
    
    -- Test detection for common addons
    local commonAddons = {"Details", "WeakAuras", "ElvUI", "DBM-Core", "BigWigs"}
    
    for _, addonName in pairs(commonAddons) do
        local loaded = IsAddOnLoaded(addonName)
        local globalExists = _G[addonName] ~= nil
        
        if loaded then
            TestPrint(addonName .. " detected and loaded", true)
        else
            TestPrint(addonName .. " not found (expected if not installed)", true)
        end
        
        -- Check if global namespace exists
        if globalExists then
            TestPrint(addonName .. " global namespace available", true)
        end
    end
end

-- Test 3: Integration Commands
function DRLS_IntegrationTest:TestCommands()
    TestHeader("Integration Commands Testing")
    
    if not DRLS or not DRLS.IntegrationHooks then
        TestPrint("Integration system available for commands", false)
        return
    end
    
    -- Test ShowStatus command (safe to call)
    local success, err = pcall(function()
        DRLS.IntegrationHooks:ShowStatus()
    end)
    TestPrint("ShowStatus command executes without error", success)
    if not success then
        print("|cffff0000Error: " .. tostring(err) .. "|r")
    end
    
    -- Test DetectAddons command (safe to call)
    success, err = pcall(function()
        DRLS.IntegrationHooks:DetectAddons()
    end)
    TestPrint("DetectAddons command executes without error", success)
    if not success then
        print("|cffff0000Error: " .. tostring(err) .. "|r")
    end
    
    -- Test InitializeHooks command (safe to call)
    success, err = pcall(function()
        DRLS.IntegrationHooks:InitializeHooks()
    end)
    TestPrint("InitializeHooks command executes without error", success)
    if not success then
        print("|cffff0000Error: " .. tostring(err) .. "|r")
    end
end

-- Test 4: Database Structure
function DRLS_IntegrationTest:TestDatabaseStructure()
    TestHeader("Database Structure Testing")
    
    if not DRLSDB then
        TestPrint("DRLSDB exists", false)
        return
    end
    
    TestPrint("DRLSDB exists", true)
    TestPrint("integrations table exists", DRLSDB.integrations ~= nil)
    
    if DRLSDB.integrations then
        TestPrint("integrations.states exists", DRLSDB.integrations.states ~= nil)
        TestPrint("integrations.enabled exists", DRLSDB.integrations.enabled ~= nil)
        TestPrint("integrations.hooks exists", DRLSDB.integrations.hooks ~= nil)
        TestPrint("integrations.lastScan exists", DRLSDB.integrations.lastScan ~= nil)
        
        -- Check data types
        TestPrint("states is table", type(DRLSDB.integrations.states) == "table")
        TestPrint("enabled is table", type(DRLSDB.integrations.enabled) == "table")
        TestPrint("hooks is table", type(DRLSDB.integrations.hooks) == "table")
        TestPrint("lastScan is number", type(DRLSDB.integrations.lastScan) == "number")
    end
end

-- Test 5: Integration Toggle (Safe Test)
function DRLS_IntegrationTest:TestToggleFunctionality()
    TestHeader("Integration Toggle Testing")
    
    if not DRLS or not DRLS.IntegrationHooks then
        TestPrint("Integration system available for toggle testing", false)
        return
    end
    
    -- Test toggle function with safe parameters
    local success, err = pcall(function()
        -- Test with non-existent addon (safe)
        DRLS.IntegrationHooks:ToggleIntegration("TestAddon", true)
    end)
    TestPrint("ToggleIntegration handles unknown addon gracefully", success)
    
    -- Test toggle function with nil parameters
    success, err = pcall(function()
        DRLS.IntegrationHooks:ToggleIntegration(nil, true)
    end)
    TestPrint("ToggleIntegration handles nil addon gracefully", success)
    
    -- Test toggle function with invalid enabled parameter
    success, err = pcall(function()
        DRLS.IntegrationHooks:ToggleIntegration("TestAddon", "invalid")
    end)
    TestPrint("ToggleIntegration handles invalid enabled parameter", success)
end

-- Main Test Runner
function DRLS_IntegrationTest:RunAllTests()
    print("|cffff0000🚀 Starting DRLS Integration Hooks Comprehensive Test Suite|r")
    print("|cffff9900Time: " .. date("%Y-%m-%d %H:%M:%S") .. "|r")
    
    -- Reset test results
    testResults = {passed = 0, failed = 0, tests = {}}
    
    -- Run all tests
    self:TestSystemInitialization()
    self:TestAddonDetection()
    self:TestDatabaseStructure()
    self:TestCommands()
    self:TestToggleFunctionality()
    
    -- Show summary
    TestSummary()
    
    -- Recommendations
    print("|cffff9900💡 Next Steps:|r")
    if testResults.failed == 0 then
        print("|cff00ff00• All tests passed! Integration system is ready.|r")
        print("|cff00ff00• Try: /drls integrations to see live status|r")
        print("|cff00ff00• Try: /drls rescan to refresh addon detection|r")
    else
        print("|cffff0000• Some tests failed. Check initialization.|r")
        print("|cffff0000• Try: /reload to restart DRLS|r")
    end
end

-- Slash Command for Testing
SLASH_DRLSTEST1 = "/drlstest"
SlashCmdList["DRLSTEST"] = function(msg)
    if msg == "integration" or msg == "hooks" then
        DRLS_IntegrationTest:RunAllTests()
    else
        print("|cffff9900DRLS Test Suite Commands:|r")
        print("|cff00ff00/drlstest integration - Run Integration Hooks tests|r")
    end
end

-- Auto-run test on load (optional)
-- DRLS_IntegrationTest:RunAllTests()

print("|cff00ff00✅ DRLS Integration Test Suite loaded!|r")
print("|cffff9900Use: /drlstest integration to run comprehensive tests|r")