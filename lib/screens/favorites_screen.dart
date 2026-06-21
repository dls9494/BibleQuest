import '../widgets/gradient_background.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/bible_service.dart';
import 'bible_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Map<String, String> _allLabelledVerses = {};
  bool _loadingLabels = true;

  @override
  void initState() {
    super.initState();
    _loadLabels();
  }

  Future<void> _loadLabels() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final labels = await FirebaseService.getAllLabelledVerses(uid);
        if (mounted) {
          setState(() {
            _allLabelledVerses = labels;
            _loadingLabels = false;
          });
        }
      } catch (e) {
        // ignore: avoid_print
        print("Error loading labels: $e");
        if (mounted) {
          setState(() => _loadingLabels = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => _loadingLabels = false);
      }
    }
  }

  Color? _getLabelColor(String bookId, int chapter, int verse) {
    final key = '${bookId}_${chapter}_$verse';
    final hex = _allLabelledVerses[key];
    if (hex == null) return null;
    if (hex == 'FFC107') return const Color(0xFFFFC107);
    if (hex == '2196F3') return const Color(0xFF2196F3);
    if (hex == '4CAF50') return const Color(0xFF4CAF50);
    if (hex == 'E91E63') return const Color(0xFFE91E63);
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Color(0xFF5D4037));
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        body: GradientBackground(
          child: Center(
            child: Text(
              'Please log in to view favorites',
              style: TextStyle(color: textColor, fontFamily: 'Outfit', fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "My Favorites ⭐",
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

              // Favorites Stream List
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirebaseService.getFavoritedVerses(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || _loadingLabels) {
                      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: textColor, fontFamily: 'Outfit'),
                        ),
                      );
                    }

                    final favorites = snapshot.data ?? [];

                    if (favorites.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_border_rounded,
                                size: 70,
                                color: subTextColor.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Favorites Yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap the star icon next to a verse in the Bible reader to save it here.",
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
                      );
                    }

                    // Group favorites by book and chapter
                    final Map<String, List<Map<String, dynamic>>> groupedFavorites = {};
                    for (final fav in favorites) {
                      final bookId = fav['bookId'] as String? ?? '';
                      final chapter = fav['chapter'] as int? ?? 1;
                      final groupKey = '$bookId|$chapter';
                      if (!groupedFavorites.containsKey(groupKey)) {
                        groupedFavorites[groupKey] = [];
                      }
                      groupedFavorites[groupKey]!.add(fav);
                    }

                    // Sort the group keys logically by bible canon order, then chapter number
                    final sortedGroupKeys = groupedFavorites.keys.toList();
                    final allBooks = BibleService.getBooks();
                    sortedGroupKeys.sort((a, b) {
                      final partsA = a.split('|');
                      final partsB = b.split('|');
                      final bookIdA = partsA[0];
                      final chapterA = int.tryParse(partsA[1]) ?? 1;
                      final bookIdB = partsB[0];
                      final chapterB = int.tryParse(partsB[1]) ?? 1;

                      final indexA = allBooks.indexWhere((b) => b.id == bookIdA);
                      final indexB = allBooks.indexWhere((b) => b.id == bookIdB);

                      if (indexA != indexB) {
                        return indexA.compareTo(indexB);
                      }
                      return chapterA.compareTo(chapterB);
                    });

                    // Sort verses within each group in ascending order
                    for (final key in groupedFavorites.keys) {
                      groupedFavorites[key]!.sort((a, b) {
                        final verseA = a['verse'] as int? ?? 1;
                        final verseB = b['verse'] as int? ?? 1;
                        return verseA.compareTo(verseB);
                      });
                    }

                    // Flatten into a list of items (either Group Header as String, or Favorite Map)
                    final List<dynamic> listItems = [];
                    for (final key in sortedGroupKeys) {
                      listItems.add(key); // Group Header
                      listItems.addAll(groupedFavorites[key]!); // Favorite Items
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await _loadLabels();
                      },
                      color: const Color(0xFFFFD700),
                      backgroundColor: isDark ? const Color(0xFF1E1E30) : Colors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: listItems.length,
                        itemBuilder: (context, index) {
                          final item = listItems[index];

                          if (item is String) {
                            final parts = item.split('|');
                            final bookId = parts[0];
                            final chapter = int.tryParse(parts[1]) ?? 1;
                            final book = BibleService.getBookById(bookId);
                            final bookName = book?.nameEn ?? bookId;

                            return Padding(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.book_rounded, color: Color(0xFFFFD700), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$bookName $chapter',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Divider(
                                      color: Colors.white24,
                                      thickness: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final favorite = item as Map<String, dynamic>;
                          final bookId = favorite['bookId'] as String? ?? '';
                          final chapter = favorite['chapter'] as int? ?? 1;
                          final verse = favorite['verse'] as int? ?? 1;
                          final verseText = favorite['verseText'] as String? ?? '';
                          final favoriteId = favorite['id'] as String? ?? '';

                          final book = BibleService.getBookById(bookId);
                          final bookName = book?.nameEn ?? bookId;
                          final reference = '$bookName $chapter:$verse';
                          final labelColor = _getLabelColor(bookId, chapter, verse);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            child: Dismissible(
                              key: Key(favoriteId),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) async {
                                await FirebaseService.toggleFavoriteVerse(
                                  uid,
                                  bookId,
                                  chapter,
                                  verse,
                                  verseText,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Removed $reference from favorites'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        textColor: const Color(0xFFFFD700),
                                        onPressed: () async {
                                          await FirebaseService.toggleFavoriteVerse(
                                            uid,
                                            bookId,
                                            chapter,
                                            verse,
                                            verseText,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BibleScreen(
                                                initialBook: bookId,
                                                initialChapter: chapter,
                                                initialVerse: verse,
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  if (labelColor != null) ...[
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: labelColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                  ],
                                                  Text(
                                                    reference,
                                                    style: const TextStyle(
                                                      color: Color(0xFFFFD700),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      fontFamily: 'Outfit',
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Icon(
                                                    Icons.chevron_right_rounded,
                                                    color: subTextColor.withValues(alpha: 0.5),
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                verseText,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: textColor.withValues(alpha: 0.9),
                                                  fontSize: 14,
                                                  fontFamily: 'Outfit',
                                                  height: 1.4,
                                                ),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
