# DRGUI Profile Manager - Executable Build Guide

## Overview
This guide explains how to build a standalone .exe file for the DRGUI Profile Manager desktop application using PyInstaller.

---

## Why Build an Executable?

### Benefits
✅ **No Python Required** - Users don't need Python installed
✅ **Simple Distribution** - Single .exe file
✅ **Easy Installation** - Just double-click to run
✅ **Professional** - Looks like a native Windows application
✅ **Portable** - Copy to any Windows computer

---

## Prerequisites

### Required Software
- **Python 3.7 or higher** - To build the executable
- **pip** - Python package installer (usually included)
- **Windows OS** - For building Windows .exe (or Mac/Linux for their equivalents)

### Check Your Setup
```bash
python --version
# Should show Python 3.7.0 or higher

pip --version
# Should show pip version
```

---

## Quick Build (Automatic)

### Option 1: Use Build Script

1. **Navigate to scripts folder:**
```bash
cd "C:\Program Files (x86)\Battle.net\World of Warcraft\_retail_\Interface\AddOns\DRGUI\scripts"
```

2. **Run build script:**
```bash
python build_exe.py
```

3. **Wait for build to complete** (2-5 minutes)

4. **Find executable:**
```
scripts/dist/DRGUI_Profile_Manager.exe
```

### Option 2: Use Batch File (Windows)

1. Navigate to scripts folder in File Explorer
2. Double-click `build.bat`
3. Wait for build to complete
4. Press any key to close window
5. Check `dist` folder for .exe

---

## Manual Build (Advanced)

### Step 1: Install PyInstaller

```bash
pip install pyinstaller
```

### Step 2: Navigate to Scripts Folder

```bash
cd scripts
```

### Step 3: Build Executable

```bash
pyinstaller --onefile --windowed --name DRGUI_Profile_Manager drgui_profile_manager.py
```

### Step 4: Find Executable

```
scripts/dist/DRGUI_Profile_Manager.exe
```

---

## Build Options Explained

### PyInstaller Flags

**`--onefile`**
- Creates single .exe file
- Everything packaged inside
- Slower startup but easier distribution

**`--windowed`**
- No console window
- GUI-only application
- Professional appearance

**`--name DRGUI_Profile_Manager`**
- Sets executable name
- Output: DRGUI_Profile_Manager.exe

**`--icon icon.ico`** (optional)
- Custom application icon
- Must provide icon.ico file

### Advanced Options

**For debugging:**
```bash
pyinstaller --onefile --console --name DRGUI_Profile_Manager drgui_profile_manager.py
```
- Uses `--console` to see error messages

**For smaller file size:**
```bash
pyinstaller --onefile --windowed --noupx --name DRGUI_Profile_Manager drgui_profile_manager.py
```
- Skips UPX compression

**With custom icon:**
```bash
pyinstaller --onefile --windowed --icon=icon.ico --name DRGUI_Profile_Manager drgui_profile_manager.py
```
- Requires icon.ico in scripts folder

---

## Build Output

### Folder Structure After Build

```
scripts/
├── build/                    # Temporary build files (can delete)
├── dist/                     # Contains final executable
│   └── DRGUI_Profile_Manager.exe
├── __pycache__/             # Python cache (can delete)
├── DRGUI_Profile_Manager.spec  # Build specification (can delete)
├── drgui_profile_manager.py    # Source code
└── build_exe.py             # Build script
```

### What to Keep
- `dist/DRGUI_Profile_Manager.exe` - **This is your final application!**
- `drgui_profile_manager.py` - Source code (for rebuilding)
- `build_exe.py` - Build script (for rebuilding)

### What to Delete (Optional)
- `build/` folder
- `__pycache__/` folder
- `DRGUI_Profile_Manager.spec` file

The build script can clean these up automatically.

---

## File Sizes

### Typical Sizes

**Source Code:**
- drgui_profile_manager.py: ~15 KB

**Executable:**
- DRGUI_Profile_Manager.exe: ~10-15 MB
- Includes Python interpreter
- Includes all dependencies
- Includes tkinter library

