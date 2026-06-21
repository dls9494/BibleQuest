import sqlite3

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Get the list of merged words issues from the audit logic
# The audit checks if a word in Telugu is longer than 25 characters without spaces/punctuation
cursor.execute("SELECT book_name, chapter, verse, text FROM verses")
rows = cursor.fetchall()

import re
merged_words = []
for r in rows:
    book, ch, v, text = r
    if not text:
        continue
    # Merged Telugu word heuristic: contiguous Telugu Unicode string longer than 25 chars without spaces/punctuation
    telugu_words = re.findall(r'[\u0c00-\u0c7f]+', text)
    for word in telugu_words:
        if len(word) > 25:
            merged_words.append((book, ch, v, word, text))

print(f"Total potential merged words found in telugu_ov: {len(merged_words)}")
print("\nFirst 15 instances:")
for item in merged_words[:15]:
    print(f"{item[0]} {item[1]}:{item[2]} -> Word length {len(item[3])}: '{item[3]}' -> Text: {item[4][:80]}")

conn.close()
