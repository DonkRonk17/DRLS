# 🧪 PHASE 2 TESTING GUIDE - Enhanced Unit Frames + Nameplates

## ✅ ACTIVATION CONFIRMED
- **Status:** Phase 2 Enhanced Active
- **Files Loaded:** DRGUI-ENHANCED.lua + unitframes_enhanced.lua + nameplates_enhanced.lua
- **Version:** 2.0.0-enhanced-phase2
- **Safety:** Emergency rollback available via switch_version.bat

---

## 🎮 TESTING PROCEDURE

### **Step 1: Launch World of Warcraft**
1. **Start WoW** (The War Within - Retail)
2. **Select Character** (any character is fine)
3. **Watch for:** 
   - ✅ Clean login (no errors)
   - ✅ DRGUI loads without crashes
   - ✅ Unit frames appear correctly
   - ✅ Nameplates display correctly

### **Step 2: Basic System Test**
Once in-game, type in chat:
```
/drgui test
```
**Expected Results:**
- ✅ "DRGUI Enhanced Phase 2 - System Test Complete" message
- ✅ No error messages
- ✅ Enhanced character detection working
- ✅ Unit frames + nameplates systems initialized

### **Step 3: Unit Frames Test** 
Type in chat:
```
/drgui frames
```
**Expected Results:**
- ✅ "Unit Frames module: ✅ Loaded"
- ✅ Player frame shows enhanced health/power display
- ✅ Target frame (target something to test)
- ✅ Party frames (if in group)
- ✅ Hero talent integration visible

### **Step 4: Nameplates Test**
Type in chat:
```
/drgui nameplates
```
**Expected Results:**
- ✅ "Nameplates module: ✅ Loaded" 
- ✅ Active nameplates count displayed
- ✅ Enhanced nameplate features visible

### **Step 5: Nameplate Visual Validation**
**Look for these enhanced features:**
- ✅ **Threat Detection:** Nameplate colors change based on threat level
- ✅ **Health Text:** Enhanced health formats (current, percent, smart)
- ✅ **Level Display:** Color-coded difficulty levels
- ✅ **Enhanced Sizing:** Proper width/height for different unit types
- ✅ **Class Colors:** Player nameplates show class colors
- ✅ **Reaction Colors:** NPC nameplates show proper faction colors

### **Step 6: System Reload Test**
Type in chat:
```
/drgui reload
```
**Expected Results:**
- ✅ "DRGUI Enhanced reloading UI..." message
- ✅ Clean reload without crashes
- ✅ All systems reinitialize correctly

---

## 🔍 WHAT TO LOOK FOR

### **✅ SUCCESS INDICATORS:**
- Clean login with no error popups
- Enhanced unit frames display correctly
- Enhanced nameplates display with new features
- All test commands work without errors
- Performance remains smooth
- Threat detection working on nameplates
- Health text formatting enhanced
- No memory leaks or crashes

### **⚠️ WARNING SIGNS:**
- Any Lua error popups
- Unit frames or nameplates not displaying
- Performance drops or lag
- Test commands failing
- Memory usage spike
- Nameplates not showing threat colors
- Missing nameplate enhancements

### **🚨 EMERGENCY ACTIONS:**
If ANY problems occur:
1. **Exit WoW immediately**
2. **Run:** `switch_version.bat`
3. **Select:** [2] Phase 1 (fallback) or [1] Safe Mode (emergency)
4. **Restart WoW** - Previous working version active

---

## 🎯 PHASE 2 VALIDATION CHECKLIST

**Core Functionality:**
- [ ] Clean addon load on login
- [ ] `/drgui test` command works
- [ ] `/drgui frames` command works  
- [ ] `/drgui nameplates` command works
- [ ] `/drgui reload` command works
- [ ] No Lua errors generated

**Enhanced Unit Frames (Phase 1 Continued):**
- [ ] Player frame displays correctly
- [ ] Target frame works when targeting
- [ ] Enhanced health/power displays
- [ ] Hero talent integration visible
- [ ] Party frames (if in group)

**Enhanced Nameplates (Phase 2 New):**
- [ ] Nameplates module loads correctly
- [ ] Threat detection colors working
- [ ] Enhanced health text formats
- [ ] Level display with difficulty colors
- [ ] Proper sizing for different unit types
- [ ] Class colors for player nameplates
- [ ] Reaction colors for NPC nameplates

**Performance & Stability:**
- [ ] Memory usage reasonable (< 3MB total)
- [ ] FPS remains stable
- [ ] No crashes during testing
- [ ] Clean reload functionality
- [ ] Responsive UI interactions
- [ ] Smooth nameplate updates

**Integration Testing:**
- [ ] Unit frames + nameplates work together
- [ ] No conflicts between systems
- [ ] Commands work for both modules
- [ ] Shared DRGUI features functional
- [ ] Phase 1 features still working

---

## 📊 TESTING RESULTS

**After testing, document:**
1. **Success Rate:** _/_ tests passed
2. **Performance Impact:** Memory: ___MB, FPS: ___
3. **Issues Found:** (list any problems)
4. **Unit Frames Status:** (working/issues)
5. **Nameplates Status:** (working/issues)
6. **Integration Quality:** (rate 1-10)

---

## 🚀 NEXT STEPS

**If Phase 2 Testing ✅ PASSES:**
- Mark Phase 2 as validated
- Proceed to Phase 3 - Advanced Chat System
- Keep Phase 2 mode active for continued development

**If Phase 2 Testing ❌ FAILS:**
- Emergency rollback to Phase 1 or Safe Mode
- Document issues found
- Fix problems before proceeding
- Re-test until stable

---

**Remember:** This builds on the proven Phase 1 success. The same methodology and protection systems are in place. If any issues arise, you have multiple fallback options available.

**Phase 2 = Phase 1 Success + Enhanced Nameplates!** 🚀