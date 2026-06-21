import os
import re
import sqlite3
import sys

# Define target databases
DB_DIR = "/home/david/Music/Bible Quiz/assets/bible"
DB_FILES = {
    "telugu_ov": "telugu_ov.sqlite",
    "telugu_irv": "telugu_irv.sqlite",
    "telugu_wbtc": "telugu_wbtc.sqlite",
    "kjv": "kjv.sqlite",
    "asv": "asv.sqlite",
    "web": "web.sqlite",
    "darby": "darby.sqlite"
}

BIBLE_SERVICE_PATH = "/home/david/Music/Bible Quiz/lib/services/bible_service.dart"

def load_canonical_counts(file_path):
    """Dynamically parses canonical verse counts from bible_service.dart"""
    if not os.path.exists(file_path):
        print(f"Error: Could not find {file_path}")
        sys.exit(1)
        
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find _verseCounts map using regex
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

def main():
    print("Loading canonical verse counts...")
    canonical_counts = load_canonical_counts(BIBLE_SERVICE_PATH)
    print(f"Loaded counts for {len(canonical_counts)} books.")

    # Initialize data structures for auditing
    all_data = {} # {version: {book_name: {chapter: {verse: text}}}}
    raw_verse_lists = {} # {version: {book_name: {chapter: [verse_num]}}}
    
    # Connect and extract data
    for version, filename in DB_FILES.items():
        db_path = os.path.join(DB_DIR, filename)
        if not os.path.exists(db_path):
            print(f"Error: Database {filename} not found at {db_path}")
            sys.exit(1)
            
        print(f"Reading database: {filename}...")
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if table exists
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='verses';")
        if not cursor.fetchone():
            print(f"Error: Table 'verses' not found in {filename}")
            sys.exit(1)
            
        cursor.execute("SELECT book_name, chapter, verse, text FROM verses ORDER BY book_number, chapter, verse;")
        rows = cursor.fetchall()
        
        all_data[version] = {}
        raw_verse_lists[version] = {}
        
        for r in rows:
            book_name = r[0].strip()
            chapter = int(r[1])
            verse = int(r[2])
            text = r[3] if r[3] is not None else ""
            
            book_lower = book_name.lower().replace(" ", "")
            
            if book_lower not in all_data[version]:
                all_data[version][book_lower] = {}
                raw_verse_lists[version][book_lower] = {}
            if chapter not in all_data[version][book_lower]:
                all_data[version][book_lower][chapter] = {}
                raw_verse_lists[version][book_lower][chapter] = []
                
            all_data[version][book_lower][chapter][verse] = text
            raw_verse_lists[version][book_lower][chapter].append(verse)
            
        conn.close()

    # Track validation issues
    issues = {
        "merged_words": [],
        "shifts": [],
        "missing_verses": [],
        "duplicate_verses": [],
        "text_integrity": [],
        "cross_version_discrepancy": [],
        "formatting": []
    }
    
    # Counters for tables
    category_counts = {v: {cat: 0 for cat in issues.keys()} for v in DB_FILES.keys()}

    def add_issue(category, version, book, chapter, verse, message, text_snippet=""):
        snippet = text_snippet[:100].replace("\n", " ").replace("\r", " ") if text_snippet else ""
        issues[category].append({
            "version": version,
            "book": book,
            "chapter": chapter,
            "verse": verse,
            "message": message,
            "snippet": snippet
        })
        category_counts[version][category] += 1

    # Book name mappings
    # Let's map normalized book names to canonical book ids
    canonical_books = list(canonical_counts.keys())
    
    # Pre-cache KJV text for shift detection
    kjv_data = all_data.get("kjv", {})

    print("Auditing data integrity...")
    for version in DB_FILES.keys():
        version_data = all_data[version]
        
        for book_id in canonical_books:
            expected_chapters = canonical_counts[book_id]
            actual_book_data = version_data.get(book_id, {})
            
            # Check chapter count
            if len(actual_book_data) != len(expected_chapters):
                # Flag missing chapters
                add_issue(
                    "missing_verses", version, book_id, 0, 0,
                    f"Chapter count mismatch: expected {len(expected_chapters)}, got {len(actual_book_data)}"
                )
            
            for ch_idx, expected_v_count in enumerate(expected_chapters):
                chapter = ch_idx + 1
                actual_ch_data = actual_book_data.get(chapter, {})
                
                # Check for missing verses / wrong counts
                actual_verses = raw_verse_lists[version].get(book_id, {}).get(chapter, [])
                if len(actual_verses) != expected_v_count:
                    add_issue(
                        "missing_verses", version, book_id, chapter, 0,
                        f"Verse count mismatch: expected {expected_v_count}, got {len(actual_verses)}"
                    )
                
                # Check individual verse numbers
                for v in range(1, expected_v_count + 1):
                    if v not in actual_ch_data:
                        add_issue(
                            "missing_verses", version, book_id, chapter, v,
                            f"Missing verse {v}"
                        )
                        continue
                        
                    text = actual_ch_data[v]
                    
                    # 1. Formatting checks
                    if text.startswith(" ") or text.endswith(" "):
                        add_issue("formatting", version, book_id, chapter, v, "Leading or trailing space", text)
                    if "  " in text:
                        add_issue("formatting", version, book_id, chapter, v, "Multiple spaces detected", text)
                    if "\n" in text or "\r" in text:
                        add_issue("formatting", version, book_id, chapter, v, "Line break detected", text)
                    if "\t" in text:
                        add_issue("formatting", version, book_id, chapter, v, "Tab character detected", text)
                        
                    # 2. Merged/Concatenated words checks
                    # English
                    if version in ["kjv", "asv", "web", "darby"]:
                        if re.search(r'[a-z][A-Z]', text):
                            add_issue("merged_words", version, book_id, chapter, v, "Merged English words (lowercase followed by uppercase)", text)
                        # Ensure no Telugu characters
                        if re.search(r'[\u0c00-\u0c7f]', text):
                            add_issue("text_integrity", version, book_id, chapter, v, "Telugu characters leaked into English text", text)
                    # Telugu
                    else:
                        # Ensure no English text (except maybe references/numbers, permit short strings like KJV, ASV in translator notes, but flag runs of characters)
                        if re.search(r'[a-zA-Z]{5,}', text):
                            add_issue("text_integrity", version, book_id, chapter, v, "Latin characters leaked into Telugu text", text)
                        # Check replacement character
                        if "\ufffd" in text:
                            add_issue("text_integrity", version, book_id, chapter, v, "Broken Unicode replacement character detected", text)
                        # Merged Telugu word heuristic: contiguous Telugu Unicode string longer than 25 chars without spaces/punctuation
                        # In Telugu Unicode range: U+0C00 to U+0C7F
                        telugu_words = re.findall(r'[\u0c00-\u0c7f]+', text)
                        for word in telugu_words:
                            if len(word) > 25:
                                add_issue("merged_words", version, book_id, chapter, v, f"Potential merged Telugu word: '{word[:15]}...' length {len(word)}", text)
                                
                    # 3. Duplicate Verse Check (within the same book)
                    # Compare this verse's text with other verses in the same book
                    for other_ch in actual_book_data.keys():
                        for other_v, other_txt in actual_book_data[other_ch].items():
                            if (other_ch != chapter or other_v != v) and len(text) > 15 and text == other_txt:
                                add_issue(
                                    "duplicate_verses", version, book_id, chapter, v,
                                    f"Duplicate verse content matching {book_id} {other_ch}:{other_v}", text
                                )

                    # 4. Verse Misplacement / Shift Checks (comparing against KJV)
                    if version != "kjv" and version in ["asv", "web", "darby"]:
                        # Compare text against KJV next or previous verse
                        kjv_ch_data = kjv_data.get(book_id, {}).get(chapter, {})
                        
                        next_kjv = kjv_ch_data.get(v + 1, "")
                        prev_kjv = kjv_ch_data.get(v - 1, "")
                        
                        # Normalize texts for comparison
                        norm_text = re.sub(r'[^\w]', '', text).lower()
                        norm_next = re.sub(r'[^\w]', '', next_kjv).lower()
                        norm_prev = re.sub(r'[^\w]', '', prev_kjv).lower()
                        norm_curr = re.sub(r'[^\w]', '', kjv_ch_data.get(v, "")).lower()
                        
                        if len(norm_text) > 15:
                            # If it matches next or previous instead of current
                            if norm_text == norm_next and norm_text != norm_curr:
                                add_issue(
                                    "shifts", version, book_id, chapter, v,
                                    f"Verse text shifted: matches KJV verse {v+1}", text
                                )
                            elif norm_text == norm_prev and norm_text != norm_curr:
                                add_issue(
                                    "shifts", version, book_id, chapter, v,
                                    f"Verse text shifted: matches KJV verse {v-1}", text
                                )

    # Cross-version discrepancy analysis
    print("Analyzing cross-version consistency...")
    for book_id in canonical_books:
        expected_chapters = canonical_counts[book_id]
        for ch_idx, expected_v_count in enumerate(expected_chapters):
            chapter = ch_idx + 1
            
            # Map version -> actual count
            counts = {}
            for version in DB_FILES.keys():
                v_list = raw_verse_lists[version].get(book_id, {}).get(chapter, [])
                counts[version] = len(v_list)
                
            # Get the majority count
            count_frequencies = {}
            for c in counts.values():
                count_frequencies[c] = count_frequencies.get(c, 0) + 1
                
            majority_count = max(count_frequencies, key=count_frequencies.get)
            
            # If any version deviates from the majority
            for version, count in counts.items():
                if count != majority_count:
                    add_issue(
                        "cross_version_discrepancy", version, book_id, chapter, 0,
                        f"Verse count discrepancy: version has {count} verses, majority has {majority_count}"
                    )

    # Telugu cross-contamination metric
    print("Checking Telugu cross-contamination...")
    for book_id in canonical_books:
        expected_chapters = canonical_counts[book_id]
        for ch_idx in range(len(expected_chapters)):
            chapter = ch_idx + 1
            
            te_ov_ch = all_data["telugu_ov"].get(book_id, {}).get(chapter, {})
            te_irv_ch = all_data["telugu_irv"].get(book_id, {}).get(chapter, {})
            te_wbtc_ch = all_data["telugu_wbtc"].get(book_id, {}).get(chapter, {})
            
            for v in te_ov_ch.keys():
                ov_txt = te_ov_ch[v]
                irv_txt = te_irv_ch.get(v, "")
                wbtc_txt = te_wbtc_ch.get(v, "")
                
                if "ఈ వచనం" in ov_txt or "not available" in ov_txt or "This verse" in ov_txt:
                    continue
                    
                whitelist = set()
                if (book_id, chapter, v) in whitelist:
                    continue

                if len(ov_txt) > 20:
                    if ov_txt == irv_txt:
                        add_issue(
                            "text_integrity", "telugu_irv", book_id, chapter, v,
                            "Cross-contamination: IRV text is 100% identical to Telugu OV", ov_txt
                        )
                    if ov_txt == wbtc_txt:
                        add_issue(
                            "text_integrity", "telugu_wbtc", book_id, chapter, v,
                            "Cross-contamination: WBTC text is 100% identical to Telugu OV", ov_txt
                        )

    # Output structured report
    report_path = "/home/david/Music/Bible Quiz/scripts/bible_validation_report.md"
    print(f"Writing structured report to {report_path}...")
    
    os.makedirs(os.path.dirname(report_path), exist_ok=True)
    
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("# Bible Verse Data Integrity Audit Report\n\n")
        f.write("This report displays validation checks across all 7 SQLite databases.\n\n")
        
        # 1. Summary table
        f.write("## 1. SUMMARY OF ISSUES BY CATEGORY & VERSION\n\n")
        f.write("| Version | Merged Words | Shifts | Missing Verses | Duplicate Verses | Text Integrity | Cross-Version Discr. | Formatting | Total |\n")
        f.write("| --- | --- | --- | --- | --- | --- | --- | --- | --- |\n")
        
        for version in DB_FILES.keys():
            v_counts = category_counts[version]
            tot = sum(v_counts.values())
            f.write(f"| **{version}** | {v_counts['merged_words']} | {v_counts['shifts']} | {v_counts['missing_verses']} | {v_counts['duplicate_verses']} | {v_counts['text_integrity']} | {v_counts['cross_version_discrepancy']} | {v_counts['formatting']} | **{tot}** |\n")
            
        f.write("\n---\n\n")
        
        # 2. Checklist showing pass/fail per version
        f.write("## 2. VALIDATION CHECKLIST PER VERSION\n\n")
        f.write("| Version | Merged Words | Shifts | Missing Verses | Duplicate Verses | Text Integrity | Cross-Version Discr. | Formatting |\n")
        f.write("| --- | --- | --- | --- | --- | --- | --- | --- |\n")
        for version in DB_FILES.keys():
            row_items = []
            for cat in issues.keys():
                status = "✅ PASS" if category_counts[version][cat] == 0 else "❌ FAIL"
                row_items.append(status)
            f.write(f"| **{version}** | " + " | ".join(row_items) + " |\n")
            
        f.write("\n---\n\n")

        # 3. Separate section for count mismatches
        f.write("## 3. CHAPTERS WITH VERSE COUNT MISMATCHES\n\n")
        mismatch_issues = [i for i in issues["missing_verses"] if i["verse"] == 0]
        if not mismatch_issues:
            f.write("No chapter verse count mismatches found.\n\n")
        else:
            f.write("| Version | Book | Chapter | Description |\n")
            f.write("| --- | --- | --- | --- |\n")
            for i in mismatch_issues:
                f.write(f"| {i['version']} | {i['book']} | {i['chapter']} | {i['message']} |\n")
            f.write("\n")

        f.write("---\n\n")

        # 4. Detailed findings Book -> Chapter -> Verse
        f.write("## 4. DETAILED FINDINGS\n\n")
        
        # Group issues by Book -> Chapter -> Verse
        grouped_issues = {}
        for cat, list_i in issues.items():
            for i in list_i:
                # Skip chapter mismatches here (already printed above)
                if cat == "missing_verses" and i["verse"] == 0:
                    continue
                key = (i["book"], i["chapter"], i["verse"])
                if key not in grouped_issues:
                    grouped_issues[key] = []
                grouped_issues[key].append((cat, i))
                
        if not grouped_issues:
            f.write("No detailed verse issues found!\n")
        else:
            # Sort by book, chapter, verse
            sorted_keys = sorted(grouped_issues.keys(), key=lambda x: (x[0], x[1], x[2]))
            
            # Print only up to first 500 issues to keep markdown file clean, and summarize if more
            total_detailed = len(sorted_keys)
            f.write(f"Showing first 500 of {total_detailed} detailed findings:\n\n")
            
            f.write("| Book | Chapter | Verse | Version | Issue Category | Description | Snippet |\n")
            f.write("| --- | --- | --- | --- | --- | --- | --- |\n")
            for idx, key in enumerate(sorted_keys):
                if idx >= 500:
                    f.write(f"| ... | ... | ... | ... | ... | *And {total_detailed - 500} more issues.* | ... |\n")
                    break
                for cat, i in grouped_issues[key]:
                    f.write(f"| {key[0]} | {key[1]} | {key[2]} | {i['version']} | {cat} | {i['message']} | `{i['snippet']}` |\n")

    print("Validation finished successfully.")

if __name__ == "__main__":
    main()
