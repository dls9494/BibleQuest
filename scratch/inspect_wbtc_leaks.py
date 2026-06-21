import sqlite3
import re

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_wbtc.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("SELECT book_name, chapter, verse, text FROM verses")
rows = cursor.fetchall()

placeholder = "[This verse may not be a part of this translation]"
non_placeholder_leaks = []

for r in rows:
    book, ch, v, text = r
    if text == placeholder:
        continue
    # Search for runs of 5 or more Latin letters
    if re.search(r'[a-zA-Z]{5,}', text):
        non_placeholder_leaks.append((book, ch, v, text))

print(f"Found {len(non_placeholder_leaks)} non-placeholder Latin leaks in telugu_wbtc:")
for item in non_placeholder_leaks:
    print(f"{item[0]} {item[1]}:{item[2]} -> {item[3]}")

conn.close()
