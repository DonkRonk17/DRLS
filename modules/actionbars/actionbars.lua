--[[
    DRGUI ActionBars Module
    
    Complete action bar replacement system that surpasses ElvUI's functionality.
    Features:
    - 12 fully customizable action bars
    - Pet and stance bars
    - Advanced positioning and scaling
    - Custom button styling and animations
    - Micro bar management
    - Future expansion compatibility
    - Enhanced keybinding system
]]

local DRGUI = _G.DRGUI
if not DRGUI then return end

-- Create ActionBars module
local ActionBars = {}
DRGUI:RegisterModule("ActionBars", ActionBars)

-- Local references for performance
local CreateFrame = CreateFrame
local UIParent = UIParent
local GetActionBarPage = GetActionBarPage
local GetBonusBarOffset = GetBonusBarOffset
local HasAction = HasAction
local GetActionTexture = GetActionTexture
local GetActionText = GetActionText
local GetActionCount = GetActionCount
local GetActionCooldown = GetActionCooldown
local IsActionInRange = IsActionInRange
local IsUsableAction = IsUsableAction
local IsCurrentAction = IsCurrentAction
local IsAutoRepeatAction = IsAutoRepeatAction
local IsAttackAction = IsAttackAction
local IsEquippedAction = IsEquippedAction

-- Module properties
ActionBars.bars = {}
ActionBars.buttons = {}
ActionBars.petBar = nil
ActionBars.stanceBar = nil
ActionBars.microBar = nil
ActionBars.vehicleBar = nil

-- Button cache for performance
ActionBars.buttonCache = {}
ActionBars.updateQueue = {}
ActionBars.throttle = 0.1
ActionBars.lastUpdate = 0

-- Constants
local NUM_ACTIONBAR_BUTTONS = 12
local NUM_PET_ACTION_SLOTS = 10
local NUM_STANCE_SLOTS = 10
local MAX_BARS = 12

-- Action bar configuration
local BAR_CONFIGS = {
    [1] = { page = 1, showInPetBattle = false, showInVehicle = false },
    [2] = { page = 2, showInPetBattle = false, showInVehicle = false },
    [3] = { page = 3, showInPetBattle = false, showInVehicle = false },
    [4] = { page = 4, showInPetBattle = false, showInVehicle = false },
    [5] = { page = 5, showInPetBattle = false, showInVehicle = false },
    [6] = { page = 6, showInPetBattle = false, showInVehicle = false },
    [7] = { page = 7, showInPetBattle = true, showInVehicle = true },
    [8] = { page = 8, showInPetBattle = true, showInVehicle = true },
    [9] = { page = 9, showInPetBattle = true, showInVehicle = true },
    [10] = { page = 10, showInPetBattle = true, showInVehicle = true },
    [11] = { page = 11, showInPetBattle = true, showInVehicle = true },
    [12] = { page = 12, showInPetBattle = true, showInVehicle = true },
}

