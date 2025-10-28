---@diagnostic disable: undefined-global
-- DRLS Library Manager
-- Revolutionary library integration and management system

local DRLS_LibManager = {}

-- Library Constants
local LIB_VERSION = "1.0.0"
local SUPPORTED_LIBS = {
    -- Essential WoW Libraries
    "AceAddon-3.0",
    "AceConsole-3.0", 
    "AceConfig-3.0",
    "AceConfigDialog-3.0",
    "AceDB-3.0",
    "AceDBOptions-3.0",
    "AceEvent-3.0",
    "AceHook-3.0",
    "AceLocale-3.0",
    "AceTimer-3.0",
    "AceComm-3.0",
    "AceSerializer-3.0",
    "AceGUI-3.0",
    
    -- Advanced Libraries
    "LibStub",
    "LibSharedMedia-3.0",
    "LibDataBroker-1.1",
    "LibDBIcon-1.0",
    "LibDualSpec-1.0",
    "LibWindow-1.1",
    "LibDropdown-1.0",
    "LibDeflate",
    "LibCompress"
}

-- Library Status Tracking
local libraryStatus = {}
local loadedLibraries = {}
local libraryHooks = {}

-- Revolutionary Library Logger
local function LibLog(message, level)
    level = level or "INFO"
    local timestamp = date("%H:%M:%S")
    local colorCode = level == "ERROR" and "|cffff0000" or 
                      level == "WARN" and "|cffff9900" or 
                      level == "LIB" and "|cff00ffff" or "|cff00ff00"
    
    print(colorCode .. "[" .. timestamp .. "] DRLS Lib " .. level .. ": " .. message .. "|r")
end

-- Revolutionary Library Detection
function DRLS_LibManager:DetectLibraries()
    LibLog("Scanning for available libraries...", "LIB")
    
    local detected = {}
    local missing = {}
    
    for _, libName in ipairs(SUPPORTED_LIBS) do
        local lib = LibStub and LibStub:GetLibrary(libName, true)
        if lib then
            detected[libName] = {
                version = lib.minor or "Unknown",
                loaded = true,
                source = "LibStub"
            }
            LibLog("Detected: " .. libName .. " v" .. (lib.minor or "Unknown"), "INFO")
        else
            -- Check if available as global
            if _G[libName] then
                detected[libName] = {
                    version = _G[libName].version or "Unknown",
                    loaded = true,
                    source = "Global"
                }
                LibLog("Detected (Global): " .. libName, "INFO")
            else
                table.insert(missing, libName)
                LibLog("Missing: " .. libName, "WARN")
            end
        end
    end
    
    libraryStatus = {
        detected = detected,
        missing = missing,
        total = #SUPPORTED_LIBS,
        available = self:CountKeys(detected)
    }
    
    LibLog(string.format("Library scan complete: %d/%d available", 
           libraryStatus.available, libraryStatus.total), "LIB")
    
    return libraryStatus
end

-- Revolutionary Library Loading
function DRLS_LibManager:LoadLibrary(libName, required)
    if loadedLibraries[libName] then
        return loadedLibraries[libName]
    end
    
    local lib = nil
    local success = false
    
    -- Try LibStub first
    if LibStub then
        lib = LibStub:GetLibrary(libName, not required)
        if lib then
            success = true
            loadedLibraries[libName] = lib
            LibLog("Loaded via LibStub: " .. libName, "LIB")
        end
    end
    
    -- Fallback to global
    if not success and _G[libName] then
        lib = _G[libName]
        success = true
        loadedLibraries[libName] = lib
        LibLog("Loaded via Global: " .. libName, "LIB")
    end
    
    if not success then
        if required then
            LibLog("CRITICAL: Required library " .. libName .. " not available!", "ERROR")
            return nil
        else
            LibLog("Optional library " .. libName .. " not available", "WARN")
            return nil
        end
    end
    
    -- Initialize library if needed
    if lib and lib.Initialize and type(lib.Initialize) == "function" then
        local initSuccess, error = pcall(lib.Initialize, lib)
        if not initSuccess then
            LibLog("Failed to initialize " .. libName .. ": " .. tostring(error), "ERROR")
        end
    end
    
    return lib
end

