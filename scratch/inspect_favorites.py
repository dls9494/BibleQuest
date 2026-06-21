path = "/home/david/Music/Bible Quiz/lib/screens/favorites_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    lines = f.read().splitlines()

for idx in range(65, 115):
    print(f"{idx+1:4d}: {lines[idx]}")
