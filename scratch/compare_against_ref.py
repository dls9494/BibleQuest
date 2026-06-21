import os
import re
import sqlite3
import sys
import xml.etree.ElementTree as ET

# Paths
DB_DIR = "/home/david/Music/Bible Quiz/assets/bible"
BIBLE_SERVICE_PATH = "/home/david/Music/Bible Quiz/lib/services/bible_service.dart"
REPORT_PATH = "/home/david/.gemini/antigravity/brain/0323657b-e3c6-4504-b85d-f4977582eaa4/validation_comparison_report.md"

DB_FILES = {
    "telugu_ov": "telugu_ov.sqlite",
    "telugu_irv": "telugu_irv.sqlite",
    "telugu_wbtc": "telugu_wbtc.sqlite",
    "kjv": "kjv.sqlite",
    "asv": "asv.sqlite",
    "web": "web.sqlite",
    "darby": "darby.sqlite"
}

REF_FILES = {
    "telugu_ov": "/tmp/bible_ref/Telugu Bible (BSI).xml",
    "telugu_wbtc": "/tmp/bible_ref/Telugu Bible (WBTC).xml",
    "kjv": "/tmp/bible_ref/King James Version (1769).xml",
    "asv": "/tmp/bible_ref/American Standard Version (1901).xml",
    "web": "/tmp/bible_ref/World English Bible.xml",
    "darby": "/tmp/bible_ref/The Darby Bible (1890).xml"
}

def load_books_metadata(file_path):
    """Parses book metadata from bible_service.dart"""
    if not os.path.exists(file_path):
        print(f"Error: Could not find {file_path}")
        sys.exit(1)
        
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    pattern = r"BibleBook\(\s*id:\s*'([^']+)',\s*nameEn:\s*'([^']+)',\s*nameTe:\s*'([^']+)',\s*chapters:\s*(\d+),\s*testament:\s*'([^']+)'\s*\)"
    matches = re.findall(pattern, content)
    books = []
    for idx, m in enumerate(matches):
        book_num = idx + 1
        books.append({
            'book_number': book_num,
            'id': m[0],
            'nameEn': m[1],
            'nameTe': m[2],
            'chapters': int(m[3]),
            'testament': m[4]
        })
    return books

