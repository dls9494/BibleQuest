#!/usr/bin/env python3
"""
Telugu Bible PDF to XML Extraction Engine
Optimized for low memory overhead and layout-aware processing.
"""

import os
import re
import sys
import pypdf

# ─── Configuration ──────────────────────────────────────────────────────────
PDF_PATH = "assets/bible/tel2017_a4.pdf"
OUTPUT_PATH = "assets/bible/telugu_bible_2017.xml"

# ─── Book Mappings ──────────────────────────────────────────────────────────
HEADER_TO_CANONICAL = {
    'ఆదికాండం': 'Genesis',
    'నిరగ్మకాండం': 'Exodus',
    'లేవీకాండం': 'Leviticus',
    'సంఖాయ్కాండం': 'Numbers',
    'దివ్తీయోపదేశకాండము': 'Deuteronomy',
    'యెహోషువా': 'Joshua',
    'నాయ్యాధిపతులు': 'Judges',
    'రూతు': 'Ruth',
    '1 సమూయేలు': '1 Samuel',
    '2 సమూయేలు': '2 Samuel',
    '1 రాజులు': '1 Kings',
    '2 రాజులు': '2 Kings',
    '1 దినవృతా త్ ంతాలు': '1 Chronicles',
    '2 దినవృతా త్ ంతాలు': '2 Chronicles',
    'ఎజా ȯ': 'Ezra',
    'నెహెమాయ్': 'Nehemiah',
    'ఎసేత్రు': 'Esther',
    'యోబు': 'Job',
    'కీరɌనలు': 'Psalms',
    'సామెతలు': 'Proverbs',
    'పȼసంగి': 'Ecclesiastes',
    'పరమ గీతము': 'Song of Solomon',
    'యెషయా': 'Isaiah',
    'యిరీమ్యా': 'Jeremiah',
    'విలాపవాకయ్ములు': 'Lamentations',
    'యెహెజేక్లు': 'Ezekiel',
    'దానియేలు': 'Daniel',
    'హోషేయ': 'Hosea',
    'యోవేలు': 'Joel',
    'ఆమోసు': 'Amos',
    'ఓబదాయ్': 'Obadiah',
    'యోనా': 'Jonah',
    'మీకా': 'Micah',
    'నహǿము': 'Nahum',
    'హబకూక్కు': 'Habakkuk',
    'జెఫనాయ్': 'Zephaniah',
    'హగగ్యి': 'Haggai',
    'జెకరాయ్': 'Zechariah',
    'మలాకీ': 'Malachi',
    'మతత్యిరాసినసువారɌ': 'Matthew',
    'మారుక్రాసినసువారɌ': 'Mark',
    'లూకా రాసినసువారɌ': 'Luke',
    'యోహానురాసినసువారɌ': 'John',
    'అపోసత్లులకారయ్ములు': 'Acts',
    'రోమీయులకురాసినపతిȷక': 'Romans',
    'కొరింతీయులకురాసినమొదటిపతిȷక': '1 Corinthians',
    'కొరింతీయులకురాసినరెండవ పతిȷక': '2 Corinthians',
    'గలతీయులకురాసినపతిȷక': 'Galatians',
    'ఎఫెసీయులకురాసినపతిȷక': 'Ephesians',
    'ఫిలిపీప్యులకురాసినపతిȷక': 'Philippians',
    'కొలసస్యులకురాసినపతిȷక': 'Colossians',
    'తెసస్లోనీకయులకురాసినమొదటిపతిȷక': '1 Thessalonians',
    'తెసస్లోనీకయులకురాసినరెండవ పతిȷక': '2 Thessalonians',
    'తిమోతికిరాసినమొదటిపతిȷక': '1 Timothy',
    'తిమోతికిరాసినరెండవ పతిȷక': '2 Timothy',
    'తీతుకురాసినపతిȷక': 'Titus',
    'ఫిలేమోనుకురాసినపతిȷక': 'Philemon',
    'హెబీȾయులకురాసినపతిȷక': 'Hebrews',
    'యాకోబురాసినపతిȷక': 'James',
    'పేతురురాసినమొదటిపతిȷక': '1 Peter',
    'పేతురురాసినరెండవ పతిȷక': '2 Peter',
    'యోహానురాసినమొదటిపతిȷక': '1 John',
    'యోహానురాసినరెండవ పతిȷక': '2 John',
    'యోహానురాసినమూడవ పతిȷక': '3 John',
    'యూదా': 'Jude',
    'యూదా రాసినపతిȷక': 'Jude',
    'యోహానురాసినపȼకటనగȪంథం': 'Revelation'
}

