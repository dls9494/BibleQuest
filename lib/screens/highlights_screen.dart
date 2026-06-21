import '../widgets/gradient_background.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/user_data/providers/user_data_providers.dart';
import '../features/bible/providers/bible_providers.dart';
import '../services/bible_service.dart';

class HighlightsScreen extends ConsumerStatefulWidget {
  const HighlightsScreen({super.key});

  @override
  ConsumerState<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends ConsumerState<HighlightsScreen> {
  String _selectedColorFilter = 'All';

  final List<String> _colorFilters = ['All', 'Yellow', 'Green', 'Blue', 'Pink', 'Orange'];

  Color _getColorForName(String name) {
    switch (name) {
      case 'Yellow':
        return const Color(0xFFFFD54F);
      case 'Green':
        return const Color(0xFFA5D6A7);
      case 'Blue':
        return const Color(0xFF90CAF9);
      case 'Pink':
        return const Color(0xFFF48FB1);
      case 'Orange':
        return const Color(0xFFFFB74D);
      default:
        return Colors.white;
    }
  }

  String _getColorNameFromHex(String hex) {
    final h = hex.toUpperCase().replaceAll('#', '');
    if (h.contains('D54F') || h.contains('EB3B') || h.contains('C107') || h.startsWith('FFD') || h.startsWith('FFE')) {
      return 'Yellow';
    }
    if (h.contains('90CA') || h.contains('96F3') || h.startsWith('90C') || h.startsWith('219')) {
      return 'Blue';
    }
    if (h.contains('D6A7') || h.contains('AF50') || h.startsWith('A5D') || h.startsWith('4CA')) {
      return 'Green';
    }
    if (h.contains('8FB1') || h.contains('1E63') || h.startsWith('F48') || h.startsWith('E91')) {
      return 'Pink';
    }
    if (h.contains('B74D') || h.contains('9800') || h.startsWith('FFB') || h.startsWith('FF9')) {
      return 'Orange';
    }
    return 'Yellow'; // default
  }

  @override
  Widget build(BuildContext context) {
    final highlights = ref.watch(highlightsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Color(0xFF5D4037));

    // Filter highlights
    final filteredHighlights = highlights.where((h) {
      if (_selectedColorFilter == 'All') return true;
      final colorHex = h['color'] as String? ?? '';
      return _getColorNameFromHex(colorHex) == _selectedColorFilter;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GradientBackground(child: SizedBox.shrink())),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                        onPressed: () => context.go('/home'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "My Highlights 🎨",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),

                // Color filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: _colorFilters.map((colorName) {
                      final isSelected = _selectedColorFilter == colorName;
                      final chipColor = _getColorForName(colorName);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedColorFilter = colorName;
                              });
                            }
                          },
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (colorName != 'All') ...[
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: chipColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24, width: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(colorName),
                            ],
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : textColor,
                            fontFamily: 'Outfit',
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white10,
                          selectedColor: colorName == 'All' ? const Color(0xFFFFD700) : chipColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : Colors.white24,
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Highlights List
                Expanded(
                  child: filteredHighlights.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.border_color_outlined,
                                  size: 70,
                                  color: subTextColor.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No Highlights Found",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedColorFilter == 'All'
                                      ? "Press and hold a verse in the Bible reader, then select a highlight color to save it here."
                                      : "No verses highlighted in $_selectedColorFilter.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subTextColor,
                                    fontFamily: 'Outfit',
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: filteredHighlights.length,
                          itemBuilder: (context, index) {
                            final h = filteredHighlights[index];
                            final id = h['id'] as String;
                            final version = h['version'] as String;
                            final bookName = h['book_name'] as String;
                            final chapter = h['chapter'] as int;
                            final verse = h['verse'] as int;
                            final colorHex = h['color'] as String;

                            final metadataBook = BibleService.getBooks().firstWhere(
                              (book) => book.id == bookName.toLowerCase().replaceAll(' ', ''),
                              orElse: () => BibleBook(
                                id: bookName.toLowerCase().replaceAll(' ', ''),
                                nameEn: bookName,
                                nameTe: '',
                                chapters: 1,
                                testament: 'OT',
                              ),
                            );

                            final reference = '${metadataBook.nameEn} $chapter:$verse';
                            final colorValue = int.tryParse(colorHex.replaceFirst('#', '0xFF')) ?? 0xFFFFD700;
                            final highlightColor = Color(colorValue);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: Dismissible(
                                key: Key(id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  ref.read(highlightsProvider.notifier).deleteHighlight(id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Removed highlight for $reference"),
                                    ),
                                  );
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade900,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? Colors.white12 : const Color(0xFFD4A574).withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          onTap: () {
                                            context.push('/bible/$version/$bookName/$chapter?verse=$verse');
                                          },
                                          borderRadius: BorderRadius.circular(16),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    // Colored dot
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: highlightColor,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: highlightColor.withValues(alpha: 0.5),
                                                            blurRadius: 4,
                                                            spreadRadius: 1,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      reference,
                                                      style: TextStyle(
                                                        color: textColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        fontFamily: 'Outfit',
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      version.toUpperCase().replaceAll('_', ' '),
                                                      style: TextStyle(
                                                        color: subTextColor.withValues(alpha: 0.5),
                                                        fontSize: 11,
                                                        fontFamily: 'Outfit',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                // Verse text snippet loaded dynamically
                                                _HighlightVerseTextSnippet(
                                                  version: version,
                                                  bookName: bookName,
                                                  chapter: chapter,
                                                  verse: verse,
                                                  textColor: subTextColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightVerseTextSnippet extends ConsumerWidget {
  final String version;
  final String bookName;
  final int chapter;
  final int verse;
  final Color textColor;

  const _HighlightVerseTextSnippet({
    required this.version,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verseAsync = ref.watch(verseProvider((version, bookName, chapter, verse)));

    return verseAsync.when(
      data: (bibleVerse) {
        if (bibleVerse == null) {
          return Text(
            "Loading text...",
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          );
        }
        final isTelugu = version.startsWith('telugu') || RegExp(r'[\u0c00-\u0c7f]').hasMatch(bibleVerse.text);
        return Text(
          bibleVerse.text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            height: isTelugu ? 1.6 : 1.4,
            fontFamily: isTelugu ? 'NotoSansTelugu' : 'Outfit',
          ),
        );
      },
      loading: () => Container(
        height: 14,
        width: 150,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      error: (_, __) => Text(
        "Failed to load verse text",
        style: TextStyle(
          color: Colors.red.withValues(alpha: 0.5),
          fontSize: 13,
        ),
      ),
    );
  }
}
