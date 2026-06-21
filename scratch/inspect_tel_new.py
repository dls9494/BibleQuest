import json

with open('/home/david/Documents/tel_new/telugu_bible_fixed.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Print keys and structure
print("Structure keys:", data.keys())

# Get Genesis 1:1
telugu_bible = data.get('telugu_bible', [])
if telugu_bible:
    first_book = telugu_bible[0]
    print("Book name:", first_book.get('book_name'))
    chapters = first_book.get('chapters', [])
    if chapters:
        first_chap = chapters[0]
        print("Chapter number:", first_chap.get('chapter_number'))
        verses = first_chap.get('verses', [])
        if verses:
            for v in verses[:5]:
                print(f"Verse {v.get('verse_number')} -> {v.get('text')}")
else:
    # Maybe it's a dict of book names
    print("Empty list or different structure.")
    # Check if data is a dict
    if isinstance(data, dict):
        for k, v in list(data.items())[:2]:
            print(k, type(v))

conn = None
