#!/usr/bin/env python3
"""
Robust script to fetch public-domain Bible texts and generate JSON files
for Telugu, KJV, and NHEB (WEB).
Uses getbible.net for single-file KJV and WEB downloads, and aruljohn/Bible-telugu
for Telugu books concurrently.
"""
import json
import os
import urllib.request
import urllib.parse
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

OUT_DIR = "assets/bible"

# Book name mapping to ensure match with Flutter app
BOOK_NAME_MAP = {
    "Song of Songs": "Song of Solomon"
}

BOOKS_LIST = [
    "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth",
    "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles",
    "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes",
    "Song of Songs", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel",
    "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
    "Zephaniah", "Haggai", "Zechariah", "Malachi",
    "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians",
    "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians",
    "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James",
    "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"
]

def download_url(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=15) as resp:
        return resp.read()

def process_getbible_json(raw_data):
    """
    Converts getbible.net structure:
    { "books": [ { "name": "...", "chapters": [ { "chapter": 1, "verses": [ { "verse": 1, "text": "..." } ] } ] } ] }
    to app structure:
    { "BookName": { "ChapterStr": { "VerseStr": "Text" } } }
    """
    input_data = json.loads(raw_data.decode('utf-8'))
    output_data = {}
    
    for book in input_data.get("books", []):
        raw_name = book.get("name")
        # Map book name if necessary
        app_name = BOOK_NAME_MAP.get(raw_name, raw_name)
        output_data[app_name] = {}
        
        for chapter_obj in book.get("chapters", []):
            ch_num = str(chapter_obj.get("chapter"))
            output_data[app_name][ch_num] = {}
            for verse_obj in chapter_obj.get("verses", []):
                v_num = str(verse_obj.get("verse"))
                text = verse_obj.get("text", "").strip()
                output_data[app_name][ch_num][v_num] = text
                
    return output_data

def process_aruljohn_book(raw_data, book_name):
    """
    Converts aruljohn book structure:
    { "chapters": [ { "chapter": "1", "verses": [ { "verse": "1", "text": "..." } ] } ] }
    to:
    { "ChapterStr": { "VerseStr": "Text" } }
    """
    input_data = json.loads(raw_data.decode('utf-8'))
    book_chapters = {}
    
    for chapter_obj in input_data.get("chapters", []):
        ch_num = str(chapter_obj.get("chapter"))
        book_chapters[ch_num] = {}
        for verse_obj in chapter_obj.get("verses", []):
            v_num = str(verse_obj.get("verse"))
            text = verse_obj.get("text", "").strip()
            book_chapters[ch_num][v_num] = text
            
    return book_chapters

def download_telugu_book(book_name):
    encoded_name = urllib.parse.quote(book_name)
    url = f"https://raw.githubusercontent.com/aruljohn/Bible-telugu/master/{encoded_name}.json"
    try:
        raw_data = download_url(url)
        processed = process_aruljohn_book(raw_data, book_name)
        app_name = BOOK_NAME_MAP.get(book_name, book_name)
        return app_name, processed, None
    except Exception as e:
        return book_name, None, str(e)

def verify_data(data, label):
    missing = []
    for book in BOOKS_LIST:
        app_name = BOOK_NAME_MAP.get(book, book)
        if app_name not in data:
            missing.append(app_name)
            continue
        # Check if it has chapters
        if not data[app_name]:
            missing.append(f"{app_name} (empty)")
            
    if missing:
        print(f"[{label}] Warning: missing or empty books: {missing[:10]}")
    else:
        print(f"[{label}] Verification success! All 66 books present.")

def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    
    # 1. Download KJV Bible
    kjv_path = os.path.join(OUT_DIR, "kjv_bible.json")
    print("Downloading English KJV Bible from getbible.net...")
    try:
        raw_kjv = download_url("https://api.getbible.net/v2/kjv.json")
        kjv_data = process_getbible_json(raw_kjv)
        with open(kjv_path, 'w', encoding='utf-8') as f:
            json.dump(kjv_data, f, ensure_ascii=False, separators=(',', ':'))
        print(f"Saved KJV to {kjv_path}")
        verify_data(kjv_data, "KJV")
    except Exception as e:
        print(f"Failed to fetch KJV: {e}")
        sys.exit(1)
        
    # 2. Download WEB Bible (saved as nhv_bible.json)
    nhv_path = os.path.join(OUT_DIR, "nhv_bible.json")
    print("\nDownloading English WEB/NHV Bible from getbible.net...")
    try:
        raw_web = download_url("https://api.getbible.net/v2/web.json")
        web_data = process_getbible_json(raw_web)
        with open(nhv_path, 'w', encoding='utf-8') as f:
            json.dump(web_data, f, ensure_ascii=False, separators=(',', ':'))
        print(f"Saved WEB/NHV to {nhv_path}")
        verify_data(web_data, "WEB/NHV")
    except Exception as e:
        print(f"Failed to fetch WEB: {e}")
        sys.exit(1)

    # 3. Download Telugu Bible book-by-book concurrently
    telugu_path = os.path.join(OUT_DIR, "telugu_bible.json")
    print("\nDownloading Telugu Bible book-by-book from aruljohn/Bible-telugu...")
    telugu_data = {}
    failures = []
    
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(download_telugu_book, book): book for book in BOOKS_LIST}
        for fut in as_completed(futures):
            book_name, processed, err = fut.result()
            if err:
                print(f"  Failed to download {book_name}: {err}")
                failures.append((book_name, err))
            else:
                telugu_data[book_name] = processed
                print(f"  ✓ {book_name} downloaded")
                
    if failures:
        print(f"\nWarning: {len(failures)} books failed to download. Generating placeholders for them.")
        # Fill in placeholders for failed books
        for book_name, _ in failures:
            app_name = BOOK_NAME_MAP.get(book_name, book_name)
            # Create a simple placeholder chapter 1 with 1 verse
            telugu_data[app_name] = {"1": {"1": "ఈ వచనం త్వరలో అందుబాటులోకి వస్తుంది."}}
            
    with open(telugu_path, 'w', encoding='utf-8') as f:
        json.dump(telugu_data, f, ensure_ascii=False, separators=(',', ':'))
    print(f"Saved Telugu Bible to {telugu_path}")
    verify_data(telugu_data, "Telugu")
    
    print("\nDone.")

if __name__ == "__main__":
    main()
