import os
import re
import zipfile
import sqlite3
import sys

# Paths
DB_DIR = "/home/david/Music/Bible Quiz/assets/bible"
REF_DIR = "/tmp/bible_ref"
BIBLE_SERVICE_PATH = "/home/david/Music/Bible Quiz/lib/services/bible_service.dart"

TRANSLATIONS = {
    "kjv": {
        "db_name": "kjv.sqlite",
        "zip_name": "eng-kjv_usfm.zip",
    },
    "asv": {
        "db_name": "asv.sqlite",
        "zip_name": "eng-asv_usfm.zip",
    },
    "web": {
        "db_name": "web.sqlite",
        "zip_name": "eng-web_usfm.zip",
    },
    "darby": {
        "db_name": "darby.sqlite",
        "zip_name": "engDBY_usfm.zip",
    }
}

USFM_CODES = [
    "GEN", "EXO", "LEV", "NUM", "DEU", "JOS", "JDG", "RUT", "1SA", "2SA",
    "1KI", "2KI", "1CH", "2CH", "EZR", "NEH", "EST", "JOB", "PSA", "PRO",
    "ECC", "SNG", "ISA", "JER", "LAM", "EZK", "DAN", "HOS", "JOL", "AMO",
    "OBA", "JON", "MIC", "NAM", "HAB", "ZEP", "HAG", "ZEC", "MAL",
    "MAT", "MRK", "LUK", "JHN", "ACT", "ROM", "1CO", "2CO", "GAL", "EPH",
    "PHP", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB", "JAS",
    "1PE", "2PE", "1JN", "2JN", "3JN", "JUD", "REV"
]

