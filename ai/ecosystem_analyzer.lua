-- DRLS Ecosystem Analyzer - Fresh Version  
local DRLS_EcosystemAnalyzer = {}

function DRLS_EcosystemAnalyzer:Initialize()
    print("Ecosystem Analyzer: Revolutionary intelligence activated!")
    return true
end

function DRLS_EcosystemAnalyzer:ShowAnalysis()
    local totalAddons = 0
    local categories = {
        combat = 0,
        ui = 0, 
        boss = 0,
        damage = 0,
        utility = 0
    }
    
    if GetNumAddOns and GetAddOnInfo and IsAddOnLoaded then
        for i = 1, GetNumAddOns() do
            local name, title, notes = GetAddOnInfo(i)
            if name and IsAddOnLoaded(name) then
                totalAddons = totalAddons + 1
                
                local lowerName = string.lower(name)
                local lowerTitle = string.lower(title or "")
                
                if string.find(lowerName, "combat") or string.find(lowerTitle, "combat") then
                    categories.combat = categories.combat + 1
                elseif string.find(lowerName, "ui") or string.find(lowerTitle, "ui") then
                    categories.ui = categories.ui + 1
                elseif string.find(lowerName, "boss") or string.find(lowerName, "dbm") then
                    categories.boss = categories.boss + 1
                elseif string.find(lowerName, "damage") or string.find(lowerName, "details") then
                    categories.damage = categories.damage + 1
                else
                    categories.utility = categories.utility + 1
                end
            end
        end
    end
    
    print("DRLS Revolutionary Ecosystem Analysis:")
    print("Total Addons Analyzed: " .. totalAddons)
    print("Combat Enhancement: " .. categories.combat)
    print("UI Frameworks: " .. categories.ui)
    print("Boss Mods: " .. categories.boss)
    print("Damage Meters: " .. categories.damage)
    print("Utility: " .. categories.utility)
    print("This level of intelligence will be IMPOSSIBLE under Blizzard's restrictions!")
end

_G.DRLS_EcosystemAnalyzer = DRLS_EcosystemAnalyzer
return DRLS_EcosystemAnalyzer
