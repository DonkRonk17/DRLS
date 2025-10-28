-- AceTimer-3.0 - Timer scheduling library
local MAJOR, MINOR = "AceTimer-3.0", 17
local AceTimer = LibStub:NewLibrary(MAJOR, MINOR)
if not AceTimer then return end

AceTimer.activeTimers = AceTimer.activeTimers or {}
local timerFrame = AceTimer.frame or CreateFrame("Frame", "AceTimer30Frame")
AceTimer.frame = timerFrame

function AceTimer:ScheduleTimer(func, delay, ...)
    local timer = C_Timer.NewTimer(delay, function()
        if type(func) == "string" then
            self[func](self, ...)
        else
            func(...)
        end
    end)
    self.activeTimers = self.activeTimers or {}
    table.insert(self.activeTimers, timer)
    return timer
end

function AceTimer:ScheduleRepeatingTimer(func, delay, ...)
    local timer = C_Timer.NewTicker(delay, function()
        if type(func) == "string" then
            self[func](self, ...)
        else
            func(...)
        end
    end)
    self.activeTimers = self.activeTimers or {}
    table.insert(self.activeTimers, timer)
    return timer
end

function AceTimer:CancelTimer(timer)
    if timer and timer.Cancel then
        timer:Cancel()
    end
end

function AceTimer:CancelAllTimers()
    if self.activeTimers then
        for _, timer in ipairs(self.activeTimers) do
            if timer and timer.Cancel then
                timer:Cancel()
            end
        end
        self.activeTimers = {}
    end
end