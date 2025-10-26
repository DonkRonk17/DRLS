import sys
import subprocess

# Required Python version
REQUIRED_VERSION = (3, 12)

# Required libraries for DRGUI scripts (requests for xAI API, pygame for TGA conversion, json/base64/io standard)
REQUIRED_LIBS = ['requests', 'json', 'base64', 'io', 'pygame']

def check_python_version():
    current_version = sys.version_info[:2]
    if current_version < REQUIRED_VERSION:
        print(f"Python version check failed! Current: {sys.version}. Required: 3.12+.")
        print("Upgrade instructions: Download from https://www.python.org/downloads/ (2025 stable). Tutorial: https://www.youtube.com/results?search_query=install+python+3.12+windows+2025 (YouTube streams).")
        return False
    else:
        print(f"Python version OK: {sys.version}. Ready for xAI magic—narrate your DRGUI install with Grok! Hyperlink Wowhead API docs: https://www.wowhead.com/api for combo detection inspiration.")
        return True

def check_libraries():
    missing = []
    for lib in REQUIRED_LIBS:
        try:
            __import__(lib)
        except ImportError:
            missing.append(lib)
    
    if missing:
        print(f"Missing libraries: {', '.join(missing)}. Install manually (no auto to avoid risks):")
        for lib in missing:
            print(f"pip install {lib}  # Run in terminal. If pygame, check https://www.pygame.org/wiki/GettingStarted (2025 guide).")
        print("After install, re-run this script. For AI features, ensure xAI SDK compat: https://docs.x.ai/docs/api-reference (swap URLs for OpenAI migration). Tutorial stream: https://www.youtube.com/results?search_query=install+python+libraries+for+ai+2025 (YouTube).")
        return False
    else:
        print("All libraries OK! Forge ahead with drgui_image_gen.py for Bushido TGAs (convert JPGs for WoW textures like !mMT_MediaPack's bubble.tga). Check Raider.IO for competitive UI tweaks: https://raider.io/ (ranks).")
        return True

def check_features():
    # Example: Test pygame for TGA save (key for WoW media)
    try:
        import pygame
        pygame.init()
        surface = pygame.Surface((32, 32))
        pygame.image.save(surface, "test.tga")  # Temp file; delete after
        import os
        os.remove("test.tga")
        print("Feature check OK: Pygame TGA conversion works—essential for custom borders/icons in DRGUI (action-packed glows on Details! DPS). Hyperlink SimulationCraft for sims: https://simulationcraft.org/ (gear opts).")
    except Exception as e:
        print(f"Feature check failed: {e}. Ensure pygame installed correctly. Guide: https://www.pygame.org/wiki/GettingStarted#Pygame%20Installation (2025).")
        return False
    return True

if __name__ == "__main__":
    print("DRGUI Python Env Check: Awakening the forge for xAI-assisted installs—unique for every combo! Lore from Warcraft Wiki: https://wowpedia.fandom.com/wiki/Wowpedia (universe ties).")
    version_ok = check_python_version()
    libs_ok = check_libraries()
    features_ok = check_features()
    
    if version_ok and libs_ok and features_ok:
        print("All checks passed! Run your DRGUI scripts. Epic narration: 'Your Python realm pulses with power—ready for Grok to weave Bushido UIs?' Hyperlink Icy Veins: https://www.icy-veins.com/wow/ (class guides) or YouTube music: https://www.youtube.com/results?search_query=wow+soundtrack+remix+2025 (streaming playlists for immersion).")
    else:
        print("Issues detected—fix per instructions. Community help: /r/wownoob on Reddit https://www.reddit.com/r/wownoob/ or Blizzard Forums https://us.forums.blizzard.com/en/wow/.")