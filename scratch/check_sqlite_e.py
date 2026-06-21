import sqlite3

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

queries = [
    (5, 12, 17),
    (11, 7, 26),
    (13, 15, 28),
    (21, 11, 5),
    (26, 44, 26)
]

for b, c, v in queries:
    cursor.execute("SELECT book_name, chapter, verse, text FROM verses WHERE book_number=? AND chapter=? AND verse=?", (b, c, v))
    row = cursor.fetchone()
    if row:
        print(f"{row[0]} {row[1]}:{row[2]} -> {row[3]}")
conn.close()
