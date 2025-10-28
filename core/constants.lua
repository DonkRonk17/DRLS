-- =====================================================
-- DRLS Constants
-- Revolutionary System Constants
-- =====================================================

local DRLS = LibStub("AceAddon-3.0"):GetAddon("DRLS")
if not DRLS then return end

DRLS.Constants = {
    -- Version Information
    VERSION = "1.0.0",
    BUILD = "Revolutionary",
    AUTHOR = "DonkRonk17",
    
    -- UI Constants
    DEFAULT_FONT = "Fonts\\FRIZQT__.TTF",
    DEFAULT_FONT_SIZE = 12,
    DEFAULT_FONT_FLAGS = "OUTLINE",
    
    -- Colors
    COLORS = {
        PRIMARY = {r = 0.09, g = 0.51, b = 0.82}, -- #1784d1
        SUCCESS = {r = 0, g = 1, b = 0},
        WARNING = {r = 1, g = 1, b = 0},
        ERROR = {r = 1, g = 0, b = 0},
        TEXT = {r = 1, g = 1, b = 1}
    },
    
    -- Frame Sizes
    FRAME_SIZES = {
        ACTIONBAR_BUTTON = 32,
        UNITFRAME_WIDTH = 230,
        UNITFRAME_HEIGHT = 55,
        NAMEPLATE_WIDTH = 110,
        NAMEPLATE_HEIGHT = 15
    },
    
    -- Events
    EVENTS = {
        PLAYER_LOGIN = "PLAYER_LOGIN",
        ADDON_LOADED = "ADDON_LOADED",
        PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD",
        ZONE_CHANGED = "ZONE_CHANGED_NEW_AREA"
    },
    
    -- Module Names
    MODULES = {
        ACTIONBARS = "ActionBars",
        UNITFRAMES = "UnitFrames", 
        NAMEPLATES = "Nameplates",
        CHAT = "Chat",
        MINIMAP = "Minimap"
    },
    
    -- Database Keys
    DB_KEYS = {
        PROFILES = "profiles",
        GLOBAL = "global",
        CHARACTERS = "characters"
    },
    
    -- Revolutionary Constants
    REVOLUTIONARY = {
        AI_ENABLED = true,
        PERFORMANCE_MODE = true,
        ADVANCED_FEATURES = true,
        COMPATIBILITY_MODE = false
    }
}

-- Export Constants
DRLS.C = DRLS.Constants