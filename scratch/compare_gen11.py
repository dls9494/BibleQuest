import sqlite3

versions = ["telugu_ov", "telugu_irv", "telugu_wbtc"]
for v in versions:
    db_path = f"/home/david/Music/Bible Quiz/assets/bible/{v}.sqlite"
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT text FROM verses WHERE book_name = 'Genesis' AND chapter = 1 AND verse = 1")
    res = cursor.fetchone()
    text = res[0] if res else "NOT FOUND"
    print(f"{v} Gen 1:1 -> {text}")
    conn.close()
