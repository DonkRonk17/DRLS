#!/usr/bin/env python3
"""
DRGUI AI Designer - Settings Manager
Handles application configuration, user preferences, and persistent settings.
"""

import json
import logging
from pathlib import Path
from typing import Dict, Any, Optional
import os

class SettingsManager:
    """
    Centralized settings management for DRGUI AI Designer
    
    Handles:
    - Application configuration
    - User preferences
    - AI model settings
    - WoW integration settings
    - Profile management settings
    """
    
    def __init__(self, config_dir: Optional[Path] = None):
        """Initialize settings manager"""
        self.logger = logging.getLogger(__name__)
        
        # Set config directory
        if config_dir is None:
            self.config_dir = Path(__file__).parent.parent / "config"
        else:
            self.config_dir = config_dir
            
        self.config_dir.mkdir(exist_ok=True)
        
        # Settings files
        self.main_config_file = self.config_dir / "settings.json"
        self.ai_config_file = self.config_dir / "ai_config.json"
        self.wow_data_file = self.config_dir / "wow_data.json"
        self.user_prefs_file = self.config_dir / "user_preferences.json"
        
        # Default settings
        self.default_settings = self._get_default_settings()
        self.default_ai_config = self._get_default_ai_config()
        self.default_wow_data = self._get_default_wow_data()
        self.default_user_prefs = self._get_default_user_preferences()
        
        # Current settings
        self.settings = {}
        self.ai_config = {}
        self.wow_data = {}
        self.user_preferences = {}
        
        # Load all settings
        self.load_all()
    
    def _get_default_settings(self) -> Dict[str, Any]:
        """Get default application settings"""
        return {
            "app": {
                "version": "2.0.0-AI-Designer",
                "name": "DRGUI AI-Powered UI Designer",
                "window_size": [1400, 900],
                "window_position": [100, 100],
                "theme": "dark",
                "auto_save": True,
                "auto_save_interval": 300,  # seconds
                "backup_count": 10
            },
            "simulation": {
                "resolution": [1920, 1080],
                "fps_target": 60,
                "performance_mode": "balanced",  # low, balanced, high
                "enable_animations": True,
                "simulation_speed": 1.0,
                "background_scenarios": ["stormwind", "orgrimmar", "raid"]
            },
            "ui": {
                "grid_snap": True,
                "grid_size": 5,
                "show_guidelines": True,
                "element_transparency": 0.9,
                "preview_mode": "live",
                "panel_layout": "default"
            },
            "export": {
                "auto_export": False,
                "export_format": "drgui_profile",
                "backup_before_export": True,
                "wow_addon_path": "",
                "profile_compression": True
            },
            "logging": {
                "level": "INFO",
                "max_log_size": 10485760,  # 10MB
                "log_retention_days": 30
            }
        }
    
    def _get_default_ai_config(self) -> Dict[str, Any]:
        """Get default AI configuration"""
        return {
            "openai": {
                "api_key": "",
                "model": "gpt-4",
                "max_tokens": 2000,
                "temperature": 0.7,
                "timeout": 30
            },
            "local_ai": {
                "enabled": True,
                "model_path": "models/local_ai",
                "device": "auto",  # auto, cpu, cuda
                "cache_responses": True
            },
            "suggestions": {
                "auto_suggest": True,
                "suggestion_frequency": "moderate",  # low, moderate, high
                "context_awareness": True,
                "learning_enabled": True,
                "style_adaptation": True
            },
            "chat": {
                "max_history": 100,
                "response_streaming": True,
                "auto_apply_changes": False,
                "confirmation_required": True
            },
            "analysis": {
                "real_time_analysis": True,
                "performance_warnings": True,
                "layout_optimization": True,
                "accessibility_checks": True
            }
        }
    
    def _get_default_wow_data(self) -> Dict[str, Any]:
        """Get default WoW game data"""
        return {
            "classes": {
                "warrior": {"color": "#C79C6E", "roles": ["tank", "dps"]},
                "paladin": {"color": "#F58CBA", "roles": ["tank", "healer", "dps"]},
                "hunter": {"color": "#ABD473", "roles": ["dps"]},
                "rogue": {"color": "#FFF569", "roles": ["dps"]},
                "priest": {"color": "#FFFFFF", "roles": ["healer", "dps"]},
                "shaman": {"color": "#0070DE", "roles": ["healer", "dps"]},
                "mage": {"color": "#40C7EB", "roles": ["dps"]},
                "warlock": {"color": "#8787ED", "roles": ["dps"]},
                "monk": {"color": "#00FF96", "roles": ["tank", "healer", "dps"]},
                "druid": {"color": "#FF7D0A", "roles": ["tank", "healer", "dps"]},
                "demon_hunter": {"color": "#A330C9", "roles": ["tank", "dps"]},
                "death_knight": {"color": "#C41F3B", "roles": ["tank", "dps"]},
                "evoker": {"color": "#33937F", "roles": ["healer", "dps"]}
            },
            "ui_elements": {
                "player_frame": {"min_size": [100, 50], "max_size": [400, 200]},
                "target_frame": {"min_size": [100, 50], "max_size": [400, 200]},
                "party_frames": {"min_size": [80, 40], "max_size": [200, 100]},
                "raid_frames": {"min_size": [40, 30], "max_size": [120, 80]},
                "action_bars": {"min_size": [300, 40], "max_size": [800, 80]},
                "minimap": {"min_size": [100, 100], "max_size": [300, 300]},
                "chat_frame": {"min_size": [200, 100], "max_size": [600, 400]}
            },
            "scenarios": {
                "solo": {"party_size": 1, "focus": "exploration"},
                "dungeon": {"party_size": 5, "focus": "group_coordination"},
                "raid": {"party_size": 20, "focus": "raid_management"},
                "pvp": {"party_size": 3, "focus": "enemy_tracking"}
            }
        }
    
    def _get_default_user_preferences(self) -> Dict[str, Any]:
        """Get default user preferences"""
        return {
            "character": {
                "name": "",
                "class": "warrior",
                "spec": "protection",
                "level": 80,
                "role": "tank"
            },
            "content_preferences": {
                "primary_content": "raid",  # raid, mythic_plus, pvp, solo
                "difficulty": "heroic",
                "group_size": 20
            },
            "ui_preferences": {
                "style": "minimalist",  # minimalist, detailed, professional
                "layout_density": "medium",  # low, medium, high
                "color_scheme": "class_themed",
                "transparency": 0.8,
                "scale": 1.0
            },
            "ai_preferences": {
                "assistance_level": "moderate",  # minimal, moderate, extensive
                "auto_apply": False,
                "explanation_detail": "medium",  # low, medium, high
                "suggestion_style": "conversational"
            },
            "workflow": {
                "recent_profiles": [],
                "favorite_templates": [],
                "last_scenario": "solo",
                "auto_load_last": True
            }
        }
    
    def load_all(self):
        """Load all configuration files"""
        try:
            self.settings = self._load_config_file(
                self.main_config_file, 
                self.default_settings
            )
            
            self.ai_config = self._load_config_file(
                self.ai_config_file,
                self.default_ai_config
            )
            
            self.wow_data = self._load_config_file(
                self.wow_data_file,
                self.default_wow_data
            )
            
            self.user_preferences = self._load_config_file(
                self.user_prefs_file,
                self.default_user_prefs
            )
            
            self.logger.info("All settings loaded successfully")
            
        except Exception as e:
            self.logger.error(f"Error loading settings: {e}")
            self._reset_to_defaults()
    
    def _load_config_file(self, file_path: Path, defaults: Dict[str, Any]) -> Dict[str, Any]:
        """Load a specific configuration file"""
        if file_path.exists():
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                
                # Merge with defaults to ensure all keys exist
                merged_config = self._deep_merge(defaults.copy(), config)
                return merged_config
                
            except (json.JSONDecodeError, OSError) as e:
                self.logger.warning(f"Error loading {file_path}: {e}. Using defaults.")
                return defaults.copy()
        else:
            # Create file with defaults
            self._save_config_file(file_path, defaults)
            return defaults.copy()
    
    def _save_config_file(self, file_path: Path, config: Dict[str, Any]):
        """Save a configuration file"""
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2, ensure_ascii=False)
        except OSError as e:
            self.logger.error(f"Error saving {file_path}: {e}")
    
    def _deep_merge(self, base: Dict[str, Any], update: Dict[str, Any]) -> Dict[str, Any]:
        """Deep merge two dictionaries"""
        for key, value in update.items():
            if key in base and isinstance(base[key], dict) and isinstance(value, dict):
                base[key] = self._deep_merge(base[key], value)
            else:
                base[key] = value
        return base
    
    def _reset_to_defaults(self):
        """Reset all settings to defaults"""
        self.logger.warning("Resetting all settings to defaults")
        self.settings = self.default_settings.copy()
        self.ai_config = self.default_ai_config.copy()
        self.wow_data = self.default_wow_data.copy()
        self.user_preferences = self.default_user_prefs.copy()
        self.save_all()
    
    def save_all(self):
        """Save all configuration files"""
        try:
            self._save_config_file(self.main_config_file, self.settings)
            self._save_config_file(self.ai_config_file, self.ai_config)
            self._save_config_file(self.wow_data_file, self.wow_data)
            self._save_config_file(self.user_prefs_file, self.user_preferences)
            
            self.logger.info("All settings saved successfully")
            
        except Exception as e:
            self.logger.error(f"Error saving settings: {e}")
    
    def save(self):
        """Alias for save_all()"""
        self.save_all()
    
    def get(self, key_path: str, default: Any = None) -> Any:
        """
        Get a setting value using dot notation
        
        Example: get("app.window_size") returns settings["app"]["window_size"]
        """
        try:
            keys = key_path.split(".")
            section = keys[0]
            
            if section == "ai":
                config = self.ai_config
            elif section == "wow":
                config = self.wow_data
            elif section == "user":
                config = self.user_preferences
            else:
                config = self.settings
            
            value = config
            for key in keys:
                value = value[key]
            
            return value
            
        except (KeyError, TypeError):
            return default
    
    def get_setting(self, key_path: str, default: Any = None) -> Any:
        """Alias for get() method for backward compatibility"""
        return self.get(key_path, default)
    
    def get_character_settings(self, character_name: str) -> Dict[str, Any]:
        """Get settings for a specific character"""
        character_settings = self.get(f"user.characters.{character_name}", {})
        
        # Ensure we have default character structure
        if not character_settings:
            character_settings = {
                "name": character_name,
                "class": "Unknown",
                "spec": "Unknown",
                "role": "DPS",
                "ui_preferences": {},
                "profiles": []
            }
            self.set(f"user.characters.{character_name}", character_settings)
        
        return character_settings
    
    def set(self, key_path: str, value: Any) -> bool:
        """
        Set a setting value using dot notation
        
        Example: set("app.window_size", [1600, 1000])
        """
        try:
            keys = key_path.split(".")
            section = keys[0]
            
            if section == "ai":
                config = self.ai_config
            elif section == "wow":
                config = self.wow_data
            elif section == "user":
                config = self.user_preferences
            else:
                config = self.settings
            
            # Navigate to the parent of the final key
            current = config
            for key in keys[:-1]:
                if key not in current:
                    current[key] = {}
                current = current[key]
            
            # Set the final value
            current[keys[-1]] = value
            
            self.logger.debug(f"Set {key_path} = {value}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error setting {key_path}: {e}")
            return False
    
    def get_wow_installation_path(self) -> Optional[str]:
        """Detect WoW installation path"""
        possible_paths = [
            r"C:\Program Files (x86)\World of Warcraft",
            r"C:\Program Files\World of Warcraft",
            r"D:\World of Warcraft",
            r"C:\Games\World of Warcraft"
        ]
        
        # Check user-configured path first
        user_path = self.get("export.wow_addon_path")
        if user_path and Path(user_path).exists():
            return user_path
        
        # Check common installation paths
        for path in possible_paths:
            if Path(path).exists():
                retail_path = Path(path) / "_retail_" / "Interface" / "AddOns"
                if retail_path.exists():
                    return str(retail_path)
        
        return None
    
    def export_settings(self, file_path: Path) -> bool:
        """Export all settings to a file"""
        try:
            export_data = {
                "version": self.get("app.version"),
                "export_date": str(Path().cwd()),
                "settings": self.settings,
                "ai_config": self.ai_config,
                "user_preferences": self.user_preferences
            }
            
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(export_data, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"Settings exported to {file_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error exporting settings: {e}")
            return False
    
    def import_settings(self, file_path: Path) -> bool:
        """Import settings from a file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                import_data = json.load(f)
            
            # Validate import data
            if "settings" not in import_data:
                raise ValueError("Invalid settings file format")
            
            # Import settings with validation
            self.settings = self._deep_merge(
                self.default_settings.copy(),
                import_data.get("settings", {})
            )
            
            if "ai_config" in import_data:
                self.ai_config = self._deep_merge(
                    self.default_ai_config.copy(),
                    import_data["ai_config"]
                )
            
            if "user_preferences" in import_data:
                self.user_preferences = self._deep_merge(
                    self.default_user_prefs.copy(),
                    import_data["user_preferences"]
                )
            
            # Save imported settings
            self.save_all()
            
            self.logger.info(f"Settings imported from {file_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error importing settings: {e}")
            return False