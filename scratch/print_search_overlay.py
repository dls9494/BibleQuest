path = "/home/david/Music/Bible Quiz/lib/screens/bible_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    lines = f.read().splitlines()

for idx in range(1830, 1900):
    print(f"{idx+1:4d}: {lines[idx]}")
