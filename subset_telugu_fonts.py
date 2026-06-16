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
    
    # Try different options to get size under 50 KB
    options_list = [
        # Option 1: Keep all layout features
        {"layout-features": "*", "drop-tables": ""},
        # Option 2: Drop GPOS
        {"layout-features": "*", "drop-tables": "GPOS"},
        # Option 3: Drop GSUB and GPOS
        {"layout-features": "*", "drop-tables": "GSUB,GPOS"},
        # Option 4: Strip layout features completely
        {"layout-features": "", "drop-tables": "GSUB,GPOS"},
        # Option 5: Keep only basic Latin characters
        {"layout-features": "", "drop-tables": "GSUB,GPOS", "unicodes": "U+0020-007E"},
    ]
    
    for idx, opts in enumerate(options_list):
        try:
            unicodes = opts.get("unicodes", "U+0020-007E,U+0C00-0C7F")
            args = [
                font_path,
                f"--unicodes={unicodes}",
                f"--output-file={tmp_path}",
                "--no-hinting",
            ]
            if opts["layout-features"]:
                args.append(f"--layout-features={opts['layout-features']}")
            else:
                args.append("--layout-features=")
                
            if opts["drop-tables"]:
                args.append(f"--drop-tables+={opts['drop-tables']}")
                
            subset_main(args)
            
            if os.path.exists(tmp_path):
                new_size = os.path.getsize(tmp_path)
                if new_size < 50 * 1024:
                    orig_size = os.path.getsize(font_path)
                    os.replace(tmp_path, font_path)
                    print(f"Successfully subsetted {filename} (Option {idx+1}): {orig_size / 1024:.1f} KB -> {new_size / 1024:.1f} KB.")
                    return
                else:
                    print(f"Option {idx+1} size ({new_size / 1024:.1f} KB) still >= 50 KB. Trying next option...")
            else:
                print(f"Option {idx+1} failed to generate tmp file.")
        except Exception as e:
            print(f"Option {idx+1} threw exception: {e}")
            
    print(f"Error: Could not reduce {filename} under 50 KB with any option.")

if __name__ == "__main__":
    fonts_dir = os.path.join("assets", "fonts")
    for f in sorted(os.listdir(fonts_dir)):
        if f.endswith(".ttf"):
            subset_font(f)
