import xml.etree.ElementTree as ET

xml_path = "/home/david/Music/Bible Quiz/audit/Telugu Bible (BSI) Clean.xml"
tree = ET.parse(xml_path)
root = tree.getroot()

ephesians = root.find(".//BIBLEBOOK[@bnumber='49']")
ch4 = ephesians.find(".//CHAPTER[@cnumber='4']")
v14 = ch4.find(".//VERS[@vnumber='14']")
print("Ephesians 4:14 Text:", v14.text)
