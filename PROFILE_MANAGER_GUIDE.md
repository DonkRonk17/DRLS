# DRGUI Profile Manager - Desktop Application Guide

## Overview

The DRGUI Profile Manager is a standalone desktop application built with Python and Tkinter that provides a graphical interface for managing, scrubbing, and backing up DRGUI profiles with full JSON support.

---

## Features

### 🎯 Core Features

1. **Profile Loading** - Automatically loads profiles from WoW SavedVariables
2. **Profile Scrubbing** - Clean and optimize individual or all profiles
3. **JSON Export/Import** - Full bidirectional JSON support
4. **Backup/Restore** - Create and restore profile backups
5. **Auto-Clean** - One-click profile optimization
6. **Profile Management** - View, edit, delete profiles

### 📊 User Interface

**Layout:**
- Split-panel design (1200x800px)
- Left panel: Profile list
- Right panel: Profile details viewer
- Top: Menu bar and path selection
- Bottom: Status bar

**Menus:**
- **File** - Load, Export, Import, Exit
- **Tools** - Scrub All, Backup, Restore, Auto-Clean

---

## Installation

### Requirements

```
Python 3.7 or higher
tkinter (usually included with Python)
```

### Setup

1. **Ensure Python is installed:**
```bash
python --version
```

2. **Navigate to DRGUI folder:**
```bash
cd "C:\Program Files (x86)\Battle.net\World of Warcraft\_retail_\Interface\AddOns\DRGUI_BK"
```

3. **Run the application:**
```bash
python scripts/drgui_profile_manager.py
```

### Creating Desktop Shortcut (Windows)

1. Right-click on Desktop → New → Shortcut
2. Enter location:
```
C:\Windows\py.exe "C:\Program Files (x86)\Battle.net\World of Warcraft\_retail_\Interface\AddOns\DRGUI_BK\scripts\drgui_profile_manager.py"
```
3. Name it "DRGUI Profile Manager"
4. Click Finish

---

## Quick Start Guide

### First Launch

1. **Launch the application**
   - Double-click desktop shortcut, or
   - Run from command line

2. **Verify WoW Path**
   - Path auto-detected on startup
   - Should show: `C:\Program Files (x86)\World of Warcraft\_retail_`
   - Click "Browse" if incorrect

3. **Load Profiles**
   - Click "Load Profiles" button
   - Application scans SavedVariables for DRGUIDB.lua
   - Profile list populates with all character combos

4. **Select a Profile**
   - Click any profile in the left list
   - Details display in right panel
   - Profile data shown in JSON format

---

## Feature Details

### 1. Profile Loading

**Purpose:** Load DRGUI profiles from World of Warcraft SavedVariables

**Steps:**
1. Ensure WoW path is correct
2. Click "Load Profiles" button
3. Application searches for: `WTF\Account\*\SavedVariables\DRGUIDB.lua`
4. Profiles appear in left panel

**Status Messages:**
- Success: "Loaded X profiles from DRGUIDB.lua"
- Error: "Could not find DRGUIDB.lua in SavedVariables"

### 2. Profile Scrubbing

**Purpose:** Clean and optimize profile data by removing invalid entries

**Single Profile:**
1. Select profile from list
2. Click "Scrub" button
3. Confirm action
4. Profile is scrubbed and marked

**All Profiles:**
1. Menu → Tools → Scrub All Profiles
2. Automatic backup created first
3. All profiles scrubbed
4. Summary displayed

**What Scrubbing Does:**
- Removes invalid entries
- Optimizes data structure
- Marks scrubbed profiles with timestamp
- Maintains data integrity

### 3. JSON Export

**Purpose:** Export profiles to shareable JSON format

**Export All Profiles:**
1. Menu → File → Export to JSON
2. Choose save location
3. Filename: `DRGUI_Profiles_YYYYMMDD_HHMMSS.json`
4. All profiles exported

**Export Single Profile:**
1. Select profile from list
2. Click "Export" button
3. Choose save location
4. Filename: `DRGUI_[ProfileName]_YYYYMMDD_HHMMSS.json`
5. Single profile exported

**JSON Format:**
```json
{
  "Human-Mage-Frost-1234": {
    "key": "Human-Mage-Frost-1234",
    "raw_content": "Profile data loaded",
    "loaded_at": "2025-10-16T02:55:00",
    "scrubbed": true,
    "scrubbed_at": "2025-10-16T02:56:30"
  }
}
```

### 4. JSON Import

**Purpose:** Import profiles from JSON files

**Steps:**
1. Menu → File → Import from JSON
2. Select JSON file
3. Profiles merged with existing data
4. Profile list refreshes
5. Confirmation message shows count

**Use Cases:**
- Share profiles between characters
- Restore from JSON backup
- Import community profiles
- Transfer between WoW installations

### 5. Backup & Restore