CANONICAL_BOOKS_TE = {
    'Genesis': 'ఆదికాండము',
    'Exodus': 'నిర్గమకాండము',
    'Leviticus': 'లేవీయకాండము',
    'Numbers': 'సంఖ్యాకాండము',
    'Deuteronomy': 'ద్వితీయోపదేశకాండము',
    'Joshua': 'యెహోషువ',
    'Judges': 'న్యాయాధిపతులు',
    'Ruth': 'రూతు',
    '1 Samuel': '1 సమూయేలు',
    '2 Samuel': '2 సమూయేలు',
    '1 Kings': '1 రాజులు',
    '2 Kings': '2 రాజులు',
    '1 Chronicles': '1 దినవృత్తాంతములు',
    '2 Chronicles': '2 దినవృత్తాంతములు',
    'Ezra': 'ఎజ్రా',
    'Nehemiah': 'నెహెమ్యా',
    'Esther': 'ఎస్తేరు',
    'Job': 'యోబు',
    'Psalms': 'కీర్తనలు',
    'Proverbs': 'సామెతలు',
    'Ecclesiastes': 'ప్రసంగి',
    'Song of Solomon': 'పరమగీతము',
    'Isaiah': 'యెషయా',
    'Jeremiah': 'యిర్మీయా',
    'Lamentations': 'విలాపవాక్యములు',
    'Ezekiel': 'యెహెజ్కేలు',
    'Daniel': 'దానియేలు',
    'Hosea': 'హోషేయ',
    'Joel': 'యోవేలు',
    'Amos': 'ఆమోసు',
    'Obadiah': 'ఓబద్యా',
    'Jonah': 'యోనా',
    'Micah': 'మీకా',
    'Nahum': 'నహూము',
    'Habakkuk': 'హబక్కూకు',
    'Zephaniah': 'జెఫన్యా',
    'Haggai': 'హగ్గయి',
    'Zechariah': 'జెకర్యా',
    'Malachi': 'మలాకీ',
    'Matthew': 'మత్తయి',
    'Mark': 'మార్కు',
    'Luke': 'లూకా',
    'John': 'యోహాను',
    'Acts': 'అపొస్తలుల కార్యములు',
    'Romans': 'రోమీయులకు',
    '1 Corinthians': '1 కొరింథీయులకు',
    '2 Corinthians': '2 కొరింథీయులకు',
    'Galatians': 'గలతీయులకు',
    'Ephesians': 'ఎఫెసీయులకు',
    'Philippians': 'ఫిలిప్పీయులకు',
    'Colossians': 'కొలొస్సయులకు',
    '1 Thessalonians': '1 థెస్సలొనీకయులకు',
    '2 Thessalonians': '2 థెస్సలొనీకయులకు',
    '1 Timothy': '1 తిమోతికి',
    '2 Timothy': '2 తిమోతికి',
    'Titus': 'తీతుకు',
    'Philemon': 'ఫిలేమోనుకు',
    'Hebrews': 'హెబ్రీయులకు',
    'James': 'యాకోబు',
    '1 Peter': '1 పేతురు',
    '2 Peter': '2 పేతురు',
    '1 John': '1 యోహాను',
    '2 John': '2 యోహాను',
    '3 John': '3 యోహాను',
    'Jude': 'యూదా',
    'Revelation': 'ప్రకటన గ్రంథము'
}