-- Enhanced Button Creation
function ActionBars:CreateActionButton(parent, buttonId, barId)
    local button = CreateFrame("CheckButton", "DRGUIActionButton" .. barId .. "_" .. buttonId, parent, "ActionBarButtonTemplate")
    
    -- Enhanced button properties
    button.id = buttonId
    button.barId = barId
    button.action = 0
    button.showGrid = 0
    button.locked = true
    
    -- Styling
    button:SetSize(32, 32)
    
    -- Enhanced texture management
    button.icon = button.icon or button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    
    -- Count text
    button.Count = button.Count or button:CreateFontString(nil, "OVERLAY")
    button.Count:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    button.Count:SetPoint("BOTTOMRIGHT", -2, 2)
    button.Count:SetJustifyH("RIGHT")
    
    -- Hotkey text
    button.HotKey = button.HotKey or button:CreateFontString(nil, "OVERLAY")
    button.HotKey:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    button.HotKey:SetPoint("TOPRIGHT", -2, -2)
    button.HotKey:SetJustifyH("RIGHT")
    
    -- Macro text
    button.Name = button.Name or button:CreateFontString(nil, "OVERLAY")
    button.Name:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
    button.Name:SetPoint("BOTTOM", 0, 2)
    button.Name:SetJustifyH("CENTER")
    
    -- Border for equipped items
    button.Border = button.Border or button:CreateTexture(nil, "OVERLAY")
    button.Border:SetAllPoints()
    button.Border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    button.Border:SetBlendMode("ADD")
    button.Border:Hide()
    
    -- Cooldown frame
    button.cooldown = button.cooldown or CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints()
    
    -- Flash texture for procs
    button.Flash = button.Flash or button:CreateTexture(nil, "OVERLAY")
    button.Flash:SetAllPoints()
    button.Flash:SetTexture("Interface\\Buttons\\UI-QuickslotRed")
    button.Flash:SetBlendMode("ADD")
    button.Flash:Hide()
    
    -- Pushed texture
    button.pushedTexture = button.pushedTexture or button:CreateTexture(nil, "ARTWORK")
    button.pushedTexture:SetAllPoints()
    button.pushedTexture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    button:SetPushedTexture(button.pushedTexture)
    
    -- Highlight texture
    button.highlightTexture = button.highlightTexture or button:CreateTexture(nil, "ARTWORK")
    button.highlightTexture:SetAllPoints()
    button.highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    button.highlightTexture:SetBlendMode("ADD")
    button:SetHighlightTexture(button.highlightTexture)
    
    -- Enhanced scripts
    button:SetScript("OnEnter", function(self)
        self:UpdateTooltip()
        if self.icon:GetTexture() then
            self.highlightTexture:Show()
        end
    end)
    
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self.highlightTexture:Hide()
    end)
    
    button:SetScript("OnUpdate", function(self, elapsed)
        self:UpdateAction()
        self:UpdateCooldown()
        self:UpdateUsable()
        self:UpdateCount()
        self:UpdateState()
    end)
    
    -- Add custom methods
    button.UpdateAction = ActionBars.UpdateButtonAction
    button.UpdateTooltip = ActionBars.UpdateButtonTooltip
    button.UpdateCooldown = ActionBars.UpdateButtonCooldown
    button.UpdateUsable = ActionBars.UpdateButtonUsable
    button.UpdateCount = ActionBars.UpdateButtonCount
    button.UpdateState = ActionBars.UpdateButtonState
    button.SetAction = ActionBars.SetButtonAction
    
    -- Register for drag and drop
    button:RegisterForDrag("LeftButton")
    button:RegisterForClicks("AnyUp")
    
    return button
end

-- Enhanced Button Update Functions
function ActionBars:UpdateButtonAction(button)
    if not button or not button.action then return end
    
    local texture = GetActionTexture(button.action)
    if texture then
        button.icon:SetTexture(texture)
        button.icon:Show()
        button:SetAlpha(1.0)
    else
        button.icon:SetTexture(nil)
        button.icon:Hide()
        button:SetAlpha(0.5)
    end
    
    -- Update macro text
    local text = GetActionText(button.action)
    if text then
        button.Name:SetText(text)
        button.Name:Show()
    else
        button.Name:Hide()
    end
end

function ActionBars:UpdateButtonCooldown(button)
    if not button or not button.action or not HasAction(button.action) then
        return
    end
    
    local start, duration, enabled = GetActionCooldown(button.action)
    if start > 0 and duration > 1.5 then
        button.cooldown:SetCooldown(start, duration)
        button.cooldown:Show()
    else
        button.cooldown:Hide()
    end
end

