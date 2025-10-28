-- =====================================================
-- DRLS English Localization (enUS)
-- Revolutionary Localization System
-- =====================================================

local L = LibStub("AceLocale-3.0"):NewLocale("DRLS", "enUS", true)
if not L then return end

-- Core Messages
L["DRLS_LOADED"] = "DRLS Revolutionary System Loaded!"
L["DRLS_ENABLED"] = "DRLS Revolutionary System Enabled!"
L["DRLS_DISABLED"] = "DRLS System Disabled"
L["DRLS_WELCOME"] = "Welcome to DRLS - DonkRonk's Last Shot!"

-- Commands
L["CMD_HELP"] = "help"
L["CMD_TOGGLE"] = "toggle" 
L["CMD_CONFIG"] = "config"
L["CMD_RESET"] = "reset"
L["CMD_STATUS"] = "status"

-- Help Text
L["HELP_HEADER"] = "DRLS Revolutionary Commands:"
L["HELP_TOGGLE"] = "/drls toggle - Toggle DRLS on/off"
L["HELP_CONFIG"] = "/drls config - Open configuration"
L["HELP_RESET"] = "/drls reset - Reset to defaults"
L["HELP_STATUS"] = "/drls status - Show system status"

-- Module Names
L["MODULE_ACTIONBARS"] = "Action Bars"
L["MODULE_UNITFRAMES"] = "Unit Frames"
L["MODULE_NAMEPLATES"] = "Nameplates"
L["MODULE_CHAT"] = "Chat System"
L["MODULE_MINIMAP"] = "Minimap"

-- Status Messages
L["STATUS_ENABLED"] = "Enabled"
L["STATUS_DISABLED"] = "Disabled"
L["STATUS_LOADING"] = "Loading..."
L["STATUS_ERROR"] = "Error"
L["STATUS_READY"] = "Ready"

-- Revolutionary Messages
L["REVOLUTIONARY_GREETING"] = "Revolutionary UI System Activated!"
L["REVOLUTIONARY_OPTIMIZE"] = "Revolutionary Optimization Complete!"
L["REVOLUTIONARY_AI"] = "AI Systems Online!"
L["REVOLUTIONARY_PERFORMANCE"] = "Performance Enhancement Active!"

-- Error Messages
L["ERROR_LOAD_FAILED"] = "Failed to load module: %s"
L["ERROR_CONFIG_FAILED"] = "Configuration error in module: %s"
L["ERROR_DEPENDENCY"] = "Missing dependency: %s"

-- Success Messages
L["SUCCESS_LOADED"] = "Successfully loaded: %s"
L["SUCCESS_ENABLED"] = "Successfully enabled: %s"
L["SUCCESS_RESET"] = "Successfully reset configuration"
L["SUCCESS_SAVED"] = "Configuration saved successfully"