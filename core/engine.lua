--[[
    DRGUI Engine - Ultimate UI Framework
    
    This is the core engine that replaces and upgrades ElvUI's functionality.
    Enhanced for future WoW expansions with modern architecture.
    
    Features:
    - Advanced module system
    - Future-proof API handling
    - Enhanced performance optimization
    - Comprehensive error handling
    - Live configuration system
]]

local _G = _G
local type, tostring, tonumber = type, tostring, tonumber
local strsplit, gsub, tinsert, next = strsplit, gsub, tinsert, next
local wipe, pairs, ipairs = wipe, pairs, ipairs
local GetTime, GetBuildInfo, GetLocale = GetTime, GetBuildInfo, GetLocale
local CreateFrame, UIParent = CreateFrame, UIParent
local ReloadUI = ReloadUI

-- API Compatibility Layer for Future Expansions
local C_AddOns = C_AddOns or {}
local C_CVar = C_CVar or {}
local C_Timer = C_Timer or {}

local DisableAddOn = C_AddOns.DisableAddOn or DisableAddOn
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local GetCVar = C_CVar.GetCVar or GetCVar
local SetCVar = C_CVar.SetCVar or SetCVar

-- Initialize DRGUI namespace
local AddOnName, Engine = ...
_G.DRGUI = _G.DRGUI or {}
local DRGUI = _G.DRGUI

-- Core Engine Properties
DRGUI.version = "2.0.0"
DRGUI.build = GetBuildInfo()
DRGUI.locale = GetLocale()
DRGUI.initialized = false
DRGUI.modules = {}
DRGUI.callbacks = {}
DRGUI.events = {}
DRGUI.timers = {}
DRGUI.hooks = {}

-- Database System
DRGUI.db = {
    profile = {},
    global = {},
    char = {}
}

-- Enhanced defaults structure
DRGUI.defaults = {
    profile = {
        general = {
            version = "2.0.0",
            loginMessage = true,
            autoScale = true,
            uiScale = 1.0,
            pixelPerfect = true,
            theme = "default"
        },
        actionbars = {
            enable = true,
            bar1 = {
                enabled = true,
                buttons = 12,
                buttonsPerRow = 12,
                size = 32,
                spacing = 2,
                point = "BOTTOM",
                x = 0,
                y = 4
            },
            bar2 = {
                enabled = true,
                buttons = 12,
                buttonsPerRow = 12,
                size = 32,
                spacing = 2,
                point = "BOTTOM", 
                x = 0,
                y = 40
            },
            bar3 = {
                enabled = false,
                buttons = 12,
                buttonsPerRow = 12,
                size = 32,
                spacing = 2,
                point = "BOTTOM",
                x = 0,
                y = 76
            },
            petbar = {
                enabled = true,
                size = 32,
                spacing = 2,
                point = "BOTTOM",
                x = -200,
                y = 4
            },
            stancebar = {
                enabled = true,
                size = 32,
                spacing = 2,
                point = "BOTTOM", 
                x = 200,
                y = 4
            }
        },
        unitframes = {
            enable = true,
            player = {
                enable = true,
                width = 200,
                height = 60,
                point = "BOTTOM",
                x = -300,
                y = 150
            },
            target = {
                enable = true,
                width = 200,
                height = 60,
                point = "BOTTOM",
                x = 300,
                y = 150
            },
            party = {
                enable = true,
                width = 150,
                height = 40,
                point = "LEFT",
                x = 20,
                y = 0
            },
            raid = {
                enable = true,
                width = 100,
                height = 30,
                point = "TOPLEFT",
                x = 20,
                y = -20
            }
        },
        nameplates = {
            enable = true,
            showFriendly = false,
            showEnemies = true,
            width = 120,
            height = 12,
            castbarHeight = 8
        },
        chat = {
            enable = true,
            panels = 2,
            panelWidth = 400,
            panelHeight = 150,
            fontSize = 12,
            font = "Expressway"
        },
        minimap = {
            enable = true,
            size = 200,
            point = "TOPRIGHT",
            x = -20,
            y = -20
        }
    },
    global = {
        profileKeys = {},
        profiles = {}
    }
}

-- Performance Optimization System
DRGUI.performance = {
    framerate = 0,
    memory = 0,
    updateThrottle = 0.1,
    lastUpdate = 0
}

-- Error Handling System
function DRGUI:HandleError(err, module)
    local errorMsg = string.format("DRGUI Error in %s: %s", module or "Core", tostring(err))
    print("|cffff0000" .. errorMsg .. "|r")
    
    if DRGUI.db.profile.general.debugMode then
        local trace = debugstack(2)
        print("|cffff9999Stack Trace:|r")
        print(trace)
    end
end

-- Enhanced Print Function
function DRGUI:Print(...)
    local args = {...}
    local message = ""
    
    for i = 1, #args do
        message = message .. tostring(args[i])
        if i < #args then
            message = message .. " "
        end
    end
    
    print("|cff1784d1DRGUI:|r " .. message)
end

-- Debug Print Function
function DRGUI:Debug(...)
    if DRGUI.db.profile.general.debugMode then
        self:Print("[DEBUG]", ...)
    end
end

-- Module Registration System
function DRGUI:RegisterModule(name, module)
    if not name or not module then
        self:HandleError("Invalid module registration", "Core")
        return false
    end
    
    if self.modules[name] then
        self:Debug("Module", name, "already registered, overwriting")
    end
    
    self.modules[name] = module
    module.name = name
    module.enabled = true
    
    -- Set up module methods
    module.Print = function(...) self:Print(...) end
    module.Debug = function(...) self:Debug(...) end
    module.HandleError = function(err) self:HandleError(err, name) end
    
    self:Debug("Registered module:", name)
    return true