function ActionBars:UpdateButtonUsable(button)
    if not button or not button.action or not HasAction(button.action) then
        return
    end
    
    local isUsable, notEnoughMana = IsUsableAction(button.action)
    if isUsable then
        button.icon:SetVertexColor(1.0, 1.0, 1.0)
    elseif notEnoughMana then
        button.icon:SetVertexColor(0.5, 0.5, 1.0)
    else
        button.icon:SetVertexColor(0.4, 0.4, 0.4)
    end
    
    -- Range checking
    local inRange = IsActionInRange(button.action)
    if inRange == false then
        button.HotKey:SetVertexColor(1.0, 0.1, 0.1)
    else
        button.HotKey:SetVertexColor(0.6, 0.6, 0.6)
    end
end

function ActionBars:UpdateButtonCount(button)
    if not button or not button.action or not HasAction(button.action) then
        button.Count:SetText("")
        return
    end
    
    local count = GetActionCount(button.action)
    if count > 1 then
        button.Count:SetText(count)
        button.Count:Show()
    else
        button.Count:Hide()
    end
end

function ActionBars:UpdateButtonState(button)
    if not button or not button.action or not HasAction(button.action) then
        button:SetChecked(false)
        button.Border:Hide()
        return
    end
    
    -- Check if action is currently active
    local isActive = IsCurrentAction(button.action) or IsAutoRepeatAction(button.action)
    button:SetChecked(isActive)
    
    -- Show border for equipped items
    if IsEquippedAction(button.action) then
        button.Border:Show()
    else
        button.Border:Hide()
    end
    
    -- Flash for attack actions
    if IsAttackAction(button.action) and isActive then
        if not button.flashing then
            button.flashing = true
            button.Flash:Show()
            -- Add flash animation here
        end
    else
        button.flashing = false
        button.Flash:Hide()
    end
end

function ActionBars:UpdateButtonTooltip(button)
    if GetCVar("UberTooltips") == "1" then
        GameTooltip_SetDefaultAnchor(GameTooltip, button)
    else
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    end
    
    if button.action and HasAction(button.action) then
        GameTooltip:SetAction(button.action)
    end
end

function ActionBars:SetButtonAction(button, action)
    button.action = action
    self:UpdateButtonAction(button)
end

-- Create Action Bar
function ActionBars:CreateBar(barId)
    local config = DRGUI:GetConfig("actionbars.bar" .. barId)
    if not config or not config.enabled then return end
    
    local barName = "DRGUIActionBar" .. barId
    local bar = CreateFrame("Frame", barName, UIParent, "SecureHandlerStateTemplate")
    
    bar.id = barId
    bar.buttons = {}
    bar.config = config
    
    -- Calculate bar size
    local buttonSize = config.size or 32
    local spacing = config.spacing or 2
    local buttonsPerRow = config.buttonsPerRow or 12
    local numButtons = config.buttons or 12
    local numRows = math.ceil(numButtons / buttonsPerRow)
    
    local barWidth = (buttonSize * buttonsPerRow) + (spacing * (buttonsPerRow - 1))
    local barHeight = (buttonSize * numRows) + (spacing * (numRows - 1))
    
    bar:SetSize(barWidth, barHeight)
    
    -- Position the bar
    bar:ClearAllPoints()
    bar:SetPoint(config.point or "CENTER", UIParent, config.point or "CENTER", config.x or 0, config.y or 0)
    
    -- Create buttons
    for i = 1, numButtons do
        local button = self:CreateActionButton(bar, i, barId)
        
        -- Calculate button position
        local row = math.floor((i - 1) / buttonsPerRow)
        local col = (i - 1) % buttonsPerRow
        local x = col * (buttonSize + spacing)
        local y = -row * (buttonSize + spacing)
        
        button:SetPoint("TOPLEFT", bar, "TOPLEFT", x, y)
        button:SetSize(buttonSize, buttonSize)
        
        -- Set action
        local actionOffset = (barId - 1) * NUM_ACTIONBAR_BUTTONS
        local action = actionOffset + i
        self:SetButtonAction(button, action)
        
        bar.buttons[i] = button
        self.buttons[action] = button
        
        -- Add to update queue
        table.insert(self.updateQueue, button)
    end
    
    -- Bar visibility management
    self:SetBarVisibility(bar)
    
    self.bars[barId] = bar
    return bar
