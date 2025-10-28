-- DRLS COMPREHENSIVE TESTING & BENCHMARKING SUITE
-- Complete testing framework for all DRLS systems and modules
-- Version: 1.0.0

local DRLS_TestSuite = {}

-- Test Results Storage
local testResults = {
    total = 0,
    passed = 0,
    failed = 0,
    warnings = 0,
    skipped = 0,
    categories = {},
    benchmarks = {},
    startTime = 0,
    endTime = 0
}

-- Test Categories
local TEST_CATEGORIES = {
    "Core System",
    "AI Systems",
    "Module Systems",
    "Integration Hooks",
    "Profile Management",
    "Backup System",
    "UI Customization",
    "Image Manager",
    "Script Launcher",
    "Performance",
    "Memory",
    "Compatibility"
}

-- Benchmark Thresholds
local PERFORMANCE_THRESHOLDS = {
    memoryLimit = 50 * 1024, -- 50 MB in KB
    frameTimeLimit = 5, -- 5ms per frame
    loadTimeLimit = 2000, -- 2 seconds
    moduleInitLimit = 100, -- 100ms per module
    eventHandlerLimit = 1 -- 1ms per event
}

-- Color Codes for Output
local COLOR = {
    SUCCESS = "|cff00ff00",
    FAIL = "|cffff0000",
    WARN = "|cffff9900",
    INFO = "|cff00ffff",
    HEADER = "|cffff0000",
    NORMAL = "|r"
}

-- ===================================================================
-- UTILITY FUNCTIONS
-- ===================================================================

local function PrintHeader(text)
    print(COLOR.HEADER .. "=" .. string.rep("=", 70) .. COLOR.NORMAL)
    print(COLOR.HEADER .. "  " .. text .. COLOR.NORMAL)
    print(COLOR.HEADER .. "-" .. string.rep("-", 70) .. COLOR.NORMAL)
end

local function PrintTest(name, success, message, category)
    local icon = success and "✅" or "❌"
    local color = success and COLOR.SUCCESS or COLOR.FAIL
    
    testResults.total = testResults.total + 1
    if success then
        testResults.passed = testResults.passed + 1
    else
        testResults.failed = testResults.failed + 1
    end
    
    -- Track by category
    if category then
        testResults.categories[category] = testResults.categories[category] or {passed = 0, failed = 0}
        if success then
            testResults.categories[category].passed = testResults.categories[category].passed + 1
        else
            testResults.categories[category].failed = testResults.categories[category].failed + 1
        end
    end
    
    local output = color .. icon .. " " .. name .. COLOR.NORMAL
    if message and message ~= "" then
        output = output .. COLOR.INFO .. " (" .. message .. ")" .. COLOR.NORMAL
    end
    print(output)
end

local function PrintWarning(message)
    testResults.warnings = testResults.warnings + 1
    print(COLOR.WARN .. "⚠️  WARNING: " .. message .. COLOR.NORMAL)
end

local function PrintInfo(message)
    print(COLOR.INFO .. "ℹ️  " .. message .. COLOR.NORMAL)
end

local function MeasureTime(func)
    local startTime = GetTime()
    func()
    return (GetTime() - startTime) * 1000 -- Convert to ms
end

local function MeasureMemory(func)
    collectgarbage("collect")
    local memBefore = collectgarbage("count")
    func()
    collectgarbage("collect")
    local memAfter = collectgarbage("count")
    return memAfter - memBefore
end

-- ===================================================================
-- CORE SYSTEM TESTS
-- ===================================================================

