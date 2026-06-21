import sqlite3
import os

db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"

# Spacing fixes to insert missing space
updates = [
    # 22. Judges 5:2
    {
        "book_name": "Judges",
        "chapter": 5,
        "verse": 2,
        "old_str": "ఇశ్రాయేలీయులలోయుద్ధశాలులు",
        "new_str": "ఇశ్రాయేలీయులలో యుద్ధశాలులు"
    },
    # 23. Judges 6:8
    {
        "book_name": "Judges",
        "chapter": 6,
        "verse": 8,
        "old_str": "ప్రకటించెనుఇశ్రాయేలీయుల",
        "new_str": "ప్రకటించెను ఇశ్రాయేలీయుల"
    },
    # 31. 1 Samuel 5:11
    {
        "book_name": "1 Samuel",
        "chapter": 5,
        "verse": 11,
        "old_str": "పిలువనంపించిఇశ్రాయేలీయుల",
        "new_str": "పిలువనంపించి ఇశ్రాయేలీయుల"
    },
    # 32. 1 Samuel 7:5
    {
        "book_name": "1 Samuel",
        "chapter": 7,
        "verse": 5,
        "old_str": "సమూయేలుఇశ్రాయేలీయులందరిని",
        "new_str": "సమూయేలు ఇశ్రాయేలీయులందరిని"
    },
    # 41. 2 Samuel 2:5
    {
        "book_name": "2 Samuel",
        "chapter": 2,
        "verse": 5,
        "old_str": "యాబేష్గిలాదువారియొద్దకు",
        "new_str": "యాబేష్గిలాదు వారియొద్దకు"
    },
    # 51. 2 Kings 24:1
    {
        "book_name": "2 Kings",
        "chapter": 24,
        "verse": 1,
        "old_str": "బబులోనురాజైననెబుకద్నెజరు",
        "new_str": "బబులోనురాజైన నెబుకద్నెజరు"
    },
    # 110. Matthew 16:13
    {
        "book_name": "Matthew",
        "chapter": 16,
        "verse": 13,
        "old_str": "వచ్చిమనుష్యకుమారుడెవడని",
        "new_str": "వచ్చి మనుష్యకుమారుడెవడని"
    },
    # 111. Matthew 19:10
    {
        "book_name": "Matthew",
        "chapter": 19,
        "verse": 10,
        "old_str": "శిష్యులుభార్యాభర్తలకుండు",
        "new_str": "శిష్యులు భార్యాభర్తలకుండు"
    }
]

def run_updates():
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    for idx, upd in enumerate(updates, 1):
        print(f"\n--- Update {idx}: {upd['book_name']} {upd['chapter']}:{upd['verse']} ---")
        
        # Get current text
        cursor.execute(
            "SELECT text FROM verses WHERE book_name=? AND chapter=? AND verse=?",
            (upd['book_name'], upd['chapter'], upd['verse'])
        )
        row = cursor.fetchone()
        
        if not row:
            print(f"ERROR: Verse not found in database!")
            continue
            
        current_text = row[0]
        print(f"BEFORE: {current_text}")
        
        if upd['old_str'] not in current_text:
            print(f"WARNING: Target string '{upd['old_str']}' not found in current text!")
            continue
            
        # Perform update
        new_text = current_text.replace(upd['old_str'], upd['new_str'])
        
        cursor.execute(
            "UPDATE verses SET text=? WHERE book_name=? AND chapter=? AND verse=?",
            (new_text, upd['book_name'], upd['chapter'], upd['verse'])
        )
        conn.commit()
        
        # Verify
        cursor.execute(
            "SELECT text FROM verses WHERE book_name=? AND chapter=? AND verse=?",
            (upd['book_name'], upd['chapter'], upd['verse'])
        )
        updated_text = cursor.fetchone()[0]
        print(f"AFTER:  {updated_text}")
        
    conn.close()

if __name__ == "__main__":
    run_updates()
