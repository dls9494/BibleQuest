import os

screens_dir = "/home/david/Music/Bible Quiz/lib/screens"
files_to_check = [
    "analytics_debug_screen.dart",
    "battle_screen.dart",
    "bookmarks_screen.dart",
    "challenges_screen.dart",
    "church_groups_screen.dart",
    "edit_profile_screen.dart",
    "favorites_screen.dart",
    "group_detail_screen.dart",
    "highlights_screen.dart",
    "leaderboard_screen.dart",
    "live_event_screen.dart",
    "memory_game_screen.dart",
    "notes_screen.dart",
    "prayer_wall_screen.dart",
    "profile_screen.dart",
    "quiz_tab.dart",
    "reading_plan_screen.dart",
    "search_screen.dart",
    "settings_screen.dart",
    "social_feed_screen.dart",
    "study_tools_screen.dart",
    "wisdom_tree_screen.dart"
]

for name in files_to_check:
    path = os.path.join(screens_dir, name)
    if not os.path.exists(path):
        continue
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Let's find lines around LinearGradient
    lines = content.splitlines()
    for idx, line in enumerate(lines):
        if "LinearGradient" in line and ("1A1A2E" in line or (idx > 0 and "1A1A2E" in lines[idx-1]) or (idx < len(lines)-1 and "1A1A2E" in lines[idx+1]) or "isDark" in line or (idx > 0 and "isDark" in lines[idx-1])):
            print(f"=== {name} (Line {idx+1}) ===")
            start = max(0, idx - 5)
            end = min(len(lines), idx + 10)
            for j in range(start, end):
                print(f"{j+1:4d}: {lines[j]}")
            print()
            break
