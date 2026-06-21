import sqlite3

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_irv.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Check Matthew 1
cursor.execute("SELECT verse, text FROM verses WHERE book_name = 'Matthew' AND chapter = 1 ORDER BY verse")
matt_verses = cursor.fetchall()
print("Matthew 1 verses in database:")
for v, t in matt_verses:
    print(f"Verse {v} -> {t[:60]}")

print("\n" + "="*40 + "\n")

# Check Luke 1
cursor.execute("SELECT verse, text FROM verses WHERE book_name = 'Luke' AND chapter = 1 ORDER BY verse")
luke_verses = cursor.fetchall()
print("Luke 1 verses in database (first 10 and last 10):")
for v, t in luke_verses[:10]:
    print(f"Verse {v} -> {t[:60]}")
print("...")
for v, t in luke_verses[-10:]:
    print(f"Verse {v} -> {t[:60]}")

conn.close()
