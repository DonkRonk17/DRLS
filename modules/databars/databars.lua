-- DRLS DataBars Module - Revolutionary Data Bar System
local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local DataBars = DRLS:NewModule("DataBars", "AceEvent-3.0")

function DataBars:OnInitialize()
    self:Print("DataBars: Revolutionary Data Bar System Initialized!")
    self.db = DRLS.db:RegisterNamespace("DataBars", {
        profile = {
            enabled = true,
            experienceBar = { enabled = true, width = 400, height = 12 },
            reputationBar = { enabled = true, width = 400, height = 8 },
            artifactBar = { enabled = true, width = 400, height = 10 }
        }
    })
end

function DataBars:OnEnable()
    self:RegisterEvent("PLAYER_XP_UPDATE")
    self:RegisterEvent("UPDATE_FACTION")
    self:CreateDataBars()
end

function DataBars:CreateDataBars()
    -- Revolutionary data bar creation
    self:CreateExperienceBar()
    self:CreateReputationBar()
end

function DataBars:CreateExperienceBar()
    local bar = CreateFrame("StatusBar", "DRLSExperienceBar", UIParent)
    bar:SetSize(self.db.profile.experienceBar.width, self.db.profile.experienceBar.height)
    bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 100)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(0, 0.4, 1, 0.8)
    self.experienceBar = bar
end

function DataBars:CreateReputationBar()
    local bar = CreateFrame("StatusBar", "DRLSReputationBar", UIParent)
    bar:SetSize(self.db.profile.reputationBar.width, self.db.profile.reputationBar.height)
    bar:SetPoint("BOTTOM", self.experienceBar, "TOP", 0, 2)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(0, 1, 0, 0.8)
    self.reputationBar = bar
end

DRLS.DataBars = DataBars