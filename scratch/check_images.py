import os
from PIL import Image

icons_dir = '/home/david/Music/Bible Quiz/assets/icons/flat/'
for filename in sorted(os.listdir(icons_dir)):
    if filename.endswith('.png'):
        filepath = os.path.join(icons_dir, filename)
        try:
            img = Image.open(filepath)
            bbox = img.getbbox()
            print(f"{filename}: size={img.size}, bbox={bbox}")
        except Exception as e:
            print(f"Error reading {filename}: {e}")
