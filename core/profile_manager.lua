-- Profile export/save (GRM integration for guild shares)
function ExportProfile(comboKey)
    if not comboKey then
        print("DRGUI: No combo key provided for export")
        return
    end
    
    if not DRGUIDB or not DRGUIDB[comboKey] then
        print("DRGUI: No profile found for combo: " .. comboKey)
        return
    end
    
    -- Check if ElvUI is loaded (E should be available from DRGUI.lua)
    local elvUILoaded = (E ~= nil) or IsAddOnLoaded("ElvUI")
    
    -- Check if Guild Roster Manager is loaded (correct addon name with underscores)
    local grmLoaded = IsAddOnLoaded("Guild_Roster_Manager") or (_G.GuildRosterManager ~= nil)
    
    if elvUILoaded and grmLoaded and E and E.ProfileTableToString then
        local export = E:ProfileTableToString(DRGUIDB[comboKey])  -- ElvUI func
        print("DRGUI Export Success!")
        print("Profile exported: " .. string.sub(export, 1, 100) .. "...")
        print("Share via Guild Roster Manager or copy to chat!")
        print("Backup links: |Hurl:https://www.curseforge.com/wow/addons|h[CurseForge]|h |Hurl:https://www.wowinterface.com/|h[WoWInterface]|h")
    elseif not elvUILoaded then
        print("DRGUI: ElvUI not detected or not loaded properly")
        print("Make sure ElvUI is installed and enabled")
    elseif not grmLoaded then
        print("DRGUI: Guild Roster Manager not detected")
        print("Install Guild_Roster_Manager for profile sharing features")
        print("Basic export fallback: Profile data available in DRGUIDB['" .. comboKey .. "']")
    else
        print("DRGUI: Export function not available (E.ProfileTableToString missing)")
        print("This may indicate an ElvUI compatibility issue")
    end
end

-- Slash command for export is handled in DRGUI.lua main file
-- This avoids duplicate registrations that can break the command system