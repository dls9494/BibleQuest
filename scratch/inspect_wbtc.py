import sqlite3

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_wbtc.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Get total verse count
cursor.execute("SELECT COUNT(*) FROM verses")
total_verses = cursor.fetchone()[0]

# Get count of verses with the placeholder text
placeholder_text = "[This verse may not be a part of this translation]"
cursor.execute("SELECT COUNT(*) FROM verses WHERE text = ?", (placeholder_text,))
placeholder_count = cursor.fetchone()[0]

# Sample some non-placeholder verses
cursor.execute("SELECT book_name, chapter, verse, text FROM verses WHERE text != ? LIMIT 10", (placeholder_text,))
samples = cursor.fetchall()

print(f"Total verses: {total_verses}")
print(f"Placeholder verses: {placeholder_count} ({placeholder_count/total_verses*100:.2f}%)")
print("\nFirst 10 non-placeholder verses:")
for sample in samples:
    print(f"{sample[0]} {sample[1]}:{sample[2]} -> {sample[3][:60]}")

conn.close()
