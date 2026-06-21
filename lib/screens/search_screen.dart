import '../widgets/gradient_background.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../providers/locale_provider.dart';
import '../features/bible/providers/bible_providers.dart';
import '../services/bible_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedVersion = 'all';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final localeProvider = provider_pkg.Provider.of<LocaleProvider>(context, listen: false);
      _selectedVersion = localeProvider.activeVersion;
    } catch (_) {}
  }
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.trim().length >= 2) {
        ref.read(searchProvider.notifier).search(_selectedVersion, query.trim());
      } else {
        ref.read(searchProvider.notifier).clear();
      }
    });
  }

  void _onVersionChanged(String? newVersion) {
    if (newVersion != null) {
      setState(() {
        _selectedVersion = newVersion;
      });
      if (newVersion != 'all') {
        try {
          provider_pkg.Provider.of<LocaleProvider>(context, listen: false).setActiveVersion(newVersion);
        } catch (_) {}
      }
      if (_controller.text.trim().length >= 2) {
        ref.read(searchProvider.notifier).search(newVersion, _controller.text.trim());
      }
    }
  }

  Widget _buildHighlightedText(String text, String query, bool isTelugu, Color normalColor) {
    if (query.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: normalColor,
          fontSize: 14,
          fontFamily: isTelugu ? 'NotoSansTelugu' : 'Outfit',
          height: isTelugu ? 1.6 : 1.4,
        ),
      );
    }

    final matches = RegExp(RegExp.escape(query), caseSensitive: false).allMatches(text);
    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: normalColor,
          fontSize: 14,
          fontFamily: isTelugu ? 'NotoSansTelugu' : 'Outfit',
          height: isTelugu ? 1.6 : 1.4,
        ),
      );
    }

    final List<TextSpan> spans = [];
    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          backgroundColor: Color(0xFFFFD700),
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ));
      lastIndex = match.end;
    }
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: TextStyle(
        color: normalColor,
        fontSize: 14,
        fontFamily: isTelugu ? 'NotoSansTelugu' : 'Outfit',
        height: isTelugu ? 1.6 : 1.4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Color(0xFF5D4037));

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
                        "Search Bible 🔍",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const Spacer(),
                      _buildVersionDropdown(context, textColor),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),

                // Search field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: textColor, fontFamily: 'Outfit'),
                      decoration: InputDecoration(
                        hintText: "Enter 2+ characters to search...",
                        hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.5), fontFamily: 'Outfit'),
                        prefixIcon: Icon(Icons.search, color: subTextColor.withValues(alpha: 0.5)),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: subTextColor.withValues(alpha: 0.5)),
                                onPressed: () {
                                  setState(() {
                                    _controller.clear();
                                  });
                                  ref.read(searchProvider.notifier).clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),

                Expanded(
                  child: _controller.text.trim().length < 2
                      ? _buildEmptyState(
                          icon: Icons.search_rounded,
                          title: "Search the Scriptures",
                          description: "Enter a keyword or phrase to search all verses in the selected version.",
                          textColor: textColor,
                          subTextColor: subTextColor,
                        )
                      : searchAsync.when(
                          data: (results) {
                            if (results.isEmpty) {
                              return _buildEmptyState(
                                icon: Icons.find_in_page_outlined,
                                title: "No Results Found",
                                description: "We couldn't find any verses matching '${_controller.text}'. Try another word.",
                                textColor: textColor,
                                subTextColor: subTextColor,
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final res = results[index];
                                final bookName = res.bookName;
                                final chapter = res.chapter;
                                final verse = res.verse;
                                final text = res.text;
                                final version = res.version;

                                final metadataBook = BibleService.getBooks().firstWhere(
                                  (book) => book.id == bookName.toLowerCase().replaceAll(' ', ''),
                                  orElse: () => BibleBook(
                                      id: bookName.toLowerCase().replaceAll(' ', ''),
                                      nameEn: bookName,
                                      nameTe: '',
                                      chapters: 1,
                                      testament: 'OT'),
                                );

                                final reference = '${metadataBook.nameEn} $chapter:$verse';
                                final isTe = version.startsWith('telugu') || RegExp(r'[\u0c00-\u0c7f]').hasMatch(text);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12.0),
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
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        reference,
                                                        style: TextStyle(
                                                          color: isDark ? const Color(0xFFFFD700) : const Color(0xFFB58D00),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          fontFamily: 'Outfit',
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          version.toUpperCase().replaceAll('_', ' '),
                                                          style: TextStyle(
                                                            color: subTextColor.withValues(alpha: 0.6),
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'Outfit',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _buildHighlightedText(
                                                    text,
                                                    _controller.text.trim(),
                                                    isTe,
                                                    textColor.withValues(alpha: 0.9),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                            ),
                          ),
                          error: (err, stack) => Center(
                            child: Text(
                              'Error: $err',
                              style: TextStyle(color: textColor, fontFamily: 'Outfit'),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionDropdown(BuildContext context, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: isDark ? const Color(0xFF1E1E30) : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVersion,
          icon: Icon(Icons.arrow_drop_down, color: textColor, size: 20),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: 'Outfit',
          ),
          onChanged: _onVersionChanged,
          items: [
            DropdownMenuItem(
              value: 'all',
              child: Text('All Versions', style: TextStyle(color: textColor)),
            ),
            DropdownMenuItem(
              value: 'telugu_ov',
              child: Text('Telugu OV', style: TextStyle(color: textColor)),
            ),
            DropdownMenuItem(
              value: 'telugu_wbtc',
              child: Text('Telugu WBTC', style: TextStyle(color: textColor)),
            ),
            DropdownMenuItem(
              value: 'telugu_irv',
              child: Text('Telugu IRV', style: TextStyle(color: textColor)),
            ),
            DropdownMenuItem(
              value: 'kjv',
              child: Text('KJV', style: TextStyle(color: textColor)),
            ),
            DropdownMenuItem(
              value: 'asv',
              child: Text('ASV', style: TextStyle(color: textColor)),
            ),
            DropdownMenuItem(
              value: 'web',
              child: Text('WEB', style: TextStyle(color: textColor)),
            ),
            DropdownMenuItem(
              value: 'darby',
              child: Text('Darby', style: TextStyle(color: textColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 70,
              color: subTextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
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
}
