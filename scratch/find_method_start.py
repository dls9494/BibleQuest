path = "/home/david/Music/Bible Quiz/lib/screens/bible_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    lines = f.read().splitlines()

# Search backwards from line 1920
for idx in range(1919, 0, -1):
    line = lines[idx]
    # Methods in classes usually start with two spaces indentation
    if line.startswith("  ") and not line.startswith("    ") and ("(" in line or "{" in line) and not line.strip().startswith("//"):
        print(f"Line {idx+1}: {line}")
        # print 5 lines around it
        start = max(0, idx - 2)
        end = min(len(lines), idx + 5)
        for j in range(start, end):
            print(f"{j+1:4d}: {lines[j]}")
        break
