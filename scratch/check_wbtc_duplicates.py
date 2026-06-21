import sqlite3

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_wbtc.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("""
    SELECT text, COUNT(*), GROUP_CONCAT(book_name || ' ' || chapter || ':' || verse)
    FROM verses
    GROUP BY text
    HAVING COUNT(*) > 1 AND length(text) > 15
""")

duplicates = cursor.fetchall()
print(f"Total distinct duplicate texts: {len(duplicates)}")
print("\nDuplicate details:")
for text, count, refs in duplicates[:20]:
    # Print first 20 duplicates
    print(f"Count: {count} | Refs: {refs[:100]}... | Text: {text[:60]}")

conn.close()
