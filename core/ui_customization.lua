-- DRGUI UI Customization Options
-- In-game customization panel for UI settings

-- Ensure DRGUI is global and available
if not _G.DRGUI then
    _G.DRGUI = {}
end
_G.DRGUI.UICustom = {}

-- Initialize customization settings
if not _G.DRGUIDB then
    print("DRGUI Debug: Creating DRGUIDB table")
    _G.DRGUIDB = {}
end

if not _G.DRGUIDB.customization then
    print("DRGUI Debug: Creating DRGUIDB.customization table")
    _G.DRGUIDB.customization = {
        style = "bushido",
        enableAnimations = true,
        enableDetailsIntegration = true,
        enableWeakAurasGlow = true,
        fontSize = 12,
        uiScale = 1.0,
        borderStyle = "default",
        colorTheme = "default"
    }
else
    print("DRGUI Debug: DRGUIDB.customization already exists")
end

-- UI Styles - Make this accessible to all functions
_G.DRGUI.UI_STYLES = {
    bushido = {
        name = "Bushido (Minimalist)",
        description = "Clean, minimalistic interface with Bushido aesthetics"
    },
    action = {
        name = "Action Packed",
        description = "Bold, dynamic interface with prominent animations"
    },
    elegant = {
        name = "Elegant",
        description = "Refined, sophisticated interface design"
    },
    custom = {
        name = "Custom",
        description = "Fully customizable - tweak every setting"
    }
}

-- Apply customization settings
function _G.DRGUI.UICustom:ApplySettings()
    print("DRGUI Debug: ApplySettings called")
    print("DRGUI Debug: _G.DRGUIDB exists: " .. tostring(_G.DRGUIDB ~= nil))
    print("DRGUI Debug: _G.DRGUIDB.customization exists: " .. tostring(_G.DRGUIDB.customization ~= nil))
    
    if not _G.DRGUIDB or not _G.DRGUIDB.customization then
        print("DRGUI Error: Database or customization table missing!")
        return
    end
    
    local settings = _G.DRGUIDB.customization
    print("DRGUI Debug: Current style setting = " .. tostring(settings.style))
    
    -- Get character combo key
    local comboKey = nil
    print("DRGUI Debug: _G.GetCharacterCombo exists: " .. tostring(_G.GetCharacterCombo ~= nil))
    if _G.GetCharacterCombo then
        comboKey = _G.GetCharacterCombo()
        print("DRGUI Debug: Character combo key = " .. tostring(comboKey))
    else
        print("DRGUI Debug: GetCharacterCombo function not available")
        return
    end
    
    -- Check if profile exists
    if not _G.DRGUIDB[comboKey] then 
        print("DRGUI Debug: Profile " .. tostring(comboKey) .. " does not exist, creating basic profile")
        _G.DRGUIDB[comboKey] = {
            general = {},
            actionbar = { bar1 = {} }
        }
    end
    
    print("DRGUI Debug: Applying settings to profile...")
    
    -- Apply font size
    _G.DRGUIDB[comboKey].general.fontSize = settings.fontSize
    
    -- Apply UI scale
    _G.DRGUIDB[comboKey].general.uiScale = settings.uiScale
    
    -- Apply style-specific settings
    if settings.style == "bushido" then
        _G.DRGUIDB[comboKey].general.font = "Expressway"
        _G.DRGUIDB[comboKey].actionbar.bar1.alpha = 0.9
        print("DRGUI Debug: Applied Bushido style settings")
    elseif settings.style == "action" then
        _G.DRGUIDB[comboKey].actionbar.bar1.alpha = 1.0
        _G.DRGUIDB[comboKey].general.font = "Arial Narrow"
        print("DRGUI Debug: Applied Action style settings")
    elseif settings.style == "elegant" then
        _G.DRGUIDB[comboKey].general.font = "PT Sans Narrow"
        _G.DRGUIDB[comboKey].actionbar.bar1.alpha = 0.85
        print("DRGUI Debug: Applied Elegant style settings")
    end
    
    print("DRGUI: Customization applied to database. Triggering reload...")
    -- Force a reload to apply changes
    C_Timer.After(1, function()
        print("DRGUI: Reloading UI to apply " .. settings.style .. " style...")
        _G.ReloadUI()
    end)
end

