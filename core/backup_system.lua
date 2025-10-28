-- DRGUI Profile Backup System
-- Automatic and manual backup functionality

local DRGUI = DRGUI or {}
DRGUI.Backup = {}

-- Backup settings
local MAX_BACKUPS = 10
local BACKUP_FOLDER = "WTF/Account/%s/SavedVariables/DRGUI_Backups/"

-- Initialize backup database
DRGUIDB.backups = DRGUIDB.backups or {}
DRGUIDB.backupSettings = DRGUIDB.backupSettings or {
    autoBackup = true,
    backupOnLogout = true,
    backupOnProfileChange = true,
    backupInterval = 3600, -- 1 hour in seconds
    maxBackups = MAX_BACKUPS
}

-- Backup metadata
local function CreateBackupMetadata(comboKey, backupType)
    return {
        timestamp = time(),
        date = date("%Y-%m-%d %H:%M:%S"),
        comboKey = comboKey,
        playerName = UnitName("player"),
        realm = GetRealmName(),
        backupType = backupType or "manual",
        gameVersion = select(4, GetBuildInfo()),
        addonVersion = "1.0"
    }
end

-- Create backup
function DRGUI.Backup:CreateBackup(comboKey, backupType)
    if not comboKey then
        comboKey = GetCharacterCombo()
    end
    
    if not DRGUIDB[comboKey] then
        print("DRGUI Backup: No profile found for " .. comboKey)
        return false
    end
    
    -- Create backup data
    local backup = {
        metadata = CreateBackupMetadata(comboKey, backupType),
        profile = CopyTable(DRGUIDB[comboKey])
    }
    
    -- Initialize backups table for this combo
    DRGUIDB.backups[comboKey] = DRGUIDB.backups[comboKey] or {}
    
    -- Add backup to list
    table.insert(DRGUIDB.backups[comboKey], backup)
    
    -- Manage backup count (keep only MAX_BACKUPS)
    self:CleanupOldBackups(comboKey)
    
    print("DRGUI Backup: Profile backed up successfully (" .. backupType .. ")")
    print("Total backups for " .. comboKey .. ": " .. #DRGUIDB.backups[comboKey])
    
    return true
end

-- Restore backup
function DRGUI.Backup:RestoreBackup(comboKey, backupIndex)
    if not comboKey then
        comboKey = GetCharacterCombo()
    end
    
    if not DRGUIDB.backups[comboKey] or not DRGUIDB.backups[comboKey][backupIndex] then
        print("DRGUI Backup: Backup not found")
        return false
    end
    
    local backup = DRGUIDB.backups[comboKey][backupIndex]
    
    -- Create a backup of current state before restoring
    self:CreateBackup(comboKey, "pre-restore")
    
    -- Restore the backup
    DRGUIDB[comboKey] = CopyTable(backup.profile)
    
    -- Apply to current session
    E.db = CopyTable(DRGUIDB[comboKey])
    
    print("DRGUI Backup: Profile restored from " .. backup.metadata.date)
    print("Type /reload to apply all changes")
    
    return true
end

-- List backups
function DRGUI.Backup:ListBackups(comboKey)
    if not comboKey then
        comboKey = GetCharacterCombo()
    end
    
    if not DRGUIDB.backups[comboKey] or #DRGUIDB.backups[comboKey] == 0 then
        print("DRGUI Backup: No backups found for " .. comboKey)
        return {}
    end
    
    print("=" .. string.rep("=", 50))
    print("Backups for " .. comboKey)
    print("=" .. string.rep("=", 50))
    
    for i, backup in ipairs(DRGUIDB.backups[comboKey]) do
        local meta = backup.metadata
        print(string.format("[%d] %s - %s (%s)", i, meta.date, meta.backupType, meta.playerName))
    end
    
    print("=" .. string.rep("=", 50))
    print("To restore: /drgui restore <number>")
    
    return DRGUIDB.backups[comboKey]
end

-- Cleanup old backups
function DRGUI.Backup:CleanupOldBackups(comboKey)
    if not DRGUIDB.backups[comboKey] then return end
    
    local backups = DRGUIDB.backups[comboKey]
    local maxBackups = DRGUIDB.backupSettings.maxBackups
    
    -- Remove oldest backups if exceeding max
    while #backups > maxBackups do
        table.remove(backups, 1) -- Remove oldest (first) backup
    end
end

-- Delete specific backup
function DRGUI.Backup:DeleteBackup(comboKey, backupIndex)
    if not comboKey then
        comboKey = GetCharacterCombo()
    end
    
    if not DRGUIDB.backups[comboKey] or not DRGUIDB.backups[comboKey][backupIndex] then
        print("DRGUI Backup: Backup not found")
        return false
    end
    
    table.remove(DRGUIDB.backups[comboKey], backupIndex)
    print("DRGUI Backup: Backup #" .. backupIndex .. " deleted")
    
    return true
end

-- Export backup to string (for sharing)
function DRGUI.Backup:ExportBackup(comboKey, backupIndex)
    if not comboKey then
        comboKey = GetCharacterCombo()
    end
    
    if not DRGUIDB.backups[comboKey] or not DRGUIDB.backups[comboKey][backupIndex] then
        print("DRGUI Backup: Backup not found")
        return nil
    end
    
    local backup = DRGUIDB.backups[comboKey][backupIndex]
    
    -- Use ElvUI's serialization if available
    if E and E.ProfileTableToString then
        local exportString = E:ProfileTableToString(backup)
        print("DRGUI Backup: Export string generated (copy from chat)")
        return exportString
    else
        print("DRGUI Backup: ElvUI serialization not available")
        return nil
    end
end

-- Import backup from string
function DRGUI.Backup:ImportBackup(importString, comboKey)
    if not importString or importString == "" then
        print("DRGUI Backup: No import string provided")
        return false
    end
    
    if not comboKey then
        comboKey = GetCharacterCombo()
    end
    
    -- Use ElvUI's deserialization if available
    if E and E.ProfileStringToTable then
        local success, data = pcall(E.ProfileStringToTable, E, importString)
        if success and data then
            -- Create backup from imported data
            local backup = {
                metadata = CreateBackupMetadata(comboKey, "imported"),
                profile = data
            }
            
            DRGUIDB.backups[comboKey] = DRGUIDB.backups[comboKey] or {}
            table.insert(DRGUIDB.backups[comboKey], backup)
            
            print("DRGUI Backup: Profile imported successfully")
            return true
        else
            print("DRGUI Backup: Failed to import - invalid format")
            return false
        end
    else
        print("DRGUI Backup: ElvUI deserialization not available")
        return false
    end
end

-- Auto-backup timer
local autoBackupTimer = 0
local function AutoBackupCheck(elapsed)
    if not DRGUIDB.backupSettings.autoBackup then return end
    
    autoBackupTimer = autoBackupTimer + elapsed
    
    if autoBackupTimer >= DRGUIDB.backupSettings.backupInterval then
        autoBackupTimer = 0
        local comboKey = GetCharacterCombo()
        DRGUI.Backup:CreateBackup(comboKey, "auto")
    end
end

-- Setup auto-backup frame
local autoBackupFrame = CreateFrame("Frame")
autoBackupFrame:SetScript("OnUpdate", AutoBackupCheck)

-- Backup on logout
local function OnPlayerLogout()
    if DRGUIDB.backupSettings.backupOnLogout then
        local comboKey = GetCharacterCombo()
        DRGUI.Backup:CreateBackup(comboKey, "logout")
    end
end

local logoutFrame = CreateFrame("Frame")
logoutFrame:RegisterEvent("PLAYER_LOGOUT")
logoutFrame:SetScript("OnEvent", OnPlayerLogout)

-- Backup on profile change
function DRGUI.Backup:OnProfileChange(oldComboKey, newComboKey)
    if DRGUIDB.backupSettings.backupOnProfileChange then
        if oldComboKey then
            self:CreateBackup(oldComboKey, "profile-change")
        end
    end
end

-- Backup settings panel
function DRGUI.Backup:ShowSettings()
    print("=" .. string.rep("=", 50))
    print("DRGUI Backup Settings")
    print("=" .. string.rep("=", 50))
    print("Auto Backup: " .. (DRGUIDB.backupSettings.autoBackup and "Enabled" or "Disabled"))
    print("Backup on Logout: " .. (DRGUIDB.backupSettings.backupOnLogout and "Enabled" or "Disabled"))
    print("Backup on Profile Change: " .. (DRGUIDB.backupSettings.backupOnProfileChange and "Enabled" or "Disabled"))
    print("Backup Interval: " .. (DRGUIDB.backupSettings.backupInterval / 60) .. " minutes")
    print("Max Backups: " .. DRGUIDB.backupSettings.maxBackups)
    print("=" .. string.rep("=", 50))
    print("Use /drgui backupsettings <setting> <value> to change")
end

-- Toggle backup setting
function DRGUI.Backup:ToggleSetting(setting)
    if DRGUIDB.backupSettings[setting] ~= nil then
        DRGUIDB.backupSettings[setting] = not DRGUIDB.backupSettings[setting]
        print("DRGUI Backup: " .. setting .. " is now " .. (DRGUIDB.backupSettings[setting] and "enabled" or "disabled"))
        return true
    end
    return false
end

-- Export
_G.DRGUI = DRGUI
