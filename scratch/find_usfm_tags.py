import zipfile
import re
from collections import Counter

zip_path = "scratch/tel2017_usfm.zip"

tags_counter = Counter()

with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    files = [f.filename for f in zip_ref.infolist() if f.filename.endswith('.usfm')]
    for fname in files:
        content = zip_ref.read(fname).decode('utf-8')
        # Find all patterns starting with backslash followed by letters and optional numbers/stars
        found = re.findall(r'\\[a-zA-Z0-9*+]+', content)
        tags_counter.update(found)

print("Found tags in USFM files:")
for tag, count in tags_counter.most_common(100):
    print(f"  {tag}: {count}")
