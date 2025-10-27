@echo off
REM DRGUI AI Designer Launcher Script
REM Simplified launcher for Windows

echo ============================================================
echo DRGUI AI-Powered UI Designer Launcher
echo The War Within Expansion Ready
echo ============================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.9+ from python.org
    echo.
    pause
    exit /b 1
)

echo Python found, checking version...
python -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python 3.8+ is required
    echo Please upgrade your Python installation
    echo.
    pause
    exit /b 1
)

echo Python version OK
echo.

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating Python virtual environment...
    python -m venv venv
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to create virtual environment
        pause
        exit /b 1
    )
    echo Virtual environment created
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to activate virtual environment
    pause
    exit /b 1
)

REM Install/upgrade dependencies
echo Installing/updating dependencies...
pip install --upgrade pip >nul 2>&1
pip install -r requirements.txt >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Some dependencies may not have installed correctly
    echo The application may still work with basic functionality
)

echo Dependencies installed
echo.

REM Launch the application
echo Starting DRGUI AI Designer...
echo.
python DRGUI_AI_main.py

REM Check exit code
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Application exited with error code %ERRORLEVEL%
    echo Check the log files for more information
)

echo.
echo DRGUI AI Designer closed
pause