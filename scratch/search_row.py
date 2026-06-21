path = "/home/david/Music/Bible Quiz/lib/screens/bible_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    lines = f.read().splitlines()

for idx, line in enumerate(lines):
    if "class Row" in line or " Row " in line or "enum Row" in line or "typedef Row" in line:
        print(f"Line {idx+1:4d}: {line}")
