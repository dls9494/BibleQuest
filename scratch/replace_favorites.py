path = "/home/david/Music/Bible Quiz/lib/screens/favorites_screen.dart"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Make the two replacements
pattern_1 = """        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF1A1A2E), Color(0xFF0F3460)]
                  : const [Color(0xFFFDF6EC), Color(0xFFF3E7D8)],
            ),
          ),
          child: Center("""

replacement_1 = """        body: GradientBackground(
          child: Center("""

pattern_2 = """      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF1A1A2E), Color(0xFF0F3460)]
                : const [Color(0xFFFDF6EC), Color(0xFFF3E7D8)],
          ),
        ),
        child: SafeArea("""

replacement_2 = """      body: GradientBackground(
        child: SafeArea("""

if pattern_1 in content and pattern_2 in content:
    content = content.replace(pattern_1, replacement_1)
    content = content.replace(pattern_2, replacement_2)
    # Add import
    if "gradient_background.dart" not in content:
        content = "import '../widgets/gradient_background.dart';\n" + content
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Success: favorites_screen.dart modified")
else:
    print("Error: patterns not found")