def load_books_metadata(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    pattern = r"BibleBook\(\s*id:\s*'([^']+)',\s*nameEn:\s*'([^']+)',\s*nameTe:\s*'([^']+)',\s*chapters:\s*(\d+),\s*testament:\s*'([^']+)'\s*\)"
    matches = re.findall(pattern, content)
    books = []
    for idx, m in enumerate(matches):
        books.append({
            'book_number': idx + 1,
            'id': m[0],
            'nameEn': m[1],
            'nameTe': m[2],
            'chapters': int(m[3])
        })
    return books

CODE_TO_BOOK = {}
BOOK_NAME_BY_NUM = {}

def init_book_maps(books_meta):
    global CODE_TO_BOOK, BOOK_NAME_BY_NUM
    for idx, code in enumerate(USFM_CODES):
        book_num = idx + 1
        meta = next((b for b in books_meta if b['book_number'] == book_num), None)
        bname = meta['nameEn'] if meta else f"Book {book_num}"
        CODE_TO_BOOK[code] = (book_num, bname)
        BOOK_NAME_BY_NUM[book_num] = bname

def clean_chapter_headings(ch_text):
    lines = ch_text.split('\n')
    cleaned_lines = []
    for line in lines:
        line_strip = line.strip()
        if not line_strip:
            continue
        if re.match(r'\\(s|r|d|mt|ms|ip|cl|cd|toc|h|io|iot|is|mr)\d?\b', line_strip):
            continue
        cleaned_lines.append(line)
    return '\n'.join(cleaned_lines)

def clean_verse_text(text):
    if not text:
        return ""
    # 1. Remove footnotes
    text = re.sub(r'\\f\+?\s+.*?\\f\*', '', text, flags=re.DOTALL)
    # 2. Remove cross-references
    text = re.sub(r'\\x\+?\s+.*?\\x\*', '', text, flags=re.DOTALL)
    
    # 3. Remove word tags with attributes like strong's numbers:
    # E.g. \w word|strong="H123"\w* or \+w word|strong="H123"\+w*
    text = re.sub(r'\\\+?w\s+([^|]+)(?:\|[a-zA-Z0-9_=-]+(?:="[^"]*")*)*\\\+?w\*', r'\1', text)
    
    # 4. Remove closed inline tags but keep their contents:
    # E.g. \add words\add* -> words
    old_text = ""
    while text != old_text:
        old_text = text
        text = re.sub(r'\\(\+?[a-zA-Z]+)\b\s*(.*?)\\(\+?[a-zA-Z]+)\*', r'\2', text)
        
    # 5. Remove any standalone tags (like \p, \q, \b, \d)
    text = re.sub(r'\\(\+?[a-zA-Z]+\d*)\b', '', text)
    
    # 6. Remove paragraph symbols
    text = text.replace("¶", "")
    
    # 7. Normalize spaces
    text = ' '.join(text.split()).strip()
    return text

def parse_usfm_source(zip_path):
    if not os.path.exists(zip_path):
        print(f"Error: {zip_path} does not exist.")
        return None
    
    db_data = {}
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        files = [f.filename for f in zip_ref.infolist() if f.filename.endswith('.usfm')]
        
        code_to_file = {}
        for fname in files:
            content_preview = zip_ref.read(fname).decode('utf-8')[:500]
            id_match = re.search(r'\\id\s+([A-Z0-9]{3})\b', content_preview)
            if id_match:
                code = id_match.group(1)
                code_to_file[code] = fname
                
        for code in USFM_CODES:
            if code not in code_to_file:
                continue
            book_number, book_name = CODE_TO_BOOK[code]
            fname = code_to_file[code]
            db_data[book_number] = {}
            content = zip_ref.read(fname).decode('utf-8')
            
            chapters = re.split(r'\\c\s+(\d+)', content)
            for idx in range(1, len(chapters), 2):
                ch_num = int(chapters[idx])
                ch_text = chapters[idx+1]
                db_data[book_number][ch_num] = {}
                ch_text_clean = clean_chapter_headings(ch_text)
                
                verses = re.split(r'\\v\s+(\d+(?:-\d+)?)\s+', ch_text_clean)
                for v_idx in range(1, len(verses), 2):
                    v_num_str = verses[v_idx]
                    v_text = verses[v_idx+1]
                    
                    cleaned_txt = clean_verse_text(v_text)
                    
                    # Split verse range
                    if '-' in v_num_str:
                        try:
                            start, end = map(int, v_num_str.split('-'))
                            for v in range(start, end + 1):
                                db_data[book_number][ch_num][v] = cleaned_txt
                        except ValueError:
                            pass
                    else:
                        try:
                            v = int(v_num_str)
                            db_data[book_number][ch_num][v] = cleaned_txt
                        except ValueError:
                            pass
    return db_data

def is_placeholder(text):
    if not text:
        return True
    placeholders = [
        "this verse is not available in this translation",
        "this verse may not be a part of this translation",
        "not available yet"
    ]
    t = text.lower()
    return any(p in t for p in placeholders)

def main():
    print("Loading books metadata...")
    books_meta = load_books_metadata(BIBLE_SERVICE_PATH)
    init_book_maps(books_meta)
    
    for key, info in TRANSLATIONS.items():
        db_path = os.path.join(DB_DIR, info["db_name"])
        zip_path = os.path.join(REF_DIR, info["zip_name"])
        
        print(f"\nRemediating database for '{key}' using official USFM reference...")
        
        raw_usfm = parse_usfm_source(zip_path)
        if not raw_usfm:
            print(f"Error: Failed to parse USFM for {key}. Skipping.")
            continue
            
        if not os.path.exists(db_path):
            print(f"Error: SQLite database {db_path} does not exist. Skipping.")
            continue
            
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Load local verses
        cursor.execute("SELECT book_number, chapter, verse, text FROM verses;")
        local_verses = {}
        for r in cursor.fetchall():
            bnum, ch, v, txt = int(r[0]), int(r[1]), int(r[2]), r[3] or ""
            local_verses[(bnum, ch, v)] = txt
            
        # Get union of all coordinates
        all_coords = set()
        for bnum in raw_usfm:
            for ch in raw_usfm[bnum]:
                for v in raw_usfm[bnum][ch]:
                    all_coords.add((bnum, ch, v))
        all_coords |= set(local_verses.keys())
        
        updates_count = 0
        inserts_count = 0
        placeholder_replacements_count = 0
        
        for coord in sorted(all_coords):
            bnum, ch, v = coord
            bname = BOOK_NAME_BY_NUM.get(bnum)
            if not bname:
                continue
                
            usfm_txt = raw_usfm.get(bnum, {}).get(ch, {}).get(v)
            db_txt = local_verses.get(coord)
            
            if usfm_txt is not None:
                if db_txt is not None:
                    # Row exists, update if text differs
                    if db_txt != usfm_txt:
                        cursor.execute(
                            "UPDATE verses SET text = ? WHERE book_number = ? AND chapter = ? AND verse = ?;",
                            (usfm_txt, bnum, ch, v)
                        )
                        updates_count += 1
                else:
                    # Row does not exist, insert
                    cursor.execute(
                        "INSERT INTO verses (book_number, book_name, chapter, verse, text) VALUES (?, ?, ?, ?, ?);",
                        (bnum, bname, ch, v, usfm_txt)
                    )
                    inserts_count += 1
            else:
                # Row exists in SQLite but is missing/omitted in official USFM
                placeholder = "This verse is not available in this translation."
                if db_txt is not None and not is_placeholder(db_txt):
                    cursor.execute(
                        "UPDATE verses SET text = ? WHERE book_number = ? AND chapter = ? AND verse = ?;",
                        (placeholder, bnum, ch, v)
                    )
                    placeholder_replacements_count += 1
                    
        print(f"Remediation stats for '{key}': Updates={updates_count}, Inserts={inserts_count}, Placeholders={placeholder_replacements_count}")
        conn.commit()
        
        # Verify book count
        cursor.execute("SELECT count(distinct book_number) FROM verses;")
        book_count = cursor.fetchone()[0]
        if book_count != 66:
            print(f"Warning: book count is {book_count}, rollback changes!")
            conn.rollback()
        else:
            print("Database integrity check passed (66 books).")
            
        conn.close()
        
    print("\nAll English database remediations complete.")

if __name__ == "__main__":
    main()
