import requests
import json
import sys

API_KEY = "YOUR_XAI_API_KEY_HERE"
API_URL = "https://api.x.ai/v1/chat/completions"  # From docs.x.ai

def generate_file(combo, file_type="lua", file_name="alerts_hook.lua"):
    prompt = f"Generate {file_type} code for DRGUI addon file: {file_name}. Bushido style for combo {combo}, action-packed, lore from Warcraft Wiki. Integrate DBM alerts with hyperlinks to MMO-Champion/Icy Veins/Raider.IO. Output full code with comments."
    
    payload = {"model": "grok-4", "messages": [{"role": "user", "content": prompt}]}
    response = requests.post(API_URL, headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}, data=json.dumps(payload))
    
    if response.status_code == 200:
        code = response.json()['choices'][0]['message']['content']
        with open(file_name, "w") as f:
            f.write(code)
        print(f"Generated {file_name}: Paste narration in WoW. Check YouTube: https://www.youtube.com/results?search_query=wow+{combo}+guide+2025 or Discord: https://www.wowhead.com/discord-servers")
    else:
        print("Error:", response.text)

if __name__ == "__main__":
    combo = sys.argv[1] if len(sys.argv) > 1 else "Human-Mage-Frost-Sunfury"
    file_type = sys.argv[2] if len(sys.argv) > 2 else "lua"
    file_name = sys.argv[3] if len(sys.argv) > 3 else "integrations/alerts_hook.lua"
    generate_file(combo, file_type, file_name)