# Phase 3B.2 Hero Talent Integration - Test Commands

## **🎯 HERO TALENT PROFILE TESTING**

### 1. **Create Hero Talent Profile**
```
/drgui create-hero-profile MyFateboundProfile
```
**Expected:** Creates profile with current hero talent (Fatebound), shows confirmation

### 2. **View Profile Status**
```
/drgui profile-status
```
**Expected:** Shows comprehensive status including:
- Auto-switching status (✅ Enabled)
- Current hero talent (Fatebound)
- Available profiles with hero talents
- Usage statistics

### 3. **List All Profiles**
```
/drgui profiles
```
**Expected:** Shows all profiles with hero talent context

### 4. **Manual Profile Switching**
```
/drgui switch-profile MyFateboundProfile
```
**Expected:** Manual switch with notification message

### 5. **Toggle Auto-Switching**
```
/drgui auto-mode
```
**Expected:** Toggle message showing enabled/disabled status

## **🔄 AUTO-SWITCH TESTING**

### 6. **Hero Talent Change Simulation**
- Change your hero talent spec in-game
- **Expected:** Auto-notification of hero talent change
- **Expected:** Auto-switch to matching profile (if available)
- **Expected:** Tip message if no matching profile exists

### 7. **Profile Creation Flow**
```
1. /drgui create-hero-profile TestProfile
2. /drgui profiles (verify creation)
3. /drgui profile-status (verify details)
4. /drgui switch-profile TestProfile (test switching)
```

## **📊 EXPECTED NOTIFICATIONS**

✅ **Profile Creation:** "Profile 'Name' created successfully with hero talent: Fatebound"
✅ **Auto-Switch:** "🔄 Auto-switched to profile 'Name'"
✅ **Manual Switch:** "✅ Manually switched to profile 'Name'"
✅ **Hero Change:** "🎯 Hero Talent changed! None → Fatebound"
✅ **Toggle Auto:** "✅ Auto-switching enabled" / "⏸️ Auto-switching disabled"

## **🎮 SUCCESS CRITERIA**

- [ ] Hero talent detection shows "Fatebound" correctly
- [ ] Profile creation includes hero talent data
- [ ] Auto-switch notifications appear on talent changes
- [ ] Manual switching works with clear feedback
- [ ] Profile status shows comprehensive information
- [ ] Auto-mode toggle provides clear status updates

## **🔧 DEBUG COMMANDS**

If issues occur:
```
/drgui profiles          (Check if profiles exist)
/drgui profile-status    (Check initialization status)
/reload                  (Restart addon if needed)
```