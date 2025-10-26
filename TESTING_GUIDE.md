# DRGUI Testing Guide

## Overview
Comprehensive testing guide for DRGUI addon and Profile Manager desktop application.

---

## Pre-Testing Checklist

### Environment Setup
- [ ] World of Warcraft installed (_retail_ version)
- [ ] Python 3.7+ installed
- [ ] DRGUI_BK folder in Interface/AddOns/
- [ ] All dependencies installed (ElvUI, Details!, WeakAuras)

### File Verification
- [ ] DRGUI.toc exists
- [ ] DRGUI.lua exists
- [ ] All core modules present (setup_wizard.lua, backup_system.lua, etc.)
- [ ] All scripts present (drgui_profile_manager.py, etc.)

---

## In-Game Testing (DRGUI Addon)

### Test 1: Initial Setup
**Objective:** Verify addon loads and detects character

**Steps:**
1. Launch WoW with DRGUI enabled
2. Log into a character
3. Check chat for DRGUI messages

**Expected Results:**
- ✓ "DRGUI Combo Detected: [Race]-[Class]-[Spec]-[HeroID]" message appears
- ✓ No Lua errors
- ✓ Profile created/loaded message

**Pass/Fail:** _____

---

### Test 2: Dependency Check
**Objective:** Verify dependency checking works

**Steps:**
1. Type `/drgui deps` in chat
2. Review output

**Expected Results:**
- ✓ Required addons status shown (ElvUI, Details!, WeakAuras)
- ✓ Optional addons status shown
- ✓ Missing addons clearly indicated
- ✓ Auto-installer instructions shown if missing

**Pass/Fail:** _____

---

### Test 3: Profile Autosave
**Objective:** Verify profiles save automatically

**Steps:**
1. Log into character
2. Make UI changes (move frames, change settings)
3. Type `/logout` or exit game normally
4. Check SavedVariables folder

**Expected Results:**
- ✓ DRGUIDB.lua file updated
- ✓ File contains character combo
- ✓ Backup created in DRGUI_Backups/ (if backup on logout enabled)
- ✓ Timestamp in backup filename

**Pass/Fail:** _____

---

### Test 4: Backup System
**Objective:** Verify in-game backup commands work

**Steps:**
1. Type `/drgui backup` - Create manual backup
2. Type `/drgui backups` - List backups
3. Note a backup number
4. Type `/drgui restore 1` - Restore first backup

**Expected Results:**
- ✓ Manual backup created successfully
- ✓ Backup list shows all backups with dates
- ✓ Restore creates pre-restore backup
- ✓ Profile restored message shown
- ✓ `/reload` prompt displayed

**Pass/Fail:** _____

---

### Test 5: Setup Wizard
**Objective:** Verify wizard launches and works

**Steps:**
1. Type `/drgui wizard`
2. Click through all 5 steps
3. Complete wizard

**Expected Results:**
- ✓ Wizard window opens (800x600)
- ✓ Step 1: Welcome message displayed
- ✓ Step 2: Dependencies checked correctly
- ✓ Step 3: Profile name shown
- ✓ Step 4: Customization options work
- ✓ Step 5: Completion message
- ✓ Profile created on finish

**Pass/Fail:** _____

---

### Test 6: Image Manager
**Objective:** Verify image manager UI works

**Steps:**
1. Type `/drgui images`
2. Select each category
3. Try adding a custom image
4. Select and apply an image

**Expected Results:**
- ✓ Image Manager window opens (800x600)
- ✓ 5 category buttons present
- ✓ Category switching works
- ✓ Preview panel shows selected image
- ✓ Add Image dialog works
- ✓ Apply Selected gives reload prompt

**Pass/Fail:** _____

---

### Test 7: UI Customization
**Objective:** Verify customization commands work

**Steps:**
1. Type `/drgui custom` - Show menu
2. Type `/drgui setstyle bushido` - Change style
3. Type `/drgui fontsize 14` - Change font
4. Type `/drgui uiscale 1.2` - Change scale
5. Type `/drgui apply` - Apply changes

**Expected Results:**
- ✓ Custom menu displays all options
- ✓ Style change confirmed
- ✓ Font size change confirmed
- ✓ UI scale change confirmed
- ✓ Apply prompts for /reload

**Pass/Fail:** _____

---

### Test 8: Script Launcher
**Objective:** Verify script launcher shows correct commands

**Steps:**
1. Type `/drgui codegen`
2. Type `/drgui imagegen`
3. Type `/drgui aihelp`

**Expected Results:**
- ✓ Each command shows Python script to run
- ✓ Command includes character combo
- ✓ Clear instructions provided
- ✓ Script path is correct

**Pass/Fail:** _____

---

### Test 9: Help System
**Objective:** Verify all help commands work

**Steps:**
1. Type `/drgui` - Show main help
2. Type `/drgui help` - Detailed help

**Expected Results:**
- ✓ Command list displayed
- ✓ All major categories shown
- ✓ Commands properly formatted
- ✓ Reference to documentation

