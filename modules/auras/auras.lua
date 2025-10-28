-- DRLS Auras Module - Revolutionary Aura System
local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local Auras = DRLS:NewModule("Auras", "AceEvent-3.0")

function Auras:OnInitialize()
    self:Print("Auras: Revolutionary Aura System Initialized!")
    self.db = DRLS.db:RegisterNamespace("Auras", {
        profile = {
            enabled = true,
            playerBuffs = { enabled = true, size = 32, growthDirection = "RIGHT" },
            playerDebuffs = { enabled = true, size = 32, growthDirection = "RIGHT" },
            targetBuffs = { enabled = true, size = 28, growthDirection = "RIGHT" }
        }
    })
end

function Auras:OnEnable()
    self:RegisterEvent("UNIT_AURA")
    self:SetupAuraFrames()
end

function Auras:SetupAuraFrames()
    -- Revolutionary aura frame setup
    self:CreatePlayerBuffFrame()
    self:CreatePlayerDebuffFrame()
    self:CreateTargetBuffFrame()
end

function Auras:CreatePlayerBuffFrame()
    local frame = CreateFrame("Frame", "DRLSPlayerBuffs", UIParent)
    frame:SetSize(320, 40)
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -100)
    self.playerBuffFrame = frame
end

function Auras:CreatePlayerDebuffFrame()
    local frame = CreateFrame("Frame", "DRLSPlayerDebuffs", UIParent)
    frame:SetSize(320, 40)
    frame:SetPoint("TOPRIGHT", self.playerBuffFrame, "BOTTOMRIGHT", 0, -5)
    self.playerDebuffFrame = frame
end

function Auras:CreateTargetBuffFrame()
    local frame = CreateFrame("Frame", "DRLSTargetBuffs", UIParent)
    frame:SetSize(280, 35)
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -100)
    self.targetBuffFrame = frame
end

DRLS.Auras = Auras