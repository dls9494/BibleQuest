import os

def revert_file_colors(filepath):
    print(f"Processing: {filepath}")
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # 1. bodyLarge (white/3E2723)
    content = content.replace(
        "Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723))",
        "isDark ? Colors.white : const Color(0xFF3E2723)"
    )
    content = content.replace(
        "Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : const Color(0xFF3E2723))",
        "isDark ? Colors.white : const Color(0xFF3E2723)"
    )

    # 2. bodyLarge (white70/3E2723)
    content = content.replace(
        "Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white70 : Color(0xFF3E2723))",
        "isDark ? Colors.white70 : const Color(0xFF3E2723)"
    )

    # 3. bodyMedium (white70/5D4037)
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Color(0xFF5D4037))",
        "isDark ? Colors.white70 : const Color(0xFF5D4037)"
    )
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : const Color(0xFF5D4037))",
        "isDark ? Colors.white70 : const Color(0xFF5D4037)"
    )

    # 4. bodyMedium (white60/5D4037)
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white60 : Color(0xFF5D4037))",
        "isDark ? Colors.white60 : const Color(0xFF5D4037)"
    )

    # 5. bodyMedium (CBC3D4/5D4037)
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Color(0xFFCBC3D4) : Color(0xFF5D4037))",
        "isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037)"
    )
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Color(0xFFCBC3D4) : Color(0xFF5D4037)).withValues(alpha: 0.8)",
        "(isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037)).withValues(alpha: 0.8)"
    )

    # 6. subTextColor (CBC3D4/5D4037)
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Color(0xFFCBC3D4) : Color(0xFF5D4037))",
        "isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037)"
    )

    # 7. Double theme lookups or direct theme assignments
    content = content.replace(
        "Theme.of(context).textTheme.bodyLarge?.color ?? Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF3E2723)",
        "const Color(0xFF3E2723)"
    )
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5D4037)",
        "const Color(0xFF5D4037)"
    )
    content = content.replace(
        "(isDark ? Color(0xFF38BDF8) : Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5D4037))",
        "(isDark ? const Color(0xFF38BDF8) : const Color(0xFF5D4037))"
    )
    content = content.replace(
        "Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF3E2723)",
        "const Color(0xFF3E2723)"
    )
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5D4037)",
        "const Color(0xFF5D4037)"
    )

    # 8. specific ones in other screens
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Color(0xFF3E2723))",
        "isDark ? Colors.white70 : const Color(0xFF3E2723)"
    )
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Color(0xFFCBC3D4) : Color(0xFF5D4037))",
        "isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037)"
    )
    content = content.replace(
        "Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white70 : Color(0xFF3E2723))",
        "isDark ? Colors.white70 : const Color(0xFF3E2723)"
    )

    # Specific check for analytic_debug_screen subTextColor
    content = content.replace(
        "Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Color(0xFFCBC3D4) : Color(0xFF5D4037))",
        "isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037)"
    )

    # Specific check for prayer_wall_screen textThemeColor
    content = content.replace(
        "final textThemeColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));",
        "final textThemeColor = isDark ? Colors.white : const Color(0xFF3E2723);"
    )

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Reverted colors in {filepath}")
    else:
        print(f"No changes made to {filepath}")

screens = [
    "analytics_debug_screen.dart",
    "bible_screen.dart",
    "book_list_screen.dart",
    "bookmarked_verses_screen.dart",
    "bookmarks_screen.dart",
    "challenges_screen.dart",
    "chapter_list_screen.dart",
    "favorites_screen.dart",
    "highlights_screen.dart",
    "leaderboard_screen.dart",
    "main_screen.dart",
    "notes_screen.dart",
    "prayer_wall_screen.dart",
    "profile_screen.dart",
    "quiz_tab.dart",
    "reading_plan_screen.dart",
    "search_screen.dart",
    "wisdom_tree_screen.dart"
]

for screen in screens:
    path = os.path.join("/home/david/Music/Bible Quiz/lib/screens", screen)
    if os.path.exists(path):
        revert_file_colors(path)
