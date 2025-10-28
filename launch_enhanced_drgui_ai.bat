@echo off
REM Enhanced DRGUI AI Designer Launcher
REM Provides seamless WoW integration with ElvUI-level functionality

echo ============================================================
echo   Enhanced DRGUI AI Designer with WoW Integration
echo ============================================================
echo.
echo Features:
echo • AI-powered UI design assistance
echo • Seamless DRGUI and ElvUI compatibility  
echo • Automatic WoW character profile loading
echo • Real-time UI preview with game assets
echo • Advanced addon integration
echo • Export to multiple formats
echo.
echo Starting enhanced launcher...
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python not found in PATH
    echo Please install Python 3.8 or higher from https://python.org
    echo.
    pause
    exit /b 1
)

REM Run the enhanced launcher
echo Launching Enhanced DRGUI AI Designer...
@echo off
title Enhanced DRGUI AI Designer
echo ============================================================
echo Enhanced DRGUI AI Designer
echo WoW UI Design Tool with AI Assistance
echo ============================================================
echo.

cd /d "%~dp0"
python launch_drgui_ai.py

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ============================================================
    echo Launch failed. Please check the error messages above.
    pause
) else (
    echo.
    echo ============================================================
    echo Application closed successfully.
)

REM Check exit code
if errorlevel 1 (
    echo.
    echo Application exited with errors
    pause
) else (
    echo.
    echo Application completed successfully
)

exit /b %errorlevel%