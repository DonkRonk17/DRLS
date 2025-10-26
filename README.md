# DRGUI - DonkRonk & Grok User Interface

![Version](https://img.shields.io/badge/version-1.0-blue.svg)
![WoW](https://img.shields.io/badge/WoW-11.0.2-orange.svg)
![Python](https://img.shields.io/badge/python-3.7+-green.svg)
![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)

**Elite World of Warcraft UI addon with AI integration and desktop profile manager**

DRGUI is a comprehensive ElvUI-based addon that creates unique, minimalistic, cartoony Bushido-style user interfaces for every race/class/spec/hero talent combination in World of Warcraft. It features automatic detection, extensive addon integrations, AI assistance, and a powerful desktop application for profile management.

## ✨ Features

### 🎮 WoW Addon Features
- **Auto-Detection**: Automatically detects and loads appropriate UI based on race/class/spec/hero talents
- **ElvUI Integration**: Built on ElvUI foundation with custom styling
- **Extensive Addon Support**: Integrates with 25+ popular addons including:
  - Details! (with WarcraftLogs hyperlinks)
  - WeakAuras (with Wago.io imports)
  - DBM/BigWigs (alert customization)
  - Hekili (rotation optimization)
  - Plater (nameplate styling)
  - And many more!
- **AI Integration**: xAI Grok assistance for in-game narrations and tips
- **Profile Export/Import**: Share profiles via GRM strings or JSON files
- **Creative Features**: 
  - Animated glows on ability procs
  - Borders that evolve with combat performance
  - Hyperlinked resources (guides, databases, tools)

### 🖥️ Desktop Application
- **Profile Manager**: Comprehensive GUI for managing DRGUI profiles
- **JSON Support**: Export/import profiles in JSON format
- **Auto-Scrubbing**: Clean and optimize profile data
- **Backup System**: Automatic backups with restore functionality
- **Cross-Platform**: Windows executable with Python source

## 📦 Installation

### Quick Install (Recommended)

#### Option A: Auto-Installer
1. Close World of Warcraft
2. Download and extract DRGUI to your AddOns folder
3. Open Command Prompt/PowerShell and navigate to the DRGUI folder:
   ```bash
   cd "C:\Program Files (x86)\Battle.net\World of Warcraft\_retail_\Interface\AddOns\DRGUI_BK"
   ```
4. Run the auto-installer:
   ```bash
   python scripts/drgui_dependency_installer.py --required-only
   ```
5. Restart WoW and enable all installed addons

#### Option B: WoWUp.io (Easiest)
1. Download [WoWUp.io](https://wowup.io/)
2. Install DRGUI and all dependencies with one click
3. Launch WoW and enable addons

### Manual Installation

#### Required Dependencies
- **ElvUI** (Core requirement)
- **Details! Damage Meter** (Combat statistics)
- **WeakAuras** (Custom animations)

#### Optional Dependencies
- DBM-Core or BigWigs (Boss encounters)
- Masque (Icon customization)
- Bartender4 (Action bars)
- Plater (Nameplates)
- Hekili (Rotations)
- And 15+ more supported addons

### Desktop Application
1. Download `DRGUI_Profile_Manager.exe` from [Releases](../../releases)
2. Run the executable - no installation required!
3. Point to your WoW installation directory
4. Manage your profiles with ease

## 🚀 Quick Start

### First Launch
1. Start World of Warcraft
2. Enable DRGUI and dependencies at character select
3. Enter the game and type `/reload`
4. DRGUI will auto-detect your character and load the appropriate profile
5. Type `/drgui help` for all available commands

### In-Game Commands
```
/drgui help          - Show all available commands
/drgui deps          - Check dependency status
/drgui install       - Show auto-installer instructions
/drgui debug         - Toggle debug mode
/drgui export        - Export current profile
/drgui reload        - Reload UI configuration
```

### Desktop Profile Manager
1. Launch `DRGUI_Profile_Manager.exe`
2. Browse to your WoW installation folder
3. Click "Load Profiles" to import your SavedVariables
4. Use the GUI to:
   - View and edit profiles
   - Export/import JSON files
   - Create backups
   - Scrub and optimize data

## 🛠️ Development

### Building the Desktop Application
Build the standalone executable using the included script:

```bash
cd scripts
python build_exe.py
```

The compiled executable will be in `scripts/dist/DRGUI_Profile_Manager.exe`.

### Python Requirements
```bash
pip install -r requirements.txt
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with multiple race/class combinations
5. Submit a pull request

## 📖 Documentation

### Comprehensive Guides
- [📋 Feature Documentation](FEATURES_DOCUMENTATION.md)
- [🏗️ Build Executable Guide](BUILD_EXECUTABLE_GUIDE.md)
- [👤 Profile Manager Guide](PROFILE_MANAGER_GUIDE.md)
- [🧪 Testing Guide](TESTING_GUIDE.md)
- [📦 Auto-Installer Guide](AUTO_INSTALLER_GUIDE.txt)

### API Integration
- **xAI Integration**: Uses Grok-4 for AI-powered features
- **Wowhead API**: Real-time data integration
- **Battle.net API**: Character information

## 🔗 Resources

### Essential Links
- **WoW Resources**
  - [Wowhead Database](https://www.wowhead.com/)
  - [Icy Veins Guides](https://www.icy-veins.com/)
  - [WarcraftLogs](https://www.warcraftlogs.com/)
  - [Raider.IO](https://raider.io/)

- **Addon Management**
  - [WoWUp.io](https://wowup.io/)
  - [CurseForge](https://www.curseforge.com/wow/addons)
  - [WoWInterface](https://www.wowinterface.com/)

- **Community**
  - [Class Discord Channels](https://www.icy-veins.com/forums/topic/16114-class-discord-channels/)
  - [r/wow Subreddit](https://www.reddit.com/r/wow/)
  - [Blizzard Forums](https://us.forums.blizzard.com/en/wow/)

## 🧪 Testing

### Addon Testing
1. Create test characters of different races/classes
2. Use `/reload` after making changes
3. Test with various spec and hero talent combinations
4. Verify addon integrations work correctly
5. Check performance with Details! integration

### Desktop App Testing
1. Test with actual SavedVariables files
2. Verify JSON export/import functionality
3. Test backup and restore features
4. Validate profile scrubbing
5. Test on different Windows versions

## ❓ Troubleshooting

### Common Issues

**Addon won't load**
- Ensure ElvUI is installed and enabled first
- Check that DRGUI.toc version matches your WoW version
- Verify all dependencies are installed

**Profile not detected**
- Type `/reload` to refresh detection
- Check that you're in a supported spec
- Verify hero talents are properly configured

**Desktop app errors**
- Ensure Python 3.7+ is installed (for source version)
- Check WoW path is correct
- Verify SavedVariables file exists

**AI features not working**
- Check xAI API key configuration
- Ensure Python scripts have internet access
- Verify Grok subscription is active

### Getting Help
1. Check the [Issues](../../issues) page for known problems
2. Search [existing discussions](../../discussions)
3. Post on [r/wow](https://www.reddit.com/r/wow/) with DRGUI tag
4. Join relevant class Discord channels

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Acknowledgments

- **ElvUI Team** - Foundation framework
- **xAI/Grok** - AI integration capabilities
- **WoW Addon Community** - Inspiration and support
- **All Addon Developers** - Creating the tools we integrate with

## 📊 Stats

- **25+ Addon Integrations**
- **12 Race Combinations**
- **13 Class Combinations** 
- **40+ Specializations**
- **Multiple Hero Talent Trees**
- **1000+ Possible UI Combinations**

---

**Made with ❤️ by DonkRonk17**

*For the Horde! For the Alliance! For Epic UIs!*

## 🔄 Recent Updates

### Version 1.0 (October 2025)
- Initial production release
- Complete ElvUI integration
- Desktop profile manager
- Auto-installer system
- AI integration with xAI Grok
- Comprehensive addon support
- JSON export/import system
- Automatic backup system

---

### 🚀 Quick Links
- [📥 Download Latest Release](../../releases/latest)
- [📖 Full Documentation](../../wiki)
- [🐛 Report Issues](../../issues/new)
- [💬 Discussions](../../discussions)
- [🔄 Changelog](../../releases)