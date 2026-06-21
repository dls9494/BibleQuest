import sqlite3

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("""
    SELECT text, COUNT(*), GROUP_CONCAT(book_name || ' ' || chapter || ':' || verse)
    FROM verses
    GROUP BY text
    HAVING COUNT(*) > 1 AND length(text) > 15
""")

duplicates = cursor.fetchall()
print(f"Total distinct duplicate texts in telugu_ov: {len(duplicates)}")
print("\nTop 15 duplicate details:")
for text, count, refs in duplicates[:15]:
    print(f"Count: {count} | Refs: {refs[:100]}... | Text: {text[:60]}")

conn.close()
