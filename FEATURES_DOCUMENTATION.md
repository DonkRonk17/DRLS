# DRGUI Features Documentation

## Table of Contents
1. [Setup Wizard](#setup-wizard)
2. [Dependency Auto-Installer](#dependency-auto-installer)
3. [Profile Backup System](#profile-backup-system)
4. [UI Customization Options](#ui-customization-options)
5. [Script Launcher](#script-launcher)
6. [Slash Commands Reference](#slash-commands-reference)

---

## Setup Wizard

### Overview
The Setup Wizard guides new users through DRGUI installation and configuration.

### When It Appears
- Automatically on first login after installing DRGUI
- Can be manually triggered with `/drgui wizard`

### Wizard Steps

#### Step 1: Welcome
- Introduction to DRGUI features
- Overview of what the wizard will do
- Option to skip wizard

#### Step 2: Dependency Check
- Scans for required addons (ElvUI, Details!, WeakAuras)
- Checks optional addons (DBM, Masque, Bartender4, etc.)
- Provides installation options if dependencies are missing
- Direct link to auto-installer

#### Step 3: Profile Setup
- Auto-detects your character combo (Race/Class/Spec/Hero Talents)
- Creates unique profile for your combination
- Option to customize profile name

#### Step 4: Customization Options
- Choose UI style (Bushido, Action Packed, Elegant, Custom)
- Enable/disable proc animations
- Configure Details! integration

#### Step 5: Finish
- Summary of setup
- Quick tips for using DRGUI
- Links to documentation and support

### Commands
```
/drgui wizard - Show setup wizard
/drgui skipwizard - Mark wizard as completed (won't show again)
```

---

## Dependency Auto-Installer

### Overview
Automatically downloads and installs all DRGUI dependencies from CurseForge.

### Features
- **Smart Detection**: Auto-finds WoW installation directory
- **Selective Installation**: Choose required-only or all dependencies
- **Safe Mode**: Continues even if one addon fails
- **Progress Tracking**: Detailed progress for each download
- **Cleanup**: Removes temporary files after installation

### Installation Options

#### Option 1: Required Addons Only (Recommended)
```bash
python scripts/drgui_dependency_installer.py --required-only
```
Installs:
- ElvUI (UI framework)
- Details! (Damage meter)
- WeakAuras (Visual effects)

#### Option 2: All Dependencies
```bash
python scripts/drgui_dependency_installer.py
```
Installs all required + optional addons:
- DBM-Core (Boss warnings)
- Masque (Action bar skins)
- Bartender4 (Action bars)
- Plater (Nameplates)
- Hekili (Rotation helper)
- GuildRosterManager (Profile sharing)

### In-Game Integration
- Missing dependencies trigger helpful error messages
- Auto-installer instructions shown automatically
- Quick access via `/drgui install`

### Requirements
- Python 3.8 or higher
- Internet connection
- WoW must be closed during installation

### Troubleshooting
See AUTO_INSTALLER_GUIDE.txt for detailed troubleshooting steps.

---

## Profile Backup System

### Overview
Automatic and manual backup system for your UI profiles, ensuring you never lose your customizations.

### Features
- **Auto-Backup**: Hourly automatic backups
- **Logout Backup**: Saves on every logout
- **Profile Change Backup**: Saves when switching characters/specs
- **Manual Backup**: Create backups anytime
- **Backup Limit**: Keeps last 10 backups (configurable)
- **Backup Metadata**: Tracks date, character, realm, backup type
- **Export/Import**: Share profiles via strings

### Backup Types
1. **manual** - Created by user command
2. **auto** - Automatic hourly backup
3. **logout** - Created when logging out
4. **profile-change** - Created when switching profiles
5. **pre-restore** - Safety backup before restoring
6. **imported** - Imported from export string

### Commands

#### Create Backup
```
/drgui backup - Create manual backup
```

#### List Backups
```
/drgui backups - List all backups for current character
```

#### Restore Backup
```
/drgui restore <number> - Restore specific backup
```
Example: `/drgui restore 3`

#### Delete Backup
```
/drgui deletebackup <number> - Delete specific backup
```

#### Export Backup
```
/drgui exportbackup <number> - Export backup as string
```
Copy the generated string to share with others.

#### Import Backup
```
/drgui importbackup - Shows instructions for importing
```
Paste an export string to import a profile.

#### Backup Settings
```
/drgui backupsettings - Show current backup settings
/drgui toggleautobackup - Toggle automatic backups
/drgui togglelogoutbackup - Toggle logout backups
```

### Backup Settings
- **autoBackup**: Enable/disable hourly auto-backups (default: enabled)
- **backupOnLogout**: Backup when logging out (default: enabled)
- **backupOnProfileChange**: Backup when changing profiles (default: enabled)
- **backupInterval**: Time between auto-backups (default: 3600 seconds / 1 hour)
- **maxBackups**: Maximum backups to keep (default: 10)

### Storage Location
Backups are stored in:
```
WTF/Account/[AccountName]/SavedVariables/DRGUIDB.lua
```
Under the `backups` table.

---

## UI Customization Options

### Overview
In-game customization system for tweaking your UI appearance and behavior.

### UI Styles

#### Bushido (Minimalist)
- Clean, uncluttered interface
- Subtle animations
- Perfect for focusing on gameplay
- Default DRGUI style

#### Action Packed
- Bold, prominent UI elements
- Intense animations
- High-contrast colors
- Great for visibility in combat

#### Elegant
- Refined, sophisticated design
- Smooth animations
- Balanced aesthetics
- Professional appearance

#### Custom
- Full control over every setting
- Mix and match features
- Advanced customization

### Customization Options

#### Style
```
/drgui setstyle <bushido|action|elegant|custom>
```
Sets the overall UI style.

#### Animations
```
/drgui toggleanims - Toggle proc animations on/off
```
Controls whether ability procs trigger visual animations.

#### Font Size
```
/drgui fontsize <8-20>
```
Adjusts text size across the UI.
Example: `/drgui fontsize 14`

#### UI Scale
```
/drgui uiscale <0.5-1.5>
```
Scales the entire UI.
Example: `/drgui uiscale 1.2`

#### Apply Changes
```
/drgui apply - Apply all pending customization changes
```
After changing settings, use this to apply them (requires /reload).

#### View Current Settings
```
/drgui custom - Show current customization settings
```

### Quick Start
1. `/drgui custom` - View current settings
2. `/drgui setstyle action` - Choose a style
3. `/drgui fontsize 14` - Adjust font
4. `/drgui apply` - Apply changes
5. `/reload` - Reload UI to see changes

---

## Script Launcher

### Overview
In-game interface to launch external Python scripts for AI generation and advanced features.

### Available Scripts

#### 1. Dependency Installer
```
/drgui install
```
Shows commands to run the auto-installer.

#### 2. Code Generator
```
/drgui codegen
```
Shows commands to generate Lua/XML files via Grok-4 AI.

#### 3. Image Generator
```
/drgui imagegen
```
Shows commands to generate custom icons/borders via AI.

#### 4. AI Integrations
```
/drgui aihelp
```
Shows commands to get AI tips and narration.

### How It Works
1. Command displays the full Python command to run
2. User closes WoW
3. User runs the command in terminal/command prompt
4. Script generates files or provides information
5. User restarts WoW to see changes

### Example Workflow
```
In-game: /drgui codegen
Output: python Interface\AddOns\DRGUI_BK\scripts\drgui_code_gen.py "Human-Mage-Frost-1234"

Close WoW → Run command → Generated files → Restart WoW
```

---

## Slash Commands Reference

### Main Commands
```
/drgui - Show main help menu
/drgui help - Detailed command list
```

### Setup & Configuration
```
/drgui wizard - Show setup wizard
/drgui deps - Check dependencies
/drgui install - Show auto-installer instructions
```

### Profile Management
```
/drgui export - Export current profile
/drgui backup - Create backup
/drgui backups - List backups
/drgui restore <number> - Restore backup
```

### Customization
```
/drgui custom - Show customization options
/drgui setstyle <style> - Set UI style
/drgui toggleanims - Toggle animations
/drgui fontsize <size> - Set font size
/drgui uiscale <scale> - Set UI scale
/drgui apply - Apply changes
```

### Scripts & Tools
```
/drgui codegen - Show code generator command
/drgui imagegen - Show image generator command
/drgui aihelp - Show AI integration command
```

### Debug & Advanced
```
/drgui debug - Toggle debug mode
/drgui config - Open advanced config
/drgui reload - Reload UI (/reload)
```

---

## Tips & Best Practices

### For New Users
1. Run setup wizard on first login
2. Install dependencies via auto-installer
3. Start with Bushido style
4. Create manual backup after customization
5. Use `/drgui help` to learn commands

### For Advanced Users
1. Enable debug mode for troubleshooting
2. Use custom style for full control
3. Export backups before major changes
4. Leverage AI scripts for unique content
5. Share profiles via export strings

### Performance Tips
- Disable animations if experiencing lag
- Use lower UI scale on small monitors
- Keep auto-backup interval at 1 hour minimum
- Limit max backups to 10 or less

### Backup Strategy
- Create manual backup before major changes
- Keep logout backups enabled
- Regularly export important profiles
- Test restore function periodically

---

## Support & Resources

### In-Game Help
```
/drgui help - Command reference
/drgui wizard - Guided setup
```

### Documentation
- ReadMe.txt - Quick start guide
- AUTO_INSTALLER_GUIDE.txt - Installation help
- FEATURES_DOCUMENTATION.md - This file

### Community Support
- Reddit: /r/wow, /r/wownoob
- Blizzard Forums: https://us.forums.blizzard.com/en/wow/
- Class Discords: https://www.icy-veins.com/forums/topic/16114-class-discord-channels/

### External Resources
- Icy Veins: https://www.icy-veins.com/wow/
- Wowhead: https://www.wowhead.com/
- Raider.IO: https://raider.io/
- WoWUp.io: https://wowup.io/

---

## Changelog

### Version 1.0 (Current)
- ✓ Setup Wizard
- ✓ Auto-Installer
- ✓ Profile Backup System
- ✓ UI Customization
- ✓ Script Launcher
- ✓ Complete Documentation

---

*Last Updated: 2025-10-16*
*DRGUI - DonkRonk & Grok User Interface*
