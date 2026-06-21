import re

path = "/home/david/Music/Bible Quiz/lib/screens/bible_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Find all occurrences of word 'Row'
matches = re.finditer(r'\bRow\b', content)
for m in matches:
    start = max(0, m.start() - 40)
    end = min(len(content), m.end() + 40)
    line_no = content[:m.start()].count('\n') + 1
    snippet = content[start:end].replace('\n', ' ')
    print(f"Line {line_no:4d}: ... {snippet} ...")
