#!/usr/bin/env python3
"""
Bible Data Generator for Telugu Bible Quiz App
Downloads KJV and creates structured JSON for the app.
Telugu text uses placeholder text (replace with real BSI text later).

Usage: python3 tools/create_bible_data.py
Output: assets/bible/kjv_bible.json, assets/bible/telugu_bible.json
"""

import json
import os
import urllib.request
import time

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'bible')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# KJV source: public domain JSON from github.com/aruljohn/Bible-kjv
KJV_BASE = "https://raw.githubusercontent.com/aruljohn/Bible-kjv/master"

# All 66 books with chapter counts
BOOKS = [
    # Old Testament
    ("Genesis", "gen", 50),
    ("Exodus", "exod", 40),
    ("Leviticus", "lev", 27),
    ("Numbers", "num", 36),
    ("Deuteronomy", "deut", 34),
    ("Joshua", "josh", 24),
    ("Judges", "judg", 21),
    ("Ruth", "ruth", 4),
    ("1 Samuel", "1sam", 31),
    ("2 Samuel", "2sam", 24),
    ("1 Kings", "1kgs", 22),
    ("2 Kings", "2kgs", 25),
    ("1 Chronicles", "1chr", 29),
    ("2 Chronicles", "2chr", 36),
    ("Ezra", "ezra", 10),
    ("Nehemiah", "neh", 13),
    ("Esther", "esth", 10),
    ("Job", "job", 42),
    ("Psalms", "ps", 150),
    ("Proverbs", "prov", 31),
    ("Ecclesiastes", "eccl", 12),
    ("Song of Solomon", "song", 8),
    ("Isaiah", "isa", 66),
    ("Jeremiah", "jer", 52),
    ("Lamentations", "lam", 5),
    ("Ezekiel", "ezek", 48),
    ("Daniel", "dan", 12),
    ("Hosea", "hos", 14),
    ("Joel", "joel", 3),
    ("Amos", "amos", 9),
    ("Obadiah", "obad", 1),
    ("Jonah", "jonah", 4),
    ("Micah", "mic", 7),
    ("Nahum", "nah", 3),
    ("Habakkuk", "hab", 3),
    ("Zephaniah", "zeph", 3),
    ("Haggai", "hag", 2),
    ("Zechariah", "zech", 14),
    ("Malachi", "mal", 4),
    # New Testament
    ("Matthew", "matt", 28),
    ("Mark", "mark", 16),
    ("Luke", "luke", 24),
    ("John", "john", 21),
    ("Acts", "acts", 28),
    ("Romans", "rom", 16),
    ("1 Corinthians", "1cor", 16),
    ("2 Corinthians", "2cor", 13),
    ("Galatians", "gal", 6),
    ("Ephesians", "eph", 6),
    ("Philippians", "phil", 4),
    ("Colossians", "col", 4),
    ("1 Thessalonians", "1thess", 5),
    ("2 Thessalonians", "2thess", 3),
    ("1 Timothy", "1tim", 6),
    ("2 Timothy", "2tim", 4),
    ("Titus", "titus", 3),
    ("Philemon", "phlm", 1),
    ("Hebrews", "heb", 13),
    ("James", "jas", 5),
    ("1 Peter", "1pet", 5),
    ("2 Peter", "2pet", 3),
    ("1 John", "1john", 5),
    ("2 John", "2john", 1),
    ("3 John", "3john", 1),
    ("Jude", "jude", 1),
    ("Revelation", "rev", 22),
]

# Books with real KJV text (NT + Psalms + Proverbs)
REAL_TEXT_BOOKS = {b[0] for b in BOOKS[39:]} | {"Psalms", "Proverbs"}

# Telugu placeholder text
TE_PLACEHOLDER = "ఈ వచనం త్వరలో అందుబాటులోకి వస్తుంది."
EN_PLACEHOLDER = "This verse will be available soon."

def fetch_kjv_book(name, abbr, chapter_count):
    """Try to fetch KJV data for a book, returns dict {chapter: {verse: text}}"""
    result = {}
    
    # Try direct URL fetch for each chapter
    # Using openbible.info or bible-api.com as fallback
    try:
        url = f"{KJV_BASE}/{name.replace(' ', '%20')}.json"
        with urllib.request.urlopen(url, timeout=15) as resp:
            data = json.loads(resp.read().decode())
            # Format: {"book": "Genesis", "chapters": [{"chapter": 1, "verses": [{"verse": 1, "text": "..."}]}]}
            if "chapters" in data:
                for ch_data in data["chapters"]:
                    ch_num = str(ch_data["chapter"])
                    result[ch_num] = {}
                    for v_data in ch_data["verses"]:
                        result[ch_num][str(v_data["verse"])] = v_data["text"].strip()
                return result
    except Exception as e:
        print(f"  Could not fetch {name} from aruljohn: {e}")
    
    return result


def build_placeholder_book(chapter_count, is_english=True):
    """Build a placeholder structure for a book."""
    result = {}
    # Approximate verse counts per chapter (use 20 as default)
    for ch in range(1, chapter_count + 1):
        result[str(ch)] = {}
        verse_count = 20  # approximate
        for v in range(1, verse_count + 1):
            result[str(ch)][str(v)] = EN_PLACEHOLDER if is_english else TE_PLACEHOLDER
    return result


def main():
    kjv_data = {}
    telugu_data = {}

    print(f"Building Bible data for {len(BOOKS)} books...")
    print(f"Real text books: {len(REAL_TEXT_BOOKS)} (NT + Psalms + Proverbs)")
    print()

    for i, (name, abbr, chapters) in enumerate(BOOKS):
        print(f"[{i+1:2d}/{len(BOOKS)}] {name} ({chapters} chapters)...", end=" ")
        
        if name in REAL_TEXT_BOOKS:
            # Try to fetch real KJV text
            kjv_book = fetch_kjv_book(name, abbr, chapters)
            if kjv_book:
                print(f"✓ KJV ({len(kjv_book)} chapters)")
                kjv_data[name] = kjv_book
            else:
                print("⚠ Using placeholder (fetch failed)")
                kjv_data[name] = build_placeholder_book(chapters, is_english=True)
        else:
            print("placeholder (OT)")
            kjv_data[name] = build_placeholder_book(chapters, is_english=True)
        
        # Telugu is placeholder for all books (BSI copyright - replace later)
        telugu_data[name] = build_placeholder_book(chapters, is_english=False)
        
        # Small delay to be polite to servers
        if name in REAL_TEXT_BOOKS:
            time.sleep(0.3)

    # Write KJV
    kjv_path = os.path.join(OUTPUT_DIR, 'kjv_bible.json')
    with open(kjv_path, 'w', encoding='utf-8') as f:
        json.dump(kjv_data, f, ensure_ascii=False, separators=(',', ':'))
    size_kb = os.path.getsize(kjv_path) / 1024
    print(f"\n✓ Written: {kjv_path} ({size_kb:.0f} KB)")

    # Write Telugu
    te_path = os.path.join(OUTPUT_DIR, 'telugu_bible.json')
    with open(te_path, 'w', encoding='utf-8') as f:
        json.dump(telugu_data, f, ensure_ascii=False, separators=(',', ':'))
    size_kb = os.path.getsize(te_path) / 1024
    print(f"✓ Written: {te_path} ({size_kb:.0f} KB)")
    print("\nDone! Register assets/bible/ in pubspec.yaml before building.")


if __name__ == '__main__':
    main()