**Pass/Fail:** _____

---

### Test 10: Spec/Talent Changes
**Objective:** Verify profile switching on spec change

**Steps:**
1. Log into character
2. Change specialization
3. Check chat messages
4. Change hero talents (if available)

**Expected Results:**
- ✓ "DRGUI Update: Combo changed!" message
- ✓ New profile created/loaded
- ✓ Old profile backed up if setting enabled
- ✓ No errors

**Pass/Fail:** _____

---

## Desktop App Testing (Profile Manager)

### Test 11: App Launch
**Objective:** Verify app starts correctly

**Steps:**
1. Close WoW completely
2. Run: `python scripts/drgui_profile_manager.py`
3. Check window appears

**Expected Results:**
- ✓ Window opens (1200x800)
- ✓ WoW path auto-detected
- ✓ Status bar shows "Ready"
- ✓ Menu bar present with File and Tools

**Pass/Fail:** _____

---

### Test 12: Profile Loading
**Objective:** Verify profiles load from SavedVariables

**Steps:**
1. Ensure DRGUIDB.lua exists in SavedVariables
2. Click "Load Profiles" button
3. Check profile list

**Expected Results:**
- ✓ Profile list populates
- ✓ Character combos displayed
- ✓ Status shows "Loaded X profiles"
- ✓ No error messages

**Pass/Fail:** _____

---

### Test 13: Profile Selection
**Objective:** Verify profile details display

**Steps:**
1. Load profiles
2. Click a profile in list
3. Check right panel

**Expected Results:**
- ✓ Profile details appear in right panel
- ✓ JSON format displayed
- ✓ Profile key shown
- ✓ Metadata visible

**Pass/Fail:** _____

---

### Test 14: Single Profile Export
**Objective:** Verify single profile export to JSON

**Steps:**
1. Select a profile
2. Click "Export" button
3. Choose save location
4. Check saved file

**Expected Results:**
- ✓ Save dialog appears
- ✓ Default filename includes profile name and timestamp
- ✓ File saved successfully
- ✓ JSON file is valid and readable
- ✓ Contains profile data

**Pass/Fail:** _____

---

### Test 15: All Profiles Export
**Objective:** Verify bulk export works

**Steps:**
1. Load profiles
2. File → Export to JSON
3. Choose location
4. Check file

**Expected Results:**
- ✓ Save dialog appears
- ✓ Filename includes timestamp
- ✓ All profiles exported
- ✓ Valid JSON format
- ✓ Success message shown

**Pass/Fail:** _____

---

### Test 16: JSON Import
**Objective:** Verify profile import works

**Steps:**
1. Have a JSON export file
2. File → Import from JSON
3. Select the file
4. Check profile list

**Expected Results:**
- ✓ File selection dialog appears
- ✓ Import successful
- ✓ Profile list updates
- ✓ New profiles appear
- ✓ Success message shows count

**Pass/Fail:** _____

---

### Test 17: Profile Scrubbing
**Objective:** Verify scrub feature works

**Steps:**
1. Select a profile
2. Click "Scrub" button
3. Confirm action
4. Check profile details

**Expected Results:**
- ✓ Confirmation dialog appears
- ✓ Profile scrubbed successfully
- ✓ "scrubbed": true in details
- ✓ Timestamp added
- ✓ Success message

**Pass/Fail:** _____

---

### Test 18: Scrub All Profiles
**Objective:** Verify batch scrubbing

**Steps:**
1. Tools → Scrub All Profiles
2. Confirm action
3. Wait for completion

**Expected Results:**
- ✓ Confirmation dialog
- ✓ Automatic backup created first
- ✓ All profiles scrubbed
- ✓ Summary shows count
- ✓ Status bar updated

**Pass/Fail:** _____

---

### Test 19: Create Backup
**Objective:** Verify backup creation

**Steps:**
1. Tools → Create Backup
2. Check backup folder

**Expected Results:**
- ✓ Backup folder created if not exists
- ✓ Two files created (.lua and .json)
- ✓ Filenames include timestamp
- ✓ Files are valid
- ✓ Success message with paths

**Pass/Fail:** _____

---

### Test 20: Restore Backup
**Objective:** Verify backup restore

**Steps:**
1. Create a backup first
2. Tools → Restore Backup
3. Select backup file
4. Confirm restore

**Expected Results:**
- ✓ File selection dialog in backup folder
- ✓ Confirmation dialog appears
- ✓ Safety backup created first
- ✓ Restore successful
- ✓ Instructions to restart WoW

**Pass/Fail:** _____

---

### Test 21: Auto-Clean
**Objective:** Verify auto-clean feature

**Steps:**
1. Tools → Auto-Clean
2. Confirm action
3. Check output

**Expected Results:**
- ✓ Automatic backup created
- ✓ All profiles scrubbed
- ✓ Cleaned JSON exported
- ✓ Summary with count
- ✓ Files created in current directory

**Pass/Fail:** _____

---

