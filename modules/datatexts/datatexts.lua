-- DRLS DataTexts Module - Revolutionary Data Text System
local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local DataTexts = DRLS:NewModule("DataTexts", "AceEvent-3.0", "AceTimer-3.0")

function DataTexts:OnInitialize()
    self:Print("DataTexts: Revolutionary Data Text System Initialized!")
    self.db = DRLS.db:RegisterNamespace("DataTexts", {
        profile = {
            enabled = true,
            fps = { enabled = true, position = "TOPLEFT" },
            memory = { enabled = true, position = "TOPRIGHT" },
            gold = { enabled = true, position = "BOTTOMLEFT" },
            clock = { enabled = true, position = "BOTTOMRIGHT" }
        }
    })
end

function DataTexts:OnEnable()
    self:CreateDataTexts()
    self:ScheduleRepeatingTimer("UpdateDataTexts", 1)
end

function DataTexts:CreateDataTexts()
    -- Revolutionary data text creation
    if self.db.profile.fps.enabled then
        self:CreateFPSText()
    end
    if self.db.profile.memory.enabled then
        self:CreateMemoryText()
    end
    if self.db.profile.gold.enabled then
        self:CreateGoldText()
    end
    if self.db.profile.clock.enabled then
        self:CreateClockText()
    end
end

function DataTexts:CreateFPSText()
    local text = UIParent:CreateFontString("DRLSFPSText", "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    text:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -10)
    text:SetTextColor(1, 1, 1, 1)
    self.fpsText = text
end

function DataTexts:CreateMemoryText()
    local text = UIParent:CreateFontString("DRLSMemoryText", "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    text:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
    text:SetTextColor(1, 1, 1, 1)
    self.memoryText = text
end

function DataTexts:CreateGoldText()
    local text = UIParent:CreateFontString("DRLSGoldText", "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    text:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10)
    text:SetTextColor(1, 0.8, 0, 1)
    self.goldText = text
end

function DataTexts:CreateClockText()
    local text = UIParent:CreateFontString("DRLSClockText", "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    text:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 10)
    text:SetTextColor(1, 1, 1, 1)
    self.clockText = text
end

function DataTexts:UpdateDataTexts()
    if self.fpsText then
        self.fpsText:SetText("FPS: " .. math.floor(GetFramerate()))
    end
    if self.memoryText then
        local memory = gcinfo()
        self.memoryText:SetText("Memory: " .. math.floor(memory/1024) .. "MB")
    end
    if self.goldText then
        local gold = GetMoney()
        self.goldText:SetText("Gold: " .. GetCoinTextureString(gold))
    end
    if self.clockText then
        self.clockText:SetText(date("%H:%M"))
    end
end

DRLS.DataTexts = DataTexts