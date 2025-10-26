import requests

XAI_KEY = "YOUR_XAI_API_KEY_HERE"  # Your key

def query_grok(combo):
    url = "https://api.x.ai/v1/chat/completions"  # Grok API endpoint
    headers = {"Authorization": f"Bearer {XAI_KEY}"}
    prompt = f"Generate a unique narrative for WoW combo {combo} (race-class-spec-hero tree). Keep it immersive, 50-100 words. Output as ElvUI-import string with example border tweak."
    data = {
        "model": "grok-beta",
        "messages": [{"role": "user", "content": prompt}]
    }
    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 200:
        narrative = response.json()['choices'][0]['message']['content']
        elvui_string = f"-- ElvUI Import for {combo}: {narrative}\nprofile.general.bordercolor = {{r = 0.5, g = 0.5, b = 0.5}}"  # Example tweak
        return narrative, elvui_string
    else:
        return "Error querying Grok.", None

# Example usage
combo = input("Enter combo (e.g., Human-Mage-Frost-Sunfury): ")
narrative, elvui_string = query_grok(combo)
print("Narrative:", narrative)
print("ElvUI String:", elvui_string)