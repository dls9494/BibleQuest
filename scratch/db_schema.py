import sqlite3

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Get table schema
cursor.execute("PRAGMA table_info(verses)")
columns = cursor.fetchall()
print("Table 'verses' columns:")
for col in columns:
    print(col)

# Get index list
cursor.execute("PRAGMA index_list(verses)")
indices = cursor.fetchall()
print("\nIndices:")
for idx in indices:
    print(idx)

# Sample one row
cursor.execute("SELECT * FROM verses LIMIT 1")
row = cursor.fetchone()
print("\nSample row:")
print(row)

conn.close()
