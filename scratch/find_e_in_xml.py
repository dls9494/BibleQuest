import xml.etree.ElementTree as ET

xml_path = "/home/david/Downloads/Telugu Bible (BSI).xml"
tree = ET.parse(xml_path)
root = tree.getroot()

for book in root.findall('.//BIBLEBOOK'):
    bnum = book.attrib.get('bnumber')
    bname = book.attrib.get('bname')
    for chapter in book.findall('.//CHAPTER'):
        cnum = chapter.attrib.get('cnumber')
        for vers in chapter.findall('.//VERS'):
            vnum = vers.attrib.get('vnumber')
            text = "".join(vers.itertext())
            if 'é' in text:
                print(f"{bname} ({bnum}) {cnum}:{vnum} -> {text}")
