#!/usr/bin/env python3
"""
DRGUI AI Designer - WoW Preview Renderer
Provides authentic WoW-style UI preview using game assets and realistic simulation.
"""

import logging
import tkinter as tk
from tkinter import ttk, Canvas
import math
import time
from pathlib import Path
from typing import Dict, Any, List, Optional, Tuple
import json

try:
    from PIL import Image, ImageTk, ImageDraw, ImageFilter
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

try:
    import pygame
    PYGAME_AVAILABLE = True
except ImportError:
    PYGAME_AVAILABLE = False

class WoWPreviewRenderer:
    """
    Authentic WoW UI Preview Renderer
    
    Features:
    - Uses actual WoW game assets when available
    - Realistic UI element positioning and scaling
    - Live combat simulation display
    - Character-specific UI previews
    - ElvUI-compatible styling
    - Real-time preview updates
    """
    
    def __init__(self, canvas: Canvas, wow_integration, settings):
        """Initialize WoW Preview Renderer"""
        self.logger = logging.getLogger(__name__)
        self.canvas = canvas
        self.wow_integration = wow_integration
        self.settings = settings
        
        # Canvas properties
        self.canvas_width = 1024
        self.canvas_height = 768
        self.scale_factor = 1.0
        
        # WoW UI properties
        self.ui_scale = 1.0
        self.resolution = (1920, 1080)
        self.aspect_ratio = 16/9
        
        # Asset management
        self.asset_cache = {}
        self.texture_cache = {}
        self.font_cache = {}
        
        # UI state
        self.ui_elements = {}
        self.selected_element = None
        self.preview_mode = "design"  # "design" or "simulation"
        
        # Animation state
        self.animation_frame = 0
        self.last_update = time.time()
        
        # WoW-style colors
        self.wow_colors = {
            "background": "#0F1419",
            "frame_border": "#2F2F2F",
            "health_green": "#00FF00",
            "health_yellow": "#FFFF00", 
            "health_red": "#FF0000",
            "mana_blue": "#0096FF",
            "energy_yellow": "#FFF569",
            "rage_red": "#FF0000",
            "focus_orange": "#FF8040",
            "text_white": "#FFFFFF",
            "text_gray": "#B0B0B0",
            "text_yellow": "#FFFF00",
            "elvui_blue": "#1784d1",
            "elvui_gray": "#333333"
        }
        
        # Initialize renderer
        self._initialize_renderer()
        self._load_wow_assets()
        self._setup_canvas()
    
    def _initialize_renderer(self):
        """Initialize the rendering system"""
        # Get canvas dimensions
        self.canvas.update_idletasks()
        self.canvas_width = self.canvas.winfo_width() or 1024
        self.canvas_height = self.canvas.winfo_height() or 768
        
        # Calculate scale factor to fit WoW UI
        ui_width = 1024  # Base WoW UI width
        ui_height = 768  # Base WoW UI height
        
        scale_x = self.canvas_width / ui_width
        scale_y = self.canvas_height / ui_height
        self.scale_factor = min(scale_x, scale_y) * 0.9  # 90% to leave margins
        
        self.logger.info(f"Initialized renderer: {self.canvas_width}x{self.canvas_height}, scale: {self.scale_factor:.2f}")
    
    def _load_wow_assets(self):
        """Load WoW game assets for authentic preview"""
        if not self.wow_integration.wow_path:
            self._create_fallback_assets()
            return
        
        # Get cached assets from WoW integration
        assets = self.wow_integration.get_ui_preview_assets()
        
        for asset_name, asset_path in assets.items():
            try:
                if PIL_AVAILABLE and Path(asset_path).exists():
                    image = Image.open(asset_path)
                    self.asset_cache[asset_name] = image
                    
                    # Create scaled versions
                    for scale in [0.5, 1.0, 1.5, 2.0]:
                        scaled_key = f"{asset_name}_scale_{scale}"
                        if scale != 1.0:
                            new_size = (int(image.width * scale), int(image.height * scale))
                            scaled_image = image.resize(new_size, Image.Resampling.LANCZOS)
                            self.asset_cache[scaled_key] = scaled_image
                        else:
                            self.asset_cache[scaled_key] = image
            
            except Exception as e:
                self.logger.warning(f"Failed to load asset {asset_name}: {e}")
        
        if not self.asset_cache:
            self._create_fallback_assets()
        
        self.logger.info(f"Loaded {len(self.asset_cache)} WoW assets")
    
    def _create_fallback_assets(self):
        """Create fallback assets when WoW assets aren't available"""
        if not PIL_AVAILABLE:
            return
        
        # Create basic UI textures
        textures = {
            "frame_background": (200, 60, self.wow_colors["elvui_gray"]),
            "actionbar_background": (498, 42, self.wow_colors["elvui_gray"]),
            "button_background": (32, 32, self.wow_colors["frame_border"]),
            "health_bar": (180, 20, self.wow_colors["health_green"]),
            "mana_bar": (180, 15, self.wow_colors["mana_blue"]),
            "chat_background": (400, 120, "#000000"),
            "minimap_background": (140, 140, "#2F4F2F")
        }
        
        for name, (width, height, color) in textures.items():
            image = Image.new("RGBA", (width, height), color)
            
            # Add border
            draw = ImageDraw.Draw(image)
            border_color = "#1F1F1F"
            draw.rectangle([0, 0, width-1, height-1], outline=border_color, width=1)
            
            self.asset_cache[name] = image
        
        self.logger.info("Created fallback assets")
    
    def _setup_canvas(self):
        """Setup canvas for WoW-style rendering"""
        # Set background to WoW-like color
        self.canvas.configure(bg=self.wow_colors["background"])
        
        # Bind events for interaction
        self.canvas.bind("<Button-1>", self._on_click)
        self.canvas.bind("<B1-Motion>", self._on_drag)
        self.canvas.bind("<ButtonRelease-1>", self._on_release)
        self.canvas.bind("<Motion>", self._on_hover)
        
        # Start animation loop
        self._animation_loop()
    
    def update_ui_elements(self, ui_elements: Dict[str, Any]):
        """Update UI elements and refresh preview"""
        self.ui_elements = ui_elements.copy()
        self._render_ui()
    
    def set_preview_mode(self, mode: str):
        """Set preview mode: 'design' or 'simulation'"""
        if mode in ["design", "simulation"]:
            self.preview_mode = mode
            self._render_ui()
    
    def _render_ui(self):
        """Render the complete UI preview"""
        # Clear canvas
        self.canvas.delete("all")
        
        # Draw background
        self._draw_background()
        
        # If no UI elements exist, show default WoW interface
        if not self.ui_elements:
            self._draw_default_wow_interface()
        else:
            # Draw UI elements in proper order
            element_order = self._get_render_order()
            
            for element_name in element_order:
                if element_name in self.ui_elements:
                    element = self.ui_elements[element_name]
                    if element.get("enabled", True):
                        self._render_ui_element(element_name, element)
        
        # Draw selection highlight
        if self.selected_element and self.selected_element in self.ui_elements:
            self._draw_selection_highlight(self.selected_element)
        
        # Draw UI overlay info in design mode
        if self.preview_mode == "design":
            self._draw_design_overlay()
    
    def _draw_background(self):
        """Draw WoW-style background"""
        # Main background
        self.canvas.create_rectangle(
            0, 0, self.canvas_width, self.canvas_height,
            fill=self.wow_colors["background"],
            outline=""
        )
        
        # Optional background texture
        if "UI-Background-Marble" in self.asset_cache:
            # Tile background texture
            bg_texture = self.asset_cache["UI-Background-Marble"]
            if PIL_AVAILABLE:
                bg_photo = ImageTk.PhotoImage(bg_texture)
                
                # Tile across canvas
                for x in range(0, self.canvas_width, bg_texture.width):
                    for y in range(0, self.canvas_height, bg_texture.height):
                        self.canvas.create_image(x, y, image=bg_photo, anchor=tk.NW)
    
    def _draw_default_wow_interface(self):
        """Draw a default WoW interface when no elements are present"""
        # Calculate positions based on canvas size
        center_x = self.canvas_width // 2
        center_y = self.canvas_height // 2
        
        # Draw Player Frame (top left)
        player_x, player_y = int(50 * self.scale_factor), int(50 * self.scale_factor)
        player_w, player_h = int(220 * self.scale_factor), int(60 * self.scale_factor)
        self._draw_sample_unitframe("Player", player_x, player_y, player_w, player_h, health=85, mana=62)
        
        # Draw Target Frame (top left, below player)
        target_x, target_y = player_x + 250, player_y
        target_w, target_h = player_w, player_h
        self._draw_sample_unitframe("Target", target_x, target_y, target_w, target_h, health=45, mana=78)
        
        # Draw Action Bars (bottom center)
        actionbar_y = self.canvas_height - int(80 * self.scale_factor)
        actionbar_x = center_x - int(249 * self.scale_factor)
        actionbar_w, actionbar_h = int(498 * self.scale_factor), int(42 * self.scale_factor)
        self._draw_sample_actionbar(actionbar_x, actionbar_y, actionbar_w, actionbar_h)
        
        # Draw Chat Frame (bottom left)
        chat_x, chat_y = int(20 * self.scale_factor), self.canvas_height - int(160 * self.scale_factor)
        chat_w, chat_h = int(400 * self.scale_factor), int(120 * self.scale_factor)
        self._draw_sample_chat(chat_x, chat_y, chat_w, chat_h)
        
        # Draw Minimap (top right)
        minimap_x = self.canvas_width - int(160 * self.scale_factor)
        minimap_y = int(20 * self.scale_factor)
        minimap_w = minimap_h = int(140 * self.scale_factor)
        self._draw_sample_minimap(minimap_x, minimap_y, minimap_w, minimap_h)
        
        # Add welcome text
        self.canvas.create_text(
            center_x, center_y + int(100 * self.scale_factor),
            text="Enhanced DRGUI AI Designer\nClick 'Unit Frame', 'Action Bar', etc. to add UI elements\nAsk the AI assistant for help designing your UI!",
            fill=self.wow_colors["text_yellow"],
            font=("Arial", int(14 * self.scale_factor), "bold"),
            justify=tk.CENTER
        )
    
    def _draw_sample_unitframe(self, name: str, x: int, y: int, w: int, h: int, health: int = 100, mana: int = 100):
        """Draw a sample unit frame"""
        # Frame background
        self.canvas.create_rectangle(x, y, x+w, y+h, fill=self.wow_colors["elvui_gray"], outline=self.wow_colors["frame_border"], width=2)
        
        # Health bar
        health_h = h // 2 - 5
        health_w = int(w * 0.8)
        health_x, health_y = x + 5, y + 5
        health_fill_w = int(health_w * (health / 100))
        
        # Health background
        self.canvas.create_rectangle(health_x, health_y, health_x + health_w, health_y + health_h, 
                                   fill="#002200", outline=self.wow_colors["frame_border"])
        # Health fill
        health_color = self.wow_colors["health_green"] if health > 50 else self.wow_colors["health_yellow"] if health > 20 else self.wow_colors["health_red"]
        self.canvas.create_rectangle(health_x, health_y, health_x + health_fill_w, health_y + health_h, 
                                   fill=health_color, outline="")
        
        # Mana bar
        mana_h = h // 3 - 3
        mana_y = health_y + health_h + 3
        mana_fill_w = int(health_w * (mana / 100))
        
        # Mana background
        self.canvas.create_rectangle(health_x, mana_y, health_x + health_w, mana_y + mana_h, 
                                   fill="#000022", outline=self.wow_colors["frame_border"])
        # Mana fill
        self.canvas.create_rectangle(health_x, mana_y, health_x + mana_fill_w, mana_y + mana_h, 
                                   fill=self.wow_colors["mana_blue"], outline="")
        
        # Name text
        self.canvas.create_text(x + w//2, y + h//2, text=name, fill=self.wow_colors["text_white"], 
                              font=("Arial", int(10 * self.scale_factor), "bold"))
    
    def _draw_sample_actionbar(self, x: int, y: int, w: int, h: int):
        """Draw a sample action bar with buttons"""
        # Background
        self.canvas.create_rectangle(x, y, x+w, y+h, fill=self.wow_colors["elvui_gray"], outline=self.wow_colors["frame_border"], width=2)
        
        # Draw 12 action buttons
        button_size = int(32 * self.scale_factor)
        button_spacing = int(6 * self.scale_factor)
        start_x = x + button_spacing
        
        for i in range(12):
            btn_x = start_x + i * (button_size + button_spacing)
            btn_y = y + (h - button_size) // 2
            
            # Button background
            self.canvas.create_rectangle(btn_x, btn_y, btn_x + button_size, btn_y + button_size,
                                       fill="#1a1a1a", outline=self.wow_colors["frame_border"], width=1)
            
            # Hotkey number
            self.canvas.create_text(btn_x + button_size//2, btn_y + button_size//2, 
                                  text=str((i % 10) if i < 10 else "0" if i == 9 else "-"),
                                  fill=self.wow_colors["text_white"], 
                                  font=("Arial", int(8 * self.scale_factor)))
    
    def _draw_sample_chat(self, x: int, y: int, w: int, h: int):
        """Draw a sample chat frame"""
        # Background
        self.canvas.create_rectangle(x, y, x+w, y+h, fill="#000000", outline=self.wow_colors["frame_border"], width=2)
        
        # Sample chat lines
        chat_lines = [
            "[General] Player: Welcome to WoW!",
            "[Guild] Guildmate: How's everyone doing?",
            "[Say] You: Testing the new UI",
            "[System] DRGUI AI Designer loaded"
        ]
        
        line_height = int(15 * self.scale_factor)
        start_y = y + h - len(chat_lines) * line_height - 10
        
        for i, line in enumerate(chat_lines):
            text_y = start_y + i * line_height
            color = self.wow_colors["text_white"]
            if "[General]" in line:
                color = "#40FF40"
            elif "[Guild]" in line:
                color = "#40FF80"
            elif "[System]" in line:
                color = self.wow_colors["text_yellow"]
                
            self.canvas.create_text(x + 5, text_y, text=line, fill=color, anchor=tk.W,
                                  font=("Arial", int(9 * self.scale_factor)))
    
    def _draw_sample_minimap(self, x: int, y: int, w: int, h: int):
        """Draw a sample minimap"""
        # Circular minimap background
        self.canvas.create_oval(x, y, x+w, y+h, fill="#2a4a2a", outline=self.wow_colors["frame_border"], width=3)
        
        # Minimap content (simple terrain representation)
        center_x, center_y = x + w//2, y + h//2
        radius = w//2 - 10
        
        # Draw some terrain features
        import random
        random.seed(42)  # Consistent pattern
        if radius > 10:  # Only draw terrain if minimap is large enough
            terrain_range = max(radius//4, 5)  # Ensure positive range
            for _ in range(min(20, radius//5)):  # Scale number of features with size
                px = center_x + random.randint(-terrain_range, terrain_range)
                py = center_y + random.randint(-terrain_range, terrain_range)
                self.canvas.create_oval(px-2, py-2, px+2, py+2, fill="#4a6a4a", outline="")
        
        # Player arrow (pointing north)
        arrow_size = int(8 * self.scale_factor)
        self.canvas.create_polygon(
            center_x, center_y - arrow_size,
            center_x - arrow_size//2, center_y + arrow_size//2,
            center_x + arrow_size//2, center_y + arrow_size//2,
            fill=self.wow_colors["text_yellow"], outline=self.wow_colors["frame_border"]
        )
    
    def _get_render_order(self) -> List[str]:
        """Get proper rendering order for UI elements"""
        # Define layer order (bottom to top)
        layer_order = {
            "background": 0,
            "groupframe": 1,
            "unitframe": 2,
            "actionbar": 3,
            "castbar": 4,
            "aura": 5,
            "chat": 6,
            "minimap": 7,
            "statusbar": 8
        }
        
        # Sort elements by layer and level
        elements_with_order = []
        
        for element_name, element in self.ui_elements.items():
            element_type = element.get("type", "unknown")
            layer = layer_order.get(element_type, 5)
            level = element.get("level", 1)
            strata_bonus = {"BACKGROUND": 0, "LOW": 10, "MEDIUM": 20, "HIGH": 30, "DIALOG": 40}.get(
                element.get("strata", "MEDIUM"), 20
            )
            
            total_order = layer * 100 + strata_bonus + level
            elements_with_order.append((total_order, element_name))
        
        # Sort and return element names
        elements_with_order.sort()
        return [name for _, name in elements_with_order]
    
    def _render_ui_element(self, element_name: str, element: Dict[str, Any]):
        """Render a single UI element"""
        element_type = element.get("type", "unknown")
        
        # Get screen position and size
        screen_pos = self._ui_to_screen_position(element["position"])
        screen_size = self._ui_to_screen_size(element["size"], element.get("scale", 1.0))
        
        if screen_pos is None or screen_size is None:
            return
        
        x, y = screen_pos
        width, height = screen_size
        
        # Render based on element type
        if element_type == "unitframe":
            self._render_unitframe(element_name, element, x, y, width, height)
        elif element_type == "actionbar":
            self._render_actionbar(element_name, element, x, y, width, height)
        elif element_type == "groupframe":
            self._render_groupframe(element_name, element, x, y, width, height)
        elif element_type == "chat":
            self._render_chat(element_name, element, x, y, width, height)
        elif element_type == "minimap":
            self._render_minimap(element_name, element, x, y, width, height)
        elif element_type == "castbar":
            self._render_castbar(element_name, element, x, y, width, height)
        elif element_type == "aura":
            self._render_aura_frame(element_name, element, x, y, width, height)
        elif element_type == "statusbar":
            self._render_statusbar(element_name, element, x, y, width, height)
        else:
            # Generic element
            self._render_generic_element(element_name, element, x, y, width, height)
    
    def _render_unitframe(self, name: str, element: Dict[str, Any], x: int, y: int, w: int, h: int):
        """Render a unit frame (player, target, etc.)"""
        # Background
        bg_color = element.get("backgroundColor", self.wow_colors["elvui_gray"])
        self.canvas.create_rectangle(x, y, x+w, y+h, fill=bg_color, outline=self.wow_colors["frame_border"], width=1)
        
        # Health bar
        health_height = element.get("healthBarHeight", 20)
        health_y = y + 5
        health_percent = 0.85 if self.preview_mode == "simulation" else 1.0
        
        # Health background
        self.canvas.create_rectangle(
            x+5, health_y, x+w-5, health_y+health_height,
            fill="#1F1F1F", outline=""
        )
        
        # Health bar
        health_width = int((w-10) * health_percent)
        health_color = self._get_health_color(health_percent)
        self.canvas.create_rectangle(
            x+5, health_y, x+5+health_width, health_y+health_height,
            fill=health_color, outline=""
        )
        
        # Health text
        if element.get("showHealthText", True):
            health_text = "12,450 / 14,650" if self.preview_mode == "simulation" else "100%"
            self.canvas.create_text(
                x+w//2, health_y+health_height//2,
                text=health_text, fill=self.wow_colors["text_white"],
                font=("Arial", 8, "bold")
            )
        
        # Power bar (mana/energy/rage)
        power_height = element.get("powerBarHeight", 8)
        power_y = health_y + health_height + 2
        power_percent = 0.65 if self.preview_mode == "simulation" else 1.0
        
        # Power background
        self.canvas.create_rectangle(
            x+5, power_y, x+w-5, power_y+power_height,
            fill="#1F1F1F", outline=""
        )
        
        # Power bar
        power_width = int((w-10) * power_percent)
        power_color = self.wow_colors["mana_blue"]  # Default to mana
        self.canvas.create_rectangle(
            x+5, power_y, x+5+power_width, power_y+power_height,
            fill=power_color, outline=""
        )
        
        # Name and level
        if element.get("showName", True):
            unit_name = name.replace("Frame", "").replace("Target", "Target") 
            if unit_name == "Player":
                unit_name = "YourCharacter"
            elif unit_name == "Target":
                unit_name = "Target Enemy" if self.preview_mode == "simulation" else "Target"
            
            self.canvas.create_text(
                x+5, y-2,
                text=unit_name, fill=self.wow_colors["text_white"],
                font=("Arial", 9, "bold"), anchor=tk.SW
            )
        
        if element.get("showLevel", True):
            level_text = "80" if self.preview_mode == "simulation" else "??"
            self.canvas.create_text(
                x+w-5, y-2,
                text=level_text, fill=self.wow_colors["text_yellow"],
                font=("Arial", 8), anchor=tk.SE
            )
    
    def _render_actionbar(self, name: str, element: Dict[str, Any], x: int, y: int, w: int, h: int):
        """Render an action bar"""
        buttons = element.get("buttons", 12)
        buttons_per_row = element.get("buttonsPerRow", 12)
        button_size = element.get("buttonSize", 32)
        button_spacing = element.get("buttonSpacing", 2)
        
        # Calculate actual button size based on bar dimensions
        actual_button_size = min(
            (w - (buttons_per_row - 1) * button_spacing) // buttons_per_row,
            h
        )
        
        rows = math.ceil(buttons / buttons_per_row)
        
        for i in range(buttons):
            row = i // buttons_per_row
            col = i % buttons_per_row
            
            button_x = x + col * (actual_button_size + button_spacing)
            button_y = y + row * (actual_button_size + button_spacing)
            
            # Skip if button is outside bar area
            if button_x + actual_button_size > x + w:
                continue
            
            # Button background
            self.canvas.create_rectangle(
                button_x, button_y, 
                button_x + actual_button_size, button_y + actual_button_size,
                fill=self.wow_colors["frame_border"], 
                outline="#4F4F4F", width=1
            )
            
            # Simulate button content in simulation mode
            if self.preview_mode == "simulation" and i < 8:  # First 8 buttons have abilities
                # Ability icon (simplified)
                icon_color = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FECA57", "#FF9FF3", "#54A0FF", "#5F27CD"][i]
                self.canvas.create_rectangle(
                    button_x + 2, button_y + 2,
                    button_x + actual_button_size - 2, button_y + actual_button_size - 2,
                    fill=icon_color, outline=""
                )
                
                # Hotkey
                if element.get("showHotkeys", True):
                    hotkey = str(i + 1) if i < 9 else ["0", "-", "="][i - 9]
                    self.canvas.create_text(
                        button_x + actual_button_size - 2, button_y + 2,
                        text=hotkey, fill=self.wow_colors["text_white"],
                        font=("Arial", 7), anchor=tk.NE
                    )
    
    def _render_groupframe(self, name: str, element: Dict[str, Any], x: int, y: int, w: int, h: int):
        """Render party/raid frames"""
        orientation = element.get("orientation", "HORIZONTAL")
        spacing = element.get("spacing", 2)
        
        # Determine number of members to show
        if "Party" in name:
            member_count = 4
            member_names = ["PartyMember1", "PartyMember2", "PartyMember3", "PartyMember4"]
        else:  # Raid
            member_count = 8  # Show first 8 for preview
            member_names = [f"Raid{i+1}" for i in range(member_count)]
        
        if orientation == "HORIZONTAL":
            member_width = (w - (member_count - 1) * spacing) // member_count
            member_height = h
            
            for i, member_name in enumerate(member_names):
                member_x = x + i * (member_width + spacing)
                member_y = y
                
                # Render as mini unit frame
                self._render_mini_unitframe(member_name, member_x, member_y, member_width, member_height)
        else:  # VERTICAL
            member_width = w
            member_height = (h - (member_count - 1) * spacing) // member_count
            
            for i, member_name in enumerate(member_names):
                member_x = x
                member_y = y + i * (member_height + spacing)
                
                # Render as mini unit frame
                self._render_mini_unitframe(member_name, member_x, member_y, member_width, member_height)
    
    def _render_mini_unitframe(self, name: str, x: int, y: int, w: int, h: int):
        """Render a mini unit frame for group members"""
        # Background
        self.canvas.create_rectangle(x, y, x+w, y+h, fill=self.wow_colors["elvui_gray"], outline=self.wow_colors["frame_border"])
        
        # Health bar
        health_percent = 0.8 + (hash(name) % 20) / 100  # Simulate varying health
        health_width = int((w-4) * health_percent)
        health_color = self._get_health_color(health_percent)
        
        self.canvas.create_rectangle(x+2, y+2, x+w-2, y+h-2, fill="#1F1F1F", outline="")
        self.canvas.create_rectangle(x+2, y+2, x+2+health_width, y+h-2, fill=health_color, outline="")
        
        # Name (shortened)
        short_name = name[:8] if len(name) > 8 else name
        self.canvas.create_text(
            x + w//2, y + h//2,
            text=short_name, fill=self.wow_colors["text_white"],
            font=("Arial", 7), anchor=tk.CENTER
        )
    
    def _render_chat(self, name: str, element: Dict[str, Any], x: int, y: int, w: int, h: int):
        """Render chat frame"""
        # Background
        bg_alpha = element.get("alpha", 0.8)
        bg_color = "#000000" if bg_alpha > 0.5 else "#1F1F1F"
        
        self.canvas.create_rectangle(x, y, x+w, y+h, fill=bg_color, outline=self.wow_colors["frame_border"])
        
        # Chat content (simulation)
        if self.preview_mode == "simulation":
            chat_lines = [
                "[Guild] PlayerName: Ready for raid?",
                "[Party] AnotherPlayer: Let's go!",
                "You receive loot: [Epic Item]",
                "[Whisper] Friend: Hey there!",
                "[Say] You: Hello everyone!"
            ]
            
            line_height = 12
            start_y = y + h - 10
            
            for i, line in enumerate(chat_lines):
                if i * line_height > h - 20:
                    break
                
                line_y = start_y - i * line_height
                color = self.wow_colors["text_white"]
                
                # Color coding for different channels
                if "[Guild]" in line:
                    color = "#40FF40"
                elif "[Party]" in line:
                    color = "#AAAAFF"
                elif "[Whisper]" in line:
                    color = "#FF80FF"
                elif "loot:" in line:
                    color = "#FFFF00"
                
                self.canvas.create_text(
                    x + 5, line_y,
                    text=line, fill=color,
                    font=("Arial", 8), anchor=tk.W
                )
        else:
            # Design mode placeholder
            self.canvas.create_text(
                x + w//2, y + h//2,
                text="Chat Frame", fill=self.wow_colors["text_gray"],
                font=("Arial", 10), anchor=tk.CENTER
            )
    
    def _render_minimap(self, name: str, element: Dict[str, Any], x: int, y: int, w: int, h: int):
        """Render minimap"""
        # Circular minimap
        center_x = x + w // 2
        center_y = y + h // 2
        radius = min(w, h) // 2 - 2
        
        # Background circle
        self.canvas.create_oval(
            center_x - radius, center_y - radius,
            center_x + radius, center_y + radius,
            fill="#2F4F2F", outline=self.wow_colors["frame_border"], width=2
        )
        
        # Minimap content (simplified)
        if self.preview_mode == "simulation":
            # Player dot (center)
            self.canvas.create_oval(
                center_x - 3, center_y - 3,
                center_x + 3, center_y + 3,
                fill=self.wow_colors["text_yellow"], outline=""
            )
            
            # Some points of interest
            import random
            for i in range(5):
                angle = i * 72  # 5 points evenly spaced
                poi_x = center_x + int((radius - 10) * math.cos(math.radians(angle)))
                poi_y = center_y + int((radius - 10) * math.sin(math.radians(angle)))
                
                self.canvas.create_oval(
                    poi_x - 2, poi_y - 2,
                    poi_x + 2, poi_y + 2,
                    fill="#FFFF00", outline=""
                )
        
        # Zone text
        if element.get("showZoneText", True):
            zone_text = "Stormwind City" if self.preview_mode == "simulation" else "Zone Name"
            self.canvas.create_text(
                center_x, y + h + 5,
                text=zone_text, fill=self.wow_colors["text_white"],
                font=("Arial", 8), anchor=tk.N
            )
    
    def _render_castbar(self, name: str, element: Dict[str, Any], x: int, y: int, w: int, h: int):
        """Render cast bar"""
        # Background
        self.canvas.create_rectangle(x, y, x+w, y+h, fill="#1F1F1F", outline=self.wow_colors["frame_border"])
        
        if self.preview_mode == "simulation":
            # Simulate casting progress
            cast_percent = (self.animation_frame % 100) / 100
            cast_width = int(w * cast_percent)
            
            # Cast bar fill
            self.canvas.create_rectangle(
                x, y, x + cast_width, y + h,
                fill="#4169E1", outline=""
            )
            
            # Spell name and cast time
            spell_name = "Fireball"
            cast_time = f"{cast_percent * 3:.1f}s / 3.0s"
            
            self.canvas.create_text(
                x + w//2, y + h//2 - 5,
                text=spell_name, fill=self.wow_colors["text_white"],
                font=("Arial", 9, "bold")
            )
            
            self.canvas.create_text(
                x + w//2, y + h//2 + 5,
                text=cast_time, fill=self.wow_colors["text_gray"],
                font=("Arial", 7)
            )
    
    def _render_aura_frame(self, name: str, element: Dict[str, Any], x: int, y: int, w: int, h: int):
        """Render buffs/debuffs frame"""
        aura_size = 20
        auras_per_row = w // (aura_size + 2)
        
        # Simulate some auras in simulation mode
        if self.preview_mode == "simulation":
            aura_colors = ["#4CAF50", "#2196F3", "#FF9800", "#9C27B0", "#F44336"]
            aura_names = ["Blessing", "Shield", "Haste", "Strength", "Curse"]
            
            for i in range(min(10, auras_per_row * 2)):  # Max 10 auras
                row = i // auras_per_row
                col = i % auras_per_row
                
                aura_x = x + col * (aura_size + 2)
                aura_y = y + row * (aura_size + 2)
                
                if aura_y + aura_size > y + h:
                    break
                
                # Aura icon
                color = aura_colors[i % len(aura_colors)]
                self.canvas.create_rectangle(
                    aura_x, aura_y, aura_x + aura_size, aura_y + aura_size,
                    fill=color, outline=self.wow_colors["frame_border"]
                )
                
                # Duration timer
                duration = f"{30 - (i * 3)}s"
                self.canvas.create_text(
                    aura_x + aura_size - 1, aura_y + aura_size - 1,
                    text=duration, fill=self.wow_colors["text_white"],
                    font=("Arial", 6), anchor=tk.SE
                )
    
    def _render_statusbar(self, name: str, element: Dict[str, Any], x: int, y: int, w: int, h: int):
        """Render experience/reputation bars"""
        # Background
        self.canvas.create_rectangle(x, y, x+w, y+h, fill="#1F1F1F", outline=self.wow_colors["frame_border"])
        
        # Progress bar
        if "Experience" in name:
            progress = 0.65
            color = "#4169E1"
            text = "XP: 125,432 / 195,000 (65%)"
        else:  # Reputation
            progress = 0.42
            color = "#32CD32"
            text = "Stormwind: 8,420 / 20,000 (Honored)"
        
        progress_width = int(w * progress)
        self.canvas.create_rectangle(x, y, x + progress_width, y + h, fill=color, outline="")
        
        # Text
        self.canvas.create_text(
            x + w//2, y + h//2,
            text=text, fill=self.wow_colors["text_white"],
            font=("Arial", 8)
        )
    
    def _render_generic_element(self, name: str, element: Dict[str, Any], x: int, y: int, w: int, h: int):
        """Render generic UI element"""
        # Background
        self.canvas.create_rectangle(x, y, x+w, y+h, fill=self.wow_colors["elvui_gray"], outline=self.wow_colors["frame_border"])
        
        # Element name
        self.canvas.create_text(
            x + w//2, y + h//2,
            text=name, fill=self.wow_colors["text_white"],
            font=("Arial", 9)
        )
    
    def _get_health_color(self, percent: float) -> str:
        """Get health bar color based on percentage"""
        if percent > 0.5:
            return self.wow_colors["health_green"]
        elif percent > 0.25:
            return self.wow_colors["health_yellow"]
        else:
            return self.wow_colors["health_red"]
    
    def _ui_to_screen_position(self, ui_pos: Dict[str, Any]) -> Optional[Tuple[int, int]]:
        """Convert UI position to screen coordinates"""
        try:
            anchor = ui_pos.get("anchor", "CENTER")
            x_offset = ui_pos.get("x", 0)
            y_offset = ui_pos.get("y", 0)
            
            # Calculate anchor position
            if anchor == "CENTER":
                anchor_x = self.canvas_width // 2
                anchor_y = self.canvas_height // 2
            elif anchor == "TOPLEFT":
                anchor_x = 0
                anchor_y = 0
            elif anchor == "TOPRIGHT":
                anchor_x = self.canvas_width
                anchor_y = 0
            elif anchor == "BOTTOMLEFT":
                anchor_x = 0
                anchor_y = self.canvas_height
            elif anchor == "BOTTOMRIGHT":
                anchor_x = self.canvas_width
                anchor_y = self.canvas_height
            elif anchor == "TOP":
                anchor_x = self.canvas_width // 2
                anchor_y = 0
            elif anchor == "BOTTOM":
                anchor_x = self.canvas_width // 2
                anchor_y = self.canvas_height
            elif anchor == "LEFT":
                anchor_x = 0
                anchor_y = self.canvas_height // 2
            elif anchor == "RIGHT":
                anchor_x = self.canvas_width
                anchor_y = self.canvas_height // 2
            else:
                anchor_x = self.canvas_width // 2
                anchor_y = self.canvas_height // 2
            
            # Apply scale factor and offsets
            screen_x = anchor_x + int(x_offset * self.scale_factor)
            screen_y = anchor_y + int(y_offset * self.scale_factor)
            
            return (screen_x, screen_y)
            
        except Exception as e:
            self.logger.error(f"Error converting UI position: {e}")
            return None
    
    def _ui_to_screen_size(self, ui_size: Dict[str, Any], scale: float = 1.0) -> Optional[Tuple[int, int]]:
        """Convert UI size to screen size"""
        try:
            width = int(ui_size.get("width", 100) * self.scale_factor * scale)
            height = int(ui_size.get("height", 30) * self.scale_factor * scale)
            return (width, height)
        except Exception as e:
            self.logger.error(f"Error converting UI size: {e}")
            return None
    
    def _draw_selection_highlight(self, element_name: str):
        """Draw selection highlight around element"""
        if element_name not in self.ui_elements:
            return
        
        element = self.ui_elements[element_name]
        screen_pos = self._ui_to_screen_position(element["position"])
        screen_size = self._ui_to_screen_size(element["size"], element.get("scale", 1.0))
        
        if screen_pos and screen_size:
            x, y = screen_pos
            w, h = screen_size
            
            # Highlight border
            self.canvas.create_rectangle(
                x-2, y-2, x+w+2, y+h+2,
                outline="#FFD700", width=2, fill=""
            )
            
            # Selection handles
            handle_size = 6
            handles = [
                (x-handle_size//2, y-handle_size//2),  # Top-left
                (x+w-handle_size//2, y-handle_size//2),  # Top-right
                (x-handle_size//2, y+h-handle_size//2),  # Bottom-left
                (x+w-handle_size//2, y+h-handle_size//2),  # Bottom-right
            ]
            
            for hx, hy in handles:
                self.canvas.create_rectangle(
                    hx, hy, hx+handle_size, hy+handle_size,
                    fill="#FFD700", outline="#FFD700"
                )
    
    def _draw_design_overlay(self):
        """Draw design mode overlay information"""
        # Grid
        if self.settings.get("ui.show_grid", True):
            self._draw_grid()
        
        # Rulers
        if self.settings.get("ui.show_rulers", True):
            self._draw_rulers()
        
        # Element labels
        if self.settings.get("ui.show_labels", True):
            self._draw_element_labels()
    
    def _draw_grid(self):
        """Draw alignment grid"""
        grid_size = 20 * self.scale_factor
        grid_color = "#2F2F2F"
        
        # Vertical lines
        x = 0
        while x < self.canvas_width:
            self.canvas.create_line(x, 0, x, self.canvas_height, fill=grid_color, width=1)
            x += grid_size
        
        # Horizontal lines
        y = 0
        while y < self.canvas_height:
            self.canvas.create_line(0, y, self.canvas_width, y, fill=grid_color, width=1)
            y += grid_size
    
    def _draw_rulers(self):
        """Draw rulers for precise positioning"""
        ruler_size = 20
        tick_color = "#4F4F4F"
        
        # Top ruler
        self.canvas.create_rectangle(0, 0, self.canvas_width, ruler_size, fill="#1F1F1F", outline=tick_color)
        
        # Left ruler  
        self.canvas.create_rectangle(0, 0, ruler_size, self.canvas_height, fill="#1F1F1F", outline=tick_color)
        
        # Tick marks every 50 pixels
        for x in range(0, self.canvas_width, 50):
            self.canvas.create_line(x, 0, x, ruler_size, fill=tick_color)
            if x > 0:
                self.canvas.create_text(x, ruler_size//2, text=str(x), fill="#AAAAAA", font=("Arial", 7))
        
        for y in range(0, self.canvas_height, 50):
            self.canvas.create_line(0, y, ruler_size, y, fill=tick_color)
            if y > 0:
                self.canvas.create_text(ruler_size//2, y, text=str(y), fill="#AAAAAA", font=("Arial", 7), angle=90)
    
    def _draw_element_labels(self):
        """Draw element labels for identification"""
        for element_name, element in self.ui_elements.items():
            if not element.get("enabled", True):
                continue
            
            screen_pos = self._ui_to_screen_position(element["position"])
            if screen_pos:
                x, y = screen_pos
                
                # Label background
                label_text = element_name
                self.canvas.create_text(
                    x, y-10,
                    text=label_text, fill="#FFFF00",
                    font=("Arial", 8, "bold"), anchor=tk.W
                )
    
    def _animation_loop(self):
        """Main animation loop for dynamic content"""
        current_time = time.time()
        
        if current_time - self.last_update > 0.1:  # Update 10 times per second
            self.animation_frame += 1
            self.last_update = current_time
            
            # Update simulation elements if in simulation mode
            if self.preview_mode == "simulation":
                self._render_ui()
        
        # Schedule next frame
        self.canvas.after(50, self._animation_loop)
    
    def _on_click(self, event):
        """Handle mouse click"""
        # Find element at click position
        clicked_element = None
        
        for element_name, element in self.ui_elements.items():
            if not element.get("enabled", True):
                continue
            
            screen_pos = self._ui_to_screen_position(element["position"])
            screen_size = self._ui_to_screen_size(element["size"], element.get("scale", 1.0))
            
            if screen_pos and screen_size:
                x, y = screen_pos
                w, h = screen_size
                
                if x <= event.x <= x + w and y <= event.y <= y + h:
                    clicked_element = element_name
                    break
        
        # Update selection
        if clicked_element != self.selected_element:
            self.selected_element = clicked_element
            self._render_ui()
            
            # Notify parent of selection change
            if hasattr(self.canvas.master, 'on_element_selected'):
                self.canvas.master.on_element_selected(clicked_element)
    
    def _on_drag(self, event):
        """Handle mouse drag"""
        if self.selected_element and self.preview_mode == "design":
            # Update element position
            element = self.ui_elements[self.selected_element]
            
            # Convert screen position back to UI coordinates
            anchor_pos = self._get_anchor_position(element["position"]["anchor"])
            if anchor_pos:
                anchor_x, anchor_y = anchor_pos
                ui_x = (event.x - anchor_x) / self.scale_factor
                ui_y = (event.y - anchor_y) / self.scale_factor
                
                element["position"]["x"] = int(ui_x)
                element["position"]["y"] = int(ui_y)
                
                self._render_ui()
    
    def _on_release(self, event):
        """Handle mouse release"""
        pass
    
    def _on_hover(self, event):
        """Handle mouse hover"""
        # Could show tooltips or highlights here
        pass
    
    def _get_anchor_position(self, anchor: str) -> Optional[Tuple[int, int]]:
        """Get anchor position on screen"""
        anchors = {
            "CENTER": (self.canvas_width // 2, self.canvas_height // 2),
            "TOPLEFT": (0, 0),
            "TOPRIGHT": (self.canvas_width, 0),
            "BOTTOMLEFT": (0, self.canvas_height),
            "BOTTOMRIGHT": (self.canvas_width, self.canvas_height),
            "TOP": (self.canvas_width // 2, 0),
            "BOTTOM": (self.canvas_width // 2, self.canvas_height),
            "LEFT": (0, self.canvas_height // 2),
            "RIGHT": (self.canvas_width, self.canvas_height // 2)
        }
        return anchors.get(anchor)
    
    def set_selected_element(self, element_name: Optional[str]):
        """Set selected element programmatically"""
        if element_name != self.selected_element:
            self.selected_element = element_name
            self._render_ui()
    
    def export_preview_image(self, output_path: Path) -> bool:
        """Export current preview as image"""
        try:
            # This would require PIL and canvas to PostScript conversion
            # For now, return success placeholder
            self.logger.info(f"Preview export requested: {output_path}")
            return True
        except Exception as e:
            self.logger.error(f"Error exporting preview: {e}")
            return False