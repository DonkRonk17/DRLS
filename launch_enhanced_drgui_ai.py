#!/usr/bin/env python3
"""
Enhanced DRGUI AI Designer Launcher
Advanced launcher with WoW integration, ElvUI compatibility, and AI assistance.
"""

import os
import sys
import logging
import subprocess
import time
from pathlib import Path
from typing import Optional

# Add current directory to path for imports
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

def setup_logging():
    """Setup enhanced logging"""
    log_dir = current_dir / "logs"
    log_dir.mkdir(exist_ok=True)
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_dir / f"drgui_ai_enhanced_{int(time.time())}.log"),
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(__name__)

def check_python_version() -> bool:
    """Check if Python version is compatible"""
    if sys.version_info < (3, 8):
        print("Error: Python 3.8 or higher required")
        print(f"Current version: {sys.version}")
        return False
    return True

def install_requirements() -> bool:
    """Install required packages"""
    logger = logging.getLogger(__name__)
    requirements_file = current_dir / "requirements.txt"
    
    if not requirements_file.exists():
        logger.error("requirements.txt not found!")
        return False
    
    try:
        logger.info("Installing enhanced requirements...")
        subprocess.check_call([
            sys.executable, "-m", "pip", "install", "-r", str(requirements_file)
        ])
        logger.info("Requirements installed successfully")
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to install requirements: {e}")
        return False

def detect_wow_installation() -> Optional[Path]:
    """Detect WoW installation automatically"""
    logger = logging.getLogger(__name__)
    
    # Common WoW installation paths
    wow_paths = [
        Path("C:/Program Files (x86)/World of Warcraft"),
        Path("C:/Program Files/World of Warcraft"),
        Path("D:/World of Warcraft"),
        Path("E:/World of Warcraft"),
        Path(os.path.expanduser("~/World of Warcraft")),
    ]
    
    # Check Battle.net installation
    battle_net_paths = [
        Path("C:/Program Files (x86)/Battle.net"),
        Path("C:/Program Files/Battle.net"),
    ]
    
    for battle_path in battle_net_paths:
        if battle_path.exists():
            wow_path = battle_path / "World of Warcraft" / "_retail_"
            if wow_path.exists():
                wow_paths.insert(0, wow_path.parent)  # Add to front of list
    
    # Check each path
    for wow_path in wow_paths:
        if wow_path.exists():
            # Check for retail installation
            retail_path = wow_path / "_retail_"
            if retail_path.exists() and (retail_path / "Wow.exe").exists():
                logger.info(f"Found WoW installation: {wow_path}")
                return wow_path
            
            # Check for direct installation
            if (wow_path / "Wow.exe").exists():
                logger.info(f"Found WoW installation: {wow_path}")
                return wow_path
    
    logger.warning("WoW installation not found automatically")
    return None

def check_wow_integration() -> bool:
    """Check WoW integration capabilities"""
    logger = logging.getLogger(__name__)
    
    wow_path = detect_wow_installation()
    if not wow_path:
        logger.warning("WoW not detected - some features will be limited")
        return False
    
    # Check for SavedVariables
    saved_vars_path = wow_path / "_retail_" / "WTF" / "Account"
    if not saved_vars_path.exists():
        logger.warning("WoW SavedVariables not found - character data unavailable")
        return False
    
    # Check for addon folders
    addon_path = wow_path / "_retail_" / "Interface" / "AddOns"
    if not addon_path.exists():
        logger.warning("AddOns folder not found")
        return False
    
    logger.info("WoW integration ready")
    return True

def check_dependencies() -> bool:
    """Check if all dependencies are available"""
    logger = logging.getLogger(__name__)
    
    required_modules = [
        "tkinter",
        "requests", 
        "Pillow",
        "opencv-python",
        "lxml",
        "beautifulsoup4",
        "py7zr"
    ]
    
    missing_modules = []
    
    for module in required_modules:
        try:
            if module == "opencv-python":
                import cv2
            elif module == "Pillow":
                import PIL
            elif module == "beautifulsoup4":
                import bs4
            else:
                __import__(module)
        except ImportError:
            missing_modules.append(module)
    
    if missing_modules:
        logger.warning(f"Missing modules: {', '.join(missing_modules)}")
        return False
    
    logger.info("All dependencies available")
    return True

def launch_ai_designer():
    """Launch the enhanced AI designer"""
    logger = logging.getLogger(__name__)
    
    try:
        # Import main application
        from main import DRGUIAIDesigner
        
        logger.info("Starting Enhanced DRGUI AI Designer...")
        
        # Create and run application
        app = DRGUIAIDesigner()
        app.run()
        
    except ImportError as e:
        logger.error(f"Failed to import main application: {e}")
        print("Error: Could not start AI designer")
        return False
    except Exception as e:
        logger.error(f"Application error: {e}")
        print(f"Error: {e}")
        return False
    
    return True

def show_welcome_message():
    """Show enhanced welcome message"""
    print("=" * 60)
    print("  Enhanced DRGUI AI Designer with WoW Integration")
    print("=" * 60)
    print()
    print("Features:")
    print("• AI-powered UI design assistance")
    print("• Seamless DRGUI and ElvUI compatibility")
    print("• Automatic WoW character profile loading")
    print("• Real-time UI preview with game assets")
    print("• Advanced addon integration")
    print("• Export to multiple formats")
    print()
    print("Starting enhanced launcher...")
    print()

def main():
    """Enhanced main launcher function"""
    show_welcome_message()
    
    # Setup logging
    logger = setup_logging()
    logger.info("Enhanced DRGUI AI Designer starting...")
    
    # Check Python version
    if not check_python_version():
        input("Press Enter to exit...")
        return False
    
    # Check and install requirements
    if not check_dependencies():
        logger.info("Installing missing dependencies...")
        if not install_requirements():
            print("Error: Failed to install requirements")
            input("Press Enter to exit...")
            return False
    
    # Check WoW integration
    wow_available = check_wow_integration()
    if wow_available:
        print("✓ WoW integration ready")
    else:
        print("⚠ WoW integration limited (WoW not detected)")
    
    # Final dependency check
    if not check_dependencies():
        print("Error: Dependencies still missing after installation")
        input("Press Enter to exit...")
        return False
    
    print("✓ All dependencies ready")
    print()
    
    # Launch application
    try:
        success = launch_ai_designer()
        if not success:
            input("Press Enter to exit...")
            return False
    except KeyboardInterrupt:
        logger.info("Application interrupted by user")
        print("\nApplication interrupted")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        print(f"Unexpected error: {e}")
        input("Press Enter to exit...")
        return False
    
    logger.info("Enhanced DRGUI AI Designer session completed")
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)