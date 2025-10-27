@echo off
echo ==========================================
echo DRGUI Version Control System
echo ==========================================
echo.
echo Current TOC files available:
echo 1. DRGUI.toc                 - Safe minimal version
echo 2. DRGUI-ENHANCED.toc        - Phase 1 Enhanced (Unit Frames)
echo 3. DRGUI-PHASE2.toc          - Phase 2 Enhanced (Unit Frames + Nameplates)
echo 4. DRGUI.toc.complex-backup  - Complex backup
echo.
echo Select version to activate:
echo [1] Safe Mode
echo [2] Phase 1 (Unit Frames Only)
echo [3] Phase 2 (Unit Frames + Nameplates)
echo [4] Restore Complex Backup
echo [S] Show current status
echo [Q] Quit
echo.
set /p choice="Enter choice: "

if "%choice%"=="1" goto safe
if "%choice%"=="2" goto phase1
if "%choice%"=="3" goto phase2
if "%choice%"=="4" goto complex
if "%choice%"=="s" goto status
if "%choice%"=="S" goto status
if "%choice%"=="q" goto end
if "%choice%"=="Q" goto end

:safe
echo Activating Safe Mode...
copy /Y "DRGUI-SAFE.toc" "DRGUI.toc" >nul
echo ✓ Safe mode activated
goto status

:phase1
echo Activating Phase 1 (Unit Frames)...
copy /Y "DRGUI-ENHANCED.toc" "DRGUI.toc" >nul
echo ✓ Phase 1 activated - Unit Frames only
goto status

:phase2
echo Activating Phase 2 (Unit Frames + Nameplates)...
copy /Y "DRGUI-PHASE2.toc" "DRGUI.toc" >nul
echo ✓ Phase 2 activated - Unit Frames + Nameplates
echo WARNING: This is Phase 2 test version. If issues occur, rollback to Phase 1 or Safe Mode.
goto status

:complex
echo Restoring Complex Backup...
copy /Y "DRGUI.toc.complex-backup" "DRGUI.toc" >nul
echo ✓ Complex backup restored
echo WARNING: This version had crash issues. Use with caution.
goto status

:status
echo.
echo Current DRGUI.toc contains:
type "DRGUI.toc" | findstr /C:"Title" /C:"DRGUI-SAFE" /C:"Enhanced Phase" /C:"unitframes_enhanced" /C:"nameplates_enhanced"
echo.
echo Files loaded:
type "DRGUI.toc" | findstr /V /C:"##" /C:"#" | findstr /V /C:"^$"
echo.
pause
goto end

:end
echo.
echo DRGUI Version Control Complete
echo Remember: Always test in a safe environment first!
pause