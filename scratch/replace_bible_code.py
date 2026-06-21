import os

file_path = "/home/david/Music/Bible Quiz/lib/screens/bible_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

start_idx = -1
for idx, line in enumerate(lines):
    if "if (_activeLabelingVerse == v.verse) ...[" in line and idx > 1800:
        start_idx = idx
        break

end_idx = -1
for idx, line in enumerate(lines):
    if "class _BookChapterSelectorDialog" in line:
        # Go backwards to find the closing brace of the state class
        for j in range(idx - 1, -1, -1):
            if lines[j].strip() == "}":
                end_idx = j
                break
        break

print(f"Start index: {start_idx} (Line {start_idx + 1}): {lines[start_idx] if start_idx != -1 else 'Not found'}")
print(f"End index: {end_idx} (Line {end_idx + 1}): {lines[end_idx] if end_idx != -1 else 'Not found'}")

if start_idx == -1 or end_idx == -1:
    print("Could not find start or end index! Aborting.")
    exit(1)

# The new code to insert
new_code = """  Widget _buildVerseRow(BuildContext context, BibleVerse v, UserDataProvider userProvider, int? playingVerse) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final book = BibleService.getBookById(_selectedBookId);
    final bookNameEn = book?.nameEn ?? '';
    final bookNameTe = book?.nameTe ?? '';

    final showTelugu = _isBilingual || _selectedLanguage == 'telugu';
    final showEnglish = _isBilingual || _selectedLanguage == 'english';

    final isCurrentlyPlaying = playingVerse == v.verse;
    final isSelected = _selectedVerse == v.verse || isCurrentlyPlaying;
    final verseRef = '${_selectedBookId}_${_selectedChapter}_${v.verse}';
    final hasNotes = _chapterNotes.any((note) => note['verseNumber'] == v.verse);
    final label = _showLabels ? VerseLabels.getLabel(_selectedBookId, _selectedChapter, v.verse) : null;

    final labelColourHex = _labelledVerses[v.verse];
    Color? highlightColor;
    if (labelColourHex != null) {
      final normalizedHex = labelColourHex.replaceAll('#', '').toUpperCase();
      if (normalizedHex == 'FFD54F' || normalizedHex == 'FFC107') {
        highlightColor = const Color(0xFFFFD54F);
      } else if (normalizedHex == '90CAF9' || normalizedHex == '2196F3') {
        highlightColor = const Color(0xFF90CAF9);
      } else if (normalizedHex == 'A5D6A7' || normalizedHex == '4CAF50') {
        highlightColor = const Color(0xFFA5D6A7);
      } else if (normalizedHex == 'F48FB1' || normalizedHex == 'E91E63') {
        highlightColor = const Color(0xFFF48FB1);
      } else {
        try {
          highlightColor = Color(int.parse(labelColourHex.replaceAll('#', '0xFF')));
        } catch (_) {}
      }
    }

    return GestureDetector(
      onTap: () {
        if (_selectedVerse != null) {
          setState(() {
            _selectedVerse = null;
          });
        } else {
          setState(() {
            _barsVisible = !_barsVisible;
          });
        }
      },
      onLongPress: () {
        setState(() {
          _selectedVerse = v.verse;
          _barsVisible = false; // Hide top/bottom bars when action panel is shown
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withValues(alpha: 0.15)
              : (highlightColor != null
                  ? highlightColor.withValues(alpha: 0.15)
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  width: 1.5,
                )
              : Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Telugu text (always shown in Telugu or Bilingual)
            if (showTelugu)
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          _toSuperscript(v.verse),
                          style: TextStyle(
                            fontSize: 14.0,  // Slightly larger verse number (14.0)
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold, // Bold verse number
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' '),
                    if (label != null) ...[
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: VerseLabels.getLabelColor(label),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ],
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: v.textTe,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _fontSize,  // User-controlled base size (default 18px)
                        height: 1.8,        // Telugu line height 1.8
                        fontWeight: FontWeight.w400,  // Normal weight for verse body
                        fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'NotoSansTelugu',
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6.0),  // Space between Telugu and English (6.0px)
            // English text (bilingual sub-version)
            if (showEnglish)
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          _toSuperscript(v.verse),
                          style: TextStyle(
                            fontSize: 14.0,  // Slightly larger verse number (14.0)
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold, // Bold verse number
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' '),
                    if (label != null && !showTelugu) ...[
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: VerseLabels.getLabelColor(label),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ],
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: v.textKjv,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),  // 75% opacity white (brighter)
                        fontSize: 15.0,    // 15px for English
                        height: 1.6,       // English line height 1.6
                        fontWeight: FontWeight.w400,  // Light weight for verse body
                        fontStyle: FontStyle.italic,  // Italic for English
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
            if (hasNotes) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.sticky_note_2,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Note added',
                    style: TextStyle(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerseActionPanel(
    BuildContext context,
    int verseNum,
    UserDataProvider userProvider,
    String bookNameEn,
    String bookNameTe,
  ) {
    final v = _verses.firstWhere((element) => element.verse == verseNum, orElse: () => _verses.first);
    final verseRef = '${_selectedBookId}_${_selectedChapter}_${v.verse}';
    final isBookmarked = userProvider.isVerseBookmarked(verseRef);
    final isFavorited = _favoritedVerses.contains(v.verse);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF132038).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header indicating which verse is selected
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$bookNameEn ($bookNameTe) ${_selectedChapter}:${v.verse}',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVerse = null;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white60,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Highlighter colors row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPanelColorOption(v, 'FFD54F', const Color(0xFFFFD54F)),
                  _buildPanelColorOption(v, '90CAF9', const Color(0xFF90CAF9)),
                  _buildPanelColorOption(v, 'A5D6A7', const Color(0xFFA5D6A7)),
                  _buildPanelColorOption(v, 'F48FB1', const Color(0xFFF48FB1)),
                  // Clear highlight button
                  GestureDetector(
                    onTap: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        await FirebaseService.removeLabelledVerse(uid, _selectedBookId, _selectedChapter, v.verse);
                        if (mounted) {
                          setState(() {
                            _labelledVerses.remove(v.verse);
                          });
                        }
                      }
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.format_color_reset,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 24),
              // Action Buttons Row (Bookmark, Favorite, Note, Copy, Share)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bookmark Toggle
                  _buildPanelActionButton(
                    icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    label: 'Bookmark',
                    color: isBookmarked ? const Color(0xFFFFD700) : Colors.white70,
                    onTap: () {
                      userProvider.toggleVerseBookmark(verseRef);
                      setState(() {});
                    },
                  ),
                  // Favorite Toggle
                  _buildPanelActionButton(
                    icon: isFavorited ? Icons.star : Icons.star_border,
                    label: 'Favorite',
                    color: isFavorited ? const Color(0xFFFFD700) : Colors.white70,
                    onTap: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in to favorite verses.')),
                        );
                        return;
                      }
                      final verseText = _selectedLanguage == 'telugu' ? v.textTe : v.textKjv;
                      await FirebaseService.toggleFavoriteVerse(uid, _selectedBookId, _selectedChapter, v.verse, verseText);
                      if (mounted) {
                        setState(() {
                          if (_favoritedVerses.contains(v.verse)) {
                            _favoritedVerses.remove(v.verse);
                          } else {
                            _favoritedVerses.add(v.verse);
                          }
                        });
                      }
                    },
                  ),
                  // Add/Edit Note
                  _buildPanelActionButton(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Note',
                    onTap: () {
                      _showNotesSheet(initialVerse: v.verse);
                    },
                  ),
                  // Copy Verse Text
                  _buildPanelActionButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: () {
                      final copyText = '${bookNameEn} ${bookNameTe} ${_selectedChapter}:${v.verse}\n\nTelugu: ${v.textTe}\n\nEnglish: ${v.textKjv}';
                      Clipboard.setData(ClipboardData(text: copyText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verse copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  // Share verse
                  _buildPanelActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: () {
                      VerseShareCard.shareVerse(
                        context: context,
                        bookNameEn: bookNameEn,
                        bookNameTe: bookNameTe,
                        chapter: _selectedChapter,
                        verse: v.verse,
                        textTe: v.textTe,
                        textEn: v.textKjv,
                        mode: _isBilingual
                            ? 'bilingual'
                            : _selectedLanguage == 'telugu'
                                ? 'te'
                                : 'kjv',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelColorOption(BibleVerse v, String hex, Color color) {
    final currentLabel = _labelledVerses[v.verse];
    final isSelected = currentLabel == hex || currentLabel == '#$hex';
    return GestureDetector(
      onTap: () async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to highlight verses.')),
          );
          return;
        }

        if (isSelected) {
          await FirebaseService.removeLabelledVerse(uid, _selectedBookId, _selectedChapter, v.verse);
          if (mounted) {
            setState(() {
              _labelledVerses.remove(v.verse);
            });
          }
        } else {
          await FirebaseService.addLabelledVerse(uid, _selectedBookId, _selectedChapter, v.verse, hex);
          if (mounted) {
            setState(() {
              _labelledVerses[v.verse] = hex;
            });
          }
        }
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
              : null,
        ),
      ),
    );
  }

  Widget _buildPanelActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white70,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
"""

# Replace lines from start_idx to end_idx (inclusive) with new_code
lines[start_idx:end_idx + 1] = [new_code + "\n"]

with open(file_path, "w", encoding="utf-8") as f:
    f.writelines(lines)

print("Code replacement completed successfully!")
