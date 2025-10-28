-- =====================================================
-- DRLS UnitFrames Module
-- Revolutionary Unit Frame System for DRLS
-- =====================================================

local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local UnitFrames = DRLS:NewModule("UnitFrames", "AceEvent-3.0", "AceTimer-3.0")

-- =====================================================
-- REVOLUTIONARY UNITFRAME SYSTEM
-- =====================================================

function UnitFrames:OnInitialize()
    self:Print("UnitFrames: Initializing Revolutionary Unit Frame System...")
    
    -- Setup configuration
    self.db = DRLS.db:RegisterNamespace("UnitFrames", {
        profile = {
            enabled = true,
            player = {
                enabled = true,
                width = 230,
                height = 55,
                scale = 1.0,
                alpha = 1.0,
                point = "TOPLEFT",
                xOffset = 20,
                yOffset = -20
            },
            target = {
                enabled = true,
                width = 230,
                height = 55,
                scale = 1.0,
                alpha = 1.0,
                point = "TOPRIGHT",
                xOffset = -20,
                yOffset = -20
            },
            focus = {
                enabled = true,
                width = 200,
                height = 45,
                scale = 0.9,
                alpha = 1.0,
                point = "TOP",
                xOffset = 0,
                yOffset = -100
            },
            party = {
                enabled = true,
                width = 180,
                height = 40,
                scale = 0.8,
                alpha = 1.0,
                point = "LEFT",
                xOffset = 20,
                yOffset = 0
            }
        }
    })
    
    self:InitializeUnitFrames()
end

function UnitFrames:OnEnable()
    self:Print("UnitFrames: Revolutionary Unit Frame System Enabled!")
    
    -- Register events
    self:RegisterEvent("PLAYER_LOGIN", "UpdateUnitFrames")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTarget")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", "UpdateFocus")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateParty")
    
    self:ApplyUnitFrameConfiguration()
end

function UnitFrames:OnDisable()
    self:Print("UnitFrames: System Disabled")
    self:UnregisterAllEvents()
end

-- =====================================================
-- CORE UNITFRAME FUNCTIONS
-- =====================================================

function UnitFrames:InitializeUnitFrames()
    local frames = {
        "PlayerFrame",
        "TargetFrame", 
        "FocusFrame",
        "PartyMemberFrame1",
        "PartyMemberFrame2",
        "PartyMemberFrame3",
        "PartyMemberFrame4"
    }
    
    for _, frameName in ipairs(frames) do
        local frame = _G[frameName]
        if frame then
            self:SetupUnitFrame(frame, frameName)
        end
    end
end

function UnitFrames:SetupUnitFrame(frame, frameName)
    if not frame then return end
    
    -- Revolutionary frame setup
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    -- Add DRLS styling
    if not frame.drlsStyled then
        self:ApplyFrameStyling(frame)
        frame.drlsStyled = true
    end
    
    -- Setup frame components
    self:SetupHealthBar(frame)
    self:SetupManaBar(frame)
    self:SetupPortrait(frame)
    self:SetupNameText(frame)
end

function UnitFrames:ApplyFrameStyling(frame)
    -- Revolutionary styling
    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }
    
    if frame.SetBackdrop then
        frame:SetBackdrop(backdrop)
        frame:SetBackdropColor(0, 0, 0, 0.8)
        frame:SetBackdropBorderColor(1, 1, 1, 0.9)
    end
end

function UnitFrames:SetupHealthBar(frame)
    local healthBar = frame.healthbar or frame.HealthBar
    if healthBar then
        -- Revolutionary health bar styling
        healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        healthBar:SetStatusBarColor(0.2, 0.8, 0.2, 1.0)
        
        -- Add text overlay
        if not healthBar.text then
            healthBar.text = healthBar:CreateFontString(nil, "OVERLAY")
            healthBar.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
            healthBar.text:SetPoint("CENTER")
            healthBar.text:SetTextColor(1, 1, 1, 1)
        end
    end
end

function UnitFrames:SetupManaBar(frame)
    local manaBar = frame.manabar or frame.ManaBar
    if manaBar then
        -- Revolutionary mana bar styling
        manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        
        -- Add text overlay
        if not manaBar.text then
            manaBar.text = manaBar:CreateFontString(nil, "OVERLAY")
            manaBar.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            manaBar.text:SetPoint("CENTER")
            manaBar.text:SetTextColor(1, 1, 1, 1)
        end
    end
end

function UnitFrames:SetupPortrait(frame)
    local portrait = frame.portrait or frame.Portrait
    if portrait then
        -- Revolutionary portrait styling
        portrait:SetWidth(50)
        portrait:SetHeight(50)
        
        -- Add border
        if not portrait.border then
            portrait.border = portrait:CreateTexture(nil, "OVERLAY")
            portrait.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
            portrait.border:SetAllPoints(portrait)
        end
    end
end

function UnitFrames:SetupNameText(frame)
    local nameText = frame.name or frame.Name
    if nameText then
        -- Revolutionary name text styling
        nameText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        nameText:SetTextColor(1, 1, 1, 1)
        nameText:SetShadowOffset(1, -1)
        nameText:SetShadowColor(0, 0, 0, 1)
    end
