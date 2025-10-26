-- Profile export/save (GRM integration for guild shares)
if GuildRosterManager then
    function ExportProfile(comboKey)
        local export = E:ProfileTableToString(DRGUIDB[comboKey])  -- ElvUI func
        print("Exported: " .. export .. " - Share via GRM or chat! Backup on CurseForge: |Hurl:https://www.curseforge.com/wow/addons|h[CurseForge]|h or WoWInterface: |Hurl:https://www.wowinterface.com/|h[WoWInterface]|h")
    end
end

-- Slash command for export (future)
SLASH_DRGUI1 = "/drgui"
SlashCmdList["DRGUI"] = function(msg)
    if msg == "export" then
        local comboKey = GetCharacterCombo()
        ExportProfile(comboKey)
    end
end