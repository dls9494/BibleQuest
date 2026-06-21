import sqlite3
import zipfile
import re
import os

ZIP_PATH = "scratch/tel2017_usfm.zip"
DB_PATH = "assets/bible/telugu_irv.sqlite"

USFM_CODES = [
    "GEN", "EXO", "LEV", "NUM", "DEU", "JOS", "JDG", "RUT", "1SA", "2SA",
    "1KI", "2KI", "1CH", "2CH", "EZR", "NEH", "EST", "JOB", "PSA", "PRO",
    "ECC", "SNG", "ISA", "JER", "LAM", "EZK", "DAN", "HOS", "JOL", "AMO",
    "OBA", "JON", "MIC", "NAM", "HAB", "ZEP", "HAG", "ZEC", "MAL",
    "MAT", "MRK", "LUK", "JHN", "ACT", "ROM", "1CO", "2CO", "GAL", "EPH",
    "PHP", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB", "JAS",
    "1PE", "2PE", "1JN", "2JN", "3JN", "JUD", "REV"
]

BOOKS_LIST = [
    "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth",
    "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles",
    "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes",
    "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel",
    "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
    "Zephaniah", "Haggai", "Zechariah", "Malachi",
    "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians",
    "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians",
    "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James",
    "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"
]

CODE_TO_BOOK = {}
for idx, code in enumerate(USFM_CODES):
    CODE_TO_BOOK[code] = (idx + 1, BOOKS_LIST[idx])

def clean_chapter_headings(ch_text):
    lines = ch_text.split('\n')
    cleaned_lines = []
    for line in lines:
        line_strip = line.strip()
        if not line_strip:
            continue
        # Remove lines starting with heading/title tags: \s, \r, \d, \mt, \ms, \ip, etc.
        if re.match(r'\\(s|r|d|mt|ms|ip|cl|cd|toc|h|io|iot|is|mr)\d?\b', line_strip):
            continue
        cleaned_lines.append(line)
    return '\n'.join(cleaned_lines)

def clean_verse_text(text):
    # Remove footnotes
    text = re.sub(r'\\f\s+.*?\\f\*(?:\d+)?', '', text, flags=re.DOTALL)
    # Remove cross-references
    text = re.sub(r'\\x\s+.*?\\x\*(?:\d+)?', '', text, flags=re.DOTALL)
    
    # Remove inline tags and paragraph tags but keep their contents
    # e.g. \wj words\wj* -> words, \q1, \p, \m, \pi1, \bd, \qs
    text = re.sub(r'\\\+?[a-zA-Z]+\d*(?:\*|\b)', '', text)
    
    # Remove word attributes (e.g. |strong="H123")
    text = re.sub(r'\|[a-zA-Z0-9_-]+="[^"]*"', '', text)
    
    # Clean whitespace
    text = ' '.join(text.split())
    return text.strip()

def main():
    print("Reading USFM zip file...")
    db_data = {} # {book_name: {chapter: {verse: text}}}
    
    with zipfile.ZipFile(ZIP_PATH, 'r') as zip_ref:
        files = [f.filename for f in zip_ref.infolist() if f.filename.endswith('.usfm')]
        
        # Map code -> filename
        code_to_file = {}
        for fname in files:
            content_preview = zip_ref.read(fname).decode('utf-8')[:500]
            id_match = re.search(r'\\id\s+([A-Z0-9]{3})\b', content_preview)
            if id_match:
                code = id_match.group(1)
                code_to_file[code] = fname

        # Check that we found all 66 books
        missing_codes = [code for code in USFM_CODES if code not in code_to_file]
        if missing_codes:
            print(f"Error: Missing books in zip: {missing_codes}")
            return
        
        for code in USFM_CODES:
            book_number, book_name = CODE_TO_BOOK[code]
            fname = code_to_file[code]
            
            db_data[book_name] = {}
            
            content = zip_ref.read(fname).decode('utf-8')
            
            # Split into chapters
            chapters = re.split(r'\\c\s+(\d+)', content)
            if len(chapters) < 3:
                print(f"Warning: Book {book_name} has no chapters?")
                continue
                
            for idx in range(1, len(chapters), 2):
                ch_num = int(chapters[idx])
                ch_text = chapters[idx+1]
                
                db_data[book_name][ch_num] = {}
                ch_text_clean = clean_chapter_headings(ch_text)
                
                # Split chapter text by \v
                verses = re.split(r'\\v\s+(\d+(?:-\d+)?)\s+', ch_text_clean)
                
                for v_idx in range(1, len(verses), 2):
                    v_num_str = verses[v_idx]
                    v_text = verses[v_idx+1]
                    
                    cleaned_text = clean_verse_text(v_text)
                    if not cleaned_text:
                        continue
                        
                    # Handle verse ranges
                    if '-' in v_num_str:
                        try:
                            start, end = map(int, v_num_str.split('-'))
                            for v in range(start, end + 1):
                                db_data[book_name][ch_num][v] = cleaned_text
                        except ValueError:
                            print(f"Warning: Failed to parse verse range '{v_num_str}' in {book_name} {ch_num}")
                    else:
                        try:
                            v = int(v_num_str)
                            db_data[book_name][ch_num][v] = cleaned_text
                        except ValueError:
                            print(f"Warning: Failed to parse verse number '{v_num_str}' in {book_name} {ch_num}")

    # Apply structural merges to match canonical Protestant counts (KJV standard)
    
    # 1. 3 John: merge verse 15 into verse 14 (3 John has 1 chapter)
    if "3 John" in db_data:
        ch_data = db_data["3 John"].get(1, {})
        if 15 in ch_data:
            print("Merging 3 John 1:15 into 3 John 1:14...")
            ch_data[14] = ch_data[14] + " " + ch_data.pop(15)

    # 2. Revelation: merge chapter 12 verse 18 ("And he stood upon the sand of the sea") 
    # to the beginning of chapter 13 verse 1.
    if "Revelation" in db_data:
        rev_12 = db_data["Revelation"].get(12, {})
        rev_13 = db_data["Revelation"].get(13, {})
        if 18 in rev_12:
            print("Merging Revelation 12:18 into Revelation 13:1...")
            rev_12_18_text = rev_12.pop(18)
            rev_13[1] = rev_12_18_text + " " + rev_13[1]

    # Write to SQLite
    print("Recreating database file...")
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE verses (
            book_number INTEGER,
            book_name TEXT,
            chapter INTEGER,
            verse INTEGER,
            text TEXT,
            PRIMARY KEY (book_number, chapter, verse)
        )
    """)

    verses_inserted = 0
    for code in USFM_CODES:
        book_number, book_name = CODE_TO_BOOK[code]
        for ch_num in sorted(db_data[book_name].keys()):
            for v_num in sorted(db_data[book_name][ch_num].keys()):
                text = db_data[book_name][ch_num][v_num]
                cursor.execute(
                    "INSERT OR REPLACE INTO verses (book_number, book_name, chapter, verse, text) VALUES (?, ?, ?, ?, ?)",
                    (book_number, book_name, ch_num, v_num, text)
                )
                verses_inserted += 1

    print("Creating database indexes...")
    cursor.execute("CREATE INDEX idx_book_chapter ON verses(book_name, chapter)")
    cursor.execute("CREATE INDEX idx_text ON verses(text)")
    
    conn.commit()
    conn.close()
    
    print(f"Successfully rebuilt {DB_PATH} with {verses_inserted} verse rows.")

if __name__ == "__main__":
    main()
