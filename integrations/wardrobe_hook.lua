-- BetterWardrobe mog sync
if BetterWardrobe then
    hooksecurefunc(BetterWardrobe, "UpdatePreview", function()
        local comboKey = GetCharacterCombo()
        -- Sync border with mog (e.g., set texture)
        _G["DRGUI_AI_Panel"]:SetBackdrop({bgFile = "media/borders/" .. comboKey .. "_border.tga"})
        print("Mog Sync! Preview sets on Wowhead: |Hurl:https://www.wowhead.com/transmog|h[Wowhead Mog]|h or WarcraftPets for pet matches: |Hurl:https://www.warcraftpets.com/|h[WarcraftPets]|h")
    end)
end