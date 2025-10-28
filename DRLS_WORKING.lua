---@diagnostic disable: undefined-global
local addonName, addon = ...

-- DRLS Revolutionary AI-Powered WoW Addon
DRLS = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

-- Initialize DRLS Database
DRLSDB = DRLSDB or {}
DRLS.db = DRLSDB

-- Revolutionary AI Core Components
DRLS.AI = nil
DRLS.EcosystemAnalyzer = nil

-- Revolutionary Constants
local DRLS_VERSION = "1.0.0"
local DRLS_BUILD = "REVOLUTIONARY"
local DEBUG_MODE = true

-- Revolutionary Manifesto Banner
local function ShowRevolutionaryBanner()
    print("|cffff0000=" .. string.rep("=", 60) .. "|r")
    print("|cffff0000🎯 DRLS - DONKRONK'S LAST SHOT 🎯|r")
    print("|cffff9900The World's First & Last AI-Powered WoW Addon|r")
    print("|cffff0000Version: " .. DRLS_VERSION .. " | Build: " .. DRLS_BUILD .. "|r")
    print("|cffff9900Revolutionary. Defiant. Unapologetic.|r")
    print("|cffff0000=" .. string.rep("=", 60) .. "|r")
end

-- Revolutionary AI System Initialization
local function InitializeRevolutionaryAI()
    print("|cffff9900🔧 DRLS: Starting AI system initialization...|r")
    
    -- Try to load AI Core
    local aiCorePath = "Interface/AddOns/DRLS/ai/drls_ai_core.lua"
    print("|cffff9900🔍 Attempting to load: " .. aiCorePath .. "|r")
    
    local success, aiCoreLoader = pcall(loadfile, aiCorePath)
    if success and aiCoreLoader then
        local aiCore = aiCoreLoader()
        if aiCore then
            print("|cff00ff00✅ DRLS AI Core: Loaded successfully|r")
            DRLS.AI = aiCore
            if aiCore.Initialize then
                aiCore:Initialize()
            end
        else
            print("|cffff9900⚠️ AI Core loaded but no return value, trying global access|r")
            DRLS.AI = _G.DRLS_AI_Core
        end
    else
        print("|cffff0000❌ Failed to load AI Core: " .. tostring(aiCoreLoader) .. "|r")
        DRLS.AI = _G.DRLS_AI_Core -- Fallback
    end
    
    -- Try to load Ecosystem Analyzer
    local ecoPath = "Interface/AddOns/DRLS/ai/ecosystem_analyzer.lua"
    print("|cffff9900🔍 Attempting to load: " .. ecoPath .. "|r")
    
    success, ecoLoader = pcall(loadfile, ecoPath)
    if success and ecoLoader then
        local ecoAnalyzer = ecoLoader()
        if ecoAnalyzer then
            print("|cff00ff00✅ Ecosystem Analyzer: Loaded successfully|r")
            DRLS.EcosystemAnalyzer = ecoAnalyzer
            if ecoAnalyzer.Initialize then
                ecoAnalyzer:Initialize()
            end
        else
            print("|cffff9900⚠️ Ecosystem Analyzer loaded but no return value, trying global access|r")
            DRLS.EcosystemAnalyzer = _G.DRLS_EcosystemAnalyzer
        end
    else
        print("|cffff0000❌ Failed to load Ecosystem Analyzer: " .. tostring(ecoLoader) .. "|r")
        DRLS.EcosystemAnalyzer = _G.DRLS_EcosystemAnalyzer -- Fallback
    end
    
    -- Final status check
    if DRLS.AI then
        print("|cff00ff00🚀 DRLS AI System: Ready for revolutionary operations!|r")
    else
        print("|cffff0000❌ DRLS AI System: Not available|r")
    end
end

-- Main Initialization
local function InitializeRevolution()
    print("|cffff0000🎯 DRLS: Revolution starting...|r")
    ShowRevolutionaryBanner()
    InitializeRevolutionaryAI()
    print("|cff00ff00🎯 DRLS: Revolutionary initialization complete!|r")
end

-- Event System
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        DRLSDB = DRLSDB or {}
        print("|cffff0000🎯 DRLS: Addon loaded - Revolution starting...|r")
    elseif event == "PLAYER_LOGIN" then
        InitializeRevolution()
    end
end)

-- Slash Commands
SLASH_DRLS1 = "/drls"
SlashCmdList["DRLS"] = function(msg)
    local command, args = msg:match("^(%S*)%s*(.-)$")
    
    if command == "ai" then
        if DRLS.AI then  
            DRLS.AI:ShowStatus()
        else
            print("|cffff0000🤖 DRLS AI: System not loaded|r")
        end
    elseif command == "help" or command == "" then
        print("|cffff0000=" .. string.rep("=", 50) .. "|r")
        print("|cffff0000🎯 DRLS - DONKRONK'S LAST SHOT|r")
        print("|cffff9900Revolutionary Commands:|r")
        print("|cff00ff00  /drls ai - AI system status|r")
        print("|cff00ff00  /drls help - Show this help|r")
        print("|cffff0000=" .. string.rep("=", 50) .. "|r")
    else
        print("|cffff0000❌ Unknown command: " .. command .. "|r")
        print("|cffff9900💡 Type /drls help for available commands|r")
    end
end