-- AceConsole-3.0 - Console command handling
local MAJOR, MINOR = "AceConsole-3.0", 7
local AceConsole = LibStub:NewLibrary(MAJOR, MINOR)
if not AceConsole then return end

function AceConsole:RegisterChatCommand(command, func)
    SlashCmdList[command] = func
    _G["SLASH_"..command.."1"] = "/"..command:lower()
end

function AceConsole:Print(...)
    print(...)
end