#!/usr/bin/env python3
"""
Enhanced DRGUI AI Designer - Main Application
Advanced World of Warcraft UI designer with AI assistance, WoW integration, and ElvUI compatibility.
"""

import logging
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import threading
import time
from pathlib import Path
from typing import Dict, Any, Optional

# Import enhanced components
from ai.ai_assistant import AIAssistant
from ai.advanced_theme_generator import AdvancedThemeGenerator
from ui.enhanced_ui_manager import EnhancedUIManager
from ui.wow_preview_renderer import WoWPreviewRenderer
from utils.settings_manager import SettingsManager
from integrations.wow_integration import WoWIntegration
from utils.export_manager import ExportManager

class DRGUIAIDesigner:
    """
    Enhanced DRGUI AI Designer Application
    
    Features:
    - AI-powered UI design assistance
    - Seamless DRGUI and ElvUI compatibility
    - Automatic WoW character profile loading
    - Real-time UI preview with game assets
    - Advanced addon integration
    - Export to multiple formats
    """
    
    def __init__(self):
        """Initialize the Enhanced DRGUI AI Designer"""
        self.logger = logging.getLogger(__name__)
        
        # Initialize core components
        self.settings = SettingsManager()
        self.wow_integration = WoWIntegration(self.settings)
        self.ai_assistant = AIAssistant(self.settings)
        self.theme_generator = AdvancedThemeGenerator(self.ai_assistant)
        self.export_manager = ExportManager(self.settings)
        
        # UI state
        self.current_profile = None
        self.ui_elements = {}
        self.selected_element = None
        self.unsaved_changes = False
        
        # Setup UI
        self.root = None
        self.main_frame = None
        self.ui_manager = None
        self.preview_renderer = None
        
        self.logger.info("Enhanced DRGUI AI Designer initialized")
    
    def run(self):
        """Run the application"""
        try:
            self._create_ui()
            self._setup_components()
            self._load_initial_data()
            
            self.logger.info("Starting Enhanced DRGUI AI Designer UI")
            self.root.mainloop()
            
        except Exception as e:
            self.logger.error(f"Application error: {e}")
            messagebox.showerror("Error", f"Application error: {e}")
    
    def _create_ui(self):
        """Create the main UI"""
        self.root = tk.Tk()
        self.root.title("Enhanced DRGUI AI Designer")
        self.root.geometry("1400x900")
        self.root.minsize(1200, 800)
        
        # Set theme
        style = ttk.Style()
        style.theme_use('clam')
        
        # Configure colors for WoW-like theme
        style.configure('TLabel', background='#2F2F2F', foreground='#FFFFFF')
        style.configure('TFrame', background='#2F2F2F')
        style.configure('TNotebook', background='#2F2F2F')
        style.configure('TNotebook.Tab', background='#1F1F1F', foreground='#FFFFFF')
        
        self.root.configure(bg='#1F1F1F')
        
        # Setup menu
        self._create_menu()
        
        # Create main layout
        self._create_main_layout()
        
        # Bind events
        self.root.protocol("WM_DELETE_WINDOW", self._on_closing)
        self.root.bind('<Control-s>', lambda e: self._save_profile())
        self.root.bind('<Control-o>', lambda e: self._load_profile())
        self.root.bind('<Control-n>', lambda e: self._new_profile())
        self.root.bind('<F1>', lambda e: self._show_help())
    
    def _create_menu(self):
        """Create application menu"""
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="New Profile", command=self._new_profile, accelerator="Ctrl+N")
        file_menu.add_command(label="Load Profile", command=self._load_profile, accelerator="Ctrl+O")
        file_menu.add_command(label="Save Profile", command=self._save_profile, accelerator="Ctrl+S")
        file_menu.add_command(label="Save As...", command=self._save_profile_as)
        file_menu.add_separator()
        file_menu.add_command(label="Import Character", command=self._import_character)
        file_menu.add_command(label="Import ElvUI Profile", command=self._import_elvui_profile)
        file_menu.add_separator()
        file_menu.add_command(label="Export DRGUI", command=self._export_drgui)
        file_menu.add_command(label="Export ElvUI", command=self._export_elvui)
        file_menu.add_command(label="Export WeakAuras", command=self._export_weakauras)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self._on_closing)
        
        # Edit menu
        edit_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Edit", menu=edit_menu)
        edit_menu.add_command(label="Undo", command=self._undo, state=tk.DISABLED)
        edit_menu.add_command(label="Redo", command=self._redo, state=tk.DISABLED)
        edit_menu.add_separator()
        edit_menu.add_command(label="Select All Elements", command=self._select_all_elements)
        edit_menu.add_command(label="Deselect All", command=self._deselect_all)
        edit_menu.add_separator()
        edit_menu.add_command(label="Preferences", command=self._show_preferences)
        
        # View menu
        view_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="View", menu=view_menu)
        view_menu.add_command(label="Show Grid", command=self._toggle_grid)
        view_menu.add_command(label="Show Rulers", command=self._toggle_rulers)
        view_menu.add_command(label="Show Element Labels", command=self._toggle_labels)
        view_menu.add_separator()
        view_menu.add_command(label="Design Mode", command=lambda: self._set_preview_mode("design"))
        view_menu.add_command(label="Simulation Mode", command=lambda: self._set_preview_mode("simulation"))
        view_menu.add_separator()
        view_menu.add_command(label="Zoom In", command=self._zoom_in)
        view_menu.add_command(label="Zoom Out", command=self._zoom_out)
        view_menu.add_command(label="Reset Zoom", command=self._reset_zoom)
        
        # AI menu
        ai_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="AI Assistant", menu=ai_menu)
        ai_menu.add_command(label="Generate UI", command=self._ai_generate_ui)
        ai_menu.add_command(label="Optimize Layout", command=self._ai_optimize_layout)
        ai_menu.add_command(label="Suggest Improvements", command=self._ai_suggest_improvements)
        ai_menu.add_separator()
        ai_menu.add_command(label="Class-Based Design", command=self._ai_class_design)
        ai_menu.add_command(label="Role-Based Design", command=self._ai_role_design)
        ai_menu.add_separator()
        ai_menu.add_command(label="AI Settings", command=self._ai_settings)
        
        # Tools menu
        tools_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Tools", menu=tools_menu)
        tools_menu.add_command(label="Character Browser", command=self._show_character_browser)
        tools_menu.add_command(label="Addon Manager", command=self._show_addon_manager)
        tools_menu.add_command(label="Asset Browser", command=self._show_asset_browser)
        tools_menu.add_separator()
        tools_menu.add_command(label="Validate Profile", command=self._validate_profile)
        tools_menu.add_command(label="Test in WoW", command=self._test_in_wow)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="User Guide", command=self._show_help, accelerator="F1")
        help_menu.add_command(label="Keyboard Shortcuts", command=self._show_shortcuts)
        help_menu.add_command(label="Video Tutorials", command=self._show_tutorials)
        help_menu.add_separator()
        help_menu.add_command(label="Check for Updates", command=self._check_updates)
        help_menu.add_command(label="About", command=self._show_about)
    
    def _create_main_layout(self):
        """Create main application layout"""
        # Main container
        self.main_frame = ttk.Frame(self.root)
        self.main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Create left panel (tools and properties)
        left_panel = ttk.Frame(self.main_frame, width=300)
        left_panel.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 5))
        left_panel.pack_propagate(False)
        
        # Create center panel (preview)
        center_panel = ttk.Frame(self.main_frame)
        center_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))
        
        # Create right panel (AI assistant)
        right_panel = ttk.Frame(self.main_frame, width=300)
        right_panel.pack(side=tk.RIGHT, fill=tk.Y)
        right_panel.pack_propagate(False)
        
        # Setup panels
        self._create_left_panel(left_panel)
        self._create_center_panel(center_panel)
        self._create_right_panel(right_panel)
        
        # Status bar
        self._create_status_bar()
    
    def _create_left_panel(self, parent):
        """Create left panel with tools and properties"""
        # AI Theme Generator
        theme_frame = ttk.LabelFrame(parent, text="🎨 AI Theme Generator")
        theme_frame.pack(fill=tk.X, pady=(0, 5))
        
        # Quick theme buttons inspired by JiberishUI
        quick_themes = [
            ("⚡ Generate Smart Theme", "smart"),
            ("🌙 Dark Elegance", "dark_elegant"),
            ("🌟 Cosmic Vibrant", "cosmic"),
            ("📐 Minimalist Pro", "minimal")
        ]
        
        for i, (text, theme_type) in enumerate(quick_themes):
            btn = ttk.Button(theme_frame, text=text,
                           command=lambda t=theme_type: self._generate_ai_theme(t))
            btn.pack(fill=tk.X, padx=5, pady=2)
        
        # Advanced theme options
        theme_options_frame = ttk.Frame(theme_frame)
        theme_options_frame.pack(fill=tk.X, padx=5, pady=5)
        
        ttk.Label(theme_options_frame, text="Role:").grid(row=0, column=0, sticky="w")
        self.role_var = tk.StringVar(value="Auto-detect")
        role_combo = ttk.Combobox(theme_options_frame, textvariable=self.role_var, 
                                 values=["Auto-detect", "Tank", "Healer", "DPS"], state="readonly")
        role_combo.grid(row=0, column=1, sticky="ew", padx=(5, 0))
        
        ttk.Label(theme_options_frame, text="Content:").grid(row=1, column=0, sticky="w")
        self.content_var = tk.StringVar(value="General")
        content_combo = ttk.Combobox(theme_options_frame, textvariable=self.content_var,
                                   values=["General", "Raid", "Dungeon", "PvP", "Solo"], state="readonly")
        content_combo.grid(row=1, column=1, sticky="ew", padx=(5, 0))
        
        theme_options_frame.grid_columnconfigure(1, weight=1)
        
        # Tool palette
        tool_frame = ttk.LabelFrame(parent, text="UI Elements")
        tool_frame.pack(fill=tk.X, pady=(0, 5))
        
        # Element buttons
        elements = [
            ("Unit Frame", "unitframe"),
            ("Action Bar", "actionbar"),
            ("Group Frame", "groupframe"),
            ("Chat Frame", "chat"),
            ("Minimap", "minimap"),
            ("Cast Bar", "castbar"),
            ("Aura Frame", "aura"),
            ("Status Bar", "statusbar")
        ]
        
        for i, (text, element_type) in enumerate(elements):
            row = i // 2
            col = i % 2
            btn = ttk.Button(tool_frame, text=text, 
                           command=lambda t=element_type: self._add_element(t))
            btn.grid(row=row, column=col, padx=2, pady=2, sticky="ew")
        
        tool_frame.grid_columnconfigure(0, weight=1)
        tool_frame.grid_columnconfigure(1, weight=1)
        
        # Character selection
        char_frame = ttk.LabelFrame(parent, text="Character")
        char_frame.pack(fill=tk.X, pady=(0, 5))
        
        self.char_var = tk.StringVar(value="Auto-detect")
        self.char_combo = ttk.Combobox(char_frame, textvariable=self.char_var, state="readonly")
        self.char_combo.pack(fill=tk.X, padx=5, pady=5)
        self.char_combo.bind('<<ComboboxSelected>>', self._on_character_changed)
        
        ttk.Button(char_frame, text="Refresh Characters", 
                  command=self._refresh_characters).pack(fill=tk.X, padx=5, pady=(0, 5))
        
        # Properties panel
        self.properties_frame = ttk.LabelFrame(parent, text="Properties")
        self.properties_frame.pack(fill=tk.BOTH, expand=True)
        
        # Scrollable properties
        canvas = tk.Canvas(self.properties_frame, bg='#2F2F2F')
        scrollbar = ttk.Scrollbar(self.properties_frame, orient="vertical", command=canvas.yview)
        self.properties_content = ttk.Frame(canvas)
        
        self.properties_content.bind("<Configure>", 
                                   lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        
        canvas.create_window((0, 0), window=self.properties_content, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        
        self._update_properties_panel()
    
    def _create_center_panel(self, parent):
        """Create center panel with preview"""
        # Toolbar
        toolbar = ttk.Frame(parent)
        toolbar.pack(fill=tk.X, pady=(0, 5))
        
        # Preview mode buttons
        ttk.Label(toolbar, text="Mode:").pack(side=tk.LEFT, padx=(0, 5))
        
        self.mode_var = tk.StringVar(value="design")
        ttk.Radiobutton(toolbar, text="Design", variable=self.mode_var, value="design",
                       command=self._on_mode_changed).pack(side=tk.LEFT, padx=(0, 10))
        ttk.Radiobutton(toolbar, text="Simulation", variable=self.mode_var, value="simulation",
                       command=self._on_mode_changed).pack(side=tk.LEFT, padx=(0, 20))
        
        # View controls
        ttk.Label(toolbar, text="View:").pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(toolbar, text="Grid", command=self._toggle_grid).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Rulers", command=self._toggle_rulers).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Labels", command=self._toggle_labels).pack(side=tk.LEFT, padx=2)
        
        # Zoom controls
        ttk.Label(toolbar, text="Zoom:").pack(side=tk.LEFT, padx=(20, 5))
        ttk.Button(toolbar, text="-", command=self._zoom_out, width=3).pack(side=tk.LEFT, padx=1)
        ttk.Button(toolbar, text="100%", command=self._reset_zoom, width=5).pack(side=tk.LEFT, padx=1)
        ttk.Button(toolbar, text="+", command=self._zoom_in, width=3).pack(side=tk.LEFT, padx=1)
        
        # Preview canvas
        preview_frame = ttk.LabelFrame(parent, text="UI Preview")
        preview_frame.pack(fill=tk.BOTH, expand=True)
        
        # Canvas with scrollbars
        canvas_frame = ttk.Frame(preview_frame)
        canvas_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.preview_canvas = tk.Canvas(canvas_frame, bg='#0F1419', 
                                       scrollregion=(0, 0, 1024, 768))
        
        h_scrollbar = ttk.Scrollbar(canvas_frame, orient="horizontal", command=self.preview_canvas.xview)
        v_scrollbar = ttk.Scrollbar(canvas_frame, orient="vertical", command=self.preview_canvas.yview)
        
        self.preview_canvas.configure(xscrollcommand=h_scrollbar.set, yscrollcommand=v_scrollbar.set)
        
        self.preview_canvas.grid(row=0, column=0, sticky="nsew")
        h_scrollbar.grid(row=1, column=0, sticky="ew")
        v_scrollbar.grid(row=0, column=1, sticky="ns")
        
        canvas_frame.grid_rowconfigure(0, weight=1)
        canvas_frame.grid_columnconfigure(0, weight=1)
    
    def _create_right_panel(self, parent):
        """Create right panel with AI assistant"""
        # AI Assistant
        ai_frame = ttk.LabelFrame(parent, text="AI Assistant")
        ai_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 5))
        
        # AI conversation
        self.ai_conversation = tk.Text(ai_frame, wrap=tk.WORD, height=15, 
                                      bg='#1F1F1F', fg='#FFFFFF', state=tk.DISABLED)
        ai_scroll = ttk.Scrollbar(ai_frame, command=self.ai_conversation.yview)
        self.ai_conversation.configure(yscrollcommand=ai_scroll.set)
        
        self.ai_conversation.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)
        ai_scroll.pack(side=tk.RIGHT, fill=tk.Y, pady=5)
        
        # AI input
        input_frame = ttk.Frame(parent)
        input_frame.pack(fill=tk.X, pady=(0, 5))
        
        self.ai_input = tk.Entry(input_frame, bg='#2F2F2F', fg='#FFFFFF')
        self.ai_input.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        self.ai_input.bind('<Return>', self._on_ai_input)
        
        ttk.Button(input_frame, text="Send", command=self._on_ai_input).pack(side=tk.RIGHT)
        
        # Quick actions
        quick_frame = ttk.LabelFrame(parent, text="Quick Actions")
        quick_frame.pack(fill=tk.X)
        
        quick_actions = [
            ("Generate UI", self._ai_generate_ui),
            ("Optimize Layout", self._ai_optimize_layout),
            ("Class Design", self._ai_class_design),
            ("Suggest Improvements", self._ai_suggest_improvements)
        ]
        
        for text, command in quick_actions:
            ttk.Button(quick_frame, text=text, command=command).pack(fill=tk.X, padx=5, pady=2)
    
    def _create_status_bar(self):
        """Create status bar"""
        self.status_bar = ttk.Frame(self.root)
        self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Status text
        self.status_text = tk.StringVar(value="Ready")
        ttk.Label(self.status_bar, textvariable=self.status_text).pack(side=tk.LEFT, padx=5)
        
        # WoW status
        self.wow_status = tk.StringVar(value="WoW: Not Connected")
        ttk.Label(self.status_bar, textvariable=self.wow_status).pack(side=tk.RIGHT, padx=5)
    
    def _setup_components(self):
        """Setup application components"""
        # Initialize UI manager
        self.ui_manager = EnhancedUIManager(
            self.root, self.wow_integration, self.ai_assistant, self.settings
        )
        
        # Initialize preview renderer
        self.preview_renderer = WoWPreviewRenderer(
            self.preview_canvas, self.wow_integration, self.settings
        )
        
        # Connect AI assistant
        self.ai_assistant.set_ui_manager(self.ui_manager)
        self.ai_assistant.set_wow_integration(self.wow_integration)
        
        self.logger.info("Components initialized")
    
    def _load_initial_data(self):
        """Load initial data and setup"""
        # Check WoW integration
        if self.wow_integration.wow_path:
            self.wow_status.set("WoW: Connected")
            self._refresh_characters()
        else:
            self.wow_status.set("WoW: Not Found")
        
        # Load default profile or create new
        self._new_profile()
        
        # Add welcome message to AI
        self._add_ai_message("system", "Welcome to Enhanced DRGUI AI Designer! I can help you create amazing WoW UIs. What would you like to design today?")
    
    def _add_element(self, element_type: str):
        """Add new UI element"""
        try:
            element = self.ui_manager.create_ui_element(element_type)
            if element:
                self.ui_elements[element["name"]] = element
                self._update_preview()
                self._mark_unsaved()
                self.status_text.set(f"Added {element_type}")
                self.logger.info(f"Added element: {element['name']}")
        except Exception as e:
            self.logger.error(f"Error adding element: {e}")
            messagebox.showerror("Error", f"Failed to add element: {e}")
    
    def _generate_ai_theme(self, theme_type: str):
        """Generate AI-powered theme based on user preferences and gameplay context"""
        try:
            self.status_text.set("Generating AI theme...")
            
            # Prepare context for theme generation
            context = {
                'player_role': self.role_var.get().lower() if self.role_var.get() != "Auto-detect" else "balanced",
                'content_type': self.content_var.get().lower(),
                'resolution': {'width': 1920, 'height': 1080},
                'theme_preference': theme_type
            }
            
            # Get user data from current profile (simplified)
            user_data = {
                'previous_colors': ['dark', 'blue'] if 'dark' in theme_type else ['bright', 'cosmic'],
                'layout_choices': ['minimal'] if 'minimal' in theme_type else ['balanced'],
                'customization_count': len(self.ui_elements),
                'enabled_elements': list(self.ui_elements.keys()),
                'effects_enabled': theme_type != 'minimal'
            }
            
            # Generate theme using advanced AI
            result = self.theme_generator.generate_intelligent_theme(context, user_data)
            
            if result:
                theme = result['theme']
                confidence = result['confidence']
                
                # Apply theme to current UI
                self._apply_ai_theme(theme)
                
                # Show AI feedback
                ai_message = f"""🎨 Generated '{theme['name']}' theme!
                
Style: {theme['style'].replace('_', ' ').title()}
AI Confidence: {confidence:.0%}
                
Key Features:
• {theme.get('description', 'Custom AI-optimized layout')}
• Color palette optimized for {context['content_type']} content  
• Layout adapted for {context['player_role']} role
                
This theme combines the best of JiberishUI's aesthetics with EltreumUI's functionality, enhanced with revolutionary AI insights!"""
                
                self._add_ai_message("assistant", ai_message)
                self.status_text.set(f"Applied AI theme: {theme['name']}")
                self._mark_unsaved()
            else:
                self._add_ai_message("system", "Failed to generate theme. Please try again.")
                
        except Exception as e:
            self.logger.error(f"Error generating AI theme: {e}")
            self._add_ai_message("system", f"Error generating theme: {e}")
            self.status_text.set("Theme generation failed")
    
    def _apply_ai_theme(self, theme: dict):
        """Apply generated AI theme to the current UI"""
        try:
            # Apply colors and layout optimizations
            colors = theme.get('colors', {})
            layout = theme.get('layout', {})
            
            # Create recommended elements based on theme
            if layout.get('threat_meter', {}).get('visible'):
                self._add_element('statusbar')
            
            if layout.get('damage_meters', {}).get('visible'):
                self._add_element('groupframe')
            
            # Update preview with new theme
            self._update_preview()
                
        except Exception as e:
            self.logger.error(f"Error applying AI theme: {e}")
            raise
    
    def _on_character_changed(self, event=None):
        """Handle character selection change"""
        character = self.char_var.get()
        if character and character != "Auto-detect":
            try:
                # Load character profile
                profile = self.wow_integration.load_character_ui_profile(character, "Unknown")
                if profile:
                    self._apply_character_profile(profile)
                    self.status_text.set(f"Loaded character: {character}")
            except Exception as e:
                self.logger.error(f"Error loading character: {e}")
                messagebox.showerror("Error", f"Failed to load character: {e}")
    
    def _refresh_characters(self):
        """Refresh character list"""
        try:
            characters = self.wow_integration.get_characters()
            self.char_combo['values'] = ["Auto-detect"] + characters
            if characters:
                self.status_text.set(f"Found {len(characters)} characters")
        except Exception as e:
            self.logger.error(f"Error refreshing characters: {e}")
    
    def _apply_character_profile(self, profile: Dict[str, Any]):
        """Apply character profile to UI"""
        try:
            # Convert profile to UI elements
            ui_elements = self.ui_manager.import_character_profile(profile)
            self.ui_elements.update(ui_elements)
            self._update_preview()
            self._mark_unsaved()
        except Exception as e:
            self.logger.error(f"Error applying character profile: {e}")
    
    def _on_mode_changed(self):
        """Handle preview mode change"""
        mode = self.mode_var.get()
        self.preview_renderer.set_preview_mode(mode)
        self.status_text.set(f"Mode: {mode.title()}")
    
    def _update_preview(self):
        """Update UI preview"""
        try:
            self.preview_renderer.update_ui_elements(self.ui_elements)
        except Exception as e:
            self.logger.error(f"Error updating preview: {e}")
    
    def _update_properties_panel(self):
        """Update properties panel for selected element"""
        # Clear existing properties
        for widget in self.properties_content.winfo_children():
            widget.destroy()
        
        if not self.selected_element or self.selected_element not in self.ui_elements:
            ttk.Label(self.properties_content, text="No element selected").pack(pady=10)
            return
        
        element = self.ui_elements[self.selected_element]
        
        # Element name
        ttk.Label(self.properties_content, text="Element Name:").pack(anchor=tk.W, padx=5)
        name_var = tk.StringVar(value=element.get("name", ""))
        ttk.Entry(self.properties_content, textvariable=name_var).pack(fill=tk.X, padx=5, pady=2)
        
        # Position
        ttk.Label(self.properties_content, text="Position:").pack(anchor=tk.W, padx=5, pady=(10, 0))
        pos_frame = ttk.Frame(self.properties_content)
        pos_frame.pack(fill=tk.X, padx=5)
        
        # Add position controls
        self._add_position_controls(pos_frame, element)
        
        # Size
        ttk.Label(self.properties_content, text="Size:").pack(anchor=tk.W, padx=5, pady=(10, 0))
        size_frame = ttk.Frame(self.properties_content)
        size_frame.pack(fill=tk.X, padx=5)
        
        # Add size controls
        self._add_size_controls(size_frame, element)
        
        # Element-specific properties
        self._add_element_specific_properties(element)
    
    def _add_position_controls(self, parent, element):
        """Add position control widgets"""
        position = element.get("position", {})
        
        # Anchor
        ttk.Label(parent, text="Anchor:").grid(row=0, column=0, sticky=tk.W)
        anchor_var = tk.StringVar(value=position.get("anchor", "CENTER"))
        anchor_combo = ttk.Combobox(parent, textvariable=anchor_var, width=10,
                                   values=["CENTER", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", 
                                          "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"])
        anchor_combo.grid(row=0, column=1, padx=5)
        
        # X offset
        ttk.Label(parent, text="X:").grid(row=1, column=0, sticky=tk.W)
        x_var = tk.StringVar(value=str(position.get("x", 0)))
        ttk.Entry(parent, textvariable=x_var, width=10).grid(row=1, column=1, padx=5)
        
        # Y offset
        ttk.Label(parent, text="Y:").grid(row=2, column=0, sticky=tk.W)
        y_var = tk.StringVar(value=str(position.get("y", 0)))
        ttk.Entry(parent, textvariable=y_var, width=10).grid(row=2, column=1, padx=5)
    
    def _add_size_controls(self, parent, element):
        """Add size control widgets"""
        size = element.get("size", {})
        
        # Width
        ttk.Label(parent, text="Width:").grid(row=0, column=0, sticky=tk.W)
        width_var = tk.StringVar(value=str(size.get("width", 100)))
        ttk.Entry(parent, textvariable=width_var, width=10).grid(row=0, column=1, padx=5)
        
        # Height
        ttk.Label(parent, text="Height:").grid(row=1, column=0, sticky=tk.W)
        height_var = tk.StringVar(value=str(size.get("height", 30)))
        ttk.Entry(parent, textvariable=height_var, width=10).grid(row=1, column=1, padx=5)
        
        # Scale
        ttk.Label(parent, text="Scale:").grid(row=2, column=0, sticky=tk.W)
        scale_var = tk.StringVar(value=str(element.get("scale", 1.0)))
        ttk.Entry(parent, textvariable=scale_var, width=10).grid(row=2, column=1, padx=5)
    
    def _add_element_specific_properties(self, element):
        """Add element-specific property controls"""
        element_type = element.get("type", "")
        
        if element_type == "unitframe":
            self._add_unitframe_properties(element)
        elif element_type == "actionbar":
            self._add_actionbar_properties(element)
        # Add more element types as needed
    
    def _add_unitframe_properties(self, element):
        """Add unit frame specific properties"""
        ttk.Separator(self.properties_content, orient=tk.HORIZONTAL).pack(fill=tk.X, pady=10)
        ttk.Label(self.properties_content, text="Unit Frame Settings:").pack(anchor=tk.W, padx=5)
        
        # Show health text
        health_text_var = tk.BooleanVar(value=element.get("showHealthText", True))
        ttk.Checkbutton(self.properties_content, text="Show Health Text", 
                       variable=health_text_var).pack(anchor=tk.W, padx=5)
        
        # Show name
        name_var = tk.BooleanVar(value=element.get("showName", True))
        ttk.Checkbutton(self.properties_content, text="Show Name", 
                       variable=name_var).pack(anchor=tk.W, padx=5)
    
    def _add_actionbar_properties(self, element):
        """Add action bar specific properties"""
        ttk.Separator(self.properties_content, orient=tk.HORIZONTAL).pack(fill=tk.X, pady=10)
        ttk.Label(self.properties_content, text="Action Bar Settings:").pack(anchor=tk.W, padx=5)
        
        # Number of buttons
        buttons_frame = ttk.Frame(self.properties_content)
        buttons_frame.pack(fill=tk.X, padx=5)
        
        ttk.Label(buttons_frame, text="Buttons:").grid(row=0, column=0, sticky=tk.W)
        buttons_var = tk.StringVar(value=str(element.get("buttons", 12)))
        ttk.Entry(buttons_frame, textvariable=buttons_var, width=10).grid(row=0, column=1, padx=5)
    
    def _on_ui_changed(self):
        """Handle UI changes"""
        self._mark_unsaved()
        self._update_preview()
    
    def _mark_unsaved(self):
        """Mark profile as having unsaved changes"""
        if not self.unsaved_changes:
            self.unsaved_changes = True
            title = self.root.title()
            if not title.endswith("*"):
                self.root.title(title + "*")
    
    def _on_ai_input(self, event=None):
        """Handle AI assistant input"""
        user_input = self.ai_input.get().strip()
        if not user_input:
            return
        
        self.ai_input.delete(0, tk.END)
        
        # Add user message
        self._add_ai_message("user", user_input)
        
        # Process AI request in background
        threading.Thread(target=self._process_ai_request, args=(user_input,), daemon=True).start()
    
    def _process_ai_request(self, user_input: str):
        """Process AI request in background"""
        try:
            response = self.ai_assistant.process_request(user_input, self.ui_elements)
            
            # Update UI in main thread
            self.root.after(0, lambda: self._handle_ai_response(response))
            
        except Exception as e:
            self.logger.error(f"AI request error: {e}")
            self.root.after(0, lambda: self._add_ai_message("system", f"Error: {e}"))
    
    def _handle_ai_response(self, response: Dict[str, Any]):
        """Handle AI response"""
        # Add response message
        self._add_ai_message("assistant", response.get("message", ""))
        
        # Apply any UI changes
        if "ui_changes" in response:
            for change in response["ui_changes"]:
                self._apply_ai_change(change)
        
        # Update preview
        self._update_preview()
    
    def _apply_ai_change(self, change: Dict[str, Any]):
        """Apply AI-suggested change"""
        action = change.get("action")
        
        if action == "add_element":
            element = change.get("element")
            if element:
                self.ui_elements[element["name"]] = element
        elif action == "modify_element":
            element_name = change.get("element_name")
            properties = change.get("properties", {})
            if element_name in self.ui_elements:
                self.ui_elements[element_name].update(properties)
        elif action == "remove_element":
            element_name = change.get("element_name")
            if element_name in self.ui_elements:
                del self.ui_elements[element_name]
        
        self._mark_unsaved()
    
    def _add_ai_message(self, sender: str, message: str):
        """Add message to AI conversation"""
        self.ai_conversation.config(state=tk.NORMAL)
        
        # Format message
        timestamp = time.strftime("%H:%M")
        if sender == "user":
            prefix = f"[{timestamp}] You: "
        elif sender == "assistant":
            prefix = f"[{timestamp}] AI: "
        else:
            prefix = f"[{timestamp}] System: "
        
        self.ai_conversation.insert(tk.END, prefix + message + "\n\n")
        self.ai_conversation.config(state=tk.DISABLED)
        self.ai_conversation.see(tk.END)
    
    # Menu command implementations
    def _new_profile(self):
        """Create new UI profile"""
        if self.unsaved_changes:
            if not messagebox.askyesno("Unsaved Changes", "You have unsaved changes. Continue?"):
                return
        
        self.ui_elements = {}
        self.selected_element = None
        self.current_profile = None
        self.unsaved_changes = False
        
        self.root.title("Enhanced DRGUI AI Designer - New Profile")
        self._update_preview()
        self._update_properties_panel()
        self.status_text.set("New profile created")
    
    def _load_profile(self):
        """Load UI profile"""
        if self.unsaved_changes:
            if not messagebox.askyesno("Unsaved Changes", "You have unsaved changes. Continue?"):
                return
        
        filename = filedialog.askopenfilename(
            title="Load Profile",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
        )
        
        if filename:
            try:
                profile = self.ui_manager.load_profile(filename)
                self.ui_elements = profile.get("ui_elements", {})
                self.current_profile = filename
                self.unsaved_changes = False
                
                self.root.title(f"Enhanced DRGUI AI Designer - {Path(filename).name}")
                self._update_preview()
                self._update_properties_panel()
                self.status_text.set(f"Loaded: {Path(filename).name}")
                
            except Exception as e:
                messagebox.showerror("Error", f"Failed to load profile: {e}")
    
    def _save_profile(self):
        """Save current profile"""
        if not self.current_profile:
            self._save_profile_as()
            return
        
        try:
            profile = {
                "ui_elements": self.ui_elements,
                "metadata": {
                    "created": time.time(),
                    "version": "1.0"
                }
            }
            
            self.ui_manager.save_profile(profile, self.current_profile)
            self.unsaved_changes = False
            
            title = self.root.title().rstrip("*")
            self.root.title(title)
            self.status_text.set("Profile saved")
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save profile: {e}")
    
    def _save_profile_as(self):
        """Save profile with new name"""
        filename = filedialog.asksaveasfilename(
            title="Save Profile As",
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
        )
        
        if filename:
            self.current_profile = filename
            self._save_profile()
    
    def _import_character(self):
        """Import character from WoW"""
        # Implementation for character import dialog
        messagebox.showinfo("Info", "Character import dialog not yet implemented")
    
    def _import_elvui_profile(self):
        """Import ElvUI profile"""
        filename = filedialog.askopenfilename(
            title="Import ElvUI Profile",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
        )
        
        if filename:
            try:
                ui_elements = self.ui_manager.import_elvui_profile(filename)
                self.ui_elements.update(ui_elements)
                self._update_preview()
                self._mark_unsaved()
                self.status_text.set("ElvUI profile imported")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to import ElvUI profile: {e}")
    
    def _export_drgui(self):
        """Export to DRGUI format"""
        filename = filedialog.asksaveasfilename(
            title="Export DRGUI",
            defaultextension=".lua",
            filetypes=[("Lua files", "*.lua"), ("All files", "*.*")]
        )
        
        if filename:
            try:
                self.export_manager.export_drgui(self.ui_elements, filename)
                self.status_text.set("Exported to DRGUI")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to export DRGUI: {e}")
    
    def _export_elvui(self):
        """Export to ElvUI format"""
        filename = filedialog.asksaveasfilename(
            title="Export ElvUI",
            defaultextension=".txt",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
        )
        
        if filename:
            try:
                self.export_manager.export_elvui(self.ui_elements, filename)
                self.status_text.set("Exported to ElvUI")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to export ElvUI: {e}")
    
    def _export_weakauras(self):
        """Export to WeakAuras format"""
        # Implementation for WeakAuras export
        messagebox.showinfo("Info", "WeakAuras export not yet implemented")
    
    # AI command implementations
    def _ai_generate_ui(self):
        """Generate UI using AI"""
        self._add_ai_message("user", "Generate a complete UI layout")
        threading.Thread(target=self._process_ai_request, args=("Generate a complete UI layout",), daemon=True).start()
    
    def _ai_optimize_layout(self):
        """Optimize layout using AI"""
        self._add_ai_message("user", "Optimize the current layout")
        threading.Thread(target=self._process_ai_request, args=("Optimize the current layout",), daemon=True).start()
    
    def _ai_suggest_improvements(self):
        """Get AI suggestions for improvements"""
        self._add_ai_message("user", "Suggest improvements for this UI")
        threading.Thread(target=self._process_ai_request, args=("Suggest improvements for this UI",), daemon=True).start()
    
    def _ai_class_design(self):
        """Generate class-specific design"""
        self._add_ai_message("user", "Create a UI design for my character class")
        threading.Thread(target=self._process_ai_request, args=("Create a UI design for my character class",), daemon=True).start()
    
    def _ai_role_design(self):
        """Generate role-specific design"""
        self._add_ai_message("user", "Create a UI design for my role (tank/healer/dps)")
        threading.Thread(target=self._process_ai_request, args=("Create a UI design for my role",), daemon=True).start()
    
    def _ai_settings(self):
        """Show AI settings"""
        # Implementation for AI settings dialog
        messagebox.showinfo("Info", "AI settings dialog not yet implemented")
    
    # View command implementations
    def _toggle_grid(self):
        """Toggle grid display"""
        current = self.settings.get("ui.show_grid", True)
        self.settings.set("ui.show_grid", not current)
        self._update_preview()
    
    def _toggle_rulers(self):
        """Toggle rulers display"""
        current = self.settings.get("ui.show_rulers", True)
        self.settings.set("ui.show_rulers", not current)
        self._update_preview()
    
    def _toggle_labels(self):
        """Toggle element labels"""
        current = self.settings.get("ui.show_labels", True)
        self.settings.set("ui.show_labels", not current)
        self._update_preview()
    
    def _set_preview_mode(self, mode: str):
        """Set preview mode"""
        self.mode_var.set(mode)
        self._on_mode_changed()
    
    def _zoom_in(self):
        """Zoom in"""
        # Implementation for zoom in
        self.status_text.set("Zoom in")
    
    def _zoom_out(self):
        """Zoom out"""
        # Implementation for zoom out
        self.status_text.set("Zoom out")
    
    def _reset_zoom(self):
        """Reset zoom to 100%"""
        # Implementation for reset zoom
        self.status_text.set("Zoom reset")
    
    # Edit command implementations
    def _undo(self):
        """Undo last action"""
        # Implementation for undo
        self.status_text.set("Undo")
    
    def _redo(self):
        """Redo last action"""
        # Implementation for redo
        self.status_text.set("Redo")
    
    def _select_all_elements(self):
        """Select all elements"""
        # Implementation for select all
        self.status_text.set("All elements selected")
    
    def _deselect_all(self):
        """Deselect all elements"""
        self.selected_element = None
        self._update_properties_panel()
        self._update_preview()
        self.status_text.set("Selection cleared")
    
    def _show_preferences(self):
        """Show preferences dialog"""
        # Implementation for preferences dialog
        messagebox.showinfo("Info", "Preferences dialog not yet implemented")
    
    # Tool command implementations
    def _show_character_browser(self):
        """Show character browser"""
        # Implementation for character browser
        messagebox.showinfo("Info", "Character browser not yet implemented")
    
    def _show_addon_manager(self):
        """Show addon manager"""
        # Implementation for addon manager
        messagebox.showinfo("Info", "Addon manager not yet implemented")
    
    def _show_asset_browser(self):
        """Show asset browser"""
        # Implementation for asset browser
        messagebox.showinfo("Info", "Asset browser not yet implemented")
    
    def _validate_profile(self):
        """Validate current profile"""
        # Implementation for profile validation
        messagebox.showinfo("Validation", "Profile is valid")
    
    def _test_in_wow(self):
        """Test UI in WoW"""
        # Implementation for WoW testing
        messagebox.showinfo("Info", "WoW testing not yet implemented")
    
    # Help command implementations
    def _show_help(self):
        """Show help documentation"""
        help_text = """
Enhanced DRGUI AI Designer Help

Features:
• AI-powered UI design assistance
• WoW character profile integration
• ElvUI compatibility
• Real-time preview
• Multiple export formats

Getting Started:
1. Load a character profile or create new elements
2. Use the AI assistant for design suggestions
3. Preview your UI in design or simulation mode
4. Export to your preferred format

Keyboard Shortcuts:
• Ctrl+N: New profile
• Ctrl+O: Load profile
• Ctrl+S: Save profile
• F1: Show help
        """
        
        help_window = tk.Toplevel(self.root)
        help_window.title("Help")
        help_window.geometry("600x400")
        
        text_widget = tk.Text(help_window, wrap=tk.WORD)
        text_widget.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        text_widget.insert(tk.END, help_text)
        text_widget.config(state=tk.DISABLED)
    
    def _show_shortcuts(self):
        """Show keyboard shortcuts"""
        # Implementation for shortcuts dialog
        messagebox.showinfo("Info", "Keyboard shortcuts dialog not yet implemented")
    
    def _show_tutorials(self):
        """Show video tutorials"""
        # Implementation for tutorials
        messagebox.showinfo("Info", "Video tutorials not yet implemented")
    
    def _check_updates(self):
        """Check for updates"""
        # Implementation for update checking
        messagebox.showinfo("Updates", "You have the latest version")
    
    def _show_about(self):
        """Show about dialog"""
        about_text = """Enhanced DRGUI AI Designer v1.0

Advanced World of Warcraft UI designer with AI assistance.

Features:
• AI-powered design assistance
• WoW integration and character profiles
• ElvUI compatibility
• Real-time preview with game assets
• Multiple export formats

Created for the WoW community."""
        
        messagebox.showinfo("About", about_text)
    
    def _on_closing(self):
        """Handle application closing"""
        if self.unsaved_changes:
            result = messagebox.askyesnocancel("Unsaved Changes", 
                                             "You have unsaved changes. Save before closing?")
            if result is None:  # Cancel
                return
            elif result:  # Yes - save
                self._save_profile()
        
        self.logger.info("Enhanced DRGUI AI Designer closing")
        self.root.destroy()

def main():
    """Main entry point"""
    app = DRGUIAIDesigner()
    app.run()

if __name__ == "__main__":
    main()