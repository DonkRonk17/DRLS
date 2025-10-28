import requests
import zipfile
import os
import sys
import json
from pathlib import Path

# CurseForge API configuration
CURSEFORGE_API_KEY = "$2a$10$bL4bIL5pUWqfcO7KQtnMReakwtfHbNKh6v1uTpKlzhwoueEJQnPem"
CURSEFORGE_API_URL = "https://api.curseforge.com/v1"

# Dependency mapping: addon name -> CurseForge project ID
DEPENDENCIES = {
    "ElvUI": 60,  # ElvUI project ID
    "Details": 61,  # Details! Damage Meter
    "WeakAuras": 65,  # WeakAuras
    "DBM-Core": 3358,  # Deadly Boss Mods
    "Masque": 13592,  # Masque
    "Bartender4": 13304,  # Bartender4
    "Plater": 100547,  # Plater Nameplates
    "Hekili": 69254,  # Hekili
    "GuildRosterManager": 350005,  # Guild Roster Manager
}

def get_wow_addons_path():
    """Detect WoW AddOns directory"""
    # Common WoW installation paths
    possible_paths = [
        "C:\\Program Files (x86)\\World of Warcraft\\_retail_\\Interface\\AddOns",
        "C:\\Program Files\\World of Warcraft\\_retail_\\Interface\\AddOns",
        os.path.expanduser("~\\World of Warcraft\\_retail_\\Interface\\AddOns"),
        # Current directory (if running from AddOns folder)
        os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")),
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return path
    
    # Ask user if not found
    custom_path = input("WoW AddOns folder not found. Please enter the full path to your WoW AddOns folder: ")
    if os.path.exists(custom_path):
        return custom_path
    
    print("Error: Invalid path. Please run script again with correct path.")
    sys.exit(1)

def check_installed_addons(addons_path):
    """Check which dependencies are already installed"""
    installed = []
    missing = []
    
    for addon_name in DEPENDENCIES.keys():
        addon_folder = os.path.join(addons_path, addon_name)
        if os.path.exists(addon_folder):
            installed.append(addon_name)
        else:
            missing.append(addon_name)
    
    return installed, missing

def download_addon(project_id, addon_name, addons_path):
    """Download addon from CurseForge"""
    print(f"\nDownloading {addon_name}...")
    
    # Get latest file info
    headers = {"x-api-key": CURSEFORGE_API_KEY}
    try:
        response = requests.get(
            f"{CURSEFORGE_API_URL}/mods/{project_id}/files",
            headers=headers,
            params={"gameVersion": "11.0.2", "pageSize": 1}
        )
        
        if response.status_code != 200:
            print(f"Error: Failed to fetch {addon_name} info. Status: {response.status_code}")
            print(f"Please download manually from: https://www.curseforge.com/wow/addons")
            return False
        
        files = response.json().get("data", [])
        if not files:
            print(f"Error: No files found for {addon_name}")
            return False
        
        latest_file = files[0]
        download_url = latest_file.get("downloadUrl")
        file_name = latest_file.get("fileName")
        
        if not download_url:
            print(f"Error: No download URL for {addon_name}")
            return False
        
        # Download the file
        print(f"Downloading {file_name}...")
        response = requests.get(download_url, stream=True)
        zip_path = os.path.join(addons_path, file_name)
        
        with open(zip_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        # Extract the zip
        print(f"Extracting {addon_name}...")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(addons_path)
        
        # Clean up zip file
        os.remove(zip_path)
        
        print(f"✓ {addon_name} installed successfully!")
        return True
        
    except Exception as e:
        print(f"Error downloading {addon_name}: {str(e)}")
        print(f"Please download manually from: https://www.curseforge.com/wow/addons")
        return False

def install_dependencies(required_only=False):
    """Main installation function"""
    print("=" * 60)
    print("DRGUI Dependency Installer")
    print("=" * 60)
    
    # Get AddOns path
    addons_path = get_wow_addons_path()
    print(f"\nWoW AddOns Path: {addons_path}")
    
    # Check installed addons
    installed, missing = check_installed_addons(addons_path)
    
    print("\n" + "=" * 60)
    print("Dependency Status:")
    print("=" * 60)
    
    if installed:
        print("\n✓ Already Installed:")
        for addon in installed:
            print(f"  - {addon}")
    
    if missing:
        print("\n✗ Missing:")
        for addon in missing:
            print(f"  - {addon}")
    else:
        print("\n✓ All dependencies are installed!")
        return
    
    # Determine which to install
    required_addons = ["ElvUI", "Details", "WeakAuras"]
    if required_only:
        to_install = [a for a in missing if a in required_addons]
        if not to_install:
            print("\n✓ All required dependencies are installed!")
            return
    else:
        to_install = missing
    
    # Confirm installation
    print("\n" + "=" * 60)
    if required_only:
        print(f"Ready to install {len(to_install)} REQUIRED addon(s)")
    else:
        print(f"Ready to install {len(to_install)} addon(s)")
    print("=" * 60)
    
    confirm = input("\nProceed with installation? (yes/no): ").lower()
    if confirm not in ['yes', 'y']:
        print("Installation cancelled.")
        return
    
    # Download and install each addon
    success_count = 0
    failed_addons = []
    
    for addon_name in to_install:
        project_id = DEPENDENCIES[addon_name]
        if download_addon(project_id, addon_name, addons_path):
            success_count += 1
        else:
            failed_addons.append(addon_name)
    
    # Summary
    print("\n" + "=" * 60)
    print("Installation Summary:")
    print("=" * 60)
    print(f"✓ Successfully installed: {success_count}/{len(to_install)}")
    
    if failed_addons:
        print(f"✗ Failed to install: {len(failed_addons)}")
        print("\nPlease download these manually:")
        for addon in failed_addons:
            print(f"  - {addon}: https://www.curseforge.com/wow/addons")
    
    print("\n" + "=" * 60)
    print("Next Steps:")
    print("=" * 60)
    print("1. Close World of Warcraft completely")
    print("2. Restart the game")
    print("3. At character select, click 'AddOns' button")
    print("4. Enable all DRGUI dependencies")
    print("5. Enter game and type /reload")
    print("\nAlternatively, use WoWUp.io for easier addon management:")
    print("https://wowup.io/")
    print("=" * 60)

if __name__ == "__main__":
    # Check for arguments
    required_only = "--required-only" in sys.argv or "-r" in sys.argv
    
    try:
        install_dependencies(required_only)
    except KeyboardInterrupt:
        print("\n\nInstallation cancelled by user.")
        sys.exit(0)
    except Exception as e:
        print(f"\nUnexpected error: {str(e)}")
        print("Please report this issue or install dependencies manually.")
        sys.exit(1)
