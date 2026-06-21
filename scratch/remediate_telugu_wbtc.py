import os
import re
import sqlite3
import sys
import xml.etree.ElementTree as ET

DB_PATH = "/home/david/Music/Bible Quiz/assets/bible/telugu_wbtc.sqlite"
XML_PATH = "/tmp/bible_ref/Telugu Bible (WBTC).xml"
BIBLE_SERVICE_PATH = "/home/david/Music/Bible Quiz/lib/services/bible_service.dart"

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

def main():
    if not os.path.exists(XML_PATH):
        print(f"Error: Reference XML not found at {XML_PATH}")
        sys.exit(1)
    if not os.path.exists(DB_PATH):
        print(f"Error: Local DB not found at {DB_PATH}")
        sys.exit(1)

    print("Loading book metadata...")
    books = load_books_metadata(BIBLE_SERVICE_PATH)
    book_num_map = {b['book_number']: b for b in books}

    print("Parsing reference XML...")
    tree = ET.parse(XML_PATH)
    root = tree.getroot()
    ref_data = {}
    for book in root.findall('.//BIBLEBOOK'):
        bnum_str = book.attrib.get('bnumber')
        if not bnum_str:
            continue
        bnum = int(bnum_str)
        if bnum < 1 or bnum > 66:
            continue
        ref_data[bnum] = {}
        for chapter in book.findall('.//CHAPTER'):
            cnum = int(chapter.attrib.get('cnumber'))
            ref_data[bnum][cnum] = {}
            for verse in chapter.findall('.//VERS'):
                vnum = int(verse.attrib.get('vnumber'))
                text = "".join(verse.itertext()).strip()
                ref_data[bnum][cnum][vnum] = text

    print("Connecting to local database...")
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Load all current local verses to detect deletions/omissions
    cursor.execute("SELECT book_number, chapter, verse, text FROM verses;")
    local_verses = {}
    for r in cursor.fetchall():
        bnum, ch, v, txt = int(r[0]), int(r[1]), int(r[2]), r[3] or ""
        local_verses[(bnum, ch, v)] = txt

    # Set of all coordinates in reference XML
    ref_coords = set()
    for bnum in ref_data:
        for ch in ref_data[bnum]:
            for v in ref_data[bnum][ch]:
                ref_coords.add((bnum, ch, v))

    # All unique coordinates to process
    all_coords = set(local_verses.keys()) | ref_coords

    print(f"Processing {len(all_coords)} verses...")
    updates_count = 0
    inserts_count = 0
    deletions_replaced_count = 0
    placeholder_replacements_count = 0

    for coord in sorted(all_coords):
        bnum, ch, v = coord
        meta = book_num_map.get(bnum)
        if not meta:
            continue
        
        book_name = meta['nameEn']
        ref_text = ref_data.get(bnum, {}).get(ch, {}).get(v)
        local_text = local_verses.get(coord)

        # Normalize ref_text formatting
        if ref_text is not None:
            ref_text = re.sub(r'\s+', ' ', ref_text).strip()
            
            # Strip parenthesized English book prefix
            ref_text = ref_text.replace("(Song of Solomon )", "").strip()
            
            # If the reference XML itself contains the English placeholder, convert it to Telugu
            if "[This verse may not be a part of this translation]" in ref_text:
                ref_text = "ఈ వచనం ఈ అనువాదంలో లేదు"
                placeholder_replacements_count += 1

        if ref_text is not None:
            # Present in reference XML
            if local_text is not None:
                # Update if different or has formatting issues
                norm_local = re.sub(r'\s+', ' ', local_text).strip()
                if norm_local != ref_text or local_text != ref_text:
                    cursor.execute(
                        "UPDATE verses SET text = ? WHERE book_number = ? AND chapter = ? AND verse = ?;",
                        (ref_text, bnum, ch, v)
                    )
                    updates_count += 1
            else:
                # Insert missing verse
                cursor.execute(
                    "INSERT INTO verses (book_number, book_name, chapter, verse, text) VALUES (?, ?, ?, ?, ?);",
                    (bnum, book_name, ch, v, ref_text)
                )
                inserts_count += 1
        else:
            # Legitimate omission in reference XML, but exists in local SQLite
            # Replace with proper Telugu placeholder: "ఈ వచనం ఈ అనువాదంలో లేదు"
            placeholder = "ఈ వచనం ఈ అనువాదంలో లేదు"
            if local_text != placeholder:
                cursor.execute(
                    "UPDATE verses SET text = ? WHERE book_number = ? AND chapter = ? AND verse = ?;",
                    (placeholder, bnum, ch, v)
                )
                deletions_replaced_count += 1

    print(f"Commit changes: updates={updates_count}, inserts={inserts_count}, placeholder_replacements={deletions_replaced_count}, xml_placeholder_fixes={placeholder_replacements_count}")
    conn.commit()

    # Integrity check: make sure we still have 66 books and correct chapter structure
    cursor.execute("SELECT count(distinct book_number) FROM verses;")
    book_count = cursor.fetchone()[0]
    if book_count != 66:
        print(f"Warning: book count is {book_count}, expected 66!")
        conn.rollback()
        conn.close()
        sys.exit(1)
        
    print("Database integrity check passed.")
    conn.close()
    print("Remediation of telugu_wbtc completed successfully.")

if __name__ == "__main__":
    main()