-- Show customization menu
function DRGUI.UICustom:ShowMenu()
    print("=" .. string.rep("=", 50))
    print("DRGUI UI Customization")
    print("=" .. string.rep("=", 50))
    print("")
    print("Current Settings:")
    print("  Style: " .. DRGUIDB.customization.style)
    print("  Animations: " .. (DRGUIDB.customization.enableAnimations and "Enabled" or "Disabled"))
    print("  Details Integration: " .. (DRGUIDB.customization.enableDetailsIntegration and "Enabled" or "Disabled"))
    print("  Font Size: " .. DRGUIDB.customization.fontSize)
    print("  UI Scale: " .. DRGUIDB.customization.uiScale)
    print("")
    print("Commands:")
    print("  /drgui setstyle <bushido|action|elegant|custom>")
    print("  /drgui toggleanims - Toggle animations")
    print("  /drgui fontsize <size> - Set font size (8-20)")
    print("  /drgui uiscale <scale> - Set UI scale (0.5-1.5)")
    print("  /drgui apply - Apply all changes")
    print("=" .. string.rep("=", 50))
end

-- Set UI style
function _G.DRGUI.UICustom:SetStyle(style)
    print("DRGUI Debug: SetStyle called with style = '" .. tostring(style) .. "'")
    print("DRGUI Debug: UI_STYLES table exists: " .. tostring(_G.DRGUI.UI_STYLES ~= nil))
    
    if _G.DRGUI.UI_STYLES then
        print("DRGUI Debug: Available styles in UI_STYLES:")
        for k, v in pairs(_G.DRGUI.UI_STYLES) do
            print("  - " .. tostring(k) .. " = " .. tostring(v.name))
        end
        print("DRGUI Debug: Looking for style '" .. tostring(style) .. "'")
        print("DRGUI Debug: UI_STYLES['" .. tostring(style) .. "'] = " .. tostring(_G.DRGUI.UI_STYLES[style]))
    else
        print("DRGUI Debug: UI_STYLES table is nil!")
        return false
    end
    
    if _G.DRGUI.UI_STYLES[style] then
        print("DRGUI Debug: Style found, setting customization...")
        print("DRGUI Debug: _G.DRGUIDB exists: " .. tostring(_G.DRGUIDB ~= nil))
        print("DRGUI Debug: _G.DRGUIDB.customization exists: " .. tostring(_G.DRGUIDB.customization ~= nil))
        
        -- Ensure customization table exists
        if not _G.DRGUIDB.customization then
            print("DRGUI Debug: Creating missing customization table")
            _G.DRGUIDB.customization = {
                style = "bushido",
                enableAnimations = true,
                enableDetailsIntegration = true,
                enableWeakAurasGlow = true,
                fontSize = 12,
                uiScale = 1.0,
                borderStyle = "default",
                colorTheme = "default"
            }
        end
        
        _G.DRGUIDB.customization.style = style
        print("DRGUI Debug: Style set to: " .. tostring(_G.DRGUIDB.customization.style))
        print("DRGUI: UI Style set to " .. _G.DRGUI.UI_STYLES[style].name)
        print("Run /drgui apply to apply changes")
        return true
    else
        print("DRGUI: Invalid style '" .. tostring(style) .. "'. Options: bushido, action, elegant, custom")
        print("DRGUI Debug: Available styles:")
        if _G.DRGUI.UI_STYLES then
            for k, v in pairs(_G.DRGUI.UI_STYLES) do
                print("  - " .. k .. ": " .. v.name)
            end
        end
        return false
    end
end

-- Toggle animations
function DRGUI.UICustom:ToggleAnimations()
    DRGUIDB.customization.enableAnimations = not DRGUIDB.customization.enableAnimations
    print("DRGUI: Animations " .. (DRGUIDB.customization.enableAnimations and "enabled" or "disabled"))
end

-- Set font size
function DRGUI.UICustom:SetFontSize(size)
    size = tonumber(size)
    if size and size >= 8 and size <= 20 then
        DRGUIDB.customization.fontSize = size
        print("DRGUI: Font size set to " .. size)
        print("Run /drgui apply to apply changes")
        return true
    else
        print("DRGUI: Invalid font size. Use 8-20")
        return false
    end
end

-- Set UI scale
function DRGUI.UICustom:SetUIScale(scale)
    scale = tonumber(scale)
    if scale and scale >= 0.5 and scale <= 1.5 then
        DRGUIDB.customization.uiScale = scale
        print("DRGUI: UI Scale set to " .. scale)
        print("Run /drgui apply to apply changes")
        return true
    else
        print("DRGUI: Invalid scale. Use 0.5-1.5")
        return false
    end
end

-- Export
_G.DRGUI = DRGUI
