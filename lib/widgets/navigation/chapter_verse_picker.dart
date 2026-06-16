import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/bible.dart';

/// Chapter/verse picker with premium UX design - sequential three-step flow
class ChapterVersePicker extends StatefulWidget {
  final BibleBook currentBook;
  final int initialChapter;
  final int initialVerse;
  final ValueChanged<int> onChapterSelected;
  final ValueChanged<int> onVerseSelected;
  final VoidCallback onDismissed;

  const ChapterVersePicker({
    Key? key,
    required this.currentBook,
    required this.initialChapter,
    required this.initialVerse,
    required this.onChapterSelected,
    required this.onVerseSelected,
    required this.onDismissed,
  }) : super(key: key);

  @override
  State<ChapterVersePicker> createState() => _ChapterVersePickerState();
}

enum PickerStep { book, chapter, verse }

class _ChapterVersePickerState extends State<ChapterVersePicker> {
  late PickerStep _step;
  late int _selectedChapter;
  late int _selectedVerse;

  @override
  void initState() {
    super.initState();
    _step = PickerStep.chapter;
    _selectedChapter = widget.initialChapter;
    _selectedVerse = widget.initialVerse;
  }

  void _onChapterTap(int chapter) {
    setState(() {
      _selectedChapter = chapter;
    });

    // Auto-advance to verse selection after 150ms
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _step = PickerStep.verse;
          _selectedVerse = 1; // Start at first verse
        });
      }
    });
  }

  void _onVerseTap(int verse) {
    setState(() {
      _selectedVerse = verse;
    });

    // Notify and dismiss after selection
    widget.onVerseSelected(_selectedVerse);
    Future.delayed(AppTheme.kAnimFast, () {
      widget.onDismissed();
    });
  }

  void _onBookTap() {
    // Reset to book selection (go back)
    setState(() {
      _step = PickerStep.book;
    });
    // Notify parent to show book picker
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = Colors.white.withValues(alpha: 0.45);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // BOOK tab
                Expanded(
                  child: InkWell(
                    onTap: _onBookTap,
                    child: Text(
                      'BOOK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (_step == PickerStep.book)
                            ? AppTheme.gold
                            : inactiveColor,
                      ),
                    ),
                  ),
                ),
                // CHAPTER tab
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_step != PickerStep.chapter) {
                        setState(() {
                          _step = PickerStep.chapter;
                        });
                      }
                    },
                    child: Text(
                      'CHAPTER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (_step == PickerStep.chapter)
                            ? AppTheme.gold
                            : inactiveColor,
                      ),
                    ),
                  ),
                ),
                // VERSE tab
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_step != PickerStep.verse && _selectedChapter > 0) {
                        setState(() {
                          _step = PickerStep.verse;
                        });
                      }
                    },
                    child: Text(
                      'VERSE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (_step == PickerStep.verse)
                            ? AppTheme.gold
                            : inactiveColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid content
          Expanded(
            child: AnimatedSwitcher(
              duration: AppTheme.kAnimMid,
              switchInCurve: AppTheme.kAnimCurve,
              switchOutCurve: AppTheme.kAnimCurve,
              child: _buildGridContent(isDark, textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridContent(bool isDark, Color textColor) {
    switch (_step) {
      case PickerStep.book:
        return const Center(child: Text('Book picker would go here'));
      case PickerStep.chapter:
        return _buildChapterGrid(isDark, textColor);
      case PickerStep.verse:
        return _buildVerseGrid(isDark, textColor);
    }
  }

  Widget _buildChapterGrid(bool isDark, Color textColor) {
    final int totalChapters = widget.currentBook.chapters;
    final List<Widget> children = [];

    for (int i = 1; i <= totalChapters; i++) {
      final bool isSelected = i == _selectedChapter;
      final bool isInCurrentRow = ((i - 1) % AppTheme.pickerGridColumns) == 0;

      children.add(
        AnimatedContainer(
          key: ValueKey<int>(i),
          duration: AppTheme.kAnimFast,
          curve: AppTheme.kAnimCurve,
          margin: EdgeInsets.symmetric(
            horizontal: isSelected ? 0 : 4,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.gold.withValues(alpha: AppTheme.pickerSelectedGlowOpacity)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
                AppTheme.pickerSelectedPillHorizontalPadding / 2),
            border: isSelected
                ? Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: InkWell(
            onTap: () => _onChapterTap(i),
            borderRadius: BorderRadius.circular(
                AppTheme.pickerSelectedPillHorizontalPadding / 2),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.pickerSelectedPillHorizontalPadding,
                vertical: AppTheme.pickerSelectedPillVerticalPadding,
              ),
              child: Center(
                child: Text(
                  '$i',
                  style: TextStyle(
                    fontSize: AppTheme.pickerUnselectedFontSize,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : textColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
        ));

      // Add wrapping logic for 6 columns
      if (!isInCurrentRow && i < totalChapters) {
        // We'll handle wrapping in the grid layout instead
      }
    }

    return GridView.count(
      crossAxisCount: AppTheme.pickerGridColumns,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }

  Widget _buildVerseGrid(bool isDark, Color textColor) {
    // For simplicity, we'll assume a max of 176 verses (Psalms 119)
    // In reality, this should come from the BibleService
    final int totalVerses = 176;
    final List<Widget> children = [];

    for (int i = 1; i <= totalVerses; i++) {
      final bool isSelected = i == _selectedVerse;

      children.add(
        AnimatedContainer(
          key: ValueKey<int>(i),
          duration: AppTheme.kAnimFast,
          curve: AppTheme.kAnimCurve,
          margin: EdgeInsets.symmetric(
            horizontal: isSelected ? 0 : 4,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.gold.withValues(alpha: AppTheme.pickerSelectedGlowOpacity)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
                AppTheme.pickerSelectedPillHorizontalPadding / 2),
            border: isSelected
                ? Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: InkWell(
            onTap: () => _onVerseTap(i),
            borderRadius: BorderRadius.circular(
                AppTheme.pickerSelectedPillHorizontalPadding / 2),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.pickerSelectedPillHorizontalPadding,
                vertical: AppTheme.pickerSelectedPillVerticalPadding,
              ),
              child: Center(
                child: Text(
                  '$i',
                  style: TextStyle(
                    fontSize: AppTheme.pickerUnselectedFontSize,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : textColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
        ));
    }

    return GridView.count(
      crossAxisCount: AppTheme.pickerGridColumns,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }
}