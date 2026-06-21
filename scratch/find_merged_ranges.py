import pypdf
import re

pdf_path = "/home/david/Documents/tel2017_a4.pdf"
reader = pypdf.PdfReader(pdf_path)

merged_patterns = []

for idx, page in enumerate(reader.pages):
    text = page.extract_text()
    if not text:
        continue
    for line in text.split('\n'):
        line = line.strip()
        # Look for lines starting with "digit-digit" followed by space
        match = re.match(r'^(\d+-\d+)\s+(.*)$', line)
        if match:
            merged_patterns.append((idx, match.group(1), match.group(2)[:60]))

print(f"Found {len(merged_patterns)} lines starting with merged verse ranges in the PDF:")
for page_num, range_str, snippet in merged_patterns[:30]:
    print(f"Page {page_num} -> Range: {range_str} -> Snippet: {snippet}")

if len(merged_patterns) > 30:
    print(f"... and {len(merged_patterns)-30} more.")
