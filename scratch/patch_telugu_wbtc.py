import sqlite3
import re

db_path = "assets/bible/telugu_wbtc.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Get all verses
cursor.execute("SELECT book_name, chapter, verse, text FROM verses")
rows = cursor.fetchall()

changes_count = 0
for r in rows:
    book, ch, v, text = r
    if not text:
        continue
    
    # 1. Clean multiple spaces and strip leading/trailing spaces
    new_text = re.sub(r' +', ' ', text).strip()
    
    # 2. Fix Song of Solomon 1:1 English leak
    if book == "Song of Solomon" and ch == 1 and v == 1:
        new_text = new_text.replace("(Song of Solomon ) ", "").strip()
        
    if new_text != text:
        cursor.execute(
            "UPDATE verses SET text=? WHERE book_name=? AND chapter=? AND verse=?",
            (new_text, book, ch, v)
        )
        changes_count += 1

conn.commit()
conn.close()

print(f"Successfully patched {changes_count} verses in telugu_wbtc.sqlite.")
