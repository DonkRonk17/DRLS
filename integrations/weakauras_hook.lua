-- WeakAuras integration for proc animations
if WeakAuras then
    -- Placeholder: Load custom WA string for combo (user imports from Wago.io)
    local function LoadComboWA(comboKey)
        print("Load WA for " .. comboKey .. ": Visit |Hurl:https://wago.io/weakauras|h[Wago.io]|h and search '" .. comboKey .. " Bushido'. Tutorial: |Hurl:https://www.youtube.com/results?search_query=weakauras+wow+setup+2025|h[YouTube]|h")
    end
    LoadComboWA(GetCharacterCombo())  -- Call from main
end