# ─── Helper Functions ────────────────────────────────────────────────────────

def clean_and_format_telugu(text):
    if not text:
        return ""
    
    # 1. OCR Character Replacement Map
    replacements = {
        'ȼ': '్ర',
        'Ⱥ': '్ర',
        'ȷ': '్ర',
        'œ': 'డై',
        'Ɍ': '్త',
        'Ò': 'క్షి',
        'Ƚ': '్ర',
        'ɀ': '్ర',
        '®': 'క్ష',
        'ś': 'పై',
        'ť': 'వై',
        'ɟ': '్త్ర',
        'Ş': 'భై',
        'Ǽ': 'ు',
        'ǻ': '్ళ',
        'ȹ': '్ర',
        'Ⱦ': '్ర',
        'ȴ': '్రి',
        'ȯ': '్రా',
        'ǿ': 'ూ',
        'Ɏ': '్తు',
        'Ś': 'నై',
        '†': '',
        '‡': '',
        '*': '',
        'Ò': 'క్షి',
    }
    
    for k, v in replacements.items():
        text = text.replace(k, v)
        
    # 2. General Spacing & Typos Correction
    # Add spacing around conjunctions and specific proper names to prevent merged words
    text = re.sub(r'(మరియు)([\u0c00-\u0c7f])', r'\1 \2', text)
    text = re.sub(r'(అప్పుడు)([\u0c00-\u0c7f])', r'\1 \2', text)
    text = re.sub(r'(అందుకు)([\u0c00-\u0c7f])', r'\1 \2', text)
    text = re.sub(r'(ఇశ్రాయేలు)([\u0c00-\u0c7f])', r'\1 \2', text)
    text = re.sub(r'(దేవుడు|ప్రభువు)([అఆఇఈఉఊఎఏఐఒఓఔకగచజటడతదపబమరవశషసహ])', r'\1 \2', text)
    text = re.sub(r'(యేసు|క్రీస్తు|మోషే|యెహోవా)([అఆఇఈఉఊఎఏఐఒఓఔగజడదపబమరవశషసహ])', r'\1 \2', text)

    merged_fixes = {
        "యేసుక్రీస్తు": "యేసు క్రీస్తు",
        "దేవుడుచూచెను": "దేవుడు చూచెను",
        "దేవుడుజలముల": "దేవుడు జలముల",
        "దేవుడుఆకాశము": "దేవుడు ఆకాశము",
        "దేవుడుగడ్డిని": "దేవుడు గడ్డిని",
        "దేవుడుపగటిని": "దేవుడు పగటిని",
        "దేవుడుజీవము": "దేవుడు జలము",
        "దేవుడుచేసెను": "దేవుడు చేసెను",
        "దేవుడుఆశీర్వదించెను": "దేవుడు ఆశీర్వదించెను",
        "దేవుడుమంచిదని": "దేవుడు మంచిదని",
        "దేవుడుతన": "దేవుడు తన",
        "దేవుడునరుని": "దేవుడు నరుని",
        "దేవుడుభూమిని": "దేవుడు భూమిని",
        "దేవుడునోవహుతో": "దేవుడు నోవహుతో",
        "దేవుడుఅబ్రాహాముతో": "దేవుడు అబ్రాహాముతో",
        "దేవుడుసెలవిచ్చిన": "దేవుడు సెలవిచ్చిన",
        "దేవుడుమోషేతో": "దేవుడు మోషేతో",
        "దేవుడుఇశ్రాయేలీయుల": "దేవుడు ఇశ్రాయేలీయుల",
        "దేవుడుఆజ్ఞాపించిన": "దేవుడు ఆజ్ఞాపించిన",
        "దేవుడునాకు": "దేవుడు నాకు",
        "దేవుడునీతో": "దేవుడు నీతో",
        "దేవుడువారిని": "దేవుడు వారిని",
        "దేవుడునాతో": "దేవుడు నాతో",
        "అదిమంచిదని": "అది మంచిదని",
        "అట్లుజరిగెను": "అట్లు జరిగెను",
    }
    for old, new in merged_fixes.items():
        text = text.replace(old, new)

    # 3. Clean spacing issues inside words
    extra_space_fixes = {
        "ప్రకార మాయెను": "ప్రకారమాయెను",
        "సమృ ద్ధిగా": "సమృద్ధిగా",
        "చీక టిని": "చీకటిని",
        "అస్తమయ మును": "అస్తమయమును",
        "నెరవేరు నట్లు": "నెరవేరునట్లు",
        "నెరవేర్చ బడునట్లు": "నెరవేర్చబడునట్లు",
        "సమ కూర్చి": "సమకూర్చి",
        "వెలు గిచ్చుటకు": "వెలుగిచ్చుటకు",
        "నజ రేతను": "నజరేతను",
        "కుమా రుని": "కుమారుని",
        "ఏల యనగా": "ఏలయనగా",
        "యాసేపు": "యోసేపు",
        "మీలోn": "మీలో",
    }
    for old, new in extra_space_fixes.items():
        text = text.replace(old, new)

    # 4. Standard Punctuation Clean
    text = text.replace(';', '।')
    if text.endswith(','):
        text = text[:-1] + '।'
    elif not text.endswith(('.', '?', '!', ';', '।', ')', '”', '’')):
        text = text + '।'

    # Remove double spaces
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def escape_xml(text):
    if not text:
        return ""
    text = text.replace('&', '&amp;')
    text = text.replace('<', '&lt;')
    text = text.replace('>', '&gt;')
    text = text.replace('"', '&quot;')
    text = text.replace("'", '&apos;')
    return text

