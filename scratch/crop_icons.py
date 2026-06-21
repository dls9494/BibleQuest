import os
from PIL import Image

icons_dir = '/home/david/Music/Bible Quiz/assets/icons/flat/'
margin_pct = 0.05  # 5% margin around the icon

for filename in sorted(os.listdir(icons_dir)):
    if filename.endswith('.png'):
        filepath = os.path.join(icons_dir, filename)
        try:
            img = Image.open(filepath).convert("RGBA")
            bbox = img.getbbox()
            if not bbox:
                print(f"Skipping empty image {filename}")
                continue
            
            # Crop to bounding box
            cropped = img.crop(bbox)
            
            # Determine square dimensions
            w, h = cropped.size
            square_size = max(w, h)
            
            # Create a new square transparent image
            square_img = Image.new("RGBA", (square_size, square_size), (0, 0, 0, 0))
            
            # Paste the cropped image in the center
            offset_x = (square_size - w) // 2
            offset_y = (square_size - h) // 2
            square_img.paste(cropped, (offset_x, offset_y))
            
            # Add padding margin
            margin = int(square_size * margin_pct)
            new_size = square_size + 2 * margin
            final_img = Image.new("RGBA", (new_size, new_size), (0, 0, 0, 0))
            final_img.paste(square_img, (margin, margin))
            
            # Save it back
            final_img.save(filepath)
            print(f"Successfully cropped and squared {filename} to {final_img.size}")
            
        except Exception as e:
            print(f"Error processing {filename}: {e}")
