import xml.etree.ElementTree as ET

xml_path = "/home/david/Downloads/Telugu Bible (BSI).xml"
try:
    tree = ET.parse(xml_path)
    root = tree.getroot()
    print("Root tag:", root.tag)
    print("Root attribs:", root.attrib)
    
    first_book = root.find(".//BIBLEBOOK")
    if first_book is not None:
        print("First BIBLEBOOK bnumber:", first_book.attrib.get("bnumber"))
        print("First BIBLEBOOK bname:", first_book.attrib.get("bname"))
        first_chap = first_book.find(".//CHAPTER")
        if first_chap is not None:
            print("  First CHAPTER cnumber:", first_chap.attrib.get("cnumber"))
            first_vers = first_chap.find(".//VERS")
            if first_vers is not None:
                print("    First VERS vnumber:", first_vers.attrib.get("vnumber"))
                print("    First VERS text:", "".join(first_vers.itertext())[:50])
except Exception as e:
    print("Error:", e)
