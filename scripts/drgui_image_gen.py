import requests
import json
import base64
from io import BytesIO
import pygame
import sys

# Your xAI key
API_KEY = "YOUR_XAI_API_KEY_HERE"
API_URL = "https://api.x.ai/v1/images/generations"  # 2025 endpoint

def generate_image(combo, media_type="border"):
    prompt = f"Generate a minimalistic, cartoony Bushido-style {media_type} for WoW combo: {combo}. Action-packed glows, unique to race/class/spec/hero (e.g., icy temporal for Frost Sunfury). Lore-inspired from Warcraft Wiki. Output as high-res JPG."
    
    # Optional: Narrate via text API first
    nar_payload = {"model": "grok-4", "messages": [{"role": "user", "content": f"Narrate epic install for {combo} image: {prompt}. Hyperlink YouTube: https://www.youtube.com/results?search_query=wow+{combo}+ui+2025"}]}
    nar_response = requests.post("https://api.x.ai/v1/chat/completions", headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}, data=json.dumps(nar_payload))
    narration = nar_response.json()['choices'][0]['message']['content'] if nar_response.status_code == 200 else "Error"
    print("Grok Narration:", narration)  # Paste into WoW chat (WIM/Prat)

    # Generate image
    payload = {"model": "grok-2-image-1212", "prompt": prompt, "n": 1, "size": "1024x1024"}  # High-res for TGA
    response = requests.post(API_URL, headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}, data=json.dumps(payload))
    
    if response.status_code == 200:
        image_data = response.json()['data'][0]['b64_json']  # Assume base64
        jpg_path = f"{combo}_{media_type}.jpg"
        with open(jpg_path, "wb") as f:
            f.write(base64.b64decode(image_data))
        print(f"JPG saved: {jpg_path}")
        convert_to_tga(jpg_path)
    else:
        print("Error:", response.text)

def convert_to_tga(jpg_path):
    pygame.init()
    surface = pygame.image.load(jpg_path)  # Load JPG
    tga_path = jpg_path.replace(".jpg", ".tga")
    pygame.image.save(surface, tga_path)  # Saves as TGA
    print(f"Converted to TGA: {tga_path}. Place in media/{tga_path.split('_')[1]}/")

if __name__ == "__main__":
    combo = sys.argv[1] if len(sys.argv) > 1 else "Human-Mage-Frost-Sunfury"
    media_type = sys.argv[2] if len(sys.argv) > 2 else "border"
    generate_image(combo, media_type)