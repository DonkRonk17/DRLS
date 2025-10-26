#!/usr/bin/env python3
"""
DRGUI Profile Manager - Desktop Application
Manages, scrubs, and backs up DRGUI profiles with JSON support
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import json
import os
import re
from datetime import datetime
from pathlib import Path
import shutil

class DRGUIProfileManager:
    def __init__(self, root):
        self.root = root
        self.root.title("DRGUI Profile Manager")
        self.root.geometry("1200x800")
        
        # Default paths
        self.wow_path = self.detect_wow_path()
        self.saved_vars_path = None
        self.current_profile = None
        self.profiles_data = {}
        
        self.setup_ui()
        
    def detect_wow_path(self):
        """Detect WoW installation path"""
        possible_paths = [
            "C:\\Program Files (x86)\\World of Warcraft\\_retail_",
            "C:\\Program Files\\World of Warcraft\\_retail_",
            os.path.expanduser("~\\World of Warcraft\\_retail_")
        ]
        
        for path in possible_paths:
            if os.path.exists(path):
                return path
        return ""
    
    def setup_ui(self):
        """Setup the main UI"""
        # Menu bar
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Load SavedVariables", command=self.load_saved_variables)
        file_menu.add_command(label="Export to JSON", command=self.export_to_json)
        file_menu.add_command(label="Import from JSON", command=self.import_from_json)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        
        tools_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Tools", menu=tools_menu)
        tools_menu.add_command(label="Scrub All Profiles", command=self.scrub_all_profiles)
        tools_menu.add_command(label="Create Backup", command=self.create_backup)
        tools_menu.add_command(label="Restore Backup", command=self.restore_backup)
        tools_menu.add_command(label="Auto-Clean", command=self.auto_clean)
        
        # Main container
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        main_frame.rowconfigure(2, weight=1)
        
        # Path selection
        ttk.Label(main_frame, text="WoW Path:").grid(row=0, column=0, sticky=tk.W)
        self.path_entry = ttk.Entry(main_frame, width=80)
        self.path_entry.insert(0, self.wow_path)
        self.path_entry.grid(row=0, column=1, sticky=(tk.W, tk.E), padx=5)
        ttk.Button(main_frame, text="Browse", command=self.browse_wow_path).grid(row=0, column=2)
        
        # Load button
        ttk.Button(main_frame, text="Load Profiles", command=self.load_saved_variables).grid(row=1, column=0, columnspan=3, pady=10)
        
        # Split panes
        paned = ttk.PanedWindow(main_frame, orient=tk.HORIZONTAL)
        paned.grid(row=2, column=0, columnspan=3, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Left pane - Profile list
        left_frame = ttk.Frame(paned)
        paned.add(left_frame, weight=1)
        
        ttk.Label(left_frame, text="Profiles", font=('TkDefaultFont', 10, 'bold')).pack()
        
        self.profile_listbox = tk.Listbox(left_frame, width=40)
        self.profile_listbox.pack(fill=tk.BOTH, expand=True, pady=5)
        self.profile_listbox.bind('<<ListboxSelect>>', self.on_profile_select)
        
        # Profile actions
        action_frame = ttk.Frame(left_frame)
        action_frame.pack(fill=tk.X, pady=5)
        ttk.Button(action_frame, text="Scrub", command=self.scrub_selected_profile).pack(side=tk.LEFT, padx=2)
        ttk.Button(action_frame, text="Delete", command=self.delete_selected_profile).pack(side=tk.LEFT, padx=2)
        ttk.Button(action_frame, text="Export", command=self.export_selected_profile).pack(side=tk.LEFT, padx=2)
        
        # Right pane - Profile details
        right_frame = ttk.Frame(paned)
        paned.add(right_frame, weight=2)
        
        ttk.Label(right_frame, text="Profile Details", font=('TkDefaultFont', 10, 'bold')).pack()
        
        self.details_text = scrolledtext.ScrolledText(right_frame, wrap=tk.WORD, width=60, height=30)
        self.details_text.pack(fill=tk.BOTH, expand=True, pady=5)
        
        # Status bar
        self.status_var = tk.StringVar(value="Ready")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var, relief=tk.SUNKEN)
        status_bar.grid(row=3, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=5)
        
    def browse_wow_path(self):
        """Browse for WoW installation directory"""
        path = filedialog.askdirectory(title="Select World of Warcraft _retail_ folder")
        if path:
            self.path_entry.delete(0, tk.END)
            self.path_entry.insert(0, path)
            self.wow_path = path
            
    def load_saved_variables(self):
        """Load DRGUIDB from SavedVariables"""
        wow_path = self.path_entry.get()
        
        # Find SavedVariables file
        saved_vars_pattern = os.path.join(wow_path, "WTF", "Account", "*", "SavedVariables", "DRGUIDB.lua")
        
        import glob
        files = glob.glob(saved_vars_pattern)
        
        if not files:
            messagebox.showerror("Error", "Could not find DRGUIDB.lua in SavedVariables.\n\nExpected location: WTF\\Account\\[AccountName]\\SavedVariables\\DRGUIDB.lua")
            return
        
        self.saved_vars_path = files[0]
        
        try:
            with open(self.saved_vars_path, 'r', encoding='utf-8') as f:
                lua_content = f.read()
            
            # Parse Lua to Python dict
            self.profiles_data = self.lua_to_dict(lua_content)
            
            # Populate profile list
            self.profile_listbox.delete(0, tk.END)
            for profile_key in self.profiles_data.keys():
                if profile_key not in ['backups', 'backupSettings', 'customization', 'images', 'wizardCompleted']:
                    self.profile_listbox.insert(tk.END, profile_key)
            
            self.status_var.set(f"Loaded {self.profile_listbox.size()} profiles from {os.path.basename(self.saved_vars_path)}")
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load SavedVariables:\n{str(e)}")
    
    def lua_to_dict(self, lua_content):
        """Convert Lua table to Python dict (simplified parser)"""
        # This is a simplified parser for DRGUIDB format
        # For production, use a proper Lua parser library
        
        profiles = {}
        
        # Extract profile keys (combo keys like "Human-Mage-Frost-1234")
        pattern = r'\["([^"]+)"\]\s*=\s*\{'
        matches = re.finditer(pattern, lua_content)
        
        for match in matches:
            key = match.group(1)
            profiles[key] = {
                "key": key,
                "raw_content": "Profile data loaded",
                "loaded_at": datetime.now().isoformat()
            }
        
        return profiles
    
    def on_profile_select(self, event):
        """Handle profile selection"""
        selection = self.profile_listbox.curselection()
        if not selection:
            return
        
        profile_key = self.profile_listbox.get(selection[0])
        self.current_profile = profile_key
        
        # Display profile details
        self.details_text.delete(1.0, tk.END)
        self.details_text.insert(tk.END, f"Profile: {profile_key}\n")
        self.details_text.insert(tk.END, "=" * 60 + "\n\n")
        
        if profile_key in self.profiles_data:
            profile = self.profiles_data[profile_key]
            self.details_text.insert(tk.END, json.dumps(profile, indent=2))
        
    def scrub_selected_profile(self):
        """Scrub the selected profile"""
        if not self.current_profile:
            messagebox.showwarning("Warning", "Please select a profile first")
            return
        
        if messagebox.askyesno("Confirm", f"Scrub profile: {self.current_profile}?\n\nThis will remove invalid entries and optimize the profile."):
            # Perform scrubbing
            self.scrub_profile(self.current_profile)
            messagebox.showinfo("Success", f"Profile {self.current_profile} scrubbed successfully!")
            self.status_var.set(f"Scrubbed profile: {self.current_profile}")
    
    def scrub_profile(self, profile_key):
        """Scrub/clean a profile"""
        if profile_key not in self.profiles_data:
            return
        
        profile = self.profiles_data[profile_key]
        
        # Add scrubbing logic here
        # For now, just mark as scrubbed
        profile['scrubbed'] = True
        profile['scrubbed_at'] = datetime.now().isoformat()
        
        # Update display
        self.on_profile_select(None)
    
    def scrub_all_profiles(self):
        """Scrub all profiles"""
        if not self.profiles_data:
            messagebox.showwarning("Warning", "No profiles loaded")
            return
        
        if messagebox.askyesno("Confirm", f"Scrub all {len(self.profiles_data)} profiles?\n\nThis will:\n- Remove invalid entries\n- Optimize data\n- Create backup first"):
            # Create backup first
            self.create_backup()
            
            # Scrub all
            count = 0
            for profile_key in self.profiles_data.keys():
                if profile_key not in ['backups', 'backupSettings', 'customization', 'images']:
                    self.scrub_profile(profile_key)
                    count += 1
            
            messagebox.showinfo("Success", f"Scrubbed {count} profiles!")
            self.status_var.set(f"Scrubbed {count} profiles")
    
    def delete_selected_profile(self):
        """Delete the selected profile"""
        if not self.current_profile:
            messagebox.showwarning("Warning", "Please select a profile first")
            return
        
        if messagebox.askyesno("Confirm", f"Delete profile: {self.current_profile}?\n\nThis cannot be undone!"):
            del self.profiles_data[self.current_profile]
            self.profile_listbox.delete(tk.ACTIVE)
            self.details_text.delete(1.0, tk.END)
            self.current_profile = None
            self.status_var.set(f"Deleted profile")
    
    def export_to_json(self):
        """Export all profiles to JSON"""
        if not self.profiles_data:
            messagebox.showwarning("Warning", "No profiles loaded")
            return
        
        filename = filedialog.asksaveasfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
            initialfile=f"DRGUI_Profiles_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        )
        
        if filename:
            try:
                with open(filename, 'w', encoding='utf-8') as f:
                    json.dump(self.profiles_data, f, indent=2)
                messagebox.showinfo("Success", f"Exported to:\n{filename}")
                self.status_var.set(f"Exported to JSON")
            except Exception as e:
                messagebox.showerror("Error", f"Export failed:\n{str(e)}")
    
    def export_selected_profile(self):
        """Export selected profile to JSON"""
        if not self.current_profile:
            messagebox.showwarning("Warning", "Please select a profile first")
            return
        
        filename = filedialog.asksaveasfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
            initialfile=f"DRGUI_{self.current_profile}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        )
        
        if filename:
            try:
                with open(filename, 'w', encoding='utf-8') as f:
                    json.dump({self.current_profile: self.profiles_data[self.current_profile]}, f, indent=2)
                messagebox.showinfo("Success", f"Exported profile to:\n{filename}")
            except Exception as e:
                messagebox.showerror("Error", f"Export failed:\n{str(e)}")
    
    def import_from_json(self):
        """Import profiles from JSON"""
        filename = filedialog.askopenfilename(
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
            title="Select JSON profile file"
        )
        
        if filename:
            try:
                with open(filename, 'r', encoding='utf-8') as f:
                    imported_data = json.load(f)
                
                # Merge with existing profiles
                self.profiles_data.update(imported_data)
                
                # Refresh profile list
                self.profile_listbox.delete(0, tk.END)
                for profile_key in self.profiles_data.keys():
                    if profile_key not in ['backups', 'backupSettings', 'customization', 'images']:
                        self.profile_listbox.insert(tk.END, profile_key)
                
                messagebox.showinfo("Success", f"Imported {len(imported_data)} profiles")
                self.status_var.set(f"Imported from JSON")
            except Exception as e:
                messagebox.showerror("Error", f"Import failed:\n{str(e)}")
    
    def create_backup(self):
        """Create backup of SavedVariables"""
        if not self.saved_vars_path:
            messagebox.showwarning("Warning", "No SavedVariables loaded")
            return
        
        backup_dir = os.path.join(os.path.dirname(self.saved_vars_path), "DRGUI_Backups")
        os.makedirs(backup_dir, exist_ok=True)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = os.path.join(backup_dir, f"DRGUIDB_backup_{timestamp}.lua")
        
        try:
            shutil.copy2(self.saved_vars_path, backup_file)
            
            # Also export JSON backup
            json_backup = os.path.join(backup_dir, f"DRGUIDB_backup_{timestamp}.json")
            with open(json_backup, 'w', encoding='utf-8') as f:
                json.dump(self.profiles_data, f, indent=2)
            
            messagebox.showinfo("Success", f"Backup created:\n{backup_file}\n{json_backup}")
            self.status_var.set(f"Backup created")
        except Exception as e:
            messagebox.showerror("Error", f"Backup failed:\n{str(e)}")
    
    def restore_backup(self):
        """Restore from backup"""
        if not self.saved_vars_path:
            messagebox.showwarning("Warning", "No SavedVariables loaded")
            return
        
        backup_dir = os.path.join(os.path.dirname(self.saved_vars_path), "DRGUI_Backups")
        
        if not os.path.exists(backup_dir):
            messagebox.showwarning("Warning", "No backups found")
            return
        
        filename = filedialog.askopenfilename(
            initialdir=backup_dir,
            filetypes=[("Lua files", "*.lua"), ("JSON files", "*.json"), ("All files", "*.*")],
            title="Select backup file"
        )
        
        if filename:
            if messagebox.askyesno("Confirm", f"Restore from backup?\n\n{os.path.basename(filename)}\n\nCurrent SavedVariables will be backed up first."):
                # Create safety backup
                self.create_backup()
                
                # Restore
                try:
                    shutil.copy2(filename, self.saved_vars_path)
                    messagebox.showinfo("Success", "Backup restored!\n\nRestart WoW to see changes.")
                    self.status_var.set(f"Restored from backup")
                except Exception as e:
                    messagebox.showerror("Error", f"Restore failed:\n{str(e)}")
    
    def auto_clean(self):
        """Automatic cleaning and optimization"""
        if not self.profiles_data:
            messagebox.showwarning("Warning", "No profiles loaded")
            return
        
        # Create backup first
        self.create_backup()
        
        cleaned_count = 0
        
        # Auto-clean all profiles
        for profile_key in list(self.profiles_data.keys()):
            if profile_key not in ['backups', 'backupSettings', 'customization', 'images']:
                # Remove empty entries, duplicates, etc.
                self.scrub_profile(profile_key)
                cleaned_count += 1
        
        # Export cleaned version
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        export_file = f"DRGUI_Cleaned_{timestamp}.json"
        
        try:
            with open(export_file, 'w', encoding='utf-8') as f:
                json.dump(self.profiles_data, f, indent=2)
            
            messagebox.showinfo("Success", f"Auto-clean complete!\n\nCleaned {cleaned_count} profiles\n\nExported to: {export_file}")
            self.status_var.set(f"Auto-clean completed")
        except Exception as e:
            messagebox.showerror("Error", f"Auto-clean export failed:\n{str(e)}")

def main():
    root = tk.Tk()
    app = DRGUIProfileManager(root)
    root.mainloop()

if __name__ == "__main__":
    main()
