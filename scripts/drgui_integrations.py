import requests
import json
import sys

API_KEY = "YOUR_XAI_API_KEY_HERE"
API_URL = "https://api.x.ai/v1/chat/completions"

def get_grok_tip(combo_or_alert):
    payload = {
        "model": "grok-4",
        "messages": [{"role": "user", "content": f"Provide optimized tips for WoW {combo_or_alert}. Include hyperlinks to Icy Veins, Wowhead, Raider.IO, MMO-Champion, Blizzard Watch. Make it epic and lore-based from Warcraft Wiki. Suggest YouTube tutorials/streams."}]
    }
    response = requests.post(API_URL, headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}, data=json.dumps(payload))
    
    if response.status_code == 200:
        tip = response.json()['choices'][0]['message']['content']
        print("Grok Tip (Paste in WoW):", tip)
    else:
        print("Error:", response.text)

def query_for_file(missing_file):
    prompt = f"Suggest borrow or gen for missing DRGUI file: {missing_file}. From AddOns like !mMT_MediaPack/!ClassColors, or Grok code. Hyperlink CurseForge if borrow."
    payload = {"model": "grok-4", "messages": [{"role": "user", "content": prompt}]}
    response = requests.post(API_URL, headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}, data=json.dumps(payload))
    if response.status_code == 200:
        suggestion = response.json()['choices'][0]['message']['content']
        print("Grok File Suggestion:", suggestion)
    else:
        print("Error:", response.text)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "file":
        missing_file = sys.argv[2] if len(sys.argv) > 2 else "example.lua"
        query_for_file(missing_file)
    else:
        query = sys.argv[1] if len(sys.argv) > 1 else "Test-Combo"
        get_grok_tip(query)