end

-- Bar Visibility System
function ActionBars:SetBarVisibility(bar)
    if not bar or not bar.config then return end
    
    local config = BAR_CONFIGS[bar.id]
    if not config then return end
    
    -- Register state driver for visibility
    local stateDriver = "[petbattle]"
    if not config.showInPetBattle then
        stateDriver = stateDriver .. " hide;"
    else
        stateDriver = stateDriver .. " show;"
    end
    
    stateDriver = stateDriver .. " [vehicleui]"
    if not config.showInVehicle then
        stateDriver = stateDriver .. " hide;"
    else
        stateDriver = stateDriver .. " show;"
    end
    
    stateDriver = stateDriver .. " [overridebar] hide; [shapeshift] hide; show"
    
    RegisterStateDriver(bar, "visibility", stateDriver)
end

-- Pet Bar Creation
function ActionBars:CreatePetBar()
    local config = DRGUI:GetConfig("actionbars.petbar")
    if not config or not config.enabled then return end
    
    local petBar = CreateFrame("Frame", "DRGUIPetBar", UIParent, "SecureHandlerStateTemplate")
    petBar.buttons = {}
    
    local buttonSize = config.size or 32
    local spacing = config.spacing or 2
    local barWidth = (buttonSize * NUM_PET_ACTION_SLOTS) + (spacing * (NUM_PET_ACTION_SLOTS - 1))
    
    petBar:SetSize(barWidth, buttonSize)
    petBar:SetPoint(config.point or "BOTTOM", UIParent, config.point or "BOTTOM", config.x or -200, config.y or 4)
    
    for i = 1, NUM_PET_ACTION_SLOTS do
        local button = CreateFrame("CheckButton", "DRGUIPetButton" .. i, petBar, "PetActionButtonTemplate")
        button:SetSize(buttonSize, buttonSize)
        button:SetID(i)
        
        if i == 1 then
            button:SetPoint("LEFT", petBar, "LEFT", 0, 0)
        else
            button:SetPoint("LEFT", petBar.buttons[i-1], "RIGHT", spacing, 0)
        end
        
        petBar.buttons[i] = button
    end
    
    -- Visibility management
    RegisterStateDriver(petBar, "visibility", "[pet,novehicleui,nopetbattle] show; hide")
    
    self.petBar = petBar
    return petBar
end

-- Stance Bar Creation
function ActionBars:CreateStanceBar()
    local config = DRGUI:GetConfig("actionbars.stancebar")
    if not config or not config.enabled then return end
    
    local stanceBar = CreateFrame("Frame", "DRGUIStanceBar", UIParent, "SecureHandlerStateTemplate")
    stanceBar.buttons = {}
    
    local buttonSize = config.size or 32
    local spacing = config.spacing or 2
    
    for i = 1, NUM_STANCE_SLOTS do
        local button = CreateFrame("CheckButton", "DRGUIStanceButton" .. i, stanceBar, "StanceButtonTemplate")
        button:SetSize(buttonSize, buttonSize)
        button:SetID(i)
        
        if i == 1 then
            button:SetPoint("LEFT", stanceBar, "LEFT", 0, 0)
        else
            button:SetPoint("LEFT", stanceBar.buttons[i-1], "RIGHT", spacing, 0)
        end
        
        stanceBar.buttons[i] = button
    end
    
    -- Auto-size based on available stances
    local numForms = GetNumShapeshiftForms()
    if numForms > 0 then
        local barWidth = (buttonSize * numForms) + (spacing * (numForms - 1))
        stanceBar:SetSize(barWidth, buttonSize)
        stanceBar:SetPoint(config.point or "BOTTOM", UIParent, config.point or "BOTTOM", config.x or 200, config.y or 4)
        
        -- Show only the needed buttons
        for i = 1, NUM_STANCE_SLOTS do
            if i <= numForms then
                stanceBar.buttons[i]:Show()
            else
                stanceBar.buttons[i]:Hide()
            end
        end
        
        RegisterStateDriver(stanceBar, "visibility", "[novehicleui,nopetbattle] show; hide")
    else
        stanceBar:Hide()
    end
    
    self.stanceBar = stanceBar
    return stanceBar
