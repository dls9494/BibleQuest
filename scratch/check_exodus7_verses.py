import xml.etree.ElementTree as ET
import sqlite3

xml_path = "/home/david/Downloads/Telugu Bible (BSI).xml"
db_path = "/home/david/Music/Bible Quiz/assets/bible/telugu_ov.sqlite"

tree = ET.parse(xml_path)
root = tree.getroot()
ex_xml = root.find(".//BIBLEBOOK[@bnumber='2']")
ch7_xml = ex_xml.find(".//CHAPTER[@cnumber='7']")

print("XML Exodus 7 count of VERS tags:", len(ch7_xml.findall("VERS")))
for v in ch7_xml.findall("VERS"):
    vnum = v.attrib.get('vnumber')
    if int(vnum) >= 23:
        print(f"XML Verse {vnum}: {''.join(v.itertext())}")

print("\nSQLite Exodus 7 verses >= 23:")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()
cursor.execute("SELECT verse, text FROM verses WHERE book_number=2 AND chapter=7 AND verse>=23 ORDER BY verse")
for verse, text in cursor.fetchall():
    print(f"SQLite Verse {verse}: {text}")
conn.close()
