-- AceAddon-3.0 - Addon framework for World of Warcraft addons
local MAJOR, MINOR = "AceAddon-3.0", 13
local AceAddon, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceAddon then return end

AceAddon.frame = AceAddon.frame or CreateFrame("Frame", "AceAddon30Frame")
AceAddon.addons = AceAddon.addons or {}
AceAddon.statuses = AceAddon.statuses or {}
AceAddon.initializeQueue = AceAddon.initializeQueue or {}
AceAddon.enableQueue = AceAddon.enableQueue or {}

-- Addon prototype
local AddonPrototype = {}
local AddonMeta = {__index = AddonPrototype}

function AddonPrototype:NewModule(name, ...)
    local module = setmetatable({}, AddonMeta)
    module.name = name
    module.parent = self
    module.modules = module.modules or {}
    
    self.modules = self.modules or {}
    self.modules[name] = module
    
    -- Apply mixins
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        if type(mixin) == "string" then
            local lib = LibStub(mixin, true)
            if lib then
                for k, v in pairs(lib) do
                    if type(v) == "function" then
                        module[k] = v
                    end
                end
            end
        end
    end
    
    return module
end

function AddonPrototype:GetModule(name)
    return self.modules and self.modules[name]
end

function AddonPrototype:EnableModule(name)
    local module = self:GetModule(name)
    if module and module.OnEnable then
        module:OnEnable()
    end
end

function AddonPrototype:DisableModule(name)
    local module = self:GetModule(name)
    if module and module.OnDisable then
        module:OnDisable()
    end
end

function AddonPrototype:Print(...)
    print("|cff33ff99" .. tostring(self.name) .. "|r:", ...)
end

-- Main AceAddon functions
function AceAddon:NewAddon(name, ...)
    local addon = setmetatable({}, AddonMeta)
    addon.name = name
    addon.modules = {}
    
    -- Apply mixins
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        if type(mixin) == "string" then
            local lib = LibStub(mixin, true)
            if lib then
                for k, v in pairs(lib) do
                    if type(v) == "function" then
                        addon[k] = v
                    end
                end
            end
        end
    end
    
    self.addons[name] = addon
    return addon
end

function AceAddon:GetAddon(name)
    return self.addons[name]
end

-- Event handling
AceAddon.frame:RegisterEvent("ADDON_LOADED")
AceAddon.frame:RegisterEvent("PLAYER_LOGIN")
AceAddon.frame:SetScript("OnEvent", function(frame, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        local addon = AceAddon.addons[addonName]
        if addon and addon.OnInitialize then
            addon:OnInitialize()
        end
    elseif event == "PLAYER_LOGIN" then
        for name, addon in pairs(AceAddon.addons) do
            if addon.OnEnable then
                addon:OnEnable()
            end
        end
    end
end)