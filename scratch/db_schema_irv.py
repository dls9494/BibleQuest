import sqlite3

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_irv.sqlite"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Get table schema
cursor.execute("PRAGMA table_info(verses)")
columns = cursor.fetchall()
print("Table 'verses' columns:")
for col in columns:
    print(col)

# Get index list and details
cursor.execute("PRAGMA index_list(verses)")
indices = cursor.fetchall()
print("\nIndices:")
for idx in indices:
    name = idx[1]
    cursor.execute(f"PRAGMA index_info({name})")
    info = cursor.fetchall()
    print(f"Index {name}: {info}")

conn.close()
