path = "/home/david/Music/Bible Quiz/lib/screens/bible_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Let's search for top-level definitions of Row
import re
# Top-level declarations look like: type/class/var/function named Row at the start of a line or in class bodies, but here it's reported as a top-level export/definition of the library.
# We can find matches for things like:
# void Row
# class Row
# var Row
# final Row
# Row Row
# etc.
# Or let's look at lines matching:
# ^(?!class|import|part|export|library)\w+\s+Row\b
# or similar.

lines = content.splitlines()
for idx, line in enumerate(lines):
    # check if line starts with a type/return type and has "Row" as a function/variable name
    # e.g., "  Row _buildVerseRow" or "class Row" or similar, or maybe a method returning "Row" in some helper class? No, that would be a member, not a top-level symbol. A top-level symbol would be outside any class.
    # Let's search for top-level declarations:
    if line.strip().startswith("class Row") or line.strip().startswith("void Row") or line.strip().startswith("dynamic Row") or re.search(r'^[A-Za-z0-9_<>]+\s+Row\b', line):
        print(f"Line {idx+1}: {line}")
