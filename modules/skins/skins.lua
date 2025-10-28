-- DRLS Skins Module - Revolutionary UI Skinning System
local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local Skins = DRLS:NewModule("Skins", "AceEvent-3.0")

function Skins:OnInitialize()
    self:Print("Skins: Revolutionary UI Skinning System Initialized!")
    self.db = DRLS.db:RegisterNamespace("Skins", {
        profile = {
            enabled = true,
            skinButtons = true,
            skinFrames = true,
            customTextures = true,
            borderSize = 2
        }
    })
end

function Skins:OnEnable()
    self:ApplySkins()
end

function Skins:ApplySkins()
    if self.db.profile.skinButtons then
        self:SkinButtons()
    end
    if self.db.profile.skinFrames then
        self:SkinFrames()
    end
end

function Skins:SkinButtons()
    -- Revolutionary button skinning
    local function SkinButton(button)
        if button and button.SetNormalTexture then
            button:SetNormalTexture("")
            button:SetHighlightTexture("")
            button:SetPushedTexture("")
            
            if not button.backdrop then
                button:CreateBackdrop("Transparent")
            end
        end
    end
    
    -- Skin common buttons
    for i = 1, 12 do
        local button = _G["ActionButton"..i]
        if button then SkinButton(button) end
    end
end

function Skins:SkinFrames()
    -- Revolutionary frame skinning
    local function SkinFrame(frame)
        if frame and frame.SetBackdrop then
            frame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                tile = false,
                tileSize = 0,
                edgeSize = self.db.profile.borderSize,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            frame:SetBackdropColor(0, 0, 0, 0.8)
            frame:SetBackdropBorderColor(1, 1, 1, 1)
        end
    end
    
    -- Skin common frames
    if PlayerFrame then SkinFrame(PlayerFrame) end
    if TargetFrame then SkinFrame(TargetFrame) end
end

DRLS.Skins = Skins