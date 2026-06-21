import os
from PIL import Image

image_dir = "/home/david/.gemini/antigravity/brain/0323657b-e3c6-4504-b85d-f4977582eaa4"
images = [
    "media__1781816224054.jpg",
    "media__1781816808254.jpg",
    "media__1781817311076.jpg",
    "media__1781817311080.jpg",
    "media__1781817311085.jpg"
]

def rgb_to_hex(rgb):
    return '#{:02x}{:02x}{:02x}'.format(rgb[0], rgb[1], rgb[2]).upper()

for img_name in images:
    img_path = os.path.join(image_dir, img_name)
    if not os.path.exists(img_path):
        print(f"{img_name} does not exist")
        continue
    try:
        with Image.open(img_path) as img:
            img = img.convert('RGB')
            w, h = img.size
            print(f"\n--- {img_name} ({w}x{h}) ---")
            
            # Sample positions
            top_y = int(h * 0.1)
            mid_y = int(h * 0.5)
            bot_y = int(h * 0.9)
            x = int(w * 0.5)
            
            top_color = img.getpixel((x, top_y))
            mid_color = img.getpixel((x, mid_y))
            bot_color = img.getpixel((x, bot_y))
            
            print(f"Top (10% down): {top_color} -> {rgb_to_hex(top_color)}")
            print(f"Middle (50% down): {mid_color} -> {rgb_to_hex(mid_color)}")
            print(f"Bottom (90% down): {bot_color} -> {rgb_to_hex(bot_color)}")
    except Exception as e:
        print(f"Error reading {img_name}: {e}")
