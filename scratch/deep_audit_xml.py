import os
import re
import xml.etree.ElementTree as ET
import sys

XML_CLEAN_PATH = "/home/david/Music/Bible Quiz/audit/Telugu Bible (BSI) Clean.xml"
BIBLE_SERVICE_PATH = "/home/david/Music/Bible Quiz/lib/services/bible_service.dart"

def load_canonical_counts(file_path):
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

# Book number to id map (standard 1-66 Protestant canon)
BOOK_ID_BY_NUM = {
    1: "genesis", 2: "exodus", 3: "leviticus", 4: "numbers", 5: "deuteronomy",
    6: "joshua", 7: "judges", 8: "ruth", 9: "1samuel", 10: "2samuel",
    11: "1kings", 12: "2kings", 13: "1chronicles", 14: "2chronicles", 15: "ezra",
    16: "nehemiah", 17: "esther", 18: "job", 19: "psalms", 20: "proverbs",
    21: "ecclesiastes", 22: "songofsolomon", 23: "isaiah", 24: "jeremiah", 25: "lamentations",
    26: "ezekiel", 27: "daniel", 28: "hosea", 29: "joel", 30: "amos",
    31: "obadiah", 32: "jonah", 33: "micah", 34: "nahum", 35: "habakkuk",
    36: "zephaniah", 37: "haggai", 38: "zechariah", 39: "malachi", 40: "matthew",
    41: "mark", 42: "luke", 43: "john", 44: "acts", 45: "romans",
    46: "1corinthians", 47: "2corinthians", 48: "galatians", 49: "ephesians", 50: "philippians",
    51: "colossians", 52: "1thessalonians", 53: "2thessalonians", 54: "1timothy", 55: "2timothy",
    56: "titus", 57: "philemon", 58: "hebrews", 59: "james", 60: "1peter",
    61: "2peter", 62: "1john", 63: "2john", 64: "3john", 65: "jude",
    66: "revelation"
}

# The reverse map
BOOK_NUM_BY_ID = {v: k for k, v in BOOK_ID_BY_NUM.items()}

def run_deep_audit():
    print("Loading canonical counts...")
    canonical_counts = load_canonical_counts(BIBLE_SERVICE_PATH)
    
    print("Parsing Clean XML...")
    tree = ET.parse(XML_CLEAN_PATH)
    root = tree.getroot()
    
    xml_data = {}
    for book in root.findall('.//BIBLEBOOK'):
        bnum = int(book.attrib.get('bnumber'))
        bname = book.attrib.get('bname')
        xml_data[bnum] = {
            "name": bname,
            "chapters": {}
        }
        for chapter in book.findall('.//CHAPTER'):
            cnum = int(chapter.attrib.get('cnumber'))
            xml_data[bnum]["chapters"][cnum] = {}
            for vers in chapter.findall('.//VERS'):
                vnum = int(vers.attrib.get('vnumber'))
                text = "".join(vers.itertext()).strip()
                xml_data[bnum]["chapters"][cnum][vnum] = text

    issues = []
    
    # 1. Structural Checks (Chapters & Verses count validation against canon)
    for bnum, book_id in BOOK_ID_BY_NUM.items():
        expected_chapters = canonical_counts.get(book_id)
        if not expected_chapters:
            issues.append({
                "severity": "CRITICAL",
                "category": "structural",
                "book": book_id, "chapter": 0, "verse": 0,
                "msg": f"Book '{book_id}' not found in canonical counts"
            })
            continue
            
        book_data = xml_data.get(bnum, {})
        if not book_data:
            issues.append({
                "severity": "CRITICAL",
                "category": "structural",
                "book": book_id, "chapter": 0, "verse": 0,
                "msg": f"Book missing in Clean XML"
            })
            continue
            
        actual_chapters = book_data["chapters"]
        if len(actual_chapters) != len(expected_chapters):
            issues.append({
                "severity": "CRITICAL",
                "category": "structural",
                "book": book_id, "chapter": 0, "verse": 0,
                "msg": f"Chapter count mismatch: expected {len(expected_chapters)}, got {len(actual_chapters)}"
            })
            
        for ch_idx, expected_v_count in enumerate(expected_chapters):
            chapter = ch_idx + 1
            chap_data = actual_chapters.get(chapter, {})
            
            # Check individual verse availability
            for v in range(1, expected_v_count + 1):
                if v not in chap_data:
                    issues.append({
                        "severity": "HIGH",
                        "category": "structural",
                        "book": book_id, "chapter": chapter, "verse": v,
                        "msg": f"Missing verse {v}"
                    })
                    continue
                    
                vtext = chap_data[v]
                
                # Check for merged Telugu words (contiguous Telugu letters > 25 chars)
                telugu_words = re.findall(r'[\u0c00-\u0c7f]+', vtext)
                for word in telugu_words:
                    if len(word) > 25:
                        issues.append({
                            "severity": "MEDIUM",
                            "category": "merged_word",
                            "book": book_id, "chapter": chapter, "verse": v,
                            "msg": f"Merged Telugu word: '{word[:15]}...' length {len(word)}",
                            "snippet": vtext
                        })
                
                # Check for Latin characters leaked in
                if re.search(r'[a-zA-Z]{4,}', vtext):
                    issues.append({
                        "severity": "HIGH",
                        "category": "char_leak",
                        "book": book_id, "chapter": chapter, "verse": v,
                        "msg": f"Latin character leak detected in Telugu text",
                        "snippet": vtext
                    })
                    
                # Check for abnormally long verses (> 600 chars)
                if len(vtext) > 600:
                    issues.append({
                        "severity": "LOW",
                        "category": "length",
                        "book": book_id, "chapter": chapter, "verse": v,
                        "msg": f"Abnormally long verse: {len(vtext)} characters",
                        "snippet": vtext
                    })
                    
                # Check for abnormally short verses (< 8 chars) that are not placeholders
                if len(vtext) < 8 and "ఈ వచనం" not in vtext:
                    issues.append({
                        "severity": "LOW",
                        "category": "length",
                        "book": book_id, "chapter": chapter, "verse": v,
                        "msg": f"Abnormally short verse: {len(vtext)} characters",
                        "snippet": vtext
                    })

    # Group issues by severity
    print(f"\nAudit completed. Total issues found: {len(issues)}")
    severity_counts = {"CRITICAL": 0, "HIGH": 0, "MEDIUM": 0, "LOW": 0}
    for iss in issues:
        severity_counts[iss["severity"]] += 1
        
    print(f"Severity counts: {severity_counts}")
    
    # Print detailed findings (first 50 issues)
    print("\nDetailed list of issues:")
    for idx, iss in enumerate(issues[:100], 1):
        print(f"{idx}. [{iss['severity']}] {iss['category'].upper()} - {iss['book']} {iss['chapter']}:{iss['verse']}: {iss['msg']}")
        if "snippet" in iss:
            print(f"   Snippet: {iss['snippet'][:80]}")

if __name__ == "__main__":
    run_deep_audit()