end

-- Module Loading System
function DRGUI:LoadModule(name)
    local module = self.modules[name]
    if not module then
        self:HandleError("Module not found: " .. tostring(name), "Core")
        return false
    end
    
    if module.loaded then
        self:Debug("Module", name, "already loaded")
        return true
    end
    
    local success, err = pcall(function()
        if module.OnInitialize then
            module:OnInitialize()
        end
    end)
    
    if not success then
        self:HandleError("Failed to load module " .. name .. ": " .. tostring(err), "Core")
        return false
    end
    
    module.loaded = true
    self:Debug("Loaded module:", name)
    return true
end

-- Event System
function DRGUI:RegisterEvent(event, callback, module)
    if not self.events[event] then
        self.events[event] = {}
    end
    
    local handler = {
        callback = callback,
        module = module or "Core"
    }
    
    tinsert(self.events[event], handler)
    
    -- Register with WoW's event system if this is the first handler
    if #self.events[event] == 1 then
        if not self.eventFrame then
            self.eventFrame = CreateFrame("Frame")
        end
        self.eventFrame:RegisterEvent(event)
    end
end

function DRGUI:FireEvent(event, ...)
    local handlers = self.events[event]
    if not handlers then return end
    
    for _, handler in ipairs(handlers) do
        local success, err = pcall(handler.callback, ...)
        if not success then
            self:HandleError("Event handler error for " .. event .. ": " .. tostring(err), handler.module)
        end
    end
end

-- Timer System
function DRGUI:ScheduleTimer(callback, delay, module)
    local timer = {
        callback = callback,
        executeTime = GetTime() + delay,
        module = module or "Core"
    }
    
    tinsert(self.timers, timer)
    return timer
end

function DRGUI:CancelTimer(timer)
    for i, t in ipairs(self.timers) do
        if t == timer then
            table.remove(self.timers, i)
            return true
        end
    end
    return false
end

-- Configuration System
function DRGUI:GetConfig(path)
    local config = self.db.profile
    if not path then return config end
    
    local keys = {strsplit(".", path)}
    for _, key in ipairs(keys) do
        if type(config) ~= "table" or config[key] == nil then
            return nil
        end
        config = config[key]
    end
    
    return config
end

function DRGUI:SetConfig(path, value)
    local config = self.db.profile
    local keys = {strsplit(".", path)}
    
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(config[key]) ~= "table" then
            config[key] = {}
        end
        config = config[key]
    end
    
    config[keys[#keys]] = value
    
    -- Fire config changed event
    self:FireEvent("DRGUI_CONFIG_CHANGED", path, value)
end

-- Initialization
function DRGUI:Initialize()
    if self.initialized then return end
    
    self:Print("Initializing DRGUI v" .. self.version)
    
    -- Initialize database
    self:InitializeDatabase()
    
    -- Load all registered modules
    for name, module in pairs(self.modules) do
        self:LoadModule(name)
    end
    
    -- Set up event frame
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            self:FireEvent(event, ...)
        end)
    end
    
    -- Set up update frame for timers and performance monitoring
    self.updateFrame = CreateFrame("Frame")
    self.updateFrame:SetScript("OnUpdate", function()
        self:OnUpdate()
    end)
    
    self.initialized = true
    self:Print("Initialization complete!")
    
    -- Fire initialization event
    self:FireEvent("DRGUI_INITIALIZED")
end

-- Database Initialization
function DRGUI:InitializeDatabase()
    -- Initialize saved variables if they don't exist
    if not _G.DRGUIDB then
        _G.DRGUIDB = {}
    end
    
    if not _G.DRGUIPrivateDB then
        _G.DRGUIPrivateDB = {}
    end
    
    if not _G.DRGUICharacterDB then
        _G.DRGUICharacterDB = {}
    end
    
    -- Set up database references
    self.db.profile = _G.DRGUIDB
    self.db.global = _G.DRGUIPrivateDB
    self.db.char = _G.DRGUICharacterDB
    
    -- Apply defaults
    self:ApplyDefaults(self.db.profile, self.defaults.profile)
    self:ApplyDefaults(self.db.global, self.defaults.global)
    
    self:Debug("Database initialized")
end

-- Apply default values to database
function DRGUI:ApplyDefaults(db, defaults)
    for key, value in pairs(defaults) do
        if db[key] == nil then
            if type(value) == "table" then
                db[key] = {}
                self:ApplyDefaults(db[key], value)
            else
                db[key] = value
            end
        elseif type(value) == "table" and type(db[key]) == "table" then
            self:ApplyDefaults(db[key], value)
        end
    end
end

-- Update loop for timers and performance monitoring
function DRGUI:OnUpdate()
    local currentTime = GetTime()
    
    -- Process timers
    for i = #self.timers, 1, -1 do
        local timer = self.timers[i]
        if currentTime >= timer.executeTime then
            local success, err = pcall(timer.callback)
            if not success then
                self:HandleError("Timer callback error: " .. tostring(err), timer.module)
            end
            table.remove(self.timers, i)
        end
    end
    
    -- Update performance metrics (throttled)
    if currentTime - self.performance.lastUpdate >= self.performance.updateThrottle then
        self.performance.framerate = GetFramerate()
        self.performance.memory = collectgarbage("count")
        self.performance.lastUpdate = currentTime
    end
end

-- Export engine to global namespace
Engine[1] = DRGUI
_G.DRGUI = DRGUI

-- Auto-initialize when this file loads
DRGUI:Initialize()