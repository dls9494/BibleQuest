import os
import re

screens_dir = "/home/david/Music/Bible Quiz/lib/screens"

replacements = {
    "bookmarks_screen.dart": (
        r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*isDark\s*\?\s*const\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*:\s*const\s*\[Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\)\]\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "search_screen.dart": (
        r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*isDark\s*\?\s*const\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*:\s*const\s*\[Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\)\]\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "settings_screen.dart": (
        r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*isDark\s*\?\s*const\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*:\s*const\s*\[Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\)\]\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "prayer_wall_screen.dart": (
        r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*isDark\s*\?\s*const\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*:\s*const\s*\[Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\)\]\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "highlights_screen.dart": (
        r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*isDark\s*\?\s*const\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*:\s*const\s*\[Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\)\]\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "analytics_debug_screen.dart": (
        r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*isDark\s*\?\s*const\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*:\s*const\s*\[Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\)\]\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "notes_screen.dart": (
        r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*isDark\s*\?\s*const\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*:\s*const\s*\[Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\)\]\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "challenges_screen.dart": (
        r'Container\(\s*decoration:\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*isDark\s*\?\s*const\s*\[\s*Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\),\s*\]\s*:\s*const\s*\[\s*Color\(0xFFFDF6EC\),\s*Color\(0xFFF3E7D8\),\s*\]\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "memory_game_screen.dart": (
        r'Container\(\s*decoration:\s*const\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'colors:\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*,\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "quiz_tab.dart": (
        r'Container\(\s*decoration:\s*const\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'colors:\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*,\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "battle_screen.dart": (
        r'Container\(\s*decoration:\s*const\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'colors:\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*,\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "live_event_screen.dart": (
        r'Container\(\s*decoration:\s*const\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'colors:\s*\[Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\)\]\s*,\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "study_tools_screen.dart": (
        r'Container\(\s*decoration:\s*const\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*\[\s*Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\),\s*\]\s*,?\s*\),?\s*\),?\s*\),?'
    ),
    "profile_screen.dart": (
        r'Container\(\s*decoration:\s*const\s*BoxDecoration\(\s*gradient:\s*LinearGradient\(\s*'
        r'begin:\s*Alignment\.topLeft,\s*'
        r'end:\s*Alignment\.bottomRight,\s*'
        r'colors:\s*\[\s*Color\(0xFF1A1A2E\),\s*Color\(0xFF0F3460\),\s*\]\s*,?\s*\),?\s*\),?\s*\),?'
    )
}

replacement_str = "const Positioned.fill(child: GradientBackground(child: SizedBox.shrink())),"

success_files = []
failed_files = []

for filename, pattern_str in replacements.items():
    path = os.path.join(screens_dir, filename)
    if not os.path.exists(path):
        continue
    
    with open(path, "r", encoding="utf-8") as f:
        original = f.read()
    
    pattern = re.compile(pattern_str)
    new_content, count = pattern.subn(replacement_str, original)
    
    if count > 0:
        if "gradient_background.dart" not in new_content:
            import_statement = "import '../widgets/gradient_background.dart';\n"
            new_content = import_statement + new_content
        
        with open(path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"Applied replacement in {filename} ({count} occurrences)")
        success_files.append(filename)
    else:
        print(f"No match found for {filename}")
        failed_files.append(filename)

print(f"\nModified files: {success_files}")
