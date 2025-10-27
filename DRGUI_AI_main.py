#!/usr/bin/env python3
"""
DRGUI AI-Powered Offline UI Designer
Main Application Entry Point

A revolutionary standalone application that provides an AI-assisted, 
WoW-like environment for designing perfect UI layouts offline.

Author: DRGUI Development Team
Version: 2.0.0-AI-Designer
License: MIT
"""

import sys
import os
import json
import logging
from pathlib import Path
import tkinter as tk
from tkinter import ttk, messagebox
import threading
import queue

# Add project root to Python path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

# Import our custom modules
try:
    from ui.main_window import DRGUIMainWindow
    from ai.natural_language import AIAssistant
    from simulation.game_engine import WoWSimulationEngine
    from config.settings_manager import SettingsManager
except ImportError as e:
    print(f"Failed to import required modules: {e}")
    print("Please ensure all dependencies are installed and modules are available.")
    sys.exit(1)

class DRGUIAIDesigner:
    """
    Main application class for DRGUI AI Designer
    
    Coordinates all major subsystems:
    - UI Management
    - AI Assistant
    - WoW Simulation Engine
    - Profile Management
    - Settings and Configuration
    """
    
    def __init__(self):
        """Initialize the DRGUI AI Designer application"""
        self.version = "2.0.0-AI-Designer"
        self.app_name = "DRGUI AI-Powered UI Designer"
        
        # Initialize logging
        self.setup_logging()
        self.logger = logging.getLogger(__name__)
        self.logger.info(f"Starting {self.app_name} v{self.version}")
        
        # Initialize core systems
        self.settings = None
        self.main_window = None
        self.ai_assistant = None
        self.simulation_engine = None
        
        # Threading and communication
        self.ai_queue = queue.Queue()
        self.simulation_queue = queue.Queue()
        self.shutdown_event = threading.Event()
        
        # Application state
        self.current_profile = None
        self.is_running = False
        
    def setup_logging(self):
        """Configure logging for the application"""
        log_dir = project_root / "logs"
        log_dir.mkdir(exist_ok=True)
        
        log_file = log_dir / "drgui_ai_designer.log"
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )
        
    def initialize_core_systems(self):
        """Initialize all core application systems"""
        try:
            # Load settings and configuration
            self.logger.info("Loading application settings...")
            self.settings = SettingsManager()
            
            # Initialize AI Assistant
            self.logger.info("Initializing AI Assistant...")
            self.ai_assistant = AIAssistant(
                settings=self.settings,
                message_queue=self.ai_queue
            )
            
            # Initialize WoW Simulation Engine
            self.logger.info("Initializing WoW Simulation Engine...")
            self.simulation_engine = WoWSimulationEngine(
                settings=self.settings,
                message_queue=self.simulation_queue
            )
            
            # Initialize main window
            self.logger.info("Creating main application window...")
            self.main_window = DRGUIMainWindow(
                app_controller=self,
                ai_assistant=self.ai_assistant,
                simulation_engine=self.simulation_engine,
                settings=self.settings
            )
            
            self.logger.info("Core systems initialized successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to initialize core systems: {e}")
            messagebox.showerror(
                "Initialization Error",
                f"Failed to start DRGUI AI Designer:\n\n{str(e)}\n\n"
                "Please check the log file for more details."
            )
            return False
    
    def start_background_services(self):
        """Start background threads for AI and simulation processing"""
        try:
            # Start AI processing thread
            ai_thread = threading.Thread(
                target=self.ai_assistant.start_processing,
                args=(self.shutdown_event,),
                name="AI-Assistant-Thread",
                daemon=True
            )
            ai_thread.start()
            self.logger.info("AI Assistant thread started")
            
            # Start simulation processing thread
            sim_thread = threading.Thread(
                target=self.simulation_engine.start_processing,
                args=(self.shutdown_event,),
                name="Simulation-Engine-Thread", 
                daemon=True
            )
            sim_thread.start()
            self.logger.info("Simulation Engine thread started")
            
            # Start message processing thread
            msg_thread = threading.Thread(
                target=self.process_background_messages,
                name="Message-Processing-Thread",
                daemon=True
            )
            msg_thread.start()
            self.logger.info("Message processing thread started")
            
        except Exception as e:
            self.logger.error(f"Failed to start background services: {e}")
            raise
    
    def process_background_messages(self):
        """Process messages from AI and simulation threads"""
        while not self.shutdown_event.is_set():
            try:
                # Process AI messages
                try:
                    ai_message = self.ai_queue.get(timeout=0.1)
                    self.handle_ai_message(ai_message)
                except queue.Empty:
                    pass
                
                # Process simulation messages
                try:
                    sim_message = self.simulation_queue.get(timeout=0.1)
                    self.handle_simulation_message(sim_message)
                except queue.Empty:
                    pass
                    
            except Exception as e:
                self.logger.error(f"Error processing background messages: {e}")
    
    def handle_ai_message(self, message):
        """Handle messages from AI Assistant"""
        try:
            if self.main_window:
                self.main_window.handle_ai_response(message)
        except Exception as e:
            self.logger.error(f"Error handling AI message: {e}")
    
    def handle_simulation_message(self, message):
        """Handle messages from Simulation Engine"""
        try:
            if self.main_window:
                self.main_window.handle_simulation_update(message)
        except Exception as e:
            self.logger.error(f"Error handling simulation message: {e}")
    
    def run(self):
        """Main application loop"""
        try:
            # Initialize all systems
            if not self.initialize_core_systems():
                return False
            
            # Start background services
            self.start_background_services()
            
            # Show splash screen with loading progress
            self.show_splash_screen()
            
            # Start the main application
            self.is_running = True
            self.logger.info(f"{self.app_name} is now running")
            
            # Run the tkinter main loop
            self.main_window.mainloop()
            
        except KeyboardInterrupt:
            self.logger.info("Application interrupted by user")
        except Exception as e:
            self.logger.error(f"Application error: {e}")
            messagebox.showerror("Application Error", f"An unexpected error occurred:\n\n{str(e)}")
        finally:
            self.shutdown()
        
        return True
    
    def show_splash_screen(self):
        """Show loading splash screen with progress"""
        splash = tk.Toplevel()
        splash.title(f"{self.app_name}")
        splash.geometry("600x400")
        splash.resizable(False, False)
        
        # Center the splash screen
        splash.geometry("+{}+{}".format(
            (splash.winfo_screenwidth() // 2) - 300,
            (splash.winfo_screenheight() // 2) - 200
        ))
        
        # Remove window decorations
        splash.overrideredirect(True)
        
        # Create splash content
        main_frame = ttk.Frame(splash, padding="20")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Title
        title_label = ttk.Label(
            main_frame,
            text="DRGUI AI Designer",
            font=("Arial", 24, "bold")
        )
        title_label.pack(pady=(50, 10))
        
        # Subtitle
        subtitle_label = ttk.Label(
            main_frame,
            text="AI-Powered Offline UI Customization",
            font=("Arial", 12)
        )
        subtitle_label.pack(pady=(0, 30))
        
        # Progress bar
        progress_var = tk.DoubleVar()
        progress_bar = ttk.Progressbar(
            main_frame,
            variable=progress_var,
            maximum=100,
            length=400
        )
        progress_bar.pack(pady=(0, 20))
        
        # Status label
        status_var = tk.StringVar(value="Initializing AI systems...")
        status_label = ttk.Label(main_frame, textvariable=status_var)
        status_label.pack()
        
        # Simulate loading progress
        loading_steps = [
            ("Loading AI models...", 20),
            ("Initializing WoW simulation...", 40),
            ("Preparing UI components...", 60),
            ("Loading templates and assets...", 80),
            ("Finalizing setup...", 100)
        ]
        
        def update_progress():
            for step_text, progress in loading_steps:
                status_var.set(step_text)
                progress_var.set(progress)
                splash.update()
                splash.after(500)  # Wait 500ms between steps
            
            # Close splash and show main window
            splash.destroy()
            if self.main_window:
                self.main_window.deiconify()  # Show main window
        
        # Start progress update
        splash.after(100, update_progress)
    
    def shutdown(self):
        """Clean shutdown of all application systems"""
        self.logger.info("Shutting down DRGUI AI Designer...")
        
        # Signal shutdown to all threads
        self.shutdown_event.set()
        
        # Save current state
        if self.settings:
            self.settings.save()
        
        # Clean up resources
        if self.ai_assistant:
            self.ai_assistant.cleanup()
        
        if self.simulation_engine:
            self.simulation_engine.cleanup()
        
        self.is_running = False
        self.logger.info("Shutdown complete")

def check_dependencies():
    """Check if all required dependencies are available"""
    required_modules = [
        'tkinter',
        'pygame', 
        'PIL',
        'numpy',
        'sqlite3'
    ]
    
    missing_modules = []
    
    for module in required_modules:
        try:
            __import__(module)
        except ImportError:
            missing_modules.append(module)
    
    if missing_modules:
        print("Missing required dependencies:")
        for module in missing_modules:
            print(f"  - {module}")
        print("\nPlease install missing dependencies and try again.")
        print("Run: pip install -r requirements.txt")
        return False
    
    return True

def main():
    """Main entry point for the application"""
    print("=" * 60)
    print("DRGUI AI-Powered Offline UI Designer v2.0.0")
    print("The War Within Expansion Ready")
    print("=" * 60)
    
    # Check dependencies
    if not check_dependencies():
        sys.exit(1)
    
    # Create and run the application
    try:
        app = DRGUIAIDesigner()
        success = app.run()
        
        if success:
            print("\nDRGUI AI Designer closed successfully.")
            sys.exit(0)
        else:
            print("\nDRGUI AI Designer failed to start.")
            sys.exit(1)
            
    except Exception as e:
        print(f"\nFatal error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()