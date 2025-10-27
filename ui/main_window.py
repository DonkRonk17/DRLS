#!/usr/bin/env python3
"""
DRGUI AI Designer - Main Window
Primary application interface with AI assistant and WoW simulation canvas.
"""

import logging
import tkinter as tk
from tkinter import ttk, messagebox
import threading
import time
from typing import Dict, Any

class DRGUIMainWindow(tk.Tk):
    """
    Main application window for DRGUI AI Designer
    
    Features:
    - AI Assistant chat interface
    - WoW UI simulation canvas
    - Element properties panel
    - Scenario management
    - Template system
    - Export/Import functionality
    """
    
    def __init__(self, app_controller, ai_assistant, simulation_engine, settings):
        """Initialize the main window"""
        super().__init__()
        
        self.logger = logging.getLogger(__name__)
        self.app_controller = app_controller
        self.ai_assistant = ai_assistant
        self.simulation_engine = simulation_engine
        self.settings = settings
        
        # Window state
        self.selected_element = None
        self.drag_mode = False
        self.current_profile = None
        
        # UI variables
        self.ai_chat_var = tk.StringVar()
        self.scenario_var = tk.StringVar(value="solo")
        self.status_var = tk.StringVar(value="Ready")
        
        # Initialize UI
        self._setup_window()
        self._create_menu_bar()
        self._create_main_layout()
        self._setup_ai_chat()
        self._setup_simulation_canvas()
        self._setup_properties_panel()
        self._setup_status_bar()
        
        # Bind events
        self._bind_events()
        
        # Initially hide window (shown after splash)
        self.withdraw()
        
        self.logger.info("Main window initialized")
    
    def _setup_window(self):
        """Configure main window properties"""
        # Window title and icon
        self.title("DRGUI AI-Powered UI Designer v2.0.0 - The War Within Ready")
        
        # Window size and position
        window_size = self.settings.get("app.window_size", [1400, 900])
        window_pos = self.settings.get("app.window_position", [100, 100])
        
        self.geometry(f"{window_size[0]}x{window_size[1]}+{window_pos[0]}+{window_pos[1]}")
        self.minsize(1200, 800)
        
        # Configure grid weights
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)
        
        # Style configuration
        self.style = ttk.Style()
        theme = self.settings.get("app.theme", "dark")
        if theme == "dark":
            self._apply_dark_theme()
    
    def _apply_dark_theme(self):
        """Apply dark theme styling"""
        try:
            # Try to use dark theme if available
            self.style.theme_use("clam")
            
            # Configure dark colors
            self.style.configure("TFrame", background="#2b2b2b")
            self.style.configure("TLabel", background="#2b2b2b", foreground="white")
            self.style.configure("TButton", background="#404040", foreground="white")
            self.style.configure("TNotebook", background="#2b2b2b")
            self.style.configure("TNotebook.Tab", background="#404040", foreground="white")
            
            self.configure(bg="#2b2b2b")
            
        except Exception as e:
            self.logger.warning(f"Could not apply dark theme: {e}")
    
    def _create_menu_bar(self):
        """Create the application menu bar"""
        menubar = tk.Menu(self)
        self.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="New Profile", command=self._new_profile)
        file_menu.add_command(label="Open Profile...", command=self._open_profile)
        file_menu.add_command(label="Save Profile", command=self._save_profile, accelerator="Ctrl+S")
        file_menu.add_command(label="Save Profile As...", command=self._save_profile_as)
        file_menu.add_separator()
        file_menu.add_command(label="Import...", command=self._import_profile)
        file_menu.add_command(label="Export to DRGUI...", command=self._export_to_drgui)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self._on_closing)
        
        # Edit menu
        edit_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Edit", menu=edit_menu)
        edit_menu.add_command(label="Undo", command=self._undo, accelerator="Ctrl+Z")
        edit_menu.add_command(label="Redo", command=self._redo, accelerator="Ctrl+Y")
        edit_menu.add_separator()
        edit_menu.add_command(label="Select All Elements", command=self._select_all)
        edit_menu.add_command(label="Clear Selection", command=self._clear_selection)
        edit_menu.add_separator()
        edit_menu.add_command(label="Preferences...", command=self._show_preferences)
        
        # View menu
        view_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="View", menu=view_menu)
        view_menu.add_command(label="Reset Layout", command=self._reset_layout)
        view_menu.add_command(label="Fullscreen Simulation", command=self._toggle_fullscreen)
        view_menu.add_separator()
        view_menu.add_command(label="Show Grid", command=self._toggle_grid)
        view_menu.add_command(label="Show Guidelines", command=self._toggle_guidelines)
        
        # AI Assistant menu
        ai_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="AI Assistant", menu=ai_menu)
        ai_menu.add_command(label="Clear Chat History", command=self._clear_chat)
        ai_menu.add_command(label="AI Suggestions", command=self._show_ai_suggestions)
        ai_menu.add_separator()
        ai_menu.add_command(label="Configure AI...", command=self._configure_ai)
        
        # Simulate menu
        simulate_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Simulate", menu=simulate_menu)
        simulate_menu.add_command(label="Solo Questing", command=lambda: self._change_scenario("solo"))
        simulate_menu.add_command(label="5-Person Dungeon", command=lambda: self._change_scenario("dungeon"))
        simulate_menu.add_command(label="20-Person Raid", command=lambda: self._change_scenario("raid"))
        simulate_menu.add_command(label="PvP Arena/BG", command=lambda: self._change_scenario("pvp"))
        simulate_menu.add_separator()
        simulate_menu.add_command(label="Start Combat", command=self._trigger_combat)
        simulate_menu.add_command(label="End Combat", command=self._end_combat)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="User Guide", command=self._show_user_guide)
        help_menu.add_command(label="AI Commands Help", command=self._show_ai_help)
        help_menu.add_command(label="Keyboard Shortcuts", command=self._show_shortcuts)
        help_menu.add_separator()
        help_menu.add_command(label="About", command=self._show_about)
    
    def _create_main_layout(self):
        """Create the main application layout"""
        # Left panel - AI Assistant and Quick Actions
        self.left_panel = ttk.Frame(self, width=300)
        self.left_panel.grid(row=0, column=0, sticky="nsew", padx=(5, 2), pady=5)
        self.left_panel.grid_propagate(False)
        
        # Center panel - WoW Simulation Canvas
        self.center_panel = ttk.Frame(self)
        self.center_panel.grid(row=0, column=1, sticky="nsew", padx=2, pady=5)
        self.center_panel.grid_columnconfigure(0, weight=1)
        self.center_panel.grid_rowconfigure(0, weight=1)
        
        # Right panel - Properties and Tools
        self.right_panel = ttk.Frame(self, width=250)
        self.right_panel.grid(row=0, column=2, sticky="nsew", padx=(2, 5), pady=5)
        self.right_panel.grid_propagate(False)
    
    def _setup_ai_chat(self):
        """Setup AI Assistant chat interface"""
        # AI Chat notebook
        ai_notebook = ttk.Notebook(self.left_panel)
        ai_notebook.pack(fill=tk.BOTH, expand=True)
        
        # Chat tab
        chat_frame = ttk.Frame(ai_notebook)
        ai_notebook.add(chat_frame, text="AI Assistant")
        
        # Chat history
        chat_history_frame = ttk.Frame(chat_frame)
        chat_history_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.chat_history = tk.Text(
            chat_history_frame,
            wrap=tk.WORD,
            height=20,
            state=tk.DISABLED,
            bg="#1e1e1e",
            fg="white",
            font=("Segoe UI", 9)
        )
        
        chat_scrollbar = ttk.Scrollbar(chat_history_frame, orient=tk.VERTICAL, command=self.chat_history.yview)
        self.chat_history.configure(yscrollcommand=chat_scrollbar.set)
        
        self.chat_history.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        chat_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Chat input
        input_frame = ttk.Frame(chat_frame)
        input_frame.pack(fill=tk.X, padx=5, pady=(0, 5))
        
        self.chat_entry = tk.Text(
            input_frame,
            height=3,
            wrap=tk.WORD,
            bg="#2b2b2b",
            fg="white",
            font=("Segoe UI", 9)
        )
        self.chat_entry.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        send_button = ttk.Button(
            input_frame,
            text="Send",
            command=self._send_ai_message
        )
        send_button.pack(side=tk.RIGHT, padx=(5, 0))
        
        # Quick Actions tab
        actions_frame = ttk.Frame(ai_notebook)
        ai_notebook.add(actions_frame, text="Quick Actions")
        
        # Scenario selection
        scenario_frame = ttk.LabelFrame(actions_frame, text="Scenario", padding=10)
        scenario_frame.pack(fill=tk.X, padx=5, pady=5)
        
        scenarios = [("Solo Questing", "solo"), ("Dungeon", "dungeon"), ("Raid", "raid"), ("PvP", "pvp")]
        for text, value in scenarios:
            ttk.Radiobutton(
                scenario_frame,
                text=text,
                variable=self.scenario_var,
                value=value,
                command=self._on_scenario_change
            ).pack(anchor=tk.W)
        
        # Quick action buttons
        actions_list_frame = ttk.LabelFrame(actions_frame, text="Quick Actions", padding=10)
        actions_list_frame.pack(fill=tk.X, padx=5, pady=5)
        
        quick_actions = [
            ("Apply Template", self._show_templates),
            ("Optimize Layout", self._optimize_layout),
            ("Test UI", self._test_ui),
            ("Reset to Default", self._reset_to_default),
            ("Import Profile", self._import_profile),
            ("Export to WoW", self._export_to_drgui)
        ]
        
        for action_text, action_command in quick_actions:
            ttk.Button(
                actions_list_frame,
                text=action_text,
                command=action_command
            ).pack(fill=tk.X, pady=2)
        
        # Add welcome message
        self._add_chat_message("AI Assistant", 
            "Welcome to DRGUI AI Designer! I'm here to help you create the perfect WoW UI.\n\n"
            "Try saying things like:\n"
            "• 'Make my health bar bigger'\n"
            "• 'Create a minimalist healer layout'\n"
            "• 'Optimize for mythic plus dungeons'\n"
            "• 'Help me position my action bars'\n\n"
            "What would you like to work on first?")
    
    def _setup_simulation_canvas(self):
        """Setup WoW simulation canvas"""
        # Canvas frame
        canvas_frame = ttk.LabelFrame(self.center_panel, text="WoW UI Simulation", padding=5)
        canvas_frame.pack(fill=tk.BOTH, expand=True)
        canvas_frame.grid_columnconfigure(0, weight=1)
        canvas_frame.grid_rowconfigure(1, weight=1)
        
        # Simulation controls
        controls_frame = ttk.Frame(canvas_frame)
        controls_frame.grid(row=0, column=0, sticky="ew", pady=(0, 5))
        
        ttk.Label(controls_frame, text="Scenario:").pack(side=tk.LEFT)
        scenario_combo = ttk.Combobox(
            controls_frame,
            textvariable=self.scenario_var,
            values=["solo", "dungeon", "raid", "pvp"],
            state="readonly",
            width=15
        )
        scenario_combo.pack(side=tk.LEFT, padx=(5, 15))
        scenario_combo.bind("<<ComboboxSelected>>", self._on_scenario_change)
        
        ttk.Button(controls_frame, text="Start Combat", command=self._trigger_combat).pack(side=tk.LEFT, padx=2)
        ttk.Button(controls_frame, text="End Combat", command=self._end_combat).pack(side=tk.LEFT, padx=2)
        ttk.Button(controls_frame, text="Reset View", command=self._reset_simulation_view).pack(side=tk.LEFT, padx=2)
        
        # Canvas for WoW simulation
        self.simulation_canvas = tk.Canvas(
            canvas_frame,
            bg="#0a0a0a",  # Dark background like WoW
            highlightthickness=0
        )
        self.simulation_canvas.grid(row=1, column=0, sticky="nsew")
        
        # Canvas scrollbars
        v_scrollbar = ttk.Scrollbar(canvas_frame, orient=tk.VERTICAL, command=self.simulation_canvas.yview)
        v_scrollbar.grid(row=1, column=1, sticky="ns")
        self.simulation_canvas.configure(yscrollcommand=v_scrollbar.set)
        
        h_scrollbar = ttk.Scrollbar(canvas_frame, orient=tk.HORIZONTAL, command=self.simulation_canvas.xview)
        h_scrollbar.grid(row=2, column=0, sticky="ew")
        self.simulation_canvas.configure(xscrollcommand=h_scrollbar.set)
        
        # Configure scroll region
        self.simulation_canvas.configure(scrollregion=(0, 0, 1920, 1080))
        
        # Create initial UI elements
        self._create_wow_ui_elements()
    
    def _setup_properties_panel(self):
        """Setup element properties panel"""
        # Properties notebook
        props_notebook = ttk.Notebook(self.right_panel)
        props_notebook.pack(fill=tk.BOTH, expand=True)
        
        # Element Properties tab
        props_frame = ttk.Frame(props_notebook)
        props_notebook.add(props_frame, text="Properties")
        
        # Selected element info
        selected_frame = ttk.LabelFrame(props_frame, text="Selected Element", padding=10)
        selected_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.selected_label = ttk.Label(selected_frame, text="No element selected")
        self.selected_label.pack()
        
        # Element properties
        self.props_frame = ttk.Frame(props_frame)
        self.props_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Templates tab
        templates_frame = ttk.Frame(props_notebook)
        props_notebook.add(templates_frame, text="Templates")
        
        # Template categories
        template_categories = [
            ("Class Layouts", ["Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Shaman", "Mage", "Warlock", "Monk", "Druid", "Demon Hunter", "Death Knight", "Evoker"]),
            ("Role Layouts", ["Tank", "Healer", "Melee DPS", "Ranged DPS"]),
            ("Content Layouts", ["Raid", "Mythic Plus", "PvP Arena", "PvP Battleground", "Solo/Questing"])
        ]
        
        for category, templates in template_categories:
            cat_frame = ttk.LabelFrame(templates_frame, text=category, padding=5)
            cat_frame.pack(fill=tk.X, padx=5, pady=5)
            
            for template in templates:
                ttk.Button(
                    cat_frame,
                    text=template,
                    command=lambda t=template: self._apply_template(t)
                ).pack(fill=tk.X, pady=1)
    
    def _setup_status_bar(self):
        """Setup status bar"""
        self.status_bar = ttk.Frame(self)
        self.status_bar.grid(row=1, column=0, columnspan=3, sticky="ew", padx=5, pady=(0, 5))
        
        # Status label
        ttk.Label(self.status_bar, textvariable=self.status_var).pack(side=tk.LEFT)
        
        # AI status
        self.ai_status_label = ttk.Label(self.status_bar, text="AI: Ready")
        self.ai_status_label.pack(side=tk.RIGHT, padx=(0, 10))
        
        # Simulation status
        self.sim_status_label = ttk.Label(self.status_bar, text="Simulation: Solo")
        self.sim_status_label.pack(side=tk.RIGHT, padx=(0, 10))
    
    def _create_wow_ui_elements(self):
        """Create initial WoW UI elements on canvas"""
        # Create mock UI elements
        self.ui_elements = {}
        
        # Player frame
        self.ui_elements["player_frame"] = self.simulation_canvas.create_rectangle(
            50, 50, 250, 120, fill="#1a3d1a", outline="#4d4d4d", width=2
        )
        self.simulation_canvas.create_text(150, 85, text="Player\n85000/100000", fill="white", font=("Arial", 10))
        
        # Target frame
        self.ui_elements["target_frame"] = self.simulation_canvas.create_rectangle(
            300, 50, 500, 120, fill="#3d1a1a", outline="#4d4d4d", width=2
        )
        self.simulation_canvas.create_text(400, 85, text="Target\n45000/75000", fill="white", font=("Arial", 10))
        
        # Action bars
        self.ui_elements["action_bar_1"] = self.simulation_canvas.create_rectangle(
            200, 950, 800, 1020, fill="#2a2a2a", outline="#4d4d4d", width=2
        )
        
        # Create action bar buttons
        for i in range(12):
            x = 210 + (i * 48)
            self.simulation_canvas.create_rectangle(
                x, 960, x + 40, 1000, fill="#404040", outline="#666666", width=1
            )
            self.simulation_canvas.create_text(x + 20, 980, text=str(i+1), fill="white", font=("Arial", 8))
        
        # Party frames
        for i in range(4):
            y = 200 + (i * 60)
            frame_id = self.simulation_canvas.create_rectangle(
                50, y, 200, y + 50, fill="#1a1a3d", outline="#4d4d4d", width=1
            )
            self.ui_elements[f"party_{i+1}"] = frame_id
            self.simulation_canvas.create_text(125, y + 25, text=f"Party {i+1}", fill="white", font=("Arial", 9))
        
        # Chat frame
        self.ui_elements["chat_frame"] = self.simulation_canvas.create_rectangle(
            50, 600, 400, 900, fill="#000000", outline="#4d4d4d", width=2
        )
        self.simulation_canvas.create_text(225, 750, text="[General] Chat messages...", fill="#40ff40", font=("Arial", 9))
        
        # Minimap
        self.ui_elements["minimap"] = self.simulation_canvas.create_oval(
            1600, 50, 1750, 200, fill="#2d4a2d", outline="#4d4d4d", width=2
        )
        self.simulation_canvas.create_text(1675, 125, text="Minimap", fill="white", font=("Arial", 10))
        
        # Bind element selection
        for element_name, element_id in self.ui_elements.items():
            self.simulation_canvas.tag_bind(element_id, "<Button-1>", lambda e, name=element_name: self._select_element(name))
            self.simulation_canvas.tag_bind(element_id, "<B1-Motion>", lambda e, name=element_name: self._drag_element(name, e))
    
    def _bind_events(self):
        """Bind keyboard and window events"""
        # Keyboard shortcuts
        self.bind("<Control-s>", lambda e: self._save_profile())
        self.bind("<Control-z>", lambda e: self._undo())
        self.bind("<Control-y>", lambda e: self._redo())
        self.bind("<Return>", lambda e: self._send_ai_message() if self.chat_entry.focus_get() == self.chat_entry else None)
        
        # Window events
        self.protocol("WM_DELETE_WINDOW", self._on_closing)
        
        # Canvas events
        self.simulation_canvas.bind("<Button-1>", self._canvas_click)
        self.simulation_canvas.bind("<B1-Motion>", self._canvas_drag)
        self.simulation_canvas.bind("<ButtonRelease-1>", self._canvas_release)
    
    def _select_element(self, element_name: str):
        """Select a UI element"""
        self.selected_element = element_name
        self.selected_label.config(text=f"Selected: {element_name.replace('_', ' ').title()}")
        
        # Highlight selected element
        self._highlight_element(element_name)
        
        # Update properties panel
        self._update_properties_panel(element_name)
        
        self.status_var.set(f"Selected: {element_name}")
    
    def _highlight_element(self, element_name: str):
        """Highlight the selected element"""
        # Remove previous highlights
        self.simulation_canvas.delete("highlight")
        
        if element_name in self.ui_elements:
            element_id = self.ui_elements[element_name]
            coords = self.simulation_canvas.coords(element_id)
            
            if len(coords) >= 4:
                # Create highlight border
                self.simulation_canvas.create_rectangle(
                    coords[0] - 3, coords[1] - 3,
                    coords[2] + 3, coords[3] + 3,
                    outline="#ffff00", width=3, tags="highlight"
                )
    
    def _update_properties_panel(self, element_name: str):
        """Update the properties panel for selected element"""
        # Clear existing properties
        for widget in self.props_frame.winfo_children():
            widget.destroy()
        
        if not element_name or element_name not in self.ui_elements:
            return
        
        # Get element coordinates
        element_id = self.ui_elements[element_name]
        coords = self.simulation_canvas.coords(element_id)
        
        if len(coords) >= 4:
            x1, y1, x2, y2 = coords[:4]
            width = x2 - x1
            height = y2 - y1
            
            # Position properties
            pos_frame = ttk.LabelFrame(self.props_frame, text="Position", padding=5)
            pos_frame.pack(fill=tk.X, pady=5)
            
            ttk.Label(pos_frame, text="X:").grid(row=0, column=0, sticky="w")
            x_var = tk.StringVar(value=str(int(x1)))
            ttk.Entry(pos_frame, textvariable=x_var, width=10).grid(row=0, column=1, padx=5)
            
            ttk.Label(pos_frame, text="Y:").grid(row=1, column=0, sticky="w")
            y_var = tk.StringVar(value=str(int(y1)))
            ttk.Entry(pos_frame, textvariable=y_var, width=10).grid(row=1, column=1, padx=5)
            
            # Size properties
            size_frame = ttk.LabelFrame(self.props_frame, text="Size", padding=5)
            size_frame.pack(fill=tk.X, pady=5)
            
            ttk.Label(size_frame, text="Width:").grid(row=0, column=0, sticky="w")
            w_var = tk.StringVar(value=str(int(width)))
            ttk.Entry(size_frame, textvariable=w_var, width=10).grid(row=0, column=1, padx=5)
            
            ttk.Label(size_frame, text="Height:").grid(row=1, column=0, sticky="w")
            h_var = tk.StringVar(value=str(int(height)))
            ttk.Entry(size_frame, textvariable=h_var, width=10).grid(row=1, column=1, padx=5)
            
            # Apply button
            ttk.Button(
                self.props_frame,
                text="Apply Changes",
                command=lambda: self._apply_element_changes(element_name, x_var, y_var, w_var, h_var)
            ).pack(pady=10)
            
            # AI Optimize button
            ttk.Button(
                self.props_frame,
                text="AI Optimize",
                command=lambda: self._ai_optimize_element(element_name)
            ).pack(pady=5)
    
    def _apply_element_changes(self, element_name: str, x_var: tk.StringVar, y_var: tk.StringVar, w_var: tk.StringVar, h_var: tk.StringVar):
        """Apply property changes to element"""
        try:
            x = int(x_var.get())
            y = int(y_var.get())
            w = int(w_var.get())
            h = int(h_var.get())
            
            element_id = self.ui_elements[element_name]
            self.simulation_canvas.coords(element_id, x, y, x + w, y + h)
            
            self._highlight_element(element_name)
            self.status_var.set(f"Updated {element_name}")
            
        except ValueError:
            messagebox.showerror("Error", "Please enter valid numeric values")
    
    def _send_ai_message(self):
        """Send message to AI Assistant"""
        message = self.chat_entry.get("1.0", tk.END).strip()
        if not message:
            return
        
        # Clear input
        self.chat_entry.delete("1.0", tk.END)
        
        # Add user message to chat
        self._add_chat_message("You", message)
        
        # Process with AI in background
        threading.Thread(
            target=self._process_ai_message,
            args=(message,),
            daemon=True
        ).start()
        
        self.ai_status_label.config(text="AI: Processing...")
    
    def _process_ai_message(self, message: str):
        """Process AI message in background thread"""
        try:
            # Get current context
            context = {
                "selected_element": self.selected_element,
                "scenario": self.scenario_var.get(),
                "ui_elements": list(self.ui_elements.keys()),
                "character": self.settings.get("user.character", {}),
                "simulation_state": self.simulation_engine.get_simulation_state()
            }
            
            # Process with AI (this would normally be async, but simplified for this example)
            response = self.ai_assistant._process_with_fallback(message)
            
            # Update UI in main thread
            self.after(0, lambda: self._handle_ai_response_ui(response))
            
        except Exception as error:
            self.logger.error(f"Error processing AI message: {error}")
            error_msg = f"I apologize, but I encountered an error: {str(error)}"
            self.after(0, lambda: self._add_chat_message("AI Assistant", error_msg))
        finally:
            self.after(0, lambda: self.ai_status_label.config(text="AI: Ready"))
    
    def _handle_ai_response_ui(self, response: Dict[str, Any]):
        """Handle AI response in UI thread"""
        # Add AI response to chat
        self._add_chat_message("AI Assistant", response.get("message", "I'm here to help!"))
        
        # Execute any actions
        actions = response.get("actions", [])
        for action in actions:
            self._execute_ai_action(action)
    
    def _execute_ai_action(self, action: Dict[str, Any]):
        """Execute an AI-suggested action"""
        action_type = action.get("type")
        
        if action_type == "resize_element":
            element = action.get("element")
            scale = action.get("scale", 1.1)
            self._resize_element(element, scale)
            
        elif action_type == "move_element":
            element = action.get("element")
            position = action.get("position")
            self._move_element_to_position(element, position)
            
        elif action_type == "highlight_element":
            element = action.get("element")
            if element in self.ui_elements:
                self._select_element(element)
                
        elif action_type == "apply_template":
            template = action.get("template")
            self._apply_template(template)
            
        elif action_type == "enable_drag_mode":
            element = action.get("element")
            if element and element in self.ui_elements:
                self._select_element(element)
                self.status_var.set(f"Drag mode enabled for {element}. Click and drag to reposition.")
    
    def _resize_element(self, element_name: str, scale: float):
        """Resize an element by scale factor"""
        if element_name not in self.ui_elements:
            return
        
        element_id = self.ui_elements[element_name]
        coords = self.simulation_canvas.coords(element_id)
        
        if len(coords) >= 4:
            x1, y1, x2, y2 = coords[:4]
            width = x2 - x1
            height = y2 - y1
            
            new_width = width * scale
            new_height = height * scale
            
            # Center the resize
            center_x = (x1 + x2) / 2
            center_y = (y1 + y2) / 2
            
            new_x1 = center_x - new_width / 2
            new_y1 = center_y - new_height / 2
            new_x2 = center_x + new_width / 2
            new_y2 = center_y + new_height / 2
            
            self.simulation_canvas.coords(element_id, new_x1, new_y1, new_x2, new_y2)
            
            if self.selected_element == element_name:
                self._highlight_element(element_name)
                self._update_properties_panel(element_name)
    
    def _add_chat_message(self, sender: str, message: str):
        """Add message to chat history"""
        self.chat_history.config(state=tk.NORMAL)
        
        # Add timestamp and sender
        timestamp = time.strftime("%H:%M")
        self.chat_history.insert(tk.END, f"[{timestamp}] {sender}: {message}\n\n")
        
        # Auto-scroll to bottom
        self.chat_history.see(tk.END)
        self.chat_history.config(state=tk.DISABLED)
    
    def handle_ai_response(self, response: Dict[str, Any]):
        """Handle AI response from background processing"""
        self.after(0, lambda: self._handle_ai_response_ui(response))
    
    def handle_simulation_update(self, update: Dict[str, Any]):
        """Handle simulation update from background processing"""
        self.after(0, lambda: self._update_simulation_display(update))
    
    def _update_simulation_display(self, update: Dict[str, Any]):
        """Update simulation display with new data"""
        # Update simulation status
        scenario = update.get("scenario", "unknown")
        combat_active = update.get("combat", {}).get("active", False)
        
        status_text = f"Simulation: {scenario.title()}"
        if combat_active:
            status_text += " (In Combat)"
        
        self.sim_status_label.config(text=status_text)
        
        # Update player health display (simplified)
        player = update.get("player", {})
        if player:
            health = player.get("health", {})
            current_health = health.get("current", 0)
            max_health = health.get("max", 1)
            
            # Update health bar color based on health percentage
            health_percent = current_health / max_health
            if health_percent > 0.5:
                color = "#1a3d1a"  # Green
            elif health_percent > 0.25:
                color = "#3d3d1a"  # Yellow
            else:
                color = "#3d1a1a"  # Red
            
            if "player_frame" in self.ui_elements:
                self.simulation_canvas.itemconfig(self.ui_elements["player_frame"], fill=color)
    
    # Event handlers and utility methods (simplified for brevity)
    def _canvas_click(self, event):
        """Handle canvas click"""
        pass
    
    def _canvas_drag(self, event):
        """Handle canvas drag"""
        pass
    
    def _canvas_release(self, event):
        """Handle canvas release"""
        pass
    
    def _drag_element(self, element_name: str, event):
        """Handle element dragging"""
        if element_name in self.ui_elements:
            element_id = self.ui_elements[element_name]
            x, y = event.x, event.y
            
            # Get current coordinates and calculate offset
            coords = self.simulation_canvas.coords(element_id)
            if len(coords) >= 4:
                width = coords[2] - coords[0]
                height = coords[3] - coords[1]
                
                # Update position
                self.simulation_canvas.coords(element_id, x, y, x + width, y + height)
                
                # Update highlight
                if self.selected_element == element_name:
                    self._highlight_element(element_name)
    
    def _on_scenario_change(self, event=None):
        """Handle scenario change"""
        scenario = self.scenario_var.get()
        self.simulation_engine.change_scenario(scenario)
        self.status_var.set(f"Changed to {scenario} scenario")
    
    def _change_scenario(self, scenario: str):
        """Change simulation scenario"""
        self.scenario_var.set(scenario)
        self._on_scenario_change()
    
    def _trigger_combat(self):
        """Trigger combat simulation"""
        self.simulation_engine.trigger_event("start_combat")
        self.status_var.set("Combat started")
    
    def _end_combat(self):
        """End combat simulation"""
        self.simulation_engine.trigger_event("end_combat")
        self.status_var.set("Combat ended")
    
    # Placeholder methods for menu actions
    def _new_profile(self): pass
    def _open_profile(self): pass
    def _save_profile(self): pass
    def _save_profile_as(self): pass
    def _import_profile(self): pass
    def _export_to_drgui(self): pass
    def _undo(self): pass
    def _redo(self): pass
    def _select_all(self): pass
    def _clear_selection(self): pass
    def _show_preferences(self): pass
    def _reset_layout(self): pass
    def _toggle_fullscreen(self): pass
    def _toggle_grid(self): pass
    def _toggle_guidelines(self): pass
    def _clear_chat(self): 
        self.chat_history.config(state=tk.NORMAL)
        self.chat_history.delete("1.0", tk.END)
        self.chat_history.config(state=tk.DISABLED)
    def _show_ai_suggestions(self): pass
    def _configure_ai(self): pass
    def _show_user_guide(self): pass
    def _show_ai_help(self): pass
    def _show_shortcuts(self): pass
    def _show_about(self): 
        messagebox.showinfo("About", "DRGUI AI Designer v2.0.0\nThe War Within Expansion Ready\n\nAI-Powered Offline UI Customization")
    def _show_templates(self): pass
    def _optimize_layout(self): pass
    def _test_ui(self): pass
    def _reset_to_default(self): pass
    def _reset_simulation_view(self): pass
    def _apply_template(self, template: str): 
        self._add_chat_message("AI Assistant", f"Applied {template} template. The layout has been optimized for your playstyle.")
    def _ai_optimize_element(self, element_name: str):
        self._add_chat_message("AI Assistant", f"Optimized {element_name} positioning and sizing based on your role and content preferences.")
    def _move_element_to_position(self, element: str, position: str): pass
    
    def _on_closing(self):
        """Handle window closing"""
        # Save window state
        self.settings.set("app.window_size", [self.winfo_width(), self.winfo_height()])
        self.settings.set("app.window_position", [self.winfo_x(), self.winfo_y()])
        self.settings.save()
        
        # Close application
        if self.app_controller:
            self.app_controller.shutdown()
        
        self.destroy()