**Why So Large?**
- Contains entire Python runtime
- Bundles all required libraries
- Ensures it runs without Python installed
- Normal for PyInstaller executables

---

## Distribution

### Sharing the Executable

**Option 1: Direct Copy**
1. Copy `DRGUI_Profile_Manager.exe` to USB drive
2. Give to friend
3. They double-click to run

**Option 2: Zip Archive**
1. Right-click `DRGUI_Profile_Manager.exe`
2. Send to → Compressed folder
3. Share the .zip file
4. Recipient extracts and runs

**Option 3: Cloud Storage**
1. Upload to Google Drive/Dropbox
2. Share link
3. Recipient downloads and runs

### Installation for End Users

1. Download/receive DRGUI_Profile_Manager.exe
2. Create folder: `C:\DRGUI\`
3. Move .exe to folder
4. Create desktop shortcut:
   - Right-click .exe → Send to → Desktop (create shortcut)
5. Double-click shortcut to run

---

## Troubleshooting

### Build Fails: "PyInstaller not found"

**Solution:**
```bash
pip install pyinstaller
```

If that fails:
```bash
python -m pip install --upgrade pip
pip install pyinstaller
```

### Build Fails: "Module not found"

**Solution:**
```bash
pip install --upgrade tk
```

or reinstall Python with tkinter

### Executable Won't Start

**Causes:**
1. Antivirus blocking it
2. Missing Visual C++ Redistributable
3. Corrupted build

**Solutions:**
1. Add exception to antivirus
2. Install VC++ Redist: https://aka.ms/vs/17/release/vc_redist.x64.exe
3. Rebuild with `--console` flag to see errors

### "Not a valid Win32 application"

**Cause:** Built on wrong architecture

**Solution:**
```bash
pyinstaller --onefile --windowed --target-arch x86_64 --name DRGUI_Profile_Manager drgui_profile_manager.py
```

### Executable Too Large

**Solutions:**
1. Use `--exclude-module` for unused modules
2. Skip UPX compression with `--noupx`
3. Use `--onedir` instead of `--onefile`

### Slow Startup

**Cause:** `--onefile` extracts to temp on each run

**Solution:**
Build with `--onedir` for faster startup:
```bash
pyinstaller --onedir --windowed --name DRGUI_Profile_Manager drgui_profile_manager.py
```

---

## Advanced Configuration

### Custom Spec File

The build script creates a .spec file. You can edit it for advanced options:

```python
# DRGUI_Profile_Manager.spec

a = Analysis(
    ['drgui_profile_manager.py'],
    pathex=[],
    binaries=[],
    datas=[('docs/', 'docs/')],  # Include documentation
    hiddenimports=['tkinter', 'json'],
    excludes=['matplotlib', 'numpy'],  # Exclude unused modules
)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='DRGUI_Profile_Manager',
    icon='icon.ico',
    version='version.txt',  # Add version info
)
```

Then build from spec:
```bash
pyinstaller DRGUI_Profile_Manager.spec
```

### Add Version Information (Windows)

Create `version.txt`:
```
VSVersionInfo(
  ffi=FixedFileInfo(
    filevers=(1, 0, 0, 0),
    prodvers=(1, 0, 0, 0),
  ),
  kids=[
    StringFileInfo([
      StringTable('040904B0', [
        StringStruct('CompanyName', 'DRGUI'),
        StringStruct('FileDescription', 'DRGUI Profile Manager'),
        StringStruct('FileVersion', '1.0.0.0'),
        StringStruct('ProductName', 'DRGUI Profile Manager'),
        StringStruct('ProductVersion', '1.0.0.0')
      ])
    ]),
    VarFileInfo([VarStruct('Translation', [1033, 1200])])
  ]
)
```

Build with version:
```bash
pyinstaller --onefile --windowed --version-file=version.txt --name DRGUI_Profile_Manager drgui_profile_manager.py
```

---

## Platform-Specific Builds

### Windows (.exe)
```bash
pyinstaller --onefile --windowed --name DRGUI_Profile_Manager drgui_profile_manager.py
```
Output: `DRGUI_Profile_Manager.exe`

### macOS (.app)
```bash
pyinstaller --onefile --windowed --name "DRGUI Profile Manager" drgui_profile_manager.py
```
Output: `DRGUI Profile Manager.app`

### Linux (binary)
```bash
pyinstaller --onefile --windowed --name DRGUI_Profile_Manager drgui_profile_manager.py
```
Output: `DRGUI_Profile_Manager` (no extension)

**Note:** Build on target platform for best compatibility

---

## Testing the Executable

### Test Checklist

- [ ] Executable starts without errors
- [ ] Window opens (1200x800)
- [ ] WoW path auto-detected
- [ ] Can browse for path
- [ ] Load profiles works
- [ ] Profile selection works
- [ ] Export to JSON works
- [ ] Import from JSON works
- [ ] Backup creation works
- [ ] Restore works
- [ ] Scrubbing works
- [ ] Status messages appear
- [ ] No crashes during use

### Test on Clean System

1. Copy .exe to computer without Python
2. Run executable
3. Verify all features work
4. Test with real SavedVariables file

---

## Continuous Integration

### Automated Builds

For automated building, create a script:

```python
# auto_build.py
import os
import subprocess
from datetime import datetime

