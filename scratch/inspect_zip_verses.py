import zipfile
import re

zip_path = "scratch/tel2017_usfm.zip"

with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    files = [f.filename for f in zip_ref.infolist() if f.filename.endswith('.usfm')]
    print(f"Total USFM files: {len(files)}")
    
    non_numeric_patterns = set()
    total_v = 0
    for fname in files:
        content = zip_ref.read(fname).decode('utf-8')
        for v in re.findall(r'\\v\s+(\S+)', content):
            total_v += 1
            if not v.isdigit():
                non_numeric_patterns.add(v)
                
    print(f"Total verse instances: {total_v}")
    print(f"Non-numeric patterns count: {len(non_numeric_patterns)}")
    print(f"Non-numeric patterns: {sorted(list(non_numeric_patterns))}")
