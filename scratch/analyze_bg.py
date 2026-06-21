from PIL import Image

image_path = '/home/david/.gemini/antigravity/brain/0323657b-e3c6-4504-b85d-f4977582eaa4/media__1781947331507.png'
img = Image.open(image_path)
w, h = img.size

# Sample pixels along a vertical line in the middle of the image
sample_ys = [0, h // 4, h // 2, 3 * h // 4, h - 1]
print("Image size:", img.size)
for y in sample_ys:
    r, g, b = img.getpixel((w // 2, y))[:3]
    hex_color = f"0xFF{r:02X}{g:02X}{b:02X}"
    print(f"y={y} ({100*y/h:.1f}%): RGB=({r}, {g}, {b}) -> {hex_color}")
