-- DRLS Tooltip Module - Revolutionary Tooltip Enhancement System
local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local Tooltip = DRLS:NewModule("Tooltip", "AceEvent-3.0", "AceHook-3.0")

function Tooltip:OnInitialize()
    self:Print("Tooltip: Revolutionary Tooltip System Initialized!")
    self.db = DRLS.db:RegisterNamespace("Tooltip", {
        profile = {
            enabled = true,
            showTargetInfo = true,
            showGuildInfo = true,
            showHealth = true,
            scale = 1.0,
            anchor = "ANCHOR_CURSOR"
        }
    })
end

function Tooltip:OnEnable()
    self:SetupTooltips()
    self:HookTooltips()
end

function Tooltip:SetupTooltips()
    -- Revolutionary tooltip configuration
    GameTooltip:SetScale(self.db.profile.scale)
    GameTooltip:HookScript("OnShow", function() self:OnTooltipShow() end)
end

function Tooltip:HookTooltips()
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "OnTooltipSetUnit")
end

function Tooltip:OnTooltipShow()
    -- Revolutionary tooltip positioning
    if self.db.profile.anchor == "ANCHOR_CURSOR" then
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
    end
end

function Tooltip:OnTooltipSetUnit()
    local unit = select(2, GameTooltip:GetUnit())
    if not unit then return end
    
    if self.db.profile.showHealth then
        self:AddHealthInfo(unit)
    end
    
    if self.db.profile.showTargetInfo then
        self:AddTargetInfo(unit)
    end
    
    if self.db.profile.showGuildInfo then
        self:AddGuildInfo(unit)
    end
end

function Tooltip:AddHealthInfo(unit)
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    if health and maxHealth and maxHealth > 0 then
        local healthPercent = math.floor((health / maxHealth) * 100)
        GameTooltip:AddLine(string.format("Health: %s/%s (%d%%)", 
            self:FormatNumber(health), 
            self:FormatNumber(maxHealth), 
            healthPercent), 1, 1, 1)
    end
end

function Tooltip:AddTargetInfo(unit)
    local target = unit.."target"
    if UnitExists(target) then
        local targetName = UnitName(target)
        if targetName then
            GameTooltip:AddLine("Target: "..targetName, 1, 0.8, 0)
        end
    end
end

function Tooltip:AddGuildInfo(unit)
    local guildName = GetGuildInfo(unit)
    if guildName then
        GameTooltip:AddLine("<"..guildName..">", 0, 1, 0)
    end
end

function Tooltip:FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

DRLS.Tooltip = Tooltip