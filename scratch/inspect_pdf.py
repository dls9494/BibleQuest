import pypdf
import re

reader = pypdf.PdfReader('assets/bible/tel2017_a4.pdf')

header_pattern = re.compile(
    r'^([1-3\s]*[\u0c00-\u0c7f\s\d\w\-]+?)\s*(\d+(?::\d+(?:-\d+)?)?)\s+(\d+)\s+([1-3\s]*[\u0c00-\u0c7f\s\d\w\-]+?)\s*(\d+(?::\d+(?:-\d+)?)?)$'
)

unmatched = []
for idx in range(4, len(reader.pages)):
    text = reader.pages[idx].extract_text()
    lines = text.split('\n')
    if not lines or not lines[0].strip():
        unmatched.append((idx, "EMPTY"))
        continue
    header = lines[0].strip()
    if not header_pattern.match(header):
        unmatched.append((idx, header))

print(f"Total unmatched pages: {len(unmatched)}")
for idx, h in unmatched[:50]:
    print(f"  Page {idx}: {h!r}")
