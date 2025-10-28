-- DRLS Bags Module - Revolutionary Bag Management System
local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
local Bags = DRLS:NewModule("Bags", "AceEvent-3.0")

function Bags:OnInitialize()
    self:Print("Bags: Revolutionary Bag Management System Initialized!")
    self.db = DRLS.db:RegisterNamespace("Bags", {
        profile = {
            enabled = true,
            oneSlot = false,
            sortOnOpen = true,
            showItemLevel = true,
            bagScale = 1.0
        }
    })
end

function Bags:OnEnable()
    self:ModifyBags()
    self:RegisterEvent("BAG_UPDATE")
end

function Bags:ModifyBags()
    -- Revolutionary bag modifications
    if self.db.profile.oneSlot then
        self:EnableOneSlotBag()
    end
    
    self:SetBagScale()
end

function Bags:EnableOneSlotBag()
    -- Create revolutionary unified bag container
    if not self.unifiedBag then
        self.unifiedBag = CreateFrame("Frame", "DRLSUnifiedBag", UIParent)
        self.unifiedBag:SetSize(400, 300)
        self.unifiedBag:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50)
        self.unifiedBag:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        self.unifiedBag:SetBackdropColor(0, 0, 0, 0.8)
        
        -- Create title
        local title = self.unifiedBag:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -10)
        title:SetText("DRLS Revolutionary Bag")
        
        self.unifiedBag:Hide()
    end
end

function Bags:SetBagScale()
    -- Set bag scale for all bag frames
    local scale = self.db.profile.bagScale
    for i = 0, 4 do
        local bagFrame = _G["ContainerFrame"..(i+1)]
        if bagFrame then
            bagFrame:SetScale(scale)
        end
    end
end

function Bags:BAG_UPDATE(event, bagID)
    if self.db.profile.sortOnOpen and bagID then
        self:SortBag(bagID)
    end
end

function Bags:SortBag(bagID)
    -- Revolutionary bag sorting algorithm
    if bagID >= 0 and bagID <= 4 then
        SortBankBags()
        SortBags()
    end
end

function Bags:ToggleUnifiedBag()
    if self.unifiedBag then
        if self.unifiedBag:IsShown() then
            self.unifiedBag:Hide()
        else
            self.unifiedBag:Show()
        end
    end
end

DRLS.Bags = Bags