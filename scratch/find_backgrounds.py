import os
import re

screens_dir = "/home/david/Music/Bible Quiz/lib/screens"
pattern_isdark = re.compile(
    r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
    r'begin:\s*Alignment\.topLeft,\s*'
    r'end:\s*Alignment\.bottomRight,\s*'
    r'colors:\s*isDark\s*\?\s*const\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*:\s*const\s*\[Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\)\]\s*,?\s*\),?\s*\),?\s*\),?'
)

pattern_const_isdark = re.compile(
    r'Container\(\s*decoration:\s*const\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
    r'begin:\s*Alignment\.topLeft,\s*'
    r'end:\s*Alignment\.bottomRight,\s*'
    r'colors:\s*isDark\s*\?\s*const\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*:\s*const\s*\[Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\)\]\s*,?\s*\),?\s*\),?\s*\),?'
)

pattern_fixed_const = re.compile(
    r'Container\(\s*decoration:\s*const\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
    r'colors:\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*,\s*'
    r'begin:\s*Alignment\.topLeft,\s*'
    r'end:\s*Alignment\.bottomRight,\s*,?\s*\),?\s*\),?\s*\),?'
)

pattern_fixed = re.compile(
    r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
    r'colors:\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*,\s*'
    r'begin:\s*Alignment\.topLeft,\s*'
    r'end:\s*Alignment\.bottomRight,\s*,?\s*\),?\s*\),?\s*\),?'
)

files = os.listdir(screens_dir)
matched_count = 0

for filename in files:
    if not filename.endswith('.dart'):
        continue
    path = os.path.join(screens_dir, filename)
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    matches = []
    for p_name, pattern in [('isdark', pattern_isdark), ('const_isdark', pattern_const_isdark), ('fixed_const', pattern_fixed_const), ('fixed', pattern_fixed)]:
        for m in pattern.finditer(content):
            matches.append((p_name, m.start(), m.end(), m.group(0)))
            
    if matches:
        matched_count += 1
        print(f"Matched {filename}:")
        for p_name, start, end, text in matches:
            line_no = content[:start].count('\n') + 1
            print(f"  - Pattern: {p_name} at line {line_no}")
            print(f"  - Content: {text[:100]}...")

print(f"\nTotal matched files: {matched_count} out of {len(files)}")
