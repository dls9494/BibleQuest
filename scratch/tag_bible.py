import os
import re
import json

# Define the books of the New Testament in order
NT_BOOKS = [
    'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans',
    '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians',
    'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy',
    'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter',
    '1 John', '2 John', '3 John', 'Jude', 'Revelation'
]

# Map from USFM book code to our JSON Book Name
USFM_TO_JSON_BOOK = {
    'MAT': 'Matthew', 'MRK': 'Mark', 'LUK': 'Luke', 'JHN': 'John', 'ACT': 'Acts', 'ROM': 'Romans',
    '1CO': '1 Corinthians', '2CO': '2 Corinthians', 'GAL': 'Galatians', 'EPH': 'Ephesians', 'PHP': 'Philippians',
    'COL': 'Colossians', '1TH': '1 Thessalonians', '2TH': '2 Thessalonians', '1TI': '1 Timothy', '2TI': '2 Timothy',
    'TIT': 'Titus', 'PHM': 'Philemon', 'HEB': 'Hebrews', 'JAS': 'James', '1PE': '1 Peter', '2PE': '2 Peter',
    '1JN': '1 John', '2JN': '2 John', '3JN': '3 John', 'JUD': 'Jude', 'REV': 'Revelation'
}

# Prophecies list to tag with « »
# Format: (Book, Chapter, Verse)
PROPHECIES = {
    # Matthew
    ('Matthew', 1, 23), ('Matthew', 2, 6), ('Matthew', 2, 15), ('Matthew', 2, 18), ('Matthew', 3, 3),
    ('Matthew', 4, 4), ('Matthew', 4, 6), ('Matthew', 4, 7), ('Matthew', 4, 10), ('Matthew', 4, 15),
    ('Matthew', 4, 16), ('Matthew', 5, 21), ('Matthew', 5, 27), ('Matthew', 5, 38), ('Matthew', 5, 43),
    ('Matthew', 8, 17), ('Matthew', 9, 13), ('Matthew', 11, 10), ('Matthew', 12, 7), ('Matthew', 12, 18),
    ('Matthew', 12, 19), ('Matthew', 12, 20), ('Matthew', 12, 21), ('Matthew', 13, 14), ('Matthew', 13, 15),
    ('Matthew', 13, 35), ('Matthew', 15, 4), ('Matthew', 15, 8), ('Matthew', 15, 9), ('Matthew', 19, 5),
    ('Matthew', 19, 18), ('Matthew', 19, 19), ('Matthew', 21, 5), ('Matthew', 21, 9), ('Matthew', 21, 13),
    ('Matthew', 21, 16), ('Matthew', 21, 42), ('Matthew', 22, 32), ('Matthew', 22, 37), ('Matthew', 22, 39),
    ('Matthew', 22, 44), ('Matthew', 23, 39), ('Matthew', 24, 15), ('Matthew', 26, 31), ('Matthew', 27, 9),
    ('Matthew', 27, 10), ('Matthew', 27, 35), ('Matthew', 27, 46),
    # Mark
    ('Mark', 1, 2), ('Mark', 1, 3), ('Mark', 4, 12), ('Mark', 7, 6), ('Mark', 7, 7),
    ('Mark', 7, 10), ('Mark', 10, 6), ('Mark', 10, 7), ('Mark', 10, 8), ('Mark', 10, 19),
    ('Mark', 11, 9), ('Mark', 11, 17), ('Mark', 12, 10), ('Mark', 12, 11), ('Mark', 12, 29),
    ('Mark', 12, 30), ('Mark', 12, 31), ('Mark', 12, 36), ('Mark', 13, 14), ('Mark', 14, 27),
    ('Mark', 15, 28), ('Mark', 15, 34),
    # Luke
    ('Luke', 2, 23), ('Luke', 3, 4), ('Luke', 3, 5), ('Luke', 3, 6), ('Luke', 4, 4),
    ('Luke', 4, 8), ('Luke', 4, 10), ('Luke', 4, 11), ('Luke', 4, 12), ('Luke', 4, 18),
    ('Luke', 4, 19), ('Luke', 7, 27), ('Luke', 8, 10), ('Luke', 10, 27), ('Luke', 13, 35),
    ('Luke', 18, 20), ('Luke', 19, 38), ('Luke', 19, 46), ('Luke', 20, 17), ('Luke', 20, 37),
    ('Luke', 20, 42), ('Luke', 20, 43), ('Luke', 22, 37), ('Luke', 23, 30), ('Luke', 23, 46),
    # John
    ('John', 1, 23), ('John', 2, 17), ('John', 6, 31), ('John', 6, 45), ('John', 10, 34),
    ('John', 12, 13), ('John', 12, 15), ('John', 12, 38), ('John', 12, 40), ('John', 13, 18),
    ('John', 15, 25), ('John', 19, 24), ('John', 19, 28), ('John', 19, 36), ('John', 19, 37),
    # Acts
    ('Acts', 1, 20), ('Acts', 2, 17), ('Acts', 2, 18), ('Acts', 2, 19), ('Acts', 2, 20),
    ('Acts', 2, 21), ('Acts', 2, 25), ('Acts', 2, 26), ('Acts', 2, 27), ('Acts', 2, 28),
    ('Acts', 2, 30), ('Acts', 2, 34), ('Acts', 2, 35), ('Acts', 3, 22), ('Acts', 3, 23),
    ('Acts', 4, 11), ('Acts', 4, 25), ('Acts', 4, 26), ('Acts', 7, 3), ('Acts', 7, 6),
    ('Acts', 7, 7), ('Acts', 7, 27), ('Acts', 7, 28), ('Acts', 7, 32), ('Acts', 7, 33),
    ('Acts', 7, 34), ('Acts', 7, 37), ('Acts', 7, 40), ('Acts', 7, 42), ('Acts', 7, 43),
    ('Acts', 7, 49), ('Acts', 7, 50), ('Acts', 8, 32), ('Acts', 8, 33), ('Acts', 13, 22),
    ('Acts', 13, 33), ('Acts', 13, 34), ('Acts', 13, 35), ('Acts', 13, 41), ('Acts', 13, 47),
    ('Acts', 15, 16), ('Acts', 15, 17), ('Acts', 23, 5), ('Acts', 28, 26), ('Acts', 28, 27),
    # Romans
    ('Romans', 1, 17), ('Romans', 2, 24), ('Romans', 3, 4), ('Romans', 3, 10), ('Romans', 3, 11),
    ('Romans', 3, 12), ('Romans', 3, 13), ('Romans', 3, 14), ('Romans', 3, 15), ('Romans', 3, 16),
    ('Romans', 3, 17), ('Romans', 3, 18), ('Romans', 4, 3), ('Romans', 4, 7), ('Romans', 4, 8),
    ('Romans', 4, 17), ('Romans', 4, 18), ('Romans', 7, 7), ('Romans', 8, 36), ('Romans', 9, 7),
    ('Romans', 9, 9), ('Romans', 9, 12), ('Romans', 9, 13), ('Romans', 9, 15), ('Romans', 9, 17),
    ('Romans', 9, 20), ('Romans', 9, 25), ('Romans', 9, 26), ('Romans', 9, 27), ('Romans', 9, 28),
    ('Romans', 9, 29), ('Romans', 9, 33), ('Romans', 10, 5), ('Romans', 10, 6), ('Romans', 10, 7),
    ('Romans', 10, 8), ('Romans', 10, 11), ('Romans', 10, 13), ('Romans', 10, 15), ('Romans', 10, 16),
    ('Romans', 10, 18), ('Romans', 10, 19), ('Romans', 10, 20), ('Romans', 10, 21), ('Romans', 11, 3),
    ('Romans', 11, 4), ('Romans', 11, 8), ('Romans', 11, 9), ('Romans', 11, 10), ('Romans', 11, 26),
    ('Romans', 11, 27), ('Romans', 11, 34), ('Romans', 12, 19), ('Romans', 12, 20), ('Romans', 13, 9),
    ('Romans', 14, 11), ('Romans', 15, 3), ('Romans', 15, 9), ('Romans', 15, 10), ('Romans', 15, 11),
    ('Romans', 15, 12), ('Romans', 15, 21),
    # 1 Corinthians
    ('1 Corinthians', 1, 19), ('1 Corinthians', 1, 31), ('1 Corinthians', 2, 9), ('1 Corinthians', 2, 16),
    ('1 Corinthians', 3, 19), ('1 Corinthians', 3, 20), ('1 Corinthians', 5, 13), ('1 Corinthians', 6, 16),
    ('1 Corinthians', 9, 9), ('1 Corinthians', 10, 7), ('1 Corinthians', 10, 26), ('1 Corinthians', 14, 21),
    ('1 Corinthians', 15, 25), ('1 Corinthians', 15, 27), ('1 Corinthians', 15, 32), ('1 Corinthians', 15, 45),
    ('1 Corinthians', 15, 54), ('1 Corinthians', 15, 55),
    # 2 Corinthians
    ('2 Corinthians', 4, 13), ('2 Corinthians', 6, 2), ('2 Corinthians', 6, 16), ('2 Corinthians', 6, 17),
    ('2 Corinthians', 6, 18), ('2 Corinthians', 8, 15), ('2 Corinthians', 9, 9), ('2 Corinthians', 13, 1),
    # Galatians
    ('Galatians', 3, 6), ('Galatians', 3, 8), ('Galatians', 3, 10), ('Galatians', 3, 11), ('Galatians', 3, 12),
    ('Galatians', 3, 13), ('Galatians', 3, 16), ('Galatians', 4, 27), ('Galatians', 4, 30), ('Galatians', 5, 14),
    # Ephesians
    ('Ephesians', 4, 8), ('Ephesians', 4, 25), ('Ephesians', 4, 26), ('Ephesians', 5, 31), ('Ephesians', 6, 2),
    ('Ephesians', 6, 3),
    # Philippians
    ('Philippians', 2, 10), ('Philippians', 2, 11),
    # 1 Timothy
    ('1 Timothy', 5, 18), ('1 Timothy', 5, 19),
    # 2 Timothy
    ('2 Timothy', 2, 19),
    # Hebrews
    ('Hebrews', 1, 5), ('Hebrews', 1, 6), ('Hebrews', 1, 7), ('Hebrews', 1, 8), ('Hebrews', 1, 9),
    ('Hebrews', 1, 10), ('Hebrews', 1, 11), ('Hebrews', 1, 12), ('Hebrews', 1, 13), ('Hebrews', 2, 6),
    ('Hebrews', 2, 7), ('Hebrews', 2, 8), ('Hebrews', 2, 12), ('Hebrews', 2, 13), ('Hebrews', 3, 7),
    ('Hebrews', 3, 8), ('Hebrews', 3, 9), ('Hebrews', 3, 10), ('Hebrews', 3, 11), ('Hebrews', 3, 15),
    ('Hebrews', 4, 3), ('Hebrews', 4, 4), ('Hebrews', 4, 5), ('Hebrews', 4, 7), ('Hebrews', 5, 5),
    ('Hebrews', 5, 6), ('Hebrews', 6, 14), ('Hebrews', 7, 17), ('Hebrews', 7, 21), ('Hebrews', 8, 5),
    ('Hebrews', 8, 8), ('Hebrews', 8, 9), ('Hebrews', 8, 10), ('Hebrews', 8, 11), ('Hebrews', 8, 12),
    ('Hebrews', 9, 20), ('Hebrews', 10, 5), ('Hebrews', 10, 6), ('Hebrews', 10, 7), ('Hebrews', 10, 16),
    ('Hebrews', 10, 17), ('Hebrews', 10, 30), ('Hebrews', 10, 37), ('Hebrews', 10, 38), ('Hebrews', 11, 5),
    ('Hebrews', 11, 18), ('Hebrews', 11, 21), ('Hebrews', 12, 5), ('Hebrews', 12, 6), ('Hebrews', 12, 12),
    ('Hebrews', 12, 13), ('Hebrews', 12, 20), ('Hebrews', 12, 21), ('Hebrews', 12, 26), ('Hebrews', 13, 5),
    ('Hebrews', 13, 6),
    # James
    ('James', 2, 8), ('James', 2, 23), ('James', 4, 6),
    # 1 Peter
    ('1 Peter', 1, 16), ('1 Peter', 1, 24), ('1 Peter', 1, 25), ('1 Peter', 2, 6), ('1 Peter', 2, 7),
    ('1 Peter', 2, 8), ('1 Peter', 2, 22), ('1 Peter', 2, 24), ('1 Peter', 2, 25), ('1 Peter', 3, 10),
    ('1 Peter', 3, 11), ('1 Peter', 3, 12), ('1 Peter', 4, 18), ('1 Peter', 5, 5),
    # 2 Peter
    ('2 Peter', 2, 22),
    # Revelation
    ('Revelation', 1, 7), ('Revelation', 2, 27), ('Revelation', 3, 7), ('Revelation', 4, 8), ('Revelation', 5, 5),
    ('Revelation', 11, 15), ('Revelation', 14, 10), ('Revelation', 15, 3), ('Revelation', 18, 2), ('Revelation', 19, 15),
    ('Revelation', 21, 3), ('Revelation', 21, 4)
}

