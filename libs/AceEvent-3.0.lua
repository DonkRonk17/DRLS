-- AceEvent-3.0 - Event handling library
local MAJOR, MINOR = "AceEvent-3.0", 4
local AceEvent = LibStub:NewLibrary(MAJOR, MINOR)
if not AceEvent then return end

local frame = AceEvent.frame or CreateFrame("Frame")
AceEvent.frame = frame
AceEvent.embeds = AceEvent.embeds or {}

local function OnEvent(frame, event, ...)
    local eventTable = AceEvent.events[event]
    if eventTable then
        for object, method in pairs(eventTable) do
            if type(method) == "string" then
                object[method](object, event, ...)
            else
                method(object, event, ...)
            end
        end
    end
end

frame:SetScript("OnEvent", OnEvent)
AceEvent.events = AceEvent.events or {}

function AceEvent:RegisterEvent(event, method)
    if not self.events then self.events = {} end
    if not AceEvent.events[event] then
        AceEvent.events[event] = {}
        frame:RegisterEvent(event)
    end
    AceEvent.events[event][self] = method or event
    self.events[event] = method or event
end

function AceEvent:UnregisterEvent(event)
    if self.events and self.events[event] then
        AceEvent.events[event][self] = nil
        self.events[event] = nil
        
        local hasHandler = false
        for _ in pairs(AceEvent.events[event]) do
            hasHandler = true
            break
        end
        
        if not hasHandler then
            frame:UnregisterEvent(event)
            AceEvent.events[event] = nil
        end
    end
end

function AceEvent:UnregisterAllEvents()
    if self.events then
        for event in pairs(self.events) do
            self:UnregisterEvent(event)
        end
    end
end