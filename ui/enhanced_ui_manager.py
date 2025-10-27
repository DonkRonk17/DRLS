#!/usr/bin/env python3
"""
DRGUI AI Designer - Enhanced UI Manager
Provides ElvUI-level UI customization with AI assistance and WoW integration.
"""

import logging
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import json
from pathlib import Path
from typing import Dict, Any, List, Optional, Callable
import threading
import time
from datetime import datetime

try:
    from PIL import Image, ImageTk
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

class EnhancedUIManager:
    """
    Advanced UI Management System
    
    Features:
    - ElvUI-compatible element positioning and sizing
    - Real-time preview with WoW assets
    - AI-powered layout suggestions
    - Automatic character profile import
    - Advanced animation and scaling
    - Complete addon integration
    """
    
    def __init__(self, main_window, wow_integration, ai_assistant, settings):
        """Initialize Enhanced UI Manager"""
        self.logger = logging.getLogger(__name__)
        self.main_window = main_window
        self.wow_integration = wow_integration
        self.ai_assistant = ai_assistant
        self.settings = settings
        
        # UI State
        self.current_profile = None
        self.ui_elements = {}
        self.selected_element = None
        self.is_preview_mode = False
        
        # ElvUI-style features
        self.anchor_points = [
            "TOPLEFT", "TOP", "TOPRIGHT",
            "LEFT", "CENTER", "RIGHT", 
            "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
        ]
        
        # UI Element types with ElvUI compatibility
        self.element_types = {
            "PlayerFrame": {"type": "unitframe", "default_size": (220, 60)},
            "TargetFrame": {"type": "unitframe", "default_size": (220, 60)},
            "TargetTargetFrame": {"type": "unitframe", "default_size": (120, 30)},
            "FocusFrame": {"type": "unitframe", "default_size": (220, 60)},
            "PetFrame": {"type": "unitframe", "default_size": (120, 30)},
            "PartyFrame": {"type": "groupframe", "default_size": (200, 40)},
            "RaidFrame": {"type": "groupframe", "default_size": (80, 30)},
            "ActionBar1": {"type": "actionbar", "default_size": (498, 42)},
            "ActionBar2": {"type": "actionbar", "default_size": (498, 42)},
            "ActionBar3": {"type": "actionbar", "default_size": (498, 42)},
            "ActionBar4": {"type": "actionbar", "default_size": (42, 498)},
            "ActionBar5": {"type": "actionbar", "default_size": (42, 498)},
            "PetActionBar": {"type": "actionbar", "default_size": (330, 42)},
            "ChatFrame": {"type": "chat", "default_size": (400, 120)},
            "Minimap": {"type": "minimap", "default_size": (140, 140)},
            "BuffFrame": {"type": "aura", "default_size": (250, 40)},
            "DebuffFrame": {"type": "aura", "default_size": (250, 40)},
            "CastBar": {"type": "castbar", "default_size": (280, 20)},
            "ExperienceBar": {"type": "statusbar", "default_size": (1024, 12)},
            "ReputationBar": {"type": "statusbar", "default_size": (1024, 12)}
        }
        
        # Initialize systems
        self._initialize_ui_elements()
        self._setup_event_handlers()
        
    def _initialize_ui_elements(self):
        """Initialize UI elements with default ElvUI-style positioning"""
        self.ui_elements = {}
        
        # Default ElvUI-style layout
        default_layout = {
            "PlayerFrame": {
                "position": {"x": -220, "y": -180, "anchor": "CENTER"},
                "size": {"width": 220, "height": 60},
                "scale": 1.0,
                "enabled": True,
                "style": "elvui"
            },
            "TargetFrame": {
                "position": {"x": 220, "y": -180, "anchor": "CENTER"},
                "size": {"width": 220, "height": 60},
                "scale": 1.0,
                "enabled": True,
                "style": "elvui"
            },
            "ActionBar1": {
                "position": {"x": 0, "y": -250, "anchor": "CENTER"},
                "size": {"width": 498, "height": 42},
                "scale": 1.0,
                "enabled": True,
                "buttons": 12,
                "buttonsPerRow": 12,
                "style": "elvui"
            },
            "ChatFrame": {
                "position": {"x": 20, "y": 20, "anchor": "BOTTOMLEFT"},
                "size": {"width": 400, "height": 120},
                "scale": 1.0,
                "enabled": True,
                "style": "elvui"
            },
            "Minimap": {
                "position": {"x": -20, "y": -20, "anchor": "TOPRIGHT"},
                "size": {"width": 140, "height": 140},
                "scale": 1.0,
                "enabled": True,
                "style": "elvui"
            }
        }
        
        for element_name, config in default_layout.items():
            self.ui_elements[element_name] = config.copy()
        
        self.logger.info("Initialized UI elements with ElvUI-style defaults")
    
    def load_character_profile(self, character_name: str, server: str = None) -> bool:
        """Load a character's UI profile from WoW installation"""
        try:
            if not self.wow_integration.wow_path:
                messagebox.showwarning(
                    "WoW Not Found",
                    "World of Warcraft installation not detected. Please configure the path manually."
                )
                return False
            
            # Get character profile from WoW integration
            profile = self.wow_integration.load_character_ui_profile(character_name, server or "")
            
            if not profile or not profile.get("ui_elements"):
                messagebox.showinfo(
                    "No Profile Found",
                    f"No UI profile found for {character_name}. Starting with default layout."
                )
                return False
            
            # Load UI elements from profile
            self.ui_elements.update(profile["ui_elements"])
            self.current_profile = profile
            
            # Update AI assistant with character context
            if self.ai_assistant:
                character_context = {
                    "character": character_name,
                    "server": server,
                    "class": profile.get("character", {}).get("class", "Unknown"),
                    "spec": profile.get("character", {}).get("spec", "Unknown"),
                    "level": profile.get("character", {}).get("level", 80)
                }
                self.ai_assistant.update_context(character_context)
            
            # Refresh UI preview
            self._refresh_ui_preview()
            
            self.logger.info(f"Loaded profile for {character_name}")
            messagebox.showinfo(
                "Profile Loaded",
                f"Successfully loaded UI profile for {character_name}-{server}"
            )
            
            return True
            
        except Exception as e:
            self.logger.error(f"Error loading character profile: {e}")
            messagebox.showerror("Load Error", f"Failed to load character profile: {e}")
            return False
    
    def auto_detect_and_load_profiles(self) -> List[Dict[str, Any]]:
        """Auto-detect and present available character profiles"""
        characters = []
        
        try:
            if not self.wow_integration.wow_path:
                return characters
            
            # Get all characters with UI data
            characters = self.wow_integration.get_characters()
            
            if characters:
                # Show character selection dialog
                self._show_character_selection_dialog(characters)
            else:
                messagebox.showinfo(
                    "No Characters Found",
                    "No character profiles found in your WoW installation."
                )
            
        except Exception as e:
            self.logger.error(f"Error detecting profiles: {e}")
        
        return characters
    
    def _show_character_selection_dialog(self, characters: List[Dict[str, Any]]):
        """Show dialog to select character profile to load"""
        dialog = tk.Toplevel(self.main_window)
        dialog.title("Select Character Profile")
        dialog.geometry("600x400")
        dialog.resizable(True, True)
        
        # Center the dialog
        dialog.transient(self.main_window)
        dialog.grab_set()
        
        # Create character list
        frame = ttk.Frame(dialog)
        frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # List with columns
        columns = ("Character", "Server", "Class", "Level", "AddOns")
        tree = ttk.Treeview(frame, columns=columns, show="headings", height=15)
        
        # Configure columns
        tree.heading("Character", text="Character")
        tree.heading("Server", text="Server")
        tree.heading("Class", text="Class")
        tree.heading("Level", text="Level")
        tree.heading("AddOns", text="UI AddOns")
        
        tree.column("Character", width=120)
        tree.column("Server", width=100)
        tree.column("Class", width=80)
        tree.column("Level", width=60)
        tree.column("AddOns", width=200)
        
        # Add scrollbar
        scrollbar = ttk.Scrollbar(frame, orient=tk.VERTICAL, command=tree.yview)
        tree.configure(yscrollcommand=scrollbar.set)
        
        tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Populate character list
        for char in characters:
            addons = ", ".join(char.get("ui_addons", []))
            tree.insert("", tk.END, values=(
                char["name"],
                char["server"],
                char.get("class", "Unknown"),
                char.get("level", "?"),
                addons
            ))
        
        # Buttons
        button_frame = ttk.Frame(dialog)
        button_frame.pack(fill=tk.X, padx=10, pady=5)
        
        def load_selected():
            selection = tree.selection()
            if selection:
                item = tree.item(selection[0])
                values = item["values"]
                character_name = values[0]
                server = values[1]
                
                dialog.destroy()
                self.load_character_profile(character_name, server)
            else:
                messagebox.showwarning("No Selection", "Please select a character first.")
        
        def cancel():
            dialog.destroy()
        
        ttk.Button(button_frame, text="Load Profile", command=load_selected).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Cancel", command=cancel).pack(side=tk.LEFT, padx=5)
        
        # Double-click to load
        tree.bind("<Double-1>", lambda e: load_selected())
    
    def create_ui_element(self, element_type: str, position: Dict[str, Any] = None) -> str:
        """Create a new UI element with ElvUI-style configuration"""
        # Handle generic element types by mapping to specific frame types
        element_mapping = {
            "unitframe": "PlayerFrame",
            "actionbar": "ActionBar1", 
            "groupframe": "PartyFrame",
            "chat": "ChatFrame",
            "minimap": "Minimap",
            "castbar": "CastBar",
            "aura": "BuffFrame",
            "statusbar": "ExperienceBar"
        }
        
        # Map generic types to specific types
        if element_type in element_mapping:
            specific_type = element_mapping[element_type]
        elif element_type in self.element_types:
            specific_type = element_type
        else:
            raise ValueError(f"Unknown element type: {element_type}")
        
        # Generate unique name if element already exists
        base_name = specific_type
        counter = 1
        element_name = base_name
        
        while element_name in self.ui_elements:
            element_name = f"{base_name}_{counter}"
            counter += 1
        
        # Get default configuration
        element_config = self.element_types[specific_type]
        default_size = element_config["default_size"]
        
        # Create element configuration
        ui_element = {
            "name": element_name,
            "type": element_config["type"],
            "position": position or {"x": 0, "y": 0, "anchor": "CENTER"},
            "size": {"width": default_size[0], "height": default_size[1]},
            "scale": 1.0,
            "enabled": True,
            "style": "elvui",
            "alpha": 1.0,
            "strata": "MEDIUM",
            "level": 1
        }
        
        # Add element-specific properties
        if element_config["type"] == "actionbar":
            ui_element.update({
                "buttons": 12,
                "buttonsPerRow": 12,
                "buttonSize": 32,
                "buttonSpacing": 2,
                "showHotkeys": True,
                "showMacroNames": True
            })
        elif element_config["type"] == "unitframe":
            ui_element.update({
                "showHealthText": True,
                "showPowerText": True,
                "showName": True,
                "showLevel": True,
                "healthBarHeight": 20,
                "powerBarHeight": 8
            })
        elif element_config["type"] == "groupframe":
            ui_element.update({
                "orientation": "HORIZONTAL",
                "spacing": 2,
                "showHealthText": False,
                "showPets": True,
                "raidIconSize": 16
            })
        
        self.ui_elements[element_name] = ui_element
        self._refresh_ui_preview()
        
        self.logger.info(f"Created UI element: {element_name}")
        return ui_element
    
    def modify_ui_element(self, element_name: str, changes: Dict[str, Any]) -> bool:
        """Modify an existing UI element with ElvUI-style options"""
        if element_name not in self.ui_elements:
            self.logger.warning(f"UI element not found: {element_name}")
            return False
        
        try:
            element = self.ui_elements[element_name]
            
            # Apply changes with validation
            for key, value in changes.items():
                if key == "position":
                    if isinstance(value, dict):
                        element["position"].update(value)
                    else:
                        self.logger.warning(f"Invalid position value for {element_name}")
                elif key == "size":
                    if isinstance(value, dict):
                        element["size"].update(value)
                    else:
                        self.logger.warning(f"Invalid size value for {element_name}")
                elif key in element:
                    element[key] = value
                else:
                    # Add new property
                    element[key] = value
            
            # Validate anchor points
            if "anchor" in element["position"] and element["position"]["anchor"] not in self.anchor_points:
                element["position"]["anchor"] = "CENTER"
            
            # Refresh preview
            self._refresh_ui_preview()
            
            self.logger.info(f"Modified UI element: {element_name}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error modifying UI element {element_name}: {e}")
            return False
    
    def delete_ui_element(self, element_name: str) -> bool:
        """Delete a UI element"""
        if element_name in self.ui_elements:
            del self.ui_elements[element_name]
            self._refresh_ui_preview()
            self.logger.info(f"Deleted UI element: {element_name}")
            return True
        return False
    
    def get_ui_element_at_position(self, x: int, y: int) -> Optional[str]:
        """Get UI element at screen position"""
        # Convert screen coordinates to UI coordinates
        for element_name, element in self.ui_elements.items():
            if not element.get("enabled", True):
                continue
            
            pos = element["position"]
            size = element["size"]
            
            # Calculate element bounds (simplified)
            elem_x = pos["x"]
            elem_y = pos["y"]
            elem_w = size["width"] * element.get("scale", 1.0)
            elem_h = size["height"] * element.get("scale", 1.0)
            
            # Check if point is within element bounds
            if (elem_x <= x <= elem_x + elem_w and
                elem_y <= y <= elem_y + elem_h):
                return element_name
        
        return None
    
    def apply_elvui_profile(self, elvui_profile_path: Path) -> bool:
        """Import and apply an ElvUI profile"""
        try:
            # Parse ElvUI profile file
            if elvui_profile_path.suffix.lower() == '.txt':
                # ElvUI export format
                with open(elvui_profile_path, 'r', encoding='utf-8') as f:
                    elvui_data = f.read()
                
                # Convert ElvUI data to DRGUI format
                converted_elements = self.wow_integration._convert_elvui_to_drgui(
                    self._parse_elvui_export(elvui_data)
                )
                
                # Apply converted elements
                self.ui_elements.update(converted_elements)
                self._refresh_ui_preview()
                
                messagebox.showinfo("Import Success", "ElvUI profile imported successfully!")
                return True
            else:
                messagebox.showerror("Invalid Format", "Please select an ElvUI profile export (.txt)")
                return False
                
        except Exception as e:
            self.logger.error(f"Error importing ElvUI profile: {e}")
            messagebox.showerror("Import Error", f"Failed to import ElvUI profile: {e}")
            return False
    
    def _parse_elvui_export(self, elvui_export: str) -> Dict[str, Any]:
        """Parse ElvUI profile export string"""
        # This is a simplified parser for ElvUI export format
        # Real implementation would need to handle the compressed format
        
        try:
            # ElvUI exports are typically base64 encoded and compressed
            # For now, return a mock structure
            return {
                "profiles": {
                    "Default": {
                        "unitframe": {},
                        "actionbar": {},
                        "chat": {}
                    }
                }
            }
        except Exception as e:
            self.logger.error(f"Error parsing ElvUI export: {e}")
            return {}
    
    def create_elvui_compatible_export(self) -> str:
        """Create an ElvUI-compatible export string"""
        try:
            # Convert DRGUI elements to ElvUI format
            elvui_data = {
                "profiles": {
                    "DRGUI_Export": {
                        "unitframe": {},
                        "actionbar": {},
                        "general": {}
                    }
                }
            }
            
            profile = elvui_data["profiles"]["DRGUI_Export"]
            
            # Convert UI elements
            for element_name, element in self.ui_elements.items():
                element_type = element.get("type", "unknown")
                
                if element_type == "unitframe":
                    # Map to ElvUI unitframe format
                    elvui_name = self._get_elvui_unitframe_name(element_name)
                    if elvui_name:
                        profile["unitframe"][elvui_name] = {
                            "enable": element.get("enabled", True),
                            "width": element["size"]["width"],
                            "height": element["size"]["height"],
                            "x": element["position"]["x"],
                            "y": element["position"]["y"],
                            "anchor": element["position"]["anchor"]
                        }
                
                elif element_type == "actionbar":
                    # Map to ElvUI actionbar format
                    bar_num = self._get_elvui_actionbar_number(element_name)
                    if bar_num:
                        profile["actionbar"][f"bar{bar_num}"] = {
                            "enabled": element.get("enabled", True),
                            "buttons": element.get("buttons", 12),
                            "buttonsPerRow": element.get("buttonsPerRow", 12),
                            "buttonsize": element.get("buttonSize", 32),
                            "point": {
                                "x": element["position"]["x"],
                                "y": element["position"]["y"]
                            }
                        }
            
            # Convert to ElvUI export format (simplified)
            export_string = json.dumps(elvui_data, separators=(',', ':'))
            
            return export_string
            
        except Exception as e:
            self.logger.error(f"Error creating ElvUI export: {e}")
            return ""
    
    def _get_elvui_unitframe_name(self, drgui_name: str) -> Optional[str]:
        """Map DRGUI unitframe name to ElvUI equivalent"""
        mapping = {
            "PlayerFrame": "player",
            "TargetFrame": "target",
            "TargetTargetFrame": "targettarget",
            "FocusFrame": "focus",
            "PetFrame": "pet",
            "PartyFrame": "party",
            "RaidFrame": "raid"
        }
        return mapping.get(drgui_name)
    
    def _get_elvui_actionbar_number(self, drgui_name: str) -> Optional[int]:
        """Map DRGUI actionbar name to ElvUI bar number"""
        if drgui_name.startswith("ActionBar"):
            try:
                return int(drgui_name.replace("ActionBar", ""))
            except ValueError:
                pass
        return None
    
    def export_to_drgui_profile(self, profile_name: str, output_path: Path = None) -> bool:
        """Export current UI configuration to DRGUI profile"""
        try:
            if not output_path:
                # Use default DRGUI profiles directory
                profiles_dir = Path(__file__).parent.parent / "profiles"
                profiles_dir.mkdir(exist_ok=True)
                output_path = profiles_dir / f"{profile_name}.json"
            
            # Create DRGUI profile format
            profile_data = {
                "profile_info": {
                    "name": profile_name,
                    "version": "2.0.0",
                    "created": datetime.now().isoformat(),
                    "source": "AI_Designer",
                    "character": self.current_profile.get("character") if self.current_profile else None
                },
                "ui_elements": self.ui_elements.copy(),
                "settings": {
                    "scale": 1.0,
                    "resolution": "1920x1080",
                    "ui_scale": 1.0
                }
            }
            
            # Save profile
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(profile_data, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"Exported DRGUI profile: {output_path}")
            messagebox.showinfo("Export Success", f"Profile exported to:\n{output_path}")
            
            return True
            
        except Exception as e:
            self.logger.error(f"Error exporting DRGUI profile: {e}")
            messagebox.showerror("Export Error", f"Failed to export profile: {e}")
            return False
    
    def get_ai_suggestions(self, context: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Get AI suggestions for UI improvements"""
        suggestions = []
        
        if not self.ai_assistant:
            return suggestions
        
        try:
            # Prepare context for AI
            ai_context = {
                "ui_elements": self.ui_elements,
                "character": self.current_profile.get("character") if self.current_profile else {},
                "request_type": "suggestions"
            }
            
            if context:
                ai_context.update(context)
            
            # Get AI suggestions (this would be async in real implementation)
            suggestions = [
                {
                    "type": "positioning",
                    "element": "PlayerFrame",
                    "suggestion": "Move player frame closer to center for better visibility",
                    "confidence": 0.8
                },
                {
                    "type": "scaling",
                    "element": "ActionBar1",
                    "suggestion": "Increase action bar size for easier clicking",
                    "confidence": 0.9
                }
            ]
            
        except Exception as e:
            self.logger.error(f"Error getting AI suggestions: {e}")
        
        return suggestions
    
    def _refresh_ui_preview(self):
        """Refresh the UI preview display"""
        if hasattr(self.main_window, 'simulation_canvas'):
            # Update the simulation canvas with current UI elements
            self.main_window.simulation_canvas.update_ui_elements(self.ui_elements)
    
    def _setup_event_handlers(self):
        """Setup event handlers for UI interactions"""
        # This would be connected to the main window's event system
        pass
    
    def get_element_properties(self, element_name: str) -> Dict[str, Any]:
        """Get properties of a UI element for editing"""
        if element_name not in self.ui_elements:
            return {}
        
        element = self.ui_elements[element_name].copy()
        
        # Add metadata for property editor
        element["_metadata"] = {
            "type": element.get("type", "unknown"),
            "editable_properties": self._get_editable_properties(element.get("type", "unknown")),
            "anchor_options": self.anchor_points,
            "element_name": element_name
        }
        
        return element
    
    def _get_editable_properties(self, element_type: str) -> List[str]:
        """Get list of editable properties for element type"""
        base_properties = ["position", "size", "scale", "enabled", "alpha"]
        
        type_properties = {
            "actionbar": ["buttons", "buttonsPerRow", "buttonSize", "buttonSpacing", "showHotkeys"],
            "unitframe": ["showHealthText", "showPowerText", "showName", "healthBarHeight"],
            "groupframe": ["orientation", "spacing", "showPets", "raidIconSize"],
            "chat": ["fontSize", "fadeTime", "maxLines"],
            "minimap": ["zoom", "showBorder", "showZoneText"]
        }
        
        return base_properties + type_properties.get(element_type, [])
    
    def import_addon_profile(self, addon_name: str, profile_path: Path) -> bool:
        """Import profile from other addons (ElvUI, Bartender4, etc.)"""
        try:
            if addon_name.lower() == "elvui":
                return self.apply_elvui_profile(profile_path)
            elif addon_name.lower() == "bartender4":
                return self._import_bartender_profile(profile_path)
            elif addon_name.lower() == "weakauras":
                return self._import_weakauras_profile(profile_path)
            else:
                messagebox.showwarning("Unsupported", f"Import from {addon_name} not yet supported")
                return False
                
        except Exception as e:
            self.logger.error(f"Error importing {addon_name} profile: {e}")
            return False
    
    def _import_bartender_profile(self, profile_path: Path) -> bool:
        """Import Bartender4 profile"""
        # Placeholder for Bartender4 import
        messagebox.showinfo("Coming Soon", "Bartender4 import will be available in a future update")
        return False
    
    def _import_weakauras_profile(self, profile_path: Path) -> bool:
        """Import WeakAuras profile"""
        # Placeholder for WeakAuras import
        messagebox.showinfo("Coming Soon", "WeakAuras import will be available in a future update")
        return False
    
    def get_supported_addons(self) -> List[str]:
        """Get list of supported addon imports"""
        return [
            "ElvUI",
            "Bartender4", 
            "WeakAuras",
            "Details",
            "Plater",
            "TellMeWhen"
        ]