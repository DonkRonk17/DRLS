#!/usr/bin/env python3
"""
Export Manager
Handles exporting UI configurations to various formats.
"""

import json
import logging
from pathlib import Path
from typing import Dict, Any

class ExportManager:
    """
    Export Manager for DRGUI AI Designer
    
    Features:
    - DRGUI Lua export
    - ElvUI profile export
    - WeakAuras export
    - Multiple format support
    """
    
    def __init__(self, settings):
        """Initialize Export Manager"""
        self.logger = logging.getLogger(__name__)
        self.settings = settings
        
        self.logger.info("Export Manager initialized")
    
    def export_drgui(self, ui_elements: Dict[str, Any], output_path: str):
        """Export to DRGUI Lua format"""
        try:
            lua_content = self._generate_drgui_lua(ui_elements)
            
            with open(output_path, 'w') as f:
                f.write(lua_content)
            
            self.logger.info(f"DRGUI export completed: {output_path}")
            
        except Exception as e:
            self.logger.error(f"DRGUI export error: {e}")
            raise
    
    def export_elvui(self, ui_elements: Dict[str, Any], output_path: str):
        """Export to ElvUI profile format"""
        try:
            elvui_content = self._generate_elvui_profile(ui_elements)
            
            with open(output_path, 'w') as f:
                f.write(elvui_content)
            
            self.logger.info(f"ElvUI export completed: {output_path}")
            
        except Exception as e:
            self.logger.error(f"ElvUI export error: {e}")
            raise
    
    def export_weakauras(self, ui_elements: Dict[str, Any], output_path: str):
        """Export to WeakAuras format"""
        try:
            wa_content = self._generate_weakauras_export(ui_elements)
            
            with open(output_path, 'w') as f:
                f.write(wa_content)
            
            self.logger.info(f"WeakAuras export completed: {output_path}")
            
        except Exception as e:
            self.logger.error(f"WeakAuras export error: {e}")
            raise
    
    def _generate_drgui_lua(self, ui_elements: Dict[str, Any]) -> str:
        """Generate DRGUI Lua configuration"""
        lua_lines = [
            "-- DRGUI AI Designer Export",
            "-- Generated automatically",
            "",
            "local DRGUI = DRGUI or {}",
            "DRGUI.profiles = DRGUI.profiles or {}",
            "",
            "DRGUI.profiles.AIGenerated = {"
        ]
        
        for element_name, element in ui_elements.items():
            lua_lines.extend(self._element_to_lua(element_name, element))
        
        lua_lines.extend([
            "}",
            "",
            "-- Apply profile",
            "DRGUI:LoadProfile('AIGenerated')"
        ])
        
        return "\n".join(lua_lines)
    
    def _element_to_lua(self, name: str, element: Dict[str, Any]) -> list:
        """Convert UI element to Lua format"""
        lines = [f"    ['{name}'] = {{"]
        
        # Element properties
        lines.append(f"        type = '{element.get('type', 'frame')}',")
        
        # Position
        pos = element.get('position', {})
        lines.append(f"        position = {{")
        lines.append(f"            anchor = '{pos.get('anchor', 'CENTER')}',")
        lines.append(f"            x = {pos.get('x', 0)},")
        lines.append(f"            y = {pos.get('y', 0)}")
        lines.append(f"        }},")
        
        # Size
        size = element.get('size', {})
        lines.append(f"        size = {{")
        lines.append(f"            width = {size.get('width', 100)},")
        lines.append(f"            height = {size.get('height', 30)}")
        lines.append(f"        }},")
        
        # Additional properties
        for key, value in element.items():
            if key not in ['type', 'position', 'size', 'name']:
                if isinstance(value, str):
                    lines.append(f"        {key} = '{value}',")
                elif isinstance(value, bool):
                    lines.append(f"        {key} = {str(value).lower()},")
                else:
                    lines.append(f"        {key} = {value},")
        
        lines.append("    },")
        
        return lines
    
    def _generate_elvui_profile(self, ui_elements: Dict[str, Any]) -> str:
        """Generate ElvUI profile string"""
        # This would generate a proper ElvUI profile string
        # For now, return a placeholder
        profile_data = {
            "general": {
                "UIScale": 0.64
            },
            "unitframe": {},
            "actionbars": {},
            "auras": {}
        }
        
        # Convert UI elements to ElvUI format
        for element_name, element in ui_elements.items():
            element_type = element.get('type', '')
            
            if element_type == 'unitframe':
                profile_data['unitframe'][element_name] = self._convert_to_elvui_unitframe(element)
            elif element_type == 'actionbar':
                profile_data['actionbars'][element_name] = self._convert_to_elvui_actionbar(element)
        
        return json.dumps(profile_data, indent=2)
    
    def _convert_to_elvui_unitframe(self, element: Dict[str, Any]) -> Dict[str, Any]:
        """Convert element to ElvUI unitframe format"""
        pos = element.get('position', {})
        size = element.get('size', {})
        
        return {
            "enable": True,
            "width": size.get('width', 200),
            "height": size.get('height', 80),
            "position": {
                "point": pos.get('anchor', 'CENTER'),
                "x": pos.get('x', 0),
                "y": pos.get('y', 0)
            },
            "health": {
                "text": element.get('showHealthText', True)
            },
            "name": {
                "enable": element.get('showName', True)
            }
        }
    
    def _convert_to_elvui_actionbar(self, element: Dict[str, Any]) -> Dict[str, Any]:
        """Convert element to ElvUI actionbar format"""
        pos = element.get('position', {})
        
        return {
            "enable": True,
            "buttons": element.get('buttons', 12),
            "buttonsPerRow": element.get('buttonsPerRow', 12),
            "position": {
                "point": pos.get('anchor', 'BOTTOM'),
                "x": pos.get('x', 0),
                "y": pos.get('y', 50)
            }
        }
    
    def _generate_weakauras_export(self, ui_elements: Dict[str, Any]) -> str:
        """Generate WeakAuras export string"""
        # Placeholder for WeakAuras export
        return json.dumps({
            "format": "weakauras",
            "elements": len(ui_elements),
            "note": "WeakAuras export not fully implemented yet"
        }, indent=2)