### Test 22: Profile Deletion
**Objective:** Verify profile deletion

**Steps:**
1. Select a profile
2. Click "Delete" button
3. Confirm deletion
4. Check list

**Expected Results:**
- ✓ Confirmation dialog
- ✓ Profile removed from list
- ✓ Details panel cleared
- ✓ Status updated
- ✓ Profile actually deleted

**Pass/Fail:** _____

---

## Integration Testing

### Test 23: In-Game to Desktop Flow
**Objective:** Verify full workflow from game to desktop app

**Steps:**
1. In WoW: Create/modify profile
2. Logout (autosave)
3. Close WoW
4. Launch Profile Manager
5. Load profiles
6. Find your profile
7. Export to JSON

**Expected Results:**
- ✓ Profile saved in-game
- ✓ Backup created on logout
- ✓ Desktop app loads profile
- ✓ Export successful
- ✓ JSON contains latest changes

**Pass/Fail:** _____

---

### Test 24: Desktop to In-Game Flow
**Objective:** Verify profile import and use in-game

**Steps:**
1. Export profile from desktop app
2. Edit JSON manually (optional)
3. Import back to desktop app
4. Close desktop app
5. Launch WoW
6. Check profile loaded

**Expected Results:**
- ✓ Export successful
- ✓ Import successful
- ✓ Profile data intact
- ✓ WoW loads edited profile
- ✓ Changes visible in-game

**Pass/Fail:** _____

---

### Test 25: Backup/Restore Cycle
**Objective:** Verify complete backup/restore workflow

**Steps:**
1. In-game: `/drgui backup`
2. Make UI changes
3. Close desktop app
4. Launch desktop app
5. Tools → Restore Backup
6. Launch WoW
7. Check UI restored

**Expected Results:**
- ✓ In-game backup created
- ✓ Desktop app sees backup
- ✓ Restore successful
- ✓ UI reverted to backup state
- ✓ No data loss

**Pass/Fail:** _____

---

## Performance Testing

### Test 26: Large Profile Handling
**Objective:** Verify app handles many profiles

**Steps:**
1. Have 10+ character profiles
2. Load in desktop app
3. Perform operations

**Expected Results:**
- ✓ All profiles load quickly (<5 seconds)
- ✓ Scrolling smooth
- ✓ Selection responsive
- ✓ Export/import work
- ✓ No lag or freezing

**Pass/Fail:** _____

---

### Test 27: File Size Handling
**Objective:** Verify large SavedVariables handled

**Steps:**
1. Have large DRGUIDB.lua file
2. Load in desktop app
3. Check memory usage

**Expected Results:**
- ✓ File loads successfully
- ✓ Reasonable memory usage
- ✓ No crashes
- ✓ Operations still responsive

**Pass/Fail:** _____

---

## Error Handling Testing

### Test 28: Missing Files
**Objective:** Verify graceful handling of missing files

**Steps:**
1. Launch app with no SavedVariables
2. Try to load profiles
3. Check error message

**Expected Results:**
- ✓ Clear error message
- ✓ No crash
- ✓ Guidance provided
- ✓ App remains functional

**Pass/Fail:** _____

---

### Test 29: Corrupted Data
**Objective:** Verify handling of corrupted SavedVariables

**Steps:**
1. Manually corrupt DRGUIDB.lua
2. Try to load in desktop app
3. Check behavior

**Expected Results:**
- ✓ Error caught gracefully
- ✓ Error message displayed
- ✓ No crash
- ✓ Suggest backup restore

**Pass/Fail:** _____

---

### Test 30: Permission Issues
**Objective:** Verify handling of read-only files

**Steps:**
1. Make SavedVariables read-only
2. Try to create backup
3. Check error handling

**Expected Results:**
- ✓ Error message displayed
- ✓ No crash
- ✓ Clear explanation
- ✓ Suggestion provided

**Pass/Fail:** _____

---

## Final Verification

### Overall Checklist
- [ ] All in-game commands work
- [ ] Profile autosave works
- [ ] Backup system functional
- [ ] Desktop app starts correctly
- [ ] Profile loading works
- [ ] Export/Import functional
- [ ] Scrubbing works
- [ ] No Lua errors in-game
- [ ] No Python errors in desktop app
- [ ] Documentation accurate

---

## Bug Report Template

**Bug ID:** _____
**Test Number:** _____
**Severity:** Critical / High / Medium / Low
**Description:**


**Steps to Reproduce:**
1.
2.
3.

**Expected Result:**


**Actual Result:**


**Error Messages:**


**Screenshots:** (if applicable)


**System Info:**
- WoW Version:
- Python Version:
- OS:

---

## Test Results Summary

**Total Tests:** 30
**Passed:** _____
**Failed:** _____
**Skipped:** _____
**Pass Rate:** _____%

**Critical Issues Found:**


**Recommendations:**


**Tester:** _____________________
**Date:** _____________________
**Time Spent:** _____________________

---

Last Updated: 2025-10-16
