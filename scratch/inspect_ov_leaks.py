import sqlite3
import re

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("SELECT book_name, chapter, verse, text FROM verses")
rows = cursor.fetchall()

leaks = []
for r in rows:
    book, ch, v, text = r
    if not text:
        continue
    # Check for Latin characters (5 or more consecutive letters)
    if re.search(r'[a-zA-Z]{5,}', text):
        leaks.append((book, ch, v, text))
    if "\ufffd" in text:
        leaks.append((book, ch, v, "[Broken Unicode] " + text))

print(f"Found {len(leaks)} integrity issues in telugu_ov:")
for item in leaks:
    print(f"{item[0]} {item[1]}:{item[2]} -> {item[3]}")

conn.close()