# Get version from git tag or use date
version = datetime.now().strftime('%Y.%m.%d')

# Build
subprocess.run([
    'pyinstaller',
    '--onefile',
    '--windowed',
    f'--name=DRGUI_Profile_Manager_v{version}',
    'drgui_profile_manager.py'
])

# Move to releases folder
os.makedirs('releases', exist_ok=True)
os.rename(
    f'dist/DRGUI_Profile_Manager_v{version}.exe',
    f'releases/DRGUI_Profile_Manager_v{version}.exe'
)
```

---

## Best Practices

### Before Building

1. ✅ Test source code thoroughly
2. ✅ Update version numbers
3. ✅ Check all dependencies installed
4. ✅ Clean previous build artifacts
5. ✅ Review spec file if using custom config

### After Building

1. ✅ Test executable on target system
2. ✅ Scan with antivirus
3. ✅ Check file size reasonable
4. ✅ Verify all features work
5. ✅ Create backup of working build

### Distribution

1. ✅ Include README with executable
2. ✅ Provide system requirements
3. ✅ Add contact information
4. ✅ Consider code signing (advanced)
5. ✅ Test on multiple systems

---

## FAQ

**Q: Do I need to rebuild for each update?**
A: Yes, rebuild after any code changes.

**Q: Can I edit the .exe?**
A: No, edit source code and rebuild.

**Q: Why is my antivirus flagging it?**
A: PyInstaller executables sometimes trigger false positives. Add exception or code-sign it.

**Q: Can I make it smaller?**
A: Use `--exclude-module` for unused libraries, or switch to `--onedir`.

**Q: Does it work on Windows 7?**
A: Yes, if Python 3.7 supports Windows 7.

**Q: Can I distribute this commercially?**
A: Check Python and PyInstaller licenses, usually yes.

**Q: How do I update users?**
A: Send new .exe, they replace old one.

---

## Resources

### Documentation
- PyInstaller Manual: https://pyinstaller.org/en/stable/
- Python Packaging: https://packaging.python.org/
- Tkinter Reference: https://docs.python.org/3/library/tkinter.html

### Tools
- PyInstaller: https://pyinstaller.org/
- UPX (compression): https://upx.github.io/
- Resource Hacker (icon editor): http://www.angusj.com/resourcehacker/

### Communities
- PyInstaller GitHub: https://github.com/pyinstaller/pyinstaller
- Python Discord: https://discord.gg/python
- Stack Overflow: https://stackoverflow.com/questions/tagged/pyinstaller

---

## Support

**Issues with building?**
1. Check error messages carefully
2. Search PyInstaller GitHub issues
3. Ask on Stack Overflow with `pyinstaller` tag
4. Check DRGUI documentation

**Build succeeded but app doesn't work?**
1. Run with `--console` flag to see errors
2. Check WoW path is correct
3. Verify SavedVariables exists
4. Test on system with Python first

---

Last Updated: 2025-10-16
Version: 1.0
