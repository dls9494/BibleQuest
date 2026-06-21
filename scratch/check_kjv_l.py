import re

with open("/tmp/kjv_mismatches.txt", "r") as f:
    lines = f.readlines()

count = 0
for line in lines:
    if not line.strip() or "Total mismatches:" in line:
        continue
    parts = line.split(" | USFM: ")
    if len(parts) < 2:
        continue
    loc = parts[0]
    parts2 = parts[1].split(" | DB: ")
    raw = parts2[0]
    db = parts2[1]
    
    r_norm = raw.lower().replace("æ", "ae").replace("œ", "oe")
    d_norm = db.lower().replace("æ", "ae").replace("œ", "oe")
    
    def norm_more(t):
        t = t.replace("-", "").replace("(", "").replace(")", "")
        t = t.replace("’", "").replace("‘", "").replace("'", "")
        t = t.replace("“", "").replace("”", "").replace("\"", "")
        t = t.replace(".", "").replace(",", "").replace(";", "").replace(":", "")
        t = t.replace(" ", "").strip()
        return t
        
    if norm_more(r_norm) != norm_more(d_norm):
        count += 1
        if count <= 100:
            print(loc)
            print("  USFM:", raw.strip())
            print("  DB  :", db.strip())

print("Total mismatch count after ligature normalization:", count)