# ─── Main Extraction Engine ─────────────────────────────────────────────────

def main():
    if not os.path.exists(PDF_PATH):
        print(f"Error: PDF file not found at {PDF_PATH}")
        sys.exit(1)

    print(f"Loading PDF from {PDF_PATH}...")
    reader = pypdf.PdfReader(PDF_PATH)
    total_pages = len(reader.pages)
    print(f"Total pages: {total_pages}")

    # Layout-aware header extraction regex
    # Matches: <BookName><ChapterRef> <Page> <BookName><ChapterRef>
    # Supports chapter:verse ranges, single digit chapters, etc.
    header_pattern = re.compile(
        r'^([1-3\s]*[\u0c00-\u0c7f\s\d\w\-]+?)\s*(\d+(?::\d+(?:-\d+)?)?)\s+(\d+)\s+([1-3\s]*[\u0c00-\u0c7f\s\d\w\-]+?)\s*(\d+(?::\d+(?:-\d+)?)?)$'
    )

    current_book_header = None
    current_book_canonical = None
    current_chapter = 1
    book_started = False
    active_verse = None

    # Sentence ending punctuation to identify verse completion / section subheadings
    sentence_endings = ('.', '।', '?', '!', '”', '’')

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    print(f"Extracting to XML: {OUTPUT_PATH}...")

    with open(OUTPUT_PATH, "w", encoding="utf-8") as out:
        # Write XML Header and metadata
        out.write('<?xml version="1.0" encoding="utf-8"?>\n')
        out.write('<bible>\n')
        out.write('  <metadata>\n')
        out.write('    <title>Telugu Bible (2017 Edition)</title>\n')
        out.write('    <description>Layout-aware XML extraction from tel2017_a4.pdf</description>\n')
        out.write('  </metadata>\n')

        # Bible text typically starts on page 4
        for idx in range(4, total_pages):
            page = reader.pages[idx]
            text = page.extract_text()
            if not text:
                continue
            
            lines = text.split('\n')
            if not lines:
                continue

            header_line = lines[0].strip()
            match = header_pattern.match(header_line)
            
            if not match:
                # If header doesn't match, this is not a standard Bible page (e.g. table of contents / appendix)
                continue

            # Extract Book Name from the left side of the header
            header_book = match.group(1).strip()
            canonical_en = HEADER_TO_CANONICAL.get(header_book, None)

            if not canonical_en:
                # Fallback check or unknown book name in header
                print(f"Warning (Page {idx}): Unknown book name in header: {header_book!r}")
                canonical_en = header_book # Use raw if not mapped

            # Check if book has transitioned
            if canonical_en != current_book_canonical:
                # Finalize previous active verse, chapter, and book tags
                if active_verse:
                    cleaned_verse = clean_and_format_telugu(active_verse["text"])
                    out.write(f'      <verse id="{active_verse["id"]}">{escape_xml(cleaned_verse)}</verse>\n')
                    active_verse = None
                
                if current_book_canonical:
                    out.write(f'    </chapter>\n')
                    out.write(f'  </book>\n')
                    print(f"Completed book: {current_book_canonical}")

                # Start new book
                current_book_canonical = canonical_en
                current_book_header = header_book
                current_chapter = 1
                book_started = False
                
                canonical_te = CANONICAL_BOOKS_TE.get(current_book_canonical, current_book_canonical)
                out.write(f'  <book id="{current_book_canonical}" name="{canonical_te}">\n')
                out.write(f'    <chapter id="1">\n')
                print(f"Starting book: {current_book_canonical} (Page {idx})")

            # Process content lines (skipping header)
            for line_idx in range(1, len(lines)):
                line = lines[line_idx].strip()
                if not line:
                    continue

                # Skip footnotes
                if re.match(r'^\s*[*†‡§¶]', line):
                    continue

                # Check for chapter milestone (single number on a line)
                if re.match(r'^\d+$', line):
                    new_chapter = int(line)
                    if active_verse:
                        cleaned_verse = clean_and_format_telugu(active_verse["text"])
                        out.write(f'      <verse id="{active_verse["id"]}">{escape_xml(cleaned_verse)}</verse>\n')
                        active_verse = None
                    
                    out.write(f'    </chapter>\n')
                    out.write(f'    <chapter id="{new_chapter}">\n')
                    current_chapter = new_chapter
                    continue

                # Check for verse number match
                verse_match = re.match(r'^(\d+)\s+(.*)$', line)
                if verse_match:
                    verse_id = int(verse_match.group(1))
                    verse_text = verse_match.group(2).strip()

                    # Check if this is the start of the book (Chapter 1 Verse 1) to bypass book introduction
                    if not book_started:
                        if current_chapter == 1 and verse_id == 1:
                            book_started = True
                        else:
                            # Still in the book introduction
                            continue

                    # Finalize previous active verse
                    if active_verse:
                        cleaned_verse = clean_and_format_telugu(active_verse["text"])
                        out.write(f'      <verse id="{active_verse["id"]}">{escape_xml(cleaned_verse)}</verse>\n')

                    active_verse = {"id": verse_id, "text": verse_text}
                    continue

                # Handle line wrapping or section subheadings
                if book_started:
                    if active_verse:
                        # If the active verse text ends with sentence-ending punctuation,
                        # this line is a section subheading (ignored). Otherwise, it is a continuation.
                        if active_verse["text"].endswith(sentence_endings):
                            # Treated as section heading, we do not append
                            continue
                        else:
                            # Continuation of the active verse
                            active_verse["text"] += " " + line

        # Finalize the last book, chapter, and verse
        if active_verse:
            cleaned_verse = clean_and_format_telugu(active_verse["text"])
            out.write(f'      <verse id="{active_verse["id"]}">{escape_xml(cleaned_verse)}</verse>\n')
        
        if current_book_canonical:
            out.write(f'    </chapter>\n')
            out.write(f'  </book>\n')
            print(f"Completed book: {current_book_canonical}")

        out.write('</bible>\n')

    print(f"\nSuccessfully generated XML Bible file: {OUTPUT_PATH}")

if __name__ == "__main__":
    main()