-- Revolutionary Ace3 Integration
function DRLS_LibManager:InitializeAce3()
    LibLog("Initializing Ace3 framework integration...", "LIB")
    
    -- Load core Ace3 libraries
    local aceAddon = self:LoadLibrary("AceAddon-3.0", true)
    if not aceAddon then
        LibLog("CRITICAL: Cannot initialize without AceAddon-3.0!", "ERROR")
        return false
    end
    
    -- Create DRLS addon object using Ace3
    if not DRLS_Ace then
        DRLS_Ace = aceAddon:NewAddon("DRLS", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
        LibLog("Created DRLS Ace3 addon object", "LIB")
    end
    
    -- Load optional Ace3 libraries
    local optionalAceLibs = {
        "AceConfig-3.0",
        "AceConfigDialog-3.0", 
        "AceDB-3.0",
        "AceDBOptions-3.0",
        "AceLocale-3.0",
        "AceComm-3.0",
        "AceSerializer-3.0",
        "AceGUI-3.0"
    }
    
    for _, libName in ipairs(optionalAceLibs) do
        local lib = self:LoadLibrary(libName, false)
        if lib then
            -- Integrate with DRLS_Ace if possible
            if libName == "AceDB-3.0" and not DRLS_Ace.db then
                DRLS_Ace.db = lib:New("DRLSDB", self:GetDefaultDBStructure())
                LibLog("Integrated AceDB-3.0 with default structure", "LIB")
            elseif libName == "AceLocale-3.0" then
                DRLS_Ace.L = lib:GetLocale("DRLS", true)
                LibLog("Integrated AceLocale-3.0", "LIB")
            end
        end
    end
    
    -- Set up Ace3 event handlers
    function DRLS_Ace:OnInitialize()
        LibLog("DRLS Ace3 addon initialized", "LIB")
        if DRLS_Core and DRLS_Core.FireEvent then
            DRLS_Core:FireEvent("ACE3_INITIALIZED")
        end
    end
    
    function DRLS_Ace:OnEnable()
        LibLog("DRLS Ace3 addon enabled", "LIB")
        if DRLS_Core and DRLS_Core.FireEvent then
            DRLS_Core:FireEvent("ACE3_ENABLED")
        end
    end
    
    function DRLS_Ace:OnDisable()
        LibLog("DRLS Ace3 addon disabled", "LIB")
        if DRLS_Core and DRLS_Core.FireEvent then
            DRLS_Core:FireEvent("ACE3_DISABLED")
        end
    end
    
    LibLog("Ace3 framework integration complete", "LIB")
    return true
end

-- Revolutionary Default Database Structure
function DRLS_LibManager:GetDefaultDBStructure()
    return {
        profile = {
            ai = {
                enabled = true,
                analysisInterval = 30,
                autoOptimize = true,
                compatibilityMode = false,
                ecosystemAnalysis = true,
                predictiveConfig = true,
                performanceOptimization = true,
                layoutEngine = true,
                compatibilityEngine = true
            },
            ui = {
                scale = 1.0,
                alpha = 1.0,
                theme = "default",
                animations = true,
                compactMode = false,
                showTooltips = true,
                enableSounds = true
            },
            performance = {
                enableOptimizations = true,
                memoryLimit = 150,
                gcInterval = 300,
                eventThrottling = true,
                backgroundOptimization = true,
                aggressiveMode = false
            },
            integrations = {
                details = true,
                elvui = true,
                weakauras = true,
                dbm = true,
                plater = true,
                hekili = true
            },
            profiles = {
                autoSwitching = true,
                specProfiles = {},
                contentProfiles = {}
            }
        },
        global = {
            version = "1.0.0",
            firstRun = true,
            installDate = time(),
            statistics = {
                totalRunTime = 0,
                profileSwitches = 0,
                aiOperations = 0,
                optimizationsApplied = 0
            }
        }
    }
end

-- Revolutionary SharedMedia Integration
function DRLS_LibManager:InitializeSharedMedia()
    local LSM = self:LoadLibrary("LibSharedMedia-3.0", false)
    if not LSM then
        LibLog("LibSharedMedia-3.0 not available - using defaults", "WARN")
        return false
    end
    
    LibLog("Initializing SharedMedia integration...", "LIB")
    
    -- Register DRLS media
    local mediaPath = "Interface\\AddOns\\DRLS\\media\\"
    
    -- Fonts
    LSM:Register("font", "DRLS Revolutionary", mediaPath .. "fonts\\revolutionary.ttf")
    LSM:Register("font", "DRLS Combat", mediaPath .. "fonts\\combat.ttf")
    
    -- Textures
    LSM:Register("statusbar", "DRLS Smooth", mediaPath .. "textures\\smooth")
    LSM:Register("statusbar", "DRLS Glow", mediaPath .. "textures\\glow")
    LSM:Register("border", "DRLS Border", mediaPath .. "borders\\revolutionary")
    
    -- Sounds
    LSM:Register("sound", "DRLS Alert", mediaPath .. "sounds\\alert.ogg")
    LSM:Register("sound", "DRLS Revolution", mediaPath .. "sounds\\revolution.ogg")
    
    -- Background textures
    LSM:Register("background", "DRLS Dark", mediaPath .. "backgrounds\\dark")
    LSM:Register("background", "DRLS Revolutionary", mediaPath .. "backgrounds\\revolutionary")
    
    LibLog("SharedMedia integration complete", "LIB")
    return true
end

-- Revolutionary DataBroker Integration
function DRLS_LibManager:InitializeDataBroker()
    local LDB = self:LoadLibrary("LibDataBroker-1.1", false)
    if not LDB then
        LibLog("LibDataBroker-1.1 not available - no minimap integration", "WARN")
        return false
    end
    
    LibLog("Initializing DataBroker integration...", "LIB")
    
    -- Create DRLS data object
    local dataObj = LDB:NewDataObject("DRLS", {
        type = "data source",
        text = "DRLS",
        label = "DRLS Revolutionary System",
        icon = "Interface\\AddOns\\DRLS\\media\\icons\\drls_icon",
        
        OnClick = function(self, button)
            if button == "LeftButton" then
                if DRLS_Core and DRLS_Core.ShowStatus then
                    DRLS_Core:ShowStatus()
                end
            elseif button == "RightButton" then
                if DRLS_AI_Core and DRLS_AI_Core.ShowStatus then
                    DRLS_AI_Core:ShowStatus()
                end
            end
        end,
        
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("DRLS - DonkRonk's Last Shot", 1, 1, 1)
            tooltip:AddLine("Revolutionary AI-Powered Addon", 0.8, 0.8, 1)
            tooltip:AddLine(" ")
            tooltip:AddLine("Left Click: Show Core Status", 0, 1, 0)
            tooltip:AddLine("Right Click: Show AI Status", 0, 1, 0)
            
            if DRLS_Performance then
                local metrics = DRLS_Performance.performance or {}
                tooltip:AddLine(" ")
                tooltip:AddLine("Performance:", 1, 1, 0)
                tooltip:AddLine(string.format("Memory: %.1f MB", (metrics.memoryUsage or 0) / 1024), 1, 1, 1)
                tooltip:AddLine(string.format("CPU: %.1f%%", metrics.cpuUsage or 0), 1, 1, 1)
            end
            
            tooltip:Show()
        end
    })
    
    -- Minimap button integration
    local LibDBIcon = self:LoadLibrary("LibDBIcon-1.0", false)
    if LibDBIcon then
        LibDBIcon:Register("DRLS", dataObj, {
            minimapPos = 220,
            hide = false
        })
        LibLog("Minimap button registered", "LIB")
    end
    
    LibLog("DataBroker integration complete", "LIB")
    return true
end

-- Revolutionary Window Management
function DRLS_LibManager:InitializeWindowLib()
    local LibWindow = self:LoadLibrary("LibWindow-1.1", false)
    if not LibWindow then
        LibLog("LibWindow-1.1 not available - using manual positioning", "WARN")
        return false
    end
    
    LibLog("Initializing window management...", "LIB")
    
    -- Register DRLS frames with LibWindow
    if DRLSMainFrame then
        LibWindow.RegisterConfig(DRLSMainFrame, DRLS_Ace and DRLS_Ace.db and DRLS_Ace.db.profile.mainFramePosition)
        LibWindow.MakeDraggable(DRLSMainFrame)
        LibWindow.RestorePosition(DRLSMainFrame)
        LibLog("Main frame registered with LibWindow", "LIB")
    end
    
    if DRLSAIFrame then
        LibWindow.RegisterConfig(DRLSAIFrame, DRLS_Ace and DRLS_Ace.db and DRLS_Ace.db.profile.aiFramePosition)
        LibWindow.MakeDraggable(DRLSAIFrame)
        LibWindow.RestorePosition(DRLSAIFrame)
        LibLog("AI frame registered with LibWindow", "LIB")
    end
    
    LibLog("Window management complete", "LIB")
    return true
end

-- Revolutionary Library Event System
function DRLS_LibManager:SetupLibraryEvents()
    -- Hook into library loading events
    if LibStub then
        -- Monitor new library registrations
        local originalNewLibrary = LibStub.NewLibrary
        LibStub.NewLibrary = function(self, libname, minor, ...)
            local result = originalNewLibrary(self, libname, minor, ...)
            
            if libname and minor then
                LibLog("New library registered: " .. libname .. " v" .. tostring(minor), "LIB")
                
                -- Check if this is a library we're interested in
                for _, supportedLib in ipairs(SUPPORTED_LIBS) do
                    if libname == supportedLib then
                        LibLog("Supported library became available: " .. libname, "LIB")
                        -- Trigger re-initialization if needed
                        if DRLS_Core and DRLS_Core.FireEvent then
                            DRLS_Core:FireEvent("LIBRARY_AVAILABLE", libname, minor)
                        end
                        break
                    end
                end
            end
            
            return result
        end
    end
end

-- Revolutionary Library Status Report
function DRLS_LibManager:GetLibraryStatus()
    local status = {
        version = LIB_VERSION,
        supported = SUPPORTED_LIBS,
        detected = libraryStatus.detected or {},
        missing = libraryStatus.missing or {},
        loaded = loadedLibraries,
        integrations = {
            ace3 = (DRLS_Ace ~= nil),
            sharedMedia = (loadedLibraries["LibSharedMedia-3.0"] ~= nil),
            dataBroker = (loadedLibraries["LibDataBroker-1.1"] ~= nil),
            windowLib = (loadedLibraries["LibWindow-1.1"] ~= nil),
            dbIcon = (loadedLibraries["LibDBIcon-1.0"] ~= nil)
        }
    }
    
    return status
end

-- Revolutionary Library Diagnostics
function DRLS_LibManager:RunDiagnostics()
    LibLog("=== DRLS LIBRARY DIAGNOSTICS ===", "LIB")
    
    local status = self:GetLibraryStatus()
    
    LibLog("Supported Libraries: " .. #status.supported, "INFO")
    LibLog("Detected Libraries: " .. self:CountKeys(status.detected), "INFO")
    LibLog("Missing Libraries: " .. #status.missing, "INFO")
    LibLog("Loaded Libraries: " .. self:CountKeys(status.loaded), "INFO")
    
    LibLog("Integration Status:", "INFO")
    for integration, enabled in pairs(status.integrations) do
        LibLog("  " .. integration .. ": " .. (enabled and "ACTIVE" or "INACTIVE"), "INFO")
    end
    
    if #status.missing > 0 then
        LibLog("Missing Libraries:", "WARN")
        for _, missing in ipairs(status.missing) do
            LibLog("  - " .. missing, "WARN")
        end
    end
    
    LibLog("=== END DIAGNOSTICS ===", "LIB")
    
    return status
end

-- Revolutionary Initialization
function DRLS_LibManager:Initialize()
    LibLog("Initializing DRLS Library Manager v" .. LIB_VERSION, "LIB")
    
    -- Detect available libraries
    self:DetectLibraries()
    
    -- Set up library event monitoring
    self:SetupLibraryEvents()
    
    -- Initialize core integrations
    local integrations = {
        {name = "Ace3", func = self.InitializeAce3, required = true},
        {name = "SharedMedia", func = self.InitializeSharedMedia, required = false},
        {name = "DataBroker", func = self.InitializeDataBroker, required = false},
        {name = "WindowLib", func = self.InitializeWindowLib, required = false}
    }
    
    local successCount = 0
    for _, integration in ipairs(integrations) do
        local success = integration.func(self)
        if success then
            successCount = successCount + 1
            LibLog(integration.name .. " integration successful", "LIB")
        else
            if integration.required then
                LibLog("CRITICAL: " .. integration.name .. " integration failed!", "ERROR")
                return false
            else
                LibLog(integration.name .. " integration failed (optional)", "WARN")
            end
        end
    end
    
    LibLog(string.format("Library Manager initialized: %d/%d integrations active", 
           successCount, #integrations), "LIB")
    
    return true
end

-- Revolutionary Utility Functions
function DRLS_LibManager:CountKeys(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- Revolutionary Shutdown
function DRLS_LibManager:Shutdown()
    LibLog("Shutting down DRLS Library Manager", "LIB")
    
    -- Save positions if LibWindow is available
    local LibWindow = loadedLibraries["LibWindow-1.1"]
    if LibWindow then
        if DRLSMainFrame then LibWindow.SavePosition(DRLSMainFrame) end
        if DRLSAIFrame then LibWindow.SavePosition(DRLSAIFrame) end
    end
    
    -- Clean up hooks
    for _, hook in pairs(libraryHooks) do
        if hook.restore then
            hook.restore()
        end
    end
    
    LibLog("Library Manager shutdown complete", "LIB")
end

-- Export the revolutionary library manager
return DRLS_LibManager