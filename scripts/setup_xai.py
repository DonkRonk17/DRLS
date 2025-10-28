import subprocess
import sys
import requests
import json

# Your xAI key (hardcode or env var for security; per docs.x.ai/docs/overview)
API_KEY = "YOUR_XAI_API_KEY_HERE"
API_URL = "https://api.x.ai/v1/chat/completions"  # Base for requests fallback

def install_sdk():
    try:
        # Pip install official xAI SDK (2025 version, gRPC-based; per github.com/xai-org/xai-sdk-python)
        subprocess.check_call([sys.executable, "-m", "pip", "install", "xai-sdk"])
        print("xAI SDK installed successfully! For lightweight alt: pip install xai-grok-sdk (pypi.org/project/xai-grok-sdk/).")
    except Exception as e:
        print(f"Install failed: {e}. Fallback to requests (no SDK needed). Check PyPI: https://pypi.org/project/xai-sdk/ or GitHub: https://github.com/xai-org/xai-sdk-python")

def test_api():
    # Sample chat completion (narrate a DRGUI combo; compatible with OpenAI SDK by URL swap per x.ai/api)
    payload = {
        "model": "grok-4",
        "messages": [{"role": "user", "content": "Narrate a WoW UI install for Human-Mage-Frost-Sunfury: Epic, Bushido-style, with Icy Veins guide hyperlink."}]
    }
    headers = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
    
    response = requests.post(API_URL, headers=headers, data=json.dumps(payload))
    if response.status_code == 200:
        narration = response.json()['choices'][0]['message']['content']
        print("API Test Success! Sample Narration:", narration)
        print("Paste in WoW (WIM/Prat). For SDK usage example: import xai; client = xai.Client(api_key=API_KEY); response = client.chat.completions.create(...)")
    else:
        print("API Test Failed:", response.text)
        print("Troubleshoot: https://docs.x.ai/docs/overview or Apidog Guide: https://apidog.com/blog/xai-grok-api/ (Feb 2025). Ensure SuperGrok sub: https://x.ai/grok")

if __name__ == "__main__":
    install_sdk()
    test_api()
    print("Setup complete! Integrate into DRGUI scripts. Video Tutorial: https://www.youtube.com/watch?v=8Jqk-rF_U-c (Grok API Python Getting Started, Dec 2024—still valid). For 2025 updates: https://www.newoaks.ai/blog/beginners-guide-grok-3-api-2025/ (Mar 2025 Guide).")