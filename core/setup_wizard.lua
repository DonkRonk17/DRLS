-- DRGUI Setup Wizard
-- First-time configuration and dependency check

local AceGUI = LibStub("AceGUI-3.0")
local DRGUI = DRGUI or {}

-- Wizard state
local wizardFrame = nil
local wizardStep = 1
local maxSteps = 5

-- Create the main wizard frame
local function CreateWizardFrame()
    if wizardFrame then return wizardFrame end
    
    wizardFrame = AceGUI:Create("Frame")
    wizardFrame:SetTitle("DRGUI Setup Wizard")
    wizardFrame:SetStatusText("Step " .. wizardStep .. " of " .. maxSteps)
    wizardFrame:SetLayout("Flow")
    wizardFrame:SetWidth(600)
    wizardFrame:SetHeight(500)
    wizardFrame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        wizardFrame = nil
    end)
    
    return wizardFrame
end

-- Step 1: Welcome
local function ShowWelcomeStep()
    local frame = CreateWizardFrame()
    frame:ReleaseChildren()
    
    local heading = AceGUI:Create("Heading")
    heading:SetText("Welcome to DRGUI!")
    heading:SetFullWidth(true)
    frame:AddChild(heading)
    
    local label = AceGUI:Create("Label")
    label:SetText([[
Welcome to DonkRonk & Grok User Interface!

This wizard will help you:
• Check and install required dependencies
• Configure your first UI profile
• Set up AI integration (optional)
• Customize appearance settings

Your character combo will be automatically detected:
Race / Class / Spec / Hero Talents

Click 'Next' to begin setup.
]])
    label:SetFullWidth(true)
    frame:AddChild(label)
    
    -- Next button
    local nextBtn = AceGUI:Create("Button")
    nextBtn:SetText("Next >")
    nextBtn:SetWidth(100)
    nextBtn:SetCallback("OnClick", function()
        wizardStep = 2
        ShowDependencyStep()
    end)
    frame:AddChild(nextBtn)
    
    -- Skip button
    local skipBtn = AceGUI:Create("Button")
    skipBtn:SetText("Skip Wizard")
    skipBtn:SetWidth(100)
    skipBtn:SetCallback("OnClick", function()
        frame:Hide()
        print("DRGUI: Wizard skipped. Type /drgui help for commands.")
    end)
    frame:AddChild(skipBtn)
end

-- Step 2: Dependency Check
local function ShowDependencyStep()
    local frame = CreateWizardFrame()
    frame:ReleaseChildren()
    frame:SetStatusText("Step " .. wizardStep .. " of " .. maxSteps)
    
    local heading = AceGUI:Create("Heading")
    heading:SetText("Dependency Check")
    heading:SetFullWidth(true)
    frame:AddChild(heading)
    
    -- Check dependencies
    local requiredAddons = {"ElvUI", "Details", "WeakAuras"}
    local optionalAddons = {"DBM-Core", "Masque", "Bartender4", "Plater", "Hekili"}
    
    local allGood = true
    local status = "Checking dependencies...\n\n"
    
    status = status .. "Required Addons:\n"
    for _, addon in ipairs(requiredAddons) do
        if IsAddOnLoaded(addon) then
            status = status .. "✓ " .. addon .. " - Installed\n"
        else
            status = status .. "✗ " .. addon .. " - MISSING\n"
            allGood = false
        end
    end
    
    status = status .. "\nOptional Addons:\n"
    for _, addon in ipairs(optionalAddons) do
        if IsAddOnLoaded(addon) then
            status = status .. "✓ " .. addon .. " - Installed\n"
        else
            status = status .. "○ " .. addon .. " - Not installed\n"
        end
    end
    
    local label = AceGUI:Create("Label")
    label:SetText(status)
    label:SetFullWidth(true)
    frame:AddChild(label)
    
    if not allGood then
        local warning = AceGUI:Create("Label")
        warning:SetText("\nWARNING: Missing required dependencies!\n\nInstall Options:")
        warning:SetColor(1, 0.2, 0.2)
        warning:SetFullWidth(true)
        frame:AddChild(warning)
        
        -- Auto-installer button
        local installBtn = AceGUI:Create("Button")
        installBtn:SetText("Run Auto-Installer (Recommended)")
        installBtn:SetFullWidth(true)
        installBtn:SetCallback("OnClick", function()
            DRGUI:LaunchInstaller()
        end)
        frame:AddChild(installBtn)
        
        -- Manual instructions button
        local manualBtn = AceGUI:Create("Button")
        manualBtn:SetText("Show Manual Instructions")
        manualBtn:SetFullWidth(true)
        manualBtn:SetCallback("OnClick", function()
            SlashCmdList["DRGUI"]("install")
        end)
        frame:AddChild(manualBtn)
    end
    
    -- Navigation
    local backBtn = AceGUI:Create("Button")
    backBtn:SetText("< Back")
    backBtn:SetWidth(100)
    backBtn:SetCallback("OnClick", function()
        wizardStep = 1
        ShowWelcomeStep()
    end)
    frame:AddChild(backBtn)
    
    if allGood then
        local nextBtn = AceGUI:Create("Button")
        nextBtn:SetText("Next >")
        nextBtn:SetWidth(100)
        nextBtn:SetCallback("OnClick", function()
            wizardStep = 3
            ShowProfileStep()
        end)
        frame:AddChild(nextBtn)
    end
end

