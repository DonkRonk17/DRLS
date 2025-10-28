-- Test file to isolate syntax error
local PM = {}

local function GetHeroTalentInfo()
    local heroID = nil
    local heroName = "None"
    
    -- TWW Hero Talent Detection
    if _G.C_ClassTalents and _G.C_ClassTalents.GetActiveHeroTalentSpec then
        heroID = _G.C_ClassTalents.GetActiveHeroTalentSpec()
        
        if heroID and heroID > 0 then
            -- Get character class and spec for mapping
            local class = UnitClass("player")
            local specIndex = GetSpecialization()
            
            -- Hero Talent mapping based on class and spec
            if class and specIndex then
                if class == "ROGUE" then
                    if specIndex == 1 then -- Assassination
                        if heroID == 52 then 
                            heroName = "Fatebound" 
                        elseif heroID == 53 then 
                            heroName = "Trickster" 
                        end
                    elseif specIndex == 2 then -- Outlaw
                        if heroID == 52 then 
                            heroName = "Fatebound" 
                        elseif heroID == 53 then 
                            heroName = "Trickster" 
                        end
                    elseif specIndex == 3 then -- Subtlety
                        if heroID == 52 then 
                            heroName = "Fatebound" 
                        elseif heroID == 53 then 
                            heroName = "Trickster" 
                        end
                    end
                elseif class == "WARRIOR" then
                    if specIndex == 1 then -- Arms
                        if heroID == 71 then 
                            heroName = "Colossus"
                        elseif heroID == 72 then 
                            heroName = "Slayer" 
                        end
                    -- Add more warrior specs as needed
                    end
                end
            end
        end
    end
    
    return heroID, heroName
end

print("Test file loaded")