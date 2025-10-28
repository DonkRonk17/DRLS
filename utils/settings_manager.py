#!/usr/bin/env python3
"""
Settings Manager
Manages application settings and configuration.
"""

import json
import logging
from pathlib import Path
from typing import Any, Dict

class SettingsManager:
    """
    Settings Manager for DRGUI AI Designer
    
    Features:
    - Persistent settings storage
    - Default configuration
    - Setting validation
    """
    
    def __init__(self, config_file: str = "config.json"):
        """Initialize Settings Manager"""
        self.logger = logging.getLogger(__name__)
        self.config_file = Path(config_file)
        self.settings = {}
        
        # Default settings
        self.defaults = {
            "ui": {
                "show_grid": True,
                "show_rulers": True,
                "show_labels": True,
                "theme": "dark"
            },
            "ai": {
                "enabled": True,
                "auto_suggestions": True,
                "model": "gpt-3.5-turbo"
            },
            "wow": {
                "auto_detect": True,
                "installation_path": "",
                "character_auto_load": True
            },
            "export": {
                "default_format": "drgui",
                "include_metadata": True
            }
        }
        
        self._load_settings()
        self.logger.info("Settings Manager initialized")
    
    def _load_settings(self):
        """Load settings from file"""
        try:
            if self.config_file.exists():
                with open(self.config_file, 'r') as f:
                    saved_settings = json.load(f)
                
                # Merge with defaults
                self.settings = self._merge_settings(self.defaults, saved_settings)
            else:
                self.settings = self.defaults.copy()
                self._save_settings()
                
        except Exception as e:
            self.logger.error(f"Error loading settings: {e}")
            self.settings = self.defaults.copy()
    
    def _merge_settings(self, defaults: Dict, saved: Dict) -> Dict:
        """Merge saved settings with defaults"""
        result = defaults.copy()
        
        for key, value in saved.items():
            if key in result:
                if isinstance(value, dict) and isinstance(result[key], dict):
                    result[key] = self._merge_settings(result[key], value)
                else:
                    result[key] = value
            else:
                result[key] = value
        
        return result
    
    def _save_settings(self):
        """Save settings to file"""
        try:
            with open(self.config_file, 'w') as f:
                json.dump(self.settings, f, indent=2)
        except Exception as e:
            self.logger.error(f"Error saving settings: {e}")
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get setting value"""
        keys = key.split('.')
        value = self.settings
        
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return default
        
        return value
    
    def set(self, key: str, value: Any):
        """Set setting value"""
        keys = key.split('.')
        settings = self.settings
        
        # Navigate to parent
        for k in keys[:-1]:
            if k not in settings:
                settings[k] = {}
            settings = settings[k]
        
        # Set value
        settings[keys[-1]] = value
        self._save_settings()
    
    def get_all(self) -> Dict:
        """Get all settings"""
        return self.settings.copy()
    
    def reset_to_defaults(self):
        """Reset all settings to defaults"""
        self.settings = self.defaults.copy()
        self._save_settings()
        self.logger.info("Settings reset to defaults")