-- Step 3: Profile Creation
local function ShowProfileStep()
    local frame = CreateWizardFrame()
    frame:ReleaseChildren()
    frame:SetStatusText("Step " .. wizardStep .. " of " .. maxSteps)
    
    local heading = AceGUI:Create("Heading")
    heading:SetText("Profile Setup")
    heading:SetFullWidth(true)
    frame:AddChild(heading)
    
    local comboKey = GetCharacterCombo()
    
    local label = AceGUI:Create("Label")
    label:SetText("Your character combo detected:\n\n" .. comboKey .. "\n\nA unique UI profile will be created for this combination.")
    label:SetFullWidth(true)
    frame:AddChild(label)
    
    -- Profile name input
    local nameInput = AceGUI:Create("EditBox")
    nameInput:SetLabel("Profile Name (Optional)")
    nameInput:SetText(comboKey)
    nameInput:SetFullWidth(true)
    frame:AddChild(nameInput)
    
    -- Navigation
    local backBtn = AceGUI:Create("Button")
    backBtn:SetText("< Back")
    backBtn:SetWidth(100)
    backBtn:SetCallback("OnClick", function()
        wizardStep = 2
        ShowDependencyStep()
    end)
    frame:AddChild(backBtn)
    
    local nextBtn = AceGUI:Create("Button")
    nextBtn:SetText("Next >")
    nextBtn:SetWidth(100)
    nextBtn:SetCallback("OnClick", function()
        wizardStep = 4
        ShowCustomizationStep()
    end)
    frame:AddChild(nextBtn)
end

-- Step 4: Customization Options
local function ShowCustomizationStep()
    local frame = CreateWizardFrame()
    frame:ReleaseChildren()
    frame:SetStatusText("Step " .. wizardStep .. " of " .. maxSteps)
    
    local heading = AceGUI:Create("Heading")
    heading:SetText("Customization Options")
    heading:SetFullWidth(true)
    frame:AddChild(heading)
    
    local label = AceGUI:Create("Label")
    label:SetText("Choose your UI style and preferences:")
    label:SetFullWidth(true)
    frame:AddChild(label)
    
    -- Style dropdown
    local styleDropdown = AceGUI:Create("Dropdown")
    styleDropdown:SetLabel("UI Style")
    styleDropdown:SetList({
        ["bushido"] = "Bushido (Minimalist)",
        ["action"] = "Action Packed",
        ["elegant"] = "Elegant",
        ["custom"] = "Custom"
    })
    styleDropdown:SetValue("bushido")
    styleDropdown:SetFullWidth(true)
    frame:AddChild(styleDropdown)
    
    -- Animation checkbox
    local animCheck = AceGUI:Create("CheckBox")
    animCheck:SetLabel("Enable Proc Animations")
    animCheck:SetValue(true)
    animCheck:SetFullWidth(true)
    frame:AddChild(animCheck)
    
    -- Details integration checkbox
    local detailsCheck = AceGUI:Create("CheckBox")
    detailsCheck:SetLabel("Enable Details! Real-time Stats")
    detailsCheck:SetValue(true)
    detailsCheck:SetFullWidth(true)
    frame:AddChild(detailsCheck)
    
    -- Navigation
    local backBtn = AceGUI:Create("Button")
    backBtn:SetText("< Back")
    backBtn:SetWidth(100)
    backBtn:SetCallback("OnClick", function()
        wizardStep = 3
        ShowProfileStep()
    end)
    frame:AddChild(backBtn)
    
    local nextBtn = AceGUI:Create("Button")
    nextBtn:SetText("Next >")
    nextBtn:SetWidth(100)
    nextBtn:SetCallback("OnClick", function()
        wizardStep = 5
        ShowFinishStep()
    end)
    frame:AddChild(nextBtn)
end

-- Step 5: Finish
local function ShowFinishStep()
    local frame = CreateWizardFrame()
    frame:ReleaseChildren()
    frame:SetStatusText("Step " .. wizardStep .. " of " .. maxSteps)
    
    local heading = AceGUI:Create("Heading")
    heading:SetText("Setup Complete!")
    heading:SetFullWidth(true)
    frame:AddChild(heading)
    
    local label = AceGUI:Create("Label")
    label:SetText([[
Congratulations! DRGUI is ready to use.

Quick Tips:
• Type /drgui help to see all commands
• Type /drgui config to customize settings
• Use /drgui backup to save your profile
• Your profile auto-saves when you log out

Resources:
• In-game: /drgui help
• Documentation: See AUTO_INSTALLER_GUIDE.txt
• Support: /r/wow or Blizzard Forums

Click 'Finish' to start using DRGUI!
]])
    label:SetFullWidth(true)
    frame:AddChild(label)
    
    -- Finish button
    local finishBtn = AceGUI:Create("Button")
    finishBtn:SetText("Finish")
    finishBtn:SetWidth(150)
    finishBtn:SetCallback("OnClick", function()
        -- Create profile
        local comboKey = GetCharacterCombo()
        CreateOrLoadProfile(comboKey)
        
        -- Save wizard completion flag
        DRGUIDB.wizardCompleted = true
        
        print("DRGUI: Setup complete! Type /drgui help for commands.")
        frame:Hide()
    end)
    frame:AddChild(finishBtn)
    
    -- Back button
    local backBtn = AceGUI:Create("Button")
    backBtn:SetText("< Back")
    backBtn:SetWidth(100)
    backBtn:SetCallback("OnClick", function()
        wizardStep = 4
        ShowCustomizationStep()
    end)
    frame:AddChild(backBtn)
end

-- Public API
function DRGUI:ShowSetupWizard()
    wizardStep = 1
    ShowWelcomeStep()
end

function DRGUI:ShouldShowWizard()
    return not DRGUIDB.wizardCompleted
end

-- Export
_G.DRGUI = DRGUI
