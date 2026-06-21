import sqlite3

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_wbtc.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("SELECT book_name, chapter, verse, text FROM verses")
rows = cursor.fetchall()

leading_trailing = []
double_spaces = []
line_breaks = []
tabs = []

for r in rows:
    book, ch, v, text = r
    if not text:
        continue
    if text.startswith(" ") or text.endswith(" "):
        leading_trailing.append((book, ch, v, text))
    if "  " in text:
        double_spaces.append((book, ch, v, text))
    if "\n" in text or "\r" in text:
        line_breaks.append((book, ch, v, text))
    if "\t" in text:
        tabs.append((book, ch, v, text))

print(f"Leading/trailing space count: {len(leading_trailing)}")
print(f"Double space count: {len(double_spaces)}")
print(f"Line break count: {len(line_breaks)}")
print(f"Tab character count: {len(tabs)}")

print("\nSample double spaces (first 5):")
for item in double_spaces[:5]:
    print(f"{item[0]} {item[1]}:{item[2]} -> '{item[3][:60]}'")

conn.close()
