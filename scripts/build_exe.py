#!/usr/bin/env python3
"""
Build script for DRGUI Profile Manager executable
Creates standalone .exe file using PyInstaller
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def check_pyinstaller():
    """Check if PyInstaller is installed"""
    try:
        import PyInstaller
        print(f"✓ PyInstaller {PyInstaller.__version__} found")
        return True
    except ImportError:
        print("✗ PyInstaller not found")
        print("\nInstalling PyInstaller...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])
        print("✓ PyInstaller installed")
        return True

def create_spec_file():
    """Create PyInstaller spec file"""
    spec_content = """# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['drgui_profile_manager.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=['tkinter', 'tkinter.ttk', 'tkinter.filedialog', 'tkinter.messagebox', 'tkinter.scrolledtext'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='DRGUI_Profile_Manager',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,  # Windows GUI app (no console)
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='icon.ico' if os.path.exists('icon.ico') else None,
)
"""
    
    with open('DRGUI_Profile_Manager.spec', 'w') as f:
        f.write(spec_content)
    print("✓ Spec file created")

def build_executable():
    """Build the executable"""
    print("\n" + "=" * 60)
    print("Building DRGUI Profile Manager executable...")
    print("=" * 60 + "\n")
    
    # Check PyInstaller
    if not check_pyinstaller():
        return False
    
    # Create spec file
    create_spec_file()
    
    # Build with PyInstaller
    print("\nBuilding executable (this may take a few minutes)...")
    try:
        subprocess.check_call([
            sys.executable,
            "-m", "PyInstaller",
            "--clean",
            "--onefile",
            "--windowed",
            "--name", "DRGUI_Profile_Manager",
            "drgui_profile_manager.py"
        ])
        
        print("\n✓ Build complete!")
        
        # Check if executable was created
        if os.name == 'nt':  # Windows
            exe_path = os.path.join("dist", "DRGUI_Profile_Manager.exe")
        else:  # Mac/Linux
            exe_path = os.path.join("dist", "DRGUI_Profile_Manager")
        
        if os.path.exists(exe_path):
            file_size = os.path.getsize(exe_path) / (1024 * 1024)  # MB
            print(f"\n✓ Executable created: {exe_path}")
            print(f"  Size: {file_size:.2f} MB")
            print(f"\nYou can now run the application by double-clicking:")
            print(f"  {os.path.abspath(exe_path)}")
            return True
        else:
            print("\n✗ Executable not found in dist folder")
            return False
            
    except subprocess.CalledProcessError as e:
        print(f"\n✗ Build failed: {e}")
        return False
    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")
        return False

def cleanup_build_files():
    """Clean up build artifacts"""
    print("\nCleaning up build files...")
    
    dirs_to_remove = ['build', '__pycache__']
    files_to_remove = ['DRGUI_Profile_Manager.spec']
    
    for d in dirs_to_remove:
        if os.path.exists(d):
            shutil.rmtree(d)
            print(f"  Removed {d}/")
    
    for f in files_to_remove:
        if os.path.exists(f):
            os.remove(f)
            print(f"  Removed {f}")
    
    print("✓ Cleanup complete")

def create_installer_batch():
    """Create batch file for easy building"""
    batch_content = """@echo off
echo ========================================
echo DRGUI Profile Manager - Build Executable
echo ========================================
echo.

python build_exe.py

echo.
echo Press any key to exit...
pause > nul
"""
    
    with open('build.bat', 'w') as f:
        f.write(batch_content)
    print("✓ Created build.bat for easy building")

def main():
    """Main build process"""
    print("\n" + "=" * 60)
    print("DRGUI Profile Manager - Executable Builder")
    print("=" * 60 + "\n")
    
    # Change to scripts directory
    script_dir = Path(__file__).parent
    os.chdir(script_dir)
    
    # Check if main script exists
    if not os.path.exists('drgui_profile_manager.py'):
        print("✗ Error: drgui_profile_manager.py not found")
        print("  Make sure you're running this from the scripts folder")
        return 1
    
    # Build executable
    if build_executable():
        print("\n" + "=" * 60)
        print("Build successful!")
        print("=" * 60)
        
        # Ask about cleanup
        response = input("\nClean up build files? (y/n): ").lower()
        if response == 'y':
            cleanup_build_files()
        
        # Create batch file
        create_installer_batch()
        
        print("\n" + "=" * 60)
        print("Next steps:")
        print("=" * 60)
        print("1. Find the executable in the 'dist' folder")
        print("2. Copy DRGUI_Profile_Manager.exe to a convenient location")
        print("3. Create desktop shortcut (optional)")
        print("4. Run and test the application")
        print("\nTo rebuild, just run: python build_exe.py")
        print("Or double-click: build.bat")
        
        return 0
    else:
        print("\n" + "=" * 60)
        print("Build failed!")
        print("=" * 60)
        print("\nTroubleshooting:")
        print("1. Ensure Python 3.7+ is installed")
        print("2. Install PyInstaller: pip install pyinstaller")
        print("3. Check for error messages above")
        print("4. Try running: pyinstaller --version")
        
        return 1

if __name__ == "__main__":
    sys.exit(main())
