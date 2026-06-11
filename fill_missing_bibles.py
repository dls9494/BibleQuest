#!/usr/bin/env python3
import os
import json
import urllib.request
import ssl
import re
import time

# Set up SSL context to ignore certificate verification errors
ssl_ctx = ssl.create_default_context()
ssl_ctx.check_hostname = False
ssl_ctx.verify_mode = ssl.CERT_NONE

# 66 Canonical Protestant books in standard order
CANONICAL_BOOKS = [
    "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth",
    "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra",
    "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon",
    "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
    "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah",
    "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians",
    "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians",
    "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James",
    "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"
]

# Source URLs
SOURCES = {
    "english_asv": {
        "url": "https://api.getbible.net/v2/asv.json",
        "type": "getbible",
        "placeholder_ver": "ASV",
        "dest": "assets/bible/english_asv.json"
    },
    "english_web": {
        "url": "https://api.getbible.net/v2/web.json",
        "type": "getbible",
        "placeholder_ver": "WEB",
        "dest": "assets/bible/english_web.json"
    },
    "english_darby": {
        "url": "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/json/Darby.json",
        "type": "darby",
        "placeholder_ver": "Darby",
        "dest": "assets/bible/english_darby.json"
    },
    "telugu_ov": {
        "url": "https://raw.githubusercontent.com/manuni/BibleDatabases/master/JSON_Bible%20as%20Single%20File/telugu.json",
        "type": "telugu",
        "placeholder_ver": "Telugu OV",
        "dest": "assets/bible/telugu_ov.json"
    }
}

def download_source_with_retry(key, info, retries=3, delay=5):
    url = info["url"]
    for attempt in range(1, retries + 1):
        print(f"[{key}] Downloading from {url} (Attempt {attempt}/{retries})...")
        try:
            req = urllib.request.Request(
                url,
                headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
            )
            with urllib.request.urlopen(req, context=ssl_ctx, timeout=20) as response:
                data = response.read()
                print(f"[{key}] Successfully downloaded {len(data)} bytes.")
                return json.loads(data.decode('utf-8'))
        except Exception as e:
            print(f"[{key}] Error downloading (Attempt {attempt}): {e}")
            if attempt < retries:
                print(f"[{key}] Waiting {delay} seconds before retrying...")
                time.sleep(delay)
            else:
                raise Exception(f"Failed to download {key} after {retries} attempts.")

def clean_darby_text(text):
    # Fix spacing issue before 'God' and 'Godhead'
    # e.g., 'beginningGod' -> 'beginning God', 'theGodhead' -> 'the Godhead'
    if not text:
        return text
    return re.sub(r'([a-zA-Z])God', r'\1 God', text)

def build_bible_dict(source_key, raw_data, reference_structure):
    info = SOURCES[source_key]
    out_bible = {}
    
    # 1. Parse into a temporary structure
    temp_bible = {}
    
    if info["type"] == "getbible":
        # getbible V2 format
        books_list = raw_data.get("books", [])
        for i, book_data in enumerate(books_list):
            if i >= len(CANONICAL_BOOKS):
                break
            book_name = CANONICAL_BOOKS[i]
            temp_bible[book_name] = {}
            for ch_data in book_data.get("chapters", []):
                ch_num = str(ch_data.get("chapter", ""))
                temp_bible[book_name][ch_num] = {}
                for v_data in ch_data.get("verses", []):
                    v_num = str(v_data.get("verse", ""))
                    v_text = v_data.get("text", "").strip()
                    temp_bible[book_name][ch_num][v_num] = v_text
                    
    elif info["type"] == "darby":
        # Scrollmapper Darby format
        books_list = raw_data.get("books", [])
        for i, book_data in enumerate(books_list):
            if i >= len(CANONICAL_BOOKS):
                break
            book_name = CANONICAL_BOOKS[i]
            temp_bible[book_name] = {}
            for ch_data in book_data.get("chapters", []):
                ch_num = str(ch_data.get("chapter", ""))
                temp_bible[book_name][ch_num] = {}
                for v_data in ch_data.get("verses", []):
                    v_num = str(v_data.get("verse", ""))
                    v_text = clean_darby_text(v_data.get("text", "").strip())
                    temp_bible[book_name][ch_num][v_num] = v_text
                    
    elif info["type"] == "telugu":
        # manuni/BibleDatabases Telugu format
        books_list = raw_data.get("Book", [])
        for i, book_data in enumerate(books_list):
            if i >= len(CANONICAL_BOOKS):
                break
            book_name = CANONICAL_BOOKS[i]
            temp_bible[book_name] = {}
            for ch_idx, ch_data in enumerate(book_data.get("Chapter", [])):
                ch_num = str(ch_idx + 1)
                temp_bible[book_name][ch_num] = {}
                for v_idx, v_data in enumerate(ch_data.get("Verse", [])):
                    v_num = str(v_idx + 1)
                    v_text = v_data.get("Verse", "").strip()
                    temp_bible[book_name][ch_num][v_num] = v_text

    # 2. Fill in missing books, chapters, and verses using the reference structure
    filled_count = 0
    total_verses = 0
    
    for book_name, chapters in reference_structure.items():
        out_bible[book_name] = {}
        for ch_num, verses in chapters.items():
            out_bible[book_name][ch_num] = {}
            for v_num in verses.keys():
                total_verses += 1
                
                # Check if we have this verse in our temp bible
                val = temp_bible.get(book_name, {}).get(ch_num, {}).get(v_num, "")
                if not val:
                    # Place placeholder
                    val = f"{info['placeholder_ver']} text for {book_name} {ch_num}:{v_num} is not available yet."
                    filled_count += 1
                
                out_bible[book_name][ch_num][v_num] = val
                
    print(f"[{source_key}] Processed {total_verses} total verses. Placeholders filled: {filled_count}")
    return out_bible

def main():
    # Ensure dest folder exists
    os.makedirs("assets/bible", exist_ok=True)
    
    # Load reference structure (from KJV)
    ref_path = "assets/bible/english_kjv.json"
    if not os.path.exists(ref_path):
        print(f"Error: Reference Bible structure '{ref_path}' not found.")
        return
        
    print(f"Loading reference structure from {ref_path}...")
    with open(ref_path, "r", encoding="utf-8") as f:
        reference_structure = json.load(f)
        
    # Download raw data sequentially to avoid rate limiting and connection locks
    raw_downloads = {}
    for key, info in SOURCES.items():
        try:
            raw_json = download_source_with_retry(key, info)
            raw_downloads[key] = raw_json
        except Exception as e:
            print(f"Error downloading {key}: {e}")
            return
            
    # Process and write files
    for key, raw_json in raw_downloads.items():
        info = SOURCES[key]
        processed_bible = build_bible_dict(key, raw_json, reference_structure)
        
        print(f"Writing {key} to {info['dest']}...")
        with open(info["dest"], "w", encoding="utf-8") as f:
            json.dump(processed_bible, f, ensure_ascii=False)
            
    print("\nAll missing Bible files generated successfully!")

if __name__ == "__main__":
    main()
