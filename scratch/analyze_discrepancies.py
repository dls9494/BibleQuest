import os
import sqlite3
from bs4 import BeautifulSoup

def parse_html_chapter(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        html_content = f.read()
    
    soup = BeautifulSoup(html_content, "html.parser")
    text_body = soup.find(id="textBody") or soup.find(class_="textBody")
    
    if not text_body:
        return {}
    
    verses = {}
    verse_spans = text_body.find_all("span", class_="verse")
    
    for span in verse_spans:
        try:
            v_num = int(span.get("id") or span.text.strip())
        except ValueError:
            continue
        
        parts = []
        curr = span.next_sibling
        while curr and curr not in verse_spans:
            if hasattr(curr, "text"):
                parts.append(curr.get_text())
            elif isinstance(curr, str):
                parts.append(curr)
            curr = curr.next_sibling
        
        verse_text = "".join(parts)
        verse_text = verse_text.replace("\xa0", " ")
        verse_text = " ".join(verse_text.split())
        verses[v_num] = verse_text.strip()
        
    return verses

def load_db_verses(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT book_number, book_name, chapter, verse, text FROM verses ORDER BY book_number, chapter, verse")
    rows = cursor.fetchall()
    conn.close()
    
    db_data = {}
    for book_number, book_name, chapter, verse, text in rows:
        db_data[(book_number, chapter, verse)] = {
            "text": text.strip() if text else "",
            "book_name": book_name
        }
    return db_data

def analyze():
    db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"
    html_dir = "/home/david/Music/tel_new"
    
    db_verses = load_db_verses(db_path)
    html_verses = {}
    
    for b in range(1, 67):
        book_folder = f"{b:02d}"
        book_path = os.path.join(html_dir, book_folder)
        if not os.path.exists(book_path):
            continue
        for file_name in os.listdir(book_path):
            if not file_name.endswith(".htm") and not file_name.endswith(".html"):
                continue
            chapter_str = file_name.split(".")[0]
            if not chapter_str.isdigit():
                continue
            chapter = int(chapter_str)
            file_path = os.path.join(book_path, file_name)
            parsed_verses = parse_html_chapter(file_path)
            for verse, text in parsed_verses.items():
                html_verses[(b, chapter, verse)] = text

    truncations = 0
    other_diffs = 0
    examples = []
    
    for key, db_val in db_verses.items():
        if key not in html_verses:
            continue
        db_text = db_val["text"]
        html_text = html_verses[key]
        
        db_clean = " ".join(db_text.split())
        html_clean = " ".join(html_text.split())
        
        if db_clean != html_clean:
            db_stripped = "".join(db_clean.split())
            html_stripped = "".join(html_clean.split())
            
            if db_stripped != html_stripped:
                # Content mismatch
                # Check if html_clean is a prefix of db_clean (truncation)
                # or if the end of html_clean is cut off compared to db_clean
                is_truncation = False
                if len(html_clean) < len(db_clean):
                    # Check if db_clean starts with html_clean, or if html_clean matches the beginning portion
                    if db_clean.startswith(html_clean[:-2]):
                        is_truncation = True
                
                if is_truncation:
                    truncations += 1
                    if len(examples) < 10:
                        examples.append({
                            "ref": f"{db_val['book_name']} {key[1]}:{key[2]}",
                            "db": db_clean,
                            "html": html_clean
                        })
                else:
                    other_diffs += 1
                    
    print(f"Total Content Mismatches Analyzed: {truncations + other_diffs}")
    print(f"  HTML Truncations (cut off at the end): {truncations} ({truncations/(truncations+other_diffs)*100:.1f}%)")
    print(f"  Other Content Discrepancies (typos, spellings): {other_diffs} ({other_diffs/(truncations+other_diffs)*100:.1f}%)")
    print("\nExamples of HTML Truncations:")
    for ex in examples:
        print(f"  - {ex['ref']}:")
        print(f"    SQLite (Correct): {ex['db']}")
        print(f"    HTML (Truncated): {ex['html']}")

if __name__ == "__main__":
    analyze()