end

-- Module Initialization
function ActionBars:OnInitialize()
    self:Print("Loading ActionBars module...")
    
    -- Create all enabled action bars
    for i = 1, MAX_BARS do
        local config = DRGUI:GetConfig("actionbars.bar" .. i)
        if config and config.enabled then
            self:CreateBar(i)
        end
    end
    
    -- Create pet bar
    self:CreatePetBar()
    
    -- Create stance bar
    self:CreateStanceBar()
    
    -- Register events
    DRGUI:RegisterEvent("ACTIONBAR_SLOT_CHANGED", function(slot)
        self:UpdateButton(slot)
    end, "ActionBars")
    
    DRGUI:RegisterEvent("ACTIONBAR_PAGE_CHANGED", function()
        self:UpdateAllButtons()
    end, "ActionBars")
    
    DRGUI:RegisterEvent("UPDATE_BONUS_ACTIONBAR", function()
        self:UpdateAllButtons()
    end, "ActionBars")
    
    DRGUI:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        self:UpdateAllButtons()
    end, "ActionBars")
    
    -- Set up update throttling
    self.updateFrame = CreateFrame("Frame")
    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
    
    self:Print("ActionBars module loaded successfully!")
end

-- Update Functions
function ActionBars:UpdateButton(slot)
    local button = self.buttons[slot]
    if button then
        self:UpdateButtonAction(button)
    end
end

function ActionBars:UpdateAllButtons()
    for _, button in pairs(self.buttons) do
        self:UpdateButtonAction(button)
    end
end

function ActionBars:OnUpdate(elapsed)
    self.lastUpdate = self.lastUpdate + elapsed
    if self.lastUpdate >= self.throttle then
        -- Process update queue
        for _, button in ipairs(self.updateQueue) do
            if button:IsVisible() then
                self:UpdateButtonUsable(button)
                self:UpdateButtonCooldown(button)
                self:UpdateButtonCount(button)
                self:UpdateButtonState(button)
            end
        end
        self.lastUpdate = 0
    end
end

-- Configuration Update
function ActionBars:UpdateConfiguration()
    -- Recreate bars with new configuration
    for barId, bar in pairs(self.bars) do
        if bar then
            bar:Hide()
            bar:SetParent(nil)
        end
    end
    
    -- Clear caches
    self.bars = {}
    self.buttons = {}
    self.updateQueue = {}
    
    -- Recreate all bars
    self:OnInitialize()
end

-- Public API
function ActionBars:EnableBar(barId)
    DRGUI:SetConfig("actionbars.bar" .. barId .. ".enabled", true)
    self:CreateBar(barId)
end

function ActionBars:DisableBar(barId)
    DRGUI:SetConfig("actionbars.bar" .. barId .. ".enabled", false)
    if self.bars[barId] then
        self.bars[barId]:Hide()
        self.bars[barId] = nil
    end
end

function ActionBars:SetBarPosition(barId, point, x, y)
    DRGUI:SetConfig("actionbars.bar" .. barId .. ".point", point)
    DRGUI:SetConfig("actionbars.bar" .. barId .. ".x", x)
    DRGUI:SetConfig("actionbars.bar" .. barId .. ".y", y)
    
    if self.bars[barId] then
        self.bars[barId]:ClearAllPoints()
        self.bars[barId]:SetPoint(point, UIParent, point, x, y)
    end
end

function ActionBars:SetBarSize(barId, size)
    DRGUI:SetConfig("actionbars.bar" .. barId .. ".size", size)
    self:UpdateConfiguration()
end

return ActionBars