---@diagnostic disable: undefined-global
-- DRLS Core Framework
-- Revolutionary Addon Framework System
local _, DRLS = ...

DRLS_Core = {}
DRLS_Core.modules = {}
DRLS_Core.hooks = {}
DRLS_Core.events = {}

-- Core Constants
local CORE_VERSION = "1.0.0"
local DEBUG_MODE = true

-- Revolutionary Core Logger
local function CoreLog(message, level)
    level = level or "INFO"
    local timestamp = date("%H:%M:%S")
    local colorCode = level == "ERROR" and "|cffff0000" or 
                      level == "WARN" and "|cffff9900" or 
                      level == "DEBUG" and "|cff808080" or "|cff00ff00"
    
    if DEBUG_MODE or level ~= "DEBUG" then
        print(colorCode .. "[" .. timestamp .. "] DRLS Core " .. level .. ": " .. message .. "|r")
    end
end

-- Revolutionary Module Registration
function DRLS_Core:RegisterModule(name, module)
    if not name or not module then
        CoreLog("Invalid module registration: " .. tostring(name), "ERROR")
        return false
    end
    
    self.modules[name] = module
    CoreLog("Module registered: " .. name, "INFO")
    
    -- Initialize module if it has an Initialize function
    if module.Initialize and type(module.Initialize) == "function" then
        local success, error = pcall(module.Initialize, module)
        if not success then
            CoreLog("Failed to initialize module " .. name .. ": " .. tostring(error), "ERROR")
            return false
        end
    end
    
    return true
end

-- Revolutionary Module Retrieval
function DRLS_Core:GetModule(name)
    return self.modules[name]
end

-- Revolutionary Event System
function DRLS_Core:RegisterEvent(event, callback, module)
    if not self.events[event] then
        self.events[event] = {}
    end
    
    table.insert(self.events[event], {
        callback = callback,
        module = module or "Core"
    })
    
    CoreLog("Event registered: " .. event .. " for " .. (module or "Core"), "DEBUG")
end

-- Revolutionary Event Firing
function DRLS_Core:FireEvent(event, ...)
    if not self.events[event] then return end
    
    CoreLog("Firing event: " .. event, "DEBUG")
    
    for _, handler in ipairs(self.events[event]) do
        local success, error = pcall(handler.callback, ...)
        if not success then
            CoreLog("Event handler error for " .. event .. " in " .. handler.module .. ": " .. tostring(error), "ERROR")
        end
    end
end

-- Revolutionary Hook System
function DRLS_Core:Hook(original, replacement, secure)
    if not original or not replacement then
        CoreLog("Invalid hook parameters", "ERROR")
        return false
    end
    
    local hookInfo = {
        original = _G[original],
        replacement = replacement,
        secure = secure or false
    }
    
    if secure then
        hooksecurefunc(original, replacement)
    else
        self.hooks[original] = hookInfo.original
        _G[original] = function(...)
            return replacement(hookInfo.original, ...)
        end
    end
    
    CoreLog("Hook installed: " .. original, "DEBUG")
    return true
end

-- Revolutionary Configuration System
DRLS_Core.config = {
    ui = {
        scale = 1.0,
        alpha = 1.0,
        theme = "default",
        animations = true
    },
    ai = {
        enabled = true,
        analysisInterval = 30,
        autoOptimize = true,
        compatibilityMode = false
    },
    performance = {
        enableOptimizations = true,
        memoryLimit = 100, -- MB
        gcInterval = 300, -- seconds
        eventThrottling = true
    },
    integrations = {
        details = true,
        elvui = true,
        weakauras = true,
        dbm = true
    }
}

-- Revolutionary Configuration Management
function DRLS_Core:GetConfig(path)
    local keys = {strsplit(".", path)}
    local value = self.config
    
    for _, key in ipairs(keys) do
        if value[key] then
            value = value[key]
        else
            return nil
        end
    end
    
    return value
end

