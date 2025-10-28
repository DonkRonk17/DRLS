-- DRLS Chat Module - Revolutionary Chat System
local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local Chat = DRLS:NewModule("Chat", "AceEvent-3.0")

function Chat:OnInitialize()
    self:Print("Chat: Revolutionary Chat System Initialized!")
    self.db = DRLS.db:RegisterNamespace("Chat", {
        profile = {
            enabled = true,
            fontSize = 12,
            fadeTime = 120,
            enableLinks = true,
            showTimestamps = true,
            classColorNames = true
        }
    })
end

function Chat:OnEnable()
    self:RegisterEvent("ADDON_LOADED")
    self:ApplyChatStyling()
end

function Chat:ApplyChatStyling()
    -- Revolutionary chat styling
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            chatFrame:SetFont("Fonts\\FRIZQT__.TTF", self.db.profile.fontSize, "OUTLINE")
            chatFrame:SetFading(true)
            chatFrame:SetTimeVisible(self.db.profile.fadeTime)
        end
    end
end

DRLS.Chat = Chat