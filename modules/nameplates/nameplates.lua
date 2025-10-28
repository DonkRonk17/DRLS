-- =====================================================
-- DRLS Nameplates Module
-- Revolutionary Nameplate System for DRLS
-- =====================================================

local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local Nameplates = DRLS:NewModule("Nameplates", "AceEvent-3.0")

function Nameplates:OnInitialize()
    self:Print("Nameplates: Initializing Revolutionary Nameplate System...")
    
    self.db = DRLS.db:RegisterNamespace("Nameplates", {
        profile = {
            enabled = true,
            showEnemyNames = true,
            showFriendlyNames = false,
            width = 110,
            height = 15,
            scale = 1.0,
            alpha = 1.0,
            showThreat = true,
            showCastBars = true,
            classColorNames = true
        }
    })
end

function Nameplates:OnEnable()
    self:Print("Nameplates: Revolutionary System Enabled!")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
end

function Nameplates:OnDisable()
    self:UnregisterAllEvents()
end

function Nameplates:NAME_PLATE_UNIT_ADDED(event, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate then
        self:StyleNameplate(nameplate, unit)
    end
end

function Nameplates:NAME_PLATE_UNIT_REMOVED(event, unit)
    -- Cleanup when nameplate is removed
end

function Nameplates:StyleNameplate(nameplate, unit)
    if not nameplate then return end
    
    -- Revolutionary nameplate styling
    local healthBar = nameplate.UnitFrame.healthBar
    if healthBar then
        healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        healthBar:SetHeight(self.db.profile.height)
        healthBar:SetWidth(self.db.profile.width)
    end
    
    -- Add threat coloring
    if self.db.profile.showThreat then
        self:UpdateThreatColor(nameplate, unit)
    end
    
    -- Class coloring
    if self.db.profile.classColorNames and UnitIsPlayer(unit) then
        self:ApplyClassColors(nameplate, unit)
    end
end

function Nameplates:UpdateThreatColor(nameplate, unit)
    local status = UnitThreatSituation("player", unit)
    local healthBar = nameplate.UnitFrame.healthBar
    
    if healthBar and status then
        local colors = {
            [0] = {0, 1, 0}, -- Safe
            [1] = {1, 1, 0}, -- Warning  
            [2] = {1, 0.5, 0}, -- Danger
            [3] = {1, 0, 0}  -- High Threat
        }
        local color = colors[status] or {0.5, 0.5, 0.5}
        healthBar:SetStatusBarColor(unpack(color))
    end
end

function Nameplates:ApplyClassColors(nameplate, unit)
    local _, class = UnitClass(unit)
    if class then
        local color = RAID_CLASS_COLORS[class]
        if color and nameplate.UnitFrame.name then
            nameplate.UnitFrame.name:SetTextColor(color.r, color.g, color.b)
        end
    end
end

DRLS.Nameplates = Nameplates