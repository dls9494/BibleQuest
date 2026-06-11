#!/usr/bin/env python3
import os
import sys
from fontTools.subset import main as subset_main

def subset_font(filename):
    font_path = os.path.join("assets", "fonts", filename)
    tmp_path = font_path + ".tmp"
    
    if not os.path.exists(font_path):
        print(f"Error: {font_path} not found.")
        return

    print(f"Subsetting {font_path}...")
    
    try:
        # Kept ranges:
        # - U+0020-007E: Basic Latin (punctuation, digits, standard letters)
        # - U+0C00-0C7F: Telugu Unicode block
        # Added --no-hinting to strip TTF hinting data, which significantly reduces file sizes
        subset_main([
            font_path,
            "--unicodes=U+0020-007E,U+0C00-0C7F",
            f"--output-file={tmp_path}",
            "--layout-features=*",
            "--no-hinting",
        ])
        
        if os.path.exists(tmp_path):
            orig_size = os.path.getsize(font_path)
            new_size = os.path.getsize(tmp_path)
            
            # Overwrite the original file
            os.replace(tmp_path, font_path)
            print(f"Successfully subsetted {filename}: {orig_size / 1024:.1f} KB -> {new_size / 1024:.1f} KB ({(1.0 - new_size / orig_size) * 100.0:.1f}% reduction).")
        else:
            print(f"Error: Subsetting failed to generate {tmp_path}")
    except Exception as e:
        print(f"Exception during subsetting {filename}: {e}")

if __name__ == "__main__":
    subset_font("NotoSansTelugu-Regular.ttf")
    subset_font("NotoSansTelugu-Bold.ttf")
