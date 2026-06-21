path = "/home/david/Music/Bible Quiz/lib/screens/bible_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Let's count open/close braces in the file step by step and print class/function scopes
lines = content.splitlines()
brace_level = 0
class_start_line = -1
class_name = ""

for idx, line in enumerate(lines):
    # simple brace level tracker
    for char in line:
        if char == '{':
            brace_level += 1
        elif char == '}':
            brace_level -= 1
            if brace_level == 0:
                if class_start_line != -1:
                    print(f"Brace level returned to 0 at line {idx+1}. Class {class_name} ended. (Started at {class_start_line})")
                    class_start_line = -1
    
    if "class _BibleScreenState" in line:
        class_start_line = idx + 1
        class_name = "_BibleScreenState"
        brace_level = line.count('{') - line.count('}')
        print(f"Class _BibleScreenState starts at line {idx+1}")