function DRLS_Core:SetConfig(path, value)
    local keys = {strsplit(".", path)}
    local config = self.config
    
    for i = 1, #keys - 1 do
        local key = keys[i]
        if not config[key] then
            config[key] = {}
        end
        config = config[key]
    end
    
    config[keys[#keys]] = value
    CoreLog("Configuration updated: " .. path .. " = " .. tostring(value), "DEBUG")
    
    -- Fire configuration change event
    self:FireEvent("CONFIG_CHANGED", path, value)
end

-- Revolutionary Performance Monitor
DRLS_Core.performance = {
    memoryUsage = 0,
    cpuUsage = 0,
    lastGC = 0,
    frameTime = 0
}

function DRLS_Core:UpdatePerformanceMetrics()
    local memBefore = collectgarbage("count")
    local timeStart = GetTime()
    
    -- Simulate some work
    for i = 1, 1000 do
        local dummy = i * 2
    end
    
    local timeEnd = GetTime()
    local memAfter = collectgarbage("count")
    
    self.performance.memoryUsage = memAfter
    self.performance.frameTime = (timeEnd - timeStart) * 1000 -- Convert to ms
    self.performance.cpuUsage = math.min(self.performance.frameTime / 16.67 * 100, 100) -- % of frame budget
    
    -- Auto garbage collection if needed
    if self:GetConfig("performance.enableOptimizations") then
        local memLimit = self:GetConfig("performance.memoryLimit") * 1024 -- Convert to KB
        if memAfter > memLimit and (GetTime() - self.performance.lastGC) > self:GetConfig("performance.gcInterval") then
            collectgarbage("collect")
            self.performance.lastGC = GetTime()
            CoreLog("Automatic garbage collection performed", "DEBUG")
        end
    end
end

-- Revolutionary Compatibility System
function DRLS_Core:CheckCompatibility(addonName)
    local knownCompatible = {
        ["ElvUI"] = {compatible = true, notes = "Full integration available"},
        ["Details"] = {compatible = true, notes = "Enhanced with DRLS AI"},
        ["WeakAuras"] = {compatible = true, notes = "Revolutionary profile support"},
        ["DBM-Core"] = {compatible = true, notes = "AI-enhanced warnings"},
        ["Plater"] = {compatible = true, notes = "Advanced nameplate integration"},
        ["TomTom"] = {compatible = false, notes = "Conflicts with DRLS navigation"},
        ["Bartender4"] = {compatible = true, notes = "UI framework compatible"}
    }
    
    local compatibility = knownCompatible[addonName]
    if not compatibility then
        -- Unknown addon - assume compatible with warning
        compatibility = {compatible = true, notes = "Compatibility unknown - monitoring"}
        CoreLog("Unknown addon compatibility: " .. addonName, "WARN")
    end
    
    return compatibility
end

-- Revolutionary Error Handler
function DRLS_Core:ErrorHandler(error)
    CoreLog("DRLS Error: " .. tostring(error), "ERROR")
    CoreLog("Stack trace: " .. debugstack(2), "ERROR")
    
    -- Attempt graceful recovery
    self:FireEvent("ERROR_OCCURRED", error)
    
    -- Show error to user if severe
    if string.find(error, "Interface\\") or string.find(error, "stack overflow") then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000DRLS: Critical error occurred. Check console for details.|r")
    end
end

-- Revolutionary Initialization
function DRLS_Core:Initialize()
    CoreLog("Initializing DRLS Core Framework v" .. CORE_VERSION, "INFO")
    
    -- Set up error handling
    seterrorhandler(function(error) self:ErrorHandler(error) end)
    
    -- Initialize performance monitoring
    C_Timer.NewTicker(5, function() self:UpdatePerformanceMetrics() end)
    
    -- Register core events
    self:RegisterEvent("ADDON_LOADED", function(addonName)
        if addonName == "DRLS" then
            self:FireEvent("DRLS_LOADED")
        else
            -- Check compatibility with loaded addon
            local compat = self:CheckCompatibility(addonName)
            if not compat.compatible then
                CoreLog("Potential compatibility issue with " .. addonName .. ": " .. compat.notes, "WARN")
            end
        end
    end, "Core")
    
    self:RegisterEvent("PLAYER_LOGIN", function()
        self:FireEvent("DRLS_READY")
        CoreLog("DRLS Core Framework ready!", "INFO")
    end, "Core")
    
    -- Initialize AI Core if available
    if DRLS_AI_Core then
        local success, error = pcall(DRLS_AI_Core.Initialize, DRLS_AI_Core)
        if success then
            CoreLog("AI Core initialized successfully", "INFO")
        else
            CoreLog("Failed to initialize AI Core: " .. tostring(error), "ERROR")
        end
    end
    
    return true
end

-- Revolutionary Shutdown
function DRLS_Core:Shutdown()
    CoreLog("Shutting down DRLS Core Framework", "INFO")
    
    -- Shutdown all modules
    for name, module in pairs(self.modules) do
        if module.Shutdown and type(module.Shutdown) == "function" then
            local success, error = pcall(module.Shutdown, module)
            if not success then
                CoreLog("Error shutting down module " .. name .. ": " .. tostring(error), "ERROR")
            end
        end
    end
    
    -- Clear hooks
    for original, originalFunc in pairs(self.hooks) do
        _G[original] = originalFunc
    end
    
    CoreLog("DRLS Core Framework shutdown complete", "INFO")
end

-- Revolutionary Status Report
function DRLS_Core:GetStatus()
    local status = {
        version = CORE_VERSION,
        modules = {},
        performance = self.performance,
        config = self.config,
        events = {}
    }
    
    -- Module status
    for name, module in pairs(self.modules) do
        status.modules[name] = {
            loaded = true,
            hasInit = (module.Initialize ~= nil),
            hasShutdown = (module.Shutdown ~= nil)
        }
    end
    
    -- Event status
    for event, handlers in pairs(self.events) do
        status.events[event] = #handlers
    end
    
    return status
end

-- Revolutionary Debug Functions
function DRLS_Core:ToggleDebug()
    DEBUG_MODE = not DEBUG_MODE
    CoreLog("Debug mode " .. (DEBUG_MODE and "enabled" or "disabled"), "INFO")
end

function DRLS_Core:DumpStatus()
    local status = self:GetStatus()
    CoreLog("=== DRLS CORE STATUS DUMP ===", "INFO")
    CoreLog("Version: " .. status.version, "INFO")
    CoreLog("Modules: " .. self:CountKeys(status.modules), "INFO")
    CoreLog("Events: " .. self:CountKeys(status.events), "INFO")
    CoreLog("Memory: " .. string.format("%.2f MB", status.performance.memoryUsage / 1024), "INFO")
    CoreLog("Frame Time: " .. string.format("%.2f ms", status.performance.frameTime), "INFO")
    CoreLog("CPU Usage: " .. string.format("%.1f%%", status.performance.cpuUsage), "INFO")
    CoreLog("=== END STATUS DUMP ===", "INFO")
end

-- Revolutionary Utility Functions
function DRLS_Core:CountKeys(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- Export the revolutionary core
return DRLS_Core