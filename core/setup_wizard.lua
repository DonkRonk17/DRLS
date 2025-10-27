-- DRGUI Setup Wizard
-- First-time configuration and dependency check

-- Use basic WoW UI frames instead of AceGUI (which isn't included)
local DRGUI = DRGUI or {}

-- Function to check if addon is loaded (with fallback)
local function IsAddonLoaded(addonName)
    local loaded1 = false
    local loaded2 = false
    
    -- Method 1: Use WoW's IsAddOnLoaded
    if _G.IsAddOnLoaded then
        loaded1 = _G.IsAddOnLoaded(addonName)
        print("DRGUI Debug: " .. addonName .. " via IsAddOnLoaded = " .. tostring(loaded1))
    end
    
    -- Method 2: Check global variable existence
    loaded2 = _G[addonName] ~= nil
    print("DRGUI Debug: " .. addonName .. " via global check = " .. tostring(loaded2))
    
    -- Method 3: Check for common addon globals
    local loaded3 = false
    if addonName == "DBM-Core" then
        loaded3 = _G.DBM ~= nil
        print("DRGUI Debug: DBM-Core via DBM global = " .. tostring(loaded3))
    elseif addonName == "Masque" then
        -- Masque has multiple ways it can be detected
        loaded3 = _G.Masque ~= nil or _G.LibMasque ~= nil or _G.MSQ ~= nil
        print("DRGUI Debug: Masque via Masque global = " .. tostring(_G.Masque ~= nil))
        print("DRGUI Debug: Masque via LibMasque global = " .. tostring(_G.LibMasque ~= nil))
        print("DRGUI Debug: Masque via MSQ global = " .. tostring(_G.MSQ ~= nil))
        print("DRGUI Debug: Masque final result = " .. tostring(loaded3))
    elseif addonName == "Details" then
        loaded3 = _G.Details ~= nil
        print("DRGUI Debug: Details via Details global = " .. tostring(loaded3))
    end
    
    -- Method 4: Check if we can find the addon folder (alternative approach)
    local loaded4 = false
    if not loaded1 and not loaded2 and not loaded3 then
        -- For Masque, also check if any Masque-related globals exist
        if addonName == "Masque" then
            -- Check for LibStub registered Masque
            if _G.LibStub then
                local masqueLib = _G.LibStub("Masque", true) -- true = silent, don't error if not found
                loaded4 = masqueLib ~= nil
                print("DRGUI Debug: Masque via LibStub = " .. tostring(loaded4))
            end
        end
    end
    
    local finalResult = loaded1 or loaded2 or loaded3 or loaded4
    print("DRGUI Debug: " .. addonName .. " FINAL RESULT = " .. tostring(finalResult))
    return finalResult
end

-- Function to get character combo (fallback if not available globally)
local function GetCharacterCombo()
    if _G.GetCharacterCombo then
        return _G.GetCharacterCombo()
    end
    
    -- Fallback implementation
    local race = UnitRace("player") or "Unknown"
    local class = UnitClass("player") or "Unknown"
    local spec = GetSpecialization() and GetSpecializationInfo(GetSpecialization()) or "Unknown"
    local heroID = "0000" -- Default hero ID
    
    return race .. "-" .. class .. "-" .. spec .. "-" .. heroID
end

-- Wizard state
local wizardFrame = nil
local wizardStep = 1
local maxSteps = 5

-- Create the main wizard frame using basic WoW UI
local function CreateWizardFrame()
    if wizardFrame then return wizardFrame end
    
    print("DRGUI Wizard: Creating wizard frame") -- Debug
    
    -- Create main frame
    wizardFrame = CreateFrame("Frame", "DRGUISetupWizard", UIParent, "BasicFrameTemplateWithInset")
    wizardFrame:SetSize(600, 500)
    wizardFrame:SetPoint("CENTER")
    wizardFrame:SetMovable(true)
    wizardFrame:EnableMouse(true)
    wizardFrame:RegisterForDrag("LeftButton")
    wizardFrame:SetScript("OnDragStart", wizardFrame.StartMoving)
    wizardFrame:SetScript("OnDragStop", wizardFrame.StopMovingOrSizing)
    
    -- Title
    wizardFrame.title = wizardFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    wizardFrame.title:SetPoint("TOP", 0, -5)
    wizardFrame.title:SetText("DRGUI Setup Wizard")
    
    -- Status text
    wizardFrame.status = wizardFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    wizardFrame.status:SetPoint("TOP", 0, -25)
    wizardFrame.status:SetText("Step " .. wizardStep .. " of " .. maxSteps)
    
    -- Content area
    wizardFrame.content = CreateFrame("ScrollFrame", nil, wizardFrame, "UIPanelScrollFrameTemplate")
    wizardFrame.content:SetPoint("TOPLEFT", 15, -50)
    wizardFrame.content:SetPoint("BOTTOMRIGHT", -35, 50)
    
    wizardFrame.contentChild = CreateFrame("Frame")
    wizardFrame.content:SetScrollChild(wizardFrame.contentChild)
    wizardFrame.contentChild:SetWidth(550)
    wizardFrame.contentChild:SetHeight(400)
    
    -- Button area
    wizardFrame.buttonFrame = CreateFrame("Frame", nil, wizardFrame)
    wizardFrame.buttonFrame:SetPoint("BOTTOMLEFT", 15, 10)
    wizardFrame.buttonFrame:SetPoint("BOTTOMRIGHT", -15, 10)
    wizardFrame.buttonFrame:SetHeight(30)
    
    print("DRGUI Wizard: Button frame created with size: " .. wizardFrame.buttonFrame:GetWidth() .. "x" .. wizardFrame.buttonFrame:GetHeight()) -- Debug
    
    -- Close button
    wizardFrame.CloseButton:SetScript("OnClick", function()
        wizardFrame:Hide()
        wizardFrame = nil
    end)
    
    print("DRGUI Wizard: Wizard frame created successfully") -- Debug
    return wizardFrame
end

-- Clear content area
local function ClearContent()
    print("DRGUI Wizard: Clearing content area") -- Debug
    
    -- Clear FontStrings created on contentChild
    local regions = {wizardFrame.contentChild:GetRegions()}
    print("DRGUI Wizard: Found " .. #regions .. " regions (FontStrings) to clear") -- Debug
    for i = 1, #regions do
        local region = regions[i]
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            region:Hide()
            region:SetParent(nil)
            region:ClearAllPoints()
        end
    end
    
    -- Clear child frames
    local children = {wizardFrame.contentChild:GetChildren()}
    print("DRGUI Wizard: Found " .. #children .. " content children to clear") -- Debug
    for i = 1, #children do
        children[i]:Hide()
        children[i]:SetParent(nil)
    end
    
    -- Clear button frames
    children = {wizardFrame.buttonFrame:GetChildren()}
    print("DRGUI Wizard: Found " .. #children .. " button children to clear") -- Debug
    for i = 1, #children do
        children[i]:Hide()
        children[i]:SetParent(nil)
    end
    print("DRGUI Wizard: Content clearing complete") -- Debug
end

-- Create a text block
local function CreateText(text, x, y, width, color)
    local fontString = wizardFrame.contentChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontString:SetPoint("TOPLEFT", x or 10, y or -10)
    fontString:SetWidth(width or 530)
    fontString:SetJustifyH("LEFT")
    fontString:SetWordWrap(true)  -- Enable word wrapping
    fontString:SetText(text)
    if color then
        fontString:SetTextColor(color.r, color.g, color.b)
    end
    return fontString
end

-- Create multiple text lines (for better spacing)
local function CreateTextLines(lines, startX, startY, width, lineHeight)
    local textElements = {}
    for i, line in ipairs(lines) do
        local y = startY - ((i - 1) * (lineHeight or 20))
        table.insert(textElements, CreateText(line, startX, y, width))
    end
    return textElements
end

-- Create a button
local function CreateButton(text, x, y, width, onClick)
    print("DRGUI Wizard: Creating button '" .. text .. "' at position (" .. (x or 0) .. ", " .. (y or 0) .. ")") -- Debug
    local button = CreateFrame("Button", nil, wizardFrame.buttonFrame, "GameMenuButtonTemplate")
    button:SetSize(width or 100, 25)
    button:SetPoint("BOTTOMLEFT", x or 0, y or 0)
    button:SetText(text)
    button:SetScript("OnClick", function()
        print("DRGUI Wizard: Button '" .. text .. "' clicked") -- Debug
        if onClick then
            onClick()
        else
            print("DRGUI Wizard: No onClick handler for button '" .. text .. "'")
        end
    end)
    print("DRGUI Wizard: Button '" .. text .. "' created successfully") -- Debug
    return button
end

-- Forward declarations
local ShowWelcomeStep, ShowDependencyStep, ShowProfileStep, ShowCustomizationStep, ShowFinishStep

-- Step 1: Welcome
ShowWelcomeStep = function()
    print("DRGUI Wizard: Showing Welcome Step") -- Debug
    local frame = CreateWizardFrame()
    ClearContent()
    frame.status:SetText("Step " .. wizardStep .. " of " .. maxSteps)
    
    CreateText("Welcome to DRGUI!", 10, -10, 530)
    CreateText("Welcome to DonkRonk & Grok User Interface!", 10, -40, 530)
    
    local currentY = -70
    CreateText("This wizard will help you:", 10, currentY, 530)
    currentY = currentY - 25
    CreateText("• Check and install required dependencies", 20, currentY, 510)
    currentY = currentY - 20
    CreateText("• Configure your first UI profile", 20, currentY, 510)
    currentY = currentY - 20
    CreateText("• Set up AI integration (optional)", 20, currentY, 510)
    currentY = currentY - 20
    CreateText("• Customize appearance settings", 20, currentY, 510)
    
    currentY = currentY - 30
    CreateText("Your character combo will be automatically detected:", 10, currentY, 530)
    currentY = currentY - 20
    CreateText("Race / Class / Spec / Hero Talents", 20, currentY, 510)
    
    currentY = currentY - 30
    CreateText("Click 'Next' to begin setup.", 10, currentY, 530)
    
    -- Next button
    CreateButton("Next >", 460, 5, 100, function()
        print("DRGUI Wizard: Next button clicked, moving to step 2") -- Debug
        wizardStep = 2
        ShowDependencyStep()
    end)
    
    -- Skip button
    CreateButton("Skip Wizard", 320, 5, 110, function()
        print("DRGUI Wizard: Skip button clicked") -- Debug
        frame:Hide()
        wizardFrame = nil
        print("DRGUI: Wizard skipped. Type /drgui help for commands.")
    end)
    
    frame:Show()
    print("DRGUI Wizard: Welcome step displayed") -- Debug
end

-- Step 2: Dependency Check
ShowDependencyStep = function()
    print("DRGUI Wizard: Showing Dependency Step") -- Debug
    local frame = CreateWizardFrame()
    ClearContent()
    frame.status:SetText("Step " .. wizardStep .. " of " .. maxSteps)
    
    CreateText("Dependency Check", 10, -10, 530)
    
    -- Check dependencies
    local requiredAddons = {"ElvUI", "Details", "WeakAuras"}
    local optionalAddons = {"DBM-Core", "Masque", "Bartender4", "Plater", "Hekili"}
    
    print("DRGUI Wizard: Starting dependency check") -- Debug
    
    local allGood = true
    local currentY = -40
    
    CreateText("Required Addons:", 10, currentY, 530)
    currentY = currentY - 25
    
    for _, addon in ipairs(requiredAddons) do
        local isLoaded = IsAddonLoaded(addon)
        print("DRGUI Wizard: Checking " .. addon .. " = " .. tostring(isLoaded)) -- Debug
        if isLoaded then
            CreateText("✓ " .. addon .. " - Installed", 20, currentY, 510, {r=0, g=1, b=0})
        else
            CreateText("✗ " .. addon .. " - MISSING", 20, currentY, 510, {r=1, g=0, b=0})
            allGood = false
        end
        currentY = currentY - 20
    end
    
    currentY = currentY - 10
    CreateText("Optional Addons:", 10, currentY, 530)
    currentY = currentY - 25
    
    for _, addon in ipairs(optionalAddons) do
        local isLoaded = IsAddonLoaded(addon)
        print("DRGUI Wizard: Checking " .. addon .. " = " .. tostring(isLoaded)) -- Debug
        if isLoaded then
            CreateText("✓ " .. addon .. " - Installed", 20, currentY, 510, {r=0, g=1, b=0})
        else
            CreateText("○ " .. addon .. " - Not installed", 20, currentY, 510, {r=0.8, g=0.8, b=0.8})
        end
        currentY = currentY - 20
    end
    
    if not allGood then
        currentY = currentY - 20
        CreateText("WARNING: Missing required dependencies!", 10, currentY, 530, {r=1, g=0.2, b=0.2})
        currentY = currentY - 20
        CreateText("You can continue setup, but some features may not work properly.", 10, currentY, 530, {r=1, g=0.2, b=0.2})
    end
    
    print("DRGUI Wizard: Creating navigation buttons") -- Debug
    
    -- Navigation
    CreateButton("< Back", 20, 5, 100, function()
        print("DRGUI Wizard: Back button clicked from step 2") -- Debug
        wizardStep = 1
        ShowWelcomeStep()
    end)
    
    CreateButton("Next >", 460, 5, 100, function()
        print("DRGUI Wizard: Next button clicked from step 2, moving to step 3") -- Debug
        wizardStep = 3
        ShowProfileStep()
    end)
    
    print("DRGUI Wizard: Dependency step displayed with buttons") -- Debug
end

-- Step 3: Profile Creation
ShowProfileStep = function()
    local frame = CreateWizardFrame()
    ClearContent()
    frame.status:SetText("Step " .. wizardStep .. " of " .. maxSteps)
    
    CreateText("Profile Setup", 10, -10, 530)
    
    local comboKey = GetCharacterCombo()
    
    CreateText("Your character combo detected:", 10, -40, 530)
    CreateText(comboKey, 20, -65, 510, {r=0, g=1, b=1})
    CreateText("A unique UI profile will be created for this combination.", 10, -95, 530)
    
    -- Navigation
    CreateButton("< Back", 20, 5, 100, function()
        wizardStep = 2
        ShowDependencyStep()
    end)
    
    CreateButton("Next >", 460, 5, 100, function()
        wizardStep = 4
        ShowCustomizationStep()
    end)
end

-- Step 4: Customization Options
ShowCustomizationStep = function()
    local frame = CreateWizardFrame()
    ClearContent()
    frame.status:SetText("Step " .. wizardStep .. " of " .. maxSteps)
    
    CreateText("Customization Options", 10, -10, 530)
    CreateText("Choose your UI style:", 10, -40, 530)
    
    local currentY = -70
    local buttonWidth = 200
    local buttonHeight = 40
    
    -- Store selected style globally for use in finish step
    if not selectedUIStyle then
        selectedUIStyle = "bushido" -- default
    end
    
    -- Bushido button
    local bushidoButton = CreateFrame("Button", nil, wizardFrame.contentChild, "GameMenuButtonTemplate")
    bushidoButton:SetSize(buttonWidth, buttonHeight)
    bushidoButton:SetPoint("TOPLEFT", 20, currentY)
    bushidoButton:SetText("Bushido (Minimalist)")
    bushidoButton:SetScript("OnClick", function()
        selectedUIStyle = "bushido"
        print("DRGUI Wizard: Bushido button clicked")
        print("DRGUI Debug: Checking DRGUI availability...")
        print("DRGUI Debug: _G.DRGUI exists: " .. tostring(_G.DRGUI ~= nil))
        if _G.DRGUI then
            print("DRGUI Debug: _G.DRGUI.UICustom exists: " .. tostring(_G.DRGUI.UICustom ~= nil))
            if _G.DRGUI.UICustom then
                print("DRGUI Debug: SetStyle function exists: " .. tostring(_G.DRGUI.UICustom.SetStyle ~= nil))
                print("DRGUI Debug: ApplySettings function exists: " .. tostring(_G.DRGUI.UICustom.ApplySettings ~= nil))
            end
        end
        
        -- Apply style using the proper workflow
        if _G.DRGUI and _G.DRGUI.UICustom then
            print("DRGUI Wizard: Calling SetStyle('bushido')...")
            local success = _G.DRGUI.UICustom:SetStyle("bushido")
            print("DRGUI Wizard: SetStyle result: " .. tostring(success))
            
            if success then
                print("DRGUI Wizard: SetStyle succeeded, now calling ApplySettings()...")
                _G.DRGUI.UICustom:ApplySettings()
                print("DRGUI Wizard: ApplySettings() completed")
            else
                print("DRGUI Wizard: SetStyle failed, not applying settings")
            end
        else
            print("DRGUI: UI customization system not available")
            print("DRGUI Debug: _G.DRGUI = " .. tostring(_G.DRGUI))
            if _G.DRGUI then
                print("DRGUI Debug: _G.DRGUI.UICustom = " .. tostring(_G.DRGUI.UICustom))
            end
        end
        
        -- Update visual feedback
        bushidoButton:SetText("✓ Bushido (Applied)")
        if actionButton then actionButton:SetText("Action Packed") end
        if elegantButton then elegantButton:SetText("Elegant") end
        if customButton then customButton:SetText("Custom") end
        
        print("DRGUI: Style application complete. UI will reload automatically...")
        -- Force immediate reload like Action button
        _G.ReloadUI()
    end)
    
    -- Action Packed button
    actionButton = CreateFrame("Button", nil, wizardFrame.contentChild, "GameMenuButtonTemplate")
    actionButton:SetSize(buttonWidth, buttonHeight)
    actionButton:SetPoint("TOPLEFT", 240, currentY)
    actionButton:SetText("Action Packed")
    actionButton:SetScript("OnClick", function()
        selectedUIStyle = "action"
        print("DRGUI Wizard: Applying Action style...")
        
        -- Apply style using the proper workflow
        if _G.DRGUI and _G.DRGUI.UICustom then
            _G.DRGUI.UICustom:SetStyle("action")
            _G.DRGUI.UICustom:ApplySettings()
        else
            print("DRGUI: UI customization system not available")
        end
        
        -- Update visual feedback
        if bushidoButton then bushidoButton:SetText("Bushido (Minimalist)") end
        actionButton:SetText("✓ Action Packed (Applied)")
        if elegantButton then elegantButton:SetText("Elegant") end
        if customButton then customButton:SetText("Custom") end
        
        print("DRGUI: Action style applied! UI will reload...")
        -- Reload UI to apply changes
        _G.ReloadUI()
    end)
    
    currentY = currentY - 50
    
    -- Elegant button
    elegantButton = CreateFrame("Button", nil, wizardFrame.contentChild, "GameMenuButtonTemplate")
    elegantButton:SetSize(buttonWidth, buttonHeight)
    elegantButton:SetPoint("TOPLEFT", 20, currentY)
    elegantButton:SetText("Elegant")
    elegantButton:SetScript("OnClick", function()
        selectedUIStyle = "elegant"
        print("DRGUI Wizard: Applying Elegant style...")
        
        -- Apply style using the proper workflow
        if _G.DRGUI and _G.DRGUI.UICustom then
            _G.DRGUI.UICustom:SetStyle("elegant")
            _G.DRGUI.UICustom:ApplySettings()
        else
            print("DRGUI: UI customization system not available")
        end
        
        -- Update visual feedback
        if bushidoButton then bushidoButton:SetText("Bushido (Minimalist)") end
        if actionButton then actionButton:SetText("Action Packed") end
        elegantButton:SetText("✓ Elegant (Applied)")
        if customButton then customButton:SetText("Custom") end
        
        print("DRGUI: Elegant style applied! UI will reload...")
        -- Reload UI to apply changes
        _G.ReloadUI()
    end)
    
    -- Custom button
    customButton = CreateFrame("Button", nil, wizardFrame.contentChild, "GameMenuButtonTemplate")
    customButton:SetSize(buttonWidth, buttonHeight)
    customButton:SetPoint("TOPLEFT", 240, currentY)
    customButton:SetText("Custom")
    customButton:SetScript("OnClick", function()
        selectedUIStyle = "custom"
        print("DRGUI Wizard: Opening custom configuration...")
        
        -- For custom, open the custom menu instead of applying a preset
        if _G.DRGUI and _G.DRGUI.UICustom and _G.DRGUI.UICustom.ShowMenu then
            _G.DRGUI.UICustom:ShowMenu()
        else
            print("DRGUI: Custom menu not available - use /drgui custom after setup")
        end
        
        -- Update visual feedback
        if bushidoButton then bushidoButton:SetText("Bushido (Minimalist)") end
        if actionButton then actionButton:SetText("Action Packed") end
        if elegantButton then elegantButton:SetText("Elegant") end
        customButton:SetText("✓ Custom (Menu Opened)")
        
        print("DRGUI: Custom configuration menu opened!")
        -- Note: No reload needed for custom menu opening
    end)
    
    -- Set default selection visual
    bushidoButton:SetText("✓ Bushido (Minimalist)")
    
    currentY = currentY - 70
    
    -- Description text
    CreateText("• Bushido: Clean, focused interface", 20, currentY, 510)
    CreateText("• Action: More visible elements and effects", 20, currentY - 20, 510)
    CreateText("• Elegant: Refined, sophisticated look", 20, currentY - 40, 510)
    CreateText("• Custom: Opens customization menu", 20, currentY - 60, 510)
    
    CreateText("Note: Clicking a style button applies it immediately!", 20, currentY - 90, 510, {r=1, g=1, b=0})
    CreateText("UI will reload automatically for preset styles.", 20, currentY - 110, 510, {r=0.7, g=0.7, b=0.7})
    
    -- Navigation
    CreateButton("< Back", 10, 0, 100, function()
        wizardStep = 3
        ShowProfileStep()
    end)
    
    CreateButton("Next >", 480, 0, 100, function()
        wizardStep = 5
        ShowFinishStep()
    end)
end

-- Step 5: Finish
ShowFinishStep = function()
    local frame = CreateWizardFrame()
    ClearContent()
    frame.status:SetText("Step " .. wizardStep .. " of " .. maxSteps)
    
    CreateText("Setup Complete!", 10, -10, 530)
    
    -- Show selected style
    local styleText = "Selected UI Style: " .. (selectedUIStyle or "Bushido")
    CreateText(styleText, 10, -40, 530, {r=0, g=1, b=0})
    
    CreateText([[Congratulations! DRGUI is ready to use.

Quick Tips:
• Type /drgui help to see all commands
• Type /drgui custom to customize settings
• Use /drgui backup to save your profile
• Your profile auto-saves when you log out

Resources:
• In-game: /drgui help
• Documentation: See AUTO_INSTALLER_GUIDE.txt
• Support: /r/wow or Blizzard Forums

Click 'Finish' to apply your settings and start using DRGUI!]], 10, -70, 530)
    
    -- Finish button
    CreateButton("Finish", 480, 0, 100, function()
        -- Create profile
        local comboKey = GetCharacterCombo()
        if _G.CreateOrLoadProfile then
            _G.CreateOrLoadProfile(comboKey)
        end
        
        -- Save wizard completion flag and selected style
        if _G.DRGUIDB then
            _G.DRGUIDB.wizardCompleted = true
            _G.DRGUIDB.selectedUIStyle = selectedUIStyle or "bushido"
        end
        
        print("DRGUI: Setup complete!")
        print("DRGUI: UI style was applied in Step 4. Type /drgui help for commands.")
        frame:Hide()
        wizardFrame = nil
    end)
    
    -- Back button
    CreateButton("< Back", 10, 0, 100, function()
        wizardStep = 4
        ShowCustomizationStep()
    end)
end

-- Public API
function DRGUI:ShowSetupWizard()
    -- Always use our custom wizard UI (no dependency on AceGUI)
    wizardStep = 1
    ShowWelcomeStep()
end

function DRGUI:ShouldShowWizard()
    return not (DRGUIDB and DRGUIDB.wizardCompleted)
end

-- Export
_G.DRGUI = DRGUI