**Create Backup:**
1. Menu → Tools → Create Backup
2. Backup created in: `SavedVariables\DRGUI_Backups\`
3. Two files created:
   - `DRGUIDB_backup_YYYYMMDD_HHMMSS.lua` (original format)
   - `DRGUIDB_backup_YYYYMMDD_HHMMSS.json` (JSON format)

**Restore Backup:**
1. Menu → Tools → Restore Backup
2. Browse to backup file (.lua or .json)
3. Confirm restore
4. Safety backup created first
5. Backup restored
6. Restart WoW to see changes

**Backup Location:**
```
WTF\Account\[AccountName]\SavedVariables\DRGUI_Backups\
```

### 6. Auto-Clean

**Purpose:** Automatic optimization of all profiles with export

**Steps:**
1. Menu → Tools → Auto-Clean
2. Automatic backup created
3. All profiles scrubbed
4. Cleaned version exported to JSON
5. Summary displayed

**Output:**
- Backup files in DRGUI_Backups folder
- Cleaned JSON: `DRGUI_Cleaned_YYYYMMDD_HHMMSS.json`
- Status report with count

### 7. Profile Deletion

**Purpose:** Remove unwanted profiles

**Steps:**
1. Select profile from list
2. Click "Delete" button
3. Confirm deletion
4. Profile removed from database
5. Cannot be undone (backup first!)

---

## Use Cases

### Use Case 1: Clean Up Old Profiles

**Scenario:** You have old character combos you no longer use

**Steps:**
1. Load profiles
2. Create backup first (Tools → Create Backup)
3. Select old profile
4. Click "Delete"
5. Repeat for each old profile
6. Export cleaned profiles to JSON

### Use Case 2: Share Profiles with Friend

**Scenario:** Friend wants your UI setup for their Mage

**Steps:**
1. Load profiles
2. Select your Mage profile
3. Click "Export" button
4. Save JSON file
5. Send file to friend
6. Friend imports using File → Import from JSON

### Use Case 3: Transfer to New Computer

**Scenario:** Setting up WoW on new PC

**Steps:**
1. On old PC: Export all profiles to JSON
2. Copy JSON file to new PC
3. On new PC: Install DRGUI
4. Open Profile Manager
5. Import from JSON
6. Launch WoW - profiles ready!

### Use Case 4: Optimize All Profiles

**Scenario:** Profiles accumulated over time, need cleaning

**Steps:**
1. Load profiles
2. Tools → Auto-Clean
3. Review cleaned JSON file
4. Restart WoW
5. Profiles optimized!

### Use Case 5: Recover from Corruption

**Scenario:** SavedVariables got corrupted

**Steps:**
1. Open Profile Manager
2. Tools → Restore Backup
3. Select most recent backup
4. Confirm restore
5. Restart WoW
6. Profiles restored!

---

## Keyboard Shortcuts

```
Ctrl+O - Load SavedVariables
Ctrl+E - Export to JSON
Ctrl+I - Import from JSON
Ctrl+B - Create Backup
Ctrl+Q - Quit
```

---

## File Locations

### SavedVariables
```
[WoW Path]\WTF\Account\[AccountName]\SavedVariables\DRGUIDB.lua
```

### Backups
```
[WoW Path]\WTF\Account\[AccountName]\SavedVariables\DRGUI_Backups\
```

### Exported JSON
```
Current directory or user-selected location
```

---

## Troubleshooting

### Issue: "Could not find DRGUIDB.lua"

**Solutions:**
- Verify WoW path is correct
- Launch WoW at least once after installing DRGUI
- Check Account name in WTF folder
- Ensure DRGUI addon is installed

### Issue: Application won't start

**Solutions:**
- Verify Python 3.7+ is installed
- Check tkinter is available: `python -m tkinter`
- Run from command line to see errors
- Reinstall Python with tkinter

### Issue: Profiles not loading

**Solutions:**
- Close WoW before loading
- Check SavedVariables file exists
- Verify file permissions
- Try browsing for WoW path manually

### Issue: Export/Import fails

**Solutions:**
- Check disk space
- Verify write permissions
- Try different location
- Check filename for invalid characters

### Issue: Backup not working

**Solutions:**
- Close WoW first
- Check DRGUI_Backups folder exists
- Verify write permissions
- Free up disk space

---

## Advanced Features

### Lua to JSON Conversion

The application automatically converts WoW's Lua SavedVariables format to JSON:

**Lua Format:**
```lua
DRGUIDB = {
  ["Human-Mage-Frost-1234"] = {
    -- profile data
  }
}
```

**JSON Format:**
```json
{
  "Human-Mage-Frost-1234": {
    "key": "Human-Mage-Frost-1234",
    ...
  }
}
```

### Profile Structure

Each profile contains:
- **key** - Character combo identifier
- **raw_content** - Original profile data
- **loaded_at** - Load timestamp
- **scrubbed** - Whether profile was scrubbed
- **scrubbed_at** - Scrub timestamp

### Batch Operations

**Process Multiple Profiles:**
1. Load all profiles
2. Use Tools → Auto-Clean
3. All profiles processed automatically
4. Single JSON export with all cleaned profiles

---

## Best Practices

### Regular Backups

**Recommendation:** Create backup before major changes

**Schedule:**
- Before scrubbing: Always
- Before deleting: Always
- Weekly: Recommended
- Before WoW patches: Recommended

### Profile Organization

**Tips:**
- Use descriptive export filenames
- Organize exports by date/character
- Keep master backup in safe location
- Document custom profiles

### Sharing Profiles

**Guidelines:**
- Export to JSON for sharing
- Include character info in filename
- Test imported profiles before use
