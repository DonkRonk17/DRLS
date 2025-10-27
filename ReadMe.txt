DRGUI - DonkRonk & Grok User Interface

Overview:
ElvUI-based addon for unique, minimalistic, cartoony Bushido-style UIs per race/class/spec/hero combo. Autodetects on login/changes via WoW API (UnitRace, UnitClass, GetSpecializationInfo, C_ClassTalents.GetActiveHeroTalentSpec). Integrates addons like Details! (real-time stats, WarcraftLogs hyperlinks), WeakAuras (animations, Wago.io imports), Masque (icons/borders), DBM/BigWigs (alerts), Hekili (rotations), BetterWardrobe (mog sync), MDT (dungeon paths), Raider.IO (rankings). xAI assistance via external Python (Grok-4 queries for narrations/tips/file gen—use key: YOUR_XAI_API_KEY_HERE). Profiles save/export via GRM (strings in chat/HTML). Creative features: Animations glow on procs (FragUI V2), borders evolve with Details! logs (pulse on kills, sim on Raidbots), AI in-game pasted into Prat/WIM (narrations from Warcraft Wiki lore). Hyperlinks: Icy Veins guides, Wowhead DB, MMO-Champion news, Blizzard Watch editorials, CurseForge/WoWInterface addons, WoWUp.io manager, Undermine Exchange economy, Saddlebag Exchange gold-making, WarcraftPets battle pets, /r/wow & /r/wownoob Reddit, Blizzard Forums, WoW Armory profiles, Battle.net official, class Discords (via Wowhead list), YouTube tutorials/streams/music (e.g., "wow ui setup 2025").

Install:
1. Place DRGUI folder in Interface/AddOns/
2. Install Dependencies (REQUIRED):
   
   OPTION A - AUTO-INSTALLER (RECOMMENDED):
   - Close World of Warcraft
   - Open Command Prompt or PowerShell
   - Navigate to: cd "C:\Program Files (x86)\Battle.net\World of Warcraft\_retail_\Interface\AddOns\DRGUI"
   - Run: python scripts/drgui_dependency_installer.py --required-only
   - Restart WoW and enable installed addons
   
   OPTION B - MANUAL INSTALL:
   - Download from CurseForge or WoWInterface:
     * ElvUI (required)
     * Details! Damage Meter (required)
     * WeakAuras (required)
     * DBM-Core, Masque, Bartender4, Plater, Hekili, GuildRosterManager (optional)
   
   OPTION C - WOWUP.IO:
   - Download WoWUp.io addon manager: https://wowup.io/
   - Search and install all dependencies with one click

3. Launch WoW and enable DRGUI + dependencies at character select
4. Enter game and type /reload
5. DRGUI will auto-detect your race/class/spec/hero talents
6. Missing files? Run scripts/drgui_code_gen.py or drgui_image_gen.py (Python 3.12+)
7. Export profiles via /drgui export

In-Game Commands:
- /drgui help - Show all available commands
- /drgui deps - Check dependency status
- /drgui install - Show auto-installer instructions
- /drgui debug - Toggle debug mode
- /drgui export - Export current profile

Testing:
 /reload for changes. Simulate combos (create alts). Check conflicts (disable ElvUI nameplates for Plater). Use SimulationCraft for gear sims (hyperlink Raidbots). Share zips on Google Drive/Dropbox/GitHub.

Resources:
- GitHub: https://github.com/DonkRonk/AddOns.git
- Wowhead API: https://www.wowhead.com/api
- Class Discords: https://www.icy-veins.com/forums/topic/16114-class-discord-channels/
- YouTube Playlist: https://www.youtube.com/playlist?list=PLYWsqa12Q6pPNlpDm5ylqZxzCa5MOvwTR (Awesome Addons)

xAI Setup:
Run Python scripts with comboKey (from print). Generates Lua/XML/TGAs on demand, narrates epicly. Costs ~$0.07/query (SuperGrok sub). Fallbacks borrow from AddOns (e.g., !ClassColors for tints).

Contact: Post on /r/wow or Blizzard Forums for feedback.

Testing Guide:
1. /reload for changes.
2. Simulate combos (alts for race/class/spec/hero).
3. Debug errors with prints; performance via Details! (hyperlink WarcraftLogs |Hurl:https://www.warcraftlogs.com/|h[Logs]|h).
4. Test AI: Run Python, paste in panels (narrations from Blizzard Watch |Hurl:https://blizzardwatch.com/|h[Blizzard Watch]|h).
5. Feedback: Post on /r/wow |Hurl:https://www.reddit.com/r/wow/|h[/r/wow]|h or class Discords |Hurl:https://www.icy-veins.com/forums/topic/16114-class-discord-channels/|h[Class Discords]|h.
6. Cross-test expansions (toggle .toc); edge cases like pet battles (WarcraftPets |Hurl:https://www.warcraftpets.com/|h[WarcraftPets]|h).
