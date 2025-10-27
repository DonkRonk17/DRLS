@echo off
echo Activating virtual environment...
call venv\Scripts\activate.bat

echo.
echo Installing dependencies with visible output...
echo This may take a while, especially for PyTorch (500MB-2GB)
echo.

pip install -r requirements.txt

echo.
echo Installation complete!
pause
