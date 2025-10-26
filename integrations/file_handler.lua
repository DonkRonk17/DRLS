-- File existence checker using WoW API
local function FileExists(filepath)
    -- Try to load the file to check existence
    local success, result = pcall(function()
        -- For Lua files, try dofile in protected mode
        if filepath:match("%.lua$") then
            return dofile(filepath)
        end
        -- For media files (TGA, etc), check if texture loads
        if filepath:match("%.tga$") or filepath:match("%.blp$") then
            local texture = CreateFrame("Frame"):CreateTexture()
            texture:SetTexture(filepath)
            local loaded = texture:GetTexture() ~= nil
            texture:GetParent():Hide()
            return loaded
        end
        return false
    end)
    return success
end

-- Check integration files and media assets
local function CheckMissingFiles(comboKey)
    local missingFiles = {}
    local requiredFiles = {
        "integrations/alerts_hook.lua",
        "integrations/mdt_hook.lua",
        "integrations/wardrobe_hook.lua",
        "media/borders/default_border.tga",
        "media/icons/default_icon.tga",
        "media/fonts/Expressway.ttf"
    }
    
    -- Check combo-specific files
    if comboKey then
        table.insert(requiredFiles, "media/borders/" .. comboKey .. "_border.tga")
        table.insert(requiredFiles, "media/icons/" .. comboKey .. "_icon.tga")
    end
    
    for _, file in ipairs(requiredFiles) do
        if not FileExists("Interface\\AddOns\\DRGUI\\" .. file) then
            table.insert(missingFiles, file)
            print("DRGUI: Missing file: " .. file)
        end
    end
    
    if #missingFiles > 0 then
        print("DRGUI: " .. #missingFiles .. " missing file(s) detected!")
        print("Options:")
        print("1. Run drgui_code_gen.py for Lua files: python scripts/drgui_code_gen.py \"" .. (comboKey or "combo") .. "\" lua \"filename.lua\"")
        print("2. Run drgui_image_gen.py for TGA/media: python scripts/drgui_image_gen.py \"" .. (comboKey or "combo") .. "\"")
        print("3. Borrow from other addons: Check |Hurl:https://www.curseforge.com/wow/addons|h[CurseForge]|h or |Hurl:https://www.wowinterface.com/|h[WoWInterface]|h")
        print("   - For media: !mMT_MediaPack, !ClassColors")
        print("   - For animations: ActionButtonAnimation, FragUI")
        return missingFiles
    else
        print("DRGUI: All required files present!")
        return nil
    end
end

-- Export function for use in main addon
_G.DRGUI_CheckMissingFiles = CheckMissingFiles
