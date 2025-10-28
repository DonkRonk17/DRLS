local MAJOR, MINOR = "AceAddon-3.0", 5
local AceAddon, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceAddon then return end  -- No upgrade needed

AceAddon.frame = AceAddon.frame or CreateFrame("Frame", "AceAddon30Frame") -- Our very own frame
AceAddon.addons = AceAddon.addons or {} -- addons in the process of being initialized
AceAddon.statuses = AceAddon.statuses or {} -- addons' initialization status
AceAddon.initializequeue = AceAddon.initializequeue or {} -- addons waiting to be initialized
AceAddon.enablequeue = AceAddon.enablequeue or {} -- addons waiting to be enabled
AceAddon.embeds = AceAddon.embeds or {} -- contains a list of libraries embedded in an addon

-- local upvalues
local safecall = LibStub("AceConsole-3.0").safecall  -- Will replace with our own when done

-- to be continued... (full AceAddon-3.0.lua is ~500 lines; copy from source for real use)