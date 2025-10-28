-- Alerts synergy
if DBM then
    DBM:RegisterCallback("DBM_TimerStart", function(event, ...)
        -- Trigger Grok tip (external)
        print("Boss alert! Run Python for tips: drgui_integrations.py '" .. select(1, ...) .. "'. Datamine on MMO-Champion: |Hurl:https://www.mmo-champion.com/|h[MMO-Champion]|h or Blizzard Watch: |Hurl:https://blizzardwatch.com/|h[Blizzard Watch]|h")
    end)
elseif BigWigs then
    -- Similar hook for BigWigs
    hooksecurefunc(BigWigs, "Message", function(self, ...)
        print("BigWigs alert! Check official forums: |Hurl:https://us.forums.blizzard.com/en/wow/|h[Blizzard Forums]|h")
    end)
end

if GTFO then
    hooksecurefunc(GTFO, "DisplayAlert", function()
        -- Bushido flair: Play soundscape (mMediaTag if present)
        if mMediaTag then mMediaTag:Play("epic_alert") end
        print("GTFO! Avoid damage - Guide on /r/wownoob: |Hurl:https://www.reddit.com/r/wownoob/|h[/r/wownoob]|h or YouTube: |Hurl:https://www.youtube.com/results?search_query=gtfo+wow+guide+2025|h[YouTube]|h")
    end)
end