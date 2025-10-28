-- DRLS Blizzard Module - Revolutionary Blizzard Frame Modifications
local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local Blizzard = DRLS:NewModule("Blizzard", "AceEvent-3.0")

function Blizzard:OnInitialize()
    self:Print("Blizzard: Revolutionary Blizzard Frame System Initialized!")
    self.db = DRLS.db:RegisterNamespace("Blizzard", {
        profile = {
            enabled = true,
            hideMainMenuBar = false,
            hideGryphons = true,
            hideMicroMenu = false,
            hideBagBar = false
        }
    })
end

function Blizzard:OnEnable()
    self:ModifyBlizzardFrames()
end

function Blizzard:ModifyBlizzardFrames()
    -- Revolutionary Blizzard frame modifications
    if self.db.profile.hideGryphons then
        self:HideGryphons()
    end
    if self.db.profile.hideMicroMenu then
        self:HideMicroMenu()
    end
end

function Blizzard:HideGryphons()
    if MainMenuBarLeftEndCap then MainMenuBarLeftEndCap:Hide() end
    if MainMenuBarRightEndCap then MainMenuBarRightEndCap:Hide() end
end

function Blizzard:HideMicroMenu()
    if MicroButtonAndBagsBar then MicroButtonAndBagsBar:Hide() end
end

DRLS.Blizzard = Blizzard