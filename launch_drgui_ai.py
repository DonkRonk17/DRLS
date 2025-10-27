#!/usr/bin/env python3
"""
Enhanced DRGUI AI Designer Launcher
"""

import sys
import os
import subprocess

def setup_python_path():
    """Set up Python path to include current directory and subdirectories"""
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Add current directory to Python path
    if current_dir not in sys.path:
        sys.path.insert(0, current_dir)
    
    print(f"✓ Added to Python path: {current_dir}")
    return current_dir

def check_dependencies():
    """Check and install required dependencies"""
    required_packages = [
        'pygame',
        'opencv-python', 
        'py7zr',
        'lxml',
        'beautifulsoup4',
        'transformers',
        'openai'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
            print(f"✓ {package}")
        except ImportError:
            missing_packages.append(package)
            print(f"✗ {package} - Missing")
    
    if missing_packages:
        print(f"\nInstalling missing packages: {', '.join(missing_packages)}")
        for package in missing_packages:
            try:
                subprocess.check_call([sys.executable, '-m', 'pip', 'install', package])
                print(f"✓ Installed {package}")
            except subprocess.CalledProcessError as e:
                print(f"✗ Failed to install {package}: {e}")
                return False
    
    return True

def launch_application():
    """Launch the Enhanced DRGUI AI Designer"""
    try:
        # Set up Python path
        setup_python_path()
        
        # Check dependencies
        if not check_dependencies():
            print("❌ Failed to install required dependencies")
            return False
        
        print("\n🚀 Launching Enhanced DRGUI AI Designer...")
        
        # Import and run the main application
        from main import DRGUIAIDesigner
        
        # Create and run the application
        app = DRGUIAIDesigner()
        app.run()
        
        return True
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        print("Make sure all required files are present:")
        required_files = [
            'main.py',
            'integrations/wow_integration.py', 
            'ui/enhanced_ui_manager.py',
            'ui/wow_preview_renderer.py',
            'ai/ai_assistant.py',
            'utils/settings_manager.py',
            'utils/export_manager.py'
        ]
        
        for file in required_files:
            if os.path.exists(file):
                print(f"  ✓ {file}")
            else:
                print(f"  ✗ {file} - Missing")
        return False
        
    except Exception as e:
        print(f"❌ Error launching application: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("Enhanced DRGUI AI Designer")
    print("WoW UI Design Tool with AI Assistance")
    print("=" * 60)
    
    success = launch_application()
    
    if not success:
        print("\n" + "=" * 60)
        print("Launch failed. Please check the error messages above.")
        input("Press Enter to exit...")
    else:
        print("\n" + "=" * 60)
        print("Application closed successfully.")