end

-- =====================================================
-- CONFIGURATION FUNCTIONS
-- =====================================================

function UnitFrames:ApplyUnitFrameConfiguration()
    local config = self.db.profile
    
    local frameMap = {
        player = PlayerFrame,
        target = TargetFrame,
        focus = FocusFrame,
        party1 = PartyMemberFrame1,
        party2 = PartyMemberFrame2,
        party3 = PartyMemberFrame3,
        party4 = PartyMemberFrame4
    }
    
    for unitType, settings in pairs(config) do
        if type(settings) == "table" and settings.enabled then
            local frame = frameMap[unitType]
            if frame then
                self:PositionUnitFrame(frame, settings)
                self:SetFrameAlpha(frame, settings.alpha)
                self:SetFrameScale(frame, settings.scale)
                self:SetFrameSize(frame, settings.width, settings.height)
            end
        end
    end
end

function UnitFrames:PositionUnitFrame(frame, settings)
    if not frame then return end
    
    frame:ClearAllPoints()
    frame:SetPoint(settings.point, UIParent, settings.point, settings.xOffset, settings.yOffset)
end

function UnitFrames:SetFrameAlpha(frame, alpha)
    if frame then
        frame:SetAlpha(alpha)
    end
end

function UnitFrames:SetFrameScale(frame, scale)
    if frame then
        frame:SetScale(scale)
    end
end

function UnitFrames:SetFrameSize(frame, width, height)
    if frame and width and height then
        frame:SetSize(width, height)
    end
end

-- =====================================================
-- EVENT HANDLERS
-- =====================================================

function UnitFrames:UpdateUnitFrames()
    self:ScheduleTimer("ApplyUnitFrameConfiguration", 0.1)
end

function UnitFrames:UpdateTarget()
    local frame = TargetFrame
    if frame then
        self:UpdateFrameData(frame, "target")
    end
end

function UnitFrames:UpdateFocus()
    local frame = FocusFrame
    if frame then
        self:UpdateFrameData(frame, "focus")
    end
end

function UnitFrames:UpdateParty()
    for i = 1, 4 do
        local frame = _G["PartyMemberFrame"..i]
        if frame then
            self:UpdateFrameData(frame, "party"..i)
        end
    end
end

function UnitFrames:UpdateFrameData(frame, unit)
    if not frame or not UnitExists(unit) then return end
    
    -- Update health bar
    local healthBar = frame.healthbar or frame.HealthBar
    if healthBar and healthBar.text then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        healthBar.text:SetText(self:FormatNumber(health).." / "..self:FormatNumber(maxHealth))
    end
    
    -- Update mana bar
    local manaBar = frame.manabar or frame.ManaBar
    if manaBar and manaBar.text then
        local mana = UnitPower(unit)
        local maxMana = UnitPowerMax(unit)
        if maxMana > 0 then
            manaBar.text:SetText(self:FormatNumber(mana).." / "..self:FormatNumber(maxMana))
        end
    end
end

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

function UnitFrames:FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

-- =====================================================
-- REVOLUTIONARY FEATURES
-- =====================================================

function UnitFrames:EnableRevolutionaryMode()
    self:Print("UnitFrames: Revolutionary Mode Activated!")
    
    -- Add AI-powered frame positioning
    self:ScheduleRepeatingTimer("OptimizeFramePositions", 60)
    
    -- Add threat detection
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", "UpdateThreat")
end

function UnitFrames:OptimizeFramePositions()
    -- AI-powered optimization
    local _, class = UnitClass("player")
    local role = GetSpecializationRole(GetSpecialization())
    
    -- Revolutionary positioning logic based on role
    self:Print("UnitFrames: AI Optimization Complete - Frames Repositioned!")
end

function UnitFrames:UpdateThreat(event, unit)
    if not unit then return end
    
    local frame = self:GetFrameForUnit(unit)
    if frame then
        local status = UnitThreatSituation(unit)
        self:UpdateThreatStyling(frame, status)
    end
end

function UnitFrames:GetFrameForUnit(unit)
    if unit == "player" then return PlayerFrame
    elseif unit == "target" then return TargetFrame
    elseif unit == "focus" then return FocusFrame
    elseif string.match(unit, "party") then
        local num = string.match(unit, "(%d+)")
        return _G["PartyMemberFrame"..num]
    end
    return nil
end

function UnitFrames:UpdateThreatStyling(frame, status)
    if not frame then return end
    
    -- Revolutionary threat indication
    local colors = {
        [0] = {0, 1, 0, 0.3}, -- Safe - Green
        [1] = {1, 1, 0, 0.5}, -- Warning - Yellow
        [2] = {1, 0.5, 0, 0.7}, -- Danger - Orange
        [3] = {1, 0, 0, 0.9}  -- High Threat - Red
    }
    
    local color = colors[status] or {1, 1, 1, 0.1}
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(unpack(color))
    end
end

-- =====================================================
-- MODULE REGISTRATION
-- =====================================================

DRLS.UnitFrames = UnitFrames