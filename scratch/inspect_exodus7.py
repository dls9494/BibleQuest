import xml.etree.ElementTree as ET
import sqlite3

xml_path = "/home/david/Downloads/Telugu Bible (BSI).xml"
db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"

print("--- XML Exodus 7 Verses ---")
tree = ET.parse(xml_path)
root = tree.getroot()
exodus_xml = root.find(".//BIBLEBOOK[@bnumber='2']")
if exodus_xml is not None:
    ch7 = exodus_xml.find(".//CHAPTER[@cnumber='7']")
    if ch7 is not None:
        for vers in ch7.findall("VERS"):
            print(f"Verse {vers.attrib.get('vnumber')}: {''.join(vers.itertext())[:50]}")

print("\n--- SQLite Exodus 7 Verses ---")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()
cursor.execute("SELECT verse, text FROM verses WHERE book_number=2 AND chapter=7 ORDER BY verse")
for verse, text in cursor.fetchall():
    print(f"Verse {verse}: {text[:50]}")
conn.close()