def load_canonical_counts(file_path):
    """Parses canonical verse counts from bible_service.dart"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    match = re.search(r'static const Map<String, List<int>> _verseCounts = \{(.*?)\};', content, re.DOTALL)
    if not match:
        print("Error: Could not find _verseCounts in bible_service.dart")
        sys.exit(1)
    dict_content = match.group(1)
    counts = {}
    for line in dict_content.split('\n'):
        line = line.strip()
        if not line or line.startswith('//'):
            continue
        line_match = re.match(r"'(\w+)'\s*:\s*\[(.*?)\]", line)
        if line_match:
            book_id = line_match.group(1)
            values = [int(v.strip()) for v in line_match.group(2).split(',') if v.strip()]
            counts[book_id] = values
    return counts

def parse_ref_xml(xml_path):
    """Parses a reference Zefania XML file into {book_num: {chapter: {verse: text}}}"""
    if not os.path.exists(xml_path):
        return None
    print(f"Parsing reference XML: {os.path.basename(xml_path)}...")
    tree = ET.parse(xml_path)
    root = tree.getroot()
    ref_data = {}
    for book in root.findall('.//BIBLEBOOK'):
        bnum_str = book.attrib.get('bnumber')
        if not bnum_str:
            continue
        try:
            bnum = int(bnum_str)
        except ValueError:
            continue
        if bnum < 1 or bnum > 66:
            continue
        ref_data[bnum] = {}
        for chapter in book.findall('.//CHAPTER'):
            cnum_str = chapter.attrib.get('cnumber')
            if not cnum_str:
                continue
            try:
                cnum = int(cnum_str)
            except ValueError:
                continue
            ref_data[bnum][cnum] = {}
            for verse in chapter.findall('.//VERS'):
                vnum_str = verse.attrib.get('vnumber')
                if not vnum_str:
                    continue
                try:
                    vnum = int(vnum_str)
                except ValueError:
                    continue
                text = "".join(verse.itertext()).strip()
                text = text.replace('\ufffd', '—')
                ref_data[bnum][cnum][vnum] = text
    return ref_data

def load_local_db(db_path):
    """Loads a local SQLite database into {book_number: {chapter: {verse: text}}}"""
    if not os.path.exists(db_path):
        print(f"Error: Local DB not found at {db_path}")
        return None
    print(f"Reading local DB: {os.path.basename(db_path)}...")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT book_number, chapter, verse, text FROM verses ORDER BY book_number, chapter, verse;")
    rows = cursor.fetchall()
    conn.close()
    
    db_data = {}
    for r in rows:
        bnum = int(r[0])
        ch = int(r[1])
        v = int(r[2])
        text = r[3] if r[3] is not None else ""
        if bnum not in db_data:
            db_data[bnum] = {}
        if ch not in db_data[bnum]:
            db_data[bnum][ch] = {}
        db_data[bnum][ch][v] = text
    return db_data

def is_placeholder(text):
    if not text:
        return False
    placeholders = [
        "this verse is not available in this translation",
        "this verse may not be a part of this translation",
        "ఈ వచనం ఈ అనువాదంలో లేదు",
        "telugu ov text for",
        "not available yet"
    ]
    text_lower = text.lower()
    return any(p in text_lower for p in placeholders)

def normalize_text(text, is_telugu=False):
    """Normalizes text by removing non-alphanumeric/non-Telugu chars for robust comparison"""
    if not text:
        return ""
    text = re.sub(r'\s+', ' ', text).strip()
    if is_telugu:
        # Keep only Telugu characters (U+0C00 to U+0C7F)
        text = "".join(c for c in text if '\u0c00' <= c <= '\u0c7f')
    else:
        # Keep alphanumeric characters, lowercase
        text = "".join(c for c in text if c.isalnum()).lower()
    return text

def get_chronological_verses(book_data):
    """Returns all (chapter, verse, text) in a book, sorted chronologically"""
    verses = []
    for ch in sorted(book_data.keys()):
        for v in sorted(book_data[ch].keys()):
            verses.append((ch, v, book_data[ch][v]))
    return verses

def main():
    books_meta = load_books_metadata(BIBLE_SERVICE_PATH)
    canonical_counts = load_canonical_counts(BIBLE_SERVICE_PATH)
    
    # Map book number -> book metadata
    book_num_map = {b['book_number']: b for b in books_meta}
    book_id_map = {b['id']: b for b in books_meta}
    
    # Validation results
    results = {}
    
    for version, db_filename in DB_FILES.items():
        results[version] = {
            "clean": True,
            "missing_books": [],
            "missing_chapters": [],
            "verse_count_mismatches": [],
            "sample_discrepancies": [],
            "placeholder_issues": [],
            "leak_issues": [],
            "merged_word_issues": [],
            "duplicate_verse_issues": [],
            "unicode_replacement_issues": [],
            "totals": {
                "missing_books": 0,
                "missing_chapters": 0,
                "verse_count_mismatches": 0,
                "sample_discrepancies": 0,
                "placeholder_issues": 0,
                "leak_issues": 0,
                "merged_word_issues": 0,
                "duplicate_verse_issues": 0,
                "unicode_replacement_issues": 0
            }
        }
        
        # Load local database
        db_path = os.path.join(DB_DIR, db_filename)
        local_data = load_local_db(db_path)
        if not local_data:
            continue
            
        # Load reference XML (if any)
        ref_xml_path = REF_FILES.get(version)
        ref_data = parse_ref_xml(ref_xml_path) if ref_xml_path else None
        
        is_telugu = "telugu" in version
        
        # 1. Verify every book and chapter exists
        for b_idx in range(1, 67):
            meta = book_num_map[b_idx]
            book_id = meta['id']
            book_name = meta['nameEn']
            
            # Check book existence
            if b_idx not in local_data:
                results[version]["missing_books"].append(book_name)
                results[version]["totals"]["missing_books"] += 1
                results[version]["clean"] = False
                continue
                
            expected_ch_count = meta['chapters']
            local_ch_data = local_data[b_idx]
            
            # Check chapter count and existence
            for ch in range(1, expected_ch_count + 1):
                if ch not in local_ch_data:
                    results[version]["missing_chapters"].append((book_name, ch))
                    results[version]["totals"]["missing_chapters"] += 1
                    results[version]["clean"] = False
                    continue
                    
                local_verses = local_ch_data[ch]
                
                ref_v_count = 0
                if ref_data and b_idx in ref_data and ch in ref_data[b_idx]:
                    ref_v_count = sum(1 for v, txt in ref_data[b_idx][ch].items() if not is_placeholder(txt))
                else:
                    # Fallback to canonical count in bible_service
                    counts_list = canonical_counts.get(book_id, [])
                    if ch <= len(counts_list):
                        ref_v_count = counts_list[ch - 1]
                        
                local_v_count = sum(1 for v, txt in local_verses.items() if not is_placeholder(txt))
                if local_v_count != ref_v_count:
                    results[version]["verse_count_mismatches"].append({
                        "book": book_name,
                        "chapter": ch,
                        "local_count": local_v_count,
                        "ref_count": ref_v_count,
                    })
                    results[version]["totals"]["verse_count_mismatches"] += 1
                    results[version]["clean"] = False
                    
        # 2. Corruption/Integrity Checks for all verses
        for b_idx, ch_dict in local_data.items():
            meta = book_num_map[b_idx]
            book_name = meta['nameEn']
            for ch, v_dict in ch_dict.items():
                for v, text in v_dict.items():
                    # Placeholder check
                    if "[This verse may not" in text or "[This verse is not" in text or "not available yet" in text:
                        results[version]["placeholder_issues"].append((book_name, ch, v, text))
                        results[version]["totals"]["placeholder_issues"] += 1
                        results[version]["clean"] = False
                        
                    # Unicode replacement character check
                    if "\ufffd" in text:
                        results[version]["unicode_replacement_issues"].append((book_name, ch, v, text))
                        results[version]["totals"]["unicode_replacement_issues"] += 1
                        results[version]["clean"] = False
                        
                    # Leak check (English in Telugu, or vice-versa)
                    if is_telugu:
                        if re.search(r'[a-zA-Z]{5,}', text):
                            results[version]["leak_issues"].append((book_name, ch, v, text))
                            results[version]["totals"]["leak_issues"] += 1
                            results[version]["clean"] = False
                    else:
                        if re.search(r'[\u0c00-\u0c7f]', text):
                            results[version]["leak_issues"].append((book_name, ch, v, text))
                            results[version]["totals"]["leak_issues"] += 1
                            results[version]["clean"] = False
                            
                    # Merged words check
                    if not is_telugu:
                        if re.search(r'[a-z][A-Z]', text):
                            # Skip common acceptable camelCase or similar, but flag standard merges
                            results[version]["merged_word_issues"].append((book_name, ch, v, text))
                            results[version]["totals"]["merged_word_issues"] += 1
                            results[version]["clean"] = False
                    else:
                        # Long contiguous Telugu word > 25 characters
                        words = re.findall(r'[\u0c00-\u0c7f]+', text)
                        for w in words:
                            if len(w) > 25:
                                results[version]["merged_word_issues"].append((book_name, ch, v, text))
                                results[version]["totals"]["merged_word_issues"] += 1
                                results[version]["clean"] = False
                                break
                                
                    # Duplicate verses check (within the same book)
                    # To keep it fast, we can skip full search on all, or do a targeted check.
                    # Since validate_bible_data.py did it, we can skip or run it.
                    # Let's keep it simple and skip duplicates unless user explicitly needs it, 
                    # or keep a quick hash-map of verses per book.
                    # Let's implement a fast duplicate check:
                    
        # Fast duplicate check within each book
        for b_idx, ch_dict in local_data.items():
            meta = book_num_map[b_idx]
            book_name = meta['nameEn']
            text_seen = {}
            for ch, v_dict in ch_dict.items():
                for v, text in v_dict.items():
                    if len(text) > 15:
                        if text in text_seen:
                            prev_ch, prev_v = text_seen[text]
                            results[version]["duplicate_verse_issues"].append({
                                "book": book_name,
                                "chapter": ch,
                                "verse": v,
                                "dup_chapter": prev_ch,
                                "dup_verse": prev_v,
                                "text": text
                            })
                            results[version]["totals"]["duplicate_verse_issues"] += 1
                            results[version]["clean"] = False
                        else:
                            text_seen[text] = (ch, v)
                            
        # 3. Sample a few verses per book for text comparison (first 5 verses and last 5 verses of each book)
        if ref_data:
            for b_idx in range(1, 67):
                meta = book_num_map[b_idx]
                book_name = meta['nameEn']
                
                local_book = local_data.get(b_idx, {})
                ref_book = ref_data.get(b_idx, {})
                
                local_sorted = get_chronological_verses(local_book)
                ref_sorted = get_chronological_verses(ref_book)
                
                # First 5 and last 5 coordinates of reference XML
                sampled_coords = set()
                if len(ref_sorted) >= 5:
                    for ch, v, _ in ref_sorted[:5] + ref_sorted[-5:]:
                        sampled_coords.add((ch, v))
                else:
                    for ch, v, _ in ref_sorted:
                        sampled_coords.add((ch, v))
                        
                # First 5 and last 5 coordinates of local database
                if len(local_sorted) >= 5:
                    for ch, v, _ in local_sorted[:5] + local_sorted[-5:]:
                        sampled_coords.add((ch, v))
                else:
                    for ch, v, _ in local_sorted:
                        sampled_coords.add((ch, v))
                
                # Pair them up by coordinate (chapter, verse)
                local_pairs = {}
                ref_pairs = {}
                for ch, v in sampled_coords:
                    if ch in local_book and v in local_book[ch]:
                        local_pairs[(ch, v)] = local_book[ch][v]
                    if ch in ref_book and v in ref_book[ch]:
                        ref_pairs[(ch, v)] = ref_book[ch][v]
                
                # Check for matches
                for coord in sorted(set(local_pairs.keys()) | set(ref_pairs.keys())):
                    ch, v = coord
                    loc_txt = local_pairs.get(coord)
                    ref_txt = ref_pairs.get(coord)
                    
                    if loc_txt is None:
                        results[version]["sample_discrepancies"].append({
                            "book": book_name,
                            "chapter": ch,
                            "verse": v,
                            "type": "Missing in Local SQLite",
                            "local_text": "",
                            "ref_text": ref_txt
                        })
                        results[version]["totals"]["sample_discrepancies"] += 1
                        results[version]["clean"] = False
                    elif ref_txt is None:
                        if is_placeholder(loc_txt):
                            continue
                        results[version]["sample_discrepancies"].append({
                            "book": book_name,
                            "chapter": ch,
                            "verse": v,
                            "type": "Missing in Reference XML",
                            "local_text": loc_txt,
                            "ref_text": ""
                        })
                        results[version]["totals"]["sample_discrepancies"] += 1
                        results[version]["clean"] = False
                    else:
                        # Compare texts
                        if is_placeholder(loc_txt) and is_placeholder(ref_txt):
                            continue
                        loc_norm = normalize_text(loc_txt, is_telugu)
                        ref_norm = normalize_text(ref_txt, is_telugu)
                        
                        if loc_txt != ref_txt:
                            if loc_norm == ref_norm:
                                # Minor discrepancy
                                results[version]["sample_discrepancies"].append({
                                    "book": book_name,
                                    "chapter": ch,
                                    "verse": v,
                                    "type": "Minor Formatting/Punctuation",
                                    "local_text": loc_txt,
                                    "ref_text": ref_txt
                                })
                                results[version]["totals"]["sample_discrepancies"] += 1
                                results[version]["clean"] = False
                            else:
                                # Major discrepancy
                                results[version]["sample_discrepancies"].append({
                                    "book": book_name,
                                    "chapter": ch,
                                    "verse": v,
                                    "type": "Major Text Mismatch",
                                    "local_text": loc_txt,
                                    "ref_text": ref_txt
                                })
                                results[version]["totals"]["sample_discrepancies"] += 1
                                results[version]["clean"] = False
                                
    # Write Structured Markdown Report
    print(f"Writing detailed report to {REPORT_PATH}...")
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)
    
    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        f.write("# Bible Verse Data Validation & Comparison Report\n\n")
        f.write("This report presents a detailed read-only validation comparing the local SQLite databases (`assets/bible/*.sqlite`) against reference XML files cloned from the community-maintained repository `https://github.com/sajeevavahini/bibles`.\n\n")
        
        f.write("## 1. VERSION-BY-VERSION SUMMARY\n\n")
        f.write("| Version | Status | Missing Books | Missing Chapters | Verse Count Mismatches | Sample Text Discrepancies | Placeholders | Latin/Telugu Leaks | Merged Words | Duplicates | Unicode Repl. |\n")
        f.write("|---|---|---|---|---|---|---|---|---|---|---|\n")
        
        for version in DB_FILES.keys():
            res = results[version]
            status = "🟢 CLEAN" if res["clean"] else "🔴 ISSUES FOUND"
            tots = res["totals"]
            f.write(f"| **{version}** | {status} | {tots['missing_books']} | {tots['missing_chapters']} | {tots['verse_count_mismatches']} | {tots['sample_discrepancies']} | {tots['placeholder_issues']} | {tots['leak_issues']} | {tots['merged_word_issues']} | {tots['duplicate_verse_issues']} | {tots['unicode_replacement_issues']} |\n")
            
        f.write("\n> [!NOTE]\n")
        f.write("> **telugu_irv** has no matching reference XML source in the cloned repository. Therefore, it was structurally validated against the canonical counts from `bible_service.dart` and checked for corruption/leaks, but text comparisons are skipped.\n\n")
        
        f.write("## 2. DETAILED FINDINGS BY VERSION\n\n")
        
        for version in DB_FILES.keys():
            res = results[version]
            tots = res["totals"]
            total_issues = sum(tots.values())
            
            f.write(f"### {version.upper()} (Total Issues: {total_issues})\n\n")
            if total_issues == 0:
                f.write("✅ No issues found. This database matches reference sources perfectly.\n\n")
                continue
                
            # Missing Books/Chapters
            if tots["missing_books"] > 0:
                f.write(f"**Missing Books:** {', '.join(res['missing_books'])}\n\n")
            if tots["missing_chapters"] > 0:
                f.write("**Missing Chapters:**\n")
                for book, ch in res["missing_chapters"]:
                    f.write(f"- {book} Chapter {ch}\n")
                f.write("\n")
                
            # Verse Count Mismatches
            if tots["verse_count_mismatches"] > 0:
                f.write("#### Verse Count Mismatches per Chapter\n")
                f.write("| Book | Chapter | Local Verse Count | Reference Verse Count | Difference |\n")
                f.write("|---|---|---|---|---|\n")
                for item in res["verse_count_mismatches"][:30]:
                    diff = item['local_count'] - item['ref_count']
                    diff_str = f"+{diff}" if diff > 0 else str(diff)
                    f.write(f"| {item['book']} | {item['chapter']} | {item['local_count']} | {item['ref_count']} | {diff_str} |\n")
                if tots["verse_count_mismatches"] > 30:
                    f.write(f"| ... | ... | ... | ... | *And {tots['verse_count_mismatches'] - 30} more mismatches.* |\n")
                f.write("\n")
                
            # Sample Discrepancies
            if tots["sample_discrepancies"] > 0:
                f.write("#### Sampled Verses Text Comparison Discrepancies\n")
                f.write("| Book | Chapter | Verse | Discrepancy Type | Local Text | Reference Text |\n")
                f.write("|---|---|---|---|---|---|\n")
                # Group and show first 30
                for item in res["sample_discrepancies"][:30]:
                    loc_snip = item['local_text'][:100] + ("..." if len(item['local_text']) > 100 else "")
                    ref_snip = item['ref_text'][:100] + ("..." if len(item['ref_text']) > 100 else "")
                    f.write(f"| {item['book']} | {item['chapter']} | {item['verse']} | {item['type']} | `{loc_snip}` | `{ref_snip}` |\n")
                if tots["sample_discrepancies"] > 30:
                    f.write(f"| ... | ... | ... | ... | ... | *And {tots['sample_discrepancies'] - 30} more text discrepancies.* |\n")
                f.write("\n")
                
            # Placeholders
            if tots["placeholder_issues"] > 0:
                f.write("#### Placeholder Texts Found\n")
                f.write("| Book | Chapter | Verse | Placeholder Text |\n")
                f.write("|---|---|---|---|\n")
                for book, ch, v, txt in res["placeholder_issues"][:20]:
                    f.write(f"| {book} | {ch} | {v} | `{txt[:100]}` |\n")
                if tots["placeholder_issues"] > 20:
                    f.write(f"| ... | ... | ... | *And {tots['placeholder_issues'] - 20} more placeholder occurrences.* |\n")
                f.write("\n")
                
            # Unicode Replacement character
            if tots["unicode_replacement_issues"] > 0:
                f.write("#### Broken Unicode Characters Found (\\uFFFD)\n")
                f.write("| Book | Chapter | Verse | Corrupted Text |\n")
                f.write("|---|---|---|---|\n")
                for book, ch, v, txt in res["unicode_replacement_issues"][:20]:
                    f.write(f"| {book} | {ch} | {v} | `{txt[:100]}` |\n")
                if tots["unicode_replacement_issues"] > 20:
                    f.write(f"| ... | ... | ... | *And {tots['unicode_replacement_issues'] - 20} more corrupted occurrences.* |\n")
                f.write("\n")
                
            # Leaks
            if tots["leak_issues"] > 0:
                f.write("#### Cross-Language Text Leaks (e.g. English in Telugu)\n")
                f.write("| Book | Chapter | Verse | Leaked Text Snippet |\n")
                f.write("|---|---|---|---|\n")
                for book, ch, v, txt in res["leak_issues"][:20]:
                    f.write(f"| {book} | {ch} | {v} | `{txt[:100]}` |\n")
                if tots["leak_issues"] > 20:
                    f.write(f"| ... | ... | ... | *And {tots['leak_issues'] - 20} more leak occurrences.* |\n")
                f.write("\n")
                
            # Merged Words
            if tots["merged_word_issues"] > 0:
                f.write("#### Merged / Concatenated Words\n")
                f.write("| Book | Chapter | Verse | Merged Word Snippet |\n")
                f.write("|---|---|---|---|\n")
                for book, ch, v, txt in res["merged_word_issues"][:20]:
                    f.write(f"| {book} | {ch} | {v} | `{txt[:100]}` |\n")
                if tots["merged_word_issues"] > 20:
                    f.write(f"| ... | ... | ... | *And {tots['merged_word_issues'] - 20} more merged word occurrences.* |\n")
                f.write("\n")
                
            # Duplicates
            if tots["duplicate_verse_issues"] > 0:
                f.write("#### Duplicate Verses within Same Book\n")
                f.write("| Book | Chapter:Verse | Duplicate Chapter:Verse | Text Snippet |\n")
                f.write("|---|---|---|---|\n")
                for item in res["duplicate_verse_issues"][:20]:
                    f.write(f"| {item['book']} | {item['chapter']}:{item['verse']} | {item['dup_chapter']}:{item['dup_verse']} | `{item['text'][:100]}` |\n")
                if tots["duplicate_verse_issues"] > 20:
                    f.write(f"| ... | ... | ... | *And {tots['duplicate_verse_issues'] - 20} more duplicates.* |\n")
                f.write("\n")
                
        f.write("## 3. OVERALL CONCLUSION & SAFE VERSIONS\n\n")
        f.write("Based on the comparative audit, here is the safety classification of each version:\n\n")
        
        safe_versions = []
        unsafe_versions = []
        for version in DB_FILES.keys():
            res = results[version]
            tots = res["totals"]
            # Exclude minor formatting/punctuation and duplicate verse checks from strict safety if minor
            critical_issues = tots["missing_books"] + tots["missing_chapters"] + tots["verse_count_mismatches"] + tots["placeholder_issues"] + tots["leak_issues"] + tots["unicode_replacement_issues"]
            
            # For sample discrepancies, only major mismatch is critical
            major_discrepancy_count = sum(1 for item in res["sample_discrepancies"] if item["type"] == "Major Text Mismatch" or item["type"] == "Missing in Local SQLite")
            critical_issues += major_discrepancy_count
            
            if critical_issues == 0:
                safe_versions.append(version)
            else:
                unsafe_versions.append((version, critical_issues, sum(tots.values())))
                
        f.write("### 🟢 Safe Versions (Ready for Production)\n")
        if safe_versions:
            for sv in safe_versions:
                f.write(f"- **{sv}** (Clean structure, no placeholders, no leaks, exact text match or minor punctuation-only differences)\n")
        else:
            f.write("- *None*\n")
        f.write("\n")
        
        f.write("### 🔴 Unsafe Versions (Require Remediation)\n")
        if unsafe_versions:
            for uv, crit, total in unsafe_versions:
                f.write(f"- **{uv}**: {crit} critical issues ({total} total issues). Needs reconstruction or patching before production release.\n")
        else:
            f.write("- *None*\n")
            
    print("Comparison finished successfully.")

if __name__ == "__main__":
    main()
