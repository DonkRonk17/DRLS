-- DRLS Minimap Module - Revolutionary Minimap System
local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local Minimap = DRLS:NewModule("Minimap", "AceEvent-3.0")

function Minimap:OnInitialize()
    self:Print("Minimap: Revolutionary Minimap System Initialized!")
    self.db = DRLS.db:RegisterNamespace("Minimap", {
        profile = {
            enabled = true,
            size = 140,
            scale = 1.0,
            hideBlizzardFrame = false,
            showClock = true,
            showZoneText = true
        }
    })
end

function Minimap:OnEnable()
    self:ApplyMinimapStyling()
end

function Minimap:ApplyMinimapStyling()
    -- Revolutionary minimap styling
    if Minimap then
        Minimap:SetSize(self.db.profile.size, self.db.profile.size)
        Minimap:SetScale(self.db.profile.scale)
    end
    
    -- Style minimap border
    if MinimapBorder then
        MinimapBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    end
end

DRLS.Minimap = Minimap