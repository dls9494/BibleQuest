import json
import re

json_path = "/home/david/Documents/tel_new/telugu_bible_fixed.json"
with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

merged_words = []
for book in data.get('telugu_bible', []):
    book_name = book.get('book_name')
    for chapter in book.get('chapters', []):
        chap_num = chapter.get('chapter_number')
        for v in chapter.get('verses', []):
            vnum = v.get('verse_number')
            text = v.get('text', '')
            if not text:
                continue
            
            # Check for Telugu string > 25 chars without spaces/punctuation
            telugu_words = re.findall(r'[\u0c00-\u0c7f]+', text)
            for word in telugu_words:
                if len(word) > 25:
                    merged_words.append((book_name, chap_num, vnum, word, text))

print(f"Total merged words in telugu_bible_fixed.json: {len(merged_words)}")
print("\nFirst 10 instances:")
for item in merged_words[:10]:
    print(f"{item[0]} {item[1]}:{item[2]} -> Word length {len(item[3])}: '{item[3]}' -> Text: {item[4][:80]}")
