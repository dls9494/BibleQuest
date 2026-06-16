#!/usr/bin/env python3
import os
import json

def minify_json(file_path):
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found.")
        return

    orig_size = os.path.getsize(file_path)
    print(f"Compressing {file_path}...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Serialize with compact separators and without ascii-only encoding to keep unicode intact
        compact_str = json.dumps(data, separators=(',', ':'), ensure_ascii=False)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(compact_str)
            
        new_size = os.path.getsize(file_path)
        print(f"Successfully compressed {os.path.basename(file_path)}: {orig_size / (1024*1024):.2f} MB -> {new_size / (1024*1024):.2f} MB ({(1.0 - new_size/orig_size)*100.0:.1f}% reduction).")
    except Exception as e:
        print(f"Exception compressing {file_path}: {e}")

if __name__ == "__main__":
    files_to_compress = [
        "assets/bible/english_kjv.json",
        "assets/bible/english_asv.json",
        "assets/bible/english_web.json",
        "assets/bible/english_darby.json",
        "assets/bible/telugu_ov.json"
    ]
    
    for f in files_to_compress:
        minify_json(f)
