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

def run_comparison():
    db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"
    html_dir = "/home/david/Music/tel_new"
    
    print("Loading database verses...")
    db_verses = load_db_verses(db_path)
    print(f"Loaded {len(db_verses)} verses from SQLite database.")
    
    html_verses = {}
    print("Parsing HTML files...")
    
    # Loop over all books (01 to 66)
    for b in range(1, 67):
        book_folder = f"{b:02d}"
        book_path = os.path.join(html_dir, book_folder)
        if not os.path.exists(book_path):
            continue
        
        # Loop over htm files in this directory
        for file_name in sorted(os.listdir(book_path), key=lambda x: int(x.split(".")[0]) if x.split(".")[0].isdigit() else 999):
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
                
    print(f"Parsed {len(html_verses)} verses from HTML source.")
    
    # Analyze differences
    missing_in_db = []
    missing_in_html = []
    spacing_mismatches = []
    content_mismatches = []
    exact_matches = 0
    
    all_keys = sorted(list(set(db_verses.keys()) | set(html_verses.keys())))
    
    for key in all_keys:
        in_db = key in db_verses
        in_html = key in html_verses
        
        if in_db and not in_html:
            missing_in_html.append(key)
        elif in_html and not in_db:
            missing_in_db.append(key)
        else:
            db_text = db_verses[key]["text"]
            html_text = html_verses[key]
            
            # Clean up db text and html text for strict matching
            db_clean = " ".join(db_text.split())
            html_clean = " ".join(html_text.split())
            
            if db_clean == html_clean:
                exact_matches += 1
            else:
                # Check if stripped versions are identical (spacing differences)
                db_stripped = "".join(db_clean.split())
                html_stripped = "".join(html_clean.split())
                
                info = {
                    "key": key,
                    "book_name": db_verses[key]["book_name"],
                    "db": db_clean,
                    "html": html_clean
                }
                
                if db_stripped == html_stripped:
                    spacing_mismatches.append(info)
                else:
                    content_mismatches.append(info)
                    
    # Generate markdown report content
    report = []
    report.append("# Telugu OV Verification Report")
    report.append("\nThis report summarizes the verification of the local SQLite database (`telugu_ov.sqlite`) against the reference HTML source files from Wordproject (`tel_new`).\n")
    
    report.append("## Summary Table")
    report.append("| Category | Count | Status |")
    report.append("| --- | --- | --- |")
    report.append(f"| **Total Verses in SQLite** | {len(db_verses)} | Checked |")
    report.append(f"| **Total Verses in HTML Source** | {len(html_verses)} | Checked |")
    report.append(f"| **Exact Matches** | {exact_matches} | ✅ OK |")
    report.append(f"| **Spacing Mismatches (Merged Words)** | {len(spacing_mismatches)} | ⚠️ Needs Spacing Fix |")
    report.append(f"| **Content Mismatches** | {len(content_mismatches)} | 🔴 Discrepancy |")
    report.append(f"| **Missing in SQLite DB** | {len(missing_in_db)} | 🔴 Missing |")
    report.append(f"| **Missing in HTML Source** | {len(missing_in_html)} | ⚠️ Omitted in HTML |")
    
    # Detailed section for Spacing Mismatches
    if spacing_mismatches:
        report.append("\n## Spacing Mismatches (Merged Words)")
        report.append("These verses are identical when whitespace is removed, meaning the difference is purely due to spacing (e.g. merged words in SQLite DB).\n")
        report.append("| Reference | SQLite Text | HTML (Correct) Text |")
        report.append("| --- | --- | --- |")
        for m in spacing_mismatches[:100]: # Cap detailed list to first 100 for readability
            ref = f"{m['book_name']} {m['key'][1]}:{m['key'][2]}"
            report.append(f"| {ref} | `{m['db']}` | `{m['html']}` |")
        if len(spacing_mismatches) > 100:
            report.append(f"| *and {len(spacing_mismatches) - 100} more spacing mismatches...* | | |")
            
    # Detailed section for Content Mismatches
    if content_mismatches:
        report.append("\n## Content Mismatches")
        report.append("These verses have different text/characters (e.g. spelling differences, typos, or punctuation issues).\n")
        report.append("| Reference | SQLite Text | HTML Text |")
        report.append("| --- | --- | --- |")
        for m in content_mismatches[:100]:
            ref = f"{m['book_name']} {m['key'][1]}:{m['key'][2]}"
            report.append(f"| {ref} | `{m['db']}` | `{m['html']}` |")
        if len(content_mismatches) > 100:
            report.append(f"| *and {len(content_mismatches) - 100} more content mismatches...* | | |")
            
    # Detailed section for Missing in SQLite
    if missing_in_db:
        report.append("\n## Missing in SQLite Database")
        report.append("These verses exist in the HTML source but are missing in the SQLite database.\n")
        report.append("| Reference | HTML Text |")
        report.append("| --- | --- |")
        for key in missing_in_db:
            ref = f"Book {key[0]} {key[1]}:{key[2]}"
            report.append(f"| {ref} | `{html_verses[key]}` |")
            
    # Detailed section for Missing in HTML
    if missing_in_html:
        report.append("\n## Missing in HTML Source")
        report.append("These verses exist in the SQLite database but are missing in the HTML source files.\n")
        report.append("| Reference | SQLite Text |")
        report.append("| --- | --- |")
        for key in missing_in_html:
            ref = f"{db_verses[key]['book_name']} {key[1]}:{key[2]}"
            report.append(f"| {ref} | `{db_verses[key]['text']}` |")
            
    # Save the report
    report_dir = "/home/david/Music/Bible Quiz/audit_reports"
    os.makedirs(report_dir, exist_ok=True)
    report_path = os.path.join(report_dir, "telugu_ov_html_comparison.md")
    
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(report))
        
    print(f"\nAudit complete! Report written to: {report_path}")
    print(f"Summary:")
    print(f"  Exact Matches: {exact_matches}")
    print(f"  Spacing Mismatches: {len(spacing_mismatches)}")
    print(f"  Content Mismatches: {len(content_mismatches)}")
    print(f"  Missing in SQLite: {len(missing_in_db)}")
    print(f"  Missing in HTML: {len(missing_in_html)}")

if __name__ == "__main__":
    run_comparison()
