-- DRGUI In-Game Script Launcher
-- Provides in-game interface to run Python scripts

local DRGUI = DRGUI or {}
DRGUI.ScriptLauncher = {}

-- Launch Python script with parameters
function DRGUI.ScriptLauncher:LaunchScript(scriptName, args)
    local scriptsPath = "Interface\\AddOns\\DRGUI\\scripts\\"
    local command = "python " .. scriptsPath .. scriptName
    
    if args then
        command = command .. " " .. args
    end
    
    print("=" .. string.rep("=", 50))
    print("DRGUI Script Launcher")
    print("=" .. string.rep("=", 50))
    print("Script: " .. scriptName)
    print("")
    print("To run this script:")
    print("1. Close World of Warcraft")
    print("2. Open Command Prompt / PowerShell")
    print("3. Run this command:")
    print("")
    print(command)
    print("")
    print("=" .. string.rep("=", 50))
    
    return command
end

-- Quick launchers for common scripts
function DRGUI:LaunchInstaller()
    DRGUI.ScriptLauncher:LaunchScript("drgui_dependency_installer.py", "--required-only")
end

function DRGUI:LaunchCodeGen(comboKey)
    comboKey = comboKey or GetCharacterCombo()
    DRGUI.ScriptLauncher:LaunchScript("drgui_code_gen.py", comboKey)
end

function DRGUI:LaunchImageGen(comboKey)
    comboKey = comboKey or GetCharacterCombo()
    DRGUI.ScriptLauncher:LaunchScript("drgui_image_gen.py", comboKey)
end

function DRGUI:LaunchIntegrations(comboKey)
    comboKey = comboKey or GetCharacterCombo()
    DRGUI.ScriptLauncher:LaunchScript("drgui_integrations.py", comboKey)
end

-- Export
_G.DRGUI = DRGUI
