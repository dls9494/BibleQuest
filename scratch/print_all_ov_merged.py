import sqlite3
import re

db_path = "assets/bible/telugu_ov.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("SELECT book_name, chapter, verse, text FROM verses")
rows = cursor.fetchall()

merged_words = []
for r in rows:
    book, ch, v, text = r
    if not text:
        continue
    telugu_words = re.findall(r'[\u0c00-\u0c7f]+', text)
    for word in telugu_words:
        if len(word) > 25:
            merged_words.append((book, ch, v, word, text))

print(f"Total: {len(merged_words)}")
for idx, (book, ch, v, word, text) in enumerate(merged_words):
    print(f"{idx+1:03d} - {book} {ch}:{v} -> '{word}' -> Text: {text[:100]}")

conn.close()