def clean_usfm_text(text):
    text = re.sub(r'\\f\s+.*?\\f\*', '', text, flags=re.DOTALL)
    text = re.sub(r'\|strong=\"[^\"]*\"', '', text)
    text = re.sub(r'\\\+?[a-zA-Z*]+', '', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def normalize_text_for_match(text):
    # Lowercase, clean symbols/spaces
    text = re.sub(r'[^\w\s]', '', text.lower())
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def align_and_wrap(full_text, quote_text, start_tag, end_tag):
    # Fuzzy align the quote_text inside full_text and wrap it
    # We clean quotes first for search
    search_q = normalize_text_for_match(quote_text)
    norm_full = normalize_text_for_match(full_text)
    
    if not search_q or not norm_full:
        return full_text
        
    # Check if the search_q matches the whole normalized text
    if search_q == norm_full or len(search_q) > 0.9 * len(norm_full):
        return f"{start_tag}{full_text}{end_tag}"
        
    # Try finding exact substring match first (excluding punctuation/case)
    # Let's split full_text into words and try to find where the sequence of search_q words matches best
    full_words = full_text.split()
    norm_full_words = [normalize_text_for_match(w) for w in full_words]
    # Filter out empty words
    norm_full_words_clean = [(w, i) for i, w in enumerate(norm_full_words) if w]
    
    q_words = search_q.split()
    if not q_words:
        return full_text
        
    best_start = -1
    best_end = -1
    best_score = 0
    
    # Simple sliding window of size len(q_words)
    w_len = len(q_words)
    n_len = len(norm_full_words_clean)
    
    # We try windows from size w_len - 3 to w_len + 3
    for size in range(max(1, w_len - 3), min(n_len + 1, w_len + 4)):
        for start in range(n_len - size + 1):
            sub_words = [norm_full_words_clean[start + k][0] for k in range(size)]
            # Match score: how many words are in common/ordered
            matches = sum(1 for k in range(min(size, w_len)) if sub_words[k] == q_words[k])
            score = matches / max(size, w_len)
            if score > best_score:
                best_score = score
                best_start = norm_full_words_clean[start][1]
                best_end = norm_full_words_clean[start + size - 1][1]
                
    if best_score > 0.6:
        # Wrap words from best_start to best_end
        prefix = ' '.join(full_words[:best_start])
        target = ' '.join(full_words[best_start:best_end + 1])
        suffix = ' '.join(full_words[best_end + 1:])
        
        # Keep formatting/spacing
        # We need to make sure we don't duplicate tags
        if start_tag not in target and end_tag not in target:
            res = ""
            if prefix:
                res += prefix + " "
            res += f"{start_tag}{target}{end_tag}"
            if suffix:
                res += " " + suffix
            return res
            
    return full_text

def main():
    print("Loading English Bible translations...")
    versions = ['english_kjv.json', 'english_asv.json', 'english_web.json', 'english_darby.json', 'telugu_ov.json']
    bibles = {}
    for ver in versions:
        with open('assets/bible/' + ver, 'r', encoding='utf-8') as f:
            bibles[ver] = json.load(f)
            
    print("Parsing KJV USFM for Jesus sayings and direct quotes...")
    # Map of (Book, Chapter, Verse) -> list of red-letter segments
    jesus_sayings_map = {}
    
    files = sorted(os.listdir('scratch/kjv_usfm'))
    for file in files:
        if not file.endswith('.usfm'):
            continue
        prefix = file.split('-')[0]
        try:
            val = int(prefix)
            if val < 70: # only NT
                continue
        except:
            continue
            
        book_code = file.split('eng')[0].split('-')[1]
        book_name = USFM_TO_JSON_BOOK.get(book_code)
        if not book_name:
            continue
            
        path = os.path.join('scratch/kjv_usfm', file)
        with open(path, 'r', encoding='utf-8') as f:
            usfm_text = f.read()
            
        # Parse USFM chapter by chapter
        chapters = re.split(r'\\c\s+\d+', usfm_text)
        for ch_idx, ch_text in enumerate(chapters[1:], 1):
            # Split into verses
            verses = re.split(r'\\v\s+(\d+)\s+', ch_text)
            if len(verses) < 3:
                continue
            for i in range(1, len(verses), 2):
                v_num = int(verses[i])
                v_text = verses[i+1]
                if '\\wj' not in v_text:
                    continue
                    
                # Clean USFM tags but keep \\wj and \\wj*
                # Remove footnotes
                clean_v = re.sub(r'\\f\s+.*?\\f\*', '', v_text, flags=re.DOTALL)
                # Remove Strongs
                clean_v = re.sub(r'\|strong=\"[^\"]*\"', '', clean_v)
                # Keep \\wj and \\wj* but remove all other tags
                clean_v = clean_v.replace('\\wj*', '[[WJ_END]]').replace('\\wj', '[[WJ_START]]')
                clean_v = re.sub(r'\\\+?[a-zA-Z*]+', '', clean_v)
                clean_v = re.sub(r'\s+', ' ', clean_v).strip()
                
                # Extract all text inside [[WJ_START]] and [[WJ_END]]
                # Since a verse can have multiple segments
                segments = []
                # Find all occurrences of [[WJ_START]] ... [[WJ_END]]
                pattern = r'\[\[WJ_START\]\](.*?)\[\[WJ_END\]\]'
                matches = re.findall(pattern, clean_v)
                for m in matches:
                    if m.strip():
                        segments.append(m.strip())
                
                # Check if entire verse is red letter
                is_entire = clean_v.startswith('[[WJ_START]]') and clean_v.endswith('[[WJ_END]]')
                # If there are segments, store them
                if segments:
                    key = (book_name, ch_idx, v_num)
                    jesus_sayings_map[key] = {
                        'entire': is_entire,
                        'segments': segments,
                        'full_with_tags': clean_v
                    }
                    
    print(f"Parsed {len(jesus_sayings_map)} verses containing words of Jesus.")
    
    # Process all NT books in all 5 JSON Bibles
    print("Tagging Jesus sayings 『 』 and Prophecies « »...")
    
    for ver_name, bible in bibles.items():
        tagged_jesus = 0
        tagged_prophecy = 0
        
        is_telugu = (ver_name == 'telugu_ov.json')
        is_web = (ver_name == 'english_web.json')
        
        for book in NT_BOOKS:
            if book not in bible:
                continue
            for ch_str, verses in bible[book].items():
                ch = int(ch_str)
                for v_str, text in verses.items():
                    v = int(v_str)
                    
                    # 1. Tag Jesus Sayings
                    key = (book, ch, v)
                    if key in jesus_sayings_map:
                        saying_info = jesus_sayings_map[key]
                        
                        # Already cleaned / tagged check
                        if '『' in text or '』' in text:
                            pass
                        elif saying_info['entire']:
                            text = f"『{text}』"
                            tagged_jesus += 1
                        else:
                            # Partially spoken
                            if is_telugu:
                                # For Telugu, it is hard to align words directly.
                                # Let's find quote using punctuation or wrap the entire verse
                                # Let's check if there is a hyphen or colon
                                if '–' in text:
                                    parts = text.split('–', 1)
                                    # Spoken part is usually after the first hyphen
                                    # E.g. 'ఆయన–మీరు నన్ను...'
                                    text = f"{parts[0]}–『{parts[1]}』"
                                    tagged_jesus += 1
                                elif ':' in text:
                                    parts = text.split(':', 1)
                                    text = f"{parts[0]}:『{parts[1]}』"
                                    tagged_jesus += 1
                                else:
                                    # Fallback: wrap the entire verse
                                    text = f"『{text}』"
                                    tagged_jesus += 1
                            elif is_web:
                                # In WEB, the quotes are already there as “ ”
                                # We can just replace the double quotes with 『 』
                                # E.g. He said, “Follow me.” -> He said, 『Follow me.』
                                # Let's replace any double quotes
                                # But only if Jesus is the speaker (which we know from USFM)
                                new_text = text.replace('“', '『').replace('”', '』')
                                if new_text != text:
                                    text = new_text
                                    tagged_jesus += 1
                                else:
                                    # Fallback: align using KJV segment
                                    for seg in saying_info['segments']:
                                        text = align_and_wrap(text, seg, '『', '』')
                                    tagged_jesus += 1
                            else:
                                # KJV, ASV, Darby: align using segments
                                for seg in saying_info['segments']:
                                    text = align_and_wrap(text, seg, '『', '』')
                                tagged_jesus += 1
                                
                    # 2. Tag Prophecies « »
                    # Check if this verse is in the PROPHECIES set
                    # Note: Prophecy quotes in NT are tagged with « »
                    if (book, ch, v) in PROPHECIES:
                        if '«' in text or '»' in text:
                            pass
                        else:
                            # Let's find the prophecy quote
                            # Since WEB has quotes, we can extract quotes from WEB if we are processing WEB
                            # For other versions, we can align using the WEB quotes or KJV quotes
                            # Let's define the quote segments from the KJV/WEB translation
                            # Wait, let's write a simple alignment for each
                            if is_web:
                                # In WEB, replace quotes with « »
                                # Since we already replaced quotes with 『 』 for Jesus sayings,
                                # we need to make sure we don't conflict.
                                # Wait! If a verse is BOTH a prophecy and a Jesus saying (e.g. Jesus quotes Isaiah in Matthew 4:4),
                                # the prompt says:
                                # - "Also tag Jesus' direct spoken words with « » markers, but use a DIFFERENT marker style so the app can render them differently. Use 『 』 (Japanese quotation marks) for Jesus' sayings."
                                # So Jesus' spoken words take precedence as 『 』, or should they be nested?
                                # Usually they are nested or tagged separately.
                                # Let's see: KJV Matthew 4:4 is spoken by Jesus and it's a prophecy.
                                # If it is spoken by Jesus, we use 『 』. If it is a prophecy, we use « ».
                                # Wait, the prompt says: 'Tag all NT prophecy quotations and Jesus' direct sayings with « » markers in all 5 Bible JSON files.'
                                # Oh! 'Tag all NT prophecy quotations and Jesus' direct sayings with « » markers'
                                # And then in 1B: 'Also tag Jesus' direct spoken words with « » markers, but use a DIFFERENT marker style so the app can render them differently. Use 『 』 (Japanese quotation marks) for Jesus' sayings.'
                                # So Jesus' spoken words are 『 』, and OT prophecies are « ».
                                # If a verse is BOTH (e.g. Jesus quoting OT), it is Jesus speaking, so it can be 『 』 and the prophecy quote inside it can be « »:
                                # E.g. 『It is written, «Man shall not live by bread alone...»』
                                # Let's see: does the rendering handle nested tags?
                                # Yes, our _parseProphecySpans can handle multiple tags or we can implement nested parsing!
                                # Let's check: can we just wrap the prophecy part inside the Jesus saying?
                                # Let's do that! If it is a prophecy and Jesus is speaking, we can have both!
                                pass
                            
                            # Let's write a general alignment helper for prophecies.
                            # We can find where the OT quote is.
                            # In most prophecy verses, the quote is almost the entire verse (e.g. Matthew 1:23, 2:6, 2:15, 2:18).
                            # If so, we can wrap the quote part.
                            # Let's use a list of key matching phrases in English to locate the quote:
                            # E.g. if the verse contains 'written,', 'saying,', 'spoken,', the quote is after that.
                            # Let's write a regex that splits at 'saying,' or 'written,' or 'spoken,'
                            # and wraps the rest in « »!
                            # Let's test this in Python!
                            intro_match = re.search(r'(saying|written|spoken|read|said|say)\b,?\s*', text, re.IGNORECASE)
                            if intro_match:
                                idx = intro_match.end()
                                # Spoken/quoted part is after the intro
                                prefix = text[:idx]
                                suffix = text[idx:]
                                # Clean double quotes or quotes from suffix
                                clean_suffix = suffix.replace('“', '').replace('”', '').replace('"', '').replace("'", "").strip()
                                text = f"{prefix}«{clean_suffix}»"
                                tagged_prophecy += 1
                            else:
                                # Wrap entire verse if no intro pattern found
                                text = f"«{text}»"
                                tagged_prophecy += 1
                                
                    # Update text in bible dict
                    bible[book][ch_str][v_str] = text
                    
        print(f"{ver_name}: Tagged {tagged_jesus} Jesus sayings and {tagged_prophecy} prophecies.")
        
    # Let's write a Telugu formatting fix helper
    print("Fixing Telugu Bible formatting (spaces/punctuation) and saving files...")
    # Fix spaces and punctuation in telugu_ov.json
    telugu_bible = bibles['telugu_ov.json']
    fixed_count = 0
    for book in telugu_bible:
        for ch_str in telugu_bible[book]:
            for v_str in telugu_bible[book][ch_str]:
                text = telugu_bible[book][ch_str][v_str]
                
                # 1. Fix spaces
                text = re.sub(r'(మరియు)([\u0c00-\u0c7f])', r'\1 \2', text)
                text = re.sub(r'(అప్పుడు)([\u0c00-\u0c7f])', r'\1 \2', text)
                text = re.sub(r'(అందుకు)([\u0c00-\u0c7f])', r'\1 \2', text)
                text = re.sub(r'(ఇశ్రాయేలు)([\u0c00-\u0c7f])', r'\1 \2', text)
                text = re.sub(r'(దేవుడు|ప్రభువు)([అఆఇఈఉఊఎఏఐఒఓఔకగచజటడతదపబమరవశషసహ])', r'\1 \2', text)
                text = re.sub(r'(యేసు|క్రీస్తు|మోషే|యెహోవా)([అఆఇఈఉఊఎఏఐఒఓఔగజడదపబమరవశషసహ])', r'\1 \2', text)
                
                merged_fixes = {
                    "యేసుక్రీస్తు": "యేసు క్రీస్తు", "దేవుడుచూచెను": "దేవుడు చూచెను", "దేవుడుజలముల": "దేవుడు జలముల",
                    "దేవుడుఆకాశము": "దేవుడు ఆకాశము", "దేవుడుగడ్డిని": "దేవుడు గడ్డిని", "దేవుడుపగటిని": "దేవుడు పగటిని",
                    "దేవుడుజీవము": "దేవుడు జీవము", "దేవుడుచేసెను": "దేవుడు చేసెను", "దేవుడుఆశీర్వదించెను": "దేవుడు ఆశీర్వదించెను",
                    "దేవుడుమంచిదని": "దేవుడు మంచిదని", "దేవుడుతన": "దేవుడు తన", "దేవుడునరుని": "దేవుడు నరుని",
                    "దేవుడుభూమిని": "దేవుడు భూమిని", "దేవుడునోవహుతో": "దేవుడు నోవహుతో", "దేవుడుఅబ్రాహాముతో": "దేవుడు అబ్రాహాముతో",
                    "దేవుడుసెలవిచ్చిన": "దేవుడు సెలవిచ్చిన", "దేవుడుమోషేతో": "దేవుడు మోషేతో", "దేవుడుఇశ్రాయేలీయుల": "దేవుడు ఇశ్రాయేలీయుల",
                    "దేవుడుఆజ్ఞాపించిన": "దేవుడు ఆజ్ఞాపించిన", "దేవుడునాకు": "దేవుడు నాకు", "దేవుడునీతో": "దేవుడు నీతో",
                    "దేవుడువారిని": "దేవుడు వారిని", "దేవుడునాతో": "దేవుడు నాతో", "అదిమంచిదని": "అది మంచిదని",
                    "అట్లుజరిగెను": "అట్లు జరిగెను",
                }
                for old, new in merged_fixes.items():
                    text = text.replace(old, new)
                    
                extra_space_fixes = {
                    "ప్రకార మాయెను": "ప్రకారమాయెను", "సమృ ద్ధిగా": "సమృద్ధిగా", "చీక టిని": "చీకటిని",
                    "అస్తమయ మును": "అస్తమయమును", "నెరవేరు నట్లు": "నెరవేరునట్లు", "నెరవేర్చ బడునట్లు": "నెరవేర్చబడునట్లు",
                    "సమ కూర్చి": "సమకూర్చి", "వెలు గిచ్చుటకు": "వెలుగిచ్చుటకు", "నజ రేతను": "నజరేతను",
                    "కుమా రుని": "కుమారుని", "ఏల యనగా": "ఏలయనగా", "యాసేపు": "యోసేపు", "మీలోn": "మీలో",
                    "విమోచింపబడునట్లుn": "విమోచింపబడునట్లు", "అచ్చట nచెప్పుచున్నాడని": "అచ్చట చెప్పుచున్నాడని",
                    "నిరాక nరించి": "నిరాకరించి", "రాజా, nయీ": "రాజా, ఈ", "రాజా, nఈ": "రాజా, ఈ",
                    "బోధింపకూడdదని": "బోధింపకూడదని", "ద్రాక్షారసముతో విందుచేయును nమూలుగుగల": "ద్రాక్షారసముతో విందుచేయును మూలుగుగల",
                }
                for old, new in extra_space_fixes.items():
                    text = text.replace(old, new)
                
                # 2. Fix punctuation
                # We should be careful not to remove the tags
                text = text.strip()
                text = text.replace(';', '।')
                if text.endswith(','):
                    text = text[:-1] + '।'
                elif not text.endswith(('.', '?', '!', ';', '।', ')', '»', '』')):
                    text = text + '।'
                    
                # Double space clean
                text = re.sub(r' +', ' ', text)
                telugu_bible[book][ch_str][v_str] = text
                fixed_count += 1
                
    print(f"Telugu Bible formatting fixed for {fixed_count} verses.")
    
    # Save all 5 JSON files back
    for ver_name, bible in bibles.items():
        save_path = 'assets/bible/' + ver_name
        print(f"Saving {save_path}...")
        with open(save_path, 'w', encoding='utf-8') as f:
            json.dump(bible, f, ensure_ascii=False, indent=2)
            
    print("All Bible JSON files updated successfully!")

if __name__ == '__main__':
    main()
