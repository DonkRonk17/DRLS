#!/usr/bin/env python3
"""
DRGUI AI Designer - WoW Integration Module
Provides seamless integration with World of Warcraft game files and character data.
"""

import os
import json
import logging
import sqlite3
import configparser
from pathlib import Path
from typing import Dict, Any, List, Optional, Tuple
import xml.etree.ElementTree as ET
import requests
from datetime import datetime

try:
    from PIL import Image, ImageTk
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

try:
    import cv2
    import numpy as np
    OPENCV_AVAILABLE = True
except ImportError:
    OPENCV_AVAILABLE = False

class WoWIntegration:
    """
    Comprehensive WoW Integration System
    
    Features:
    - Automatic WoW installation detection
    - Character data extraction from SavedVariables
    - UI configuration import from DRGUI and other addons
    - WoW Armory integration for character information
    - Game asset extraction for authentic UI preview
    - ElvUI configuration parsing and conversion
    """
    
    def __init__(self, settings_manager):
        """Initialize WoW Integration"""
        self.logger = logging.getLogger(__name__)
        self.settings = settings_manager
        
        # WoW installation paths
        self.wow_path = self._detect_wow_installation()
        self.addon_path = None
        self.saved_variables_path = None
        self.wtf_path = None
        
        if self.wow_path:
            self._setup_wow_paths()
        
        # Character and UI data
        self.character_data = {}
        self.addon_configurations = {}
        self.ui_profiles = {}
        
        # Asset cache
        self.asset_cache = {}
        self.texture_cache = {}
        
        # Initialize integration
        self._initialize_integration()
    
    def _detect_wow_installation(self) -> Optional[Path]:
        """Detect WoW installation automatically"""
        self.logger.info("Detecting World of Warcraft installation...")
        
        # Check if we're running from within the WoW installation
        current_path = Path(__file__).resolve()
        for parent in current_path.parents:
            if parent.name == "World of Warcraft" and parent.exists():
                # Check for _retail_ subdirectory to confirm this is the WoW root
                retail_path = parent / "_retail_"
                if retail_path.exists():
                    self.logger.info(f"Found WoW installation at: {parent}")
                    return parent
        
        # Common WoW installation paths
        possible_paths = [
            Path("C:/Program Files (x86)/Battle.net/World of Warcraft"),
            Path("C:/Program Files/Battle.net/World of Warcraft"),
            Path("C:/Games/World of Warcraft"),
            Path("D:/Program Files (x86)/Battle.net/World of Warcraft"),
            Path("D:/Program Files/Battle.net/World of Warcraft"),
            Path("D:/Games/World of Warcraft"),
            Path(os.path.expanduser("~/Games/World of Warcraft")),
        ]
        
        # Check Battle.net config for custom path
        battlenet_config = self._get_battlenet_wow_path()
        if battlenet_config:
            possible_paths.insert(0, Path(battlenet_config))
        
        for path in possible_paths:
            if self._is_valid_wow_installation(path):
                self.logger.info(f"Found WoW installation at: {path}")
                return path
        
        self.logger.warning("WoW installation not found automatically")
        return None
    
    def _get_battlenet_wow_path(self) -> Optional[str]:
        """Get WoW path from Battle.net configuration"""
        try:
            # Battle.net config locations
            config_paths = [
                Path(os.environ.get('PROGRAMDATA', '')) / "Battle.net" / "Agent" / "product.db",
                Path(os.environ.get('APPDATA', '')) / "Battle.net" / "Battle.net.config",
            ]
            
            for config_path in config_paths:
                if config_path.exists():
                    # Parse Battle.net configuration for WoW path
                    # This is a simplified approach - actual parsing may vary
                    with open(config_path, 'r', errors='ignore') as f:
                        content = f.read()
                        if 'World of Warcraft' in content:
                            # Extract path information
                            lines = content.split('\n')
                            for line in lines:
                                if 'InstallPath' in line and 'World of Warcraft' in line:
                                    # Extract the path
                                    start = line.find('"') + 1
                                    end = line.rfind('"')
                                    if start > 0 and end > start:
                                        return line[start:end]
        except Exception as e:
            self.logger.debug(f"Could not read Battle.net config: {e}")
        
        return None
    
    def _is_valid_wow_installation(self, path: Path) -> bool:
        """Check if path contains a valid WoW installation"""
        if not path.exists():
            return False
        
        # Check for key WoW files and directories
        required_items = [
            path / "_retail_" / "Interface",
            path / "_retail_" / "WTF",
            path / "_retail_" / "Data",
            path / "World of Warcraft Launcher.exe"
        ]
        
        return all(item.exists() for item in required_items)
    
    def _setup_wow_paths(self):
        """Setup WoW-related paths"""
        if not self.wow_path:
            return
        
        self.addon_path = self.wow_path / "_retail_" / "Interface" / "AddOns"
        self.saved_variables_path = self.wow_path / "_retail_" / "WTF" / "Account"
        self.wtf_path = self.wow_path / "_retail_" / "WTF"
        
        self.logger.info(f"WoW paths configured:")
        self.logger.info(f"  AddOns: {self.addon_path}")
        self.logger.info(f"  SavedVariables: {self.saved_variables_path}")
        self.logger.info(f"  WTF: {self.wtf_path}")
    
    def _initialize_integration(self):
        """Initialize WoW integration systems"""
        if not self.wow_path:
            self.logger.warning("WoW integration limited - installation not found")
            return
        
        # Load existing character data
        self._load_character_data()
        
        # Load addon configurations
        self._load_addon_configurations()
        
        # Cache frequently used assets
        self._cache_common_assets()
    
    def get_characters(self) -> List[Dict[str, Any]]:
        """Get list of all characters with their basic information"""
        characters = []
        
        if not self.saved_variables_path or not self.saved_variables_path.exists():
            return characters
        
        try:
            # Scan account folders
            for account_folder in self.saved_variables_path.iterdir():
                if account_folder.is_dir():
                    # Scan server folders
                    for server_folder in account_folder.iterdir():
                        if server_folder.is_dir() and server_folder.name != "SavedVariables":
                            # Scan character folders
                            for char_folder in server_folder.iterdir():
                                if char_folder.is_dir():
                                    char_info = self._extract_character_info(
                                        account_folder.name,
                                        server_folder.name,
                                        char_folder.name
                                    )
                                    if char_info:
                                        characters.append(char_info)
        
        except Exception as e:
            self.logger.error(f"Error scanning for characters: {e}")
        
        return characters
    
    def _extract_character_info(self, account: str, server: str, character: str) -> Optional[Dict[str, Any]]:
        """Extract character information from SavedVariables"""
        try:
            char_path = self.saved_variables_path / account / server / character
            
            # Look for SavedVariables files
            saved_vars_files = [
                char_path / "SavedVariables" / "DRGUI.lua",
                char_path / "SavedVariables" / "ElvUI.lua",
                char_path / "SavedVariables" / "Bartender4.lua",
                char_path / "SavedVariables" / "Details.lua",
            ]
            
            char_info = {
                "name": character,
                "server": server,
                "account": account,
                "class": "Unknown",
                "level": 0,
                "faction": "Unknown",
                "race": "Unknown",
                "spec": "Unknown",
                "ui_addons": [],
                "profiles": {},
                "last_login": None
            }
            
            # Parse character data from addon files
            for var_file in saved_vars_files:
                if var_file.exists():
                    addon_name = var_file.stem
                    char_info["ui_addons"].append(addon_name)
                    
                    # Parse the Lua file for character data
                    char_data = self._parse_lua_saved_variables(var_file)
                    if char_data:
                        char_info["profiles"][addon_name] = char_data
                        
                        # Extract character details from DRGUI if available
                        if addon_name == "DRGUI" and character in char_data:
                            drgui_data = char_data[character]
                            char_info.update({
                                "class": drgui_data.get("class", "Unknown"),
                                "level": drgui_data.get("level", 0),
                                "race": drgui_data.get("race", "Unknown"),
                                "spec": drgui_data.get("spec", "Unknown")
                            })
            
            return char_info
            
        except Exception as e:
            self.logger.error(f"Error extracting character info for {character}: {e}")
            return None
    
    def _parse_lua_saved_variables(self, file_path: Path) -> Dict[str, Any]:
        """Parse Lua SavedVariables file"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Simple Lua parsing - convert to Python-like structure
            # This is a simplified parser for basic Lua tables
            data = self._lua_to_dict(content)
            return data
            
        except Exception as e:
            self.logger.error(f"Error parsing Lua file {file_path}: {e}")
            return {}
    
    def _lua_to_dict(self, lua_content: str) -> Dict[str, Any]:
        """Convert simple Lua table syntax to Python dict"""
        # This is a simplified Lua parser for basic table structures
        # For production use, consider using a proper Lua parser library
        
        result = {}
        lines = lua_content.split('\n')
        
        current_table = None
        current_data = {}
        
        for line in lines:
            line = line.strip()
            
            # Skip comments and empty lines
            if not line or line.startswith('--'):
                continue
            
            # Look for table definitions
            if '= {' in line:
                table_name = line.split('=')[0].strip()
                if table_name:
                    current_table = table_name
                    current_data = {}
            
            # Look for simple key-value pairs
            elif '=' in line and current_table:
                try:
                    key, value = line.split('=', 1)
                    key = key.strip().strip('"\'[]')
                    value = value.strip().rstrip(',')
                    
                    # Convert value types
                    if value.startswith('"') and value.endswith('"'):
                        value = value[1:-1]  # String
                    elif value.lower() in ['true', 'false']:
                        value = value.lower() == 'true'  # Boolean
                    elif value.isdigit():
                        value = int(value)  # Integer
                    elif '.' in value and value.replace('.', '').isdigit():
                        value = float(value)  # Float
                    
                    current_data[key] = value
                    
                except Exception:
                    continue
            
            # End of table
            elif line == '}' and current_table:
                result[current_table] = current_data.copy()
                current_table = None
                current_data = {}
        
        return result
    
    def load_character_ui_profile(self, character_name: str, server: str, account: str = None) -> Dict[str, Any]:
        """Load a character's complete UI profile"""
        profile = {
            "character": character_name,
            "server": server,
            "account": account,
            "ui_elements": {},
            "addon_settings": {},
            "keybindings": {},
            "macros": [],
            "chat_settings": {},
            "interface_settings": {}
        }
        
        if not self.saved_variables_path:
            return profile
        
        try:
            # Find character's SavedVariables
            char_path = None
            if account:
                char_path = self.saved_variables_path / account / server / character_name
            else:
                # Search all accounts
                for acc_folder in self.saved_variables_path.iterdir():
                    if acc_folder.is_dir():
                        test_path = acc_folder / server / character_name
                        if test_path.exists():
                            char_path = test_path
                            account = acc_folder.name
                            break
            
            if not char_path or not char_path.exists():
                self.logger.warning(f"Character data not found: {character_name}-{server}")
                return profile
            
            profile["account"] = account
            
            # Load DRGUI profile
            drgui_file = char_path / "SavedVariables" / "DRGUI.lua"
            if drgui_file.exists():
                drgui_data = self._parse_lua_saved_variables(drgui_file)
                profile["addon_settings"]["DRGUI"] = drgui_data
                
                # Extract UI elements from DRGUI
                if character_name in drgui_data:
                    char_drgui = drgui_data[character_name]
                    profile["ui_elements"].update(char_drgui.get("ui_elements", {}))
            
            # Load ElvUI profile if present
            elvui_file = char_path / "SavedVariables" / "ElvUI.lua"
            if elvui_file.exists():
                elvui_data = self._parse_lua_saved_variables(elvui_file)
                profile["addon_settings"]["ElvUI"] = elvui_data
                
                # Convert ElvUI settings to DRGUI format
                converted_ui = self._convert_elvui_to_drgui(elvui_data)
                profile["ui_elements"].update(converted_ui)
            
            # Load other addon configurations
            saved_vars_dir = char_path / "SavedVariables"
            if saved_vars_dir.exists():
                for addon_file in saved_vars_dir.glob("*.lua"):
                    addon_name = addon_file.stem
                    if addon_name not in ["DRGUI", "ElvUI"]:
                        addon_data = self._parse_lua_saved_variables(addon_file)
                        profile["addon_settings"][addon_name] = addon_data
            
            # Load keybindings
            bindings_file = char_path / "bindings-cache.wtf"
            if bindings_file.exists():
                profile["keybindings"] = self._parse_keybindings(bindings_file)
            
            # Load macros
            macros_file = char_path / "macros-cache.txt"
            if macros_file.exists():
                profile["macros"] = self._parse_macros(macros_file)
            
            self.logger.info(f"Loaded UI profile for {character_name}-{server}")
            
        except Exception as e:
            self.logger.error(f"Error loading character UI profile: {e}")
        
        return profile
    
    def _convert_elvui_to_drgui(self, elvui_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convert ElvUI configuration to DRGUI-compatible format"""
        converted = {}
        
        try:
            # Map ElvUI frame positions to DRGUI format
            if "profiles" in elvui_data:
                for profile_name, profile_data in elvui_data["profiles"].items():
                    if isinstance(profile_data, dict):
                        # Convert unitframes
                        if "unitframe" in profile_data:
                            uf_data = profile_data["unitframe"]
                            converted.update(self._convert_elvui_unitframes(uf_data))
                        
                        # Convert actionbars
                        if "actionbar" in profile_data:
                            ab_data = profile_data["actionbar"]
                            converted.update(self._convert_elvui_actionbars(ab_data))
                        
                        # Convert chat
                        if "chat" in profile_data:
                            chat_data = profile_data["chat"]
                            converted.update(self._convert_elvui_chat(chat_data))
        
        except Exception as e:
            self.logger.error(f"Error converting ElvUI data: {e}")
        
        return converted
    
    def _convert_elvui_unitframes(self, uf_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convert ElvUI unitframe settings to DRGUI format"""
        converted = {}
        
        frame_mapping = {
            "player": "PlayerFrame",
            "target": "TargetFrame", 
            "targettarget": "TargetTargetFrame",
            "focus": "FocusFrame",
            "pet": "PetFrame",
            "party": "PartyFrame",
            "raid": "RaidFrame"
        }
        
        for elvui_name, drgui_name in frame_mapping.items():
            if elvui_name in uf_data:
                frame_data = uf_data[elvui_name]
                if isinstance(frame_data, dict):
                    converted[drgui_name] = {
                        "position": {
                            "x": frame_data.get("x", 0),
                            "y": frame_data.get("y", 0),
                            "anchor": frame_data.get("anchor", "CENTER")
                        },
                        "size": {
                            "width": frame_data.get("width", 100),
                            "height": frame_data.get("height", 30)
                        },
                        "enabled": frame_data.get("enable", True),
                        "scale": frame_data.get("scale", 1.0)
                    }
        
        return converted
    
    def _convert_elvui_actionbars(self, ab_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convert ElvUI actionbar settings to DRGUI format"""
        converted = {}
        
        for i in range(1, 11):  # ElvUI has bars 1-10
            bar_key = f"bar{i}"
            if bar_key in ab_data:
                bar_data = ab_data[bar_key]
                if isinstance(bar_data, dict):
                    converted[f"ActionBar{i}"] = {
                        "position": {
                            "x": bar_data.get("point", {}).get("x", 0),
                            "y": bar_data.get("point", {}).get("y", 0)
                        },
                        "enabled": bar_data.get("enabled", True),
                        "buttons": bar_data.get("buttons", 12),
                        "buttonsPerRow": bar_data.get("buttonsPerRow", 12),
                        "scale": bar_data.get("buttonsize", 32) / 32  # Convert to scale
                    }
        
        return converted
    
    def _convert_elvui_chat(self, chat_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convert ElvUI chat settings to DRGUI format"""
        converted = {}
        
        if "panelWidth" in chat_data:
            converted["ChatFrame"] = {
                "size": {
                    "width": chat_data.get("panelWidth", 400),
                    "height": chat_data.get("panelHeight", 180)
                },
                "position": {
                    "x": 0,
                    "y": 0,
                    "anchor": "BOTTOMLEFT"
                }
            }
        
        return converted
    
    def _parse_keybindings(self, bindings_file: Path) -> Dict[str, str]:
        """Parse WoW keybindings file"""
        bindings = {}
        
        try:
            with open(bindings_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    line = line.strip()
                    if line.startswith('bind '):
                        parts = line.split(' ', 2)
                        if len(parts) >= 3:
                            key = parts[1]
                            action = parts[2]
                            bindings[action] = key
        
        except Exception as e:
            self.logger.error(f"Error parsing keybindings: {e}")
        
        return bindings
    
    def _parse_macros(self, macros_file: Path) -> List[Dict[str, str]]:
        """Parse WoW macros file"""
        macros = []
        
        try:
            with open(macros_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
                # Split macros (they're separated by null bytes typically)
                macro_parts = content.split('\x00')
                
                for i in range(0, len(macro_parts) - 1, 2):
                    if i + 1 < len(macro_parts):
                        name = macro_parts[i].strip()
                        body = macro_parts[i + 1].strip()
                        if name and body:
                            macros.append({
                                "name": name,
                                "body": body,
                                "icon": "INV_Misc_QuestionMark"  # Default icon
                            })
        
        except Exception as e:
            self.logger.error(f"Error parsing macros: {e}")
        
        return macros
    
    def get_wow_armory_data(self, character_name: str, server: str, region: str = "us") -> Dict[str, Any]:
        """Fetch character data from WoW Armory API"""
        armory_data = {}
        
        try:
            # This would require Battle.net API credentials
            # For now, return mock data structure
            armory_data = {
                "name": character_name,
                "realm": server,
                "class": "Unknown",
                "race": "Unknown",
                "level": 80,
                "faction": "Alliance",
                "spec": "Unknown",
                "guild": None,
                "achievement_points": 0,
                "gear": {},
                "stats": {},
                "talents": {},
                "last_login": None
            }
            
            # TODO: Implement actual Battle.net API integration
            self.logger.info(f"Armory data requested for {character_name}-{server}")
            
        except Exception as e:
            self.logger.error(f"Error fetching Armory data: {e}")
        
        return armory_data
    
    def extract_wow_assets(self) -> bool:
        """Extract WoW game assets for UI preview"""
        if not self.wow_path:
            return False
        
        try:
            # Common asset locations
            asset_paths = [
                self.wow_path / "_retail_" / "Data" / "data.000",
                self.wow_path / "_retail_" / "Data" / "data.001",
                self.wow_path / "_retail_" / "Interface",
            ]
            
            # Cache directory for extracted assets
            cache_dir = Path(__file__).parent.parent / "cache" / "wow_assets"
            cache_dir.mkdir(parents=True, exist_ok=True)
            
            # Extract common UI textures
            ui_textures = [
                "Interface/FrameGeneral/UI-Background-Marble",
                "Interface/DialogFrame/UI-DialogBox-Background",
                "Interface/Tooltips/UI-Tooltip-Background",
                "Interface/ChatFrame/ChatFrameBackground",
                "Interface/AddOns/Blizzard_ActionBarButtonEventsFrame/ActionButton-Border",
            ]
            
            extracted_count = 0
            
            for texture_path in ui_textures:
                cache_file = cache_dir / f"{texture_path.replace('/', '_')}.png"
                if not cache_file.exists():
                    # Try to extract texture from WoW data files
                    if self._extract_texture(texture_path, cache_file):
                        extracted_count += 1
            
            self.logger.info(f"Extracted {extracted_count} WoW assets")
            return extracted_count > 0
            
        except Exception as e:
            self.logger.error(f"Error extracting WoW assets: {e}")
            return False
    
    def _extract_texture(self, texture_path: str, output_file: Path) -> bool:
        """Extract a specific texture from WoW data files"""
        # This is a simplified placeholder
        # Real implementation would need to parse WoW's MPQ/CASC archives
        
        try:
            # Look for texture in Interface folder first
            interface_path = self.wow_path / "_retail_" / texture_path
            
            if interface_path.with_suffix('.blp').exists():
                # BLP files need special handling
                return self._convert_blp_to_png(interface_path.with_suffix('.blp'), output_file)
            elif interface_path.with_suffix('.tga').exists():
                # TGA files can be converted directly
                return self._convert_tga_to_png(interface_path.with_suffix('.tga'), output_file)
            
            # If not found in Interface, would need to extract from data archives
            # This requires specialized libraries for MPQ/CASC format
            
        except Exception as e:
            self.logger.debug(f"Could not extract texture {texture_path}: {e}")
        
        return False
    
    def _convert_blp_to_png(self, blp_file: Path, png_file: Path) -> bool:
        """Convert BLP texture to PNG format"""
        # BLP conversion requires specialized library
        # For now, create a placeholder
        try:
            if PIL_AVAILABLE:
                # Create a placeholder image
                img = Image.new('RGBA', (64, 64), (128, 128, 128, 255))
                img.save(png_file)
                return True
        except Exception as e:
            self.logger.debug(f"BLP conversion failed: {e}")
        
        return False
    
    def _convert_tga_to_png(self, tga_file: Path, png_file: Path) -> bool:
        """Convert TGA texture to PNG format"""
        try:
            if PIL_AVAILABLE:
                with Image.open(tga_file) as img:
                    img.save(png_file, 'PNG')
                return True
        except Exception as e:
            self.logger.debug(f"TGA conversion failed: {e}")
        
        return False
    
    def _load_character_data(self):
        """Load all character data from WoW installation"""
        self.character_data = {}
        
        characters = self.get_characters()
        for char in characters:
            key = f"{char['name']}-{char['server']}"
            self.character_data[key] = char
        
        self.logger.info(f"Loaded data for {len(characters)} characters")
    
    def _load_addon_configurations(self):
        """Load addon configurations and detect installed addons"""
        self.addon_configurations = {}
        
        if not self.addon_path or not self.addon_path.exists():
            return
        
        # Scan for installed addons
        for addon_folder in self.addon_path.iterdir():
            if addon_folder.is_dir() and not addon_folder.name.startswith('.'):
                toc_file = addon_folder / f"{addon_folder.name}.toc"
                if toc_file.exists():
                    addon_info = self._parse_addon_toc(toc_file)
                    self.addon_configurations[addon_folder.name] = addon_info
        
        self.logger.info(f"Found {len(self.addon_configurations)} installed addons")
    
    def _parse_addon_toc(self, toc_file: Path) -> Dict[str, Any]:
        """Parse addon TOC file for metadata"""
        addon_info = {
            "name": toc_file.stem,
            "title": "",
            "version": "",
            "author": "",
            "description": "",
            "dependencies": [],
            "files": []
        }
        
        try:
            with open(toc_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    line = line.strip()
                    
                    if line.startswith('## Title:'):
                        addon_info["title"] = line[9:].strip()
                    elif line.startswith('## Version:'):
                        addon_info["version"] = line[11:].strip()
                    elif line.startswith('## Author:'):
                        addon_info["author"] = line[10:].strip()
                    elif line.startswith('## Notes:'):
                        addon_info["description"] = line[9:].strip()
                    elif line.startswith('## Dependencies:'):
                        deps = line[16:].strip().split(',')
                        addon_info["dependencies"] = [dep.strip() for dep in deps if dep.strip()]
                    elif line and not line.startswith('#'):
                        # Lua file
                        addon_info["files"].append(line)
        
        except Exception as e:
            self.logger.error(f"Error parsing TOC file {toc_file}: {e}")
        
        return addon_info
    
    def _cache_common_assets(self):
        """Cache commonly used WoW assets"""
        self.asset_cache = {}
        
        # Extract and cache essential UI assets
        if self.extract_wow_assets():
            cache_dir = Path(__file__).parent.parent / "cache" / "wow_assets"
            
            for asset_file in cache_dir.glob("*.png"):
                asset_name = asset_file.stem
                self.asset_cache[asset_name] = str(asset_file)
        
        self.logger.info(f"Cached {len(self.asset_cache)} WoW assets")
    
    def get_ui_preview_assets(self) -> Dict[str, str]:
        """Get paths to UI preview assets"""
        return self.asset_cache.copy()
    
    def export_character_ui_to_drgui(self, character_profile: Dict[str, Any], output_path: Path) -> bool:
        """Export character UI configuration to DRGUI format"""
        try:
            # Convert to DRGUI profile format
            drgui_profile = {
                "profile_info": {
                    "name": f"{character_profile['character']}_imported",
                    "version": "2.0.0",
                    "created": datetime.now().isoformat(),
                    "source": "WoW_Integration",
                    "character": character_profile['character'],
                    "server": character_profile['server']
                },
                "ui_elements": character_profile.get("ui_elements", {}),
                "settings": character_profile.get("addon_settings", {}),
                "keybindings": character_profile.get("keybindings", {}),
                "macros": character_profile.get("macros", [])
            }
            
            # Save as JSON for DRGUI
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(drgui_profile, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"Exported UI profile to {output_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error exporting UI profile: {e}")
            return False
    
    def get_installation_info(self) -> Dict[str, Any]:
        """Get comprehensive WoW installation information"""
        info = {
            "wow_path": str(self.wow_path) if self.wow_path else None,
            "addon_path": str(self.addon_path) if self.addon_path else None,
            "installation_found": self.wow_path is not None,
            "characters_found": len(self.character_data),
            "addons_installed": len(self.addon_configurations),
            "assets_cached": len(self.asset_cache),
            "supported_addons": [
                "DRGUI", "ElvUI", "Bartender4", "Details", "WeakAuras",
                "DBM", "BigWigs", "Plater", "TellMeWhen", "OmniCC"
            ]
        }
        
        return info