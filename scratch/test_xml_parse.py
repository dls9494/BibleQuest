import os
import xml.etree.ElementTree as ET

REF_FILES = {
    "telugu_ov": "/tmp/bible_ref/Telugu Bible (BSI).xml",
    "telugu_wbtc": "/tmp/bible_ref/Telugu Bible (WBTC).xml",
    "kjv": "/tmp/bible_ref/King James Version (1769).xml",
    "asv": "/tmp/bible_ref/American Standard Version (1901).xml",
    "web": "/tmp/bible_ref/World English Bible.xml",
    "darby": "/tmp/bible_ref/The Darby Bible (1890).xml",
}

for name, path in REF_FILES.items():
    if not os.path.exists(path):
        continue
    try:
        tree = ET.parse(path)
        root = tree.getroot()
        nested_tags = set()
        for verse in root.findall(".//VERS"):
            if len(verse) > 0:
                for child in verse:
                    nested_tags.add(child.tag)
        if nested_tags:
            print(f"{name}: Found nested tags under <VERS>: {nested_tags}")
        else:
            print(f"{name}: No nested tags under <VERS>.")
    except Exception as e:
        print(f"{name}: Error: {e}")
