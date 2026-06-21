import os

screens_dir = "/home/david/Music/Bible Quiz/lib/screens"
files = [f for f in os.listdir(screens_dir) if f.endswith('.dart')]

for name in files:
    path = os.path.join(screens_dir, name)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Find any LinearGradient
    if "LinearGradient" in content:
        lines = content.splitlines()
        for idx, line in enumerate(lines):
            if "LinearGradient" in line:
                # print 3 lines before and 7 lines after
                print(f"=== {name} (Line {idx+1}) ===")
                start = max(0, idx - 3)
                end = min(len(lines), idx + 8)
                for j in range(start, end):
                    print(f"{j+1:4d}: {lines[j]}")
                print()