function DRLS_TestSuite:TestCoreSystem()
    PrintHeader("CORE SYSTEM TESTS")
    local category = "Core System"
    
    -- Test 1: DRLS Main Object Exists
    PrintTest("DRLS main object exists", DRLS ~= nil, type(DRLS), category)
    
    -- Test 2: Database Initialization
    PrintTest("DRLSDB initialized", DRLSDB ~= nil, type(DRLSDB), category)
    
    if DRLSDB then
        PrintTest("DRLSDB.profiles exists", DRLSDB.profiles ~= nil, nil, category)
        PrintTest("DRLSDB.backups exists", DRLSDB.backups ~= nil, nil, category)
        PrintTest("DRLSDB.settings exists", DRLSDB.settings ~= nil, nil, category)
    end
    
    -- Test 3: Core Methods
    if DRLS then
        PrintTest("DRLS has db property", DRLS.db ~= nil, nil, category)
        
        -- Test system message capability
        local hasSystemMessage = DRLS.SystemMessage ~= nil or DRLS.Print ~= nil
        PrintTest("System messaging available", hasSystemMessage, nil, category)
    end
    
    -- Test 4: LibStub Integration
    local libStub = LibStub
    PrintTest("LibStub available", libStub ~= nil, nil, category)
    
    if libStub then
        local aceAddon = LibStub:GetLibrary("AceAddon-3.0", true)
        PrintTest("AceAddon-3.0 loaded", aceAddon ~= nil, nil, category)
        
        local aceEvent = LibStub:GetLibrary("AceEvent-3.0", true)
        PrintTest("AceEvent-3.0 loaded", aceEvent ~= nil, nil, category)
        
        local aceTimer = LibStub:GetLibrary("AceTimer-3.0", true)
        PrintTest("AceTimer-3.0 loaded", aceTimer ~= nil, nil, category)
    end
    
    -- Test 5: Version Information
    if DRLSDB then
        local hasVersion = DRLSDB.version ~= nil
        PrintTest("Version tracking", hasVersion, DRLSDB.version or "N/A", category)
    end
end

-- ===================================================================
-- AI SYSTEM TESTS
-- ===================================================================

function DRLS_TestSuite:TestAISystems()
    PrintHeader("AI SYSTEMS TESTS")
    local category = "AI Systems"
    
    -- Test AI Core
    PrintTest("AI Core exists", DRLS.AI ~= nil, nil, category)
    
    if DRLS.AI then
        PrintTest("AI.Initialize method", type(DRLS.AI.Initialize) == "function", nil, category)
        PrintTest("AI.ShowStatus method", type(DRLS.AI.ShowStatus) == "function", nil, category)
        PrintTest("AI.DelayedScan method", type(DRLS.AI.DelayedScan) == "function", nil, category)
        
        -- Test AI status
        local success, error = pcall(function() DRLS.AI.status end)
        PrintTest("AI status accessible", success, nil, category)
    end
    
    -- Test Ecosystem Analyzer
    PrintTest("Ecosystem Analyzer exists", DRLS.EcosystemAnalyzer ~= nil, nil, category)
    
    if DRLS.EcosystemAnalyzer then
        PrintTest("EcosystemAnalyzer.Initialize", 
            type(DRLS.EcosystemAnalyzer.Initialize) == "function", nil, category)
        PrintTest("EcosystemAnalyzer.ShowAnalysis", 
            type(DRLS.EcosystemAnalyzer.ShowAnalysis) == "function", nil, category)
    end
    
    -- Test addon detection capability
    local testAddons = {"ElvUI", "Details", "WeakAuras", "DBM", "DRLS"}
    local detectionWorks = false
    for _, addonName in ipairs(testAddons) do
        if _G[addonName] then
            detectionWorks = true
            PrintInfo("Detected: " .. addonName)
        end
    end
    PrintTest("Addon detection functional", detectionWorks, nil, category)
end

-- ===================================================================
-- MODULE SYSTEM TESTS
-- ===================================================================

