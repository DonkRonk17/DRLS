-- Hook Details! for real-time stats (lean heavy)
if Details then
    hooksecurefunc(Details, "RefreshMainWindow", function(instance)
        -- Example: Update DRGUI panel with DPS
        local dps = Details:GetCurrentDPS(UnitName("player"))
        _G["DRGUI_Stats_PanelText"]:SetText("DPS: " .. dps)
        if dps > 100000 then  -- Threshold for glow
            _G["DRGUI_Stats_Panel"]:SetBackdropColor(0.09, 0.52, 0.82, 1)  -- Blue glow
            print("Epic DPS! Sim gear on Raidbots: |Hurl:https://www.raidbots.com/simbot|h[Raidbots]|h or analyze logs on WarcraftLogs: |Hurl:https://www.warcraftlogs.com/|h[WarcraftLogs]|h")
        end
    end)
end