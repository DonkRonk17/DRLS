-- DRGUI UI Customization Options
-- In-game customization panel for UI settings

local DRGUI = DRGUI or {}
DRGUI.UICustom = {}

-- Initialize customization settings
DRGUIDB.customization = DRGUIDB.customization or {
    style = "bushido",
    enableAnimations = true,
    enableDetailsIntegration = true,
    enableWeakAurasGlow = true,
    fontSize = 12,
    uiScale = 1.0,
    borderStyle = "default",
    colorTheme = "default"
}

-- UI Styles
local UI_STYLES = {
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
function DRGUI.UICustom:ApplySettings()
    local settings = DRGUIDB.customization
    local comboKey = GetCharacterCombo()
    
    if not DRGUIDB[comboKey] then return end
    
    -- Apply font size
    DRGUIDB[comboKey].general.fontSize = settings.fontSize
    
    -- Apply UI scale
    DRGUIDB[comboKey].general.uiScale = settings.uiScale
    
    -- Apply style-specific settings
    if settings.style == "bushido" then
        DRGUIDB[comboKey].general.font = "Expressway"
        DRGUIDB[comboKey].actionbar.bar1.alpha = 0.9
    elseif settings.style == "action" then
        DRGUIDB[comboKey].actionbar.bar1.alpha = 1.0
        DRGUIDB[comboKey].general.font = "Arial Narrow"
    elseif settings.style == "elegant" then
        DRGUIDB[comboKey].general.font = "PT Sans Narrow"
        DRGUIDB[comboKey].actionbar.bar1.alpha = 0.85
    end
    
    print("DRGUI: Customization applied. Type /reload to see changes.")
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
function DRGUI.UICustom:SetStyle(style)
    if UI_STYLES[style] then
        DRGUIDB.customization.style = style
        print("DRGUI: UI Style set to " .. UI_STYLES[style].name)
        print("Run /drgui apply to apply changes")
        return true
    else
        print("DRGUI: Invalid style. Options: bushido, action, elegant, custom")
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