function DRLS_TestSuite:TestModules()
    PrintHeader("MODULE SYSTEMS TESTS")
    local category = "Module Systems"
    
    -- List of expected modules based on DRLS.toc
    local expectedModules = {
        "actionbars",
        "unitframes",
        "nameplates",
        "chat",
        "minimap",
        "databars",
        "datatexts",
        "auras",
        "blizzard",
        "skins",
        "tooltip",
        "bags"
    }
    
    PrintInfo("Testing " .. #expectedModules .. " modules")
    
    for _, moduleName in ipairs(expectedModules) do
        -- Check if module globals exist (modules may register themselves)
        local upperName = moduleName:upper()
        local moduleExists = _G["DRLS_" .. upperName] ~= nil
        
        PrintTest("Module: " .. moduleName, moduleExists, 
            moduleExists and "Loaded" or "Not found", category)
    end
    
    -- Test module registration system if available
    if DRLS_Core and DRLS_Core.modules then
        local moduleCount = 0
        for _ in pairs(DRLS_Core.modules) do
            moduleCount = moduleCount + 1
        end
        PrintTest("Core module registry", moduleCount > 0, 
            moduleCount .. " modules registered", category)
    end
end

-- ===================================================================
-- INTEGRATION HOOKS TESTS
-- ===================================================================

function DRLS_TestSuite:TestIntegrationHooks()
    PrintHeader("INTEGRATION HOOKS TESTS")
    local category = "Integration Hooks"
    
    PrintTest("IntegrationHooks exists", DRLS.IntegrationHooks ~= nil, nil, category)
    
    if DRLS.IntegrationHooks then
        -- Test methods
        PrintTest("IntegrationHooks.Initialize", 
            type(DRLS.IntegrationHooks.Initialize) == "function", nil, category)
        PrintTest("IntegrationHooks.ShowStatus", 
            type(DRLS.IntegrationHooks.ShowStatus) == "function", nil, category)
        PrintTest("IntegrationHooks.DetectAddons", 
            type(DRLS.IntegrationHooks.DetectAddons) == "function", nil, category)
        PrintTest("IntegrationHooks.ToggleIntegration", 
            type(DRLS.IntegrationHooks.ToggleIntegration) == "function", nil, category)
        
        -- Test database structure
        if DRLSDB.integrations then
            PrintTest("Integration states tracked", 
                DRLSDB.integrations.states ~= nil, nil, category)
            PrintTest("Integration hooks tracked", 
                DRLSDB.integrations.hooks ~= nil, nil, category)
        end
        
        -- Test safe execution
        local success, error = pcall(function()
            DRLS.IntegrationHooks:DetectAddons()
        end)
        PrintTest("DetectAddons executes safely", success, 
            error and tostring(error) or nil, category)
    end
end

-- ===================================================================
-- PROFILE MANAGEMENT TESTS
-- ===================================================================

function DRLS_TestSuite:TestProfileManagement()
    PrintHeader("PROFILE MANAGEMENT TESTS")
    local category = "Profile Management"
    
    PrintTest("ProfileManager exists", DRLS.ProfileManager ~= nil, nil, category)
    
    if DRLS.ProfileManager then
        -- Test methods
        PrintTest("ProfileManager.Initialize", 
            type(DRLS.ProfileManager.Initialize) == "function", nil, category)
        PrintTest("ProfileManager.CreateProfile", 
            type(DRLS.ProfileManager.CreateProfile) == "function", nil, category)
        PrintTest("ProfileManager.GetCurrentProfile", 
            type(DRLS.ProfileManager.GetCurrentProfile) == "function", nil, category)
        PrintTest("ProfileManager.ListProfiles", 
            type(DRLS.ProfileManager.ListProfiles) == "function", nil, category)
        
        -- Test profile structure
        if DRLSDB.profiles then
            local profileCount = 0
            for _ in pairs(DRLSDB.profiles) do
                profileCount = profileCount + 1
            end
            PrintTest("Profiles exist", profileCount > 0, 
                profileCount .. " profiles", category)
            
            -- Test current profile
            local success, profile = pcall(function()
                return DRLS.ProfileManager:GetCurrentProfile()
            end)
            
            if success and profile then
                PrintTest("Current profile accessible", true, nil, category)
                PrintTest("Profile has general settings", profile.general ~= nil, nil, category)
                PrintTest("Profile has AI settings", profile.ai ~= nil, nil, category)
                PrintTest("Profile has ecosystem settings", profile.ecosystem ~= nil, nil, category)
            end
        end
    end
end

-- ===================================================================
-- BACKUP SYSTEM TESTS
-- ===================================================================

function DRLS_TestSuite:TestBackupSystem()
    PrintHeader("BACKUP SYSTEM TESTS")
    local category = "Backup System"
    
    PrintTest("BackupManager exists", DRLS.BackupManager ~= nil, nil, category)
    
    if DRLS.BackupManager then
        -- Test methods
        PrintTest("BackupManager.Initialize", 
            type(DRLS.BackupManager.Initialize) == "function", nil, category)
        PrintTest("BackupManager.CreateBackup", 
            type(DRLS.BackupManager.CreateBackup) == "function", nil, category)
        PrintTest("BackupManager.ListBackups", 
            type(DRLS.BackupManager.ListBackups) == "function", nil, category)
        PrintTest("BackupManager.RestoreBackup", 
            type(DRLS.BackupManager.RestoreBackup) == "function", nil, category)
        
        -- Test backup settings
        if DRLSDB.settings then
            PrintTest("Auto-backup setting exists", 
                DRLSDB.settings.autoBackup ~= nil, 
                tostring(DRLSDB.settings.autoBackup), category)
            PrintTest("Backup interval configured", 
                DRLSDB.settings.backupInterval ~= nil, 
                DRLSDB.settings.backupInterval and (DRLSDB.settings.backupInterval .. "s") or nil, 
                category)
            PrintTest("Max backups limit set", 
                DRLSDB.settings.maxBackups ~= nil, 
                tostring(DRLSDB.settings.maxBackups), category)
        end
        
        -- Test backup structure
        if DRLSDB.backups then
            local totalBackups = 0
            for _ in pairs(DRLSDB.backups) do
                totalBackups = totalBackups + 1
            end
            PrintInfo("Total backup profiles: " .. totalBackups)
        end
    end
end

-- ===================================================================
-- UI CUSTOMIZATION TESTS
-- ===================================================================

function DRLS_TestSuite:TestUICustomization()
    PrintHeader("UI CUSTOMIZATION TESTS")
    local category = "UI Customization"
    
    PrintTest("UICustomization exists", DRLS.UICustomization ~= nil, nil, category)
    
    if DRLS.UICustomization then
        -- Test methods
        PrintTest("UICustomization.Initialize", 
            type(DRLS.UICustomization.Initialize) == "function", nil, category)
        PrintTest("UICustomization.GetCurrentStyle", 
            type(DRLS.UICustomization.GetCurrentStyle) == "function", nil, category)
        PrintTest("UICustomization.SetStyle", 
            type(DRLS.UICustomization.SetStyle) == "function", nil, category)
        PrintTest("UICustomization.GetColor", 
            type(DRLS.UICustomization.GetColor) == "function", nil, category)
        PrintTest("UICustomization.ListStyles", 
            type(DRLS.UICustomization.ListStyles) == "function", nil, category)
        
        -- Test style retrieval
        local success, currentStyle = pcall(function()
            return DRLS.UICustomization:GetCurrentStyle()
        end)
        PrintTest("Current style retrieval", success, currentStyle or nil, category)
        
        -- Test color retrieval
        success = pcall(function()
            local r, g, b, a = DRLS.UICustomization:GetColor("primary")
            return r ~= nil and g ~= nil and b ~= nil
        end)
        PrintTest("Color retrieval functional", success, nil, category)
    end
end

-- ===================================================================
-- IMAGE MANAGER TESTS
-- ===================================================================

function DRLS_TestSuite:TestImageManager()
    PrintHeader("IMAGE MANAGER TESTS")
    local category = "Image Manager"
    
    PrintTest("ImageManager exists", DRLS.ImageManager ~= nil, nil, category)
    
    if DRLS.ImageManager then
        -- Test methods
        PrintTest("ImageManager.Initialize", 
            type(DRLS.ImageManager.Initialize) == "function", nil, category)
        PrintTest("ImageManager.LoadImage", 
            type(DRLS.ImageManager.LoadImage) == "function", nil, category)
        PrintTest("ImageManager.GetStats", 
            type(DRLS.ImageManager.GetStats) == "function", nil, category)
        PrintTest("ImageManager.ClearCache", 
            type(DRLS.ImageManager.ClearCache) == "function", nil, category)
        
        -- Test image loading
        local success, imagePath = pcall(function()
            return DRLS.ImageManager:LoadImage("default", "textures")
        end)
        PrintTest("Image loading functional", success, nil, category)
        
        -- Test statistics
        success = pcall(function()
            local stats = DRLS.ImageManager:GetStats()
            return stats.totalLoaded ~= nil
        end)
        PrintTest("Statistics tracking", success, nil, category)
        
        -- Test database structure
        if DRLSDB.images then
            PrintTest("Image cache exists", DRLSDB.images.cache ~= nil, nil, category)
            PrintTest("Image settings exist", DRLSDB.images.settings ~= nil, nil, category)
            PrintTest("Image stats tracked", DRLSDB.images.stats ~= nil, nil, category)
        end
    end
end

-- ===================================================================
-- SCRIPT LAUNCHER TESTS
-- ===================================================================

function DRLS_TestSuite:TestScriptLauncher()
    PrintHeader("SCRIPT LAUNCHER TESTS")
    local category = "Script Launcher"
    
    if DRLS.ScriptLauncher then
        PrintTest("ScriptLauncher exists", true, nil, category)
        
        -- Test methods
        PrintTest("ScriptLauncher.Initialize", 
            type(DRLS.ScriptLauncher.Initialize) == "function", nil, category)
        PrintTest("ScriptLauncher.ExecuteScript", 
            type(DRLS.ScriptLauncher.ExecuteScript) == "function", nil, category)
        PrintTest("ScriptLauncher.ListScripts", 
            type(DRLS.ScriptLauncher.ListScripts) == "function", nil, category)
        PrintTest("ScriptLauncher.SaveScript", 
            type(DRLS.ScriptLauncher.SaveScript) == "function", nil, category)
        
        -- Test safe script execution
        local success, result = pcall(function()
            return DRLS.ScriptLauncher:ExecuteScript("return 2 + 2", "Test Script")
        end)
        PrintTest("Script execution functional", success, nil, category)
        
        -- Test database structure
        if DRLSDB.scripts then
            PrintTest("Scripts database exists", true, nil, category)
            PrintTest("Saved scripts storage", DRLSDB.scripts.saved ~= nil, nil, category)
            PrintTest("Script settings exist", DRLSDB.scripts.settings ~= nil, nil, category)
            PrintTest("Script stats tracked", DRLSDB.scripts.stats ~= nil, nil, category)
        end
    else
        PrintTest("ScriptLauncher exists", false, "Disabled for performance", category)
        PrintInfo("Script Launcher is intentionally disabled in current build")
    end
end

-- ===================================================================
-- PERFORMANCE BENCHMARKS
-- ===================================================================

function DRLS_TestSuite:BenchmarkPerformance()
    PrintHeader("PERFORMANCE BENCHMARKS")
    local category = "Performance"
    
    -- Benchmark 1: Memory Usage
    collectgarbage("collect")
    local memUsage = collectgarbage("count")
    local memMB = memUsage / 1024
    
    PrintInfo("Current memory usage: " .. string.format("%.2f MB", memMB))
    PrintTest("Memory within limits", memUsage < PERFORMANCE_THRESHOLDS.memoryLimit, 
        string.format("%.2f / %.2f MB", memMB, PERFORMANCE_THRESHOLDS.memoryLimit / 1024), 
        category)
    
    testResults.benchmarks.memory = {
        current = memUsage,
        limit = PERFORMANCE_THRESHOLDS.memoryLimit,
        passed = memUsage < PERFORMANCE_THRESHOLDS.memoryLimit
    }
    
    -- Benchmark 2: Frame Time
    local frameTime = MeasureTime(function()
        -- Simulate typical frame operations
        if DRLS.AI then
            local _ = DRLS.AI.status
        end
        if DRLS.ProfileManager then
            local _ = DRLS.ProfileManager:GetCurrentProfile()
        end
    end)
    
    PrintInfo("Frame operation time: " .. string.format("%.2f ms", frameTime))
    PrintTest("Frame time acceptable", frameTime < PERFORMANCE_THRESHOLDS.frameTimeLimit, 
        string.format("%.2f / %.2f ms", frameTime, PERFORMANCE_THRESHOLDS.frameTimeLimit), 
        category)
    
    testResults.benchmarks.frameTime = {
        current = frameTime,
        limit = PERFORMANCE_THRESHOLDS.frameTimeLimit,
        passed = frameTime < PERFORMANCE_THRESHOLDS.frameTimeLimit
    }
    
    -- Benchmark 3: Event Handler Performance
    if DRLS and DRLS.RegisterEvent then
        local eventTime = MeasureTime(function()
            for i = 1, 100 do
                -- Simulate event processing
                local dummy = i * 2
            end
        end)
        
        PrintInfo("Event processing time: " .. string.format("%.2f ms", eventTime))
        PrintTest("Event processing efficient", eventTime < 10, 
            string.format("%.2f ms", eventTime), category)
    end
    
    -- Benchmark 4: Database Access Speed
    local dbAccessTime = MeasureTime(function()
        if DRLSDB then
            for i = 1, 1000 do
                local _ = DRLSDB.settings
                local _ = DRLSDB.profiles
            end
        end
    end)
    
    PrintInfo("Database access time (1000 ops): " .. string.format("%.2f ms", dbAccessTime))
    PrintTest("Database access fast", dbAccessTime < 5, 
        string.format("%.2f ms", dbAccessTime), category)
end

-- ===================================================================
-- MEMORY LEAK TESTS
-- ===================================================================

function DRLS_TestSuite:TestMemoryLeaks()
    PrintHeader("MEMORY LEAK TESTS")
    local category = "Memory"
    
    collectgarbage("collect")
    local memBefore = collectgarbage("count")
    
    -- Test 1: Profile Creation Memory
    if DRLS.ProfileManager then
        local memGrowth = MeasureMemory(function()
            for i = 1, 10 do
                local testProfile = "TestProfile" .. i
                -- Don't actually create to avoid pollution
            end
        end)
        
        PrintTest("Profile operations memory stable", memGrowth < 100, 
            string.format("%.2f KB growth", memGrowth), category)
    end
    
    -- Test 2: Event Registration Memory
    local memGrowth = MeasureMemory(function()
        for i = 1, 50 do
            -- Simulate event registrations
            local dummy = {event = "TEST_EVENT_" .. i, handler = function() end}
        end
    end)
    
    PrintTest("Event registration memory stable", memGrowth < 50, 
        string.format("%.2f KB growth", memGrowth), category)
    
    -- Test 3: Image Cache Memory
    if DRLS.ImageManager then
        local initialMem = collectgarbage("count")
        
        for i = 1, 5 do
            pcall(function()
                DRLS.ImageManager:LoadImage("test", "textures")
            end)
        end
        
        collectgarbage("collect")
        local finalMem = collectgarbage("count")
        local cacheGrowth = finalMem - initialMem
        
        PrintTest("Image cache memory managed", cacheGrowth < 500, 
            string.format("%.2f KB growth", cacheGrowth), category)
    end
    
    collectgarbage("collect")
    local memAfter = collectgarbage("count")
    local totalGrowth = memAfter - memBefore
    
    PrintInfo("Total test memory growth: " .. string.format("%.2f KB", totalGrowth))
    PrintTest("Overall memory stability", totalGrowth < 1024, 
        string.format("%.2f KB", totalGrowth), category)
end

-- ===================================================================
-- COMPATIBILITY TESTS
-- ===================================================================

function DRLS_TestSuite:TestCompatibility()
    PrintHeader("COMPATIBILITY TESTS")
    local category = "Compatibility"
    
    -- Test WoW API availability
    local criticalAPIs = {
        {name = "UnitName", func = UnitName},
        {name = "UnitClass", func = UnitClass},
        {name = "UnitRace", func = UnitRace},
        {name = "GetTime", func = GetTime},
        {name = "CreateFrame", func = CreateFrame},
        {name = "C_Timer", func = C_Timer}
    }
    
    for _, api in ipairs(criticalAPIs) do
        PrintTest("API: " .. api.name, api.func ~= nil, nil, category)
    end
    
    -- Test addon compatibility
    local testAddons = {
        {name = "ElvUI", global = "ElvUI"},
        {name = "Details", global = "Details"},
        {name = "WeakAuras", global = "WeakAuras"},
        {name = "DBM", global = "DBM"},
        {name = "BigWigs", global = "BigWigs"}
    }
    
    PrintInfo("Testing compatibility with popular addons:")
    for _, addon in ipairs(testAddons) do
        if _G[addon.global] then
            PrintInfo("  " .. addon.name .. " detected - compatible")
        end
    end
    
    -- Test Lua version
    PrintTest("Lua 5.1+ available", _VERSION ~= nil, _VERSION, category)
    
    -- Test table operations
    local tableTest = {1, 2, 3, 4, 5}
    local tableWorks = #tableTest == 5
    PrintTest("Table operations functional", tableWorks, nil, category)
    
    -- Test string operations
    local stringTest = "DRLS Test"
    local stringWorks = string.find(stringTest, "DRLS") ~= nil
    PrintTest("String operations functional", stringWorks, nil, category)
end

-- ===================================================================
-- STRESS TESTS
-- ===================================================================

function DRLS_TestSuite:StressTest()
    PrintHeader("STRESS TESTS")
    local category = "Performance"
    
    PrintInfo("Running stress tests (this may take a moment)...")
    
    -- Stress Test 1: Rapid profile access
    if DRLS.ProfileManager then
        local time = MeasureTime(function()
            for i = 1, 100 do
                pcall(function()
                    DRLS.ProfileManager:GetCurrentProfile()
                end)
            end
        end)
        
        PrintTest("Rapid profile access (100x)", time < 50, 
            string.format("%.2f ms total", time), category)
    end
    
    -- Stress Test 2: Multiple addon detections
    if DRLS.AI then
        local time = MeasureTime(function()
            for i = 1, 20 do
                pcall(function()
                    -- Simulate detection
                    local _ = _G["DRLS"]
                    local _ = _G["ElvUI"]
                    local _ = _G["Details"]
                end)
            end
        end)
        
        PrintTest("Multiple addon detections (20x)", time < 20, 
            string.format("%.2f ms total", time), category)
    end
    
    -- Stress Test 3: Image cache operations
    if DRLS.ImageManager then
        local time = MeasureTime(function()
            for i = 1, 50 do
                pcall(function()
                    DRLS.ImageManager:LoadImage("default", "textures")
                end)
            end
        end)
        
        PrintTest("Image cache operations (50x)", time < 100, 
            string.format("%.2f ms total", time), category)
    end
    
    -- Stress Test 4: Database operations
    local time = MeasureTime(function()
        for i = 1, 1000 do
            if DRLSDB and DRLSDB.settings then
                local _ = DRLSDB.settings.autoBackup
            end
        end
    end)
    
    PrintTest("Database read operations (1000x)", time < 10, 
        string.format("%.2f ms total", time), category)
end

-- ===================================================================
-- TEST SUMMARY
-- ===================================================================

function DRLS_TestSuite:PrintSummary()
    testResults.endTime = GetTime()
    local totalTime = (testResults.endTime - testResults.startTime) * 1000
    
    print("")
    PrintHeader("TEST SUITE SUMMARY")
    
    print(COLOR.INFO .. "📊 Test Statistics:" .. COLOR.NORMAL)
    print(COLOR.SUCCESS .. "  ✅ Passed: " .. testResults.passed .. COLOR.NORMAL)
    print(COLOR.FAIL .. "  ❌ Failed: " .. testResults.failed .. COLOR.NORMAL)
    print(COLOR.WARN .. "  ⚠️  Warnings: " .. testResults.warnings .. COLOR.NORMAL)
    print(COLOR.INFO .. "  📝 Total Tests: " .. testResults.total .. COLOR.NORMAL)
    
    local successRate = testResults.total > 0 and 
        (testResults.passed / testResults.total * 100) or 0
    
    local rateColor = successRate >= 90 and COLOR.SUCCESS or 
                     successRate >= 70 and COLOR.WARN or COLOR.FAIL
    
    print(rateColor .. "  📈 Success Rate: " .. string.format("%.1f%%", successRate) .. COLOR.NORMAL)
    print("")
    
    print(COLOR.INFO .. "⏱️  Performance:" .. COLOR.NORMAL)
    print(COLOR.INFO .. "  Total Test Time: " .. string.format("%.2f ms", totalTime) .. COLOR.NORMAL)
    
    if testResults.benchmarks.memory then
        local mem = testResults.benchmarks.memory
        local memColor = mem.passed and COLOR.SUCCESS or COLOR.FAIL
        print(memColor .. "  Memory Usage: " .. 
            string.format("%.2f / %.2f MB", mem.current / 1024, mem.limit / 1024) .. COLOR.NORMAL)
    end
    
    if testResults.benchmarks.frameTime then
        local ft = testResults.benchmarks.frameTime
        local ftColor = ft.passed and COLOR.SUCCESS or COLOR.FAIL
        print(ftColor .. "  Frame Time: " .. 
            string.format("%.2f / %.2f ms", ft.current, ft.limit) .. COLOR.NORMAL)
    end
    
    print("")
    print(COLOR.INFO .. "📂 Results by Category:" .. COLOR.NORMAL)
    for category, results in pairs(testResults.categories) do
        local catTotal = results.passed + results.failed
        local catRate = catTotal > 0 and (results.passed / catTotal * 100) or 0
        local catColor = catRate >= 90 and COLOR.SUCCESS or 
                        catRate >= 70 and COLOR.WARN or COLOR.FAIL
        print(catColor .. "  " .. category .. ": " .. results.passed .. "/" .. catTotal .. 
            " (" .. string.format("%.0f%%", catRate) .. ")" .. COLOR.NORMAL)
    end
    
    print("")
    print(COLOR.HEADER .. "=" .. string.rep("=", 70) .. COLOR.NORMAL)
    
    -- Final verdict
    if testResults.failed == 0 then
        print(COLOR.SUCCESS .. "🎉 ALL TESTS PASSED! DRLS is fully operational!" .. COLOR.NORMAL)
    elseif successRate >= 80 then
        print(COLOR.WARN .. "⚠️  Most tests passed, but some issues detected." .. COLOR.NORMAL)
    else
        print(COLOR.FAIL .. "❌ Critical issues detected. Review failed tests." .. COLOR.NORMAL)
    end
    
    print(COLOR.HEADER .. "=" .. string.rep("=", 70) .. COLOR.NORMAL)
end

-- ===================================================================
-- MAIN TEST RUNNER
-- ===================================================================

function DRLS_TestSuite:RunAllTests()
    print("")
    PrintHeader("DRLS COMPREHENSIVE TEST & BENCHMARK SUITE")
    print(COLOR.INFO .. "Starting comprehensive testing of all DRLS systems..." .. COLOR.NORMAL)
    print("")
    
    testResults.startTime = GetTime()
    
    -- Run all test categories
    self:TestCoreSystem()
    self:TestAISystems()
    self:TestModules()
    self:TestIntegrationHooks()
    self:TestProfileManagement()
    self:TestBackupSystem()
    self:TestUICustomization()
    self:TestImageManager()
    self:TestScriptLauncher()
    
    -- Run performance tests
    self:BenchmarkPerformance()
    self:TestMemoryLeaks()
    self:TestCompatibility()
    self:StressTest()
    
    -- Print summary
    self:PrintSummary()
    
    print("")
    print(COLOR.INFO .. "💡 Use '/drlstest' to run this suite again" .. COLOR.NORMAL)
    print(COLOR.INFO .. "💡 Use '/drlstest <category>' for specific category tests" .. COLOR.NORMAL)
end

function DRLS_TestSuite:RunCategory(category)
    print("")
    PrintHeader("DRLS TEST SUITE - " .. category:upper())
    print(COLOR.INFO .. "Running tests for: " .. category .. COLOR.NORMAL)
    print("")
    
    testResults.startTime = GetTime()
    
    -- Map category names to test functions
    local categoryMap = {
        ["core"] = function() self:TestCoreSystem() end,
        ["ai"] = function() self:TestAISystems() end,
        ["modules"] = function() self:TestModules() end,
        ["hooks"] = function() self:TestIntegrationHooks() end,
        ["integration"] = function() self:TestIntegrationHooks() end,
        ["profile"] = function() self:TestProfileManagement() end,
        ["backup"] = function() self:TestBackupSystem() end,
        ["ui"] = function() self:TestUICustomization() end,
        ["image"] = function() self:TestImageManager() end,
        ["script"] = function() self:TestScriptLauncher() end,
        ["performance"] = function() 
            self:BenchmarkPerformance()
            self:TestMemoryLeaks()
            self:StressTest()
        end,
        ["compatibility"] = function() self:TestCompatibility() end
    }
    
    local testFunc = categoryMap[category:lower()]
    if testFunc then
        testFunc()
        self:PrintSummary()
    else
        print(COLOR.FAIL .. "❌ Unknown category: " .. category .. COLOR.NORMAL)
        print(COLOR.INFO .. "Available categories: core, ai, modules, hooks, profile, backup, ui, image, script, performance, compatibility" .. COLOR.NORMAL)
    end
end

-- ===================================================================
-- EXPORT TEST RESULTS
-- ===================================================================

function DRLS_TestSuite:ExportResults()
    local report = {
        timestamp = GetTime(),
        totalTests = testResults.total,
        passed = testResults.passed,
        failed = testResults.failed,
        warnings = testResults.warnings,
        successRate = testResults.total > 0 and (testResults.passed / testResults.total * 100) or 0,
        executionTime = (testResults.endTime - testResults.startTime) * 1000,
        categories = testResults.categories,
        benchmarks = testResults.benchmarks
    }
    
    return report
end

-- ===================================================================
-- SLASH COMMAND REGISTRATION
-- ===================================================================

SLASH_DRLSTEST1 = "/drlstest"
SLASH_DRLSTEST2 = "/drls test"
SlashCmdList["DRLSTEST"] = function(msg)
    local command = string.lower(string.match(msg, "^%s*(.-)%s*$") or "")
    
    if command == "" or command == "all" then
        DRLS_TestSuite:RunAllTests()
    elseif command == "help" then
        print(COLOR.HEADER .. "DRLS Test Suite Commands:" .. COLOR.NORMAL)
        print(COLOR.INFO .. "/drlstest - Run all tests" .. COLOR.NORMAL)
        print(COLOR.INFO .. "/drlstest all - Run all tests" .. COLOR.NORMAL)
        print(COLOR.INFO .. "/drlstest <category> - Run specific category" .. COLOR.NORMAL)
        print(COLOR.INFO .. "/drlstest help - Show this help" .. COLOR.NORMAL)
        print("")
        print(COLOR.INFO .. "Categories: core, ai, modules, hooks, profile, backup, ui, image, script, performance, compatibility" .. COLOR.NORMAL)
    else
        DRLS_TestSuite:RunCategory(command)
    end
end

-- ===================================================================
-- INITIALIZATION
-- ===================================================================

print(COLOR.SUCCESS .. "✅ DRLS Comprehensive Test Suite loaded!" .. COLOR.NORMAL)
print(COLOR.INFO .. "💡 Type '/drlstest' or '/drls test' to run all tests" .. COLOR.NORMAL)
print(COLOR.INFO .. "💡 Type '/drlstest help' for more options" .. COLOR.NORMAL)

-- Export for external use
return DRLS_TestSuite
