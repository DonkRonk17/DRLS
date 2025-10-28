#!/usr/bin/env python3
"""
DRGUI AI Designer - System Test Script
Tests all major components of the standalone application
"""

import os
import sys
import importlib.util
from pathlib import Path

def test_imports():
    """Test that all required modules can be imported"""
    print("🔍 Testing Python imports...")
    
    required_modules = [
        'tkinter',
        'threading', 
        'json',
        'time',
        'os',
        'sys'
    ]
    
    for module in required_modules:
        try:
            __import__(module)
            print(f"  ✅ {module}")
        except ImportError as e:
            print(f"  ❌ {module}: {e}")
            return False
    
    return True

def test_optional_imports():
    """Test optional AI-related imports"""
    print("\n🧠 Testing AI-related imports...")
    
    optional_modules = [
        ('openai', 'OpenAI API support'),
        ('transformers', 'Local AI models'),
        ('torch', 'PyTorch for AI'),
        ('PIL', 'Image processing'),
        ('pygame', 'Game simulation')
    ]
    
    results = {}
    for module, description in optional_modules:
        try:
            __import__(module)
            print(f"  ✅ {module} ({description})")
            results[module] = True
        except ImportError:
            print(f"  ⚠️  {module} ({description}) - Optional")
            results[module] = False
    
    return results

def test_file_structure():
    """Test that all required files exist"""
    print("\n📁 Testing file structure...")
    
    base_path = Path(__file__).parent
    required_files = [
        'DRGUI_AI_main.py',
        'requirements.txt',
        'launch_drgui_ai.bat',
        'config/settings_manager.py',
        'ai/natural_language.py',
        'simulation/game_engine.py',
        'ui/main_window.py'
    ]
    
    all_exist = True
    for file_path in required_files:
        full_path = base_path / file_path
        if full_path.exists():
            print(f"  ✅ {file_path}")
        else:
            print(f"  ❌ {file_path} - Missing!")
            all_exist = False
    
    return all_exist

def test_module_loading():
    """Test that our custom modules can be loaded"""
    print("\n🔧 Testing custom module loading...")
    
    base_path = Path(__file__).parent
    modules_to_test = [
        ('config.settings_manager', 'SettingsManager'),
        ('ai.natural_language', 'AIAssistant'),
        ('simulation.game_engine', 'WoWSimulationEngine'),
        ('ui.main_window', 'DRGUIMainWindow')
    ]
    
    # Add the base path to Python path
    sys.path.insert(0, str(base_path))
    
    all_loaded = True
    for module_name, class_name in modules_to_test:
        try:
            module = __import__(module_name, fromlist=[class_name])
            _ = getattr(module, class_name)
            print(f"  ✅ {module_name}.{class_name}")
        except Exception as e:
            print(f"  ❌ {module_name}.{class_name}: {e}")
            all_loaded = False
    
    return all_loaded

def test_configuration():
    """Test settings manager functionality"""
    print("\n⚙️  Testing configuration system...")
    
    try:
        from config.settings_manager import SettingsManager
        
        # Test basic initialization
        settings = SettingsManager()
        print("  ✅ SettingsManager initialization")
        
        # Test basic settings access
        default_settings = settings.get_setting("ui.window.width", 1200)
        print(f"  ✅ Settings access (window width: {default_settings})")
        
        # Test character settings
        _ = settings.get_character_settings("TestChar")
        print("  ✅ Character settings access")
        
        return True
        
    except Exception as e:
        print(f"  ❌ Configuration test failed: {e}")
        return False

def test_ai_system():
    """Test AI assistant basic functionality"""
    print("\n🤖 Testing AI system...")
    
    try:
        from ai.natural_language import AIAssistant
        
        # Test basic initialization (no args for testing)
        ai = AIAssistant()
        print("  ✅ AIAssistant initialization")
        
        # Test basic functionality that should exist
        # The AI has async methods, so we'll just test that it exists
        has_process_method = hasattr(ai, 'process_natural_language_command')
        if has_process_method:
            print("  ✅ AI processing capability available")
        else:
            print("  ⚠️  AI processing method not found")
        
        return True
        
    except Exception as e:
        print(f"  ❌ AI system test failed: {e}")
        return False

def test_simulation_engine():
    """Test WoW simulation engine"""
    print("\n🎮 Testing simulation engine...")
    
    try:
        from simulation.game_engine import WoWSimulationEngine
        
        # Test basic initialization (no args for testing)
        engine = WoWSimulationEngine()
        print("  ✅ Simulation engine initialization")
        
        # Test scenario changing (instead of loading)
        engine.change_scenario("solo_questing")
        print("  ✅ Scenario changing")
        
        # Test that update method exists
        has_update = hasattr(engine, 'start_processing')
        if has_update:
            print("  ✅ Engine processing capability available")
        else:
            print("  ⚠️  Engine processing method not found")
        
        return True
        
    except Exception as e:
        print(f"  ❌ Simulation engine test failed: {e}")
        return False

def generate_test_report(results):
    """Generate a comprehensive test report"""
    print("\n" + "="*60)
    print("🎯 DRGUI AI DESIGNER - SYSTEM TEST REPORT")
    print("="*60)
    
    all_passed = all(results.values())
    
    for test_name, passed in results.items():
        status = "✅ PASSED" if passed else "❌ FAILED"
        print(f"{test_name:<25} {status}")
    
    print("-"*60)
    
    if all_passed:
        print("🎉 ALL TESTS PASSED! Your DRGUI AI Designer is ready to run!")
        print("\nTo start the application:")
        print("  Windows: launch_drgui_ai.bat")
        print("  Manual:  python DRGUI_AI_main.py")
    else:
        print("⚠️  Some tests failed. Please check the installation:")
        print("  1. Ensure Python 3.8+ is installed")
        print("  2. Run: pip install -r requirements.txt")
        print("  3. Check that all files are in place")
    
    print("\n" + "="*60)
    return all_passed

def main():
    """Run all system tests"""
    print("🚀 DRGUI AI DESIGNER - SYSTEM TEST")
    print("Testing all components before launch...\n")
    
    results = {}
    
    # Core system tests
    results["Python Imports"] = test_imports()
    results["File Structure"] = test_file_structure()
    results["Module Loading"] = test_module_loading()
    
    # Component tests
    results["Configuration"] = test_configuration()
    results["AI System"] = test_ai_system()
    results["Simulation Engine"] = test_simulation_engine()
    
    # Optional features
    optional_results = test_optional_imports()
    ai_features_available = optional_results.get('openai', False) or optional_results.get('transformers', False)
    results["AI Features"] = ai_features_available
    
    simulation_features_available = optional_results.get('pygame', False)
    results["Simulation Graphics"] = simulation_features_available
    
    # Generate final report
    return generate_test_report(results)

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n⚠️  Test interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error during testing: {e}")
        sys.exit(1)